# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user, only: [:login, :signup]

      # POST /api/v1/auth/signup
      def signup
        user = User.new(user_params)
        
        if user.save
          token = JsonWebToken.encode(user_id: user.id)
          render json: { 
            token: token,
            user: user_response(user),
            message: 'Account created successfully'
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
            message: 'Login successful'
          }, status: :ok
        else
          render json: { errors: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # GET /api/v1/auth/me
      def me
        render json: { user: user_response(current_user) }, status: :ok
      end

      # DELETE /api/v1/auth/signout
      def signout
        # Token invalidation would typically be handled client-side or with a token blacklist
        render json: { message: 'Signed out successfully' }, status: :ok
      end

      private

      def user_params
        params.permit(:name, :email, :phone, :password, :password_confirmation, :role)
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
