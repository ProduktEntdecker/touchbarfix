# Release & Notarization Guide

Last updated: 2025-08-20

## Version Bump
1. Update `App/Resources/Info.plist`:
   - `CFBundleShortVersionString`
   - `CFBundleVersion`
2. Update scripts displaying version if needed (e.g., `create-dmg.sh`).

## Build Universal App Bundle
```bash
cd App
./build-app.sh
```

## Create DMG Installer
```bash
./create-dmg.sh
```

## Code Signing (if not already signed by build script)
```bash
IDENTITY="Developer ID Application: Your Name"
codesign --deep --force --verify --verbose \
  --entitlements Resources/TouchBarFix.entitlements \
  --options runtime \
  --sign "$IDENTITY" Release/TouchBarFix.app
```

## Notarization
```bash
# Create zip for submission
ditto -c -k --keepParent Release/TouchBarFix.app TouchBarFix.zip

# Submit and wait for result
xcrun notarytool submit TouchBarFix.zip \
  --apple-id YOUR_APPLE_ID \
  --password APP_SPECIFIC_PASSWORD \
  --team-id YOUR_TEAM_ID \
  --wait

# Staple result to the app and DMG
xcrun stapler staple Release/TouchBarFix.app
xcrun stapler validate Release/TouchBarFix.app
xcrun stapler staple Release/TouchBarFix-<VERSION>.dmg
```

## Checksums
```bash
shasum -a 256 Release/TouchBarFix-<VERSION>.dmg > Release/TouchBarFix-<VERSION>.dmg.sha256
```

## GitHub Release
1. Tag the release: `git tag v<version> && git push origin v<version>`
2. Use the release workflow to build/upload DMG
3. Include release notes, checksum, and notarization status

## Post-Release
- Update website download links if needed
- Smoke test on Intel and Apple Silicon
- Monitor crash logs/support inbox

