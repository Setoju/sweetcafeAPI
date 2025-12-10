require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    context 'email validations' do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_length_of(:email).is_at_most(255) }
      it { is_expected.to allow_value('user@example.com').for(:email) }
      it { is_expected.to allow_value('test.user+tag@domain.co.uk').for(:email) }
      it { is_expected.not_to allow_value('invalid_email').for(:email) }
      it { is_expected.not_to allow_value('user@').for(:email) }
      it { is_expected.not_to allow_value('@example.com').for(:email) }

      it 'validates uniqueness of email (case insensitive)' do
        create(:user, email: 'TEST@example.com')
        duplicate_user = build(:user, email: 'test@example.com')
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include('has already been taken')
      end
    end

    context 'name validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(50) }
      it { is_expected.to allow_value('John Doe').for(:name) }
      it { is_expected.to allow_value('O\'Brien').for(:name) }
      it { is_expected.not_to allow_value('A').for(:name) }
    end

    context 'phone validations' do
      it { is_expected.to allow_value('+1234567890').for(:phone) }
      it { is_expected.to allow_value('(123) 456-7890').for(:phone) }
      it { is_expected.to allow_value('').for(:phone) }
      it { is_expected.to allow_value(nil).for(:phone) }
      it { is_expected.not_to allow_value('123').for(:phone).with_message('must be a valid phone number') }
      it { is_expected.not_to allow_value('abc').for(:phone).with_message('must be a valid phone number') }
    end

    context 'role validations' do
      it { is_expected.to validate_presence_of(:role) }
      it { is_expected.to allow_value('customer').for(:role) }
      it { is_expected.to allow_value('admin').for(:role) }
      it { is_expected.to allow_value('staff').for(:role) }
      it { is_expected.not_to allow_value('invalid_role').for(:role) }
    end

    context 'password validations' do
      it 'validates password presence on create for non-OAuth users' do
        user = build(:user, password: nil, password_confirmation: nil, provider: nil)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it 'validates password length minimum of 8 characters' do
        user = build(:user, password: 'Short1!', password_confirmation: 'Short1!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
      end

      it 'accepts valid password with complexity' do
        user = build(:user, password: 'SecurePass123!', password_confirmation: 'SecurePass123!')
        expect(user).to be_valid
      end

      it 'does not require password for OAuth users' do
        user = build(:user, :oauth_google, password: nil, password_confirmation: nil)
        expect(user).to be_valid
      end
    end
  end

  describe 'callbacks' do
    it 'normalizes email to lowercase before validation' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end

    it 'strips whitespace from email' do
      user = create(:user, email: '  user@example.com  ')
      expect(user.email).to eq('user@example.com')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'creates admin user with admin trait' do
      admin = create(:user, :admin)
      expect(admin.role).to eq('admin')
    end

    it 'creates staff user with staff trait' do
      staff = create(:user, :staff)
      expect(staff.role).to eq('staff')
    end

    it 'creates user with orders' do
      user = create(:user, :with_orders, orders_count: 3)
      expect(user.orders.count).to eq(3)
    end

    it 'creates user with cart items' do
      user = create(:user, :with_cart_items, cart_items_count: 2)
      expect(user.cart_items.count).to eq(2)
    end

    it 'creates OAuth user' do
      user = create(:user, :oauth_google)
      expect(user.provider).to eq('google')
      expect(user.uid).to be_present
      expect(user.oauth_token).to be_present
    end
  end

  describe '.from_google_oauth' do
    let(:google_user_info) do
      {
        'id' => '123456789',
        'email' => 'oauth@example.com',
        'name' => 'OAuth User'
      }
    end

    context 'when user does not exist' do
      it 'creates a new user with Google OAuth data' do
        user = User.from_google_oauth(google_user_info)
        user.save!

        expect(user.persisted?).to be true
        expect(user.email).to eq('oauth@example.com')
        expect(user.provider).to eq('google')
        expect(user.uid).to eq('123456789')
        expect(user.name).to eq('OAuth User')
      end
    end

    context 'when user exists with same email' do
      it 'links the existing account to Google OAuth' do
        existing_user = create(:user, email: 'oauth@example.com')

        user = User.from_google_oauth(google_user_info)
        user.save!

        existing_user.reload
        expect(existing_user.provider).to eq('google')
        expect(existing_user.uid).to eq('123456789')
      end
    end

    context 'when OAuth user already exists' do
      it 'returns the existing OAuth user' do
        existing_user = create(:user, :oauth_google, uid: '123456789', email: 'oauth@example.com')

        expect {
          found_user = User.from_google_oauth(google_user_info)
          expect(found_user.id).to eq(existing_user.id)
        }.not_to change(User, :count)
      end
    end
  end

  describe 'password authentication' do
    it 'authenticates with correct password' do
      user = create(:user, password: 'SecurePass123!', password_confirmation: 'SecurePass123!')
      expect(user.authenticate('SecurePass123!')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      user = create(:user, password: 'SecurePass123!', password_confirmation: 'SecurePass123!')
      expect(user.authenticate('WrongPassword')).to be_falsey
    end
  end
end
