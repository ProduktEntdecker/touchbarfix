#!/bin/bash

# Touch Bar Restarter Build Script
echo "🔨 Building Touch Bar Restarter..."

# Clean previous build
echo "🧹 Cleaning previous build..."
swift package clean

# Build the project
echo "🏗️ Building project..."
swift build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🚀 To run the app:"
    echo "   swift run"
    echo ""
    echo "📦 To create a release build:"
    echo "   swift build -c release"
    echo ""
    echo "🔍 To run tests:"
    echo "   swift test"
else
    echo "❌ Build failed!"
    exit 1
fi
