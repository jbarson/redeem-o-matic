module AuthHelpers
  # Generate a JWT token for a user (for testing)
  def auth_token_for(user)
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    secret_key = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
    JWT.encode(payload, secret_key, 'HS256')
  end

  # Set authentication headers for a request
  def auth_headers_for(user)
    { 'Authorization' => "Bearer #{auth_token_for(user)}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end

