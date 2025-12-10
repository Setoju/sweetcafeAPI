require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:order_items).dependent(:destroy) }
    it { is_expected.to have_one(:delivery).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:order) }

    context 'status validations' do
      it { is_expected.to validate_presence_of(:status) }
      it { is_expected.to allow_value('pending').for(:status) }
      it { is_expected.to allow_value('completed').for(:status) }
      it { is_expected.to allow_value('delivered').for(:status) }
      it { is_expected.to allow_value('cancelled').for(:status) }

      it 'does not allow invalid status values' do
        expect { build(:order, status: 'invalid') }.to raise_error(ArgumentError)
      end
    end

    context 'total_amount validations' do
      it { is_expected.to validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
      it { is_expected.to allow_value(nil).for(:total_amount) }
      it { is_expected.to allow_value(0).for(:total_amount) }
      it { is_expected.to allow_value(100.50).for(:total_amount) }
      it { is_expected.not_to allow_value(-10).for(:total_amount) }
      it { is_expected.not_to allow_value(1000001).for(:total_amount) }
    end

    context 'notes validations' do
      it { is_expected.to validate_length_of(:notes).is_at_most(1000) }
      it { is_expected.to allow_value('').for(:notes) }
      it { is_expected.to allow_value(nil).for(:notes) }
    end

    context 'user validation' do
      it { is_expected.to validate_presence_of(:user) }
    end
  end

  describe 'custom validations' do
    context 'must_have_order_items' do
      it 'validates order has at least one order item on update' do
        order = create(:order, :with_items, items_count: 1)
        order.order_items.destroy_all
        order.reload

        expect(order.update(notes: 'Updated notes')).to be false
        expect(order.errors[:base]).to include('Order must have at least one item')
      end

      it 'allows update when order has items' do
        order = create(:order, :with_items, items_count: 2)
        expect(order.update(notes: 'Updated notes')).to be true
      end
    end

    context 'total_amount_matches_items' do
      it 'validates total amount matches sum of order items' do
        order = create(:order)
        create(:order_item, order: order, price: 10, total_quantity: 2) # subtotal: 20
        create(:order_item, order: order, price: 15, total_quantity: 1) # subtotal: 15
        # Total should be 35

        order.reload
        order.total_amount = 50 # incorrect total

        expect(order).not_to be_valid
        expect(order.errors[:total_amount]).to include('does not match the sum of order items (expected: 35.0)')
      end

      it 'allows correct total amount' do
        order = create(:order)
        create(:order_item, order: order, price: 10, total_quantity: 2) # subtotal: 20
        create(:order_item, order: order, price: 15, total_quantity: 1) # subtotal: 15

        order.reload
        order.total_amount = 35

        expect(order).to be_valid
      end

      it 'allows nil total amount' do
        order = create(:order)
        create(:order_item, order: order, price: 10, total_quantity: 2)

        order.reload
        order.total_amount = nil

        expect(order).to be_valid
      end
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Order.statuses).to eq({
        'pending' => 'pending',
        'completed' => 'completed',
        'delivered' => 'delivered',
        'cancelled' => 'cancelled'
      })
    end

    it 'has pending as default status' do
      order = Order.new
      expect(order.status).to eq('pending')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:order)).to be_valid
    end

    it 'creates order with items' do
      order = create(:order, :with_items, items_count: 3)
      expect(order.order_items.count).to eq(3)
      expect(order.total_amount).to be_present
      expect(order.total_amount).to eq(order.order_items.sum(&:subtotal))
    end

    it 'creates order with delivery' do
      order = create(:order, :with_delivery)
      expect(order.delivery).to be_present
    end

    it 'creates pending order' do
      order = create(:order, :pending)
      expect(order.status).to eq('pending')
    end

    it 'creates completed order' do
      order = create(:order, :completed)
      expect(order.status).to eq('completed')
    end

    it 'creates delivered order' do
      order = create(:order, :delivered)
      expect(order.status).to eq('delivered')
    end

    it 'creates cancelled order' do
      order = create(:order, :cancelled)
      expect(order.status).to eq('cancelled')
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated order items when order is destroyed' do
      order = create(:order, :with_items, items_count: 3)

      expect {
        order.destroy
      }.to change(OrderItem, :count).by(-3)
    end

    it 'destroys associated delivery when order is destroyed' do
      order = create(:order, :with_delivery)

      expect {
        order.destroy
      }.to change(Delivery, :count).by(-1)
    end
  end
end
