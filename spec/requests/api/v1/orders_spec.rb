require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:category) { create(:category) }
  let(:menu_item1) { create(:menu_item, category: category, price: 10.00, available_quantity: 50) }
  let(:menu_item2) { create(:menu_item, category: category, price: 15.00, available_quantity: 30) }

  describe 'GET /api/v1/orders' do
    context 'with authentication' do
      before do
        create_list(:order, 3, :with_items, user: user, items_count: 2)
        create_list(:order, 2, :with_items, user: create(:user), items_count: 1)
      end

      it 'returns only current user orders' do
        get '/api/v1/orders', headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:orders].count).to eq(3)
      end

      it 'orders by created_at desc' do
        get '/api/v1/orders', headers: auth_headers(user)

        timestamps = json_response[:orders].map { |o| DateTime.parse(o[:created_at]) }
        expect(timestamps).to eq(timestamps.sort.reverse)
      end

      it 'filters orders by status' do
        user.orders.first.update(status: 'completed')
        user.orders.last.update(status: 'delivered')

        get '/api/v1/orders', params: { status: 'completed' }, headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:orders].count).to eq(1)
        expect(json_response[:orders].first[:status]).to eq('completed')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get '/api/v1/orders'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:errors]).to eq('Unauthorized')
      end
    end
  end

  describe 'GET /api/v1/orders/:id' do
    let(:order) { create(:order, :with_items, :with_delivery, user: user, items_count: 2) }

    context 'with authentication' do
      it 'returns detailed order information' do
        get "/api/v1/orders/#{order.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:order][:id]).to eq(order.id)
        expect(json_response[:order]).to have_key(:order_items)
        expect(json_response[:order]).to have_key(:delivery)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get "/api/v1/orders/#{order.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/orders' do
    let(:valid_order_params) do
      {
        notes: 'Please deliver ASAP',
        order_items: [
          { menu_item_id: menu_item1.id, total_quantity: 2 },
          { menu_item_id: menu_item2.id, total_quantity: 1 }
        ],
        delivery: {
          address: '123 Main St',
          city: 'New York',
          phone: '+1234567890',
          delivery_method: 'by courier',
          payment_method: 'cash',
          delivery_time: 2.hours.from_now
        }
      }
    end





    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/v1/orders', params: valid_order_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/orders/:id' do
    let(:order) { create(:order, :with_items, user: user, status: 'pending') }

    context 'updating order status' do
      it 'allows updating status to completed' do
        patch "/api/v1/orders/#{order.id}",
              params: { status: 'completed' },
              headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:order][:status]).to eq('completed')
      end

      it 'allows updating status to cancelled' do
        patch "/api/v1/orders/#{order.id}",
              params: { status: 'cancelled' },
              headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:order][:status]).to eq('cancelled')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        patch "/api/v1/orders/#{order.id}", params: { status: 'completed' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
