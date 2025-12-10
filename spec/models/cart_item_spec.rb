require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:menu_item) }
  end

  describe 'validations' do
    subject { build(:cart_item) }

    context 'total_quantity validations' do
      it { is_expected.to validate_presence_of(:total_quantity) }
      it { is_expected.to allow_value(1).for(:total_quantity) }
      it { is_expected.to allow_value(10).for(:total_quantity) }
      it { is_expected.not_to allow_value(0).for(:total_quantity) }
      it { is_expected.not_to allow_value(-1).for(:total_quantity) }

      it 'validates numericality with only_integer and greater_than 0' do
        cart_item = build(:cart_item, total_quantity: 5)
        expect(cart_item).to be_valid

        cart_item.total_quantity = 0
        expect(cart_item).not_to be_valid

        cart_item.total_quantity = -1
        expect(cart_item).not_to be_valid
      end
    end

    context 'user validation' do
      it { is_expected.to validate_presence_of(:user) }
    end

    context 'menu_item validation' do
      it { is_expected.to validate_presence_of(:menu_item) }
    end

    context 'uniqueness validation' do
      it 'validates uniqueness of menu_item_id scoped to user_id' do
        cart_item = create(:cart_item)
        duplicate = build(:cart_item, user: cart_item.user, menu_item: cart_item.menu_item)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:menu_item_id]).to include('is already in cart')
      end
    end
  end

  describe 'custom validations' do
    context 'menu_item_must_be_available' do
      it 'validates menu item is available' do
        unavailable_item = create(:menu_item, :unavailable)
        cart_item = build(:cart_item, menu_item: unavailable_item)

        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:menu_item]).to include('is not available')
      end

      it 'allows available menu items' do
        available_item = create(:menu_item, available: true)
        cart_item = build(:cart_item, menu_item: available_item)

        expect(cart_item).to be_valid
      end
    end

    context 'quantity_must_not_exceed_stock' do
      it 'validates quantity does not exceed available stock' do
        menu_item = create(:menu_item, available_quantity: 5)
        cart_item = build(:cart_item, menu_item: menu_item, total_quantity: 10)

        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:total_quantity]).to include('exceeds available stock (5 available)')
      end

      it 'allows quantity within stock limits' do
        menu_item = create(:menu_item, available_quantity: 10)
        cart_item = build(:cart_item, menu_item: menu_item, total_quantity: 5)

        expect(cart_item).to be_valid
      end

      it 'allows quantity equal to available stock' do
        menu_item = create(:menu_item, available_quantity: 10)
        cart_item = build(:cart_item, menu_item: menu_item, total_quantity: 10)

        expect(cart_item).to be_valid
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:cart_item)).to be_valid
    end

    it 'creates cart item with large quantity' do
      cart_item = create(:cart_item, :large_quantity)
      expect(cart_item.total_quantity).to be >= 5
    end

    it 'creates cart item with single item' do
      cart_item = create(:cart_item, :single_item)
      expect(cart_item.total_quantity).to eq(1)
    end

    it 'prevents duplicate cart items for same user and menu item' do
      cart_item = create(:cart_item)

      expect {
        create(:cart_item, user: cart_item.user, menu_item: cart_item.menu_item)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'dependent destroy' do
    it 'is destroyed when menu item is destroyed' do
      cart_item = create(:cart_item)
      menu_item = cart_item.menu_item

      expect {
        menu_item.destroy
      }.to change(CartItem, :count).by(-1)
    end

    it 'is destroyed when user is destroyed' do
      cart_item = create(:cart_item)
      user = cart_item.user

      expect {
        user.destroy
      }.to change(CartItem, :count).by(-1)
    end
  end
end
