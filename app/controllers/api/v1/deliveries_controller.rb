# frozen_string_literal: true

module Api
  module V1
    class DeliveriesController < ApplicationController
      before_action :authorize_admin, only: [:index, :update, :destroy]
      before_action :set_delivery, only: [:show, :update, :destroy]

      # GET /api/v1/deliveries
      def index
        @deliveries = Delivery.includes(:order).order(created_at: :desc)
        
        # Filter by status if provided
        @deliveries = @deliveries.where(delivery_status: params[:status]) if params[:status].present?
        
        # Filter by delivery type if provided
        @deliveries = @deliveries.where(delivery_type: params[:delivery_type]) if params[:delivery_type].present?

        render json: {
          deliveries: @deliveries.map { |delivery| delivery_response(delivery) }
        }, status: :ok
      end

      # GET /api/v1/deliveries/:id
      def show
        authorize_delivery_access(@delivery)
        
        render json: {
          delivery: delivery_response(@delivery, detailed: true)
        }, status: :ok
      end

      # POST /api/v1/deliveries
      def create
        @order = Order.find(params[:order_id])
        
        # Check if user owns the order or is admin
        unless current_user.role == 'admin' || @order.user_id == current_user.id
          return render json: { errors: 'Unauthorized' }, status: :unauthorized
        end
        
        # Check if order already has a delivery
        if @order.delivery.present?
          return render json: { errors: 'Order already has a delivery' }, status: :unprocessable_entity
        end
        
        @delivery = @order.build_delivery(delivery_params)
        
        if @delivery.save
          render json: {
            delivery: delivery_response(@delivery, detailed: true),
            message: 'Delivery created successfully'
          }, status: :created
        else
          render json: { errors: @delivery.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'Order not found' }, status: :not_found
      end

      # PATCH/PUT /api/v1/deliveries/:id
      def update
        if @delivery.update(delivery_update_params)
          # Update order status when delivery is marked as delivered
          if @delivery.delivery_status == 'delivered' && @delivery.order.status != 'delivered'
            @delivery.order.update(status: 'delivered')
          end
          
          render json: {
            delivery: delivery_response(@delivery, detailed: true),
            message: 'Delivery updated successfully'
          }, status: :ok
        else
          render json: { errors: @delivery.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/deliveries/:id
      def destroy
        @delivery.destroy
        render json: { message: 'Delivery deleted successfully' }, status: :ok
      end

      private

      def set_delivery
        @delivery = Delivery.includes(:order).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'Delivery not found' }, status: :not_found
      end

      def authorize_delivery_access(delivery)
        unless current_user.role == 'admin' || delivery.order.user_id == current_user.id
          render json: { errors: 'Unauthorized' }, status: :unauthorized
        end
      end

      def authorize_admin
        unless current_user&.role == 'admin'
          render json: { errors: 'Admin access required' }, status: :forbidden
        end
      end

      def delivery_params
        params.require(:delivery).permit(
          :address,
          :city,
          :phone,
          :delivery_type,
          :payment_type,
          :delivery_notes,
          :delivery_time
        )
      end

      def delivery_update_params
        permitted = [:address, :city, :phone, :delivery_notes, :delivery_time]
        
        # Only admins can update these fields
        if current_user&.role == 'admin'
          permitted += [:delivery_status, :delivery_type, :payment_type, :delivered_at]
        end
        
        params.require(:delivery).permit(*permitted)
      end

      def delivery_response(delivery, detailed: false)
        response = {
          id: delivery.id,
          order_id: delivery.order_id,
          address: delivery.address,
          city: delivery.city,
          phone: delivery.phone,
          delivery_type: delivery.delivery_type,
          payment_type: delivery.payment_type,
          delivery_status: delivery.delivery_status,
          delivery_notes: delivery.delivery_notes,
          delivery_time: delivery.delivery_time,
          delivered_at: delivery.delivered_at,
          created_at: delivery.created_at
        }
        
        if detailed
          response[:order] = {
            id: delivery.order.id,
            status: delivery.order.status,
            total_amount: delivery.order.total_amount.to_f,
            user_id: delivery.order.user_id
          }
          response[:updated_at] = delivery.updated_at
        end
        
        response
      end
    end
  end
end
