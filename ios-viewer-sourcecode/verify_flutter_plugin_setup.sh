#!/bin/bash

echo "🔍 Verifying Flutter Plugin Texture Setup"
echo "=========================================="
echo ""

# Ask for Flutter plugin path
read -p "Enter the path to your flutter_igolf_viewer plugin directory: " PLUGIN_PATH

if [ ! -d "$PLUGIN_PATH" ]; then
    echo "❌ Directory does not exist: $PLUGIN_PATH"
    exit 1
fi

echo "📂 Plugin path: $PLUGIN_PATH"
echo ""

# Check 1: Assets directory exists
echo "✓ Checking Assets directory..."
if [ -d "$PLUGIN_PATH/ios/Assets" ]; then
    echo "  ✅ Assets directory exists"
    TEXTURE_COUNT=$(find "$PLUGIN_PATH/ios/Assets" -name "*.png" | wc -l | tr -d ' ')
    echo "  📊 Found $TEXTURE_COUNT PNG files"

    # Check for key textures
    if [ -f "$PLUGIN_PATH/ios/Assets/v3d_tree_1.png" ]; then
        echo "  ✅ v3d_tree_1.png exists"
    else
        echo "  ❌ v3d_tree_1.png NOT found"
    fi

    if [ -f "$PLUGIN_PATH/ios/Assets/v3d_background.png" ]; then
        echo "  ✅ v3d_background.png exists"
    else
        echo "  ❌ v3d_background.png NOT found"
    fi
else
    echo "  ❌ Assets directory does NOT exist"
    echo "  Create it with: mkdir -p $PLUGIN_PATH/ios/Assets"
fi
echo ""

# Check 2: Podspec configuration
echo "✓ Checking podspec..."
PODSPEC_PATH="$PLUGIN_PATH/ios/flutter_igolf_viewer.podspec"
if [ -f "$PODSPEC_PATH" ]; then
    echo "  ✅ Podspec exists"

    if grep -q "s.resources.*Assets" "$PODSPEC_PATH"; then
        echo "  ✅ Podspec contains Assets resource reference"
        grep "s.resources" "$PODSPEC_PATH" | sed 's/^/    /'
    else
        echo "  ❌ Podspec does NOT reference Assets"
        echo "  Add this line: s.resources = 'Assets/**/*.png'"
    fi
else
    echo "  ❌ Podspec not found at: $PODSPEC_PATH"
fi
echo ""

# Check 3: XCFramework exists
echo "✓ Checking xcframework..."
if [ -d "$PLUGIN_PATH/ios/IGolfViewer3D.xcframework" ]; then
    echo "  ✅ IGolfViewer3D.xcframework exists"
else
    echo "  ❌ IGolfViewer3D.xcframework NOT found"
    echo "  Copy it from: ./build/IGolfViewer3D.xcframework"
fi
echo ""

echo "=========================================="
echo "📋 Next Steps:"
echo ""
echo "1. If textures are missing from Assets/, copy them:"
echo "   cp /path/to/textures/*.png $PLUGIN_PATH/ios/Assets/"
echo ""
echo "2. If podspec needs updating, edit:"
echo "   $PODSPEC_PATH"
echo ""
echo "3. In your Flutter app, run:"
echo "   cd <flutter_app>/ios"
echo "   pod install"
echo "   cd .."
echo "   flutter clean"
echo "   flutter run"
echo ""
