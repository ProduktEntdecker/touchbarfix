# SECURITY AUDIT – TouchBarFix

Date: 2025-08-20

## Overview
- Scope: macOS app (Swift), website (static), serverless API (Vercel), CI/CD (GitHub Actions), release artifacts (DMG).
- Method: Static code/config review and build/deploy review based on repository contents at audit time.

## Risk Summary
- Overall posture: Medium pre-launch risk due to exposed/internal endpoints, weak API controls, missing legal/compliance UX, and distribution hygiene issues.
- Highest risks: Public “admin” artifact exposure, hardcoded API key, permissive CORS/validation, lack of persistent compliant email storage.

## Severity Definitions
- Critical: Can cause compromise of user data, system, or distribution trust; exploit likely.
- High: Material security/privacy/legal risk; must be fixed before launch.
- Medium: Not immediately exploitable but degrades security or reliability.
- Low: Hygiene and best practices.

## Top Findings

### 1) Public admin artifact exposed (High)
- Details: `emails-to-send.html` is a public “operations” page with instructions and local email handling.
- Impact: Leaks internal operations context and encourages non-compliant handling of emails.
- Fix: Exclude from deploy or explicitly block via `vercel.json` redirect to `404.html`.

### 2) Hardcoded API access key (High)
- Details: `api/get-emails.js` uses a static query key (`?key=touchbar2025`).
- Impact: Guessable/discoverable key enables probing; promotes insecure pattern.
- Fix: Remove endpoint or require proper authentication (admin auth + secret via env) and persistent storage.

### 3) Permissive CORS and weak validation (High)
- Details: `api/capture-email.js` sets `Access-Control-Allow-Origin: *`, minimal email validation, logs PII.
- Impact: Cross-origin abuse, spam, and PII exposure in logs; legal/privacy concerns.
- Fix: Restrict CORS to `https://touchbarfix.com`, add strict validation/size limits, sanitize inputs, remove PII from logs, add rate limiting.

### 4) No persistent, compliant email storage (High)
- Details: `api/capture-email.js` returns success but does not store emails.
- Impact: False UX, data loss, non-compliance (no consent logs, no double opt-in).
- Fix: Use Vercel KV/Postgres; store timestamps, consent, source; send double opt-in via Resend/Postmark/SES.

### 5) Missing Privacy/Terms and explicit consent (High)
- Details: Email collection modal in `index.html` lacks privacy/terms links and explicit consent.
- Impact: GDPR/ePrivacy risk.
- Fix: Add `/privacy`, `/terms`, and explicit consent checkbox.

### 6) Missing security headers (Medium-High)
- Details: No CSP/HSTS/X-Content-Type-Options/Referrer-Policy/Permissions-Policy.
- Impact: Increased clickjacking/XSS/metadata risks.
- Fix: Add headers via `vercel.json`: CSP, HSTS, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, and frame-ancestors.

### 7) Artifact hygiene: DMGs/binaries in repo (Medium)
- Details: `TouchBarFix-1.2.1.dmg` at root and in `downloads/`; `tailwindcss-macos-arm64` committed.
- Impact: Repo bloat, outdated binaries, supply-chain risk.
- Fix: Publish via GitHub Releases or object storage. Remove binaries from repo. Use npm `tailwindcss`.

### 8) Inconsistent download links (Medium)
- Details: `index.html` references both `/downloads/TouchBarFix-1.2.1.dmg` and `/TouchBarFix-1.2.1.dmg`.
- Impact: Broken links/confusion.
- Fix: Single canonical path; publish checksums on the download page.

### 9) Entitlements and sandbox settings (Medium)
- Details: `App/Resources/TouchBarFix.entitlements` is non-sandboxed with broad mach-lookup exceptions.
- Impact: Required for functionality but disqualifies MAS; needs clear distribution stance and minimal permissions.
- Fix: Document non-MAS distribution; tighten entitlements to minimal set.

