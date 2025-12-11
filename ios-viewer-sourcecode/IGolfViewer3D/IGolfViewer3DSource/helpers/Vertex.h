//
//  Vertex.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "../math/Vector.h"

@interface Vertex : NSObject

@property (nonatomic, readonly) Vector* vector;
@property (nonatomic, assign) Vector* normalVector;

-(id)initWithX:(double)x Y:(double)y Z:(double)z;


@end
