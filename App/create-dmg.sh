#!/bin/bash

# DMG Creation Script for TouchBarFix
set -e

APP_NAME="TouchBarFix"
DMG_NAME="TouchBarFix-1.2.1"
RELEASE_DIR="Release"
APP_BUNDLE="$RELEASE_DIR/$APP_NAME.app"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📀 Creating DMG installer..."

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo -e "${RED}❌ App bundle not found. Run ./build-app.sh first.${NC}"
    exit 1
fi

# Create temporary DMG directory
DMG_DIR="$RELEASE_DIR/dmg"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
cp -R "$APP_BUNDLE" "$DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$DMG_DIR/Applications"

# Create README file
cat > "$DMG_DIR/README.txt" << EOF
TouchBarFix v1.2.1
==========================

Installation:
1. Drag "TouchBarFix" to your Applications folder
2. Launch from Applications or Spotlight
3. The app will appear in your menu bar

Usage:
- Click the menu bar icon
- Click "Restart Touch Bar" when your Touch Bar is unresponsive

Requirements:
- macOS 13.0 or later
- MacBook Pro with Touch Bar (2016-2021 models)

Support:
Visit https://github.com/ProduktEntdecker/touchbarfix

© 2024 ProduktEntdecker
EOF

# Create DMG
echo "🔨 Building DMG..."
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$RELEASE_DIR/$DMG_NAME.dmg"

# Clean up
rm -rf "$DMG_DIR"

# Sign the DMG if possible
if command -v codesign &> /dev/null; then
    IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | awk -F'"' '{print $2}')
    
    if [ -n "$IDENTITY" ]; then
        echo "🔐 Signing DMG..."
        codesign --force --sign "$IDENTITY" "$RELEASE_DIR/$DMG_NAME.dmg"
        echo -e "${GREEN}✅ DMG signed${NC}"
    fi
fi

# Verify DMG
if [ -f "$RELEASE_DIR/$DMG_NAME.dmg" ]; then
    DMG_SIZE=$(du -h "$RELEASE_DIR/$DMG_NAME.dmg" | cut -f1)
    echo -e "${GREEN}✅ DMG created successfully!${NC}"
    echo ""
    echo "📦 File: $RELEASE_DIR/$DMG_NAME.dmg"
    echo "📏 Size: $DMG_SIZE"
    echo ""
    echo "Next steps:"
    echo "1. Test installation from DMG"
    echo "2. Notarize for distribution:"
    echo "   xcrun notarytool submit $RELEASE_DIR/$DMG_NAME.dmg --apple-id YOUR_APPLE_ID --password YOUR_APP_PASSWORD --team-id YOUR_TEAM_ID"
    echo "3. Staple the notarization:"
    echo "   xcrun stapler staple $RELEASE_DIR/$DMG_NAME.dmg"
else
    echo -e "${RED}❌ DMG creation failed!${NC}"
    exit 1
fi