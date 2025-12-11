//
//  OpenGLESRenderView.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "OpenGLESRenderView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/ES3/gl.h>

@interface OpenGLESRenderView () {
    GLuint _colorRenderBuffer;
    GLuint _framebuffer;
    GLuint _depthStencilBuffer;
    GLuint _stencilBuffer;
    
    GLint _backingWidth;
    GLint _backingHeight;
    GLint _backingDynamicWidth;
    GLint _backingDynamicHeight;

}

@end


@implementation OpenGLESRenderView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    [self setNeedsDisplay];
    
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        [self tearDown];
    }
}

- (void)normalizeBuffers:(BOOL) usePercentageWidth {
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
    [self updateViewportSize:usePercentageWidth];
}

-(void) updateViewportSize:(BOOL) usePercentageWidth {
    
    if(usePercentageWidth){
        glViewport(_backingWidth-_backingDynamicWidth, 0, _backingDynamicWidth, _backingDynamicHeight);
    } else{
        glViewport(0, 0, _backingWidth, _backingHeight);
    }
}

-(GLint) getCurrentOffset:(BOOL)usePercentageWidth{
    if(usePercentageWidth){
        return _backingWidth -_backingDynamicWidth;
    }else{
        return 0;
    }
}

-(GLint) getCurrentWidth:(BOOL)usePercentageWidth{
    if(usePercentageWidth){
        return _backingDynamicWidth;
    }else{
        return _backingWidth;
    }
}

-(GLint) getCurrentHeight{
    return _backingDynamicHeight;
}

- (void)setupLayer {
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)self.layer;
//    eaglLayer.backgroundColor = [UIColor clearColor];
    eaglLayer.opaque = NO;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    eaglLayer.contentsScale = [UIScreen mainScreen].scale;
}

- (void)setupContext {

    [EAGLContext setCurrentContext:nil];
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"iGolf Viewer 3D: Failed to initialize OpenGLES 3.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"iGolf Viewer 3D: Failed to set current OpenGL context");
        exit(1);
    }
    
    [EAGLContext setCurrentContext:_context];
    
    self.context = [EAGLContext currentContext];
}

-(void) initializeDymamicWidth:(float)renderViewWidthPercent{
    _backingDynamicWidth = _backingWidth * renderViewWidthPercent;
    _backingDynamicHeight = _backingHeight;
    
    glViewport(_backingWidth - _backingDynamicWidth, 0, _backingDynamicWidth, _backingDynamicHeight);
}



- (void)initialize {
    float scale = [UIScreen mainScreen].scale;
    
    _backingHeight = self.frame.size.height * scale;
    _backingWidth = self.frame.size.width * scale;
    
    [self setupLayer];
    [self setupContext];
    [self setupDepthStencilBuffer];
    [self setupRenderBuffer];
    
    [self setupFrameBuffer];
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupDepthStencilBuffer {
    glGenRenderbuffers(1, &_depthStencilBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthStencilBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, _backingWidth, _backingHeight);
}


- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthStencilBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthStencilBuffer);
}

- (void)tearDown {
    
    if (_framebuffer != 0) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_colorRenderBuffer != 0) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
    
    _context = nil;
    
    [EAGLContext setCurrentContext:nil];
}

@end

