//
//  BunkerTriangulator.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "../IGolfViewer3DPrivateImports.h"

@class TriangulatedDrawObject;

@interface BunkerTriangulator : NSObject

@property (nonatomic, readonly) NSArray* vertexList;
@property (nonatomic, readonly) NSArray* uvList;
@property (nonatomic, readonly) NSArray* indexList;
@property (nonatomic, readonly) NSArray* normalList;
@property (nonatomic, readonly) NSArray<TriangulatedDrawObject*>* bottomObjects;

-(instancetype)initWithBunkerForm:(NSMutableArray<NSMutableArray<Vertex*>*>*)bunkerForm;

@end
