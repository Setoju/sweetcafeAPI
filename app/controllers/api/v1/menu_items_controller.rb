# frozen_string_literal: true

module Api
  module V1
    class MenuItemsController < ApplicationController
      before_action :set_menu_item, only: [:show, :update, :destroy]
      before_action :authorize_admin, only: [:create, :update, :destroy]
      skip_before_action :authenticate_user, only: [:index, :show]

      # GET /api/v1/menu_items
      def index
        @menu_items = MenuItem.includes(:category).all
        
        # Filter by category if provided
        if params[:category].present?
          @menu_items = @menu_items.joins(:category).where(categories: { name: params[:category] })
        end
        
        # Filter by availability if provided
        @menu_items = @menu_items.where(available: params[:available]) if params[:available].present?

        render json: {
          menu_items: @menu_items.map { |item| menu_item_response(item) }
        }, status: :ok
      end

      # GET /api/v1/menu_items/:id
      def show
        render json: {
          menu_item: menu_item_response(@menu_item, detailed: true)
        }, status: :ok
      end

      # POST /api/v1/menu_items
      def create
        @menu_item = MenuItem.new(menu_item_params)
        
        if @menu_item.save
          render json: {
            menu_item: menu_item_response(@menu_item),
            message: 'Menu item created successfully'
          }, status: :created
        else
          render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/menu_items/:id
      def update
        if @menu_item.update(menu_item_params)
          render json: {
            menu_item: menu_item_response(@menu_item),
            message: 'Menu item updated successfully'
          }, status: :ok
        else
          render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/menu_items/:id
      def destroy
        @menu_item.destroy
        render json: { message: 'Menu item deleted successfully' }, status: :ok
      end

      private

      def authorize_admin
        render json: { errors: 'Admin access required' }, status: :forbidden unless current_user.role == 'admin'
      end

      def set_menu_item
        @menu_item = MenuItem.includes(:category).find(params[:id])
      end

      def menu_item_params
        params.require(:menu_item).permit(:name, :description, :price, :category_id, :available, :image_url, :quantity)
      end

      def menu_item_response(menu_item, detailed: false)
        response = {
          id: menu_item.id,
          name: menu_item.name,
          size: menu_item.size,
          description: menu_item.description,
          price: menu_item.price.to_f,
          available: menu_item.available,
          quantity: menu_item.quantity,
          image_url: menu_item.image_url,
          category: {
            id: menu_item.category.id,
            name: menu_item.category.name
          }
        }
        
        if detailed
          response.merge!({
            created_at: menu_item.created_at,
            updated_at: menu_item.updated_at
          })
        end
        
        response
      end
    end
  end
end
