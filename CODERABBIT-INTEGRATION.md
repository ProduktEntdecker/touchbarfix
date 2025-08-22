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

### For Claude Code Development:
1. **Write Code** - Implement features/fixes
2. **Review with CodeRabbit** - Run MCP command to get suggestions
3. **Apply Improvements** - Implement CodeRabbit's recommendations
4. **Commit Final Version** - Push clean, reviewed code

### For Pull Requests:
1. Create feature branch
2. Make changes
3. Run CodeRabbit review
4. Apply suggestions
5. Create PR (CodeRabbit will auto-review)

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
1. Run manual review: `npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD`
2. Apply suggested improvements
3. Commit fixes
4. Verify with another review if needed

## Integration with Development Flow

```bash
# Standard development process with CodeRabbit:
git add .
git commit -m "feature: implement new functionality"

# Review with CodeRabbit
npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD

# Apply suggestions, then:
git add .
git commit -m "fix: apply CodeRabbit suggestions"
git push origin main
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