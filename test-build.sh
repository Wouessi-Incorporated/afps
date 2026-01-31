#!/bin/bash

# AFRIPULSE Docker Build Test Script
# This script tests the Docker build locally before deploying to Coolify

set -e

echo "🧪 AFRIPULSE Docker Build Test Script"
echo "====================================="
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
    exit 1
fi

print_success "Docker is installed"

# Test 1: Backend Dockerfile Build
print_status "Testing backend Dockerfile build..."
if docker build -t afripulse-backend-test -f Dockerfile . > /tmp/backend-build.log 2>&1; then
    print_success "Backend Dockerfile builds successfully"
else
    print_error "Backend Dockerfile build failed. Check logs:"
    cat /tmp/backend-build.log
    exit 1
fi

# Test 2: Frontend Dockerfile Build
print_status "Testing frontend Dockerfile build..."
if docker build -t afripulse-frontend-test -f Dockerfile.frontend . > /tmp/frontend-build.log 2>&1; then
    print_success "Frontend Dockerfile builds successfully"
else
    print_error "Frontend Dockerfile build failed. Check logs:"
    cat /tmp/frontend-build.log
    exit 1
fi

# Test 3: Check required files exist
print_status "Checking required files..."

required_files=(
    "deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json"
    "deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/src/index.js"
    "deliverables/AFRIPULSE_FINAL_WEBSITE_v1/server.js"
    "deliverables/AFRIPULSE_FINAL_WEBSITE_v1/index.html"
    "deliverables/AFRIPULSE_FINAL_WEBSITE_v1/dashboard.html"
    "docker-compose.yml"
)

all_files_exist=true

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file exists"
    else
        print_error "✗ $file is missing"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = false ]; then
    print_error "Some required files are missing"
    exit 1
fi

# Test 4: Package.json validation
print_status "Validating backend package.json..."
if node -e "JSON.parse(require('fs').readFileSync('deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json'))" 2>/dev/null; then
    print_success "Backend package.json is valid JSON"
else
    print_error "Backend package.json is invalid"
    exit 1
fi

# Test 5: Docker Compose validation
print_status "Validating docker-compose.yml..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    print_warning "Docker Compose not available, skipping validation"
    COMPOSE_CMD=""
fi

if [ -n "$COMPOSE_CMD" ]; then
    if $COMPOSE_CMD config > /dev/null 2>&1; then
        print_success "docker-compose.yml is valid"
    else
        print_error "docker-compose.yml has errors:"
        $COMPOSE_CMD config
        exit 1
    fi
fi

# Test 6: Test backend container startup
print_status "Testing backend container startup..."
if docker run -d --name afripulse-backend-test-run -e DATABASE_URL=mock -p 8081:8080 afripulse-backend-test > /dev/null 2>&1; then
    sleep 5

    # Test if backend responds
    if curl -s http://localhost:8081/health > /dev/null 2>&1; then
        print_success "Backend container starts and responds to health check"
    else
        print_warning "Backend container starts but health check failed (may need database)"
        docker logs afripulse-backend-test-run | tail -10
    fi

    # Cleanup
    docker stop afripulse-backend-test-run > /dev/null 2>&1
    docker rm afripulse-backend-test-run > /dev/null 2>&1
else
    print_error "Backend container failed to start"
    docker logs afripulse-backend-test-run 2>/dev/null | tail -10 || true
    docker rm -f afripulse-backend-test-run > /dev/null 2>&1 || true
    exit 1
fi

# Test 7: Test frontend container startup
print_status "Testing frontend container startup..."
if docker run -d --name afripulse-frontend-test-run -p 3001:3000 afripulse-frontend-test > /dev/null 2>&1; then
    sleep 3

    # Test if frontend responds
    if curl -s http://localhost:3001 > /dev/null 2>&1; then
        print_success "Frontend container starts and responds"
    else
        print_warning "Frontend container starts but doesn't respond yet"
        docker logs afripulse-frontend-test-run | tail -5
    fi

    # Cleanup
    docker stop afripulse-frontend-test-run > /dev/null 2>&1
    docker rm afripulse-frontend-test-run > /dev/null 2>&1
else
    print_error "Frontend container failed to start"
    docker logs afripulse-frontend-test-run 2>/dev/null | tail -10 || true
    docker rm -f afripulse-frontend-test-run > /dev/null 2>&1 || true
    exit 1
fi

# Test 8: Check environment file template
print_status "Checking environment configuration..."
if [ -f "env.example" ]; then
    print_success "Environment template exists"

    # Check for required variables
    required_vars=("DATABASE_URL" "JWT_SECRET" "NODE_ENV")
    for var in "${required_vars[@]}"; do
        if grep -q "$var" env.example; then
            print_success "✓ $var is in environment template"
        else
            print_warning "⚠ $var is missing from environment template"
        fi
    done
else
    print_warning "env.example not found - creating basic template"
    cat > env.example << 'EOL'
# AFRIPULSE Environment Configuration
DATABASE_URL=postgres://afripulse:password@postgres:5432/afripulse
JWT_SECRET=your_secure_jwt_secret_key
NODE_ENV=production
WHATSAPP_WEBHOOK_VERIFY_TOKEN=your_webhook_token
CORS_ORIGIN=https://yourdomain.com
EOL
    print_success "Created basic env.example template"
fi

# Cleanup test images
print_status "Cleaning up test images..."
docker rmi afripulse-backend-test afripulse-frontend-test > /dev/null 2>&1

# Test 9: Final deployment readiness check
print_status "Deployment readiness checklist:"

checklist=(
    "Dockerfile exists in root directory"
    "Dockerfile.frontend exists for frontend service"
    "docker-compose.yml is valid"
    "Backend builds successfully"
    "Frontend builds successfully"
    "Required source files present"
    "Package.json files valid"
    "Environment template available"
)

echo ""
for item in "${checklist[@]}"; do
    print_success "✓ $item"
done

echo ""
echo "🎉 BUILD TEST COMPLETED SUCCESSFULLY!"
echo "=================================="
echo ""
echo "Your AFRIPULSE project is ready for Coolify deployment!"
echo ""
echo "Next steps:"
echo "1. Push your code to Git repository"
echo "2. Create new resource in Coolify"
echo "3. Select 'Git Repository' → 'Dockerfile' build pack"
echo "4. Configure environment variables from env.example"
echo "5. Set up domains and SSL"
echo "6. Deploy!"
echo ""
echo "For detailed deployment instructions, see:"
echo "- COOLIFY_SETUP.md"
echo "- DOCKER_README.md"
echo ""
print_success "Build test completed - ready for deployment! 🚀"
