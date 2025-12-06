# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user, only: [ :login, :signup ]

      # POST /api/v1/auth/signup
      def signup
        user = User.new(user_params)

        if user.save
          token = JsonWebToken.encode(user_id: user.id)
          render json: {
            token: token,
            user: user_response(user),
            message: "Account created successfully"
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render json: {
            token: token,
            user: user_response(user),
            message: "Login successful"
          }, status: :ok
        else
          render json: { errors: "Invalid email or password" }, status: :unauthorized
        end
      end

      # GET /api/v1/auth/me
      def me
        render json: { user: user_response(current_user) }, status: :ok
      end

      # PATCH /api/v1/auth/me
      def update_profile
        update_params = {}

        # Add basic profile fields if present
        update_params[:name] = params[:name] if params[:name].present?
        update_params[:phone] = params[:phone] if params[:phone].present?

        # Handle password change
        if params[:new_password].present?
          unless params[:current_password].present?
            render json: { errors: "Current password is required to change password" }, status: :unprocessable_entity
            return
          end

          unless current_user.authenticate(params[:current_password])
            render json: { errors: "Current password is incorrect" }, status: :unauthorized
            return
          end

          update_params[:password] = params[:new_password]
          update_params[:password_confirmation] = params[:password_confirmation]
        end

        if current_user.update(update_params)
          render json: {
            user: user_response(current_user),
            message: "Profile updated successfully"
          }, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/auth/signout
      def signout
        # Token invalidation would typically be handled client-side or with a token blacklist
        render json: { message: "Signed out successfully" }, status: :ok
      end

      private

      def user_params
        params.permit(:name, :email, :phone, :password, :password_confirmation)
      end

      def user_response(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          created_at: user.created_at
        }
      end
    end
  end
end
