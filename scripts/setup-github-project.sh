#!/usr/bin/env bash
set -euo pipefail

# Setup GitHub Mission Control Project
# This script guides you through the setup process

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 GitHub Mission Control Setup"
echo "================================"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not found. Install with: brew install gh"
    exit 1
fi

# Check if logged in
if ! gh auth status &> /dev/null; then
    echo "❌ Not logged in to GitHub. Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI ready"
echo ""

# Step 1: Choose location
echo "📍 Step 1: Choose Project Location"
echo "-----------------------------------"
echo "Where do you want to create the Mission Control project?"
echo ""
echo "  1) User account (danvoulez) - Faster, simpler"
echo "  2) Organization (VoulezVous) - Centralized, team access"
echo ""
read -p "Choose [1/2]: " location_choice

if [[ "$location_choice" == "1" ]]; then
    OWNER="danvoulez"
    OWNER_TYPE="user"
elif [[ "$location_choice" == "2" ]]; then
    OWNER="VoulezVous"
    OWNER_TYPE="org"
else
    echo "❌ Invalid choice"
    exit 1
fi

echo "Selected: $OWNER ($OWNER_TYPE)"
echo ""

# Step 2: Create project (manual - gh CLI doesn't support projects v2 creation yet)
echo "📋 Step 2: Create Project (Manual)"
echo "----------------------------------"
echo "GitHub CLI doesn't support creating Projects v2 yet."
echo ""
echo "Please create manually:"
if [[ "$OWNER_TYPE" == "user" ]]; then
    echo "  1. Go to: https://github.com/users/$OWNER/projects"
else
    echo "  1. Go to: https://github.com/orgs/$OWNER/projects"
fi
echo "  2. Click: 'New project'"
echo "  3. Name: 'Mission Control'"
echo "  4. Description: 'Coordenação de Registry, voulezvous.tv e Rust Workspace'"
echo "  5. Template: 'Table'"
echo ""
read -p "Press ENTER when you've created the project..."
echo ""

# Step 3: Get project number
echo "🔢 Step 3: Find Project Number"
echo "-------------------------------"
echo "After creating the project, the URL will be:"
if [[ "$OWNER_TYPE" == "user" ]]; then
    echo "  https://github.com/users/$OWNER/projects/NUMBER"
else
    echo "  https://github.com/orgs/$OWNER/projects/NUMBER"
fi
echo ""
read -p "Enter the project NUMBER: " project_number

PROJECT_URL="https://github.com/$OWNER_TYPE/$OWNER/projects/$project_number"
echo "Project URL: $PROJECT_URL"
echo ""

# Step 4: Install GitHub App
echo "🤖 Step 4: Install GitHub App"
echo "------------------------------"
echo "The 'minicontratos' GitHub App needs to be installed."
echo ""
echo "Go to: https://github.com/apps/minicontratos"
echo "Click: 'Install' or 'Configure'"
echo "Select organization: $OWNER"
echo "Grant access to: 'All repositories' or select 'voulezvous.tv'"
echo ""
read -p "Press ENTER when the app is installed..."
echo ""

# Step 5: Configure secrets
echo "🔐 Step 5: Configure GitHub Secrets"
echo "------------------------------------"
echo "You need to add 2 secrets to the repository:"
echo ""
echo "  1. APP_GITHUB_ID = 1460425"
echo "  2. APP_GITHUB_PRIVATE_KEY = [PEM content from protected file]"
echo ""
echo "⚠️  Note: Secret names cannot start with GITHUB_"
echo ""
echo "Add them at:"
echo "  https://github.com/danvoulez/lab.voulezvous.tv/settings/secrets/actions"
echo ""
echo "See: .github/SECRETS.md for detailed instructions"
echo ""
read -p "Press ENTER when secrets are configured..."
echo ""

# Step 6: Update workflow
echo "📝 Step 6: Update Workflow"
echo "--------------------------"

WORKFLOW_FILE="$PROJECT_ROOT/.github/workflows/add-to-project.yml"

if [[ -f "$WORKFLOW_FILE" ]]; then
    # Update project URL in workflow
    if [[ "$OWNER_TYPE" == "user" ]]; then
        PROJECT_URL_IN_WORKFLOW="https://github.com/users/$OWNER/projects/$project_number"
    else
        PROJECT_URL_IN_WORKFLOW="https://github.com/orgs/$OWNER/projects/$project_number"
    fi
    
    # Use sed to update the project-url line
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed requires -i with empty string
        sed -i '' "s|project-url:.*|project-url: $PROJECT_URL_IN_WORKFLOW|" "$WORKFLOW_FILE"
    else
        sed -i "s|project-url:.*|project-url: $PROJECT_URL_IN_WORKFLOW|" "$WORKFLOW_FILE"
    fi
    
    echo "✅ Updated workflow with project URL"
else
    echo "⚠️  Workflow file not found: $WORKFLOW_FILE"
fi
echo ""

# Step 7: Test
echo "🧪 Step 7: Test the Setup"
echo "-------------------------"
echo "Create a test issue to verify everything works:"
echo ""
echo "  gh issue create \\"
echo "    --repo LogLine-Foundation/voulezvous.tv \\"
echo "    --title 'Test Mission Control' \\"
echo "    --body 'Testing auto-add workflow' \\"
echo "    --label 'mission-control'"
echo ""
read -p "Create test issue now? [y/N]: " create_test

if [[ "$create_test" == "y" || "$create_test" == "Y" ]]; then
    gh issue create \
        --repo danvoulez/lab.voulezvous.tv \
        --title "Test Mission Control" \
        --body "Testing auto-add workflow" \
        --label "mission-control"
    
    echo ""
    echo "✅ Test issue created!"
    echo "Check: https://github.com/danvoulez/lab.voulezvous.tv/actions"
    echo "Expected: Issue should appear in Mission Control project"
else
    echo "Skipped test issue creation"
fi
echo ""

# Summary
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "  1. Follow GITHUB_PROJECTS_SETUP.md to configure:"
echo "     - Custom fields (Workstream, Mode, Outcome, etc.)"
echo "     - Views (Hoje, Inbox, Board, Roadmap, Done)"
echo "     - Built-in automations"
echo "     - Auto-archive (14 days)"
echo ""
echo "  2. Create your first real task:"
echo "     - Use issue template: .github/ISSUE_TEMPLATE/mission-control.yml"
echo "     - Or create manually with label 'mission-control'"
echo ""
echo "  3. Start daily workflow:"
echo "     - Open 'Hoje' view"
echo "     - Mark 1-3 items as Mode:Active"
echo "     - Work, close issues, repeat!"
echo ""
echo "📚 Documentation:"
echo "  - Setup guide: GITHUB_PROJECTS_SETUP.md"
echo "  - Secrets: .github/SECRETS.md"
echo "  - Architecture: ADR-002-github-projects.md"
echo ""
