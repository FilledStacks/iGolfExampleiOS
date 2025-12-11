//
//  PointList.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "PointList.h"
#import "../IGolfViewer3DPrivateImports.h"

@implementation PointList {
    NSMutableArray<Vector*>* _pointList;
    CGRect _boundingBox;
}

- (NSMutableArray<Vector*>*)pointList {
    return _pointList;
}

-(void)setPointList:(NSMutableArray<Vector *> *)pointList {
    _pointList = pointList;
}

- (CGRect)boundingBox {
    return _boundingBox;
}

- (id)initWithJsonObject:(NSDictionary*)jsonObject andTransform:(BOOL)transform {
    self = [super init];
    
    _boundingBox = CGRectZero;
    _pointList = [NSMutableArray new];

    BOOL firstIteration = YES;

    NSString* points = [jsonObject objectForKey:@"Points"];
    NSArray* lonLatPointsArray = [points componentsSeparatedByString:@","];

    for (NSString* lonLatPoints in lonLatPointsArray) {
        NSArray* lonLatPair = [lonLatPoints componentsSeparatedByString:@" "];
        double lon = [lonLatPair[0] doubleValue];
        double lat = [lonLatPair[1] doubleValue];
        
        if (transform) {
            lon = [Layer transformLonFromDouble:lon];
            lat = [Layer transformLatFromDouble:lat];
        }
        
        Vector* newVector = [[Vector alloc] initWithX:lon andY:lat];

        if (_pointList.count > 0) {
            if ([_pointList.lastObject isEqualToVector:newVector]) {
                continue;
            }
        }

        CGRect thisRect = CGRectMake(lon, lat, 0, 0);
        if (firstIteration) {
            firstIteration = NO;
            _boundingBox = thisRect;
            
        } else {
            _boundingBox = CGRectUnion(_boundingBox, thisRect);
            
        }
        
        [_pointList addObject:newVector];
    }

    return self;
}

- (void)reverse {
    _pointList = [NSMutableArray arrayWithArray:[[_pointList reverseObjectEnumerator] allObjects]];
}

- (BOOL)containsWithVector:(Vector*)vector {
    return [VectorMath isVector:vector insidePolygon:_pointList];
}

- (void)makeUnclosed {
    while (true) {
        Vector* first = _pointList.firstObject;
        Vector* last = _pointList.lastObject;
        if (![first isEqualToVector:last]) {
            break;
        }
        [_pointList removeLastObject];
    }
}

@end
