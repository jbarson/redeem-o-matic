class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    unless token
      render json: { error: 'Unauthorized - Missing token' }, status: :unauthorized
      return
    end

    begin
      decoded = JWT.decode(token, secret_key, true, algorithm: 'HS256')[0]
      @current_user = User.find(decoded['user_id'])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Unauthorized - User not found' }, status: :unauthorized
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: 'Unauthorized - Invalid or expired token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def secret_key
    Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
  end

  def encode_token(payload)
    JWT.encode(payload, secret_key, 'HS256')
  end
end
