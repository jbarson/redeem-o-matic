#!/bin/bash

# Script to start both frontend and backend servers
# Usage: ./start.sh

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Redeem-O-Matic servers...${NC}\n"

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down servers...${NC}"
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    exit
}

# Trap Ctrl+C and call cleanup
trap cleanup INT TERM

# Check if ports are already in use
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Port 3000 is already in use. Stopping existing process...${NC}"
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true
    sleep 1
fi

if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Port 3001 is already in use. Stopping existing process...${NC}"
    lsof -ti:3001 | xargs kill -9 2>/dev/null || true
    sleep 1
fi

# Start backend server
echo -e "${GREEN}Starting backend server on port 3000...${NC}"
cd backend
bundle exec rails server -p 3000 > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Wait a moment for backend to start
sleep 2

# Start frontend server
echo -e "${GREEN}Starting frontend server on port 3001...${NC}"
cd frontend
PORT=3001 npm start > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

echo -e "\n${BLUE}✓ Backend server started (PID: $BACKEND_PID)${NC}"
echo -e "${BLUE}✓ Frontend server started (PID: $FRONTEND_PID)${NC}"
echo -e "\n${GREEN}Servers are running!${NC}"
echo -e "${BLUE}Backend:  http://localhost:3000${NC}"
echo -e "${BLUE}Frontend: http://localhost:3001${NC}"
echo -e "\n${YELLOW}Press Ctrl+C to stop both servers${NC}\n"

# Wait for both processes
wait

