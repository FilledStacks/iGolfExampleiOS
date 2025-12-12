#!/bin/bash

echo "🔍 Checking if textures were copied by CocoaPods"
echo "================================================"
echo ""

# Ask for Flutter app path
read -p "Enter the path to your Flutter app directory: " APP_PATH

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Directory does not exist: $APP_PATH"
    exit 1
fi

echo "📂 App path: $APP_PATH"
echo ""

# Check 1: Look in DerivedData for the built app
echo "✓ Looking for built app bundle with textures..."
APP_BUNDLE=$(find ~/Library/Developer/Xcode/DerivedData -name "Runner.app" -type d 2>/dev/null | head -1)

if [ -n "$APP_BUNDLE" ]; then
    echo "  📦 Found app bundle: $APP_BUNDLE"

    # Check for textures in the app bundle
    TEXTURE_COUNT=$(find "$APP_BUNDLE" -name "v3d_*.png" 2>/dev/null | wc -l | tr -d ' ')
    echo "  📊 Found $TEXTURE_COUNT v3d_*.png files in app bundle"

    if [ "$TEXTURE_COUNT" -gt 0 ]; then
        echo "  ✅ Textures ARE in the app bundle!"
        echo ""
        echo "  Sample files:"
        find "$APP_BUNDLE" -name "v3d_tree_*.png" 2>/dev/null | head -5 | sed 's/^/    /'
    else
        echo "  ❌ No v3d_*.png textures found in app bundle"
        echo "  This means CocoaPods didn't copy them"
    fi
else
    echo "  ⚠️  No built app bundle found in DerivedData"
    echo "  You may need to build the app first: flutter build ios"
fi
echo ""

# Check 2: Look in Pods directory
echo "✓ Checking Pods directory..."
PODS_DIR="$APP_PATH/ios/Pods/flutter_igolf_viewer"

if [ -d "$PODS_DIR" ]; then
    echo "  ✅ Plugin pod directory exists"

    TEXTURE_COUNT=$(find "$PODS_DIR" -name "v3d_*.png" 2>/dev/null | wc -l | tr -d ' ')
    echo "  📊 Found $TEXTURE_COUNT v3d_*.png files in pod"

    if [ "$TEXTURE_COUNT" -gt 0 ]; then
        echo "  ✅ Textures are in the pod!"
        echo ""
        echo "  Sample files:"
        find "$PODS_DIR" -name "v3d_tree_*.png" 2>/dev/null | head -5 | sed 's/^/    /'
    else
        echo "  ❌ No v3d_*.png textures found in pod"
    fi
else
    echo "  ❌ Plugin pod directory not found at: $PODS_DIR"
fi
echo ""

# Check 3: Examine the resource script
echo "✓ Checking CocoaPods resource copy script..."
RESOURCE_SCRIPT="$APP_PATH/ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-resources.sh"

if [ -f "$RESOURCE_SCRIPT" ]; then
    echo "  ✅ Resource script exists"

    if grep -q "flutter_igolf_viewer" "$RESOURCE_SCRIPT"; then
        echo "  ✅ Script mentions flutter_igolf_viewer"

        if grep -q "\.png" "$RESOURCE_SCRIPT"; then
            echo "  ✅ Script has PNG file references"
            echo ""
            echo "  PNG references in script:"
            grep "\.png" "$RESOURCE_SCRIPT" | head -5 | sed 's/^/    /'
        else
            echo "  ❌ Script has NO PNG file references"
            echo "  This means s.resources might not be configured correctly"
        fi
    else
        echo "  ❌ Script does NOT mention flutter_igolf_viewer"
    fi
else
    echo "  ❌ Resource script not found"
fi
echo ""

echo "================================================"
echo "📋 Diagnosis:"
echo ""

if [ "$TEXTURE_COUNT" -gt 0 ]; then
    echo "✅ Textures are present and should be accessible"
    echo ""
    echo "If the app still can't find them, the issue might be:"
    echo "  1. Need to do a clean build: flutter clean && flutter run"
    echo "  2. Building for wrong architecture (simulator vs device)"
else
    echo "❌ Textures are NOT being copied by CocoaPods"
    echo ""
    echo "To fix:"
    echo "  1. Verify podspec has: s.resources = 'Assets/**/*.png'"
    echo "  2. Verify textures are at: flutter_igolf_viewer/ios/Assets/*.png"
    echo "  3. Run: cd ios && pod install && cd .."
    echo "  4. Run: flutter clean && flutter run"
fi
echo ""
