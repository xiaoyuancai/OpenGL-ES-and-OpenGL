
#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext

@property (nonatomic, assign, readwrite) 
   GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;
- (void)enable:(GLenum)capability;
- (void)disable:(GLenum)capability;
- (void)setBlendSourceFunction:(GLenum)sfactor 
   destinationFunction:(GLenum)dfactor;
   
@end
