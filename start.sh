#!/bin/bash

echo "🎵 Starting Music App with Vocal Separation..."
echo ""

# Check if backend directory exists
if [ ! -d "backend" ]; then
    echo "❌ Backend directory not found. Please run from project root."
    exit 1
fi

# Check if frontend directory exists
if [ ! -d "frontend" ]; then
    echo "❌ Frontend directory not found. Please run from project root."
    exit 1
fi

# Function to start backend
start_backend() {
    echo "🔧 Starting Backend (Flask)..."
    cd backend
    
    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        echo "❌ Virtual environment not found. Please run backend/setup.sh first."
        exit 1
    fi
    
    # Activate virtual environment and start Flask
    source venv/bin/activate
    python app.py &
    BACKEND_PID=$!
    echo "✅ Backend started (PID: $BACKEND_PID) - http://localhost:5000"
    cd ..
}

# Function to start frontend
start_frontend() {
    echo "⚛️  Starting Frontend (React)..."
    cd frontend
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing frontend dependencies..."
        npm install
    fi
    
    # Start React development server
    npm start &
    FRONTEND_PID=$!
    echo "✅ Frontend started (PID: $FRONTEND_PID) - http://localhost:3000"
    cd ..
}

# Start both services
start_backend
sleep 3
start_frontend

echo ""
echo "🚀 Both services are starting..."
echo "🔧 Backend: http://localhost:5000"
echo "⚛️  Frontend: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop both services"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    echo "✅ Services stopped"
    exit 0
}

# Trap Ctrl+C and call cleanup
trap cleanup INT

# Wait for any key to exit
read -p "Press Enter to stop services..."
cleanup