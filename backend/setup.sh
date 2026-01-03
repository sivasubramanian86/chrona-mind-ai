#!/bin/bash

echo "🚀 Setting up ChronaMindAI Backend"
echo "=================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ Node.js and npm are installed"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit the .env file with your actual configuration values"
    echo "   Required: MONGODB_URI, JWT_SECRET, OPENAI_API_KEY"
else
    echo "✅ .env file already exists"
fi

# Check if MongoDB is running
echo "🗄️  Checking MongoDB connection..."
if command -v mongosh &> /dev/null; then
    if mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
        echo "✅ MongoDB is running"
    else
        echo "⚠️  MongoDB is not running. Please start MongoDB:"
        echo "   - Local: mongod"
        echo "   - Docker: docker run -d -p 27017:27017 --name mongodb mongo:latest"
    fi
else
    echo "⚠️  MongoDB client not found. Please ensure MongoDB is installed and running"
fi

echo ""
echo "🎉 Backend setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env with your configuration"
echo "2. Start the server: npm start"
echo "3. For development: npm run dev"
echo ""
echo "📚 API Documentation: http://localhost:3000/api/health"