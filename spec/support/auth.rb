module AuthHelper
  def login_and_return_token
    # Create a test user if it doesn't exist
    User.find_or_create_by!(email: "test@test.com") do |user|
      user.name = "Test User"
      user.password = "password123"
      user.password_confirmation = "password123"
      user.role = "customer"
    end

    post "/api/v1/auth/login", params: {
      email: "test@test.com",
      password: "password123"
    }
    json["token"]
  end

  def login_as_admin_and_return_token
    # Create an admin user if it doesn't exist
    User.find_or_create_by!(email: "admin@test.com") do |user|
      user.name = "Admin User"
      user.password = "password123"
      user.password_confirmation = "password123"
      user.role = "admin"
    end

    post "/api/v1/auth/login", params: {
      email: "admin@test.com",
      password: "password123"
    }
    json["token"]
  end

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper
end
