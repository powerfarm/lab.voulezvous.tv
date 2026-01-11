#!/usr/bin/env bash
set -euo pipefail

APP_ID="1460425"
INSTALLATION_ID="99794544"
PRIVATE_KEY_PATH="/Users/ubl-ops/voulezvous.tv/minicontratos.2026-01-09.private-key.pem"

# Generate JWT
NOW=$(date +%s)
IAT=$((NOW - 60))
EXP=$((NOW + 600))

HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
PAYLOAD=$(echo -n "{\"iat\":$IAT,\"exp\":$EXP,\"iss\":\"$APP_ID\"}" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

SIGNATURE=$(echo -n "${HEADER}.${PAYLOAD}" | openssl dgst -sha256 -sign "$PRIVATE_KEY_PATH" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
JWT="${HEADER}.${PAYLOAD}.${SIGNATURE}"

echo "✅ Generated JWT"

# Get installation token
TOKEN_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens")

TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.token')

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get token"
  echo "$TOKEN_RESPONSE"
  exit 1
fi

echo "✅ Got installation token"

# List projects using GraphQL (Projects v2)
PROJECTS=$(curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/graphql" \
  -d '{
    "query": "query { user(login: \"danvoulez\") { id projectsV2(first: 20) { nodes { number title url } } } }"
  }')

echo ""
echo "📋 Existing projects:"
echo "$PROJECTS" | jq -r '.data.user.projectsV2.nodes[] | "\(.number): \(.title)"'

# Find Mission Control project
MC_NUMBER=$(echo "$PROJECTS" | jq -r '.data.user.projectsV2.nodes[] | select(.title=="Mission Control") | .number')

if [ -z "$MC_NUMBER" ] || [ "$MC_NUMBER" = "null" ]; then
  echo ""
  echo "🔨 Creating Mission Control project..."
  
  # Get user ID
  USER_ID=$(echo "$PROJECTS" | jq -r '.data.user.id')
  
  # Create project
  CREATE_RESULT=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/graphql" \
    -d "{
      \"query\": \"mutation { createProjectV2(input: {ownerId: \\\"$USER_ID\\\", title: \\\"Mission Control\\\"}) { projectV2 { number url } } }\"
    }")
  
  echo "$CREATE_RESULT" | jq '.'
  
  MC_NUMBER=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.number')
  MC_URL=$(echo "$CREATE_RESULT" | jq -r '.data.createProjectV2.projectV2.url')
  
  if [ -z "$MC_NUMBER" ] || [ "$MC_NUMBER" = "null" ]; then
    echo "❌ Failed to create project"
    exit 1
  fi
  
  echo "✅ Created Mission Control project #$MC_NUMBER"
else
  MC_URL=$(echo "$PROJECTS" | jq -r '.data.user.projectsV2.nodes[] | select(.title=="Mission Control") | .url')
  echo "✅ Found existing Mission Control project #$MC_NUMBER"
fi

# Update workflow
WORKFLOW_FILE="/Users/ubl-ops/voulezvous.tv/.github/workflows/add-to-project.yml"
sed -i '' "s|project-url:.*|project-url: https://github.com/users/danvoulez/projects/$MC_NUMBER|" "$WORKFLOW_FILE"

echo "✅ Updated workflow with project URL"
echo ""
echo "🎉 Setup complete!"
echo ""
echo "Test it:"
echo "  gh issue create --title 'Test Mission Control' --body 'Testing' --label 'mission-control'"
