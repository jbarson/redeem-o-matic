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
- Passwordless user selection (demo mode - see [Assumptions](#assumptions))
- JWT-based authentication with protected routes
- Persistent session with localStorage

**Rewards Management:**
- Browse active rewards with images and descriptions
- Real-time points balance updates
- Confirmation modal before redemption
- Stock quantity tracking

**Redemption Flow:**
- Transaction-safe reward redemption with pessimistic locking
- Automatic point deduction
- Stock quantity tracking
- Success/error messaging

**History Tracking:**
- View past redemptions with details
- Formatted dates and costs
- Reward information display
- Pagination support

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
- JWT for authentication
- Rack::Attack for rate limiting

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
- Install backend dependencies (Ruby gems)
- Install frontend dependencies (npm packages)
- Set up the database schema

**Note:** If the project is already set up, you can run the individual setup scripts:
- `./setup-backend.sh` - Backend setup only
- `./setup-frontend.sh` - Frontend setup only

#### 3. Start Development Servers

**Option A: Using the start script (Recommended)**

From the project root:

```bash
./start.sh
```

This script will:
- Kill any existing processes on ports 3000 and 3001
- Start the Rails backend server on port 3000
- Start the React frontend server on port 3001
- Log output to `backend.log` and `frontend.log`

Press `Ctrl+C` to stop both servers.

**Option B: Manual startup (Two terminals)**

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

#### 4. Access the Application

- **Frontend:** http://localhost:3001
- **Backend API:** http://localhost:3000
- **API Documentation:** See [API Endpoints](#api-endpoints) section below

## Assumptions

Based on the requirements in [`assignment.md`](./assignment.md), the following assumptions and design decisions were made:

1. **Passwordless Authentication (Demo Mode)**
   - The login functionality is **passwordless** in this iteration
   - Users select their account from a list without password verification
   - This is a demo/evaluation implementation - production would require proper password authentication
   - JWT tokens are generated upon user selection for session management
   - See [SECURITY.md](./SECURITY.md) for security considerations

2. **Database Choice**
   - SQLite3 is used for development (as preferred in requirements)
   - Database schema includes Users, Rewards, and Redemptions tables
   - See [ERD.md](./ERD.md) for the complete database schema

3. **User Interface**
   - Web-based interface (React SPA) was chosen over CLI
   - This aligns with the preference stated in requirements for frontend-focused submissions

4. **API Design**
   - RESTful API endpoints following Rails conventions
   - API versioning (`/api/v1/`) for future compatibility
   - JSON responses for all endpoints

5. **Data Model**
   - Users have a `points_balance` that tracks available points
   - Rewards have a `cost` in points and optional `stock_quantity`
   - Redemptions track the transaction history with status
   - See [ERD.md](./ERD.md) for detailed schema

6. **Transaction Safety**
   - Redemptions use database transactions with pessimistic locking
   - Prevents race conditions and ensures data consistency
   - Stock quantities and user balances are updated atomically

7. **Error Handling**
   - Comprehensive error handling on both frontend and backend
   - User-friendly error messages
   - Proper HTTP status codes

8. **Testing**
   - Backend: RSpec with FactoryBot for test data
   - Frontend: Jest with React Testing Library
   - Test coverage for models, controllers, and components

## Running Tests

### Backend Tests (RSpec)

```bash
cd backend
bundle exec rspec
```

**Test Coverage:**
- Model tests (validations, associations, scopes)
- Request specs (API endpoints, error handling, transaction safety)
- Authentication and authorization tests
- Race condition tests
- Factories with FactoryBot and Faker

**Run with coverage:**
```bash
bundle exec rspec --format documentation
```

**Run specific test file:**
```bash
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/requests/api/v1/users_spec.rb
```

### Frontend Tests (Jest + React Testing Library)

```bash
cd frontend
npm test
```

**Run without watch mode:**
```bash
npm test -- --watchAll=false
```

**Run with coverage:**
```bash
npm test -- --coverage --watchAll=false
```

**Test Coverage:**
- Component tests (RewardCard, PointsBalance, ConfirmModal)
- User interaction tests
- TypeScript integration
- Error handling tests

### Run All Tests

To run both backend and frontend tests:

```bash
# Backend tests
cd backend && bundle exec rspec && cd ..

# Frontend tests
cd frontend && npm test -- --watchAll=false && cd ..
```

## Project Structure

```
redeem-o-matic/
├── .tool-versions          # asdf version configuration
├── .env.example            # Environment variables template
├── .gitignore              # Git ignore rules
├── .gitattributes          # Git attributes
├── backend/                # Rails API application
│   ├── app/
│   │   ├── controllers/    # API controllers (Users, Rewards, Redemptions, Auth)
│   │   └── models/         # Database models (User, Reward, Redemption)
│   ├── config/             # Rails configuration (CORS, routes, rack_attack)
│   ├── db/                 # Database schema, migrations, seeds
│   ├── spec/               # RSpec tests (models, requests, factories)
│   └── Gemfile             # Ruby dependencies
├── frontend/               # React + TypeScript application
│   ├── public/             # Static files
│   ├── src/
│   │   ├── components/     # React components (common, rewards, user, etc.)
│   │   ├── context/        # UserContext for authentication
│   │   ├── pages/          # Page components (Dashboard, Rewards, History, Login)
│   │   ├── services/       # API service layer (axios client, logger)
│   │   ├── styles/         # CSS files for components
│   │   ├── types/          # TypeScript type definitions
│   │   └── App.tsx         # Main app component
│   ├── package.json        # Node dependencies
│   └── tsconfig.json       # TypeScript configuration
├── setup.sh                # Master setup script
├── setup-backend.sh        # Backend setup script
├── setup-frontend.sh       # Frontend setup script
├── start.sh                # Start both servers script
├── assignment.md           # Project requirements
├── SECURITY.md             # Security documentation
├── ERD.md                  # Entity-Relationship Diagram
├── README.md               # This file
├── backend/README.md       # Backend-specific documentation
└── frontend/README.md      # Frontend-specific documentation
```

## Documentation

- **[SECURITY.md](./SECURITY.md)** - Security documentation, implemented features, and production recommendations
- **[ERD.md](./ERD.md)** - Entity-Relationship Diagram showing database schema and relationships
- **[backend/README.md](./backend/README.md)** - Backend-specific quick start and key files
- **[frontend/README.md](./frontend/README.md)** - Frontend-specific quick start and key files
- **[assignment.md](./assignment.md)** - Original project requirements

## API Endpoints

The following RESTful endpoints are implemented:

### Authentication
- `POST /api/v1/auth/login` - Login (passwordless - accepts `user_id`)

### Users
- `GET /api/v1/users` - List all users (public - for login selection, returns only `id` and `name`)
- `GET /api/v1/users/:id/balance` - Get user's current points balance (protected)
- `GET /api/v1/users/:id/redemptions` - Get user's redemption history (protected, supports `limit` and `offset`)

### Rewards
- `GET /api/v1/rewards` - List all available rewards (protected)

### Redemptions
- `POST /api/v1/redemptions` - Redeem a reward (protected, requires `reward_id`)

**Authentication:**
All protected endpoints require a JWT token in the `Authorization` header:
```
Authorization: Bearer <token>
```

**Response Format:**
All endpoints return JSON responses with proper error handling and HTTP status codes.

**Pagination:**
The redemptions endpoint supports pagination:
- `limit` - Number of records to return (1-100, default: 50)
- `offset` - Number of records to skip (default: 0)

## Development Workflow

### Backend Development

The Rails backend is API-only and handles:
- RESTful API endpoints
- Business logic
- Database operations
- Authentication and authorization
- Rate limiting

**Common Commands:**
```bash
cd backend

# Generate a model
rails generate model Reward name:string cost:integer

# Run migrations
rails db:migrate

# Start Rails console
rails console

# Run Rails server
rails server

# Run tests
bundle exec rspec
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

# Run tests
npm test
```

### API Communication

The React frontend communicates with the Rails backend via HTTP requests:
- Backend API: http://localhost:3000
- Frontend App: http://localhost:3001

CORS is configured in the Rails backend to allow requests from the React frontend.

## Database

SQLite3 is used for development. The database file is located at `backend/storage/development.sqlite3`.

**Common Database Commands:**
```bash
cd backend

# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed database
rails db:seed

# Reset database (drop, create, migrate, seed)
rails db:reset

# View database schema
rails db:schema:dump
```

## Environment Variables

See [`.env.example`](./.env.example) for all available environment variables.

**Key Variables:**
- `REACT_APP_API_URL` - Frontend API base URL (default: `http://localhost:3000/api/v1`)
- `CORS_ORIGINS` - Backend CORS allowed origins (default: `http://localhost:3001`)
- `RAILS_ENV` - Rails environment (development, test, production)

## Troubleshooting

**Wrong Ruby version:**
- Ensure asdf is properly configured in your shell
- Run `asdf current` to verify Ruby 3.4.3 is active
- Try `asdf reshim ruby` if commands aren't found

**Rails server won't start:**
- Check if port 3000 is already in use: `lsof -i :3000`
- Ensure you ran migrations: `rails db:migrate`
- Verify all gems are installed: `bundle install`
- Check `backend.log` for error messages

**React app won't start:**
- Ensure you're in the `frontend/` directory
- Try removing `node_modules/` and running `npm install` again
- Check if port 3001 is already in use: `lsof -i :3001`
- Check `frontend.log` for error messages

**Database issues:**
- Reset the database: `cd backend && rails db:reset`
- Check SQLite3 is installed: `sqlite3 --version`
- Verify database file exists: `ls -la backend/storage/development.sqlite3`

**Authentication issues:**
- Clear browser localStorage if experiencing auth problems
- Check that JWT gem is installed: `cd backend && bundle list | grep jwt`
- Verify backend is running and accessible

**Port conflicts:**
- Use `./start.sh` which automatically kills processes on ports 3000 and 3001
- Or manually: `lsof -ti:3000 | xargs kill -9` and `lsof -ti:3001 | xargs kill -9`

## Security Features

This application includes several security features:

- ✅ JWT-based authentication
- ✅ Authorization (users can only access their own data)
- ✅ Rate limiting (Rack::Attack)
- ✅ Input validation and sanitization
- ✅ CORS configuration
- ✅ Transaction-safe operations

See [SECURITY.md](./SECURITY.md) for detailed security documentation, including:
- Current security status
- Implemented features
- Known limitations
- Production recommendations

## License

This project is for evaluation purposes as part of a coding challenge.
