# frozen_string_literal: true

module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :set_category, only: [ :show, :update, :destroy ]
      skip_before_action :authenticate_user, only: [ :index, :show ]

      # GET /api/v1/categories
      def index
        @categories = Category.includes(:menu_items).all
        render json: {
          categories: @categories.map { |category| category_response(category) }
        }, status: :ok
      end

      # GET /api/v1/categories/:id
      def show
        render json: {
          category: category_response(@category, include_items: true)
        }, status: :ok
      end

      # POST /api/v1/categories
      def create
        @category = Category.new(category_params)

        if @category.save
          render json: {
            category: category_response(@category),
            message: "Category created successfully"
          }, status: :created
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/categories/:id
      def update
        if @category.update(category_params)
          render json: {
            category: category_response(@category),
            message: "Category updated successfully"
          }, status: :ok
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/categories/:id
      def destroy
        @category.destroy
        render json: { message: "Category deleted successfully" }, status: :ok
      end

      private

      def set_category
        @category = Category.includes(:menu_items).find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :description)
      end

      def category_response(category, include_items: false)
        response = {
          id: category.id,
          name: category.name,
          description: category.description,
          created_at: category.created_at,
          updated_at: category.updated_at
        }

        if include_items
          response[:menu_items] = category.menu_items.map do |item|
            {
              id: item.id,
              name: item.name,
              description: item.description,
              price: item.price,
              available: item.available
            }
          end
        else
          response[:menu_items_count] = category.menu_items.count
        end

        response
      end
    end
  end
end
