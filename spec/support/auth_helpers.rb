module AuthHelpers
  def auth_headers(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  def login_user(user, password = 'SecurePass123!')
    post '/api/v1/auth/login', params: {
      email: user.email,
      password: password
    }
    json_response[:token]
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
