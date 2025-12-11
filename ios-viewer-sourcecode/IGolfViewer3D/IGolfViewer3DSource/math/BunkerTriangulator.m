//
//  BunkerTriangulator.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//
#import "BunkerTriangulator.h"
#import <CoreLocation/CoreLocation.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface BunkerTriangulator() {
    
    NSMutableArray* _indexList;
    NSMutableArray* _vertexList;
    NSMutableArray* _normalList;
    NSMutableArray* _uvList;
    NSMutableArray* _vertexArray;
    NSArray<TriangulatedDrawObject*>* _bottomObjects;
}

@end

@implementation BunkerTriangulator


-(instancetype)initWithBunkerForm:(NSMutableArray<NSMutableArray<Vertex*>*>*)bunkerForm {
    self = [super init];
    
    if (self != nil) {
        _vertexArray    = [NSMutableArray new];

        [self triangulateBunkerForm:bunkerForm];
    }
    
    return self;
}

-(void)triangulateBunkerForm:(NSMutableArray<NSMutableArray<Vertex*>*>*)bunkerMapArray {

    NSMutableArray* indexList   = [NSMutableArray new];
    NSMutableArray* vertexList  = [NSMutableArray new];
    NSMutableArray* uvList      = [NSMutableArray new];
    NSMutableArray* normalList  = [NSMutableArray new];

    for (int mapIndex = 0 ; mapIndex < bunkerMapArray.count; mapIndex ++) {
        if (mapIndex != bunkerMapArray.count - 1) {
            
            NSMutableArray<Vertex*>* outSideMap = bunkerMapArray[mapIndex];
            NSMutableArray<Vertex*>* inSideMap = bunkerMapArray[mapIndex + 1];
            
            for (int i = 0; i < outSideMap.count; i++) {
                
                [_vertexArray addObject:[outSideMap objectAtIndex:i]];
                [_vertexArray addObject:[inSideMap objectAtIndex:i]];
            }
        }
    }
    
    int mapPointsCount = (int)bunkerMapArray.firstObject.count;
    
    for (int mapIndex = 0 ; mapIndex < bunkerMapArray.count; mapIndex ++) {
        
        if (mapIndex != bunkerMapArray.count - 1) {
            
            for (int i = 0; i < mapPointsCount; i++) {
                
                Vertex* v1;
                Vertex* v2;
                Vertex* v3;
                Vector* normal;
                
                int firstIndex = mapIndex * (mapPointsCount * 2);
                
                int t = i * 2 + firstIndex;
                
                if (i != mapPointsCount - 1) {
                    
                    [indexList addObject:@(t + 3)];
                    [indexList addObject:@(t + 1)];
                    [indexList addObject:@(t)];
                    
                    v1 = [_vertexArray objectAtIndex:(t + 3)];
                    v2 = [_vertexArray objectAtIndex:(t + 1)];
                    v3 = [_vertexArray objectAtIndex:(t)];

                    normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];
                    
                    [v1 setNormalVector: normal];
                    [v2 setNormalVector: normal];
                    [v3 setNormalVector: normal];
                    
                    [indexList addObject:@(t + 2)];
                    [indexList addObject:@(t + 3)];
                    [indexList addObject:@(t)];
                    
                    v1 = [_vertexArray objectAtIndex:(t + 2)];
                    v2 = [_vertexArray objectAtIndex:(t + 3)];
                    v3 = [_vertexArray objectAtIndex:(t)];
                    
                    normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];

                    [v1 setNormalVector: normal];
                    [v2 setNormalVector: normal];
                    [v3 setNormalVector: normal];
                    
                } else {
                    
                    [indexList addObject:@(firstIndex + 1)];
                    [indexList addObject:@(t + 1)];
                    [indexList addObject:@(t)];
                    
                    v1 = [_vertexArray objectAtIndex:(firstIndex + 1)];
                    v2 = [_vertexArray objectAtIndex:(t + 1)];
                    v3 = [_vertexArray objectAtIndex:(t)];
                    
                    normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];
                    
                    [v1 setNormalVector: normal];
                    [v2 setNormalVector: normal];
                    [v3 setNormalVector: normal];
                    
                    [indexList addObject:@(firstIndex)];
                    [indexList addObject:@(firstIndex + 1)];
                    [indexList addObject:@(t)];
                    
                    v1 = [_vertexArray objectAtIndex:(firstIndex)];
                    v2 = [_vertexArray objectAtIndex:(firstIndex + 1)];
                    v3 = [_vertexArray objectAtIndex:(t)];
                    
                    normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];
                    
                    [v1 setNormalVector: normal];
                    [v2 setNormalVector: normal];
                    [v3 setNormalVector: normal];
                }
            }
        }
    }

    for (Vertex* vertex in _vertexArray) {
        
        [vertexList addObject:@(vertex.vector.x)];
        [vertexList addObject:@(vertex.vector.y)];
        [vertexList addObject:@(vertex.vector.z)];
        
        [uvList addObject:@(vertex.vector.x)];
        [uvList addObject:@(vertex.vector.y)];

        [normalList addObject:@(fabs(-vertex.normalVector.x))];
        [normalList addObject:@(fabs(-vertex.normalVector.y))];
        [normalList addObject:@(fabs(-vertex.normalVector.z))];
    }
    

    NSMutableArray<NSNumber*>* vertices = [NSMutableArray new];
    
    NSArray<Vertex*>* bunkerBottom = bunkerMapArray.lastObject;
    
    for (Vertex* v in bunkerBottom) {
        
        //This check skips NAN vertices
        if (v.vector.x != v.vector.x || v.vector.y != v.vector.y || v.vector.z != v.vector.z) {
            continue;
        }
        
        [vertices addObject:@(v.vector.x)];
        [vertices addObject:@(v.vector.y)];
        [vertices addObject:@(v.vector.z)];
    }
    
    [vertices addObject:@(bunkerBottom.firstObject.vector.x)];
    [vertices addObject:@(bunkerBottom.firstObject.vector.y)];
    [vertices addObject:@(bunkerBottom.firstObject.vector.z)];
    
    _bottomObjects = [Triangulator2 triangulate:vertices];
    
    double baseU = 0;
    double baseV = 0;
    
    BOOL isFirstIteration = YES;
    
    for (TriangulatedDrawObject* drawObject in _bottomObjects) {
        NSArray* vertexList = drawObject.vertexList;
        
        NSMutableArray* uvList = [NSMutableArray new];
        for (int i = 0 ; i < vertexList.count / 3 ; i++) {
            double u = [[vertexList objectAtIndex:i*3 + 0] doubleValue];
            double v = [[vertexList objectAtIndex:i*3 + 1] doubleValue];
            
            if (isFirstIteration) {
                baseU = u;
                baseV = v;
                
                isFirstIteration = NO;
            }
            
            [uvList addObject:[NSNumber numberWithDouble:u - baseU]];
            [uvList addObject:[NSNumber numberWithDouble:v - baseV]];
            
        }
        
        drawObject.uvList = uvList;
        
        [drawObject allocateVerticalNormalBuffer];
        [drawObject allocateRawBuffers];
    }

    _vertexList     = vertexList;
    _uvList         = uvList;
    _normalList     = normalList;
    _indexList      = indexList;
}

-(NSArray*)indexList {
    return _indexList;
}

-(NSArray*)vertexList {
    return _vertexList;
}

-(NSArray*)uvList {
    return _uvList;
}

-(NSArray*)normalList {
    return _normalList;
}

-(NSArray<TriangulatedDrawObject*>*)bottomObjects {
    return _bottomObjects;
}

@end
