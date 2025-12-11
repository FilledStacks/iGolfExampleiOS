//
//  Layer.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"


static NSNumber* layer_baseLon_;
static NSNumber* layer_baseLat_;

@interface Layer () {
    NSMutableArray<LayerPolygon*>* _layerPolygons;
    BOOL _isDrawingEnabled;
    NSString* _drawableId;
    Vector* _centroid;
}

@end

@implementation Layer

+ (double)transformLonFromString:(NSString*)lon {
    
    double retval = [Layer transformLonFromDouble:[lon doubleValue]];


    return retval;
}

+ (double)transformLonFromDouble:(double)lon {
    
    if (layer_baseLon_ == nil) {
        layer_baseLon_ = [NSNumber numberWithDouble:lon];
    }

    return (lon - [layer_baseLon_ doubleValue]) * [Layer getMetersInOneLongitudeDegreeWithLatitude:[layer_baseLat_ doubleValue]];
}

+ (double)transformLatFromDouble:(double)lat {
    
    if (layer_baseLat_ == nil) {
        layer_baseLat_ = [NSNumber numberWithDouble:lat];
    }

    return (lat - [layer_baseLat_ doubleValue]) * [Layer getMetersInOneLatitudeDegree];
}

+ (double)transformLatFromString:(NSString*)lat {

    return [Layer transformLatFromDouble:[lat doubleValue]];
}

+ (double)transformToLonWithDouble:(double)lon {
    
    lon /= [Layer getMetersInOneLongitudeDegreeWithLatitude:[layer_baseLat_ doubleValue]];
    lon += [layer_baseLon_ doubleValue];
    
    return lon;
}

+ (double)transformToLatWithDouble:(double)lat {
    
    lat /= [Layer getMetersInOneLatitudeDegree];
    lat += [layer_baseLat_ doubleValue];
    
    return lat;
}

+ (void)setBaseLatitude:(double)lat andBaseLongitude:(double)lon {
    
    layer_baseLat_ = [NSNumber numberWithDouble:lat];
    layer_baseLon_ = [NSNumber numberWithDouble:lon];
}

+ (void)resetBaseValues {
    
    layer_baseLat_ = nil;
    layer_baseLon_ = nil;
}

- (NSArray<LayerPolygon*>*)layerPolygons {
    
    return _layerPolygons;
}

+ (double)degreesToRadians:(double)degrees {
    
    return (degrees * M_PI)/180;
}

+ (double)getMetersInOneLongitudeDegreeWithLatitude:(double)latitude {
    
    return 111321.377778 * cos([Layer degreesToRadians:latitude]) * METERS_IN_POINT;
}

+ (double)getMetersInOneLatitudeDegree{
    
    return 111111.0 * METERS_IN_POINT;
}

-(id)initWithJsonObject:(NSDictionary *)jsonObject andFilePath:(NSString *)filePath andInterpolation:(int)interpolation andExtend:(double)extend {

    
    self = [super init];
    
    self->_drawableId = @"";
    self->_layerPolygons = [NSMutableArray new];
    self->_isDrawingEnabled = true;

    GLKTextureInfo* texture = [GLKTextureInfo loadFromCacheWithFilePath:filePath];

    NSDictionary* shapesObject = [jsonObject objectForKey:@"Shapes"];
    NSArray* shapeArray = [shapesObject objectForKey:@"Shape"];

    for (int i = 0 ; i < shapeArray.count ; i++) {
        NSDictionary* shapeObject = shapeArray[i];
        LayerPolygon* polygon = [[LayerPolygon alloc] initWithJsonObject:shapeObject andTexture:texture andInterpolation:interpolation andExtend:extend];
        
        [self->_layerPolygons addObject:polygon];

        if (i == 0) {
            _boundingBox = polygon.boundingBox;
            _extremeLeft = polygon.extremeLeft;
            _extremeTop = polygon.extremeTop;
            _extremeRight = polygon.extremeRight;
            _extremeBottom = polygon.extremeBottom;
        } else {
            _boundingBox = CGRectUnion(self.boundingBox, polygon.boundingBox);
            if (_extremeLeft.x > polygon.extremeLeft.x) {
                _extremeLeft = polygon.extremeLeft;
            }
            if (_extremeRight.x < polygon.extremeRight.x) {
                _extremeRight = polygon.extremeRight;
            }
            if (_extremeTop.y < polygon.extremeTop.y) {
                _extremeTop = polygon.extremeTop;
            }
            if (_extremeBottom.y > polygon.extremeBottom.y) {
                _extremeBottom = polygon.extremeBottom;
            }
        }
    }
    
    return self;
}

-(NSMutableArray<Vector*>*) getExtremeBox {
    NSMutableArray<Vector*>* retVal = [NSMutableArray new];
    [retVal addObject:[[Vector alloc] initWithX:_extremeLeft.x andY:_extremeBottom.y]];
    [retVal addObject:[[Vector alloc] initWithX:_extremeLeft.x andY:_extremeTop.y]];
    [retVal addObject:[[Vector alloc] initWithX:_extremeRight.x andY:_extremeTop.y]];
    [retVal addObject:[[Vector alloc] initWithX:_extremeRight.x andY:_extremeBottom.y]];
    return retVal;
}

-(Vector*) getCenter {
    return [VectorMath calculateCenteroidWithVectorArray:[self getExtremeBox]];
}

