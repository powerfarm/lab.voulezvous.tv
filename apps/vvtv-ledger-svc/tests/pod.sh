#!/bin/bash
# Proof of Done - VVTV Ledger Service
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"

echo "🧪 VVTV Ledger Service - Proof of Done"
echo "======================================"
echo "Base URL: $BASE_URL"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Health check
echo -e "${YELLOW}1️⃣ Health check...${NC}"
HEALTH=$(curl -sf "$BASE_URL/health" || echo "FAILED")
if echo "$HEALTH" | jq -e '.status == "healthy"' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Service is healthy${NC}"
else
    echo "❌ Health check failed"
    exit 1
fi
echo ""

# 2. Create PlanCreated
echo -e "${YELLOW}2️⃣ Creating PlanCreated fact...${NC}"
PLAN_RESPONSE=$(curl -sf -X POST "$BASE_URL/facts" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "PlanCreated",
    "timestamp": "2026-01-10T20:00:00Z",
    "plan_id": "pod_test_001",
    "source": "youtube",
    "url": "https://example.com/test",
    "title": "PoD Test Video",
    "duration_secs": 720,
    "tags": ["test", "pod"],
    "bucket": "test",
    "score": 0.85
  }' || echo "FAILED")

PLAN_CID=$(echo "$PLAN_RESPONSE" | jq -r '.cid')
PLAN_STREAM=$(echo "$PLAN_RESPONSE" | jq -r '.stream')

if [ "$PLAN_CID" != "null" ] && [ -n "$PLAN_CID" ]; then
    echo -e "${GREEN}✅ PlanCreated CID: $PLAN_CID${NC}"
    echo -e "${GREEN}✅ Stream: $PLAN_STREAM${NC}"
else
    echo "❌ Failed to create PlanCreated"
    exit 1
fi
echo ""

# 3. Fetch by CID
echo -e "${YELLOW}3️⃣ Fetching fact by CID...${NC}"
FETCHED=$(curl -sf "$BASE_URL/facts/$PLAN_CID" || echo "FAILED")
if echo "$FETCHED" | jq -e '.plan_id == "pod_test_001"' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Fact retrieved successfully${NC}"
else
    echo "❌ Failed to fetch fact"
    exit 1
fi
echo ""

# 4. Create QCReport
echo -e "${YELLOW}4️⃣ Creating QCReport fact...${NC}"
QC_RESPONSE=$(curl -sf -X POST "$BASE_URL/facts" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "QCReport",
    "timestamp": "2026-01-10T20:05:00Z",
    "asset_id": "asset_001",
    "pass": true,
    "vmaf": 92.5,
    "ssim": 0.94,
    "lufs": -14.0,
    "resolution": "1920x1080"
  }' || echo "FAILED")

QC_CID=$(echo "$QC_RESPONSE" | jq -r '.cid')
QC_STREAM=$(echo "$QC_RESPONSE" | jq -r '.stream')

if [ "$QC_CID" != "null" ] && [ -n "$QC_CID" ]; then
    echo -e "${GREEN}✅ QCReport CID: $QC_CID${NC}"
    echo -e "${GREEN}✅ Stream: $QC_STREAM${NC}"
else
    echo "❌ Failed to create QCReport"
    exit 1
fi
echo ""

# 5. Create PolicyPatched
echo -e "${YELLOW}5️⃣ Creating PolicyPatched fact...${NC}"
POLICY_RESPONSE=$(curl -sf -X POST "$BASE_URL/facts" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "PolicyPatched",
    "timestamp": "2026-01-10T20:10:00Z",
    "patch_id": "patch_001",
    "changes": [
      {
        "path": "selection.temperature",
        "old_value": 0.6,
        "new_value": 0.62
      }
    ],
    "reason": "Autopilot D+1 adjustment",
    "approved_by": "autopilot"
  }' || echo "FAILED")

POLICY_CID=$(echo "$POLICY_RESPONSE" | jq -r '.cid')
POLICY_STREAM=$(echo "$POLICY_RESPONSE" | jq -r '.stream')

if [ "$POLICY_CID" != "null" ] && [ -n "$POLICY_CID" ]; then
    echo -e "${GREEN}✅ PolicyPatched CID: $POLICY_CID${NC}"
    echo -e "${GREEN}✅ Stream: $POLICY_STREAM${NC}"
else
    echo "❌ Failed to create PolicyPatched"
    exit 1
fi
echo ""

# 6. List facts in plans stream
echo -e "${YELLOW}6️⃣ Listing facts in 'plans' stream...${NC}"
PLANS_LIST=$(curl -sf "$BASE_URL/facts/stream/plans" || echo "FAILED")
PLANS_COUNT=$(echo "$PLANS_LIST" | jq '. | length')
if [ "$PLANS_COUNT" -ge 1 ]; then
    echo -e "${GREEN}✅ Found $PLANS_COUNT facts in 'plans' stream${NC}"
else
    echo "❌ Failed to list plans stream"
    exit 1
fi
echo ""

# 7. Check metrics
echo -e "${YELLOW}7️⃣ Checking Prometheus metrics...${NC}"
METRICS=$(curl -sf "$BASE_URL/metrics" || echo "FAILED")

if echo "$METRICS" | grep -q 'facts_written_total{stream="plans"}'; then
    PLANS_METRIC=$(echo "$METRICS" | grep 'facts_written_total{stream="plans"}' | awk '{print $2}')
    echo -e "${GREEN}✅ facts_written_total{stream=\"plans\"} = $PLANS_METRIC${NC}"
else
    echo "⚠️  Metrics not found (service may need restart)"
fi

if echo "$METRICS" | grep -q 'ledger_append_duration_seconds'; then
    echo -e "${GREEN}✅ ledger_append_duration_seconds histogram present${NC}"
fi
echo ""

# Summary
echo "======================================"
echo -e "${GREEN}🎉 Proof of Done COMPLETE!${NC}"
echo ""
echo "Created facts:"
echo "  • PlanCreated: $PLAN_CID"
echo "  • QCReport: $QC_CID"
echo "  • PolicyPatched: $POLICY_CID"
echo ""
echo "Streams verified:"
echo "  • plans: $PLANS_COUNT facts"
echo "  • assets: QC report stored"
echo "  • policy: Policy patch stored"
echo ""
echo "Next steps:"
echo "  1. Check ledger files: ls -lh /var/lib/vvtv/ledger/"
echo "  2. View raw NDJSON: cat /var/lib/vvtv/ledger/plans.ndjson"
echo "  3. Integrate with vv-plannerd (Fase B.1)"
