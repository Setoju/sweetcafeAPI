require 'rails_helper'

RSpec.describe Delivery, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }
  end

  describe 'validations' do
    subject { build(:delivery, :by_courier) }

    context 'address validations for courier delivery' do
      it { is_expected.to validate_presence_of(:address) }
      it { is_expected.to validate_length_of(:address).is_at_least(2).is_at_most(50) }

      it 'does not require address for pickup' do
        delivery = build(:delivery, :pickup, address: nil)
        expect(delivery).to be_valid
      end
    end

    context 'city validations for courier delivery' do
      it { is_expected.to validate_presence_of(:city) }
      it { is_expected.to validate_length_of(:city).is_at_least(2).is_at_most(100) }
      it { is_expected.to allow_value('New York').for(:city) }
      it { is_expected.to allow_value("O'Connor").for(:city) }
      it { is_expected.to allow_value('Saint-Denis').for(:city) }
      it { is_expected.not_to allow_value('City123').for(:city) }
      it { is_expected.not_to allow_value('City@Name').for(:city) }

      it 'does not require city for pickup' do
        delivery = build(:delivery, :pickup, city: nil)
        expect(delivery).to be_valid
      end
    end

    context 'phone validations' do
      it { is_expected.to validate_presence_of(:phone) }
      it { is_expected.to allow_value('+1234567890').for(:phone) }
      it { is_expected.to allow_value('(123) 456-7890').for(:phone) }
      it { is_expected.to allow_value('123-456-7890').for(:phone) }
      it { is_expected.not_to allow_value('123').for(:phone) }
      it { is_expected.not_to allow_value('abc').for(:phone) }
    end

    context 'delivery_method validations' do
      it { is_expected.to allow_value('by courier').for(:delivery_method) }
      it { is_expected.to allow_value('pickup').for(:delivery_method) }
      it { is_expected.to allow_value('').for(:delivery_method) }
      it { is_expected.not_to allow_value('drone').for(:delivery_method) }
    end

    context 'payment_method validations' do
      it { is_expected.to allow_value('cash').for(:payment_method) }
      it { is_expected.to allow_value('card').for(:payment_method) }
      it { is_expected.to allow_value('online').for(:payment_method) }
      it { is_expected.to allow_value('').for(:payment_method) }
      it { is_expected.not_to allow_value('bitcoin').for(:payment_method) }
    end

    context 'delivery_status validations' do
      it { is_expected.to validate_presence_of(:delivery_status) }
      it { is_expected.to allow_value('pending').for(:delivery_status) }
      it { is_expected.to allow_value('in_transit').for(:delivery_status) }
      it { is_expected.to allow_value('delivered').for(:delivery_status) }

      it 'does not allow invalid delivery_status values' do
        expect { build(:delivery, delivery_status: 'cancelled') }.to raise_error(ArgumentError)
      end
    end

    context 'delivery_notes validations' do
      it { is_expected.to validate_length_of(:delivery_notes).is_at_most(50) }
      it { is_expected.to allow_value('').for(:delivery_notes) }
      it { is_expected.to allow_value(nil).for(:delivery_notes) }
    end

    context 'order validation' do
      it { is_expected.to validate_presence_of(:order) }
    end
  end

  describe 'custom validations' do
    context 'delivery_time_is_future' do
      it 'validates delivery_time is in the future on create' do
        delivery = build(:delivery, delivery_time: 1.hour.ago)

        expect(delivery).not_to be_valid
        expect(delivery.errors[:delivery_time]).to include('must be in the future')
      end

      it 'allows future delivery_time' do
        delivery = build(:delivery, delivery_time: 1.hour.from_now)
        expect(delivery).to be_valid
      end

      it 'allows nil delivery_time' do
        delivery = build(:delivery, :pickup, delivery_time: nil)
        expect(delivery).to be_valid
      end
    end

    context 'pickup_time_is_future' do
      it 'validates pickup_time is in the future on create' do
        delivery = build(:delivery, :pickup, pickup_time: 1.hour.ago)

        expect(delivery).not_to be_valid
        expect(delivery.errors[:pickup_time]).to include('must be in the future')
      end

      it 'allows future pickup_time' do
        delivery = build(:delivery, :pickup, pickup_time: 1.hour.from_now)
        expect(delivery).to be_valid
      end

      it 'allows nil pickup_time' do
        delivery = build(:delivery, :by_courier, pickup_time: nil)
        expect(delivery).to be_valid
      end
    end

    context 'delivered_at_when_delivered' do
      it 'requires delivered_at when status is delivered' do
        delivery = build(:delivery, delivery_status: 'delivered', delivered_at: nil)

        expect(delivery).not_to be_valid
        expect(delivery.errors[:delivered_at]).to include('must be set when delivery status is delivered')
      end

      it 'allows delivered_at when status is delivered' do
        delivery = build(:delivery, delivery_status: 'delivered', delivered_at: Time.current)
        expect(delivery).to be_valid
      end

      it 'allows nil delivered_at for non-delivered status' do
        delivery = build(:delivery, delivery_status: 'pending', delivered_at: nil)
        expect(delivery).to be_valid
      end
    end
  end

  describe 'enums' do
    it 'defines delivery_status enum' do
      expect(Delivery.delivery_statuses).to eq({
        'pending' => 'pending',
        'in_transit' => 'in_transit',
        'delivered' => 'delivered'
      })
    end

    it 'has pending as default delivery_status' do
      delivery = Delivery.new
      expect(delivery.delivery_status).to eq('pending')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:delivery)).to be_valid
    end

    it 'creates pickup delivery' do
      delivery = create(:delivery, :pickup)
      expect(delivery.delivery_method).to eq('pickup')
      expect(delivery.address).to be_nil
      expect(delivery.city).to be_nil
      expect(delivery.pickup_time).to be_present
    end

    it 'creates courier delivery' do
      delivery = create(:delivery, :by_courier)
      expect(delivery.delivery_method).to eq('by courier')
      expect(delivery.address).to be_present
      expect(delivery.city).to be_present
    end

    it 'creates delivery with cash payment' do
      delivery = create(:delivery, :cash_payment)
      expect(delivery.payment_method).to eq('cash')
    end

    it 'creates delivery with card payment' do
      delivery = create(:delivery, :card_payment)
      expect(delivery.payment_method).to eq('card')
    end

    it 'creates delivery with online payment' do
      delivery = create(:delivery, :online_payment)
      expect(delivery.payment_method).to eq('online')
    end

    it 'creates pending delivery' do
      delivery = create(:delivery, :pending)
      expect(delivery.delivery_status).to eq('pending')
      expect(delivery.delivered_at).to be_nil
    end

    it 'creates in_transit delivery' do
      delivery = create(:delivery, :in_transit)
      expect(delivery.delivery_status).to eq('in_transit')
    end

    it 'creates delivered delivery' do
      delivery = create(:delivery, :delivered)
      expect(delivery.delivery_status).to eq('delivered')
      expect(delivery.delivered_at).to be_present
    end
  end

  describe 'dependent destroy' do
    it 'is destroyed when order is destroyed' do
      delivery = create(:delivery)
      order = delivery.order

      expect {
        order.destroy
      }.to change(Delivery, :count).by(-1)
    end
  end
end
