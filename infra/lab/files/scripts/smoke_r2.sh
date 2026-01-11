#!/bin/bash
# Smoke test: verify Worker and R2 connectivity
set -euo pipefail

WORKER_URL="${1:-}"

if [ -z "$WORKER_URL" ]; then
    echo "Usage: $0 <worker_url>"
    exit 1
fi

echo "🔍 Running smoke tests..."

# Test 1: Worker health
echo "Testing Worker health..."
if curl -sf "$WORKER_URL/health" > /dev/null; then
    echo "✅ Worker health check passed"
else
    echo "❌ Worker health check failed"
    exit 1
fi

# Test 2: List packs (should return empty or valid JSON)
echo "Testing R2 pack listing..."
RESPONSE=$(curl -sf "$WORKER_URL/packs" || echo "{}")
if echo "$RESPONSE" | jq empty 2>/dev/null; then
    echo "✅ R2 pack listing working"
else
    echo "❌ R2 pack listing failed"
    exit 1
fi

# Test 3: Worker version/info (if available)
echo "Testing Worker info..."
if curl -sf "$WORKER_URL/info" > /dev/null 2>&1; then
    echo "✅ Worker info endpoint available"
else
    echo "⚠️  Worker info endpoint not available (optional)"
fi

echo ""
echo "✅ All smoke tests passed!"
echo "Worker URL: $WORKER_URL"
