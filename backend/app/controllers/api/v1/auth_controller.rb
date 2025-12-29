class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login]

  # POST /api/v1/auth/login
  # For demo purposes, accepts user_id to generate a token
  # In production, this would verify email/password
  def login
    user_id = params[:user_id]

    if user_id.blank?
      render json: { error: 'user_id is required' }, status: :bad_request
      return
    end

    begin
      user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    # Generate token with 24 hour expiration
    begin
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      token = encode_token(payload)
    rescue NameError => e
      # JWT gem might not be installed
      Rails.logger.error("JWT encoding failed: #{e.message}")
      render json: { error: 'Authentication service unavailable. Please ensure JWT gem is installed.' }, status: :internal_server_error
      return
    rescue => e
      Rails.logger.error("Token generation failed: #{e.message}")
      render json: { error: 'Failed to generate authentication token' }, status: :internal_server_error
      return
    end

    render json: {
      token: token,
      user: user.as_json(only: [:id, :name, :email, :points_balance])
    }, status: :ok
  end
end