### 10) UI behavior mismatch: LSUIElement vs regular window (Medium)
- Details: `Info.plist` sets `LSUIElement=true` while `main.swift` shows a normal window and sets `.regular`.
- Impact: UX inconsistencies; potential confusion.
- Fix: Decide status-bar agent vs regular app and align settings.

### 11) Platform version mismatch (Medium)
- Details: `Package.swift` targets macOS 13; `Info.plist` minimum is 11.0.
- Impact: Install/build/runtime expectations mismatch.
- Fix: Align targets across both files.

### 12) Aggressive system changes without confirmation (Medium)
- Details: `resetTouchBarPreferences()` deletes preference domains and restarts Dock.
- Impact: Surprising behavior; possible loss of user settings.
- Fix: Add explicit confirmation; make it a last-resort option.

### 13) DevOps script mutates global git config (Low-Medium)
- Details: `scripts/setup-devops.sh` sets global aliases/config.
- Impact: Side effects on contributors.
- Fix: Scope to repo or document risks; prompt clearly.

### 14) Analytics without CSP tightening (Low)
- Details: Plausible loaded; CSP absent.
- Impact: Expands XSS surface.
- Fix: Add strict CSP allowing only plausible.io and self.

## Prioritized Remediation (Pre-Launch)
1. Secure email pipeline (High)
   - Restrict CORS, validate/sanitize inputs, remove PII logs, implement rate limiting.
   - Add persistent storage and double opt-in.
   - Remove/lock down `api/get-emails.js` behind proper auth.
2. Remove/admin-block internal artifacts (High)
   - Ensure `emails-to-send.html` is not deployed; add `vercel.json` redirect to `404.html`.
3. Add security headers (High)
   - Add CSP, HSTS, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, frame-ancestors.
4. Legal/compliance UX (High)
   - Create `/privacy` and `/terms`; require explicit consent in email modal with links.
5. Distribution hygiene (Medium)
   - Remove DMGs/3rd-party binaries from repo; publish via GitHub Releases; unify download URL; publish checksums.
6. App hardening & UX alignment (Medium)
   - Decide LSUIElement vs regular app; align macOS target versions.
   - Confirm before resetting preferences/restarting Dock; tighten entitlements.
7. Supply-chain and build (Medium)
   - Use npm `tailwindcss` CLI; add `build` script; pin versions; rely on lockfiles.
8. CI/CD (Medium)
   - Build universal binary, sign/notarize, validate stapling, upload to GitHub Releases; stop committing artifacts.

## Defense-in-Depth
- Use environment variables (Vercel) for secrets/admin endpoints; enable rotation.
- Consider Upstash Redis for rate limiting; add bot defenses on API endpoints.
- Structured logging without PII; alert on abuse patterns.
- Publish SHA-256 checksums and show on download page; verify notarization in CI.
- Start CSP in report-only mode to tune policies before enforcing.

## Notable Strengths
- Swift app uses exact-name process checks and `Process.executableURL`.
- Allowed process whitelist reduces injection risk.
- CI on macOS runners builds/tests app; release workflow scripted.
- `vercel.json` already blocks several internal paths and maps `/App` to 404.

## Files Reviewed
- Web: `index.html`, `download/index.html`, `robots.txt`, `404.html`, `dist/tailwind.css`
- API: `api/capture-email.js`, `api/get-emails.js`, `vercel.json`
- App: `App/Sources/*`, `App/Resources/*`, `App/Package.swift`, tests
- Build: `App/build.sh`, `App/build-app.sh`, `App/create-dmg.sh`
- CI: `.github/workflows/*.yml`
- Assets/Artifacts: `TouchBarFix-1.2.1.dmg`, `downloads/TouchBarFix-1.2.1.dmg`, `tailwindcss-macos-arm64`
- Docs: `docs/*.md`, `emails-to-send.html`, `README.md`

## Next Steps
- Track remediation items in issues with owners and dates.
- Add a short security review gate to the release checklist.
- Re-run this audit after changes and before launch to verify closure of high/medium items.

