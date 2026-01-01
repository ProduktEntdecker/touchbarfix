---
status: pending
priority: p2
issue_id: "003"
tags: [code-review, deprecation, swift, pattern]
dependencies: []
---

# Deprecated onChange API Usage

## Problem Statement

The code uses the deprecated single-parameter `onChange(of:perform:)` API which is deprecated in iOS 17/macOS 14.

## Findings

**Source:** Pattern Recognition Agent

**Location:** `App/Sources/TouchBarDashboardView.swift:174`

```swift
.onChange(of: process.status) { newStatus in
    isPulsing = (newStatus == .inProgress)
}
```

**Impact:**
- Deprecation warning in Xcode
- May be removed in future Swift/SwiftUI versions
- Different performance characteristics

## Proposed Solutions

### Option A: Update to New API (Recommended)

**Pros:** Future-proof, no deprecation warning
**Cons:** Minor code change
**Effort:** Small (10 min)
**Risk:** Low

```swift
.onChange(of: process.status) { oldStatus, newStatus in
    isPulsing = (newStatus == .inProgress)
}
```

## Recommended Action

Option A - Update to new two-parameter API

## Technical Details

**Affected Files:**
- `App/Sources/TouchBarDashboardView.swift` (line 174)
- Also check `RestartProgressView.swift` (line 179)

## Acceptance Criteria

- [ ] No deprecation warnings for onChange
- [ ] Animation behavior unchanged
- [ ] App builds on macOS 14+

## Work Log

| Date | Action | Notes |
|------|--------|-------|
| 2026-01-01 | Created | From code review of v1.5.0 dashboard changes |

## Resources

- Apple docs: https://developer.apple.com/documentation/swiftui/view/onchange(of:initial:_:)-8wgp9
