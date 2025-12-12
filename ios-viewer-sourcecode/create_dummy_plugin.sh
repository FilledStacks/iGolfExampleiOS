#!/bin/bash

echo "Creating minimal Flutter plugin files"
echo "======================================"
echo ""

read -p "Enter the path to your flutter_igolf_viewer plugin directory: " PLUGIN_PATH

if [ ! -d "$PLUGIN_PATH" ]; then
    echo "❌ Directory does not exist: $PLUGIN_PATH"
    exit 1
fi

# Create Classes directory
mkdir -p "$PLUGIN_PATH/ios/Classes"

# Create header file
cat > "$PLUGIN_PATH/ios/Classes/FlutterIgolfViewerPlugin.h" << 'EOF'
#import <Flutter/Flutter.h>

@interface FlutterIgolfViewerPlugin : NSObject<FlutterPlugin>
@end
EOF

# Create implementation file
cat > "$PLUGIN_PATH/ios/Classes/FlutterIgolfViewerPlugin.m" << 'EOF'
#import "FlutterIgolfViewerPlugin.h"

@implementation FlutterIgolfViewerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  // Minimal plugin registration - no method channel needed
  // The actual functionality is in the IGolfViewer3D.xcframework
}
@end
EOF

echo "✅ Created plugin files:"
echo "   $PLUGIN_PATH/ios/Classes/FlutterIgolfViewerPlugin.h"
echo "   $PLUGIN_PATH/ios/Classes/FlutterIgolfViewerPlugin.m"
echo ""
echo "Now run:"
echo "  cd <your_flutter_app>"
echo "  cd ios"
echo "  pod install"
echo ""
