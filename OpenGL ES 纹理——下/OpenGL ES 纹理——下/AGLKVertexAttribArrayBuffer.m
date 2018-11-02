
#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer ()

@end


@implementation AGLKVertexAttribArrayBuffer


- (id)initWithAttribStride:(GLsizeiptr)aStride numberOfVertices:(GLsizei)count bytes:(const GLvoid*)dataPtr usage:(GLenum)usage;{
   NSParameterAssert(0 < aStride);
   NSAssert((0 < count && NULL != dataPtr) ||
      (0 == count && NULL == dataPtr),
      @"data must not be NULL or count > 0");
      
   if(nil != (self = [super init]))
   {
      _stride = aStride;
      _bufferSizeBytes = _stride * count;
      
      glGenBuffers(1,  //指定要生成的缓存标识符数量
                   &_name//指向生成的标识符的内存保存位置
                   );// STEP 1 生成标识符
       
      glBindBuffer(GL_ARRAY_BUFFER,//常量，缓存类型，此处是一个数组，还有一种类型后面说明
                   self.name
                   ); // STEP 2 绑定缓存
       
      glBufferData(                  // STEP 3
         GL_ARRAY_BUFFER,  // 初始化缓存内容，指定要更新当前上下文中所绑定的是哪一个缓存
         _bufferSizeBytes,  // 要复制进这个缓存的字节的数量(大小)
         dataPtr,          // 要复制的字节地址(数据)
         usage            // 提示了缓存在未来的运算中可能将会被怎样使用，
                        //GL_STATIC_DRAW会告诉上下文，缓存的内容适合复制到GPU控制的内存，因为很少对其它进行修改，这个可以帮助OpenGL优化内存。使用GL_DYNAMIC_DRAW，缓存内的数据会频繁改变，同时提示OpenGLES以不同的方式来处理缓存的存储
                   );//复制应用的顶点数据到当前上下文的所绑定的顶点缓存中
         
      NSAssert(0 != _name, @"Failed to generate name");
       
   }
   
   return self;
}   


// This method loads the data stored by the receiver.
- (void)reinitWithAttribStride:(GLsizeiptr)aStride numberOfVertices:(GLsizei)count bytes:(const GLvoid*)dataPtr;{
    
   NSParameterAssert(0 < aStride);
   NSParameterAssert(0 < count);
   NSParameterAssert(NULL != dataPtr);
   NSAssert(0 != _name, @"Invalid name");

   self.stride = aStride;
   self.bufferSizeBytes = aStride * count;
   
   glBindBuffer(GL_ARRAY_BUFFER,
      self.name); 
   glBufferData(
      GL_ARRAY_BUFFER,
      _bufferSizeBytes,
      dataPtr,
      GL_DYNAMIC_DRAW); 
}


/////////////////////////////////////////////////////////////////
// A vertex attribute array buffer must be prepared when your 
// application wants to use the buffer to render any geometry. 
// When your application prepares an buffer, some OpenGL ES state
// is altered to allow bind the buffer and configure pointers.
- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable{
    
   NSParameterAssert((0 < count) && (count < 4));
   NSParameterAssert(offset < self.stride);
   NSAssert(0 != _name, @"Invalid name");
    
   if(shouldEnable){
      glEnableVertexAttribArray(     // Step 4 是否在渲染中使用缓存中的数据
         index); 
   }

   glVertexAttribPointer(
      index,               // 使用属性的标识(当前绑定的缓存包含每个顶点的位置信息)
      count,               // 属性坐标的数量（每个位置有count个部分）
      GL_FLOAT,            // 每个部分都保存了float类型的数据
      GL_FALSE,            // 小数点固定数据是否可以被改变
      self.stride,         // "步幅"，每个顶点的保存需要多少个字节(指定了GUP从一个顶点的内存开始位置转到下一个顶点的内存开始位置需要跳过多少字节)
      NULL + offset        // 从每个顶点开始位置到第一个属性位置
                         );// Step 5
#ifdef DEBUG
   {
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
#endif
}

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
    
   NSAssert(self.bufferSizeBytes >= 
      ((first + count) * self.stride),
      @"Attempt to draw more vertex data than available.");

    glDrawArrays(mode,//如何去处理顶点缓存内的顶点数据，此处是去渲染三角形
                 first,//需要渲染的第一个顶点的位置
                 count //需要渲染的第一个顶点的位置
                 ); // Step 6 绘图
    
}

+ (void)drawPreparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
    
   glDrawArrays(mode,//如何去处理顶点缓存内的顶点数据，此处是去渲染三角形
                first,//需要渲染的第一个顶点的位置
                count //需要渲染的第一个顶点的位置
                ); // Step 6 绘图
}

- (void)dealloc{
    // Delete buffer from current context
    if (0 != _name)
    {
        glDeleteBuffers (1, &_name); // Step 7  删除缓存区
        _name = 0;
    }
}

@end
