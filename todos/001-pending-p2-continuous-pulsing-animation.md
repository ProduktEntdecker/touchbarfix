---
status: pending
priority: p2
issue_id: "001"
tags: [code-review, performance, animation, swift]
dependencies: []
---

# Continuous Pulsing Animation Never Stops

## Problem Statement

The pulsing animation in `CompactProcessRow` uses `.repeatForever()` but continues running even after the process transitions away from `.inProgress` state. SwiftUI's animation system does not automatically stop repeating animations when the condition changes.

## Findings

**Source:** Performance Oracle Agent

**Location:** `App/Sources/TouchBarDashboardView.swift:186-194`

```swift
Circle()
    .fill(Color.blue)
    .scaleEffect(isPulsing ? 1.2 : 1.0)
    .opacity(isPulsing ? 0.7 : 1.0)
    .animation(
        .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true),
        value: isPulsing
    )
```

**Impact:** The animation continues running in the background, consuming CPU cycles even when not visible. With 3 process rows, this could mean 3 continuous animations running simultaneously.

## Proposed Solutions

### Option A: Extract to Separate View (Recommended)

**Pros:** Clean lifecycle management, animation stops when view disappears
**Cons:** Slightly more code
**Effort:** Small (30 min)
**Risk:** Low

```swift
struct PulsingCircle: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(Color.blue)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.7 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}
```

### Option B: Conditional Animation

**Pros:** Simpler, fewer files
**Cons:** May not cleanly stop animation
**Effort:** Small (15 min)
**Risk:** Medium - may not work as expected

```swift
.animation(
    process.status == .inProgress
        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        : .default,
    value: process.status
)
```

## Recommended Action

Option A - Extract to separate `PulsingCircle` view

## Technical Details

**Affected Files:**
- `App/Sources/TouchBarDashboardView.swift`

**Components:**
- `CompactProcessRow`
- `statusIndicator` ViewBuilder

## Acceptance Criteria

- [ ] Pulsing animation only runs when process is `.inProgress`
- [ ] Animation stops when process transitions to success/failure
- [ ] CPU usage returns to baseline after restart completes
- [ ] No visual regression in animation appearance

## Work Log

| Date | Action | Notes |
|------|--------|-------|
| 2026-01-01 | Created | From code review of v1.5.0 dashboard changes |

## Resources

- PR: Uncommitted v1.5.0 changes on main
- SwiftUI animation lifecycle: https://developer.apple.com/documentation/swiftui/animation
