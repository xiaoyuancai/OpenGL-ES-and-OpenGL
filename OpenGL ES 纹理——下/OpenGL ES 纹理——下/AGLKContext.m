//
//  AGLKContext.m
//  OpenGL ES 纹理——下
//
//  Created by Yuan Le on 2018/11/2.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext

- (void)setClearColor:(GLKVector4)clearColorRGBA
{
    _clearColor = clearColorRGBA;
    
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    
    //用于在上下文的帧缓存被清除时初始化每个像素点的颜色值（其实就是个背景颜色）
    glClearColor(
                 clearColorRGBA.r,
                 clearColorRGBA.g,
                 clearColorRGBA.b,
                 clearColorRGBA.a);
}


- (void)clear:(GLbitfield)mask{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    //清楚帻缓存（抹去之前画的）
    glClear(mask);
}

- (void)enable:(GLenum)capability;{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    
    glEnable(capability);
}

- (void)disable:(GLenum)capability;{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    
    glDisable(capability);
}

- (void)setBlendSourceFunction:(GLenum)sfactor
           destinationFunction:(GLenum)dfactor;{
    glBlendFunc(sfactor, dfactor);
}

@end
