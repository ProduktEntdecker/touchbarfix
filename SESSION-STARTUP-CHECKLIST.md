# Claude Code Session Startup Checklist

**Effective Date:** August 23, 2025  
**Purpose:** Automatic issue monitoring and session initialization procedures

## 🔄 Automatic Session Start Routine

### **Step 1: Check for Open Issues (Always First)**
```bash
# Check for all open issues
export GH_TOKEN=$GITHUB_PAT && gh issue list --repo ProduktEntdecker/touchbarfix --state open --json number,title,createdAt,labels

# Quick summary format
gh issue list --repo ProduktEntdecker/touchbarfix --state open
```

**Expected Actions:**
- If **no open issues**: Continue with planned session work
- If **open issues exist**: Review and prioritize immediately
- If **new issues** (created since last session): Auto-assign and start work

### **Step 2: Issue Processing Protocol**
For each open issue found:

1. **Read Full Issue**: `gh issue view [number]`
2. **Self-Assign**: `gh issue edit [number] --add-assignee @me`  
3. **Create Feature Branch**: `git checkout -b feature/issue-[number]-[description]`
4. **Add to TodoWrite**: Track implementation progress
5. **Implement Solution**: Follow GitHub Issues workflow
6. **Create PR**: `gh pr create` with "fixes #[number]"
7. **Request Review**: Include "@coderabbitai review" in PR body

### **Step 3: Session Context Update**
- Update TodoWrite with current session priorities
- If issues exist, prioritize over other planned work
- Maintain issue-driven development focus

## 📋 Issue Priority Matrix

### **High Priority (Work Immediately):**
- 🔴 `priority: high` label
- 🐛 `bug` with app crashes or data loss
- 🔒 Security-related issues
- 📈 Revenue-blocking issues

### **Medium Priority (Work Today):**
- 🟡 `priority: medium` label  
- ✨ `enhancement` that improves UX
- 📚 `docs` that block user adoption
- 🔧 `refactor` that blocks other work

### **Low Priority (Work When Available):**
- 🟢 `priority: low` label
- Nice-to-have enhancements
- Minor documentation updates
- Non-critical refactoring

## 🎯 Session Planning Logic

### **Scenario A: No Open Issues**
```
✅ No pending work - proceed with planned session goals
→ Continue marketing campaign, feature development, etc.
```

### **Scenario B: 1-2 Open Issues**  
```
🎯 Focus session on completing these issues
→ Implement → PR → Review → Merge → Mark complete
```

### **Scenario C: 3+ Open Issues**
```
📊 Prioritize by labels and impact
→ Work highest priority first
→ Batch similar issues if possible
→ Complete at least 1-2 per session
```

### **Scenario D: Critical Issues**
```
🚨 Stop all other work immediately
→ Address critical issues first
→ Communicate status updates to user
→ Resume normal work only after resolution
```

## 🔄 Status Update Commands

### **Issue Status Management:**
```bash
# Check current issue status
gh issue view [number]

# Update issue with progress
gh issue comment [number] --body "Status update: [current progress]"

# Close completed issue (if PR doesn't auto-close)
gh issue close [number] --comment "Completed via PR #[number]"
```

### **Branch Management:**
```bash
# List active feature branches
git branch | grep "feature/issue-"

# Clean up merged branches
git branch -d feature/issue-[number]-[description]
```

## 🎛️ Automation Rules

### **Auto-Assignment Rules:**
- **New issues**: Auto-assign to Claude Code if created within 24 hours
- **High priority**: Immediate assignment regardless of other work
- **Bug reports**: Assign and start work within same session

### **TodoWrite Integration:**
- **New issues**: Automatically add to todo list with "pending" status
- **In progress**: Mark as "in_progress" when branch created
- **Completed**: Mark as "completed" when PR merged

### **Branch Naming Automation:**
- **Format**: `feature/issue-[number]-[short-kebab-description]`
- **Examples**: 
  - `feature/issue-6-add-dark-mode`
  - `fix/issue-7-memory-leak-touchbar`
  - `docs/issue-8-update-installation-guide`

## 📊 Session Success Metrics

### **Daily Goals:**
- **Issue Response Time**: < 4 hours for new issues
- **Implementation Speed**: 1-2 issues completed per session
- **Code Quality**: 90%+ CodeRabbit approval rate on first review

### **Weekly Review:**
- **Issue Closure Rate**: 80%+ of opened issues closed within week
- **User Satisfaction**: Clear communication and complete solutions
- **Technical Debt**: No accumulation of incomplete implementations

## ⚠️ Important Notes

### **Never Skip Issue Check:**
- Issue checking is **mandatory** at every session start
- Even if user has specific requests, check issues **first**
- Issues take precedence over planned work unless explicitly overridden

### **Communication Protocol:**
- **Always inform user** of open issues found
- **Provide quick summary** of what needs to be done
- **Ask for priority guidance** if multiple high-priority issues exist

### **Emergency Procedures:**
- **Critical bugs**: Stop all work, focus on immediate fix
- **Security issues**: Private communication, immediate resolution
- **User requests**: Balance with existing issue priorities

## 🔧 Technical Implementation

### **Session Start Script (Conceptual):**
```bash
#!/bin/bash
# session-start.sh - Run at beginning of every Claude Code session

echo "🔍 Checking for open issues..."
ISSUES=$(gh issue list --repo ProduktEntdecker/touchbarfix --state open --json number,title)
ISSUE_COUNT=$(echo "$ISSUES" | jq length)

if [ "$ISSUE_COUNT" -gt 0 ]; then
    echo "📋 Found $ISSUE_COUNT open issues:"
    gh issue list --repo ProduktEntdecker/touchbarfix --state open
    echo "⚡ Starting issue-driven development mode..."
else
    echo "✅ No open issues - ready for planned work"
fi
```

### **Integration Points:**
- **CLAUDE.md**: Reference this checklist in session startup
- **GitHub Issues Workflow**: Seamless integration with existing process
- **TodoWrite**: Automatic population from issue status

---

**This checklist ensures no issues are missed and maintains consistent issue-driven development workflow.**

**Next Update:** After implementing this for a few sessions, refine based on actual usage patterns.