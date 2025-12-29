#!/bin/bash
# Setup script for Rails API backend
# Run this from the project root directory

set -e

echo "🚀 Setting up Rails API backend..."

# Get the script's directory and navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create Rails API backend if it doesn't exist
if [ ! -f "backend/config/application.rb" ]; then
    echo "📦 Creating new Rails API application..."
    rails new backend --api --database=sqlite3 --skip-test --force

    cd backend

    echo "📝 Configuring CORS..."
    # Add rack-cors to Gemfile
    echo "" >> Gemfile
    echo "# CORS configuration for React frontend" >> Gemfile
    echo "gem 'rack-cors'" >> Gemfile

    # Install gems
    bundle install

    echo "✅ Rails backend created successfully!"
else
    echo "✓ Rails backend already exists"
    cd backend
    bundle install
fi

echo ""
echo "🎉 Backend setup complete!"
echo ""
echo "Next steps:"
echo "  1. Configure CORS in config/initializers/cors.rb"
echo "  2. Generate models and controllers for rewards system"
echo "  3. Run 'rails db:migrate' to set up database"
echo "  4. Start server with 'rails server'"
