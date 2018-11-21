//
//  main.cpp
//  OpenGL_shader_file
//
//  Created by Yuan Le on 2018/11/21.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "Shader.hpp"

using namespace std;

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void processInput(GLFWwindow *window);

// 窗口大小
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

int main()
{

    // 初始化并配置
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); //OS 下使用
#endif
    
    // 创建窗口
    GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    // glad: 加载OpenGL函数指针
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }
    
    // 创建和编译着色器程序,注意使用自己的正确路径，而不是“我的路径”
    Shader ourShader("/Users/yuanle/Documents/OpenGL-ES-and-OpenGL/OpenGL_shader_file/OpenGL_shader_file/3.3.shader.vs", "/Users/yuanle/Documents/OpenGL-ES-and-OpenGL/OpenGL_shader_file/OpenGL_shader_file/3.3.shader.fs");
    
    // 设置顶点坐标 (顶点缓存buffer(s)) 并且配置顶点属性
    float vertices[] = {
        // 位置         // 颜色
        0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,  // 右下角
        -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,  // 左下角
        0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f   // 顶点
    };
    
    unsigned int VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    // 首先绑定顶点对象
    glBindVertexArray(VAO);
    
    //然后绑定设置顶点缓存 .
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    //配置顶点属性
    // position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    // color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    
    // 循环渲染
    while (!glfwWindowShouldClose(window))
    {
        //输入
        processInput(window);
        
        //渲染
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // 渲染三角形
        ourShader.use();
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        //交换缓冲区和轮询IO事件(按键按下/释放，鼠标移动等)
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    //释放资源
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    
    // 清除之前分配的所有GLFW资源
    glfwTerminate();
    return 0;
}

// 处理输入
void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

// 重绘(改变大小)窗口调用
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}
