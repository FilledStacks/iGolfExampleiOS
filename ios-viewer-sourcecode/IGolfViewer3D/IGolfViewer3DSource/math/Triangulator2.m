//
//  Triangulator.m
//  iOS3DCourseViewer
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Triangulator2.h"
#import "TriangulatedDrawObject.h"
#import "../../GLULib/libGLU.xcframework/glu.h"

@interface Triangulator2 ()

+ (void)gluTessBeginCallback:(GLenum)type;
+ (void)gluTessEndCallback;
+ (void)gluTessVertexCallback:(GLvoid*)vertex;
+ (void)gluTessCombineCallback:(GLdouble[3])coords andDataOut:(GLdouble**)dataOut;

@end


static void gluTessBeginCallback(GLenum type)
{
    [Triangulator2 gluTessBeginCallback:type];
}

static void gluTessEndCallback()
{
    [Triangulator2 gluTessEndCallback];
}

static void gluTessVertexCallback(GLvoid* vertex)
{
    [Triangulator2 gluTessVertexCallback:vertex];
}

static void gluTessCombineCallback(GLdouble coords[3], GLdouble* vertex_data[4], GLfloat weight[4], GLdouble** data_out)
{
    [Triangulator2 gluTessCombineCallback:coords andDataOut:data_out];
}



@implementation Triangulator2

static NSMutableArray* userAllocatedVertices;
static TriangulatedDrawObject* currentDrawObject;
static NSMutableArray* drawObjects;
static NSMutableArray* currentPointList;


+ (NSArray<TriangulatedDrawObject*>*)triangulate:(NSArray*)pointList {
    userAllocatedVertices = [NSMutableArray new];
    currentDrawObject = nil;
    drawObjects = [NSMutableArray new];
    currentPointList = [NSMutableArray new];
    
    
    GLUtesselator* tesselator = gluNewTess();
    
    gluTessCallback(tesselator, GLU_TESS_BEGIN, (void(*)())&gluTessBeginCallback);
    gluTessCallback(tesselator, GLU_TESS_END, (void(*)())&gluTessEndCallback);
    gluTessCallback(tesselator, GLU_TESS_VERTEX, (void(*)())&gluTessVertexCallback);
    gluTessCallback(tesselator, GLU_TESS_COMBINE, (void(*)())&gluTessCombineCallback);
    
    gluTessBeginPolygon(tesselator, 0);
    gluTessBeginContour(tesselator);
    GLdouble* doubleBuffer = (GLdouble*)malloc(sizeof(GLdouble) * pointList.count);
    for (int i = 0 ; i < pointList.count/3 ; i++) {
        doubleBuffer[i*3 + 0] = [[pointList objectAtIndex:i*3 + 0] doubleValue];
        doubleBuffer[i*3 + 1] = [[pointList objectAtIndex:i*3 + 1] doubleValue];
        doubleBuffer[i*3 + 2] = [[pointList objectAtIndex:i*3 + 2] doubleValue];
        
        gluTessVertex(tesselator, doubleBuffer + i*3, doubleBuffer + i*3);
    }
    gluTessEndContour(tesselator);
    gluTessEndPolygon(tesselator);
    
    gluDeleteTess(tesselator);
    free(doubleBuffer);
    
    [userAllocatedVertices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        free((GLdouble*)[obj longValue]);
    }];
    
    return drawObjects;
}

+ (void)gluTessBeginCallback:(GLenum)type {
    currentDrawObject = [TriangulatedDrawObject new];
    currentDrawObject.type = type;
    
    currentPointList = [NSMutableArray new];
}

+ (void)gluTessEndCallback {
    currentDrawObject.vertexList = currentPointList;
    [drawObjects addObject:currentDrawObject];
}

+ (void)gluTessVertexCallback:(GLvoid*)vertex {
    GLdouble* pointer = (GLdouble*)vertex;
    [currentPointList addObject:[NSNumber numberWithDouble:pointer[0]]];
    [currentPointList addObject:[NSNumber numberWithDouble:pointer[1]]];
    [currentPointList addObject:[NSNumber numberWithDouble:pointer[2]]];
}

+ (void)gluTessCombineCallback:(GLdouble[3])coords andDataOut:(GLdouble**)dataOut {
    GLdouble* vertex = (GLdouble*)malloc(3 * sizeof(GLdouble));
    vertex[0] = coords[0];
    vertex[1] = coords[1];
    vertex[2] = coords[2];
    [userAllocatedVertices addObject:[NSNumber numberWithLong:(long)vertex]];
    *dataOut = vertex;
    //free(vertex);
}

@end
