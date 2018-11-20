//
//  main.cpp
//  OpenGL_shader
//
//  Created by Yuan Le on 2018/11/19.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>//必须在glfw3头文件前面
#include <GLFW/glfw3.h>
#include <math.h>

using namespace std;

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void processInput(GLFWwindow *window);

// 窗口大小
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

//顶点着色器
const char *vertexShaderSource = "#version 330 core\n"
"layout (location = 0) in vec3 aPos;\n"
"layout (location = 1) in vec3 aColor;\n"
"out vec3 ourColor;\n"
"void main()\n"
"{\n"
"   gl_Position = vec4(aPos, 1.0);\n"
"   ourColor = aColor;\n"
"}\n";

//片段着色器
const char *fragmentShaderSource = "#version 330 core\n"
"out vec4 FragColor;\n"
"in vec3 ourColor;\n"
"void main()\n"
"{\n"
"   FragColor = vec4(ourColor,1.0);\n"
"}\n";

float vertices[]={
    // 位置              // 颜色
    0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // 右下
    -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // 左下
    0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // 顶部
};

int main(int argc, const char * argv[]) {
    
    /*********************生成窗口*******************/
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    
    // 创建窗口
    GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
    if (window == NULL)
    {
        cout << "Failed to create GLFW window" << endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        cout << "Failed to initialize GLAD" << endl;
        return -1;
    }
    
    //创建顶点着色器对象来编译我们创建好的顶点着色器，让opengl去动态编译它的源码
    unsigned int vertexShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);//由于我们正在创建一个顶点着色器，传递的参数是GL_VERTEX_SHADER
    
    //着色器为图形渲染的某个特定部分而运行。从基本意义上来说，着色器只是一种把输入转化为输出的程序。着色器也是一种非常独立的程序，因为它们之间不能相互通信；它们之间唯一的沟通只有通过输入和输出。
    //把顶点着色器源码附加到顶点着色器对象上，然后编译它：
    glShaderSource(vertexShader,//要编译的着色器对象
                   1,//指定了传递的源码字符串数量，这里只有一个
                   &vertexShaderSource,//顶点着色器真正的源码
                   NULL//指定了传递的源码字符串数量，这里只有一个
                   );
    glCompileShader(vertexShader);//编译
    //检测是否编译成功
    int success;
    char info[512];
    glGetShaderiv(vertexShader,GL_COMPILE_STATUS,&success);
    if (!success) {
        glGetShaderInfoLog(vertexShader,512,NULL,info);
        cout << "error::vertex_compilation_faild\n" << info << endl;
        return -1;
    }
    
    //创建片段着色器对象来编译我们创建好的片段着色器，让opengl去动态编译它的源码,和顶点着色器创建方式类似，只是选择不同的类型
    unsigned int fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    //把片段着色器源码附加到片段着色器对象上，然后编译它：
    glShaderSource(fragmentShader,1,&fragmentShaderSource,NULL);
    //编译
    glCompileShader(fragmentShader);
    //检测是否编译成功
    glGetShaderiv(fragmentShader,GL_COMPILE_STATUS,&success);
    if (!success) {
        glGetShaderInfoLog(fragmentShader,512,NULL,info);
        cout << "fragment::compilation_faild\n" << info <<endl;
        return -1;
    }
    
    /**
     1. 两个着色器现在都编译了，剩下的事情是把两个着色器对象链接到一个用来渲染的着色器程序中
     2. 着色器程序对象 是多个着色器合并之后并最终链接完成的版本。如果要使用刚才编译的着色器我们必须把它们链接(Link)为一个着色器程序对象，然后在渲染对象的时候激活这个着色器程序。已激活着色器程序的着色器将在我们发送渲染调用的时候被使用。
     3. 当链接着色器至一个程序的时候，它会把每个着色器的输出链接到下个着色器的输入。当输出和输入不匹配的时候，你会得到一个连接错误。
     */
    
    //创建一个着色器程序对象
    unsigned int shaderProgram =  glCreateProgram();//函数创建一个程序，并返回新创建程序对象的ID引用
    //要把之前编译的着色器附加到程序对象上，然后用glLinkProgram链接它们：
    glAttachShader(shaderProgram,vertexShader);
    glAttachShader(shaderProgram,fragmentShader);
    glLinkProgram(shaderProgram);
    
    //检测链接着色器程序是否失败，并获取相应的日志
    glGetProgramiv(shaderProgram,GL_LINK_STATUS,&success);
    if (!success) {
        glGetProgramInfoLog(shaderProgram,512,NULL,info);
        cout << "shader link faild\n" << info << endl;
        return  -1;
    }
    //把着色器对象链接到程序对象以后，记得删除着色器对象
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    //生成顶点缓存对象，好处是我们可以一次性的发送一大批数据到显卡上，而不是每个顶点发送一次。从CPU把数据发送到显卡相对较慢，所以只要可能我们都要尝试尽量一次性发送尽可能多的数据
    unsigned int VBO,VAO;
    //第一步，生成对象
    glGenBuffers(1,&VBO);//生成顶点缓存对象
    glGenVertexArrays(1,&VAO);//顶点数组对象
    //第二步：绑定对象
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER,VBO);//把新创建的缓冲绑定到GL_ARRAY_BUFFER目标上
    //第三步：设置属性
    glBufferData(GL_ARRAY_BUFFER,//目标缓冲的类型：顶点缓冲对象当前绑定到GL_ARRAY_BUFFER目标上
                 sizeof(vertices),//指定传输数据的大小(以字节为单位)
                 vertices,//发送的实际数据
                 GL_STATIC_DRAW//如何管理给定的数据,有三种形式，分别如下：
                 /**
                  GL_STATIC_DRAW ：数据不会或几乎不会改变。
                  GL_DYNAMIC_DRAW：数据会被改变很多。
                  GL_STREAM_DRAW ：数据每次绘制时都会改变。
                  */
                 );
    
    //第四步：告诉OpenGL该如何解析顶点数据（应用到逐个顶点属性上）
    glVertexAttribPointer(0,//指定我们要配置的顶点属性。还记得我们在顶点着色器中使用layout(location = 0)定义了position顶点属性的位置值(Location)吗？它可以把顶点属性的位置值设置为0。因为我们希望把数据传递到这一个顶点属性中，所以这里我们传入0。
                          3,//指定顶点属性的大小。顶点属性是一个vec3，它由3个值组成，所以大小是3。
                          GL_FLOAT,//指定数据的类型，这里是GL_FLOAT(GLSL(shading lauguage)中vec*都是由浮点数值组成的)。
                          GL_FALSE,//定义我们是否希望数据被标准化(Normalize)。如果我们设置为GL_TRUE，所有数据都会被映射到0（对于有符号型signed数据是-1）到1之间。我们把它设置为GL_FALSE。
                          6*sizeof(float),//第五个参数叫做步长(Stride)，它告诉我们在连续的顶点属性组之间的间隔。由于下个组位置数据在6个float之后，我们把步长设置为6 * sizeof(float)。
                          0//表示位置数据在缓冲中起始位置的偏移量。由于位置数据在数组的开头，所以这里是0
                          );
    
    //第五步：启用顶点属性
    glEnableVertexAttribArray(0);
    
    //颜色属性
    glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,6*sizeof(float),(void*)(3*sizeof(float)));
    glEnableVertexAttribArray(1);
    
    //调用注册了VBO的glVertexAttribPointer作为顶点属性绑定的顶点缓冲区对象，这样之后我们就可以安全地解除绑定
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    //为了程序不退出，我们循环渲染
    while (!glfwWindowShouldClose(window)) {
        //等待输入
        processInput(window);
        
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glUseProgram(shaderProgram);
//        //通过uniform设置片段着色器输出的颜色值
//        double timeValue =  glfwGetTime();
//        float greenValue = (sin(timeValue) / 2.0f) + 0.5f;
//        int vertexColorLocation = glGetUniformLocation(shaderProgram,"ourColor");
//        glUniform4f(vertexColorLocation,0.0f,greenValue,0.0f,1.0f);//更新一个uniform之前你必须先使用程序（调用glUseProgram)，因为它是在当前激活的着色器程序中设置uniform的
        
        
        glBindVertexArray(VAO); // 因为我们只有一个VAO，所以没有必要每次都绑定它，但是我们这样做是为了更标准化
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glfwSwapBuffers(window);//交换指定窗口的前后缓存
        glfwPollEvents();
    }
    //dealloc资源
    glDeleteBuffers(1,&VBO);
    glDeleteVertexArrays(1,&VAO);
    glDeleteProgram(shaderProgram);
    glfwTerminate();//销毁窗口
    return 0;
}

void processInput(GLFWwindow *window){
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height){
    //确保视口与新的窗口尺寸相匹配，宽度和高度将大大超过指定的视网膜显示器
    glViewport(0, 0, width, height);
}
