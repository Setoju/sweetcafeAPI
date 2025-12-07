# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [ :show, :update, :cancel ]

      # GET /api/v1/orders
      def index
        @orders = current_user.orders.includes(:order_items, :delivery).order(created_at: :desc)

        # Filter by status if provided
        @orders = @orders.where(status: params[:status]) if params[:status].present?

        render json: {
          orders: @orders.map { |order| order_response(order) }
        }, status: :ok
      end

      # GET /api/v1/orders/:id
      def show
        render json: {
          order: order_response(@order, detailed: true)
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Error in orders#show: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { errors: "Internal server error" }, status: :internal_server_error
      end

      # POST /api/v1/orders
      def create
        @order = current_user.orders.new(order_params.except(:order_items_attributes, :delivery_attributes))
        @order.status = "pending"
        @order.total_amount = 0

        ActiveRecord::Base.transaction do
          if @order.save
            # Create order items
            if params[:order_items].present?
              total = 0
              params[:order_items].each do |item_params|
                menu_item = MenuItem.find(item_params[:menu_item_id])
                quantity = item_params[:total_quantity].to_i

                order_item = @order.order_items.create!(
                  menu_item: menu_item,
                  total_quantity: quantity,
                  price: menu_item.price,
                  subtotal: menu_item.price * quantity
                )

                total += order_item.subtotal
              end

              @order.update!(total_amount: total)
            else
              render json: { errors: "No order items provided" }, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end

            # Create delivery if provided
            if params[:delivery].present?
              @order.create_delivery!(delivery_params)
            end

            render json: {
              order: order_response(@order, detailed: true),
              message: "Order created successfully"
            }, status: :created
          else
            render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # PATCH /api/v1/orders/:id
      def update
        # Only allow status updates
        if @order.update(status: params[:status])
          render json: {
            order: order_response(@order, detailed: true),
            message: "Order updated successfully"
          }, status: :ok
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/orders/:id/cancel
      def cancel
        if @order.status == "pending"
          @order.update!(status: "cancelled")
          render json: {
            order: order_response(@order),
            message: "Order cancelled successfully"
          }, status: :ok
        else
          render json: { errors: "Only pending orders can be cancelled" }, status: :unprocessable_entity
        end
      end

      private

      def set_order
        return render json: { errors: "Unauthorized" }, status: :unauthorized unless current_user

        @order = if current_user.role == "admin"
          Order.includes(:order_items, :delivery, order_items: :menu_item).find(params[:id])
        else
          current_user.orders.includes(:order_items, :delivery, order_items: :menu_item).find(params[:id])
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: "Order not found" }, status: :not_found
      rescue StandardError => e
        Rails.logger.error "Error in set_order: #{e.message}"
        render json: { errors: "Internal server error" }, status: :internal_server_error
      end

      def order_params
        params.require(:order).permit(:notes)
      end

      def delivery_params
        params.require(:delivery).permit(:address, :city, :postal_code, :phone, :delivery_notes, :delivery_method, :payment_method, :delivery_time, :pickup_time)
      end

      def order_response(order, detailed: false)
        return {} unless order

        response = {
          id: order.id,
          status: order.status,
          total_amount: order.total_amount&.to_f || 0.0,
          items_quantity: order.order_items&.sum(:total_quantity) || 0,
          notes: order.notes,
          created_at: order.created_at
        }

        if detailed
          response[:order_items] = (order.order_items || []).map do |item|
            menu_item = item.menu_item
            {
              id: item.id,
              menu_item: menu_item ? {
                id: menu_item.id,
                name: menu_item.name,
                description: menu_item.description
              } : nil,
              quantity: item.total_quantity,
              price: item.price&.to_f || 0.0,
              subtotal: item.subtotal&.to_f || 0.0
            }
          end

          if order.delivery
            delivery = order.delivery
            response[:delivery] = {
              id: delivery.id,
              address: delivery.address,
              city: delivery.city,
              postal_code: delivery.postal_code,
              phone: delivery.phone,
              delivery_notes: delivery.delivery_notes,
              delivery_method: delivery.delivery_method,
              payment_method: delivery.payment_method,
              delivery_status: delivery.delivery_status,
              delivery_time: delivery.delivery_time,
              pickup_time: delivery.pickup_time,
              delivered_at: delivery.delivered_at
            }
          end

          response[:updated_at] = order.updated_at
        end

        response
      end
    end
  end
end
