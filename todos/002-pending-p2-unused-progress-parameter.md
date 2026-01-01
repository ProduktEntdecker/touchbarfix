---
status: pending
priority: p2
issue_id: "002"
tags: [code-review, simplicity, swift]
dependencies: []
---

# Unused `progress` Parameter in ContextPanelView

## Problem Statement

The `ContextPanelView` receives an `@ObservedObject var progress: RestartProgress` parameter but never uses it. This creates unnecessary coupling and could cause unintended view rebuilds.

## Findings

**Source:** Simplicity Reviewer Agent

**Location:** `App/Sources/ContextPanelView.swift:6`

```swift
struct ContextPanelView: View {
    @ObservedObject var progress: RestartProgress  // Never used!
    let flowState: ContentViewFlowState
    // ...
}
```

**Impact:**
- Unnecessary dependency in view signature
- Potential for view rebuilds when progress changes (even though nothing uses it)
- Confusing API for future maintainers

## Proposed Solutions

### Option A: Remove Parameter (Recommended)

**Pros:** Cleaner API, no unnecessary observation
**Cons:** Breaking change to call sites
**Effort:** Small (15 min)
**Risk:** Low

Remove from `ContextPanelView` and update call site in `TouchBarDashboardView`.

### Option B: Keep for Future Use

**Pros:** Available if needed later
**Cons:** YAGNI violation
**Effort:** None
**Risk:** Low

## Recommended Action

Option A - Remove the unused parameter

## Technical Details

**Affected Files:**
- `App/Sources/ContextPanelView.swift` (line 6)
- `App/Sources/TouchBarDashboardView.swift` (lines 31-32)

## Acceptance Criteria

- [ ] `progress` parameter removed from ContextPanelView
- [ ] Call site in TouchBarDashboardView updated
- [ ] App builds and functions correctly
- [ ] No visual or behavioral changes

## Work Log

| Date | Action | Notes |
|------|--------|-------|
| 2026-01-01 | Created | From code review of v1.5.0 dashboard changes |

## Resources

- PR: Uncommitted v1.5.0 changes on main
