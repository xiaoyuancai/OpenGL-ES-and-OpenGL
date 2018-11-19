//
//  ViewController.m
//  openglES
//
//  Created by Yuan Le on 2018/10/25.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

// 保存顶点信息
typedef struct {
    GLKVector3  positionCoords;
}
SceneVertex;

// 定义三角形顶点数据
static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0}}, // 左下角
    {{ 0.5f, -0.5f, 0.0}}, // 右下角
    {{-0.5f,  0.5f, 0.0}}  // 左上角
};



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //创建OpenGL ES 2.0 上下文
    GLKView*view = (GLKView*)self.view;
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    //把view的上下文设置为当前上下文
    [EAGLContext setCurrentContext:view.context];
    
    //创建效果，渲染使用
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    //图形颜色
    self.baseEffect.constantColor = GLKVector4Make(
                                                   1.0f, // Red
                                                   1.0f, // Green
                                                   1.0f, // Blue
                                                   1.0f);// Alpha
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);//用于在上下文的帧缓存被清除时初始化每个像素点的颜色值（其实就是个背景颜色）
    
    //生成，绑定，初始化GPU缓存内容，因为数据要发送到GPU来渲染
    glGenBuffers(1,//指定要生成的缓存标识符数量
                 &vertexBufferID//指向生成的标识符的内存保存位置
                 );//STEP 1 生成一个顶点缓存对象
    
    glBindBuffer(GL_ARRAY_BUFFER,//常量，缓存类型，此处是一个数组，还有一种类型后面说明
                 vertexBufferID);//STEP 2 新创建的缓冲绑定到GL_ARRAY_BUFFER目标上
    
    glBufferData(GL_ARRAY_BUFFER,//目标缓冲的类型：顶点缓冲对象当前绑定到
                                //GL_ARRAY_BUFFER目标上
                 sizeof(vertices),//要复制进这个缓存的字节的数量(大小)
                 vertices,//要复制的字节地址(希望发送的实际数据)
                 GL_STATIC_DRAW//希望显卡如何管理给定的数据，
                                //GL_STATIC_DRAW数据不会或几乎不会改变。这个可以帮助OpenGL优化内存。
                 );//STEP 3 把之前定义的顶点数据复制到缓冲的内存中
    
    /**
     GL_STATIC_DRAW ：数据不会或几乎不会改变。
     GL_DYNAMIC_DRAW：数据会被改变很多。
     GL_STREAM_DRAW ：数据每次绘制时都会改变。
     
     比如说一个缓冲中的数据将频繁被改变，那么使用的类型就是GL_DYNAMIC_DRAW或GL_STREAM_DRAW，这样就能确保显卡把数据放在能够高速写入的内存部分。
     
     */
    
    
}

//GLKview 代理方法
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [self.baseEffect prepareToDraw];//准备好当前OpenGL ES上下文，以便为使用baseEffect
                                    //生成的属性和Shading Language程序的绘图做好准备。
    
    glClear(GL_COLOR_BUFFER_BIT);//清楚帻缓存（抹去之前画的）
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);//STEP 4，是否在渲染中使用缓存中的数据
    //STEP 5 设置指针
    glVertexAttribPointer(GLKVertexAttribPosition,//当前绑定的缓存包含每个顶点的位置信息
                          3,//每个位置有三部分
                          GL_FLOAT,//每个部分都保存了float类型的数据
                          GL_FALSE,//是否希望数据被标准化(Normalize)。如果我们设置为GL_TRUE，所有数据都会被映射到0（对于有符号型signed数据是-1）到1之间。我们把它设置为GL_FALSE
                          sizeof(SceneVertex),//"步幅"，每个顶点的保存需要多少个字节(指定了GUP从一个顶点的内存开始位置转到下一个顶点的内存开始位置需要跳过多少字节)
                          NULL);//从当前绑定的顶点缓存的开始位置访问顶点数据(表示位置数据在缓冲中起始位置的偏移量)
    
    //STEP 6绘图
    glDrawArrays(GL_TRIANGLES,//如何去处理顶点缓存内的顶点数据，此处是去渲染三角形
                 0,//需要渲染的第一个顶点的位置
                 3);//需要渲染的顶点数量
    
    /**
     补充：
     CPU和GPU运算是异步的，此示例的代码都是运行在CPU上的，然后在需要进一步处理的时候向GPU发送命令。
     */
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    //STEP 7 删除
    if (0 != vertexBufferID) {
        glDeleteBuffers(1,//缓存区数目
                        &vertexBufferID);
    }
    view.context = nil;
    [EAGLContext setCurrentContext:nil];
}

@end
