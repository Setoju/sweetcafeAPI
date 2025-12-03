# spec/requests/api/v1/protected_access_spec.rb
require 'rails_helper'

RSpec.describe "Protected Access", type: :request do
  it "rejects unauthorized access to users list" do
    get "/api/v1/users"

    expect(response).to have_http_status(:unauthorized)
  end
end
