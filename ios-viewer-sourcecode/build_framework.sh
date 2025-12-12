#!/bin/bash

# IGolfViewer3D Framework Build Script
# This script builds the framework and creates an xcframework for distribution

set -e  # Exit on error

echo ""
echo "🚀 =========================================="
echo "🚀 Building IGolfViewer3D Framework"
echo "🚀 =========================================="
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf ./build
xcodebuild clean -project IGolfViewer3D.xcodeproj -scheme IGolfViewer3D-Enterprise -configuration Standard-Release > /dev/null 2>&1
echo "✅ Clean completed"
echo ""

# Build the framework
echo "🔨 Building framework (this may take a minute)..."
xcodebuild build \
  -project IGolfViewer3D.xcodeproj \
  -scheme IGolfViewer3D-Enterprise \
  -configuration Standard-Release \
  -sdk iphoneos \
  -arch arm64 \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  > /tmp/xcodebuild.log 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Framework build succeeded"
else
    echo "❌ Framework build failed! Check /tmp/xcodebuild.log for details"
    exit 1
fi
echo ""

# Create xcframework
echo "📦 Creating xcframework..."
mkdir -p ./build
xcodebuild -create-xcframework \
  -framework /Users/danemackier/Library/Developer/Xcode/DerivedData/IGolfViewer3D-eefpxmdgljdwlxaggekrzbkyopmc/Build/Products/Standard-Release-iphoneos/IGolfViewer3D.framework \
  -output ./build/IGolfViewer3D.xcframework \
  > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ XCFramework created successfully"
else
    echo "❌ XCFramework creation failed!"
    exit 1
fi
echo ""

# Get the full path
FRAMEWORK_PATH="$(pwd)/build/IGolfViewer3D.xcframework"

echo "🎉 =========================================="
echo "🎉 Build Complete!"
echo "🎉 =========================================="
echo ""
echo "📍 Framework location:"
echo "   $FRAMEWORK_PATH"
echo ""
echo "📋 Next steps:"
echo "   1. Copy the framework to your Flutter plugin:"
echo "      cp -R ./build/IGolfViewer3D.xcframework /path/to/flutter_igolf_viewer/ios/"
echo ""
echo "   2. Or manually copy from:"
echo "      ./build/IGolfViewer3D.xcframework"
echo "      → flutter_igolf_viewer/ios/"
echo ""
echo "✨ Framework is ready to use!"
echo ""
