# spec/requests/api/v1/categories_spec.rb
require 'rails_helper'

RSpec.describe "Categories API", type: :request do
  let(:token) { login_and_return_token }

  it "creates category successfully" do
    post "/api/v1/categories",
      params: { category: { name: "Coffee" } },
      headers: auth_header(token)

    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)["category"]["name"]).to eq("Coffee")
  end

  it "fails validation with empty name" do
    post "/api/v1/categories",
      params: { category: { name: "" } },
      headers: auth_header(token)

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
