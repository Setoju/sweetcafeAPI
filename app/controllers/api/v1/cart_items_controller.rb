# frozen_string_literal: true

module Api
  module V1
    class CartItemsController < ApplicationController
      include InventoryValidator
      
      before_action :authenticate_user
      before_action :set_cart_item, only: [ :update, :destroy ]

      # GET /api/v1/cart
      def index
        @cart_items = current_user.cart_items.includes(menu_item: :category)

        render json: {
          cart_items: @cart_items.map { |item| cart_item_response(item) },
          total_items: @cart_items.sum(:total_quantity),
          total_price: calculate_total_price(@cart_items)
        }, status: :ok
      end

      # POST /api/v1/cart
      def create
        menu_item = MenuItem.find(params[:menu_item_id])

        # Check if item already exists in cart
        @cart_item = current_user.cart_items.find_by(menu_item_id: menu_item.id)

        if @cart_item
          # Update quantity if item exists
          new_quantity = @cart_item.total_quantity + (params[:total_quantity] || 1).to_i

          validation_result = validate_inventory_availability(menu_item, new_quantity)
          unless validation_result[:valid]
            render json: {
              errors: [ validation_result[:error] ]
            }, status: :unprocessable_entity
            return
          end

          @cart_item.total_quantity = new_quantity

          if @cart_item.save
            render json: {
              cart_item: cart_item_response(@cart_item),
              message: "Cart item quantity updated"
            }, status: :ok
          else
            render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
          end
        else
          # Create new cart item
          @cart_item = current_user.cart_items.build(
            menu_item_id: menu_item.id,
            total_quantity: params[:total_quantity] || 1
          )

          if @cart_item.save
            render json: {
              cart_item: cart_item_response(@cart_item),
              message: "Item added to cart successfully"
            }, status: :created
          else
            render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      # PATCH/PUT /api/v1/cart/:id
      def update
        if @cart_item.update(total_quantity: params[:total_quantity])
          render json: {
            cart_item: cart_item_response(@cart_item),
            message: "Cart item updated successfully"
          }, status: :ok
        else
          render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/cart/:id
      def destroy
        @cart_item.destroy
        render json: { message: "Item removed from cart successfully" }, status: :ok
      end

      # DELETE /api/v1/cart/clear
      def clear
        current_user.cart_items.destroy_all
        render json: { message: "Cart cleared successfully" }, status: :ok
      end

      private

      def set_cart_item
        @cart_item = current_user.cart_items.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: "Cart item not found" }, status: :not_found
      end

      def cart_item_response(cart_item)
        menu_item = cart_item.menu_item
        {
          id: cart_item.id,
          total_quantity: cart_item.total_quantity,
          menu_item: {
            id: menu_item.id,
            name: menu_item.name,
            size: menu_item.size,
            price: menu_item.price.to_f,
            available: menu_item.available,
            quantity_available: menu_item.quantity,
            image_url: menu_item.image_url,
            category: {
              id: menu_item.category.id,
              name: menu_item.category.name
            }
          },
          subtotal: (cart_item.total_quantity * menu_item.price).to_f,
          created_at: cart_item.created_at,
          updated_at: cart_item.updated_at
        }
      end

      def calculate_total_price(cart_items)
        cart_items.sum { |item| item.total_quantity * item.menu_item.price }.to_f
      end
    end
  end
end
