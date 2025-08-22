# Development Workflow for TouchBarFix

## CRITICAL: Always Use Feature Branches for Code Quality

**Never push directly to main branch!** All changes must go through pull requests to trigger CodeRabbit automated code review.

## Standard Development Workflow

### 1. Create Feature Branch
```bash
# Always create a feature branch for any changes
git checkout -b feature/description-of-change
# or for fixes:
git checkout -b fix/issue-description
```

### 2. Make Changes
- Edit files as needed
- Test changes locally
- Ensure all tests pass

### 2.5. Pre-Review with CodeRabbit MCP (Optional but Recommended)
```bash
# Get instant feedback before committing
npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD

# Apply any suggested improvements
# This catches issues early, before PR creation
```

### 3. Commit Changes
```bash
git add -A
git commit -m "type: description

- Detail 1
- Detail 2

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Commit types:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `style:` Formatting, missing semi-colons, etc
- `refactor:` Code change that neither fixes a bug nor adds a feature
- `test:` Adding missing tests
- `chore:` Changes to build process or auxiliary tools

### 4. Push Feature Branch
```bash
git push -u origin feature/your-branch-name
```

### 5. Create Pull Request

#### Option A: Via GitHub Web
1. Go to: https://github.com/ProduktEntdecker/touchbarfix
2. Click "Pull requests" → "New pull request"
3. Select your branch
4. Add description with `@coderabbitai` mention

#### Option B: Via GitHub CLI (if installed)
```bash
gh pr create --title "feat: your feature" --body "Description

@coderabbitai please review"
```

### 6. Wait for CodeRabbit Review
- CodeRabbit will automatically review within 2-3 minutes
- Address any feedback in the PR comments
- Make additional commits to the branch if needed

### 7. Merge After Approval
- Once CodeRabbit approves and all checks pass
- Merge via GitHub web interface
- Delete the feature branch

## Example Workflow

```bash
# 1. Start new feature
git checkout main
git pull origin main
git checkout -b feature/add-analytics

# 2. Make changes
# ... edit files ...

# 3. Commit
git add -A
git commit -m "feat: add anonymous analytics for success tracking

- Track fix success rate
- No personal data collected
- Helps improve the app

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 4. Push
git push -u origin feature/add-analytics

# 5. Create PR (manual via GitHub)
# Go to the URL shown in terminal output
# Add PR description with @coderabbitai mention

# 6. After CodeRabbit approval and merge
git checkout main
git pull origin main
git branch -d feature/add-analytics
```

## Emergency Hotfixes

For critical production issues only:

```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-issue

# Make minimal fix
# ... fix issue ...

# Commit and push
git add -A
git commit -m "hotfix: critical issue description"
git push -u origin hotfix/critical-issue

# Create PR with URGENT label
# Merge after expedited review
```

## Branch Naming Conventions

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions/changes
- `hotfix/` - Urgent production fixes
- `chore/` - Maintenance tasks

## CodeRabbit Configuration

The `.coderabbit.yaml` file configures automated reviews for:
- Swift code quality
- Security best practices
- Version consistency
- Documentation accuracy

## Quality Gates

Before merging any PR:
1. ✅ CodeRabbit approval
2. ✅ All automated checks pass
3. ✅ Version numbers consistent (if changed)
4. ✅ Documentation updated (if needed)
5. ✅ Tests pass (if applicable)

## Common Issues

### CodeRabbit Not Reviewing
- Ensure PR is created (not draft)
- Check `.coderabbit.yaml` exists in repo
- Mention `@coderabbitai` in PR description

### Merge Conflicts
```bash
# Update your branch with latest main
git checkout main
git pull origin main
git checkout your-branch
git merge main
# Resolve conflicts
git add -A
git commit -m "fix: resolve merge conflicts"
git push
```

## Documentation Updates

When making changes, update:
1. This file if workflow changes
2. README.md for user-facing changes
3. CLAUDE.md for AI assistant context
4. Version numbers in all relevant files

## Version Management

When releasing new versions:
1. Update version in `App/Resources/Info.plist`
2. Update version in `App/Package.swift`
3. Update version in DMG creation scripts
4. Create git tag: `git tag v1.2.1`

## CodeRabbit MCP Integration

### How to Use MCP for Instant Reviews

The CodeRabbit MCP integration provides instant code review during development:

```bash
# After making changes, before committing:
npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD

# This gives you instant feedback on:
# - Code quality issues
# - Security concerns
# - Best practice violations
# - Documentation gaps
```

### Complete Example with MCP Integration

```bash
# 1. Create feature branch
git checkout -b feature/add-telemetry

# 2. Make your changes
# ... edit files ...

# 3. Stage changes for review
git add -A
git commit -m "feat: add telemetry"

# 4. Run MCP review BEFORE pushing
npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD

# 5. Apply CodeRabbit suggestions
# ... fix issues found ...
git add -A
git commit -m "fix: address CodeRabbit feedback"

# 6. Push clean code to GitHub
git push -u origin feature/add-telemetry

# 7. Create PR - CodeRabbit bot will do final review
# Go to GitHub and create PR with @coderabbitai mention
```

### Benefits of Using MCP

1. **Instant Feedback**: No waiting for PR creation
2. **Cleaner PRs**: Issues fixed before push
3. **Learning**: See issues immediately while context is fresh
4. **Double Review**: MCP during dev + Bot on PR = higher quality

## Remember

**Always use feature branches and pull requests!** This ensures:
- Automated code review by CodeRabbit (both MCP and bot)
- Consistent code quality
- Proper documentation
- Security validation
- No broken builds in main

Direct pushes to main bypass all quality checks and should never be done.