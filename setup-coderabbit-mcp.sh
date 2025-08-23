#!/bin/bash
# CodeRabbit MCP Server Setup Script for TouchBarFix
# This script sets up the complete CodeRabbit integration with Claude Code

set -e  # Exit on error

echo "🤖 Setting up CodeRabbit MCP Integration for TouchBarFix"
echo "========================================================="

# Color codes for output
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

# Check prerequisites
print_status "Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi
print_success "Node.js $(node -v) found"

# Check npm/npx
if ! command -v npx &> /dev/null; then
    print_error "npx is not installed. Please install npm/npx."
    exit 1
fi
print_success "npx $(npx --version) found"

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    print_warning "GitHub CLI not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install gh
        print_success "GitHub CLI installed"
    else
        print_error "Homebrew not found. Please install GitHub CLI manually: https://cli.github.com"
        exit 1
    fi
else
    print_success "GitHub CLI $(gh --version | head -1) found"
fi

# Setup GitHub authentication
print_status "Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    print_warning "GitHub CLI not authenticated. Please authenticate:"
    gh auth login
else
    print_success "GitHub CLI authenticated"
fi

# Get GitHub token
print_status "Retrieving GitHub token..."
GITHUB_TOKEN=$(gh auth token)
if [ -z "$GITHUB_TOKEN" ]; then
    print_error "Failed to retrieve GitHub token"
    exit 1
fi
print_success "GitHub token retrieved"

# Create MCP configuration directory
MCP_CONFIG_DIR="$HOME/.config/mcp"
print_status "Creating MCP configuration directory..."
mkdir -p "$MCP_CONFIG_DIR"
print_success "Configuration directory created: $MCP_CONFIG_DIR"

# Install CodeRabbit MCP server globally
print_status "Installing CodeRabbit MCP server (bradthebeeble/coderabbitai-mcp)..."
npm install -g coderabbitai-mcp@latest
print_success "CodeRabbit MCP server installed globally"

# Create environment file for tokens
ENV_FILE="$MCP_CONFIG_DIR/.env"
print_status "Creating environment configuration..."
cat > "$ENV_FILE" << EOF
# CodeRabbit MCP Server Configuration
# Generated on $(date)

# GitHub Personal Access Token (automatically retrieved from gh CLI)
GITHUB_TOKEN=$GITHUB_TOKEN

# CodeRabbit API Key (optional - for advanced features)
# Get your API key from: https://app.coderabbit.ai/settings/api
# CODERABBIT_API_KEY=your_api_key_here

# Default repository for TouchBarFix
DEFAULT_REPO=ProduktEntdecker/touchbarfix
EOF
print_success "Environment configuration created: $ENV_FILE"

# Create MCP server configuration for Claude Code
MCP_SERVER_CONFIG="$MCP_CONFIG_DIR/servers.json"
print_status "Creating MCP server configuration for Claude Code..."
cat > "$MCP_SERVER_CONFIG" << 'EOF'
{
  "coderabbit": {
    "command": "npx",
    "args": ["coderabbitai-mcp@latest"],
    "env": {
      "GITHUB_TOKEN": "${GITHUB_TOKEN}"
    },
    "description": "CodeRabbit AI code review integration for GitHub PRs"
  }
}
EOF
print_success "MCP server configuration created: $MCP_SERVER_CONFIG"

# Create helper script for manual testing
HELPER_SCRIPT="$HOME/bin/coderabbit-review"
mkdir -p "$HOME/bin"
print_status "Creating helper script..."
cat > "$HELPER_SCRIPT" << 'EOF'
#!/bin/bash
# CodeRabbit Review Helper Script

# Load environment variables
source ~/.config/mcp/.env

# Default to TouchBarFix repo if not specified
REPO=${1:-$DEFAULT_REPO}
PR_NUMBER=$2

if [ -z "$PR_NUMBER" ]; then
    echo "Usage: coderabbit-review [repo] <pr_number>"
    echo "Example: coderabbit-review 123"
    echo "Example: coderabbit-review owner/repo 456"
    exit 1
fi

echo "Fetching CodeRabbit review for PR #$PR_NUMBER in $REPO..."
npx coderabbitai-mcp@latest get-review --repo "$REPO" --pr "$PR_NUMBER"
EOF
chmod +x "$HELPER_SCRIPT"
print_success "Helper script created: $HELPER_SCRIPT"

# Create workflow documentation
WORKFLOW_DOC="/Users/floriansteiner/Documents/GitHub/touchbarfix/CODERABBIT-MCP-WORKFLOW.md"
print_status "Creating workflow documentation..."
cat > "$WORKFLOW_DOC" << 'EOF'
# CodeRabbit MCP Integration Workflow

## Setup Complete! 🎉

The CodeRabbit MCP server is now configured and ready to use with Claude Code.

## Configuration Files

- **Environment Variables**: `~/.config/mcp/.env`
- **MCP Server Config**: `~/.config/mcp/servers.json`
- **Helper Script**: `~/bin/coderabbit-review`

## How to Use with Claude Code

### 1. Automatic PR Review Workflow

When you create a PR with Claude Code, CodeRabbit will automatically review it:

