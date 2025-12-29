# Redeem-O-Matic

A rewards redemption web application built with Ruby on Rails (API) and React.

## Project Overview

This application allows users to:
- View their current reward points balance
- Browse available rewards
- Redeem rewards using their points
- See a history of their reward redemptions

## Features

**Authentication:**
- Simple email-based user selection (demo mode)
- Protected routes requiring authentication
- Persistent session with localStorage

**Rewards Management:**
- Browse active rewards with images and descriptions
- Filter by stock availability
- Real-time points balance updates
- Confirmation modal before redemption

**Redemption Flow:**
- Transaction-safe reward redemption
- Automatic point deduction
- Stock quantity tracking
- Success/error messaging

**History Tracking:**
- View past redemptions with details
- Formatted dates and costs
- Reward information display

**UI/UX:**
- Responsive design
- Loading states during API calls
- Error handling with user-friendly messages
- Clean, functional styling

## Tech Stack

**Backend:**
- Ruby 3.4.3
- Rails 8.0.2 (API mode)
- SQLite3
- RSpec (testing)
- FactoryBot & Faker (test data)

**Frontend:**
- React 19 with TypeScript
- React Router v7 for navigation
- Axios for API calls
- Jest & React Testing Library (testing)

**Development:**
- asdf for Ruby version management
- Local development environment
- Git version control

## Getting Started

### Prerequisites

- **Ruby 3.4.3** - Managed via [asdf](https://asdf-vm.com/) (see `.tool-versions`)
- **Node.js** (v16 or higher) - Install via [asdf](https://asdf-vm.com/) or [nvm](https://github.com/nvm-sh/nvm)
- **SQLite3** - Usually pre-installed on macOS/Linux
- **Bundler** - Install with `gem install bundler`

### Setup Instructions

#### 1. Install Ruby

```bash
# Install asdf (if not already installed)
# Follow instructions at: https://asdf-vm.com/guide/getting-started.html

# Install Ruby plugin
asdf plugin add ruby

# Install Ruby 3.4.3 (specified in .tool-versions)
asdf install
```

#### 2. Run Setup Script

From the project root, run:

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
├── .tool-versions          # asdf version configuration
├── backend/                # Rails API application
│   ├── app/
│   │   ├── controllers/    # API controllers (Users, Rewards, Redemptions)
│   │   └── models/         # Database models (User, Reward, Redemption)
│   ├── config/             # Rails configuration (CORS, routes)
│   ├── db/                 # Database schema, migrations, seeds
│   ├── spec/               # RSpec tests (models, requests, factories)
│   └── Gemfile             # Ruby dependencies
├── frontend/               # React + TypeScript application
│   ├── public/             # Static files
│   ├── src/
│   │   ├── components/     # React components (common, rewards, user, etc.)
│   │   ├── context/        # UserContext for authentication
│   │   ├── pages/          # Page components (Dashboard, Rewards, History)
│   │   ├── services/       # API service layer (axios client)
│   │   ├── styles/         # CSS files for components
│   │   ├── types/          # TypeScript type definitions
│   │   └── App.tsx         # Main app component
│   ├── package.json        # Node dependencies
│   └── tsconfig.json       # TypeScript configuration
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

## API Endpoints

The following RESTful endpoints are implemented:

- `GET /api/v1/users` - List all users (for login selection)
- `GET /api/v1/users/:id/balance` - Get user's current points balance
- `GET /api/v1/rewards` - List all available rewards
- `POST /api/v1/redemptions` - Redeem a reward (with transaction safety)
- `GET /api/v1/users/:id/redemptions` - Get user's redemption history

All endpoints return JSON responses and include proper error handling.

## Testing

Comprehensive test suites are included:

**Backend Tests (RSpec):**
```bash
cd backend
bundle exec rspec
```
- **Coverage:** 89.55%
- **Tests:** 57 examples, 0 failures
- Model tests (validations, associations)
- Request specs (API endpoints, error handling, transaction safety)
- Factories with FactoryBot and Faker

**Frontend Tests (Jest + React Testing Library):**
```bash
cd frontend
npm test -- --coverage
```
- **Coverage:** 100% (for tested components)
- **Tests:** 20 tests passing
- Component tests (RewardCard, PointsBalance, ConfirmModal)
- User interaction tests
- TypeScript integration

## Submission Notes

When submitting:
1. Remove `node_modules/` (already in .gitignore)
2. Remove `backend/tmp/` and `backend/log/` directories
3. Include this README.md
4. Ensure `.tool-versions` is included for Ruby version consistency

## Troubleshooting

**Wrong Ruby version:**
- Ensure asdf is properly configured in your shell
- Run `asdf current` to verify Ruby 3.4.3 is active
- Try `asdf reshim ruby` if commands aren't found

**Rails server won't start:**
- Check if port 3000 is already in use: `lsof -i :3000`
- Ensure you ran migrations: `rails db:migrate`
- Verify all gems are installed: `bundle install`

**React app won't start:**
- Ensure you're in the `frontend/` directory
- Try removing `node_modules/` and running `npm install` again
- Check if port 3001 is already in use: `lsof -i :3001`

**Database issues:**
- Reset the database: `cd backend && rails db:reset`
- Check SQLite3 is installed: `sqlite3 --version`

## License

This project is for evaluation purposes as part of a coding challenge.
