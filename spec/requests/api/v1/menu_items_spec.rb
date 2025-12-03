# spec/requests/api/v1/menu_items_spec.rb
require 'rails_helper'

RSpec.describe "Menu Items API", type: :request do
  let(:token) { login_as_admin_and_return_token }
  let(:category) { Category.create!(name: "Coffee", description: "Hot beverages") }

  it "filters menu items by category" do
    get "/api/v1/menu_items", params: { category_id: 1 }

    expect(response).to have_http_status(:ok)
  end

  it "creates a menu item" do
    post "/api/v1/menu_items",
      params: { menu_item: { name: "Latte", price: 55, category_id: category.id } },
      headers: auth_header(token)

    expect(response).to have_http_status(:created)
  end

  it "CRUD: show, update and delete menu item" do
    # CREATE
    post "/api/v1/menu_items",
      params: { menu_item: { name: "Mocha", price: 60, category_id: category.id } },
      headers: auth_header(token)

    id = JSON.parse(response.body)["menu_item"]["id"]

    # READ
    get "/api/v1/menu_items/#{id}"
    expect(response).to have_http_status(:ok)

    # UPDATE
    put "/api/v1/menu_items/#{id}",
      params: { menu_item: { name: "Mocha XL" } },
      headers: auth_header(token)

    expect(JSON.parse(response.body)["menu_item"]["name"]).to eq("Mocha XL")

    # DELETE
    delete "/api/v1/menu_items/#{id}", headers: auth_header(token)
    expect(response).to have_http_status(:ok)
  end
end
