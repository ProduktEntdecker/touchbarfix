---
status: pending
priority: p3
issue_id: "004"
tags: [code-review, simplicity, performance, swift]
dependencies: []
---

# Remove Barely-Visible Hover Animation System

## Problem Statement

The `ContextPanelView` has a complex hover state management system (`hoveredButton` enum and state, multiple `.onHover` handlers) for a barely-noticeable 2% scale effect (1.02x). The complexity is not worth the minimal visual benefit.

## Findings

**Source:** Simplicity Reviewer Agent, Performance Oracle Agent

**Location:** `App/Sources/ContextPanelView.swift:17-21, 275-276, 322-324, 350-352, 378-379`

```swift
@State private var hoveredButton: ButtonType?

private enum ButtonType {
    case primary, secondary, tertiary
}

// Multiple places:
.scaleEffect(hoveredButton == .primary ? 1.02 : 1.0)
.onHover { hoveredButton = $0 ? .primary : nil }
```

**Impact:**
- ~15 lines of complexity for imperceptible effect
- Each hover triggers state change and view rebuild
- Cognitive load for maintainers

## Proposed Solutions

### Option A: Remove Entirely (Recommended)

**Pros:** Simplest, removes all complexity
**Cons:** Slightly less polish (but barely visible anyway)
**Effort:** Small (20 min)
**Risk:** Low

Delete all hover-related code.

### Option B: Use `.hoverEffect()` Modifier (macOS 13+)

**Pros:** System-managed, less code
**Cons:** May not work identically
**Effort:** Small (15 min)
**Risk:** Low

## Recommended Action

Option A - Remove hover animation system entirely

## Technical Details

**Code to Remove:**
- Lines 17-21: `@State private var hoveredButton` and `ButtonType` enum
- Lines 275-276: hover effect on success Done button
- Lines 322-324: hover effect on Grant Admin button
- Lines 350-352: hover effect on Restart Mac button
- Lines 378-379: hover effect on Try Again button

**Estimated LOC reduction:** ~15 lines

## Acceptance Criteria

- [ ] All hover-related code removed
- [ ] No visual regression (buttons still look correct)
- [ ] Buttons still respond to clicks
- [ ] Build succeeds

## Work Log

| Date | Action | Notes |
|------|--------|-------|
| 2026-01-01 | Created | From code review of v1.5.0 dashboard changes |

## Resources

- PR: Uncommitted v1.5.0 changes on main
