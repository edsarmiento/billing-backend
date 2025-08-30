# Billing Backend

A Rails API application for invoice consultation and management.

## Prerequisites

- **Docker** and **Docker Compose** installed on your system
- **RAILS_MASTER_KEY** environment variable (for Rails credentials)

## Local Development Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd billing-backend
```

### 2. Environment Setup

Create a `.env` file in the root directory with your Rails master key:

```bash
# Copy your Rails master key from config/master.key or generate a new one
RAILS_MASTER_KEY=your_rails_master_key_here
```

### 3. Start the Application

The application uses Docker Compose to run all services (Rails app, PostgreSQL, Redis) together:

```bash
# Build and start all services
docker compose up --build

# Or run in detached mode
docker compose up --build -d
```

This will start:
- **Rails API server** on `http://localhost:3000`
- **Redis** for caching and Action Cable

### 4. Access the Application

- **API**: `http://localhost:3000`

## API Endpoints

- **API Base**: `/api/v1/`
- **Invoices**: 
  - `GET /api/v1/invoices` - List invoices
  - `GET /api/v1/invoices/:id` - Show invoice details
  - `GET /api/v1/invoices/export` - Export invoices

## Docker Commands

### Useful Commands

## Development Workflow

1. **Start services**: `docker compose up --build`
2. **Make code changes** - Files are mounted as volumes, so changes are reflected immediately
3. **View logs**: `docker compose logs -f web`
4. **Stop services**: `docker compose down`

## CORS Configuration

The application is configured to accept requests from any origin (`*`) for development purposes. This allows cross-origin requests from frontend applications.

## Services Architecture

- **web**: Rails API application
- **redis**: Redis server for caching and Action Cable
