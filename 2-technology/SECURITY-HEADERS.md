# Security Headers and CSP

Last updated: 2025-08-20

This document tracks HTTP security headers for touchbarfix.com and the Content Security Policy (CSP).

## Current (configured in `vercel.json`)
- X-Robots-Tag (for private routes): `noindex, nofollow`
- Download headers on `/downloads/*`: `Content-Type: application/octet-stream`, `Content-Disposition: attachment`
- Long-lived caching on icons: `Cache-Control: public, max-age=31536000, immutable`

## Recommended Headers (to add)
- Strict-Transport-Security: `max-age=31536000; includeSubDomains; preload`
- X-Content-Type-Options: `nosniff`
- Referrer-Policy: `no-referrer`
- Permissions-Policy: `camera=(), microphone=(), geolocation=()`
- Content-Security-Policy (see below)

## CSP (proposed)
```
Content-Security-Policy:
  default-src 'self';
  img-src 'self' data:;
  script-src 'self' https://plausible.io;
  style-src 'self' 'unsafe-inline';
  connect-src 'self' https://plausible.io;
  frame-ancestors 'none';
```

Notes
- Start with `Report-Only` to tune, then enforce.
- If additional third-party resources are added, update the CSP accordingly.

