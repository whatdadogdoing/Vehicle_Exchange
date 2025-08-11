#!/bin/bash

# ==================== SMOKE TESTS SCRIPT ====================
# Usage: ./smoke-tests.sh [staging|production]

set -e

ENVIRONMENT=${1:-staging}
BASE_URL=""

case $ENVIRONMENT in
  staging)
    BASE_URL="https://staging-api.item-exchange.com"
    ;;
  production)
    BASE_URL="https://api.item-exchange.com"
    ;;
  *)
    echo "Usage: $0 [staging|production]"
    exit 1
    ;;
esac

echo "🧪 Running smoke tests for $ENVIRONMENT environment..."
echo "🌐 Base URL: $BASE_URL"

# ==================== HEALTH CHECK ====================
echo "1. Testing health endpoint..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/health")
if [ "$response" != "200" ]; then
  echo "❌ Health check failed. HTTP status: $response"
  exit 1
fi
echo "✅ Health check passed"

# ==================== API ENDPOINTS ====================
echo "2. Testing API endpoints..."

# Test items endpoint
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/items")
if [ "$response" != "200" ]; then
  echo "❌ Items endpoint failed. HTTP status: $response"
  exit 1
fi
echo "✅ Items endpoint working"

# Test user registration (should return validation error)
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/register" \
  -H "Content-Type: application/json" \
  -d '{}')
if [ "$response" != "400" ]; then
  echo "❌ Register endpoint validation failed. HTTP status: $response"
  exit 1
fi
echo "✅ Register endpoint validation working"

# ==================== DATABASE CONNECTION ====================
echo "3. Testing database connectivity..."
response=$(curl -s "$BASE_URL/api/items?page=1&per_page=1")
if ! echo "$response" | grep -q "items"; then
  echo "❌ Database connection test failed"
  exit 1
fi
echo "✅ Database connection working"

# ==================== PERFORMANCE TEST ====================
echo "4. Testing response times..."
start_time=$(date +%s%N)
curl -s "$BASE_URL/api/items" > /dev/null
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))

if [ "$duration" -gt 2000 ]; then
  echo "⚠️  Response time is slow: ${duration}ms"
else
  echo "✅ Response time acceptable: ${duration}ms"
fi

# ==================== SSL CERTIFICATE CHECK ====================
if [[ $BASE_URL == https* ]]; then
  echo "5. Testing SSL certificate..."
  ssl_check=$(curl -s -I "$BASE_URL" | head -n 1)
  if [[ $ssl_check == *"200"* ]]; then
    echo "✅ SSL certificate valid"
  else
    echo "❌ SSL certificate issue"
    exit 1
  fi
fi

echo "🎉 All smoke tests passed for $ENVIRONMENT!"

# ==================== SLACK NOTIFICATION ====================
if [ -n "$SLACK_WEBHOOK_URL" ]; then
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"✅ Smoke tests passed for $ENVIRONMENT environment\"}" \
    "$SLACK_WEBHOOK_URL"
fi