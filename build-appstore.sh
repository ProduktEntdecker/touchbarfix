#!/bin/bash

# Build script for App Store version of TouchBarFix
# This creates a sandboxed version compatible with App Store requirements

set -e

echo "🏗️ Building TouchBarFix for App Store..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to App directory
cd App

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf TouchBarFix.app

# Use App Store compatible manager
echo "📝 Switching to App Store compatible code..."
if [ -f Sources/TouchBarManager.swift ]; then
    mv Sources/TouchBarManager.swift Sources/TouchBarManager.original.swift
fi
cp Sources/TouchBarManagerAppStore.swift Sources/TouchBarManager.swift

# Build the app
echo "🔨 Building App Store version..."
swift build -c release --arch arm64 --arch x86_64

# Create app bundle
echo "📦 Creating app bundle..."
mkdir -p TouchBarFix.app/Contents/MacOS
mkdir -p TouchBarFix.app/Contents/Resources

# Copy executable
cp .build/apple/Products/Release/TouchBarFix TouchBarFix.app/Contents/MacOS/

# Copy Info.plist
cp Resources/Info.plist TouchBarFix.app/Contents/

# Copy icon
if [ -f ../Assets/AppIcon.icns ]; then
    cp ../Assets/AppIcon.icns TouchBarFix.app/Contents/Resources/
fi

# Use App Store entitlements
cp Resources/TouchBarFixAppStore.entitlements TouchBarFix.app/Contents/Resources/

# Sign the app with App Store certificate
echo "🔏 Signing for App Store..."
IDENTITY="Developer ID Application: FLORIAN MICHAEL STEINER (D3SM7HA325)"

# For App Store, we need to use "3rd Party Mac Developer Application" certificate
# Check if App Store certificate exists
if security find-identity -v -p codesigning | grep -q "3rd Party Mac Developer Application"; then
    IDENTITY=$(security find-identity -v -p codesigning | grep "3rd Party Mac Developer Application" | head -1 | awk '{print $2}')
    echo "Using App Store certificate: $IDENTITY"
else
    echo -e "${YELLOW}⚠️ Warning: No App Store certificate found. Using Developer ID for testing.${NC}"
    echo "To submit to App Store, you need a '3rd Party Mac Developer Application' certificate."
fi

codesign --force --deep --sign "$IDENTITY" \
    --entitlements Resources/TouchBarFixAppStore.entitlements \
    --options runtime \
    TouchBarFix.app

# Verify signature
echo "✅ Verifying signature..."
codesign --verify --deep --strict --verbose=2 TouchBarFix.app

# Check entitlements
echo "🔍 Checking entitlements..."
codesign -d --entitlements - TouchBarFix.app

# Restore original manager file
if [ -f Sources/TouchBarManager.original.swift ]; then
    mv Sources/TouchBarManager.original.swift Sources/TouchBarManager.swift
fi

echo -e "${GREEN}✅ App Store build complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open TouchBarFix.app in Xcode"
echo "2. Select Product > Archive"
echo "3. Validate the archive"
echo "4. Upload to App Store Connect"
echo ""
echo "App location: $(pwd)/TouchBarFix.app"