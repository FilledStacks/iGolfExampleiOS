#!/bin/bash

echo "🔍 Verifying CocoaPods Plugin Installation"
echo "==========================================="
echo ""

read -p "Enter the path to your Flutter app directory: " APP_PATH

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Directory does not exist: $APP_PATH"
    exit 1
fi

cd "$APP_PATH/ios" || exit 1

echo "📂 Checking: $(pwd)"
echo ""

# Check 1: Pod directory exists
echo "1️⃣ Checking if plugin pod directory exists..."
if [ -d "Pods/flutter_igolf_viewer" ]; then
    echo "✅ Plugin pod directory exists"

    # List what's in it
    echo ""
    echo "📦 Contents of pod:"
    ls -la "Pods/flutter_igolf_viewer/" | head -20
else
    echo "❌ Plugin pod directory NOT found at: Pods/flutter_igolf_viewer"
    echo ""
    echo "This means CocoaPods didn't install the plugin!"
    echo ""
    echo "Check:"
    echo "  1. Does the plugin have source files in Classes/?"
    echo "  2. Does the podspec have s.source_files = 'Classes/**/*'?"
    echo "  3. Does the podspec have s.public_header_files = 'Classes/**/*.h'?"
    exit 1
fi
echo ""

# Check 2: XCFramework copied
echo "2️⃣ Checking if xcframework was copied..."
if [ -d "Pods/flutter_igolf_viewer/IGolfViewer3D.xcframework" ]; then
    echo "✅ XCFramework exists in pod"
else
    echo "❌ XCFramework NOT found in pod"
fi
echo ""

# Check 3: Textures copied
echo "3️⃣ Checking if texture assets were copied..."
TEXTURE_COUNT=$(find "Pods/flutter_igolf_viewer" -name "v3d_*.png" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TEXTURE_COUNT" -gt 0 ]; then
    echo "✅ Found $TEXTURE_COUNT texture files in pod"
    echo ""
    echo "Sample textures:"
    find "Pods/flutter_igolf_viewer" -name "v3d_tree_*.png" 2>/dev/null | head -5
else
    echo "❌ No texture files found in pod"
    echo ""
    echo "Textures should be at: flutter_igolf_viewer/ios/Assets/*.png"
    echo "And podspec should have: s.resources = 'Assets/**/*.png'"
fi
echo ""

# Check 4: Resource script
echo "4️⃣ Checking resource copy script..."
RESOURCE_SCRIPT="Pods/Target Support Files/Pods-Runner/Pods-Runner-resources.sh"
if [ -f "$RESOURCE_SCRIPT" ]; then
    echo "✅ Resource script exists"

    if grep -q "flutter_igolf_viewer" "$RESOURCE_SCRIPT"; then
        echo "✅ Script mentions flutter_igolf_viewer"

        PNG_COUNT=$(grep -c "\.png" "$RESOURCE_SCRIPT" 2>/dev/null || echo "0")
        if [ "$PNG_COUNT" -gt 0 ]; then
            echo "✅ Script will copy $PNG_COUNT PNG files"
            echo ""
            echo "Sample PNG references:"
            grep "\.png" "$RESOURCE_SCRIPT" | head -3
        else
            echo "❌ Script has NO PNG references"
        fi
    else
        echo "❌ Script does NOT mention flutter_igolf_viewer"
    fi
else
    echo "❌ Resource script not found"
fi
echo ""

# Check 5: Podfile.lock
echo "5️⃣ Checking Podfile.lock..."
if [ -f "Podfile.lock" ]; then
    if grep -q "flutter_igolf_viewer" "Podfile.lock"; then
        echo "✅ flutter_igolf_viewer is in Podfile.lock"
        echo ""
        echo "Version info:"
        grep -A 3 "flutter_igolf_viewer" "Podfile.lock" | head -5
    else
        echo "❌ flutter_igolf_viewer NOT in Podfile.lock"
    fi
else
    echo "❌ Podfile.lock not found - run 'pod install' first"
fi
echo ""

echo "==========================================="
echo "📋 Summary:"
echo ""

if [ -d "Pods/flutter_igolf_viewer" ] && [ "$TEXTURE_COUNT" -gt 0 ]; then
    echo "✅ Plugin installation looks GOOD!"
    echo ""
    echo "Next steps:"
    echo "  1. Run: flutter clean"
    echo "  2. Run: flutter run"
    echo "  3. Check logs for texture loading"
else
    echo "❌ Plugin installation has ISSUES"
    echo ""
    echo "To fix:"
    echo "  1. Ensure plugin has Classes/ directory with plugin files"
    echo "  2. Ensure plugin has Assets/ directory with PNG files"
    echo "  3. Update podspec with:"
    echo "     s.source_files = 'Classes/**/*'"
    echo "     s.public_header_files = 'Classes/**/*.h'"
    echo "     s.resources = 'Assets/**/*.png'"
    echo "  4. Run: cd ios && rm -rf Pods Podfile.lock && pod install"
fi
echo ""
