require 'rails_helper'

RSpec.describe 'Api::V1::MenuItems', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:category) { create(:category) }

  describe 'GET /api/v1/menu_items' do
    before do
      create_list(:menu_item, 10, category: category)
    end

    it 'returns all menu items' do
      get '/api/v1/menu_items'

      expect(response).to have_http_status(:ok)
      expect(json_response[:menu_items]).to be_an(Array)
    end

    it 'includes category information' do
      get '/api/v1/menu_items'

      menu_item = json_response[:menu_items].first
      expect(menu_item[:category]).to have_key(:id)
      expect(menu_item[:category]).to have_key(:name)
    end

    it 'filters by category_id' do
      other_category = create(:category)
      create_list(:menu_item, 3, category: other_category)

      get '/api/v1/menu_items', params: { category_id: category.id }

      expect(response).to have_http_status(:ok)
      expect(json_response[:menu_items].count).to eq(10)
    end

    it 'filters by availability' do
      get '/api/v1/menu_items', params: { available: true }

      expect(response).to have_http_status(:ok)
      json_response[:menu_items].each do |item|
        expect(item[:available]).to be true
      end
    end

    it 'does not require authentication' do
      get '/api/v1/menu_items'

      expect(response).to have_http_status(:ok)
    end

    it 'returns menu item attributes' do
      get '/api/v1/menu_items'

      item = json_response[:menu_items].first
      expect(item).to have_key(:id)
      expect(item).to have_key(:name)
      expect(item).to have_key(:price)
      expect(item).to have_key(:size)
      expect(item).to have_key(:description)
      expect(item).to have_key(:available)
      expect(item).to have_key(:available_quantity)
      expect(item).to have_key(:image_url)
    end
  end

  describe 'GET /api/v1/menu_items/:id' do
    let(:menu_item) { create(:menu_item, category: category) }

    it 'returns detailed menu item information' do
      get "/api/v1/menu_items/#{menu_item.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response[:menu_item][:id]).to eq(menu_item.id)
      expect(json_response[:menu_item][:name]).to eq(menu_item.name)
    end

    it 'includes category details' do
      get "/api/v1/menu_items/#{menu_item.id}"

      expect(json_response[:menu_item][:category][:id]).to eq(category.id)
      expect(json_response[:menu_item][:category][:name]).to eq(category.name)
    end

    it 'returns not found for invalid id' do
      get '/api/v1/menu_items/99999'

      expect(response).to have_http_status(:not_found)
    end

    it 'does not require authentication' do
      get "/api/v1/menu_items/#{menu_item.id}"

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/menu_items' do
    let(:valid_params) do
      {
        menu_item: {
          name: Faker::Food.dish,
          description: Faker::Food.description,
          price: 15.99,
          size: '350',
          category_id: category.id,
          available: true,
          available_quantity: 50,
          image_url: 'https://example.com/image.jpg'
        }
      }
    end

    context 'with admin authentication' do
      it 'creates a new menu item' do
        expect {
          post '/api/v1/menu_items',
               params: valid_params,
               headers: auth_headers(admin)
        }.to change(MenuItem, :count).by(1)
      end

      it 'returns created menu item' do
        post '/api/v1/menu_items',
             params: valid_params,
             headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
        expect(json_response[:menu_item][:name]).to eq(valid_params[:menu_item][:name])
        expect(json_response[:menu_item][:price]).to eq(valid_params[:menu_item][:price])
        expect(json_response[:message]).to eq('Menu item created successfully')
      end

      it 'associates menu item with category' do
        post '/api/v1/menu_items',
             params: valid_params,
             headers: auth_headers(admin)

        menu_item = MenuItem.last
        expect(menu_item.category_id).to eq(category.id)
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing name' do
        post '/api/v1/menu_items',
             params: { menu_item: valid_params[:menu_item].except(:name) },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it 'returns error for invalid price' do
        post '/api/v1/menu_items',
             params: { menu_item: valid_params[:menu_item].merge(price: -10) },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for missing category' do
        post '/api/v1/menu_items',
             params: { menu_item: valid_params[:menu_item].except(:category_id) },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for duplicate name in same category' do
        existing_item = create(:menu_item, name: 'Cappuccino', category: category)

        post '/api/v1/menu_items',
             params: { menu_item: valid_params[:menu_item].merge(name: 'Cappuccino') },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for invalid image URL' do
        post '/api/v1/menu_items',
             params: { menu_item: valid_params[:menu_item].merge(image_url: 'not_a_url') },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for negative available_quantity' do
        post '/api/v1/menu_items',
             params: { menu_item: valid_params[:menu_item].merge(available_quantity: -5) },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/v1/menu_items', params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with non-admin user' do
      it 'returns forbidden error' do
        post '/api/v1/menu_items',
             params: valid_params,
             headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
        expect(json_response[:errors]).to eq('Admin access required')
      end
    end
  end

  describe 'PATCH /api/v1/menu_items/:id' do
    let(:menu_item) { create(:menu_item, category: category, price: 10.00) }
    let(:update_params) do
      {
        menu_item: {
          name: 'Updated Item',
          price: 12.99,
          available: false
        }
      }
    end

    context 'with admin authentication' do
      it 'updates menu item' do
        patch "/api/v1/menu_items/#{menu_item.id}",
              params: update_params,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        menu_item.reload
        expect(menu_item.name).to eq('Updated Item')
        expect(menu_item.price.to_f).to eq(12.99)
        expect(menu_item.available).to be false
        expect(json_response[:message]).to eq('Menu item updated successfully')
      end

      it 'allows partial updates' do
        patch "/api/v1/menu_items/#{menu_item.id}",
              params: { menu_item: { price: 15.00 } },
              headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        menu_item.reload
        expect(menu_item.price.to_f).to eq(15.00)
      end

      it 'updates available_quantity' do
        patch "/api/v1/menu_items/#{menu_item.id}",
              params: { menu_item: { available_quantity: 25 } },
              headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        menu_item.reload
        expect(menu_item.available_quantity).to eq(25)
      end

      it 'automatically marks unavailable when quantity is 0' do
        patch "/api/v1/menu_items/#{menu_item.id}",
              params: { menu_item: { available_quantity: 0 } },
              headers: auth_headers(admin)

        menu_item.reload
        expect(menu_item.available_quantity).to eq(0)
        expect(menu_item.available).to be false
      end
    end

    context 'with invalid parameters' do
      it 'returns error for invalid price' do
        patch "/api/v1/menu_items/#{menu_item.id}",
              params: { menu_item: { price: 0 } },
              headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for empty name' do
        patch "/api/v1/menu_items/#{menu_item.id}",
              params: { menu_item: { name: '' } },
              headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        patch "/api/v1/menu_items/#{menu_item.id}", params: update_params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with non-admin user' do
      it 'returns forbidden error' do
        patch "/api/v1/menu_items/#{menu_item.id}",
              params: update_params,
              headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/menu_items/:id' do
    let!(:menu_item) { create(:menu_item, category: category) }

    context 'with admin authentication' do
      it 'deletes menu item when no pending orders' do
        expect {
          delete "/api/v1/menu_items/#{menu_item.id}", headers: auth_headers(admin)
        }.to change(MenuItem, :count).by(-1)
      end

      it 'returns success message' do
        delete "/api/v1/menu_items/#{menu_item.id}", headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq('Menu item deleted successfully')
      end

      it 'prevents deletion when item has pending orders' do
        order = create(:order, :pending)
        create(:order_item, menu_item: menu_item, order: order)

        expect {
          delete "/api/v1/menu_items/#{menu_item.id}", headers: auth_headers(admin)
        }.not_to change(MenuItem, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('Cannot delete menu item. There are pending orders containing this item.')
      end

      it 'allows deletion when orders are completed' do
        order = create(:order, :completed)
        create(:order_item, menu_item: menu_item, order: order)

        expect {
          delete "/api/v1/menu_items/#{menu_item.id}", headers: auth_headers(admin)
        }.to change(MenuItem, :count).by(-1)
      end
    end

    context 'menu item not found' do
      it 'returns not found error' do
        delete '/api/v1/menu_items/99999', headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete "/api/v1/menu_items/#{menu_item.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with non-admin user' do
      it 'returns forbidden error' do
        delete "/api/v1/menu_items/#{menu_item.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
