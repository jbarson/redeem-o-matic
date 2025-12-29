# Backend (Rails API)

This is the Rails API backend for Redeem-O-Matic.

For complete documentation, setup instructions, and development workflow, see the [root README.md](../README.md).

## Quick Start

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Run tests
bundle exec rspec

# Start server
rails server
```

## Key Files

- `app/controllers/api/v1/` - API endpoints
- `app/models/` - Database models
- `config/routes.rb` - API routes
- `spec/` - Test suite
