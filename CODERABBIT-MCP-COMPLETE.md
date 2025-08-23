# Complete CodeRabbit MCP Integration Guide

## Installation Status ✅

The CodeRabbit MCP server is now installed and configured.

## Required: Add Your GitHub Token

Before you can use the integration, you need to add your GitHub token:

### Step 1: Create a GitHub Personal Access Token

1. Visit: https://github.com/settings/tokens/new
2. Give it a name: "CodeRabbit MCP Integration"
3. Select these scopes:
   - `repo` (Full control of private repositories)
   - `read:org` (Read org and team membership)
   - `read:user` (Read user profile data)
4. Click "Generate token"
5. **IMPORTANT**: Copy the token immediately (you won't see it again!)

### Step 2: Configure the Token

```bash
# Copy the template
cp ~/.config/mcp/.env.template ~/.config/mcp/.env

# Edit the file and add your token
nano ~/.config/mcp/.env
# Or use your preferred editor
```

Replace `YOUR_GITHUB_TOKEN_HERE` with your actual token.

### Step 3: Verify the Setup

```bash
# Export the token for current session
export GITHUB_TOKEN="your-token-here"

# Test the integration
npx coderabbitai-mcp@latest get-coderabbit-reviews \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 1
```

## Using CodeRabbit MCP with Claude Code

### Available MCP Commands

All commands use the format: `npx coderabbitai-mcp@latest [command] [options]`

#### 1. Get All Reviews for a PR
```bash
npx coderabbitai-mcp@latest get-coderabbit-reviews \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123
```

#### 2. Get Detailed Review Information
```bash
npx coderabbitai-mcp@latest get-review-details \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123
```

#### 3. Get Review Comments
```bash
npx coderabbitai-mcp@latest get-review-comments \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123
```

#### 4. Get Specific Comment Details
```bash
npx coderabbitai-mcp@latest get-comment-details \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123 \
  --comment-id 456789
```

#### 5. Resolve a Comment
```bash
npx coderabbitai-mcp@latest resolve-comment \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr 123 \
  --comment-id 456789 \
  --resolution "addressed"  # or "won't fix" or "not applicable"
```

## Complete Automated Workflow

Here's how Claude Code can work with CodeRabbit:

### 1. Create Feature Branch and Code
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes (Claude Code writes the code)
# ... coding happens here ...

# Commit changes
git add -A
git commit -m "feat: implement new feature"
```

### 2. Push and Create PR
```bash
# Push to GitHub
git push -u origin feature/new-feature

# Create PR using GitHub CLI
gh pr create \
  --title "Add new feature" \
  --body "Description of changes" \
  --base main
```

### 3. Wait for CodeRabbit Review
CodeRabbit will automatically review the PR within 1-2 minutes.

### 4. Fetch and Read Reviews
```bash
# Get the PR number (if you don't know it)
PR_NUMBER=$(gh pr view --json number -q .number)

# Fetch CodeRabbit's review
npx coderabbitai-mcp@latest get-review-comments \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr $PR_NUMBER
```

### 5. Fix Issues Based on Feedback
Claude Code reads the review comments and makes necessary fixes:
```bash
# Make fixes based on CodeRabbit feedback
# ... coding fixes happen here ...

# Commit and push fixes
git add -A
git commit -m "fix: address CodeRabbit review comments"
git push
```

### 6. Mark Comments as Resolved
```bash
# After fixing an issue, mark the comment as resolved
npx coderabbitai-mcp@latest resolve-comment \
  --owner ProduktEntdecker \
  --repo touchbarfix \
  --pr $PR_NUMBER \
  --comment-id <comment-id> \
  --resolution "addressed"
```

### 7. Merge When Approved
```bash
# Check if all reviews are resolved
gh pr checks

# Merge the PR
gh pr merge --auto --squash
```

## Practical Example Script

Create a file `coderabbit-workflow.sh`:

```bash
#!/bin/bash
# Automated CodeRabbit workflow example

# Configuration
OWNER="ProduktEntdecker"
REPO="touchbarfix"
BRANCH="feature/test-coderabbit"

# Step 1: Create and push changes
git checkout -b $BRANCH
echo "# Test file" > test.md
git add test.md
git commit -m "test: add test file for CodeRabbit"
git push -u origin $BRANCH

# Step 2: Create PR
PR_URL=$(gh pr create \
  --title "Test CodeRabbit Integration" \
  --body "Testing automated review workflow" \
  --base main \
  2>&1)

# Extract PR number
PR_NUMBER=$(echo $PR_URL | grep -o '[0-9]*$')
echo "Created PR #$PR_NUMBER"

# Step 3: Wait for CodeRabbit review (usually 1-2 minutes)
echo "Waiting for CodeRabbit to review..."
sleep 90

# Step 4: Fetch review
echo "Fetching CodeRabbit review..."
npx coderabbitai-mcp@latest get-review-comments \
  --owner $OWNER \
  --repo $REPO \
  --pr $PR_NUMBER

# Step 5: Process reviews (Claude Code would do this programmatically)
echo "Review fetched! Claude Code can now process and fix issues."
```

## Troubleshooting

### Problem: "Authentication failed"
**Solution**: Make sure your GitHub token is properly set in `~/.config/mcp/.env`

### Problem: "Command not found: npx"
**Solution**: Install Node.js and npm: `brew install node`

### Problem: "CodeRabbit didn't review my PR"
**Solutions**:
1. Make sure CodeRabbit app is installed: https://github.com/apps/coderabbit-ai
2. Check `.coderabbit.yaml` configuration
3. Wait 1-2 minutes after PR creation
4. Manually trigger: Comment `@coderabbitai review` on the PR

### Problem: "Cannot resolve comments"
**Solution**: You need write access to the repository and proper token permissions

## Advanced Usage

### Batch Processing Multiple PRs
```bash
#!/bin/bash
# Review all open PRs
for pr in $(gh pr list --json number -q '.[].number'); do
  echo "Processing PR #$pr"
  npx coderabbitai-mcp@latest get-review-comments \
    --owner ProduktEntdecker \
    --repo touchbarfix \
    --pr $pr
done
```

### Custom Review Instructions
When creating a PR, you can add specific instructions for CodeRabbit:
```bash
gh pr create \
  --title "Feature: Add new functionality" \
  --body "## Description
  Add new feature X

  @coderabbitai review with focus on:
  - Security implications
  - Performance optimization
  - Error handling"
```

### Integration with CI/CD
Add to your GitHub Actions workflow:
```yaml
- name: Wait for CodeRabbit Review
  run: |
    sleep 120  # Wait for review
    npx coderabbitai-mcp@latest get-review-comments \
      --owner ${{ github.repository_owner }} \
      --repo ${{ github.event.repository.name }} \
      --pr ${{ github.event.pull_request.number }}
```

## Best Practices

1. **Always wait for CodeRabbit** before merging
2. **Address all critical issues** identified by CodeRabbit
3. **Use custom instructions** for specific review focus
4. **Mark comments as resolved** to maintain clear PR status
5. **Integrate with CI/CD** for automated quality gates

## Resources

- CodeRabbit Documentation: https://docs.coderabbit.ai
- MCP Server GitHub: https://github.com/bradthebeeble/coderabbitai-mcp
- TouchBarFix Repository: https://github.com/ProduktEntdecker/touchbarfix
- GitHub CLI Documentation: https://cli.github.com/manual/

## Next Steps

1. Add your GitHub token to `~/.config/mcp/.env`
2. Test the integration with a sample PR
3. Configure `.coderabbit.yaml` for project-specific rules
4. Set up automated workflows
5. Train team on using CodeRabbit feedback

---

**Setup Complete!** The CodeRabbit MCP integration is ready to use once you add your GitHub token.
EOF'
print_success "Complete documentation created: $WORKFLOW_DOC"

# Final summary
echo ""
echo "========================================================="
echo -e "${GREEN}✅ CodeRabbit MCP Integration Installed!${NC}"
echo "========================================================="
echo ""
echo "📁 Files Created:"
echo "   - Config template: ~/.config/mcp/.env.template"
echo "   - MCP Config: ~/.config/mcp/servers.json"
echo "   - Test Script: ./test-coderabbit-mcp.sh"
echo "   - Documentation: ./CODERABBIT-MCP-COMPLETE.md"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Manual Step Required${NC}"
echo "========================================================="
echo "You need to add your GitHub token to complete the setup:"
echo ""
echo "1. Create a GitHub token at:"
echo "   ${BLUE}https://github.com/settings/tokens/new${NC}"
echo ""
echo "2. Select these scopes:"
echo "   - repo (Full control of private repositories)"
echo "   - read:org (Read org and team membership)"
echo "   - read:user (Read user profile data)"
echo ""
echo "3. Copy the template and add your token:"
echo "   ${GREEN}cp ~/.config/mcp/.env.template ~/.config/mcp/.env${NC}"
echo "   ${GREEN}nano ~/.config/mcp/.env${NC}"
echo ""
echo "4. Test the integration:"
echo "   ${GREEN}./test-coderabbit-mcp.sh${NC}"
echo ""
echo "📖 See CODERABBIT-MCP-COMPLETE.md for detailed usage"
echo ""
print_warning "Note: CodeRabbit app must be installed on your GitHub repository"
print_warning "Install at: https://github.com/apps/coderabbit-ai"
