#!/bin/bash

# TouchBarFix App Bundle Build Script
# This script builds a proper .app bundle for distribution

set -e

echo "🔨 Building TouchBarFix App Bundle..."

# Configuration
APP_NAME="TouchBarFix"
BUNDLE_ID="com.produktentdecker.touchbarfix"
# Informational only — the actual bundle version comes from Resources/Info.plist,
# which is copied verbatim below. Keep this in sync manually when bumping releases.
VERSION="1.5.1"
BUILD_DIR=".build"
RELEASE_DIR="Release"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$RELEASE_DIR"
swift package clean

# Build universal binary for both Intel and Apple Silicon
echo "🏗️ Building universal binary..."

# Build for Apple Silicon (arm64)
echo "  📱 Building for Apple Silicon (arm64)..."
swift build -c release --arch arm64

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ ARM64 build failed!${NC}"
    exit 1
fi

# Build for Intel (x86_64)
echo "  💻 Building for Intel (x86_64)..."
swift build -c release --arch x86_64

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ x86_64 build failed!${NC}"
    exit 1
fi

# Create universal binary using lipo
echo "  🔗 Creating universal binary..."
ARM64_BINARY="$BUILD_DIR/arm64-apple-macosx/release/TouchBarFix"
X86_64_BINARY="$BUILD_DIR/x86_64-apple-macosx/release/TouchBarFix"
UNIVERSAL_BINARY="$BUILD_DIR/universal-TouchBarFix"

lipo -create "$ARM64_BINARY" "$X86_64_BINARY" -output "$UNIVERSAL_BINARY"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to create universal binary!${NC}"
    exit 1
fi

# Verify universal binary
echo "  🔍 Verifying universal binary..."
lipo -info "$UNIVERSAL_BINARY"

# Create app bundle structure
echo "📦 Creating app bundle..."
APP_BUNDLE="$RELEASE_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy universal executable
cp "$UNIVERSAL_BINARY" "$APP_BUNDLE/Contents/MacOS/TouchBarFix"

# Copy Info.plist
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/"

# Copy entitlements (for reference during signing)
cp "Resources/TouchBarFix.entitlements" "$RELEASE_DIR/"

# Copy app icon
echo "🎨 Adding app icon..."
if [ -f "../Assets/AppIcon.icns" ]; then
    cp "../Assets/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
    echo "✅ App icon copied from Assets directory"
else
    echo "⚠️ AppIcon.icns not found in Assets directory, creating placeholder"
    touch "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# Sign the app (requires Apple Developer ID)
if command -v codesign &> /dev/null; then
    echo "🔐 Signing app..."
    
    # Check for signing identity
    IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | awk -F'"' '{print $2}')
    
    if [ -n "$IDENTITY" ]; then
        codesign --force --deep --sign "$IDENTITY" \
            --entitlements "Resources/TouchBarFix.entitlements" \
            --options runtime \
            "$APP_BUNDLE"
        
        echo -e "${GREEN}✅ App signed with: $IDENTITY${NC}"
    else
        echo -e "${YELLOW}⚠️ No Developer ID found. App will not be signed.${NC}"
        echo "   To sign the app, you need an Apple Developer account."
    fi
else
    echo -e "${YELLOW}⚠️ codesign not found. App will not be signed.${NC}"
fi

# Verify the app bundle
echo "🔍 Verifying app bundle..."
if [ -f "$APP_BUNDLE/Contents/MacOS/TouchBarFix" ]; then
    echo -e "${GREEN}✅ App bundle created successfully!${NC}"
    echo ""
    echo "📍 Location: $APP_BUNDLE"
    echo ""
    echo "Next steps:"
    echo "1. Test the app: open '$APP_BUNDLE'"
    echo "2. Create DMG: ./create-dmg.sh"
    echo "3. Notarize: xcrun notarytool submit ..."
else
    echo -e "${RED}❌ App bundle creation failed!${NC}"
    exit 1
fi

# Run tests
echo ""
echo "🧪 Running tests..."
swift test

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${YELLOW}⚠️ Some tests failed. Check the output above.${NC}"
fi

echo ""
echo "🎉 Build complete!"