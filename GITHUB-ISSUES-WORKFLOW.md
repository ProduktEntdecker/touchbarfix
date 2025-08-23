# GitHub Issues Development Workflow

**Effective Date:** August 23, 2025  
**Purpose:** Streamlined issue-driven development workflow for TouchBarFix project

## 🎯 Overview

This workflow enables efficient collaboration between project owner (issue creation) and Claude Code (implementation) with automated code review via CodeRabbit.

**Flow:** Issues → Feature Branch → CodeRabbit Review → Merge

## 📋 Issue Templates

### Bug Report Template
```markdown
## Bug Description
[Clear, specific description of the problem]

## Expected Behavior
[What should happen]

## Actual Behavior  
[What actually happens + error messages if any]

## Steps to Reproduce
1. [Specific step 1]
2. [Specific step 2]
3. [Include exact commands if applicable]

## Environment
- macOS Version: [e.g., macOS 14.1 Sonoma]
- TouchBarFix Version: [e.g., v1.2.1]
- MacBook Model: [e.g., MacBook Pro 16" 2019]

## Files Affected
[List relevant files if known, e.g., TouchBarManager.swift]

## Priority
- [ ] High (app crashes/unusable)
- [ ] Medium (feature broken)
- [ ] Low (minor issue)

## Acceptance Criteria
- [ ] Bug is completely fixed
- [ ] Tests pass (existing + new)
- [ ] No regressions introduced
- [ ] Documentation updated if needed
```

### Feature Request Template
```markdown
## Feature Description
[What functionality should be added]

## User Story
As a [user type], I want [functionality] so that [benefit/value]

## Technical Requirements
[Specific implementation details - be as detailed as possible]

## Files Expected to Modify
[List components/files that likely need changes]
- [ ] App/Sources/[specific file].swift
- [ ] README.md (if user-facing)
- [ ] Tests/[test file].swift

## UI/UX Requirements
[If applicable - describe interface changes]

## Acceptance Criteria
- [ ] [Specific deliverable 1]
- [ ] [Specific deliverable 2]
- [ ] Unit tests added for new functionality
- [ ] Integration tests pass
- [ ] Documentation updated
- [ ] CodeRabbit review passes

## Priority
- [ ] High (critical for next release)
- [ ] Medium (improves user experience)
- [ ] Low (nice to have enhancement)

## Additional Context
[Screenshots, mockups, related issues, etc.]
```

### Technical Debt/Refactoring Template
```markdown
## Current State
[What code/architecture needs improvement]

## Problems with Current Approach
[Why this needs to be refactored - performance, maintainability, etc.]

## Proposed Solution
[How to improve the code/architecture]

## Benefits
- [Specific improvement 1]
- [Specific improvement 2]
- [Performance/maintainability gains]

## Implementation Plan
1. [Specific step 1]
2. [Specific step 2]
3. [Testing approach]

## Risk Assessment
- [ ] Breaking changes possible
- [ ] Requires careful testing
- [ ] May affect [specific functionality]

## Files to Refactor
[List specific files and what changes each needs]

## Acceptance Criteria
- [ ] Code quality metrics improved
- [ ] All existing tests pass
- [ ] No breaking changes to public API
- [ ] Performance maintained or improved
- [ ] CodeRabbit review passes
```

### Documentation Update Template
```markdown
## Documentation Scope
[What documentation needs updating]

## Current Issues
[What's wrong/missing with current docs]

## Required Changes
- [ ] [Specific change 1]
- [ ] [Specific change 2]
- [ ] [Update screenshots if needed]

## Files to Update
- [ ] README.md
- [ ] [Specific .md files]
- [ ] Code comments
- [ ] API documentation

## Acceptance Criteria
- [ ] Documentation is accurate and up-to-date
- [ ] All links work correctly
- [ ] Screenshots are current
- [ ] Grammar and spelling checked
```

## 🏷️ Label System

### Type Labels (Required)
- `bug` - Something is broken or not working
- `enhancement` - New feature or functionality
- `refactor` - Code improvement without new features
- `docs` - Documentation changes only
- `ci/cd` - Build, deployment, or workflow changes
- `security` - Security-related changes

### Priority Labels (Required)
- `priority: high` - Urgent, blocks other work or critical bug
- `priority: medium` - Important for user experience
- `priority: low` - Nice to have, can be deferred

### Status Labels (Claude Code will manage)
- `ready` - Ready for development to begin
- `in progress` - Currently being worked on by Claude Code
- `needs review` - PR created, waiting for review
- `blocked` - Cannot proceed due to external dependency

### Size Labels (Optional, for planning)
- `size: small` - 1-2 hours of work
- `size: medium` - Half day of work
- `size: large` - Full day or more

## 🔄 Development Workflow

### Step 1: Issue Creation (Project Owner)
1. Create new issue using appropriate template
2. Add type and priority labels
3. Add `ready` label when fully specified
4. Assign to Claude Code if urgent

### Step 2: Issue Selection (Claude Code)
1. Read issue via: `gh issue view [number]`
2. Self-assign issue: `gh issue edit [number] --add-assignee @me`
3. Add `in progress` label, remove `ready` label
4. Comment with implementation approach if needed

### Step 3: Implementation (Claude Code)
1. Create feature branch: `git checkout -b feature/issue-[number]-[short-description]`
   - Example: `feature/issue-42-add-monterey-support`
2. Implement solution following issue requirements exactly
3. Write/update tests as specified in acceptance criteria
4. Update documentation if required
5. Commit with conventional format: `feat: add macOS Monterey support (issue #42)`

