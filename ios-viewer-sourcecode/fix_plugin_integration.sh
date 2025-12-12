#!/bin/bash

echo "🔧 Fixing Flutter Plugin Integration"
echo "====================================="
echo ""

read -p "Enter the path to your Flutter app directory: " APP_PATH

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Directory does not exist: $APP_PATH"
    exit 1
fi

cd "$APP_PATH" || exit 1

echo "📂 Working in: $(pwd)"
echo ""

# Step 1: Clean Flutter cache
echo "1️⃣ Cleaning Flutter cache..."
flutter clean
echo "✅ Flutter cache cleaned"
echo ""

# Step 2: Get Flutter dependencies
echo "2️⃣ Getting Flutter dependencies..."
flutter pub get
echo "✅ Dependencies fetched"
echo ""

# Step 3: Verify plugin was registered
echo "3️⃣ Checking if plugin was registered..."
if [ -f ".flutter-plugins-dependencies" ]; then
    if grep -q "flutter_igolf_viewer" ".flutter-plugins-dependencies"; then
        echo "✅ flutter_igolf_viewer found in .flutter-plugins-dependencies"
    else
        echo "❌ flutter_igolf_viewer NOT in .flutter-plugins-dependencies"
        echo "   This means Flutter didn't detect the plugin!"
        exit 1
    fi
else
    echo "❌ .flutter-plugins-dependencies file not found"
    exit 1
fi
echo ""

# Step 4: Clean iOS build
echo "4️⃣ Cleaning iOS build artifacts..."
cd ios || exit 1
rm -rf Pods Podfile.lock .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
echo "✅ iOS artifacts cleaned"
echo ""

# Step 5: Install pods
echo "5️⃣ Installing CocoaPods dependencies..."
pod install --verbose
echo ""

# Step 6: Verify plugin in Pods
echo "6️⃣ Verifying plugin was installed..."
if [ -d "Pods/flutter_igolf_viewer" ]; then
    echo "✅ flutter_igolf_viewer pod installed"

    # Check for Assets
    TEXTURE_COUNT=$(find "Pods/flutter_igolf_viewer" -name "v3d_*.png" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$TEXTURE_COUNT" -gt 0 ]; then
        echo "✅ Found $TEXTURE_COUNT texture files in pod"
    else
        echo "❌ No texture files found in pod"
    fi
else
    echo "❌ flutter_igolf_viewer pod NOT installed"
fi
echo ""

# Step 7: Check resource script
echo "7️⃣ Checking resource copy script..."
RESOURCE_SCRIPT="Pods/Target Support Files/Pods-Runner/Pods-Runner-resources.sh"
if [ -f "$RESOURCE_SCRIPT" ]; then
    if grep -q "flutter_igolf_viewer" "$RESOURCE_SCRIPT"; then
        echo "✅ Resource script mentions flutter_igolf_viewer"

        if grep -q "\.png" "$RESOURCE_SCRIPT"; then
            echo "✅ Resource script will copy PNG files"
        else
            echo "❌ Resource script has NO PNG references"
        fi
    else
        echo "❌ Resource script does NOT mention flutter_igolf_viewer"
    fi
else
    echo "❌ Resource script not found"
fi

cd ..
echo ""
echo "====================================="
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run: flutter run"
echo "  2. Check logs for texture loading"
echo ""
