#!/bin/bash

# Railway deployment script
echo "🚀 Deploying to Railway..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI is not installed. Please install it first:"
    echo "npm install -g @railway/cli"
    exit 1
fi

# Login to Railway (if not already logged in)
echo "🔐 Checking Railway authentication..."
railway login

# Set environment variables
echo "⚙️  Setting environment variables..."

# Set the Redis URL for Railway
railway variables set REDIS_URL="redis://ballast.proxy.rlwy.net:31355"

# Set Rails environment
railway variables set RAILS_ENV="production"

# Set Rails master key (you'll need to provide this)
echo "🔑 Please enter your Rails master key:"
read -s RAILS_MASTER_KEY
railway variables set RAILS_MASTER_KEY="$RAILS_MASTER_KEY"

# Set other production variables
railway variables set RAILS_SERVE_STATIC_FILES="true"
railway variables set RAILS_LOG_TO_STDOUT="true"
railway variables set RAILS_MAX_THREADS="5"

# Deploy to Railway
echo "🚀 Deploying application..."
railway up

echo "✅ Deployment complete!"
echo "🌐 Your application should be available at the Railway URL"
