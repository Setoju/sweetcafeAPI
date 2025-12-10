require 'rails_helper'

RSpec.describe 'Api::V1::CartItems', type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:menu_item) { create(:menu_item, category: category, price: 10.00, available_quantity: 50) }

  describe 'GET /api/v1/cart' do
    context 'with authentication' do
      before do
        create_list(:cart_item, 3, user: user)
      end

      it 'returns user cart items' do
        get '/api/v1/cart', headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:cart_items].count).to eq(3)
      end

      it 'returns total items count' do
        get '/api/v1/cart', headers: auth_headers(user)

        total_items = user.cart_items.sum(:total_quantity)
        expect(json_response[:total_items]).to eq(total_items)
      end

      it 'returns total price' do
        get '/api/v1/cart', headers: auth_headers(user)

        expect(json_response).to have_key(:total_price)
        expect(json_response[:total_price]).to be_a(Numeric)
      end

      it 'includes menu item details' do
        get '/api/v1/cart', headers: auth_headers(user)

        cart_item = json_response[:cart_items].first
        expect(cart_item).to have_key(:menu_item)
        expect(cart_item[:menu_item]).to have_key(:name)
        expect(cart_item[:menu_item]).to have_key(:price)
      end

      it 'returns empty cart for user with no items' do
        new_user = create(:user)
        get '/api/v1/cart', headers: auth_headers(new_user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:cart_items]).to be_empty
        expect(json_response[:total_items]).to eq(0)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get '/api/v1/cart'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:errors]).to eq('Unauthorized')
      end
    end
  end

  describe 'POST /api/v1/cart' do
    context 'adding new item to cart' do
      it 'creates a new cart item' do
        expect {
          post '/api/v1/cart',
               params: { menu_item_id: menu_item.id, total_quantity: 2 },
               headers: auth_headers(user)
        }.to change(CartItem, :count).by(1)
      end

      it 'returns created cart item' do
        post '/api/v1/cart',
             params: { menu_item_id: menu_item.id, total_quantity: 2 },
             headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect(json_response[:cart_item][:total_quantity]).to eq(2)
        expect(json_response[:message]).to eq('Item added to cart successfully')
      end

      it 'defaults to quantity 1 if not specified' do
        post '/api/v1/cart',
             params: { menu_item_id: menu_item.id },
             headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect(json_response[:cart_item][:total_quantity]).to eq(1)
      end
    end

    context 'updating existing cart item' do
      let!(:existing_cart_item) { create(:cart_item, user: user, menu_item: menu_item, total_quantity: 2) }

      it 'increases quantity instead of creating new item' do
        expect {
          post '/api/v1/cart',
               params: { menu_item_id: menu_item.id, total_quantity: 3 },
               headers: auth_headers(user)
        }.not_to change(CartItem, :count)
      end

      it 'updates the quantity correctly' do
        post '/api/v1/cart',
             params: { menu_item_id: menu_item.id, total_quantity: 3 },
             headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        existing_cart_item.reload
        expect(existing_cart_item.total_quantity).to eq(5) # 2 + 3
        expect(json_response[:message]).to eq('Cart item quantity updated')
      end
    end

    context 'validation errors' do
      it 'returns error when menu item not found' do
        post '/api/v1/cart',
             params: { menu_item_id: 99999, total_quantity: 1 },
             headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end

      it 'returns error when quantity exceeds stock' do
        low_stock_item = create(:menu_item, available_quantity: 5)

        post '/api/v1/cart',
             params: { menu_item_id: low_stock_item.id, total_quantity: 10 },
             headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error when item is unavailable' do
        unavailable_item = create(:menu_item, :unavailable)

        post '/api/v1/cart',
             params: { menu_item_id: unavailable_item.id, total_quantity: 1 },
             headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/v1/cart', params: { menu_item_id: menu_item.id, total_quantity: 1 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/cart/:id' do
    let(:cart_item) { create(:cart_item, user: user, total_quantity: 2) }

    context 'with valid parameters' do
      it 'updates cart item quantity' do
        patch "/api/v1/cart/#{cart_item.id}",
              params: { total_quantity: 5 },
              headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        cart_item.reload
        expect(cart_item.total_quantity).to eq(5)
        expect(json_response[:message]).to eq('Cart item updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns error for invalid quantity' do
        patch "/api/v1/cart/#{cart_item.id}",
              params: { total_quantity: 0 },
              headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error when quantity exceeds stock' do
        cart_item.menu_item.update(available_quantity: 3)

        patch "/api/v1/cart/#{cart_item.id}",
              params: { total_quantity: 5 },
              headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'cart item not found' do
      it 'returns not found error' do
        patch '/api/v1/cart/99999',
              params: { total_quantity: 5 },
              headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        patch "/api/v1/cart/#{cart_item.id}", params: { total_quantity: 5 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/cart/:id' do
    let!(:cart_item) { create(:cart_item, user: user) }

    context 'with authentication' do
      it 'deletes cart item' do
        expect {
          delete "/api/v1/cart/#{cart_item.id}", headers: auth_headers(user)
        }.to change(CartItem, :count).by(-1)
      end

      it 'returns success message' do
        delete "/api/v1/cart/#{cart_item.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq('Item removed from cart successfully')
      end

      it 'returns not found for non-existent cart item' do
        delete '/api/v1/cart/99999', headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete "/api/v1/cart/#{cart_item.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/cart/clear' do
    before do
      create_list(:cart_item, 5, user: user)
    end

    context 'with authentication' do
      it 'clears all cart items for user' do
        expect {
          delete '/api/v1/cart/clear', headers: auth_headers(user)
        }.to change { user.cart_items.count }.from(5).to(0)
      end

      it 'returns success message' do
        delete '/api/v1/cart/clear', headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq('Cart cleared successfully')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete '/api/v1/cart/clear'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
