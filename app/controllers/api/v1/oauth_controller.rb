# frozen_string_literal: true

module Api
  module V1
    class OauthController < ApplicationController
      skip_before_action :authenticate_user, only: [ :google, :google_callback ]

      # POST /api/v1/auth/google
      # Returns Google OAuth authorization URL for frontend to redirect user
      def google
        oauth_service = GoogleOauthService.new
        authorization_url = oauth_service.authorization_url

        render json: {
          authorization_url: authorization_url,
          message: "Redirect user to this URL to authenticate with Google"
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Google OAuth initialization error: #{e.message}"
        render json: {
          errors: "Failed to initialize Google OAuth",
          details: e.message
        }, status: :internal_server_error
      end

      # POST /api/v1/auth/google/callback
      # Handles the OAuth callback with authorization code
      def google_callback
        code = params[:code]

        unless code.present?
          render json: { errors: "Authorization code is required" }, status: :bad_request
          return
        end

        begin
          oauth_service = GoogleOauthService.new
          google_user_info = oauth_service.authenticate(code)

          # Find or create user from Google data
          user = User.from_google_oauth(google_user_info)

          if user.save
            # Generate JWT token for the user
            jwt_token = JsonWebToken.encode(user_id: user.id)

            render json: {
              token: jwt_token,
              user: format_user_response(user),
              message: "Successfully authenticated with Google"
            }, status: :ok
          else
            render json: {
              errors: user.errors.full_messages
            }, status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.error "Google OAuth callback error: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")

          render json: {
            errors: "Authentication failed",
            details: e.message
          }, status: :unprocessable_entity
        end
      end

      private

      def format_user_response(user)
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
