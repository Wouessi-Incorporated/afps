#!/bin/bash

# AFRIPULSE Docker Startup Script
# This script helps you test the Docker setup locally before deploying to Coolify

set -e

echo "🚀 AFRIPULSE Docker Startup Script"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

print_success "Docker and Docker Compose are installed"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_warning ".env file not found, creating from template..."
    cat > .env << EOL
# AFRIPULSE Local Docker Environment
POSTGRES_PASSWORD=afripulse_local_2024
DATABASE_URL=postgres://afripulse:afripulse_local_2024@postgres:5432/afripulse
NODE_ENV=development
JWT_SECRET=afripulse_local_jwt_secret_2024
WHATSAPP_WEBHOOK_VERIFY_TOKEN=local_webhook_token_2024
APP_DOMAIN=localhost
BACKEND_URL=http://localhost:8080
BACKEND_PUBLIC_URL=http://localhost:8080
CORS_ORIGIN=http://localhost:3000,http://localhost:8080
EOL
    print_success ".env file created with local development settings"
else
    print_success ".env file found"
fi

# Function to check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check if required ports are available
PORTS_TO_CHECK=(3000 8080 5432)
PORTS_IN_USE=()

for port in "${PORTS_TO_CHECK[@]}"; do
    if check_port $port; then
        PORTS_IN_USE+=($port)
    fi
done

if [ ${#PORTS_IN_USE[@]} -gt 0 ]; then
    print_warning "The following ports are in use: ${PORTS_IN_USE[*]}"
    echo "You may need to stop other services or the existing containers might be running."
    echo ""
    read -p "Do you want to stop any existing AFRIPULSE containers? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping existing containers..."
        docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true
    fi
fi

print_status "Starting AFRIPULSE system with Docker..."
echo ""

# Start the services
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

# Pull latest images
print_status "Pulling latest base images..."
$COMPOSE_CMD pull postgres 2>/dev/null || true

# Build and start services
print_status "Building and starting services..."
$COMPOSE_CMD up -d --build

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 10

# Check service health
print_status "Checking service health..."

# Check PostgreSQL
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "afripulse-postgres.*Up"; then
    print_success "PostgreSQL is running"
else
    print_error "PostgreSQL failed to start"
    exit 1
fi

# Check Backend
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "afripulse-backend.*Up"; then
    print_success "Backend API is running"
else
    print_error "Backend API failed to start"
    exit 1
fi

# Check Frontend
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "afripulse-frontend.*Up"; then
    print_success "Frontend website is running"
else
    print_error "Frontend website failed to start"
    exit 1
fi

# Test API endpoints
print_status "Testing API endpoints..."

# Wait a bit more for services to fully initialize
sleep 5

# Test health endpoint
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    print_success "Health endpoint is responding"
else
    print_warning "Health endpoint is not responding yet (may need more time)"
fi

# Test media shares endpoint
if curl -s "http://localhost:8080/public/media-shares?country=NG&category=ALL" > /dev/null 2>&1; then
    print_success "Media shares endpoint is responding"
else
    print_warning "Media shares endpoint is not responding yet (may need more time)"
fi

# Test frontend
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    print_success "Frontend website is accessible"
else
    print_warning "Frontend website is not accessible yet (may need more time)"
fi

echo ""
echo "🎉 AFRIPULSE System is now running!"
echo "=================================="
echo ""
echo "📱 Frontend Website:"
echo "   http://localhost:3000"
echo "   - Homepage: http://localhost:3000/"
echo "   - Dashboard: http://localhost:3000/dashboard.html"
echo ""
echo "🔗 Backend API:"
echo "   http://localhost:8080"
echo "   - Health: http://localhost:8080/health"
echo "   - Media: http://localhost:8080/public/media-shares?country=NG&category=ALL"
echo ""
echo "🗄️  Database:"
echo "   PostgreSQL running on localhost:5432"
echo "   - Database: afripulse"
echo "   - Username: afripulse"
echo "   - Password: afripulse_local_2024"
echo ""
echo "📊 Container Status:"
$COMPOSE_CMD ps
echo ""
echo "📋 Useful Commands:"
echo "   View logs: $COMPOSE_CMD logs -f [service_name]"
echo "   Stop all:  $COMPOSE_CMD down"
echo "   Restart:   $COMPOSE_CMD restart [service_name]"
echo "   Shell:     docker exec -it afripulse-backend sh"
echo "   DB Shell:  docker exec -it afripulse-postgres psql -U afripulse -d afripulse"
echo ""
echo "🚨 To stop the system:"
echo "   $COMPOSE_CMD down"
echo ""
echo "🔗 Ready for Coolify deployment!"
echo "   Follow COOLIFY_DEPLOYMENT.md for production deployment"
echo ""

# Optional: Open browser
if command -v xdg-open &> /dev/null; then
    read -p "Open http://localhost:3000 in browser? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        xdg-open http://localhost:3000
    fi
elif command -v open &> /dev/null; then
    read -p "Open http://localhost:3000 in browser? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open http://localhost:3000
    fi
fi

print_success "Startup complete! System is ready for use."
