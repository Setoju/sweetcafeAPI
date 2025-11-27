class ApplicationController < ActionController::API
  before_action :authenticate_user

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  def authenticate_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id]) if @decoded
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: 'Unauthorized' }, status: :unauthorized and return
    rescue JWT::DecodeError => e
      render json: { errors: 'Unauthorized' }, status: :unauthorized and return
    end
    
    render json: { errors: 'Unauthorized' }, status: :unauthorized and return unless @current_user
  end

  attr_reader :current_user

  private

  def not_found(exception)
    render json: { errors: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def bad_request(exception)
    render json: { errors: exception.message }, status: :bad_request
  end
end
