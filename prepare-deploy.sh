#!/bin/bash

# AFRIPULSE Deployment Preparation Script
# This script prepares the project for Coolify deployment by fixing common issues

set -e

echo "🚀 AFRIPULSE Deployment Preparation Script"
echo "========================================="
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

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ] || [ ! -d "deliverables" ]; then
    print_error "Please run this script from the AFRIPULSE project root directory"
    exit 1
fi

print_success "Found project root directory"

# Step 1: Fix package-lock.json issue
print_status "Step 1: Ensuring package-lock.json exists..."
SERVER_DIR="deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server"

if [ ! -f "$SERVER_DIR/package-lock.json" ]; then
    print_warning "package-lock.json not found. Generating..."

    if command -v npm &> /dev/null; then
        cd "$SERVER_DIR"
        npm install --package-lock-only
        cd - > /dev/null
        print_success "Generated package-lock.json"
    else
        print_warning "npm not found. Creating minimal package-lock.json"
        cat > "$SERVER_DIR/package-lock.json" << 'EOF'
{
  "name": "afripulse-server",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "afripulse-server",
      "version": "1.0.0",
      "dependencies": {
        "cors": "^2.8.5",
        "dotenv": "^16.4.5",
        "express": "^4.19.2",
        "helmet": "^7.1.0",
        "morgan": "^1.10.0",
        "pg": "^8.12.0",
        "zod": "^3.23.8"
      }
    }
  }
}
EOF
        print_success "Created minimal package-lock.json"
    fi
else
    print_success "package-lock.json already exists"
fi

# Step 2: Create optimized Dockerfile
print_status "Step 2: Creating optimized Dockerfile..."
cat > Dockerfile << 'EOF'
# AFRIPULSE Backend API Server - Optimized for Coolify
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++ curl

# Copy package files
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json ./
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package-lock.json* ./

# Install dependencies based on available files
RUN if [ -f package-lock.json ]; then \
        echo "Using npm ci with package-lock.json" && \
        npm ci --only=production; \
    else \
        echo "Using npm install (no package-lock.json found)" && \
        npm install --only=production; \
    fi && \
    npm cache clean --force

# Copy source code
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/ ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (res) => { \
        process.exit(res.statusCode === 200 ? 0 : 1) \
    }).on('error', () => process.exit(1))" || exit 1

# Start application
CMD ["npm", "start"]
EOF

print_success "Created optimized Dockerfile"

# Step 3: Create .dockerignore
print_status "Step 3: Creating .dockerignore for faster builds..."
cat > .dockerignore << 'EOF'
# Node.js
node_modules
npm-debug.log*
yarn-debug.log*
.npm

# Version control
.git
.gitignore

# Environment files
.env*

# Documentation
*.md
!README.md

# IDE files
.vscode/
.idea/
*.swp

# OS files
.DS_Store
Thumbs.db

# Logs
logs
*.log

# Temporary files
tmp/
temp/

# Test files
test/
tests/
*.test.js
*.spec.js

# Build artifacts
build/
dist/

# Development scripts
docker-start.*
test-build.*
prepare-deploy.sh

# Deployment configs
nginx/
ssl/
monitoring/
EOF

print_success "Created .dockerignore"

# Step 4: Create environment template for Coolify
print_status "Step 4: Creating environment template..."
cat > env.coolify << 'EOF'
# AFRIPULSE Environment Variables for Coolify
# Copy these to your Coolify environment configuration

# Core Application Settings
NODE_ENV=production
PORT=8080

# Database Configuration
POSTGRES_PASSWORD=REPLACE_WITH_SECURE_PASSWORD
DATABASE_URL=postgres://afripulse:REPLACE_WITH_SECURE_PASSWORD@YOUR_DB_HOST:5432/afripulse

# Security Settings
JWT_SECRET=REPLACE_WITH_SECURE_JWT_SECRET_32_CHARS_MIN
WHATSAPP_WEBHOOK_VERIFY_TOKEN=REPLACE_WITH_WEBHOOK_TOKEN

# CORS Configuration (replace with your actual domains)
CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com

# WhatsApp Integration (Optional - configure when ready)
WHATSAPP_PROVIDER=twilio
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+1234567890

# AI Integration (Optional)
OPENAI_API_KEY=your_openai_api_key

# Frontend URLs (for API injection)
BACKEND_URL=https://api.yourdomain.com
BACKEND_PUBLIC_URL=https://api.yourdomain.com

