# feat: Extend Test Coverage to 80%+

## Overview

Erweitere die Test-Coverage der TouchBarFix App von ~35% auf 80%+ durch umfassende Unit Tests für die drei ungetesteten Services: `AnalyticsService`, `SharingManager` und `ReviewRequestManager`.

## Problem Statement

**Aktueller Stand:**
- Nur 1 Test-Datei (`TouchBarManagerTests.swift`) mit 118 LOC
- ~35-40% geschätzte Code-Coverage
- Keine Tests für business-kritische Services (Analytics, Sharing, Review Requests)
- Privacy-relevanter Code (`AnalyticsService`) ist ungetestet

**Risiken ohne Tests:**
- Regressions bei Änderungen werden nicht erkannt
- Privacy-Compliance (GDPR Opt-Out) ist nicht verifiziert
- CI kann Code-Qualität nicht garantieren

## Proposed Solution

### Architektur

```
Tests/
├── TouchBarManagerTests.swift      (existiert - erweitern)
├── AnalyticsServiceTests.swift     (neu - 15+ Tests)
├── SharingManagerTests.swift       (neu - 12+ Tests)
├── ReviewRequestManagerTests.swift (neu - 10+ Tests)
├── PrivacyComplianceTests.swift    (neu - 5+ Tests)
└── Mocks/
    ├── MockURLProtocol.swift       (neu)
    ├── MockUserDefaults.swift      (neu)
    └── TestHelpers.swift           (neu)
```

### Technical Approach

**Mocking-Strategie:** Protocol-basiertes Mocking mit Dependency Injection

```swift
// Beispiel: AnalyticsService refactoring
protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

class AnalyticsService: ObservableObject {
    private let session: NetworkSession
    private let userDefaults: UserDefaults

    init(
        session: NetworkSession = URLSession.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.session = session
        self.userDefaults = userDefaults
    }
}
```

## Implementation Phases

### Phase 1: Test Infrastructure (Pre-Requisite)

**Deliverables:**
- [ ] `Tests/Mocks/MockURLProtocol.swift` - URLProtocol-Subclass für Network-Mocking
- [ ] `Tests/Mocks/MockUserDefaults.swift` - Isolierte UserDefaults für Tests
- [ ] `Tests/Mocks/TestHelpers.swift` - Shared Test Utilities

**MockURLProtocol.swift:**
```swift
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
```

### Phase 2: AnalyticsService Tests

**File:** `Tests/AnalyticsServiceTests.swift`

**Test Cases:**
- [ ] `test_formatLargeNumber_withSmallNumber_returnsPlain()` - 999 → "999"
- [ ] `test_formatLargeNumber_withThousands_returnsKFormat()` - 1500 → "1.5K"
- [ ] `test_formatLargeNumber_withMillions_returnsMFormat()` - 1500000 → "1.5M"
- [ ] `test_getSuccessMessage_withFirstFix_returnsFirstVariant()`
- [ ] `test_getSuccessMessage_withMultipleFixes_returnsCountVariant()`
- [ ] `test_trackFixAttempt_whenOptedOut_doesNotSendRequest()` **[Privacy Critical]**
- [ ] `test_trackFixAttempt_whenOptedIn_sendsCorrectPayload()`
- [ ] `test_trackFixAttempt_withNetworkError_failsGracefully()`
- [ ] `test_trackFixAttempt_withMalformedResponse_logsError()`
- [ ] `test_analyticsPayload_doesNotContainPII()` **[Privacy Critical]**
- [ ] `test_modelIdentifier_isTruncatedTo12Characters()` **[Privacy Critical]**
- [ ] `test_userFixCount_persistsAcrossInstances()`
- [ ] `test_lastTrackingTime_updatesOnSuccess()`

**Refactoring Required:**
```swift
// AnalyticsService.swift - Add DI
init(session: NetworkSession = URLSession.shared, userDefaults: UserDefaults = .standard)
```

### Phase 3: SharingManager Tests

**File:** `Tests/SharingManagerTests.swift`

**Pre-Requisite:** Dedupliziere `getModelSeries()` in eine zentrale Utility!

**Test Cases:**
- [ ] `test_getShareTitle_withSingleFix_returnsSingular()`
- [ ] `test_getShareTitle_withMultipleFixes_returnsPlural()`
- [ ] `test_getModelSeries_withMacBookPro_returnsCorrectSeries()`
- [ ] `test_getModelSeries_withMacBookAir_returnsCorrectSeries()`
- [ ] `test_getModelSeries_withUnknownModel_returnsFallback()`
- [ ] `test_generateShareContent_includesFixCount()`
- [ ] `test_generateShareContent_includesModelSeries()`
- [ ] `test_getTwitterContent_isUnder280Characters()`
- [ ] `test_getLinkedInContent_hasCorrectFormat()`
- [ ] `test_generateTrackingURL_includesSource()`

**Code Deduplication:**
```swift
// NEU: Sources/Utilities/MacBookModel.swift
struct MacBookModel {
    static func series(from identifier: String) -> String {
        // Zentralisierte Model-zu-Series Mapping Logik
    }
}
```

### Phase 4: ReviewRequestManager Tests

**File:** `Tests/ReviewRequestManagerTests.swift`

