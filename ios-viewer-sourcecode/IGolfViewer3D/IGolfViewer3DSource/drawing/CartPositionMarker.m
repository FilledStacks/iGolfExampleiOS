//
//  CartPositionMarker.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CartPositionMarker.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>

#import "../IGolfViewer3DPrivateImports.h"


@interface CartPositionMarker() {
    
    Vector* _position;
    TexturedPolygon* _polygon;
    int _cartId;
}

@end

@implementation CartPositionMarker

- (id)initWithCartName:(NSString *)name andId:(int)cartId andLocation:(CLLocation *)location andUVBuffer:(GLuint)uvBuffer andVertexbuffer:(GLuint)vertexBuffer {
    
    self = [super init];
    
    if (self) {
        
        self->_position = [[Vector alloc] initWithX:[Layer transformLonFromDouble:location.coordinate.longitude]
                                               andY:[Layer transformLatFromDouble:location.coordinate.latitude]];
        
        self->_polygon = [[TexturedPolygon alloc] initWithTexture:[self createTextureWithCartName:name] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        
        self->_cartId = cartId;
    }
    
    return self;
}

- (void)updateLocation:(CLLocation*)location {
    
    self->_position = [[Vector alloc] initWithX:[Layer transformLonFromDouble:location.coordinate.longitude]
                                           andY:[Layer transformLatFromDouble:location.coordinate.latitude]];
}

- (GLKTextureInfo*)createTextureWithCartName:(NSString*)name  {
    
    UIImage* backgroundImage = [UIImage imageNamed:@"v3d_cart_marker_bg.png"];
    UIColor* textColor = [UIColor whiteColor];
    
    int textSize = 65;
    int width = backgroundImage.size.width;
    int height = backgroundImage.size.height;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);
    
    [backgroundImage drawInRect:CGRectMake(0, 0, width, height)];
    
    UIFont* font;
    
    CGSize size;
    
    for (int i = textSize; i > 0; i--) {
        
        UIFont* calcFont = [UIFont fontWithName:@"BebasNeue" size:i];
        
        if (calcFont == nil) {
            calcFont = [UIFont fontWithName:@"LeagueGothic" size:i];
        }
        if (calcFont == nil) {
            calcFont = [UIFont systemFontOfSize:textSize];
        }
        
        CGSize calcSize = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:calcFont, NSFontAttributeName, nil]];
        
        if (calcSize.width  < width * 0.8) {
            size = calcSize;
            font = calcFont;
            break;
        }
    }
    
    CGPoint drawPoint = CGPointMake((width - size.width)/2, (height * 53.0 / 146.0) - size.height / 2 + 3);
    
    [name drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                font, NSFontAttributeName,
                                                textColor, NSForegroundColorAttributeName, nil]];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
}

- (void)renderWithCamera:(Camera*)camera andEffect:(GLKBaseEffect*)effect {
    
    CGFloat _scaleFactor = fabs(camera.z * METERS_IN_POINT) * 0.7;//MAX(4 * METERS_IN_POINT, fabs(camera.z * METERS_IN_POINT));
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, _scaleFactor, _scaleFactor, _scaleFactor);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_polygon renderWithEffect:effect];
}

-(int)cartId {
    return _cartId;
}

- (void)dealloc {
    [_polygon destroy];
}

@end
