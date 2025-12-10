require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to have_many(:order_items) }
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
  end

  describe 'validations' do
    let(:category) { create(:category) }
    subject { build(:menu_item, category: category) }

    context 'name validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(200) }

      it 'validates uniqueness of name scoped to category' do
        create(:menu_item, name: 'Cappuccino', category: category)
        duplicate_item = build(:menu_item, name: 'Cappuccino', category: category)
        expect(duplicate_item).not_to be_valid
        expect(duplicate_item.errors[:name]).to include('already exists in this category')
      end

      it 'allows same name in different categories' do
        other_category = create(:category)
        create(:menu_item, name: 'Cappuccino', category: category)
        duplicate_item = build(:menu_item, name: 'Cappuccino', category: other_category)
        expect(duplicate_item).to be_valid
      end
    end

    context 'price validations' do
      it { is_expected.to validate_presence_of(:price) }
      it { is_expected.to allow_value(5.99).for(:price) }
      it { is_expected.to allow_value(100.00).for(:price) }
      it { is_expected.not_to allow_value(0).for(:price) }
      it { is_expected.not_to allow_value(-10).for(:price) }
      it { is_expected.not_to allow_value(10001).for(:price) }

      it 'validates numericality is greater than 0' do
        menu_item = build(:menu_item, price: 10)
        expect(menu_item).to be_valid

        menu_item.price = 0
        expect(menu_item).not_to be_valid

        menu_item.price = -5
        expect(menu_item).not_to be_valid
      end
    end

    context 'size validations' do
      it { is_expected.to validate_presence_of(:size) }
      it { is_expected.to allow_value('250').for(:size) }
      it { is_expected.to allow_value('500').for(:size) }
      it { is_expected.not_to allow_value('0').for(:size) }
      it { is_expected.not_to allow_value('-100').for(:size) }

      it 'validates size is a positive integer' do
        menu_item = build(:menu_item, size: '100')
        expect(menu_item).to be_valid

        menu_item.size = '0'
        expect(menu_item).not_to be_valid
      end
    end

    context 'description validations' do
      it { is_expected.to validate_length_of(:description).is_at_most(1000) }
      it { is_expected.to allow_value('').for(:description) }
      it { is_expected.to allow_value(nil).for(:description) }
    end

    context 'image_url validations' do
      it { is_expected.to allow_value('').for(:image_url) }
      it { is_expected.to allow_value(nil).for(:image_url) }
      it { is_expected.to allow_value('http://example.com/image.jpg').for(:image_url) }
      it { is_expected.to allow_value('https://example.com/image.png').for(:image_url) }
      it { is_expected.not_to allow_value('not_a_url').for(:image_url) }
      it { is_expected.not_to allow_value('ftp://example.com/image.jpg').for(:image_url) }
    end

    context 'available validations' do
      it { is_expected.to allow_value(true).for(:available) }
      it { is_expected.to allow_value(false).for(:available) }
    end

    context 'available_quantity validations' do
      it { is_expected.to allow_value(0).for(:available_quantity) }
      it { is_expected.to allow_value(100).for(:available_quantity) }
      it { is_expected.not_to allow_value(-1).for(:available_quantity) }

      it 'validates available_quantity is a non-negative integer' do
        menu_item = build(:menu_item, available_quantity: 50)
        expect(menu_item).to be_valid

        menu_item.available_quantity = -1
        expect(menu_item).not_to be_valid
      end
    end

    context 'category validation' do
      it { is_expected.to validate_presence_of(:category) }
    end
  end

  describe 'callbacks' do
    context 'mark_unavailable_if_depleted' do
      it 'marks item as unavailable when quantity becomes 0' do
        menu_item = create(:menu_item, available: true, available_quantity: 5)
        menu_item.update(available_quantity: 0)
        expect(menu_item.available).to be false
      end

      it 'keeps item available when quantity is greater than 0' do
        menu_item = create(:menu_item, available: true, available_quantity: 5)
        menu_item.update(available_quantity: 3)
        expect(menu_item.available).to be true
      end

      it 'does not override manually set availability' do
        menu_item = create(:menu_item, available: true, available_quantity: 5)
        menu_item.update(available: false, available_quantity: 3)
        expect(menu_item.available).to be false
      end
    end
  end

  describe 'instance methods' do
    describe '#has_pending_orders?' do
      it 'returns true when item has pending orders' do
        menu_item = create(:menu_item)
        order = create(:order, :pending)
        create(:order_item, menu_item: menu_item, order: order)

        expect(menu_item.has_pending_orders?).to be true
      end

      it 'returns false when item has no pending orders' do
        menu_item = create(:menu_item)
        order = create(:order, :completed)
        create(:order_item, menu_item: menu_item, order: order)

        expect(menu_item.has_pending_orders?).to be false
      end

      it 'returns false when item has no orders' do
        menu_item = create(:menu_item)
        expect(menu_item.has_pending_orders?).to be false
      end
    end

    describe '#can_be_deleted?' do
      it 'returns false when item has pending orders' do
        menu_item = create(:menu_item)
        order = create(:order, :pending)
        create(:order_item, menu_item: menu_item, order: order)

        expect(menu_item.can_be_deleted?).to be false
      end

      it 'returns true when item has no pending orders' do
        menu_item = create(:menu_item)
        expect(menu_item.can_be_deleted?).to be true
      end
    end

    describe '#deletion_blocked_reason' do
      it 'returns reason when item has pending orders' do
        menu_item = create(:menu_item)
        order = create(:order, :pending)
        create(:order_item, menu_item: menu_item, order: order)

        expect(menu_item.deletion_blocked_reason).to eq('There are pending orders containing this item')
      end

      it 'returns nil when item can be deleted' do
        menu_item = create(:menu_item)
        expect(menu_item.deletion_blocked_reason).to be_nil
      end
    end
  end

  describe 'deletion prevention' do
    it 'prevents deletion when item has pending orders' do
      menu_item = create(:menu_item)
      order = create(:order, :pending)
      create(:order_item, menu_item: menu_item, order: order)

      expect {
        menu_item.destroy
      }.not_to change(MenuItem, :count)

      expect(menu_item.errors[:base]).to include('Cannot delete menu item. There are pending orders containing this item.')
    end

    it 'allows deletion when no pending orders exist' do
      menu_item = create(:menu_item)

      expect {
        menu_item.destroy
      }.to change(MenuItem, :count).by(-1)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:menu_item)).to be_valid
    end

    it 'creates unavailable menu item' do
      item = create(:menu_item, :unavailable)
      expect(item.available).to be false
      expect(item.available_quantity).to eq(0)
    end

    it 'creates low stock menu item' do
      item = create(:menu_item, :low_stock)
      expect(item.available_quantity).to be <= 5
    end

    it 'creates expensive menu item' do
      item = create(:menu_item, :expensive)
      expect(item.price).to be >= 100
    end

    it 'creates cheap menu item' do
      item = create(:menu_item, :cheap)
      expect(item.price).to be <= 10
    end
  end
end
