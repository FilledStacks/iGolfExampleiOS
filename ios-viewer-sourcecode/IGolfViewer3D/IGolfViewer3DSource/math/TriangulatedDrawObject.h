//
//  TriangulatedDrawObject.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface TriangulatedDrawObject : NSObject

@property (nonatomic, assign) GLenum type;
@property (nonatomic, retain) NSArray* vertexList;
@property (nonatomic, retain) NSArray* uvList;
@property (nonatomic, retain) NSArray* colorList;

@property (nonatomic, readonly) GLuint vertexBuffer;
@property (nonatomic, readonly) GLuint uvBuffer;
@property (nonatomic, readonly) GLuint numVertices;
@property (nonatomic, readonly) GLuint normalBuffer;
@property (nonatomic, readonly) GLuint colorBuffer;


- (void)allocateVertexBuffer;
- (void)allocateColorBuffer;
- (void)allocateVerticalNormalBuffer;
- (void)allocateNormalBuffer;
- (void)allocateRawBuffers;
- (void)releaseRawBuffers;


@end
