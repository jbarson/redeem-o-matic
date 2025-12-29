# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Support multiple origins via comma-separated ENV variable
    # Example: CORS_ORIGINS=http://localhost:3001,https://app.yourdomain.com
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3001').split(',').map(&:strip)

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      # credentials: true is now appropriate since we have JWT authentication
      # This allows cookies/credentials to be sent with cross-origin requests
      # which is needed for proper authentication flow
      credentials: true,
      # Expose Authorization header to frontend
      expose: ['Authorization']
  end
end