-(Vector*) getRotatedLayerCenterWithPivot:(Vector*) pivot andAngleDegrees:(double) angleDegrees {


        Vector* extremeLeft;
        Vector* extremeTop;
        Vector* extremeRight;
        Vector* extremeBottom;

        for (LayerPolygon* p in self.layerPolygons) {
            for (Vector* point in p.vectorArray) {

                Vector* rotated = [VectorMath rotatedAroundPoint:point andPivot:pivot andAngleDegrees:angleDegrees];

                if (extremeLeft == nil) {
                    extremeLeft = [[Vector alloc] initWithX:rotated.x andY:rotated.y];
                    extremeTop = [[Vector alloc] initWithX:rotated.x andY:rotated.y];
                    extremeRight = [[Vector alloc] initWithX:rotated.x andY:rotated.y];
                    extremeBottom = [[Vector alloc] initWithX:rotated.x andY:rotated.y];
                } else {
                    if (rotated.x < extremeLeft.x) {
                        extremeLeft =[[Vector alloc] initWithX:rotated.x andY:rotated.y];
                    }
                    if (rotated.x > extremeRight.x) {
                        extremeRight = [[Vector alloc] initWithX:rotated.x andY:rotated.y];
                    }
                    if (rotated.y < extremeBottom.y) {
                        extremeBottom = [[Vector alloc] initWithX:rotated.x andY:rotated.y];
                    }
                    if (rotated.y > extremeTop.y) {
                        extremeTop = [[Vector alloc] initWithX:rotated.x andY:rotated.y];
                    }
                }
            }
        }

        if (extremeLeft != nil && extremeBottom != nil && extremeRight != nil && extremeBottom != nil) {
            Vector* leftTop = [VectorMath rotatedAroundPoint:[[Vector alloc] initWithX:extremeLeft.x andY: extremeTop.y] andPivot:pivot andAngleDegrees:-angleDegrees];
            Vector* rightTop = [VectorMath rotatedAroundPoint:[[Vector alloc] initWithX:extremeRight.x andY: extremeTop.y] andPivot:pivot andAngleDegrees:-angleDegrees];
            Vector* rightBottom = [VectorMath rotatedAroundPoint:[[Vector alloc] initWithX:extremeRight.x andY: extremeBottom.y] andPivot:pivot andAngleDegrees:-angleDegrees];
            Vector* leftBottom = [VectorMath rotatedAroundPoint:[[Vector alloc] initWithX:extremeLeft.x andY: extremeBottom.y] andPivot:pivot andAngleDegrees:-angleDegrees];
            
            NSMutableArray<Vector*>* retVal = [NSMutableArray new];
            
            [retVal addObject:leftTop];
            [retVal addObject:rightTop];
            [retVal addObject:rightBottom];
            [retVal addObject:leftBottom];
            
            return [VectorMath calculateCenteroidWithVectorArray:retVal];
        } else {
            return pivot;
        }

}

-(void)enableDrawing {
    _isDrawingEnabled = true;
}

-(void)disableDrawing {
    _isDrawingEnabled = false;
}

- (void)renderWithEffect:(GLKBaseEffect*)effect andFrustum:(Frustum*)frustum {
    if (_isDrawingEnabled == true) {
        for (LayerPolygon* polygon in _layerPolygons) {
            [polygon renderWithEffect:effect andFrustum:frustum];
        }
    }
}

-(Vector *)centroid {
    
    if (_centroid != nil) {
        return _centroid;
    }
    
    NSMutableArray<Vector*>* points = [NSMutableArray new];
    
    for (LayerPolygon* p in self.layerPolygons) {
        for (Vector* v in p.vectorArray) {
            [points addObject:v];
        }
    }
    
    _centroid = [VectorMath calculateCenteroidWithVectorArray:points];
    
    return _centroid;
}

- (BOOL)isInFrustum:(Frustum *)frustum withGrid:(ElevationMap *)grid {
    BOOL retval = true;
    
    for (LayerPolygon* p in self.layerPolygons) {
        for (Vector* v in p.vectorArray) {
            Vector* aV = [[Vector alloc] initWithX:v.x andY:v.y andZ:[grid getZForPointX:-v.x andY:-v.y]];
            if (![frustum isVectorVisible:aV]) {
                retval = false;
                break;
            }
        }
    }
    
    return retval;
}

-(BOOL) isWaterLayer {
    return _drawableId != NULL && ([_drawableId caseInsensitiveCompare:@"lake"] == NSOrderedSame ||
    [_drawableId caseInsensitiveCompare:@"ocean"] == NSOrderedSame ||
    [_drawableId caseInsensitiveCompare:@"pond"] == NSOrderedSame ||
    [_drawableId caseInsensitiveCompare:@"water"] == NSOrderedSame ||
    [_drawableId caseInsensitiveCompare:@"lake_border"] == NSOrderedSame ||
    [_drawableId caseInsensitiveCompare:@"ocean_border"] == NSOrderedSame ||
    [_drawableId caseInsensitiveCompare:@"pond_border"] == NSOrderedSame ||
    [_drawableId caseInsensitiveCompare:@"water_border"] == NSOrderedSame);
}

-(BOOL) isDrawingEnabled {
    return _isDrawingEnabled;
}

- (BOOL)isInFrustum:(Frustum *)frustum {
    
    BOOL retval = true;
    
    for (LayerPolygon* p in self.layerPolygons) {
        if (![p isInFrustum:frustum]) {
            retval = false;
            break;
        }
    }
    
    return retval;
}

- (void)destroy {
    for (LayerPolygon* polygon in _layerPolygons) {
        [polygon destroy];
    }
}

-(void)setDrawableId:(NSString *)drawableId {
    
    _drawableId = drawableId;
}

-(NSString *)drawableId {
    
    return _drawableId != NULL ? _drawableId : @"";
}

@end
