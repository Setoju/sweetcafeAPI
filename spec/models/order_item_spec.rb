require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }

    it 'belongs to menu_item optionally' do
      order_item = build(:order_item, menu_item: nil, order: create(:order))
      order_item.save(validate: false)
      expect(order_item.menu_item).to be_nil
    end

    it 'can have a menu_item' do
      order_item = build(:order_item)
      expect(order_item.menu_item).to be_present
    end
  end

  describe 'validations' do
    subject { build(:order_item) }

    context 'total_quantity validations' do
      it { is_expected.to validate_presence_of(:total_quantity) }
      it { is_expected.to allow_value(1).for(:total_quantity) }
      it { is_expected.to allow_value(50).for(:total_quantity) }
      it { is_expected.to allow_value(100).for(:total_quantity) }
      it { is_expected.not_to allow_value(0).for(:total_quantity) }
      it { is_expected.not_to allow_value(-1).for(:total_quantity) }
      it { is_expected.not_to allow_value(101).for(:total_quantity) }

      it 'validates total_quantity is an integer between 1 and 100' do
        order_item = build(:order_item, total_quantity: 50)
        expect(order_item).to be_valid

        order_item.total_quantity = 0
        expect(order_item).not_to be_valid

        order_item.total_quantity = 101
        expect(order_item).not_to be_valid
      end
    end

    context 'price validations' do
      it { is_expected.to validate_presence_of(:price) }
      it { is_expected.to allow_value(5.99).for(:price) }
      it { is_expected.to allow_value(100.00).for(:price) }
      it { is_expected.not_to allow_value(0).for(:price) }
      it { is_expected.not_to allow_value(-10).for(:price) }
      it { is_expected.not_to allow_value(10001).for(:price) }

      it 'validates price is greater than 0' do
        order_item = build(:order_item, price: 10.00)
        expect(order_item).to be_valid

        order_item.price = 0
        expect(order_item).not_to be_valid
      end
    end

    context 'subtotal validations' do
      it { is_expected.to allow_value(nil).for(:subtotal) }
      it { is_expected.not_to allow_value(0).for(:subtotal) }
      it { is_expected.not_to allow_value(-10).for(:subtotal) }

      it 'allows valid subtotal that matches calculation' do
        order_item = build(:order_item, price: 5.00, total_quantity: 2, subtotal: nil)
        order_item.save
        expect(order_item.subtotal).to eq(10.00)
        expect(order_item).to be_valid
      end
    end

    context 'order validation' do
      it { is_expected.to validate_presence_of(:order) }
    end

    context 'menu_item validation' do
      it 'validates presence on create' do
        order_item = build(:order_item, menu_item: nil)
        expect(order_item).not_to be_valid
        expect(order_item.errors[:menu_item]).to include("can't be blank")
      end

      it 'allows nil menu_item on existing records' do
        order_item = create(:order_item)
        order_item.menu_item = nil
        expect(order_item.valid?(:update)).to be true
      end
    end
  end

  describe 'callbacks' do
    context 'calculate_subtotal' do
      it 'calculates subtotal before save' do
        order_item = build(:order_item, price: 10.50, total_quantity: 3, subtotal: nil)
        order_item.save
        expect(order_item.subtotal).to eq(31.50)
      end
    end
  end

  describe 'custom validations' do
    context 'subtotal_matches_calculation' do
      it 'validates subtotal matches price × quantity' do
        order_item = create(:order_item, price: 10, total_quantity: 2)
        order_item.subtotal = 25

        expect(order_item).not_to be_valid
        expect(order_item.errors[:subtotal]).to include('does not match price × quantity (expected: 20.0)')
      end

      it 'allows correct subtotal calculation' do
        order_item = build(:order_item, price: 10, total_quantity: 2, subtotal: 20)
        expect(order_item).to be_valid
      end

      it 'allows subtotal to be nil' do
        order_item = build(:order_item, price: 10, total_quantity: 2, subtotal: nil)
        expect(order_item).to be_valid
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:order_item)).to be_valid
    end

    it 'creates order item with large quantity' do
      order_item = create(:order_item, :large_quantity)
      expect(order_item.total_quantity).to be >= 10
    end

    it 'creates order item with single item' do
      order_item = create(:order_item, :single_item)
      expect(order_item.total_quantity).to eq(1)
    end

    it 'automatically calculates subtotal' do
      order_item = create(:order_item, price: 15, total_quantity: 3)
      expect(order_item.subtotal).to eq(45)
    end

    it 'uses menu item price if not specified' do
      menu_item = create(:menu_item, price: 25.50)
      order_item = create(:order_item, menu_item: menu_item, total_quantity: 2)
      expect(order_item.price).to eq(25.50)
      expect(order_item.subtotal).to eq(51.00)
    end
  end
end
