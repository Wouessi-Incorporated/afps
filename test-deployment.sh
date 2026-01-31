#!/bin/bash

# AFRIPULSE Deployment Test Script
# Quick test to verify the deployment is working correctly

echo "🧪 AFRIPULSE Deployment Test"
echo "============================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if URL provided
if [ -z "$1" ]; then
    print_error "Usage: ./test-deployment.sh <your-api-url>"
    echo "Example: ./test-deployment.sh https://api.yourdomain.com"
    exit 1
fi

API_URL="$1"
API_URL="${API_URL%/}"  # Remove trailing slash

print_info "Testing AFRIPULSE API at: $API_URL"
echo ""

# Test 1: Health Check
print_info "Test 1: Health Check"
echo "URL: $API_URL/health"

if command -v curl &> /dev/null; then
    HEALTH_RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" "$API_URL/health" 2>/dev/null)
    HTTP_STATUS=$(echo $HEALTH_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    BODY=$(echo $HEALTH_RESPONSE | sed -e 's/HTTPSTATUS:.*//g')

    if [ "$HTTP_STATUS" = "200" ]; then
        if echo "$BODY" | grep -q '"ok":true'; then
            print_success "Health endpoint working correctly"
            echo "Response: $BODY"
        else
            print_error "Health endpoint returned unexpected response"
            echo "Response: $BODY"
        fi
    else
        print_error "Health endpoint returned HTTP $HTTP_STATUS"
        echo "Response: $BODY"
    fi
else
    print_warning "curl not available - cannot test endpoints"
fi
echo ""

# Test 2: Media Shares API
print_info "Test 2: Media Shares API (Nigeria)"
echo "URL: $API_URL/public/media-shares?country=NG&category=ALL"

if command -v curl &> /dev/null; then
    MEDIA_RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" "$API_URL/public/media-shares?country=NG&category=ALL" 2>/dev/null)
    HTTP_STATUS=$(echo $MEDIA_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    BODY=$(echo $MEDIA_RESPONSE | sed -e 's/HTTPSTATUS:.*//g')

    if [ "$HTTP_STATUS" = "200" ]; then
        if echo "$BODY" | grep -q '"country":"NG"'; then
            TOTAL=$(echo "$BODY" | grep -o '"total":[0-9]*' | cut -d':' -f2)
            print_success "Media Shares API working correctly"
            echo "Country: Nigeria, Total responses: $TOTAL"
        else
            print_error "Media Shares API returned unexpected response"
            echo "Response: $BODY"
        fi
    else
        print_error "Media Shares API returned HTTP $HTTP_STATUS"
        echo "Response: $BODY"
    fi
fi
echo ""

# Test 3: TV Category Filter
print_info "Test 3: TV Category Filter"
echo "URL: $API_URL/public/media-shares?country=NG&category=TV"

if command -v curl &> /dev/null; then
    TV_RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" "$API_URL/public/media-shares?country=NG&category=TV" 2>/dev/null)
    HTTP_STATUS=$(echo $TV_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    BODY=$(echo $TV_RESPONSE | sed -e 's/HTTPSTATUS:.*//g')

    if [ "$HTTP_STATUS" = "200" ]; then
        if echo "$BODY" | grep -q '"category":"TV"'; then
            print_success "TV category filtering working"
        else
            print_warning "TV category filter may not be working correctly"
        fi
    else
        print_warning "TV category endpoint returned HTTP $HTTP_STATUS"
    fi
fi
echo ""

# Test 4: CORS Headers
print_info "Test 4: CORS Headers"

if command -v curl &> /dev/null; then
    CORS_HEADERS=$(curl -s -I -H "Origin: https://example.com" "$API_URL/health" 2>/dev/null | grep -i "access-control")

    if [ -n "$CORS_HEADERS" ]; then
        print_success "CORS headers present"
        echo "Headers found: $CORS_HEADERS"
    else
        print_warning "CORS headers not detected (may still work)"
    fi
fi
echo ""

# Summary
echo "📊 TEST SUMMARY"
echo "==============="
echo ""

if command -v curl &> /dev/null; then
    # Quick status check
    HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/health" 2>/dev/null)
    MEDIA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/public/media-shares?country=NG&category=ALL" 2>/dev/null)

    if [ "$HEALTH_STATUS" = "200" ] && [ "$MEDIA_STATUS" = "200" ]; then
        print_success "✅ AFRIPULSE API is working correctly!"
        echo ""
        echo "🌐 Your API endpoints:"
        echo "  • Health: $API_URL/health"
        echo "  • Nigerian media: $API_URL/public/media-shares?country=NG&category=ALL"
        echo "  • TV only: $API_URL/public/media-shares?country=NG&category=TV"
        echo "  • South Africa: $API_URL/public/media-shares?country=ZA&category=ALL"
        echo ""
        echo "📊 Available countries: NG, ZA, KE, EG, MA, CM, SN, CI"
        echo "📺 Available categories: ALL, TV, RADIO, ONLINE, SOCIAL"
        echo ""
        print_success "Deployment test PASSED! 🎉"
    else
        print_error "❌ Some endpoints are not working correctly"
        echo "Health status: $HEALTH_STATUS"
        echo "Media status: $MEDIA_STATUS"
        echo ""
        echo "🔧 Troubleshooting:"
        echo "  • Check Coolify logs for errors"
        echo "  • Verify domain DNS resolution"
        echo "  • Ensure SSL certificate is active"
        echo "  • Wait 1-2 minutes for container to fully start"
    fi
else
    print_warning "Cannot test endpoints without curl"
    echo ""
    echo "Manual test URLs:"
    echo "  • $API_URL/health"
    echo "  • $API_URL/public/media-shares?country=NG&category=ALL"
fi

echo ""
echo "🚀 AFRIPULSE deployment test completed!"
