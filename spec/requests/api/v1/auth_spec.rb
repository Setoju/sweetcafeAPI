require 'rails_helper'

RSpec.describe "Auth API", type: :request do
  describe "POST /api/v1/auth/signup" do
    it "creates a new user and returns JWT token" do
      post "/api/v1/auth/signup", params: {
        email: "test@test.com",
        name: "Test User",
        password: "password123"
      }

      expect(response).to have_http_status(:created)
      expect(json["token"]).to be_present
    end
  end

  describe "POST /api/v1/auth/login" do
    it "returns JWT token" do
      # Create user first
      User.create!(
        email: "test@test.com",
        name: "Test User",
        password: "password123",
        password_confirmation: "password123",
        role: "customer"
      )

      post "/api/v1/auth/login", params: {
        email: "test@test.com",
        password: "password123"
      }

      expect(response).to have_http_status(:ok)
      expect(json["token"]).to be_present
    end
  end
end
