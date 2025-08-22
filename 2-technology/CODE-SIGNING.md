# Code Signing & Entitlements

Last updated: 2025-08-20

## Distribution Model
- Direct distribution (outside Mac App Store). App Store is not feasible due to required process control.
- Use Developer ID Application certificate and notarization for a smooth first run on macOS.

## Entitlements (Resources/TouchBarFix.entitlements)
- App sandbox: disabled (requires system-level process control)
- Limited temporary mach-lookup exceptions for Touch Bar components
- Keep entitlements minimal and documented; review each release

## Signing
```bash
IDENTITY="Developer ID Application: Your Name"
codesign --deep --force --verify --verbose \
  --entitlements Resources/TouchBarFix.entitlements \
  --options runtime \
  --sign "$IDENTITY" Release/TouchBarFix.app
codesign --verify --deep --strict --verbose=2 Release/TouchBarFix.app
spctl -a -t exec -vv Release/TouchBarFix.app
```

## Notarization
```bash
# Zip and submit
 ditto -c -k --keepParent Release/TouchBarFix.app TouchBarFix.zip
 xcrun notarytool submit TouchBarFix.zip --apple-id <ID> --password <APP_PW> --team-id <TEAM> --wait
 xcrun stapler staple Release/TouchBarFix.app
 xcrun stapler validate Release/TouchBarFix.app
```

## Tips
- Ensure all nested binaries are signed (`--deep`).
- Hardened runtime (`--options runtime`) required for notarization.
- Verify signatures with `codesign --verify` and Gatekeeper with `spctl`.
- Keep certificates secure; rotate if compromised.

