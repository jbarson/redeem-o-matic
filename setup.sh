#!/bin/bash
# Master setup script for Redeem-O-Matic
# Run this inside the dev container after opening the project

set -e

echo "════════════════════════════════════════════"
echo "  Redeem-O-Matic Project Setup"
echo "════════════════════════════════════════════"
echo ""

# Run backend setup
./setup-backend.sh

echo ""
echo "----------------------------------------"
echo ""

# Run frontend setup
./setup-frontend.sh

echo ""
echo "════════════════════════════════════════════"
echo "  ✨ Setup Complete! ✨"
echo "════════════════════════════════════════════"
echo ""
echo "To start development:"
echo ""
echo "  Terminal 1 - Backend:"
echo "    cd backend"
echo "    rails server"
echo ""
echo "  Terminal 2 - Frontend:"
echo "    cd frontend"
echo "    PORT=3001 npm start"
echo ""
echo "Then visit: http://localhost:3001"
echo "Backend API: http://localhost:3000"
echo ""