**Test Cases:**
- [ ] `test_shouldRequestReview_onFirstFix_returnsFalse()`
- [ ] `test_shouldRequestReview_atThreshold_returnsTrue()`
- [ ] `test_shouldRequestReview_afterReview_returnsFalse()`
- [ ] `test_shouldRequestReview_withinCooldown_returnsFalse()`
- [ ] `test_shouldShowReviewButton_withZeroFixes_returnsFalse()`
- [ ] `test_shouldShowReviewButton_afterThreshold_returnsTrue()`
- [ ] `test_getReviewRequestMessage_includesFixCount()`
- [ ] `test_getOptimalReviewTiming_returnsExpectedValue()`
- [ ] `test_reviewState_persistsAcrossInstances()`

**Klärung benötigt:**
- Review-Threshold: Bei welchem `fixCount` wird Review angefragt? (Annahme: 3)
- Cooldown: Wie lange nach erster Review bis zur nächsten Anfrage? (Annahme: 30 Tage)

### Phase 5: Privacy Compliance Tests

**File:** `Tests/PrivacyComplianceTests.swift`

**Test Cases:**
- [ ] `test_optOut_persistsCorrectly()`
- [ ] `test_optOut_preventsAllTracking()`
- [ ] `test_payload_neverContainsUserId()`
- [ ] `test_payload_neverContainsDeviceId()`
- [ ] `test_payload_neverContainsSerialNumber()`

### Phase 6: CI Integration

**File:** `.github/workflows/build-test.yml` (erweitern)

```yaml
- name: Run Tests with Coverage
  run: |
    cd App
    swift test --enable-code-coverage
    xcrun llvm-cov report .build/debug/TouchBarFixPackageTests.xctest/Contents/MacOS/TouchBarFixPackageTests -instr-profile .build/debug/codecov/default.profdata

- name: Check Coverage Threshold
  run: |
    COVERAGE=$(xcrun llvm-cov report ... | grep TOTAL | awk '{print $4}' | sed 's/%//')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage $COVERAGE% is below 80% threshold"
      exit 1
    fi
```

## Acceptance Criteria

### Functional Requirements
- [ ] Alle Services (AnalyticsService, SharingManager, ReviewRequestManager) haben Unit Tests
- [ ] Code Coverage erreicht mindestens 80% (Line Coverage)
- [ ] Alle Tests laufen erfolgreich in CI (macOS runner ohne Touch Bar)
- [ ] Privacy-Tests verifizieren GDPR-konformes Opt-Out Verhalten

### Non-Functional Requirements
- [ ] Tests laufen in < 30 Sekunden
- [ ] Keine flaky Tests durch ordentliches async/await Handling
- [ ] Keine externen Netzwerk-Calls in Tests (vollständig gemockt)

### Quality Gates
- [ ] Test:Source Ratio verbessert von 1:19 auf mindestens 1:4
- [ ] Branch Coverage für kritische Pfade (Error Handling) ≥ 90%
- [ ] Alle `@Published` Properties haben State-Change Tests

## Dependencies & Prerequisites

1. **Refactoring vor Tests:**
   - Dependency Injection in `AnalyticsService` (URLSession, UserDefaults)
   - Dependency Injection in `ReviewRequestManager` (UserDefaults)
   - `getModelSeries()` deduplizieren in zentrale Utility

2. **CI Requirements:**
   - GitHub Actions Runner: `macos-14` (unterstützt macOS 13+)
   - Coverage Tool: `llvm-cov` (in Xcode enthalten)

## Risk Analysis & Mitigation

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|-------------------|--------|------------|
| Async Test Flakiness | Mittel | Hoch | URLProtocol-Mocking statt echte Netzwerk-Calls |
| Coverage-Tool Unterschiede | Niedrig | Mittel | Standardisieren auf Xcode/llvm-cov |
| Refactoring Breaking Changes | Niedrig | Hoch | Backward-compatible DI mit Default-Werten |

## File Changes Summary

### New Files
- `App/Tests/AnalyticsServiceTests.swift` (~150 LOC)
- `App/Tests/SharingManagerTests.swift` (~120 LOC)
- `App/Tests/ReviewRequestManagerTests.swift` (~100 LOC)
- `App/Tests/PrivacyComplianceTests.swift` (~60 LOC)
- `App/Tests/Mocks/MockURLProtocol.swift` (~40 LOC)
- `App/Tests/Mocks/TestHelpers.swift` (~50 LOC)
- `App/Sources/Utilities/MacBookModel.swift` (~30 LOC) - Deduplizierung

### Modified Files
- `App/Sources/AnalyticsService.swift` - Add DI
- `App/Sources/ReviewRequestManager.swift` - Add DI
- `App/Sources/SharingManager.swift` - Use MacBookModel utility
- `App/Sources/ShareSuccessView.swift` - Use MacBookModel utility
- `.github/workflows/build-test.yml` - Add coverage check

## References & Research

### Internal References
- Existing tests: `/Users/floriansteiner/Documents/GitHub/touchbarfix/App/Tests/TouchBarManagerTests.swift`
- MockTouchBarManager pattern: `TouchBarManagerTests.swift:96-115`
- CI workflow: `/Users/floriansteiner/Documents/GitHub/touchbarfix/.github/workflows/build-test.yml`

### External References
- [Apple XCTest Async Documentation](https://developer.apple.com/documentation/xctest/asynchronous-tests-and-expectations)
- [URLProtocol Mocking (WWDC 2018)](https://developer.apple.com/videos/play/wwdc2018/417/)
- [Swift by Sundell - Unit Testing async/await](https://www.swiftbysundell.com/articles/unit-testing-code-that-uses-async-await/)

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
