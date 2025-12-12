#!/bin/bash

echo "🔍 Debugging Flutter Plugin CocoaPods Setup"
echo "============================================"
echo ""

read -p "Enter the path to your Flutter app directory: " APP_PATH
read -p "Enter the path to your flutter_igolf_viewer plugin directory: " PLUGIN_PATH

echo ""
echo "📂 Checking plugin structure..."

# Check plugin directory structure
if [ -d "$PLUGIN_PATH/ios" ]; then
    echo "✅ Plugin ios/ directory exists"

    # Check for podspec
    PODSPEC="$PLUGIN_PATH/ios/flutter_igolf_viewer.podspec"
    if [ -f "$PODSPEC" ]; then
        echo "✅ Podspec exists at: $PODSPEC"
        echo ""
        echo "📄 Podspec content (s.resources line):"
        grep "s.resources" "$PODSPEC" || echo "  ❌ No s.resources line found"
        echo ""
    else
        echo "❌ Podspec NOT found at: $PODSPEC"
    fi

    # Check for Assets directory
    if [ -d "$PLUGIN_PATH/ios/Assets" ]; then
        TEXTURE_COUNT=$(find "$PLUGIN_PATH/ios/Assets" -name "v3d_*.png" | wc -l | tr -d ' ')
        echo "✅ Assets directory exists with $TEXTURE_COUNT v3d_*.png files"
    else
        echo "❌ Assets directory NOT found at: $PLUGIN_PATH/ios/Assets"
    fi
else
    echo "❌ Plugin ios/ directory NOT found at: $PLUGIN_PATH/ios"
    exit 1
fi

echo ""
echo "📂 Checking Flutter app pubspec.yaml..."

PUBSPEC="$APP_PATH/pubspec.yaml"
if [ -f "$PUBSPEC" ]; then
    echo "✅ pubspec.yaml exists"
    echo ""
    echo "📄 Plugin dependency:"
    grep -A 2 "flutter_igolf_viewer" "$PUBSPEC" | head -3
else
    echo "❌ pubspec.yaml NOT found at: $PUBSPEC"
fi

echo ""
echo "📂 Checking if plugin is in Pods..."

if [ -d "$APP_PATH/ios/Pods" ]; then
    echo "✅ Pods directory exists"

    if [ -d "$APP_PATH/ios/Pods/flutter_igolf_viewer" ]; then
        echo "✅ flutter_igolf_viewer pod exists"

        # Check what's in the pod
        TEXTURE_COUNT=$(find "$APP_PATH/ios/Pods/flutter_igolf_viewer" -name "v3d_*.png" 2>/dev/null | wc -l | tr -d ' ')
        echo "   Found $TEXTURE_COUNT texture files in pod"
    else
        echo "❌ flutter_igolf_viewer NOT in Pods directory"
        echo "   This is the problem! CocoaPods doesn't know about your plugin."
        echo ""
        echo "   Possible causes:"
        echo "   1. Plugin is referenced with 'path:' in pubspec.yaml"
        echo "   2. .flutter-plugins or .flutter-plugins-dependencies is stale"
        echo "   3. pubspec.yaml doesn't list the plugin"
    fi
else
    echo "❌ Pods directory NOT found"
fi

echo ""
echo "================================================"
echo "🔧 Recommended fix:"
echo ""
echo "1. In your Flutter app's pubspec.yaml, ensure the plugin is listed:"
echo "   dependencies:"
echo "     flutter_igolf_viewer:"
echo "       path: ../path/to/flutter_igolf_viewer"
echo ""
echo "2. Run these commands in your Flutter app directory:"
echo "   cd $APP_PATH"
echo "   flutter pub get"
echo "   cd ios"
echo "   rm -rf Pods Podfile.lock .symlinks"
echo "   pod install"
echo "   cd .."
echo "   flutter clean"
echo ""
