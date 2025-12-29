# Security Documentation

## Current Security Status

**⚠️ IMPORTANT: This application is a demonstration/evaluation project and is NOT production-ready as-is.**

### Known Security Limitations

#### 1. **No Authentication/Authorization (CRITICAL)**

**Current State:**
- Users can select any account without password verification
- All API endpoints are unprotected
- Any user can access any other user's data by modifying request parameters
- User IDs are passed as plain parameters with no verification

**Risk:**
- Complete unauthorized access to all user data
- Ability to redeem rewards on behalf of other users
- Access to sensitive information (emails, balances, transaction history)

**For Production:** Implement proper authentication before deployment.

#### 2. **Data Exposure**

**Current State:**
- `/api/v1/users` endpoint returns all users including emails
- No pagination or rate limiting
- User data stored in localStorage as plain JSON

**Risk:**
- Information disclosure
- Privacy violations
- GDPR/CCPA non-compliance

#### 3. **Session Management**

**Current State:**
- No session timeouts
- No secure session storage
- No CSRF protection

---

## Production Security Checklist

Before deploying this application to production, implement the following security measures:

### ✅ Authentication & Authorization

#### Option 1: JWT-Based Authentication (Recommended for API)

1. **Add authentication gems:**
   ```ruby
   # Gemfile
   gem 'bcrypt'      # Password hashing
   gem 'jwt'         # JSON Web Tokens
   ```

2. **Add password to User model:**
   ```ruby
   rails g migration AddPasswordDigestToUsers password_digest:string
   rails db:migrate

   # app/models/user.rb
   class User < ApplicationRecord
     has_secure_password
     validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
     validates :password, length: { minimum: 8 }, allow_nil: true
   end
   ```

3. **Create authentication controller:**
   ```ruby
   # app/controllers/api/v1/auth_controller.rb
   class Api::V1::AuthController < ApplicationController
     def login
       user = User.find_by(email: params[:email])

       if user&.authenticate(params[:password])
         token = encode_token({ user_id: user.id })
         render json: { token: token, user: user.as_json(only: [:id, :name, :email, :points_balance]) }
       else
         render json: { error: 'Invalid credentials' }, status: :unauthorized
       end
     end

     private

     def encode_token(payload)
       JWT.encode(payload, Rails.application.credentials.secret_key_base)
     end
   end
   ```

4. **Add authentication middleware:**
   ```ruby
   # app/controllers/application_controller.rb
   class ApplicationController < ActionController::API
     before_action :authenticate_user!

     private

     def authenticate_user!
       header = request.headers['Authorization']
       token = header.split(' ').last if header

       begin
         decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
         @current_user = User.find(decoded['user_id'])
       rescue ActiveRecord::RecordNotFound, JWT::DecodeError
         render json: { error: 'Unauthorized' }, status: :unauthorized
       end
     end

     def current_user
       @current_user
     end
   end
   ```

5. **Update frontend to store and send JWT:**
   ```typescript
   // services/api.ts
   const token = localStorage.getItem('auth_token');
   const apiClient = axios.create({
     baseURL: API_BASE_URL,
     headers: {
       'Content-Type': 'application/json',
       ...(token && { 'Authorization': `Bearer ${token}` }),
     },
   });
   ```

#### Option 2: OAuth 2.0 / OpenID Connect

For enterprise applications, consider using:
- **Devise** + **Doorkeeper** (OAuth provider)
- **OmniAuth** (OAuth consumer - Google, GitHub, etc.)
- External identity providers (Auth0, Okta, AWS Cognito)

### ✅ Authorization

1. **Implement role-based access control:**
   ```ruby
   # app/models/user.rb
   enum role: { user: 0, admin: 1 }
   ```

2. **Use Pundit or CanCanCan for authorization:**
   ```ruby
   # Gemfile
   gem 'pundit'

   # app/policies/redemption_policy.rb
   class RedemptionPolicy < ApplicationPolicy
     def create?
       record.user == user && user.points_balance >= record.reward.cost
     end
   end
   ```

3. **Protect user data access:**
   ```ruby
   # Ensure users can only access their own data
   def balance
     unless @user.id == current_user.id
       render json: { error: 'Unauthorized' }, status: :forbidden
       return
     end
     # ... render balance
   end
   ```

### ✅ Data Protection

1. **Environment variables for secrets:**
   ```bash
   # backend/.env (never commit this)
   SECRET_KEY_BASE=<generated-secret>
   DATABASE_URL=<database-connection>
   CORS_ORIGINS=https://yourdomain.com
   ```

2. **Use Rails encrypted credentials:**
   ```bash
   rails credentials:edit --environment production
   ```

