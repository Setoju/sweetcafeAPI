# frozen_string_literal: true

module Api
  module V1
    class OauthController < ApplicationController
      skip_before_action :authenticate_user, only: [ :google, :google_callback ]

      # POST /api/v1/auth/google
      # Initiates Google OAuth flow by redirecting to Google's authorization URL
      def google
        # For API-only apps, we'll return the authorization URL
        # The frontend will handle the redirect
        client = Signet::OAuth2::Client.new(
          client_id: ENV["GOOGLE_CLIENT_ID"],
          client_secret: ENV["GOOGLE_CLIENT_SECRET"],
          authorization_uri: "https://accounts.google.com/o/oauth2/auth",
          scope: [ "email", "profile" ],
          redirect_uri: google_callback_url
        )

        authorization_uri = client.authorization_uri.to_s

        render json: {
          authorization_url: authorization_uri,
          message: "Redirect to this URL to authorize with Google"
        }, status: :ok
      end

      # GET/POST /api/v1/auth/google/callback
      # Handles the callback from Google OAuth
      def google_callback
        auth_code = params[:code]

        unless auth_code
          render json: { errors: "Authorization code not provided" }, status: :bad_request
          return
        end

        begin
          # Exchange authorization code for access token
          client = Signet::OAuth2::Client.new(
            client_id: ENV["GOOGLE_CLIENT_ID"],
            client_secret: ENV["GOOGLE_CLIENT_SECRET"],
            token_credential_uri: "https://oauth2.googleapis.com/token",
            redirect_uri: google_callback_url
          )

          client.code = auth_code
          client.fetch_access_token!

          # Get user info from Google
          user_info = get_google_user_info(client.access_token)

          # Create auth hash compatible with omniauth structure
          auth = OpenStruct.new(
            provider: "google_oauth2",
            uid: user_info["id"],
            info: OpenStruct.new(
              email: user_info["email"],
              name: user_info["name"]
            ),
            credentials: OpenStruct.new(
              token: client.access_token,
              expires_at: client.expires_at
            )
          )

          # Find or create user
          user = User.from_omniauth(auth)

          if user.save
            token = JsonWebToken.encode(user_id: user.id)
            render json: {
              token: token,
              user: user_response(user),
              message: "Successfully authenticated with Google"
            }, status: :ok
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.error "Google OAuth error: #{e.message}"
          render json: { errors: "Authentication failed: #{e.message}" }, status: :unprocessable_entity
        end
      end

      private

      def google_callback_url
        "#{ENV['API_BASE_URL']}/api/v1/auth/google/callback"
      end

      def get_google_user_info(access_token)
        require "net/http"
        require "json"

        uri = URI("https://www.googleapis.com/oauth2/v2/userinfo")
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{access_token}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        JSON.parse(response.body)
      end

      def user_response(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          oauth_user: user.oauth_user?,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
