# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [ :show, :update, :destroy ]
      before_action :authorize_admin, only: [ :index, :destroy ]

      # GET /api/v1/users
      def index
        @users = User.all.order(created_at: :desc)
        render json: {
          users: @users.map { |user| user_response(user) }
        }, status: :ok
      end

      # GET /api/v1/users/:id
      def show
        # Users can only view their own profile unless they're admin
        if current_user.id == @user.id || current_user.role == "admin"
          render json: {
            user: user_response(@user, detailed: true)
          }, status: :ok
        else
          render json: { errors: "Unauthorized" }, status: :unauthorized
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        # Users can only update their own profile unless they're admin
        if current_user.id == @user.id || current_user.role == "admin"
          if @user.update(user_update_params)
            render json: {
              user: user_response(@user),
              message: "Profile updated successfully"
            }, status: :ok
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { errors: "Unauthorized" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        render json: { message: "User deleted successfully" }, status: :ok
      end

      # GET /api/v1/users/:id/orders
      def orders
        @user = User.find(params[:id])

        # Users can only view their own orders unless they're admin
        if current_user.id == @user.id || current_user.role == "admin"
          @orders = @user.orders.includes(:order_items, :delivery).order(created_at: :desc)
          render json: {
            orders: @orders.map { |order| order_summary(order) }
          }, status: :ok
        else
          render json: { errors: "Unauthorized" }, status: :unauthorized
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def authorize_admin
        render json: { errors: "Admin access required" }, status: :forbidden unless current_user.role == "admin"
      end

      def user_update_params
        allowed_params = [ :name, :phone ]
        allowed_params << :role if current_user.role == "admin"
        params.require(:user).permit(allowed_params)
      end

      def user_response(user, detailed: false)
        response = {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role
        }

        if detailed
          response.merge!({
            created_at: user.created_at,
            updated_at: user.updated_at,
            orders_count: user.orders.count
          })
        end

        response
      end

      def order_summary(order)
        {
          id: order.id,
          status: order.status,
          total_amount: order.total_amount.to_f,
          items_count: order.order_items.count,
          created_at: order.created_at
        }
      end
    end
  end
end
