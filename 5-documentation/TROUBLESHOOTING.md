# Troubleshooting

Last updated: 2025-08-20

## Website
- 404 on pages: Ensure `vercel.json` is deployed; `/` rewrites to `/index.html`.
- SSL not working: Verify domain DNS in Vercel; wait for propagation.
- Icons not showing: Confirm `/favicon.ico` and `/apple-touch-icon.png` rewrites and caching headers.

## Download/Install
- Gatekeeper warning (“unidentified developer”): Right-click app → Open → Open. Prefer Developer ID signed + notarized builds.
- DMG won’t open: Re-download and verify SHA-256 checksum.

## App Usage
- App won’t launch: Check macOS version meets minimum; look at Console logs.
- Touch Bar not fixed:
  - Try again; wait ~2 seconds between attempts
  - If persistent, it may be a hardware issue; contact Apple support
- Dock restarts unexpectedly: The app may refresh Dock after preference resets; you can disable/reset less aggressively in future versions.

## Email
- Didn’t receive download email: Check spam; use direct download button; ensure email was entered correctly.

## Contact
- support@touchbarfix.com or florian.steiner@mac.com

