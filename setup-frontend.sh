#!/bin/bash
# Setup script for React frontend
# Run this from the project root directory

set -e

echo "🚀 Setting up React frontend..."

# Get the script's directory and navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create React frontend if it doesn't exist
if [ ! -f "frontend/package.json" ]; then
    echo "📦 Creating new React application..."
    npx create-react-app frontend

    cd frontend

    echo "📝 Installing additional dependencies..."
    npm install axios react-router-dom

    echo "✅ React frontend created successfully!"
else
    echo "✓ React frontend already exists"
    cd frontend
    npm install
fi

echo ""
echo "🎉 Frontend setup complete!"
echo ""
echo "Next steps:"
echo "  1. Configure API endpoint to connect to Rails backend (http://localhost:3000)"
echo "  2. Build components for rewards browsing and redemption"
echo "  3. Start dev server with 'npm start' (will run on port 3001)"