# How to generate secure secrets:
# JWT_SECRET: openssl rand -base64 32
# POSTGRES_PASSWORD: openssl rand -base64 24
# WHATSAPP_WEBHOOK_VERIFY_TOKEN: openssl rand -base64 16
EOF

print_success "Created env.coolify template"

# Step 5: Create deployment checklist
print_status "Step 5: Creating deployment checklist..."
cat > DEPLOYMENT_CHECKLIST.md << 'EOF'
# AFRIPULSE Coolify Deployment Checklist

## Pre-Deployment
- [ ] Run `./prepare-deploy.sh` to fix common issues
- [ ] Commit and push all changes to Git repository
- [ ] Ensure Docker builds locally: `docker build -t afripulse-test .`

## Coolify Setup
- [ ] Create new resource in Coolify
- [ ] Select "Git Repository" → "Dockerfile" build pack
- [ ] Set repository URL and branch (usually `main`)

## Environment Variables
Copy from `env.coolify` and update:
- [ ] Set strong `POSTGRES_PASSWORD`
- [ ] Set secure `JWT_SECRET` (32+ characters)
- [ ] Set unique `WHATSAPP_WEBHOOK_VERIFY_TOKEN`
- [ ] Update `CORS_ORIGIN` with your domains
- [ ] Configure `DATABASE_URL` with your database details

## Domain Configuration
- [ ] Backend API: `api.yourdomain.com` → Port `8080`
- [ ] Enable SSL for API domain
- [ ] Test DNS resolution

## Post-Deployment Verification
- [ ] Health check: `https://api.yourdomain.com/health`
- [ ] Media API: `https://api.yourdomain.com/public/media-shares?country=NG&category=ALL`
- [ ] Check Coolify logs for errors
- [ ] Verify database connection in logs

## Troubleshooting
- 502 Bad Gateway: Check container logs in Coolify
- Database errors: Verify DATABASE_URL format
- Build failures: Check package-lock.json exists
- CORS errors: Update CORS_ORIGIN environment variable

## Security Reminders
- Use strong, unique passwords
- Never commit secrets to Git
- Enable HTTPS only
- Regular security updates
EOF

print_success "Created deployment checklist"

# Step 6: Validate Docker build locally
print_status "Step 6: Testing Docker build locally..."
if command -v docker &> /dev/null; then
    if docker build -t afripulse-deploy-test . > build.log 2>&1; then
        print_success "Docker build successful!"
        docker rmi afripulse-deploy-test > /dev/null 2>&1
    else
        print_error "Docker build failed. Check build.log for details:"
        tail -20 build.log
        exit 1
    fi
else
    print_warning "Docker not found - skipping build test"
fi

# Step 7: Final validation
print_status "Step 7: Final validation..."

# Check required files
required_files=(
    "Dockerfile"
    ".dockerignore"
    "docker-compose.yml"
    "deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json"
    "deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package-lock.json"
    "deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/src/index.js"
    "deliverables/AFRIPULSE_FINAL_WEBSITE_v1/server.js"
    "deliverables/AFRIPULSE_FINAL_WEBSITE_v1/index.html"
    "deliverables/AFRIPULSE_FINAL_WEBSITE_v1/dashboard.html"
)

all_good=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file"
    else
        print_error "✗ Missing: $file"
        all_good=false
    fi
done

# Cleanup
rm -f build.log 2>/dev/null || true

echo ""
if [ "$all_good" = true ]; then
    echo "🎉 DEPLOYMENT PREPARATION COMPLETED!"
    echo "=================================="
    echo ""
    echo "Your AFRIPULSE project is ready for Coolify deployment!"
    echo ""
    echo "Next steps:"
    echo "1. Commit and push changes to Git:"
    echo "   git add ."
    echo "   git commit -m 'Prepare for Coolify deployment'"
    echo "   git push origin main"
    echo ""
    echo "2. In Coolify:"
    echo "   - Create new resource → Git Repository"
    echo "   - Build pack: Dockerfile"
    echo "   - Copy environment variables from env.coolify"
    echo "   - Set domain: api.yourdomain.com → port 8080"
    echo ""
    echo "3. Follow DEPLOYMENT_CHECKLIST.md for detailed steps"
    echo ""
    print_success "Ready for deployment! 🚀"
else
    print_error "Some files are missing. Please fix the issues above."
    exit 1
fi
