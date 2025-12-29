# Rate limiting configuration using Rack::Attack
# See https://github.com/rack/rack-attack for documentation

class Rack::Attack
  # Configure cache store (use Rails cache)
  self.cache.store = Rails.cache

  # Throttle all requests by IP address
  # Allow 300 requests per 5 minutes per IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/up')
  end

  # Throttle login attempts
  # Allow 5 login attempts per 20 seconds per IP
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/api/v1/auth/login' && req.post?
      req.ip
    end
  end

  # Throttle API requests by IP
  # Allow 100 API requests per minute per IP
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    if req.path.start_with?('/api/v1')
      req.ip
    end
  end

  # Throttle redemption creation (more restrictive)
  # Allow 10 redemptions per minute per IP
  throttle('redemptions/ip', limit: 10, period: 1.minute) do |req|
    if req.path == '/api/v1/redemptions' && req.post?
      req.ip
    end
  end

  # Custom response for throttled requests
  self.throttled_response = lambda do |env|
    match_data = env['rack.attack.match_data']
    now = match_data[:epoch_time]
    headers = {
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now % match_data[:period])).to_s,
      'Content-Type' => 'application/json',
    }

    body = {
      error: 'Rate limit exceeded. Please try again later.',
      retry_after: match_data[:period],
    }.to_json

    [429, headers, [body]]
  end
end


