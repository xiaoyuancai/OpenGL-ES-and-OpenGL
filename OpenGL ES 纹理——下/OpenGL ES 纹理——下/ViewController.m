//
//  ViewController.m
//  OpenGL ES 纹理——下
//
//  Created by Yuan Le on 2018/11/2.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "AGLKTextureLoader.h"

@implementation ViewController

// 保存每一个顶点信息
typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}
SceneVertex;

// 定义三角形顶点数据
static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}}, //左下角
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}}, // 右下角
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}}, // 左上角
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [AGLKContext setCurrentContext:view.context];
    
    // //用于在上下文的帧缓存被清除时初始化每个像素点的颜色值（其实就是个背景颜色）
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
    //创建效果，渲染使用
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(
                                                   1.0f, // Red
                                                   1.0f, // Green
                                                   1.0f, // Blue
                                                   1.0f);// Alpha
    
    // 创建buffer
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices
                         usage:GL_STATIC_DRAW];
    
    // 设置文理
    CGImageRef imageRef =
    [[UIImage imageNamed:@"leaves.gif"] CGImage];
    
    //GLKTextureLoader类 用于将一个纹理图像加载到一个OPenGL ES纹理缓存中（GLKTextureLoader会自动调用glTextParameteri()方法来创建纹理缓存设置OpenLG ES取样和循环模式）
    //textureInfo 封装了与刚创建的纹理缓存相关的信息，包括它的尺寸及它是否包含MIP贴图(此示例没有贴图)。
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    
    AGLKTextureInfo *textureInfo1 = [AGLKTextureLoader
                                    textureWithCGImage:imageRef
                                    options:nil
                                    error:NULL];
    
    self.baseEffect.texture2d0.name = textureInfo1.name;//纹理缓存名称
    self.baseEffect.texture2d0.target = textureInfo1.target;//target指定被配置的纹理缓存的类型
    
}


//GLKview 代理方法
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [self.baseEffect prepareToDraw];//准备好当前OpenGL ES上下文，以便为使用baseEffect
    //生成的属性和Shading Language程序的绘图做好准备
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];//清楚帻缓存（抹去之前画的）
    
    //设置buffer
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    
    
    // 绘制三角形
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:3];
}


-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexBuffer = nil;
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


@end