```bash
# Claude Code creates a feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add -A
git commit -m "feat: add new feature"

# Push to GitHub
git push -u origin feature/new-feature

# Create PR using gh CLI
gh pr create --title "Add new feature" --body "Description"
```

### 2. Reading CodeRabbit Reviews in Claude Code

Claude Code can now access CodeRabbit reviews through the MCP server:

```bash
# Method 1: Using the MCP server directly
npx coderabbitai-mcp@latest get-review --repo ProduktEntdecker/touchbarfix --pr 123

# Method 2: Using the helper script
coderabbit-review 123  # For TouchBarFix repo
coderabbit-review owner/repo 456  # For other repos
```

### 3. Interactive Review Commands

Claude Code can send commands to CodeRabbit:

```bash
# Get all reviews for a PR
npx coderabbitai-mcp@latest get-coderabbit-reviews \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123

# Get detailed review information
npx coderabbitai-mcp@latest get-review-details \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123

# Get specific comments
npx coderabbitai-mcp@latest get-review-comments \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123

# Resolve a comment
npx coderabbitai-mcp@latest resolve-comment \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123 \
  --comment-id 456 \
  --resolution "addressed"
```

### 4. Automated Workflow with Claude Code

The complete automated workflow:

1. **Claude Code writes code** on a feature branch
2. **Creates a PR** using `gh pr create`
3. **CodeRabbit automatically reviews** the PR
4. **Claude Code reads the review** using MCP commands
5. **Fixes issues** based on feedback
6. **Marks comments as resolved** using MCP
7. **PR gets merged** when all issues are resolved

### 5. Testing the Integration

Test the integration with these commands:

```bash
# Check if MCP server is working
npx coderabbitai-mcp@latest --version

# Test GitHub authentication
gh auth status

# Test fetching a review (replace with actual PR number)
npx coderabbitai-mcp@latest get-review \
  --repo ProduktEntdecker/touchbarfix \
  --pr 1
```

## Troubleshooting

### Issue: MCP server timeout
**Solution**: The MCP server may take a moment to start. Wait a few seconds and retry.

### Issue: Authentication failed
**Solution**: Re-authenticate with GitHub:
```bash
gh auth refresh
gh auth token  # Should output a token
```

### Issue: CodeRabbit not reviewing PRs
**Solution**: Ensure CodeRabbit app is installed on the repository:
1. Visit: https://github.com/apps/coderabbit-ai
2. Install on your repository
3. Configure review settings in `.coderabbit.yaml`

### Issue: Cannot read PR comments
**Solution**: Use the MCP server commands listed above to fetch reviews programmatically.

## Advanced Features

### Custom Review Instructions

You can provide custom instructions when creating a PR:

```bash
gh pr create --title "Feature" --body "
Description of changes

@coderabbitai review with focus on:
- Security implications
- Performance optimization
- Code style consistency
"
```

### Batch Operations

Process multiple PRs:

```bash
# Review all open PRs
for pr in $(gh pr list --json number -q '.[].number'); do
  echo "Reviewing PR #$pr"
  npx coderabbitai-mcp@latest get-review \
    --repo ProduktEntdecker/touchbarfix \
    --pr "$pr"
done
```

## Next Steps

1. Create a test PR to verify the integration
2. Configure custom review rules in `.coderabbit.yaml`
3. Set up team review workflows
4. Integrate with CI/CD pipeline

## Support

- **CodeRabbit Documentation**: https://docs.coderabbit.ai
- **MCP Server Issues**: https://github.com/bradthebeeble/coderabbitai-mcp/issues
- **TouchBarFix Issues**: https://github.com/ProduktEntdecker/touchbarfix/issues
EOF'
print_success "Workflow documentation created: $WORKFLOW_DOC"

# Test the installation
print_status "Testing CodeRabbit MCP server installation..."
if npx coderabbitai-mcp@latest --version &> /dev/null; then
    print_success "CodeRabbit MCP server is working!"
else
    print_warning "Could not verify MCP server. It may still work when called with proper parameters."
fi

# Final summary
echo ""
echo "========================================================="
echo -e "${GREEN}✅ CodeRabbit MCP Integration Setup Complete!${NC}"
echo "========================================================="
echo ""
echo "📁 Configuration Files Created:"
echo "   - Environment: ~/.config/mcp/.env"
echo "   - MCP Config: ~/.config/mcp/servers.json"
echo "   - Helper Script: ~/bin/coderabbit-review"
echo "   - Documentation: ./CODERABBIT-MCP-WORKFLOW.md"
echo ""
echo "🚀 Quick Start:"
echo "   1. Create a PR: gh pr create --title 'Test' --body 'Test PR'"
echo "   2. Get review: npx coderabbitai-mcp@latest get-review --repo ProduktEntdecker/touchbarfix --pr <number>"
echo "   3. Or use helper: coderabbit-review <pr_number>"
echo ""
echo "📖 See CODERABBIT-MCP-WORKFLOW.md for detailed usage instructions"
echo ""
print_warning "Note: Make sure CodeRabbit app is installed on your GitHub repository"
print_warning "Visit: https://github.com/apps/coderabbit-ai to install"