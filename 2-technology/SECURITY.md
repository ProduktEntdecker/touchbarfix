# Security Policy

This document provides a public, high‑level overview of our security posture and how to report vulnerabilities. It intentionally avoids sensitive implementation details.

## Supported Versions
- TouchBarFix app: latest public release
- Website and serverless endpoints: latest production deployment

## Reporting a Vulnerability
- Email: security@touchbarfix.com (or florian.steiner@mac.com)
- Please include: affected component, version/URL, reproduction steps, impact, and any logs/screenshots
- We acknowledge within 3 business days and aim to provide a fix or mitigation timeline within 7 business days

## Data Handling
- Minimal data collection; no sensitive personal data is required to use the app
- Any email collection requires explicit user action and consent
- We strive to avoid logging personally identifiable information (PII) in production

## Security Practices
- Signed and (where applicable) notarized macOS binaries
- Principle of least privilege for app entitlements
- Input validation and origin restrictions for serverless endpoints
- Defense‑in‑depth via HTTP security headers and strict CSP (where supported)
- CI builds on macOS runners; releases published via GitHub Releases

## Known Risks (Public Summary)
- Strict access controls are applied to internal/admin routes; we periodically review to ensure they are not exposed publicly
- Serverless endpoints implement input validation, rate limiting, and origin/CORS restrictions
- Distribution artifacts are built and released through a controlled CI pipeline; repository‑stored binaries are avoided

## User Guidance
- Download only from the official website or GitHub Releases
- Verify macOS Gatekeeper warnings and proceed only if the app is signed/notarized
- Report any suspicious downloads, certificates, or app behavior

## Disclosure Policy
- We follow coordinated disclosure. Please do not publicly disclose issues before we release a fix or provide an advisory

## Hall of Fame
- We credit reporters upon request after a fix/advisory is published

## Notes
- A detailed internal security audit exists and is reviewed periodically. This public document is a summary and omits exploitable details.
