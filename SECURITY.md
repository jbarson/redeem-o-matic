# Security Documentation

## Current Security Status

**⚠️ IMPORTANT: This application is a demonstration/evaluation project. While basic security measures are implemented, additional hardening is recommended for production use.**

### ✅ Implemented Security Features

#### 1. **Authentication & Authorization (IMPLEMENTED)**

**Current Implementation:**
- ✅ JWT-based authentication using `jwt` gem
- ✅ Protected API endpoints with `authenticate_user!` before_action
- ✅ Token-based authorization (Bearer tokens in Authorization header)
- ✅ Users can only access their own data (authorization checks in controllers)
- ✅ Token expiration (24 hours)
- ✅ Frontend stores tokens in localStorage and includes them in requests
- ✅ Login endpoint at `/api/v1/auth/login` (public, for demo accepts user_id)

**Note:** For production, consider:
- Password-based authentication (currently uses user_id for demo)
- Token refresh mechanism
- More granular role-based access control (RBAC)

#### 2. **Rate Limiting (IMPLEMENTED)**

**Current Implementation:**
- ✅ Rack::Attack middleware configured
- ✅ General API throttling (300 requests per 5 minutes per IP)
- ✅ Login endpoint throttling (5 attempts per 20 seconds per IP)
- ✅ Redemption endpoint throttling (10 per minute per IP)
- ✅ Custom 429 response with rate limit headers

#### 3. **Data Protection**

**Current State:**
- ✅ CORS configured with credentials support
- ✅ Authorization header exposed to frontend
- ✅ User data access restricted (users can only access their own data)
- ⚠️ `/api/v1/users` endpoint returns minimal data (id, name only) for login selection
- ⚠️ User data stored in localStorage (consider httpOnly cookies for production)
- ⚠️ No pagination on endpoints (consider adding for large datasets)

#### 4. **Input Validation (IMPLEMENTED)**

**Current Implementation:**
- ✅ Parameter validation on all API endpoints
- ✅ Type checking for IDs
- ✅ Presence validation
- ✅ Model-level validations (points_balance >= 0, etc.)

### ⚠️ Known Security Limitations

#### 1. **Session Management**

**Current State:**
- ⚠️ No session timeouts (tokens expire after 24 hours)
- ⚠️ Tokens stored in localStorage (XSS vulnerability if not properly sanitized)
- ⚠️ No CSRF protection (not needed for API-only, but consider for cookie-based auth)

**Recommendation:** For production, implement:
- Token refresh mechanism
- Shorter token expiration with refresh tokens
- Consider httpOnly cookies for token storage

---

## Production Security Checklist

Before deploying this application to production, implement the following security measures:

### ✅ Authentication & Authorization (✓ Implemented)

**Current Implementation:**
- ✅ JWT-based authentication using `jwt` gem
- ✅ Authentication controller at `app/controllers/api/v1/auth_controller.rb`
- ✅ `authenticate_user!` before_action in `ApplicationController`
- ✅ Token-based authorization with Bearer tokens
- ✅ Users can only access their own data (authorization checks)
- ✅ Frontend stores tokens and includes in Authorization header
- ✅ Token expiration (24 hours)

**Implementation Details:**
```ruby
# Gemfile
gem 'jwt', '~> 2.9'

# app/controllers/application_controller.rb
# See backend/app/controllers/application_controller.rb

# app/controllers/api/v1/auth_controller.rb
# See backend/app/controllers/api/v1/auth_controller.rb

# Frontend: services/api.ts
# See frontend/src/services/api.ts for Axios interceptors
```

**For Production Enhancement:**
- Add password-based authentication (currently uses user_id for demo)
- Implement token refresh mechanism
- Consider shorter token expiration with refresh tokens
- Add role-based access control (RBAC) for admin functions

#### Option 2: OAuth 2.0 / OpenID Connect

For enterprise applications, consider using:
- **Devise** + **Doorkeeper** (OAuth provider)
- **OmniAuth** (OAuth consumer - Google, GitHub, etc.)
- External identity providers (Auth0, Okta, AWS Cognito)

### ✅ Authorization (✓ Implemented)

**Current Implementation:**
- ✅ Users can only access their own data
- ✅ Authorization checks in controllers (e.g., `current_user.id` validation)
- ✅ Protected endpoints require valid JWT token
- ✅ 403 Forbidden responses for unauthorized access attempts

**Implementation:**
```ruby
# Controllers use current_user from JWT token
# Users can only access their own balance, redemptions, etc.
# See backend/app/controllers/api/v1/users_controller.rb
# See backend/app/controllers/api/v1/redemptions_controller.rb
```

**For Production Enhancement:**
- Add role-based access control (RBAC) for admin functions
- Consider using Pundit or CanCanCan for more complex authorization rules

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

### ✅ Rate Limiting (✓ Implemented)

**Current Implementation:**
- ✅ Rack::Attack middleware configured
- ✅ General API throttling (300 requests per 5 minutes per IP)
- ✅ Login endpoint throttling (5 attempts per 20 seconds per IP)
- ✅ Redemption endpoint throttling (10 per minute per IP)
- ✅ Custom 429 response with rate limit headers

**Configuration:**
```ruby
# Gemfile
gem 'rack-attack'

# config/application.rb
config.middleware.use Rack::Attack

# config/initializers/rack_attack.rb
# See backend/config/initializers/rack_attack.rb for full configuration
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

**Last Updated:** 2025-12-30
