#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Wait for database to be ready (for Railway PostgreSQL)
echo "Waiting for database..."
until pg_isready -h $DATABASE_HOST -U $DATABASE_USERNAME -d $DATABASE_NAME; do
  echo "Database is unavailable - sleeping"
  sleep 1
done
echo "Database is ready!"

# Run database migrations in production
echo "Running database migrations..."
bundle exec rails db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
