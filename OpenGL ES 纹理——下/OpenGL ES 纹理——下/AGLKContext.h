//
//  AGLKContext.h
//  OpenGL ES 纹理——下
//
//  Created by Yuan Le on 2018/11/2.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext

@property (nonatomic, assign, readwrite)GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;
- (void)enable:(GLenum)capability;
- (void)disable:(GLenum)capability;
- (void)setBlendSourceFunction:(GLenum)sfactor
           destinationFunction:(GLenum)dfactor;

@end
