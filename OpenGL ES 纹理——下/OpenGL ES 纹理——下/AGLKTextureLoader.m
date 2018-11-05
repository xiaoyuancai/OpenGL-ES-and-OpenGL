//
//  AGLKTextureLoader.m
//  OpenGL ES 纹理——下
//
//  Created by Yuan Le on 2018/11/2.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import "AGLKTextureLoader.h"

typedef enum
{
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}
AGLKPowerOf2;


static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(
                                                      GLuint dimension);


static NSData *AGLKDataWithResizedCGImageBytes(
                                               CGImageRef cgImage,
                                               size_t *widthPtr,
                                               size_t *heightPtr);

// AGLKTextureInfo实例一旦初始化就不可变
@interface AGLKTextureInfo (AGLKTextureLoader)

- (id)initWithName:(GLuint)aName
            target:(GLenum)aTarget
             width:(size_t)aWidth
            height:(size_t)aHeight;

@end


@implementation AGLKTextureInfo (AGLKTextureLoader)


- (id)initWithName:(GLuint)aName
            target:(GLenum)aTarget
             width:(size_t)aWidth
            height:(size_t)aHeight
{
    if (nil != (self = [super init]))
    {
        name = aName;
        target = aTarget;
        width = aWidth;
        height = aHeight;
    }
    
    return self;
}

@end


@implementation AGLKTextureInfo

@synthesize name;
@synthesize target;
@synthesize width;
@synthesize height;
@end


@implementation AGLKTextureLoader

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage                           options:(NSDictionary *)options
                                  error:(NSError **)outError;
{
    // 获取将数据复制到新纹理缓冲区时使用的字节
    size_t width;
    size_t height;
    NSData *imageData = AGLKDataWithResizedCGImageBytes(
                                                        cgImage,
                                                        &width,
                                                        &height);
    
    // 生成、绑定和复制数据到一个新的纹理缓冲区
    GLuint      textureBufferID;
    
    glGenTextures(1, &textureBufferID);                  // Step 1
    glBindTexture(GL_TEXTURE_2D, textureBufferID);       // Step 2
    
    glTexImage2D(                                        // Step 3 复制图片像素的颜色数据到绑定的纹理缓存中
                 GL_TEXTURE_2D,//用于2D纹理
                 0,            //指定MIP贴图的初始细节级别，如果没有使用MI贴图，些参数必须是0
                 GL_RGBA,      //指定在纹理缓存内每个纹素需要保存的信息数量
                 (GLsizei)width,//指定图像的宽度
                 (GLsizei)height,//指定图像的高度，宽度和高度要是2的幂
                 0,              //确定围绕纹理的纹素的一个边界的大小，但是在OpenGL ES中剖是被设置为0
                 GL_RGBA,       //指定初始化缓存所使用的图像数据中每个像素所要保存的信息，这个参数要总与第三个参数相同
                 GL_UNSIGNED_BYTE,//指定缓存中的纹素数据所使用的位编码类型
                 [imageData bytes]//要被复制到绑定纹理缓存中的图片的像素颜色数据的指针(就是数据)
                 );
    
    // 设置控制绑定纹理采样的参数
    glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_MIN_FILTER,
                    GL_LINEAR);
    
    //分配并初始化要返回的AGLKTextureInfo实例
    AGLKTextureInfo *result = [[AGLKTextureInfo alloc]
                               initWithName:textureBufferID
                               target:GL_TEXTURE_2D
                               width:width
                               height:height];
    
    return result;
}

//获取用于初始化纹理缓存内容的字节
static NSData *AGLKDataWithResizedCGImageBytes(
                                               CGImageRef cgImage,
                                               size_t *widthPtr,
                                               size_t *heightPtr)
{
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);
    
    size_t originalWidth = CGImageGetWidth(cgImage);
    size_t originalHeight = CGImageGetWidth(cgImage);
    
    NSCAssert(0 < originalWidth, @"Invalid image width");
    NSCAssert(0 < originalHeight, @"Invalid image height");
    
    // 计算新纹理缓冲区的宽度和高度新纹理缓冲区将具有2维的能力。
    size_t width = AGLKCalculatePowerOf2ForDimension((GLuint)originalWidth);
    size_t height = AGLKCalculatePowerOf2ForDimension((GLuint)originalHeight);
    
    // 为RGBA像素颜色数据分配足够的存储空间，指定2个大小
    NSMutableData    *imageData = [NSMutableData dataWithLength:
                                   height * width * 4];  // 4 bytes per RGBA pixel
    
    NSCAssert(nil != imageData,
              @"Unable to allocate image storage");
    
    // 创建一个核心图形上下文来提取已分配的字节
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(
                                                   [imageData mutableBytes], width, height, 8,
                                                   4 * width, colorSpace,
                                                   kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    // 翻转y轴，原因是OpenGL ES的纹理坐标系会放置在原点左下角，同时y值向上增大，翻转y轴确保了图像字节拥有适用于纹理缓存的正确方向
    CGContextTranslateCTM (cgContext, 0, height);
    CGContextScaleCTM (cgContext, 1.0, -1.0);
    
    // Draw the loaded image into the Core Graphics context
    // resizing as necessary
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height),
                       cgImage);
    
    CGContextRelease(cgContext);
    
    *widthPtr = width;
    *heightPtr = height;
    
    return imageData;
}


// 计算并返回最接近的2的幂，它大于或等于维度参数，小于或等于1024。
static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(
                                                      GLuint dimension)
{
    AGLKPowerOf2  result = AGLK1;
    
    if(dimension > (GLuint)AGLK512)
    {
        result = AGLK1024;
    }
    else if(dimension > (GLuint)AGLK256)
    {
        result = AGLK512;
    }
    else if(dimension > (GLuint)AGLK128)
    {
        result = AGLK256;
    }
    else if(dimension > (GLuint)AGLK64)
    {
        result = AGLK128;
    }
    else if(dimension > (GLuint)AGLK32)
    {
        result = AGLK64;
    }
    else if(dimension > (GLuint)AGLK16)
    {
        result = AGLK32;
    }
    else if(dimension > (GLuint)AGLK8)
    {
        result = AGLK16;
    }
    else if(dimension > (GLuint)AGLK4)
    {
        result = AGLK8;
    }
    else if(dimension > (GLuint)AGLK2)
    {
        result = AGLK4;
    }
    else if(dimension > (GLuint)AGLK1)
    {
        result = AGLK2;
    }
    
    return result;
}


@end
