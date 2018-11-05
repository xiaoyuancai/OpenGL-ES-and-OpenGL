//
//  AGLKTextureLoader.h
//  OpenGL ES 纹理——下
//
//  Created by Yuan Le on 2018/11/2.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#pragma mark -AGLKTextureInfo

@interface AGLKTextureInfo : NSObject
{
@private
    GLuint name;
    GLenum target;
    size_t width;
    size_t height;
}

@property (readonly) GLuint name;
@property (readonly) GLenum target;
@property (readonly) size_t width;
@property (readonly) size_t height;

@end


#pragma mark -AGLKTextureLoader

@interface AGLKTextureLoader : NSObject

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage                                                         options:(NSDictionary *)options
                                  error:(NSError **)outError;

@end
