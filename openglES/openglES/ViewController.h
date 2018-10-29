//
//  ViewController.h
//  openglES
//
//  Created by Yuan Le on 2018/10/25.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController{
    GLuint vertexBufferID;//缓存标识
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;//简化OpenGL ES 很多操作

@end

