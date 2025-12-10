require 'rails_helper'

RSpec.describe 'Api::V1::Categories', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  describe 'GET /api/v1/categories' do
    before do
      Category.destroy_all
      create_list(:category, 5, :with_menu_items, menu_items_count: 3)
    end

    it 'returns all categories' do
      get '/api/v1/categories'

      expect(response).to have_http_status(:ok)
      expect(json_response[:categories].count).to eq(5)
    end

    it 'includes menu items count' do
      get '/api/v1/categories'

      category = json_response[:categories].first
      expect(category).to have_key(:menu_items_count)
      expect(category[:menu_items_count]).to eq(3)
    end

    it 'returns category attributes' do
      get '/api/v1/categories'

      category = json_response[:categories].first
      expect(category).to have_key(:id)
      expect(category).to have_key(:name)
      expect(category).to have_key(:description)
      expect(category).to have_key(:created_at)
      expect(category).to have_key(:updated_at)
    end

    it 'does not require authentication' do
      get '/api/v1/categories'

      expect(response).to have_http_status(:ok)
    end

    it 'returns empty array when no categories exist' do
      Category.destroy_all
      get '/api/v1/categories'

      expect(response).to have_http_status(:ok)
      expect(json_response[:categories]).to be_empty
    end
  end

  describe 'GET /api/v1/categories/:id' do
    let(:category) { create(:category, :with_menu_items, menu_items_count: 3) }

    it 'returns category with menu items' do
      get "/api/v1/categories/#{category.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response[:category][:id]).to eq(category.id)
      expect(json_response[:category][:menu_items]).to be_an(Array)
      expect(json_response[:category][:menu_items].count).to eq(3)
    end

    it 'includes detailed menu item information' do
      get "/api/v1/categories/#{category.id}"

      menu_item = json_response[:category][:menu_items].first
      expect(menu_item).to have_key(:id)
      expect(menu_item).to have_key(:name)
      expect(menu_item).to have_key(:description)
      expect(menu_item).to have_key(:price)
      expect(menu_item).to have_key(:available)
    end

    it 'returns not found for invalid id' do
      get '/api/v1/categories/99999'

      expect(response).to have_http_status(:not_found)
    end

    it 'does not require authentication' do
      get "/api/v1/categories/#{category.id}"

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/categories' do
    let(:valid_params) do
      {
        category: {
          name: Faker::Food.dish,
          description: Faker::Food.description
        }
      }
    end

    context 'with admin authentication' do
      it 'creates a new category' do
        expect {
          post '/api/v1/categories',
               params: valid_params,
               headers: auth_headers(admin)
        }.to change(Category, :count).by(1)
      end

      it 'returns created category' do
        post '/api/v1/categories',
             params: valid_params,
             headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
        expect(json_response[:category][:name]).to eq(valid_params[:category][:name])
        expect(json_response[:message]).to eq('Category created successfully')
      end

      it 'normalizes category name' do
        post '/api/v1/categories',
             params: { category: { name: '  Hot  Beverages  ', description: 'Test' } },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:created)
        expect(json_response[:category][:name]).to eq('Hot Beverages')
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing name' do
        post '/api/v1/categories',
             params: { category: { description: 'Test' } },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it 'returns error for duplicate name' do
        existing_category = create(:category, name: 'Beverages')

        post '/api/v1/categories',
             params: { category: { name: 'Beverages' } },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('Name has already been taken')
      end

      it 'returns error for too short name' do
        post '/api/v1/categories',
             params: { category: { name: 'A' } },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for invalid characters in name' do
        post '/api/v1/categories',
             params: { category: { name: 'Category@#$' } },
             headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/v1/categories', params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/categories/:id' do
    let(:category) { create(:category) }
    let(:update_params) do
      {
        category: {
          name: 'Updated Name',
          description: 'Updated description'
        }
      }
    end

    context 'with admin authentication' do
      it 'updates category' do
        patch "/api/v1/categories/#{category.id}",
              params: update_params,
              headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        category.reload
        expect(category.name).to eq('Updated Name')
        expect(category.description).to eq('Updated description')
        expect(json_response[:message]).to eq('Category updated successfully')
      end

      it 'allows partial updates' do
        patch "/api/v1/categories/#{category.id}",
              params: { category: { name: 'New Name Only' } },
              headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        category.reload
        expect(category.name).to eq('New Name Only')
      end
    end

    context 'with invalid parameters' do
      it 'returns error for duplicate name' do
        other_category = create(:category, name: 'Existing Category')

        patch "/api/v1/categories/#{category.id}",
              params: { category: { name: 'Existing Category' } },
              headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for empty name' do
        patch "/api/v1/categories/#{category.id}",
              params: { category: { name: '' } },
              headers: auth_headers(admin)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        patch "/api/v1/categories/#{category.id}", params: update_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/categories/:id' do
    let!(:category) { create(:category) }

    context 'with admin authentication' do
      it 'deletes category' do
        expect {
          delete "/api/v1/categories/#{category.id}", headers: auth_headers(admin)
        }.to change(Category, :count).by(-1)
      end

      it 'returns success message' do
        delete "/api/v1/categories/#{category.id}", headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq('Category deleted successfully')
      end

      it 'deletes associated menu items' do
        category_with_items = create(:category, :with_menu_items, menu_items_count: 5)

        expect {
          delete "/api/v1/categories/#{category_with_items.id}", headers: auth_headers(admin)
        }.to change(MenuItem, :count).by(-5)
      end
    end

    context 'category not found' do
      it 'returns not found error' do
        delete '/api/v1/categories/99999', headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete "/api/v1/categories/#{category.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
