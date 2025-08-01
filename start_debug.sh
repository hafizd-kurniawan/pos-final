#!/bin/bash

echo "🚀 STARTING POS SYSTEM WITH REACT WEB APP"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "go.mod" ]; then
    echo "❌ Please run this script from the pos-final root directory"
    exit 1
fi

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

echo "🔍 ENVIRONMENT CHECK"
echo "Go version: $(go version)"
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo ""

echo "🔧 Building server..."
go build -o server cmd/server/main.go

if [ $? -ne 0 ]; then
    echo "❌ Failed to build server"
    exit 1
fi

echo "✅ Server built successfully"

echo ""
echo "🏥 HEALTH CHECK"
echo "Testing server connectivity..."
if ./server &
    SERVER_PID=$!
    sleep 3
    
    if curl -s http://localhost:8080/health > /dev/null; then
        echo "✅ Server is running and responsive"
        echo "📊 Server health: $(curl -s http://localhost:8080/health)"
        kill $SERVER_PID
    else
        echo "❌ Server is not responding"
        kill $SERVER_PID 2>/dev/null
        exit 1
    fi
else
    echo "❌ Failed to start server"
    exit 1
fi

echo ""
echo "🎯 Starting POS System with React Web App..."
echo ""

# Function to start server
start_server() {
    echo "🔥 Starting Golang server with ultra-detailed logging..."
    ./server &
    SERVER_PID=$!
    echo "Server PID: $SERVER_PID"
    sleep 2
}

# Function to start React app
start_react() {
    echo "🌐 Starting React web application..."
    cd pos-web-app
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing dependencies..."
        npm install
    fi
    
    echo "🔧 Starting React development server..."
    BROWSER=none npm start &
    REACT_PID=$!
    echo "React PID: $REACT_PID"
    cd ..
}

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    if [ ! -z "$SERVER_PID" ]; then
        kill $SERVER_PID 2>/dev/null
        echo "✅ Server stopped"
    fi
    if [ ! -z "$REACT_PID" ]; then
        kill $REACT_PID 2>/dev/null
        echo "✅ React app stopped"
    fi
    exit 0
}

# Set up cleanup on script exit
trap cleanup EXIT INT TERM

# Start services
start_server
start_react

echo ""
echo "🎉 POS System is starting up!"
echo ""
echo "📊 Monitoring setup:"
echo "  🌐 Backend Server: http://localhost:8080"
echo "  🌐 React Web App: http://localhost:3000"
echo "  🩺 Health Check: http://localhost:8080/health"
echo ""
echo "🔍 Enhanced logging is active:"
echo "  ✅ Ultra-detailed React API debugging"
echo "  ✅ Comprehensive Golang request tracking"
echo "  ✅ No CORS issues with React"
echo "  ✅ Real-time error monitoring"
echo ""
echo "🔐 LOGIN CREDENTIALS"
echo "Username: kasir1"
echo "Password: password123"
echo ""
echo "⏸️  Press Ctrl+C to stop both services"
echo ""

# Wait for user to stop
wait