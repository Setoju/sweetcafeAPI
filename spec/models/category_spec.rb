require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:menu_items).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:category) }

    context 'name validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }

      it 'validates uniqueness of name (case insensitive)' do
        create(:category, name: 'BEVERAGES')
        duplicate_category = build(:category, name: 'beverages')
        expect(duplicate_category).not_to be_valid
        expect(duplicate_category.errors[:name]).to include('has already been taken')
      end

      it { is_expected.to allow_value('Beverages').for(:name) }
      it { is_expected.to allow_value('Coffee & Tea').for(:name) }
      it { is_expected.to allow_value("Baker's Choice").for(:name) }
      it { is_expected.to allow_value('Main-Courses').for(:name) }
      it { is_expected.not_to allow_value('Category!@#').for(:name) }
      it { is_expected.not_to allow_value('Category_Name').for(:name) }
    end

    context 'description validations' do
      it { is_expected.to validate_length_of(:description).is_at_most(500) }
      it { is_expected.to allow_value('').for(:description) }
      it { is_expected.to allow_value(nil).for(:description) }
      it { is_expected.to allow_value('A delicious category').for(:description) }
    end
  end

  describe 'callbacks' do
    it 'normalizes name by stripping whitespace' do
      category = create(:category, name: '  Beverages  ')
      expect(category.name).to eq('Beverages')
    end

    it 'squeezes multiple spaces in name' do
      category = create(:category, name: 'Hot    Beverages')
      expect(category.name).to eq('Hot Beverages')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:category)).to be_valid
    end

    it 'creates category with menu items' do
      category = create(:category, :with_menu_items, menu_items_count: 5)
      expect(category.menu_items.count).to eq(5)
    end

    it 'creates beverages category' do
      category = create(:category, :beverages)
      expect(category.name).to eq('Beverages')
      expect(category.description).to eq('Hot and cold drinks')
    end

    it 'creates desserts category' do
      category = create(:category, :desserts)
      expect(category.name).to eq('Desserts')
    end

    it 'creates main courses category' do
      category = create(:category, :main_courses)
      expect(category.name).to eq('Main Courses')
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated menu items when category is destroyed' do
      category = create(:category, :with_menu_items, menu_items_count: 3)
      menu_item_ids = category.menu_items.pluck(:id)

      expect {
        category.destroy
      }.to change(MenuItem, :count).by(-3)

      menu_item_ids.each do |id|
        expect(MenuItem.find_by(id: id)).to be_nil
      end
    end
  end
end
