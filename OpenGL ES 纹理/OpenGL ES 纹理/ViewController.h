//
//  ViewController.h
//  OpenGL ES 纹理
//
//  Created by Yuan Le on 2018/10/31.
//  Copyright © 2018年 Yuan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;

@interface ViewController : GLKViewController

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;


@end