### Step 4: Pull Request Creation (Claude Code)
1. Push branch: `git push -u origin feature/issue-[number]-[short-description]`
2. Create PR: `gh pr create --title "[type]: [description] (fixes #[issue-number])" --body "@coderabbitai review"`
3. PR title examples:
   - `feat: add macOS Monterey support (fixes #42)`
   - `fix: resolve Touch Bar detection on Intel Macs (fixes #38)`
   - `refactor: improve error handling in TouchBarManager (fixes #45)`
4. Add `needs review` label to issue

### Step 5: Automated Review (CodeRabbit)
1. CodeRabbit automatically reviews PR
2. Claude Code addresses any CodeRabbit feedback
3. Push updates to same branch (auto-updates PR)
4. Repeat until CodeRabbit approves

### Step 6: Final Review & Merge (Project Owner)
1. Review PR and CodeRabbit feedback
2. Test functionality if needed
3. Merge PR when satisfied
4. Issue automatically closes (due to "fixes #[number]" in PR)

## 📊 Branch Naming Convention

**Format:** `[type]/issue-[number]-[short-description]`

**Examples:**
- `feature/issue-42-add-monterey-support`
- `fix/issue-38-intel-mac-detection`  
- `refactor/issue-45-error-handling`
- `docs/issue-51-update-readme`

**Benefits:**
- Clear issue linkage
- Easy to understand purpose
- Consistent across all branches
- Auto-linkage in GitHub

## 🎯 Acceptance Criteria Best Practices

### ✅ Good Acceptance Criteria
```markdown
- [ ] App detects macOS Monterey 12.x correctly
- [ ] TouchBarManager.detectMacOSVersion() returns correct version string
- [ ] Unit test added for Monterey detection
- [ ] README compatibility matrix updated
- [ ] No breaking changes to existing functionality
```

### ❌ Vague Acceptance Criteria
```markdown
- [ ] App works better
- [ ] Fix the issue
- [ ] Update some docs
```

## 🔍 Issue Quality Guidelines

### ✅ Excellent Issues Include:
- **Specific technical details** (exact functions, files, methods)
- **Clear acceptance criteria** (testable outcomes)
- **Context and background** (why this matters)
- **Expected implementation approach** (if known)
- **Links to related issues/PRs** (for context)

### 📝 Issue Description Template
```markdown
## Background
[Why this issue exists - context for Claude Code]

## Technical Details
[Specific functions, classes, files involved]

## Implementation Approach
[Suggested approach or constraints]

## Definition of Done
[When is this truly complete?]
```

## 🚀 Automation Features

### GitHub Auto-Linking
- `fixes #42` in PR description → auto-closes issue on merge
- `relates to #38` → creates reference without closing
- Branch names with `issue-42` → auto-linked in PR

### Status Management
- PR creation → Issue gets `needs review` label
- PR merged → Issue auto-closed
- Branch deleted → Cleanup complete

### CodeRabbit Integration
- `@coderabbitai review` in PR body → triggers review
- Auto-comments on code quality issues
- Integrates with Claude Code MCP server for reading feedback

## 📋 Quality Checklist

### Before Creating Issue:
- [ ] Used appropriate template
- [ ] Added type and priority labels
- [ ] Acceptance criteria are specific and testable
- [ ] Technical details provided where known
- [ ] Related to project goals/roadmap

### Before Starting Development:
- [ ] Issue is fully understood
- [ ] Acceptance criteria are clear
- [ ] Technical approach is planned
- [ ] Tests strategy is defined

### Before Creating PR:
- [ ] All acceptance criteria met
- [ ] Tests added/updated as required
- [ ] Documentation updated if needed
- [ ] Code follows project conventions
- [ ] No debugging code left in

### Before Merging:
- [ ] CodeRabbit review passed
- [ ] All tests passing
- [ ] No breaking changes
- [ ] Issue requirements fully satisfied

## 🔧 Commands Reference

### Issue Management
```bash
# List open issues
gh issue list --state open

# View specific issue
gh issue view 42

# Edit issue (add labels, assignees)
gh issue edit 42 --add-label "in progress" --add-assignee @me

# Comment on issue
gh issue comment 42 --body "Starting implementation"
```

### Branch & PR Management
```bash
# Create and switch to feature branch
git checkout -b feature/issue-42-add-monterey-support

# Push and create PR
git push -u origin feature/issue-42-add-monterey-support
gh pr create --title "feat: add macOS Monterey support (fixes #42)" --body "@coderabbitai review"

# Check PR status
gh pr view 42
gh pr checks 42
```

### CodeRabbit Integration
```bash
# Test MCP connection
npx coderabbitai-mcp --version

# Get CodeRabbit review for PR
npx coderabbitai-mcp review-pr --repo ProduktEntdecker/touchbarfix --pr 42

# Review specific commit
npx coderabbitai-mcp review-commit --repo ProduktEntdecker/touchbarfix --commit HEAD
```

## 📈 Success Metrics

### Issue Quality Metrics
- Time from issue creation to PR creation
- Number of clarification requests needed
- Percentage of issues completed as specified

### Development Efficiency
- CodeRabbit review pass rate (target: >90% first review)
- Number of review iterations per PR (target: <3)
- Time from PR creation to merge

### Process Adherence
- Percentage of issues using templates
- Percentage of PRs following naming convention
- Percentage of branches properly linked to issues

---

**This workflow ensures:**
- Clear communication between project owner and Claude Code
- Automatic code quality enforcement via CodeRabbit
- Full traceability from idea to implementation
- Consistent development standards
- Efficient issue-to-deployment pipeline

**Next Steps:**
1. Set up GitHub issue templates in `.github/ISSUE_TEMPLATE/`
2. Configure repository labels
3. Test workflow with first issue
4. Refine based on experience