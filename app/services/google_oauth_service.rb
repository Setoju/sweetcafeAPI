# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

class GoogleOauthService
  GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
  GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
  GOOGLE_USER_INFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo"

  def initialize
    @client_id = ENV["GOOGLE_CLIENT_ID"]
    @client_secret = ENV["GOOGLE_CLIENT_SECRET"]
    @redirect_uri = "#{ENV['API_BASE_URL']}/api/v1/auth/google/callback"
  end

  # Generate the Google OAuth authorization URL
  def authorization_url
    params = {
      client_id: @client_id,
      redirect_uri: @redirect_uri,
      response_type: "code",
      scope: "email profile",
      access_type: "offline",
      prompt: "consent"
    }

    "#{GOOGLE_AUTH_URL}?#{URI.encode_www_form(params)}"
  end

  # Exchange authorization code for access token
  def exchange_code_for_token(code)
    uri = URI(GOOGLE_TOKEN_URL)

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/x-www-form-urlencoded"

    request.set_form_data(
      code: code,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_uri,
      grant_type: "authorization_code"
    )

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    raise "Failed to exchange code: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  # Get user information from Google
  def get_user_info(access_token)
    uri = URI(GOOGLE_USER_INFO_URL)

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    raise "Failed to get user info: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  # Complete OAuth flow: exchange code and get user info
  def authenticate(code)
    token_data = exchange_code_for_token(code)
    user_info = get_user_info(token_data["access_token"])

    # Merge token info with user info
    user_info.merge(
      "access_token" => token_data["access_token"],
      "expires_at" => Time.now.to_i + token_data["expires_in"].to_i
    )
  end
end
