//
//  GLHelper.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "../math/Vector.h"
#import "Camera.h"

@interface GLHelper : NSObject

+(GLuint)getEmptyBuffer;
+(GLuint)getBuffer:(NSArray *)list;
+(GLuint)getIndexBuffer:(NSArray *)list;

+(void)deleteBuffer:(GLuint)buffer;
+(void)deleteAllBuffers;

+(void)updateBuffer:(GLuint)buffer andData:(NSArray *)list;
+(void)updateBuffer:(GLuint)buffer andData:(GLfloat *)array andCount:(int)count;

+(void)drawVertexBuffer:(GLuint)vertexBufer andTexCoordBuffer:(GLuint)texCoordBuffer andMode:(GLenum)mode andCount:(GLsizei)count;
+(void)drawVertexBuffer:(GLuint)vertexBufer andColorBuffer:(GLuint)colorBuffer andMode:(GLenum)mode andCount:(GLsizei)count;
+(void)drawVertexBuffer:(GLuint)vertexBufer andMode:(GLenum)mode andCount:(GLsizei)count;
+(void)drawVertexBuffer:(GLuint)vertexBufer andTexCoordBuffer:(GLuint)texCoordBuffer andNormalBuffer:(GLuint)normalBuffer andMode:(GLenum)mode andCount:(GLsizei)count;
+(void)drawVertexBuffer:(GLuint)vertexBufer andIndexBuffer:(GLuint)indexBuffer andTexCoordBuffer:(GLuint)texCoordBuffer andNormalBuffer:(GLuint)normalBuffer andMode:(GLenum)mode andCount:(GLsizei)count;
+(CGPoint)getObjectScreenCoordinate:(Vector*)position camera:(Camera*)camera;
+(void)prepareTextureToStartDraw:(GLKTextureInfo*)texture andEffect:(GLKBaseEffect*)effect;
+(void)disableTextureForEffect:(GLKBaseEffect*)effect;
+(void)drawVertexBuffer:(GLuint)vertexBufer andIndexBuffer:(GLuint)indexBuffer andMode:(GLenum)mode andCount:(GLsizei)count;

@end

