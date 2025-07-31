#!/bin/bash

echo "🚀 POS System Quick Start with Enhanced Debugging"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "go.mod" ]; then
    echo "❌ Please run this script from the pos-final root directory"
    exit 1
fi

echo "🔧 Building server..."
go build -o server cmd/server/main.go

if [ $? -ne 0 ]; then
    echo "❌ Failed to build server"
    exit 1
fi

echo "✅ Server built successfully"

echo ""
echo "🌐 Testing server connectivity..."
if ./server &
    SERVER_PID=$!
    sleep 3
    
    if curl -s http://localhost:8080/health > /dev/null; then
        echo "✅ Server is running and responsive"
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
echo "🎯 Starting POS System with enhanced debugging..."
echo ""

# Function to start server
start_server() {
    echo "🔥 Starting Golang server with ultra-detailed logging..."
    ./server &
    SERVER_PID=$!
    echo "Server PID: $SERVER_PID"
    sleep 2
}

# Function to start Flutter
start_flutter() {
    echo "📱 Starting Flutter app with browser-compatible settings..."
    cd pos_flutter_app
    echo "Using HTML renderer for better CORS compatibility..."
    flutter run -d chrome --web-renderer html &
    FLUTTER_PID=$!
    echo "Flutter PID: $FLUTTER_PID"
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
    if [ ! -z "$FLUTTER_PID" ]; then
        kill $FLUTTER_PID 2>/dev/null
        echo "✅ Flutter stopped"
    fi
    exit 0
}

# Set up cleanup on script exit
trap cleanup EXIT INT TERM

# Start services
start_server
start_flutter

echo ""
echo "🎉 POS System is starting up!"
echo ""
echo "📊 Monitoring setup:"
echo "  🌐 Server: http://localhost:8080"
echo "  📱 Flutter Web: Will open automatically"
echo "  🩺 Health Check: http://localhost:8080/health"
echo ""
echo "🔍 Enhanced logging is active:"
echo "  ✅ Ultra-detailed Flutter API debugging"
echo "  ✅ Comprehensive Golang request tracking"
echo "  ✅ CORS troubleshooting information"
echo "  ✅ Browser-specific error analysis"
echo ""
echo "⏸️  Press Ctrl+C to stop both services"
echo ""

# Wait for user to stop
wait