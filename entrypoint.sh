#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Install dependencies if they don't exist
if [ ! -f /usr/local/bundle/config ]; then
  bundle install
fi

# Wait for Redis to be ready
echo "Waiting for Redis..."
until redis-cli -h redis ping; do
  echo "Redis is unavailable - sleeping"
  sleep 1
done
echo "Redis is ready!"

echo "Starting Sidekiq..."
bundle exec sidekiq &

sleep 2

# Then exec the container's main process (what's set as CMD in the Dockerfile).
# Use bundle exec to ensure gems are available
if [[ "$1" == "rails" ]]; then
  exec bundle exec "$@"
else
  exec "$@"
fi
