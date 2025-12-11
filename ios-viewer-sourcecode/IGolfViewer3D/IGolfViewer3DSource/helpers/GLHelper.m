//
//  GLHelper.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "GLHelper.h"
#import <GLKit/GLKit.h>

#import "../IGolfViewer3DPrivateImports.h"

static int maxBufferIndex = 0;

@implementation GLHelper


+(void)drawVertexBuffer:(GLuint)vertexBufer andMode:(GLenum)mode andCount:(GLsizei)count {
    
    if (glIsBuffer(vertexBufer)) {
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glDrawArrays(mode, 0, count);
        
        glDisableVertexAttribArray(GLKVertexAttribPosition);
    }
}


+(void)drawVertexBuffer:(GLuint)vertexBufer andIndexBuffer:(GLuint)indexBuffer andMode:(GLenum)mode andCount:(GLsizei)count {
    
    if (glIsBuffer(vertexBufer) && glIsBuffer(indexBuffer)) {
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glDrawElements(mode, count, GL_UNSIGNED_INT, nil);
        
        glDisableVertexAttribArray(GLKVertexAttribPosition);
    }
}

+(void)drawVertexBuffer:(GLuint)vertexBufer andTexCoordBuffer:(GLuint)texCoordBuffer andMode:(GLenum)mode andCount:(GLsizei)count {
    
    if (glIsBuffer(vertexBufer) && glIsBuffer(texCoordBuffer)) {
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, texCoordBuffer);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glDrawArrays(mode, 0, count);
        
        glDisableVertexAttribArray(GLKVertexAttribPosition);
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
}

+(void)drawVertexBuffer:(GLuint)vertexBufer andTexCoordBuffer:(GLuint)texCoordBuffer andNormalBuffer:(GLuint)normalBuffer andMode:(GLenum)mode andCount:(GLsizei)count {
    
    if (glIsBuffer(vertexBufer) && glIsBuffer(texCoordBuffer) && glIsBuffer(normalBuffer)) {
        
        glBindBuffer(GL_ARRAY_BUFFER, texCoordBuffer);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, normalBuffer);
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glDrawArrays(mode, 0, count);
        
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
        glDisableVertexAttribArray(GLKVertexAttribNormal);
        glDisableVertexAttribArray(GLKVertexAttribPosition);
    }
}






+(void)drawVertexBuffer:(GLuint)vertexBufer andIndexBuffer:(GLuint)indexBuffer andTexCoordBuffer:(GLuint)texCoordBuffer andNormalBuffer:(GLuint)normalBuffer andMode:(GLenum)mode andCount:(GLsizei)count {
    
    if (glIsBuffer(vertexBufer) && glIsBuffer(indexBuffer) && glIsBuffer(texCoordBuffer) && glIsBuffer(normalBuffer)) {
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER, texCoordBuffer);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, normalBuffer);
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glDrawElements(mode, count, GL_UNSIGNED_INT, nil);
        
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
        glDisableVertexAttribArray(GLKVertexAttribNormal);
        glDisableVertexAttribArray(GLKVertexAttribPosition);
    }
}


+(void)drawVertexBuffer:(GLuint)vertexBufer andColorBuffer:(GLuint)colorBuffer andMode:(GLenum)mode andCount:(GLsizei)count {
    
    if (glIsBuffer(vertexBufer) && glIsBuffer(colorBuffer)) {
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glDrawArrays(mode, 0, count);
        
        glDisableVertexAttribArray(GLKVertexAttribPosition);
        glDisableVertexAttribArray(GLKVertexAttribColor);
    }
}


+(void)prepareTextureToStartDraw:(GLKTextureInfo *)texture andEffect:(GLKBaseEffect *)effect {
    
    effect.texture2d0.name = texture.name;
    effect.texture2d0.enabled = GL_TRUE;
    [effect prepareToDraw];
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
}

+(void)disableTextureForEffect:(GLKBaseEffect *)effect {
    
    effect.texture2d0.enabled = GL_FALSE;
}


+(void)updateBuffer:(GLuint)buffer andData:(GLfloat *)array andCount:(int)count {
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, count * sizeof(GLfloat), array, GL_STATIC_DRAW);
}

+(GLuint)getBuffer:(NSArray *)list {
    
    GLfloat* array = malloc(list.count * sizeof(GLfloat));
    
    for (int i = 0 ; i < list.count ; i++) {
        GLfloat  value = [[list objectAtIndex:i] floatValue];
        array[i] = value;
    }
    
    GLuint buffer = [GLHelper getEmptyBuffer];
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, list.count * sizeof(GLfloat), array, GL_STATIC_DRAW);
    
    free(array);
    
    return buffer;
}

+(GLuint)getIndexBuffer:(NSArray *)list {
    
    GLuint* array = malloc(list.count * sizeof(GLuint));
    
    for (int i = 0 ; i < list.count ; i++) {
        GLuint value = [[list objectAtIndex:i] unsignedIntValue];
        array[i] = value;
    }
    
    GLuint buffer = [GLHelper getEmptyBuffer];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, list.count * sizeof(GLuint), array, GL_STATIC_DRAW);
    
    free(array);
    
    return buffer;
}


+(GLuint)getEmptyBuffer {
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    maxBufferIndex = MAX(maxBufferIndex, buffer);
    
    return buffer;
}

+(void)updateBuffer:(GLuint)buffer andData:(NSArray *)list {
    GLfloat* array = malloc(list.count * sizeof(GLfloat));
    
    for (int i = 0 ; i < list.count ; i++) {
        GLfloat  value = [[list objectAtIndex:i] floatValue];
        array[i] = value;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, list.count * sizeof(GLfloat), array, GL_STATIC_DRAW);
    
    free(array);
}

+(void)deleteAllBuffers {
    
    for (int i = 0; i <= maxBufferIndex; i++) {
        GLuint index = i;
        glDeleteBuffers(1, &index);
    }
}

+(CGPoint)getObjectScreenCoordinate:(Vector*)position camera:(Camera*)camera {
    
    CGRect _viewPort = camera.getViewport;
    int viewport[4] = {_viewPort.origin.x, 0, _viewPort.size.width, _viewPort.size.height};
    
    GLKVector3 _position = GLKVector3Make(position.x, position.y, position.z);
    
    if (camera.navigationMode == NavigationMode2DView) {
        _position.z = 0;
    }
    
    GLKVector3 coordVector = GLKMathProject(_position, camera.modelViewMatrix, camera.projectionMatrix, viewport);
    CGPoint retval = CGPointMake(coordVector.x + _viewPort.origin.x, _viewPort.origin.y + _viewPort.size.height - coordVector.y);

    return retval;
}


+(void)deleteBuffer:(GLuint)buffer {
    
    glDeleteBuffers(1, &buffer);
}

@end

