# frozen_string_literal: true

# OAuth Controller with Security Measures:
# 1. CSRF Protection - State parameter validated on callback
# 2. Single-use codes - Authorization codes can only be used once
# 3. Short expiration - Codes expire in 2 minutes
# 4. No token in URL - JWT never exposed in browser URL
# 5. Secure redirects - Frontend receives temporary code, exchanges for token

module Api
  module V1
    class OauthController < ApplicationController
      skip_before_action :authenticate_user, only: [ :google, :google_callback, :exchange_code ]

      # POST /api/v1/auth/google
      # Returns Google OAuth authorization URL with CSRF protection
      def google
        # Generate state parameter for CSRF protection
        state = generate_state_token

        oauth_service = GoogleOauthService.new
        authorization_url = oauth_service.authorization_url(state)

        render json: {
          authorization_url: authorization_url,
          state: state,
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
      # Handles the OAuth callback with authorization code and CSRF protection
      def google_callback
        code = params[:code]
        state = params[:state]

        unless code.present?
          redirect_to_frontend_with_error("Authorization code is required")
          return
        end

        # Verify state parameter to prevent CSRF attacks
        unless verify_state_token(state)
          Rails.logger.error "Invalid or expired state token"
          redirect_to_frontend_with_error("Invalid authentication request")
          return
        end

        begin
          oauth_service = GoogleOauthService.new
          google_user_info = oauth_service.authenticate(code)

          # Find or create user from Google data
          user = User.from_google_oauth(google_user_info)

          if user.save
            # Generate a short-lived authorization code for secure token exchange
            auth_code = generate_secure_auth_code(user.id)

            # Redirect to frontend with the authorization code
            redirect_to "#{frontend_url}/auth/callback?code=#{auth_code}", allow_other_host: true
          else
            redirect_to_frontend_with_error(user.errors.full_messages.join(", "))
          end
        rescue StandardError => e
          Rails.logger.error "Google OAuth callback error: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")

          redirect_to_frontend_with_error("Authentication failed")
        end
      end

      # POST /api/v1/auth/google/exchange
      # Exchange authorization code for JWT token
      def exchange_code
        code = params[:code]

        unless code.present?
          render json: { errors: "Authorization code is required" }, status: :bad_request
          return
        end

        # Verify and decode the authorization code
        user_id = verify_auth_code(code)

        if user_id
          user = User.find_by(id: user_id)

          if user
            # Generate JWT token for the user
            jwt_token = JsonWebToken.encode(user_id: user.id)

            render json: {
              token: jwt_token,
              user: format_user_response(user),
              message: "Successfully authenticated with Google"
            }, status: :ok
          else
            render json: { errors: "User not found" }, status: :not_found
          end
        else
          render json: { errors: "Invalid or expired authorization code" }, status: :unauthorized
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

      def frontend_url
        ENV["FRONTEND_URL"] || "http://localhost:3000"
      end

      def redirect_to_frontend_with_error(error_message)
        redirect_to "#{frontend_url}/auth/error?message=#{CGI.escape(error_message)}", allow_other_host: true
      end

      # Generate state token for CSRF protection
      def generate_state_token
        state = SecureRandom.urlsafe_base64(32)
        # Store state in cache for 10 minutes
        Rails.cache.write("oauth_state:#{state}", true, expires_in: 10.minutes)
        state
      end

      # Verify state token
      def verify_state_token(state)
        return false unless state.present?

        # Check if state exists in cache
        valid = Rails.cache.read("oauth_state:#{state}")

        # Delete state to prevent reuse
        Rails.cache.delete("oauth_state:#{state}") if valid

        valid.present?
      end

      # Generate a short-lived authorization code (expires in 2 minutes, single use)
      def generate_secure_auth_code(user_id)
        # Generate a unique code identifier
        code_id = SecureRandom.hex(32)

        payload = {
          user_id: user_id,
          type: "oauth_auth_code",
          code_id: code_id,
          exp: 2.minutes.from_now.to_i
        }

        # Store the code_id in cache to ensure single use
        Rails.cache.write("oauth_code:#{code_id}", user_id, expires_in: 2.minutes)

        JsonWebToken.encode(payload)
      end

      # Verify and decode the authorization code (single use only)
      def verify_auth_code(code)
        begin
          decoded = JsonWebToken.decode(code)
          return nil unless decoded && decoded[:type] == "oauth_auth_code"

          code_id = decoded[:code_id]
          user_id = decoded[:user_id]

          # Check if code has already been used (single use enforcement)
          cached_user_id = Rails.cache.read("oauth_code:#{code_id}")
          return nil unless cached_user_id == user_id

          # Delete the code immediately to prevent reuse
          Rails.cache.delete("oauth_code:#{code_id}")

          user_id
        rescue JWT::ExpiredSignature
          Rails.logger.error "Authorization code expired"
          nil
        rescue StandardError => e
          Rails.logger.error "Authorization code verification failed: #{e.message}"
          nil
        end
      end
    end
  end
end