3. **Enable HTTPS only:**
   ```ruby
   # config/environments/production.rb
   config.force_ssl = true
   ```

4. **Secure cookie settings:**
   ```ruby
   # config/initializers/session_store.rb
   Rails.application.config.session_store :cookie_store,
     key: '_redeem_o_matic_session',
     secure: Rails.env.production?,
     httponly: true,
     same_site: :lax
   ```

### ✅ Rate Limiting

1. **Install Rack::Attack:**
   ```ruby
   # Gemfile
   gem 'rack-attack'

   # config/application.rb
   config.middleware.use Rack::Attack

   # config/initializers/rack_attack.rb
   Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
     req.ip
   end

   Rack::Attack.throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
     req.ip if req.path == '/api/v1/auth/login' && req.post?
   end
   ```

### ✅ Input Validation (✓ Implemented)

- [x] Parameter validation on all API endpoints
- [x] Type checking for IDs
- [x] Presence validation

### ✅ Error Handling

1. **Don't expose stack traces in production:**
   ```ruby
   # config/environments/production.rb
   config.consider_all_requests_local = false
   ```

2. **Log errors to monitoring service:**
   ```ruby
   # Use Sentry, Honeybadger, or similar
   gem 'sentry-ruby'
   gem 'sentry-rails'
   ```

### ✅ Database Security

1. **Use database-level constraints:**
   ```ruby
   # Ensure unique indexes
   add_index :users, :email, unique: true

   # Add check constraints
   execute <<-SQL
     ALTER TABLE users
     ADD CONSTRAINT check_points_balance_non_negative
     CHECK (points_balance >= 0)
   SQL
   ```

2. **Enable query logging in production:**
   ```ruby
   # Monitor for SQL injection attempts
   config.active_record.verbose_query_logs = true
   ```

### ✅ Frontend Security

1. **Content Security Policy:**
   ```ruby
   # Gemfile
   gem 'secure_headers'

   # config/initializers/secure_headers.rb
   SecureHeaders::Configuration.default do |config|
     config.csp = {
       default_src: %w('self'),
       script_src: %w('self'),
       style_src: %w('self' 'unsafe-inline'),
       img_src: %w('self' data: https:),
       connect_src: %w('self' https://api.yourdomain.com)
     }
   end
   ```

2. **XSS Protection:**
   - React automatically escapes content
   - Don't use `dangerouslySetInnerHTML` without sanitization
   - Validate all user input

3. **Secure localStorage:**
   ```typescript
   // Don't store sensitive data in localStorage
   // Use httpOnly cookies for tokens when possible
   // Or encrypt sensitive data before storing
   ```

### ✅ API Security

1. **CORS restrictions:**
   ```ruby
   # Only allow specific origins in production
   origins ENV.fetch('CORS_ORIGINS', '').split(',')
   ```

2. **API versioning:**
   - Current: `/api/v1/...`
   - Maintain backward compatibility
   - Deprecate old versions gradually

3. **Request signing (optional for high security):**
   ```typescript
   // HMAC signing for API requests
   import CryptoJS from 'crypto-js';

   const signature = CryptoJS.HmacSHA256(request_body, secret_key);
   ```

---

## Security Testing

### Before Production Deployment:

1. **Run security audit:**
   ```bash
   # Backend
   cd backend
   bundle audit check --update
   brakeman -z

   # Frontend
   cd frontend
   npm audit
   ```

2. **Penetration testing:**
   - Test SQL injection
   - Test XSS vulnerabilities
   - Test CSRF attacks
   - Test authentication bypass
   - Test authorization flaws

3. **Load testing with authentication:**
   ```bash
   # Use tools like Apache Bench, wrk, or Artillery
   ab -n 1000 -c 10 -H "Authorization: Bearer TOKEN" https://api.yourdomain.com/api/v1/rewards
   ```

---

## Incident Response

### If Security Breach Occurs:

1. **Immediate actions:**
   - Revoke all active sessions/tokens
   - Disable affected endpoints
   - Preserve logs for forensics
   - Notify affected users

2. **Investigation:**
   - Review access logs
   - Identify attack vector
   - Assess data exposure

3. **Remediation:**
   - Patch vulnerability
   - Update dependencies
   - Implement additional monitoring
   - Document lessons learned

4. **Compliance:**
   - Report breach as required by law (GDPR: 72 hours)
   - Notify users of data exposure
   - File incident reports

---

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [React Security Best Practices](https://react.dev/learn/security)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

## Contact

For security concerns or to report vulnerabilities, please contact:
- **Security Team:** security@yourdomain.com
- **Bug Bounty:** (if applicable)

---

**Last Updated:** 2025-12-29
