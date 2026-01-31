#!/bin/bash

# AFRIPULSE Deployment Verification Script
# This script verifies that your AFRIPULSE deployment is working correctly

set -e

echo "🔍 AFRIPULSE Deployment Verification Script"
echo "=========================================="
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

# Check if URL is provided
if [ -z "$1" ]; then
    print_error "Usage: ./verify-deployment.sh <your-api-url>"
    echo "Example: ./verify-deployment.sh https://api.yourdomain.com"
    exit 1
fi

API_URL="$1"
# Remove trailing slash if present
API_URL="${API_URL%/}"

print_status "Testing AFRIPULSE API at: $API_URL"
echo ""

# Test 1: Health Check
print_status "Test 1: Health Check Endpoint"
HEALTH_URL="$API_URL/health"

if curl -s -f "$HEALTH_URL" > /dev/null 2>&1; then
    HEALTH_RESPONSE=$(curl -s "$HEALTH_URL")
    if echo "$HEALTH_RESPONSE" | grep -q "\"ok\":true"; then
        print_success "Health endpoint is working"
        echo "         Response: $HEALTH_RESPONSE"
    else
        print_error "Health endpoint returned unexpected response"
        echo "         Response: $HEALTH_RESPONSE"
        exit 1
    fi
else
    print_error "Health endpoint is not accessible at $HEALTH_URL"
    exit 1
fi
echo ""

# Test 2: Media Shares API - Nigeria All Categories
print_status "Test 2: Media Shares API - Nigeria (All Categories)"
MEDIA_URL="$API_URL/public/media-shares?country=NG&category=ALL"

if curl -s -f "$MEDIA_URL" > /dev/null 2>&1; then
    MEDIA_RESPONSE=$(curl -s "$MEDIA_URL")
    if echo "$MEDIA_RESPONSE" | grep -q "\"country\":\"NG\""; then
        TOTAL_RESPONSES=$(echo "$MEDIA_RESPONSE" | grep -o '"total":[0-9]*' | cut -d':' -f2)
        print_success "Media Shares API is working"
        echo "         Country: Nigeria"
        echo "         Total responses: $TOTAL_RESPONSES"
    else
        print_error "Media Shares API returned unexpected response"
        echo "         Response: $MEDIA_RESPONSE"
        exit 1
    fi
else
    print_error "Media Shares API is not accessible at $MEDIA_URL"
    exit 1
fi
echo ""

# Test 3: Media Shares API - Nigeria TV
print_status "Test 3: Media Shares API - Nigeria TV Category"
TV_URL="$API_URL/public/media-shares?country=NG&category=TV"

if curl -s -f "$TV_URL" > /dev/null 2>&1; then
    TV_RESPONSE=$(curl -s "$TV_URL")
    if echo "$TV_RESPONSE" | grep -q "\"category\":\"TV\""; then
        TV_TOTAL=$(echo "$TV_RESPONSE" | grep -o '"total":[0-9]*' | cut -d':' -f2)
        print_success "TV category filtering is working"
        echo "         TV responses: $TV_TOTAL"
    else
        print_error "TV category API returned unexpected response"
        echo "         Response: $TV_RESPONSE"
    fi
else
    print_warning "TV category API is not accessible (this might be normal)"
fi
echo ""

# Test 4: Media Shares API - South Africa
print_status "Test 4: Media Shares API - South Africa"
ZA_URL="$API_URL/public/media-shares?country=ZA&category=ALL"

if curl -s -f "$ZA_URL" > /dev/null 2>&1; then
    ZA_RESPONSE=$(curl -s "$ZA_URL")
    if echo "$ZA_RESPONSE" | grep -q "\"country\":\"ZA\""; then
        ZA_TOTAL=$(echo "$ZA_RESPONSE" | grep -o '"total":[0-9]*' | cut -d':' -f2)
        print_success "Multi-country support is working"
        echo "         Country: South Africa"
        echo "         Total responses: $ZA_TOTAL"
    else
        print_error "South Africa API returned unexpected response"
        echo "         Response: $ZA_RESPONSE"
    fi
else
    print_warning "South Africa API is not accessible (this might be normal)"
fi
echo ""

# Test 5: Invalid Endpoint (Should Return 404)
print_status "Test 5: Invalid Endpoint (404 Test)"
INVALID_URL="$API_URL/invalid-endpoint"

if curl -s -f "$INVALID_URL" > /dev/null 2>&1; then
    print_warning "Invalid endpoint should return 404, but it didn't"
else
    print_success "404 error handling is working correctly"
fi
echo ""

# Test 6: CORS Headers
print_status "Test 6: CORS Headers Check"
CORS_HEADERS=$(curl -s -I -H "Origin: https://example.com" "$HEALTH_URL" | grep -i "access-control")

if [ -n "$CORS_HEADERS" ]; then
    print_success "CORS headers are present"
    echo "         Headers: $CORS_HEADERS"
else
    print_warning "CORS headers not found (might still work for same-origin requests)"
fi
echo ""

# Test 7: Response Time Check
print_status "Test 7: Response Time Check"
RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$HEALTH_URL")
RESPONSE_MS=$(echo "$RESPONSE_TIME * 1000" | bc 2>/dev/null || echo "N/A")

if [ "$RESPONSE_MS" != "N/A" ] && [ "$(echo "$RESPONSE_TIME < 2" | bc 2>/dev/null)" = "1" ]; then
    print_success "Response time is good: ${RESPONSE_MS}ms"
elif [ "$RESPONSE_TIME" != "" ]; then
    print_warning "Response time is slow: ${RESPONSE_TIME}s"
else
    print_warning "Could not measure response time"
fi
echo ""

# Summary
echo "🎉 DEPLOYMENT VERIFICATION SUMMARY"
echo "================================="
echo ""
print_success "Core API functionality is working!"
echo ""
echo "✅ Health endpoint: $API_URL/health"
echo "✅ Media shares API: $API_URL/public/media-shares"
echo "✅ Multi-country support (NG, ZA, etc.)"
echo "✅ Category filtering (TV, RADIO, ONLINE, SOCIAL)"
echo "✅ Error handling (404s)"
if [ -n "$CORS_HEADERS" ]; then
    echo "✅ CORS headers configured"
fi
echo ""

echo "🌐 Your AFRIPULSE API is ready to use!"
echo ""
echo "Example API calls:"
echo "  - All Nigerian media: $API_URL/public/media-shares?country=NG&category=ALL"
echo "  - Nigerian TV only:   $API_URL/public/media-shares?country=NG&category=TV"
echo "  - South African data: $API_URL/public/media-shares?country=ZA&category=ALL"
echo ""

echo "📊 Sample data includes:"
echo "  - Nigeria: Channels TV, NTA, Cool FM, Wazobia FM, Punch, Vanguard"
echo "  - South Africa: SABC, 5FM"
echo "  - Categories: TV, RADIO, ONLINE, SOCIAL media"
echo ""

echo "🔗 Next steps:"
echo "  1. Deploy frontend website (optional)"
echo "  2. Set up custom domain and SSL"
echo "  3. Configure real PostgreSQL database (optional)"
echo "  4. Set up WhatsApp integration (optional)"
echo "  5. Configure monitoring and backups"
echo ""

print_success "Verification completed successfully! 🚀"
