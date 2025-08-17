#!/bin/bash

# TouchBarFix DevOps Setup Script
# Author: DevOps Team
# Date: August 17, 2024
# Purpose: Configure Git and repository for optimal development workflow

set -e

echo "🚀 TouchBarFix DevOps Setup Script"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Configure Git
echo "Step 1: Configuring Git..."
git config pull.rebase true
git config pull.ff only
git config push.default current
git config merge.ff false
print_status "Git configuration updated"

# Step 2: Set up Git aliases
echo ""
echo "Step 2: Setting up Git aliases..."
git config --global alias.sync '!git fetch --all --prune && git pull --rebase'
git config --global alias.publish '!git push origin HEAD'
git config --global alias.amend 'commit --amend --no-edit'
git config --global alias.undo 'reset --soft HEAD~1'
git config --global alias.cleanup '!git branch --merged | grep -v "\*\|main\|develop" | xargs -n 1 git branch -d'
print_status "Git aliases configured"

# Step 3: Clean up repository
echo ""
echo "Step 3: Cleaning up repository..."
if [ -f "CNAME" ] && [ -f "docs/CNAME" ]; then
    rm -f CNAME
    print_status "Removed duplicate CNAME file"
else
    print_status "No duplicate files found"
fi

# Step 4: Verify GitHub Actions
echo ""
echo "Step 4: Verifying GitHub Actions..."
if [ -d ".github/workflows" ]; then
    workflow_count=$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l)
    print_status "Found $workflow_count workflow files"
else
    print_warning "No GitHub Actions workflows found"
fi

# Step 5: Check current branch
echo ""
echo "Step 5: Checking branch status..."
current_branch=$(git branch --show-current)
echo "Current branch: $current_branch"

if [ "$current_branch" != "main" ]; then
    print_warning "You're not on the main branch"
    read -p "Switch to main branch? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout main
        git pull --rebase origin main
        print_status "Switched to main branch"
    fi
fi

# Step 6: Sync with remote
echo ""
echo "Step 6: Syncing with remote..."
git fetch --all --prune
git pull --rebase origin main || true
print_status "Repository synced"

# Step 7: Display status
echo ""
echo "Step 7: Repository Status"
echo "------------------------"
git status --short

# Step 8: Create recommended branches
echo ""
echo "Step 8: Branch Setup"
read -p "Create develop branch? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git checkout -b develop 2>/dev/null || git checkout develop
    git push -u origin develop 2>/dev/null || true
    git checkout main
    print_status "Develop branch ready"
fi

# Step 9: Display next steps
echo ""
echo "========================================="
echo "✅ DevOps Setup Complete!"
echo "========================================="
echo ""
echo "📋 Next Steps:"
echo "1. Review DEVOPS-SETUP.md for complete documentation"
echo "2. Configure branch protection rules on GitHub:"
echo "   - Go to Settings → Branches"
echo "   - Add rule for 'main' branch"
echo "   - Enable: Require pull request reviews"
echo "   - Enable: Require status checks"
echo ""
echo "🎯 Quick Commands:"
echo "  git sync     - Sync with remote"
echo "  git publish  - Push current branch"
echo "  git cleanup  - Remove merged branches"
echo "  git undo     - Undo last commit"
echo ""
echo "📚 Documentation: DEVOPS-SETUP.md"
echo ""
print_status "Setup script completed successfully!"