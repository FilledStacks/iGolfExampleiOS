//
//  PointListLayer.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "PointListLayer.h"
#import "PointList.h"
#import "ElevationMap.h"

@interface PointListLayer () {
    NSMutableArray<PointList*>* _pointList;
    CGRect _boundingBox;
}

@end

@implementation PointListLayer

- (NSMutableArray<PointList*>*)pointList {
    return _pointList;
}

- (CGRect)boundingBox {
    return _boundingBox;
}

- (id)initWithJsonObject:(NSDictionary*)jsonObject andTransform:(BOOL)transform {
    self = [super init];
    
    _boundingBox = CGRectZero;
    _pointList = [NSMutableArray new];

    NSDictionary* shapesObject = [jsonObject objectForKey:@"Shapes"];
    NSArray* shapeArray = [shapesObject objectForKey:@"Shape"];

    for (int i = 0 ; i < shapeArray.count ; i++) {
        NSDictionary* shapeObject = shapeArray[i];
        PointList* list = [[PointList alloc] initWithJsonObject:shapeObject andTransform:transform];
        [_pointList addObject:list];

        if (i == 0) {
            _boundingBox = list.boundingBox;
        } else {
            _boundingBox = CGRectUnion(_boundingBox, list.boundingBox);
        }
    }
    
    return self;
}

- (BOOL)isInFrustum:(Frustum *)frustum withGrid:(ElevationMap *)grid {
    BOOL retval = true;
    
    for (PointList* list in _pointList) {
        for (Vector* v in list.pointList) {
            Vector* aV = [[Vector alloc] initWithX:v.x andY:v.y andZ:[grid getZForPointX:-v.x andY:-v.y]];
            if (![frustum isVectorVisible:aV]) {
                retval = false;
                break;
            }
        }
    }
    
    return retval;
}

- (BOOL)containsWithVector:(Vector*)vector {
    BOOL retval = NO;
    
    for (PointList* pointList in _pointList) {
        retval = [pointList containsWithVector:vector];
        if (retval) {
            break;
        }
    }
    
    return retval;
}

- (void)makeUnclosed {
    [_pointList enumerateObjectsUsingBlock:^(PointList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj makeUnclosed];
    }];
}

@end
