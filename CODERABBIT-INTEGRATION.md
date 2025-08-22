# CodeRabbit Integration for TouchBarFix

## Current Status
CodeRabbit MCP server is available and can be used for code review.

## Available Commands

### Review Latest Changes
```bash
npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit $(git rev-parse HEAD)
```

### Create Pull Request Review
```bash
npx coderabbitai-mcp create-review --repo ProduktEntdecker/touchbarfix --head [branch] --base main
```

## Integration Workflow

### Two-Layer Review Process:

#### Layer 1: MCP Pre-Review (Before Committing)
1. **Write Code** - Implement features/fixes
2. **Run MCP Review** - Make a temporary WIP commit, then get instant feedback:
   ```bash
   git add -A
   git commit -m "chore: WIP pre-review"
   npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit $(git rev-parse HEAD)
   ```
3. **Apply Improvements** - Fix issues found by CodeRabbit
4. **Amend/Squash WIP** - Amend or squash the WIP commit before pushing

#### Layer 2: PR Auto-Review (After Push)
1. **Create feature branch**: `git checkout -b feature/name`
2. **Make changes** and commit
3. **Optional: Run MCP pre-review** to catch issues early
4. **Push to GitHub**: `git push -u origin feature/name`
5. **Create PR** - CodeRabbit bot will auto-review
6. **Address PR feedback** if any additional issues found

### Benefits of Two-Layer Approach:
- **MCP Review**: Instant feedback during development
- **PR Review**: Final validation before merge
- **Cleaner PRs**: Issues fixed before PR creation
- **Faster Iteration**: No waiting for PR to get feedback

## CodeRabbit Bot Setup

CodeRabbit bot comments on PRs automatically when:
- New PR is created
- New commits are pushed to PR
- Code changes are detected

## Issues from August 20th Review

CodeRabbit found these issues that need fixing:

### 1. Duplicate Favicon Rewrite in vercel.json
```json
// Remove duplicate entry:
{ "source": "/favicon.ico", "destination": "/Assets/favicon.ico" }
```

### 2. Placeholder Text in terms.html
```html
<!-- Replace placeholder: -->
<p class="mb-4">These Terms are governed by the laws of Germany. The courts of Germany shall have exclusive jurisdiction, except where mandatory consumer protection law provides otherwise.</p>
```

## Manual Review Process

When CodeRabbit doesn't trigger automatically:
1. Create WIP commit: `git add -A && git commit -m "chore: WIP for review"`
2. Run manual review: `npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD`
3. Apply suggested improvements
4. Amend WIP commit with fixes: `git add -A && git commit --amend`
5. Verify with another review if needed

## Integration with Development Flow

```bash
# Standard development process with CodeRabbit:
# 1. Create WIP commit for review
git add .
git commit -m "chore: WIP - implement new functionality"

# 2. Review with CodeRabbit
npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD

# 3. Apply suggestions and amend the WIP commit:
git add .
git commit --amend -m "feature: implement new functionality"

# 4. Push clean, reviewed code:
git push -u origin feature/your-feature-name
# Open a PR from feature/your-feature-name → main (CodeRabbit will auto-review)
```

## Why CodeRabbit Might Not Trigger

1. **Direct commits to main** - Bot may not review direct pushes
2. **Small changes** - May not trigger for minor updates
3. **Configuration** - Repository settings might need adjustment

## Next Steps

1. Fix the duplicate favicon rewrite in vercel.json
2. Update terms.html placeholder text
3. Test CodeRabbit bot on next PR
4. Set up automated review triggers if needed

---

**CodeRabbit helps maintain code quality and catches issues before they reach production.**