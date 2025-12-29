# Redeem-O-Matic

A rewards redemption web application built with Ruby on Rails (API) and React.

## Project Overview

This application allows users to:
- View their current reward points balance
- Browse available rewards
- Redeem rewards using their points
- See a history of their reward redemptions

## Tech Stack

**Backend:**
- Ruby 3.4.3
- Rails 8.0.2 (API mode)
- SQLite3

**Frontend:**
- React (>16)
- Axios for API calls
- React Router for navigation

**Development:**
- Dev Container with Docker
- VS Code recommended

## Getting Started

### Prerequisites

- Docker Desktop installed
- VS Code with the "Dev Containers" extension

### Setup Instructions

#### 1. Open in Dev Container

1. Open this project folder in VS Code
2. When prompted, click "Reopen in Container" (or use Command Palette: `Dev Containers: Reopen in Container`)
3. Wait for the container to build (first time only, ~2-5 minutes)

#### 2. Run Setup Script

Once inside the dev container, run:

```bash
./setup.sh
```

This will:
- Create the Rails API backend in the `backend/` directory
- Create the React frontend in the `frontend/` directory
- Install all dependencies

#### 3. Start Development Servers

Open two terminals in VS Code:

**Terminal 1 - Rails Backend:**
```bash
cd backend
rails server
```
Backend will run on: http://localhost:3000

**Terminal 2 - React Frontend:**
```bash
cd frontend
PORT=3001 npm start
```
Frontend will run on: http://localhost:3001

## Project Structure

```
redeem-o-matic/
├── .devcontainer/          # Dev container configuration
│   ├── Dockerfile          # Container image definition
│   └── devcontainer.json   # VS Code container settings
├── backend/                # Rails API application
│   ├── app/
│   │   ├── controllers/    # API controllers
│   │   └── models/         # Database models
│   ├── config/             # Rails configuration
│   ├── db/                 # Database schema and migrations
│   └── Gemfile             # Ruby dependencies
├── frontend/               # React application
│   ├── public/             # Static files
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── services/       # API service layer
│   │   └── App.js          # Main app component
│   └── package.json        # Node dependencies
├── setup.sh                # Master setup script
├── setup-backend.sh        # Backend setup script
├── setup-frontend.sh       # Frontend setup script
├── assignment.md           # Project requirements
└── README.md               # This file
```

## Development Workflow

### Backend Development

The Rails backend is API-only and handles:
- RESTful API endpoints
- Business logic
- Database operations

**Common Commands:**
```bash
cd backend

# Generate a model
rails generate model Reward name:string points_required:integer

# Run migrations
rails db:migrate

# Start Rails console
rails console

# Run Rails server
rails server
```

### Frontend Development

The React frontend is a separate SPA that consumes the Rails API.

**Common Commands:**
```bash
cd frontend

# Install new package
npm install package-name

# Start dev server
PORT=3001 npm start

# Build for production
npm run build
```

### API Communication

The React frontend communicates with the Rails backend via HTTP requests:
- Backend API: http://localhost:3000
- Frontend App: http://localhost:3001

CORS is configured in the Rails backend to allow requests from the React frontend.

## Database

SQLite3 is used for development. The database file is located at `backend/db/development.sqlite3`.

**Common Database Commands:**
```bash
cd backend

# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed database (after creating seeds)
rails db:seed

# Reset database
rails db:reset
```

## API Endpoints (To Be Implemented)

The following RESTful endpoints should be implemented:

- `GET /api/users/:id/balance` - Get user's current points balance
- `GET /api/rewards` - List all available rewards
- `POST /api/redemptions` - Redeem a reward
- `GET /api/users/:id/redemptions` - Get user's redemption history

## Testing

Testing frameworks can be added as needed:
- Backend: RSpec or Minitest
- Frontend: Jest and React Testing Library

## Submission Notes

When submitting:
1. Remove `node_modules/` (already in .gitignore)
2. Remove `backend/tmp/` and `backend/log/` directories
3. Include this README.md
4. The `.devcontainer/` configuration allows reviewers to run the project instantly

## Dev Container Benefits

This project uses a dev container which provides:
- Consistent development environment across all machines
- Pre-configured Ruby 3.4.3 and Rails 8.0.2
- No need to install dependencies on host machine
- Instant setup for reviewers
- Isolated environment that won't conflict with other projects

## Troubleshooting

**Container won't build:**
- Ensure Docker Desktop is running
- Try rebuilding: Command Palette → "Dev Containers: Rebuild Container"

**Rails server won't start:**
- Check if port 3000 is already in use
- Ensure you ran migrations: `rails db:migrate`

**React app won't start:**
- Ensure you're in the `frontend/` directory
- Try removing `node_modules/` and running `npm install` again

**Ports not accessible:**
- Check VS Code port forwarding (Ports tab in bottom panel)
- Ensure ports 3000 and 3001 are forwarded

## License

This project is for evaluation purposes as part of a coding challenge.
