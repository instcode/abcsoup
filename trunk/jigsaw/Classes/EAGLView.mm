//
//  EAGLView.m
//  Jigsaw
//
//  Created by Son Hua on 7/28/09.
//  Copyright Aptus Ventures 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "Constant.h"
#import "EAGLView.h"
#import "WindowsManager.h"
#import "Jigsaw.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (bool) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
//- (id)initWithCoder:(NSCoder*)coder {
- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithCoder:coder])) {
	if ((self = [super initWithFrame:frame])) {
		// Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
		
		// create a board and register with Jigsaw
		/*
		board = [[Board alloc] initWithSize:7 :7];
		[board loadResources];
		
		Jigsaw* js = [Jigsaw instance];
		[js addBoard: board];
		[js setActiveBoard: board];
		*/
		jigsaw = [Jigsaw instance];
		[jigsaw load];
		
		// one time initialization
		//[self initView]; // not work when drawView is not called.
    }
    return self;
}

- (void)initView {
	[EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
}

- (void)drawView {
	[EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    glViewport(0, 0, backingWidth, backingHeight);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-160.0f, 160.0f, -240.0f, 240.0f, -1.0f, 1.0f);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
        
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	// update
	//[board update: 10];
	// render board
	//[board render];
	[jigsaw update: 0];
	[jigsaw render];
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
	[self initView]; // load textures, one time
    [self drawView];
}


- (bool)createFramebuffer {
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void) mainLoop {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	bool notDone = YES;
	
	while (notDone)
	{
		[self performSelectorOnMainThread:@selector(drawView) withObject:self waitUntilDone:NO];
		[NSThread sleepForTimeInterval:0.5f];
	}
	[pool release];
}

- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		
	
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}


- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
	[jigsaw release];
	
    [context release];  
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// only single-touch at the moment (anyObject)
	UITouch *touch = [touches anyObject];
	
	//WindowsManager* manager = [WindowsManager getWindowsManager];
	
	// get touch point
	CGPoint touchPoint = [touch locationInView: self];
	//CGPoint touchPoint = [manager mapWindowPointToScreen: [touch locationInView:NULL]]; // use window coordinates
	// touch the upper left corner to go back to main menu
	/*
	if (touchPoint.x < LIMIT_X && touchPoint.y < LIMIT_Y) {
		
		[manager goToMainNavigationView];
		[manager hideStatusBar:FALSE];
	}*/
	
	struct JPoint p = {touchPoint.x, touchPoint.y, 0.0f};
	[jigsaw onTouchEnded: p];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// only single-touch at the moment (anyObject)
	UITouch *touch = [touches anyObject];
	
	// get touch point
	CGPoint touchPoint = [touch locationInView: self];
	// piece hit test
	struct JPoint p = {touchPoint.x, touchPoint.y, 0.0f};
	//struct EventJPoint e = {EVENT_TOUCH_BEGAN, p};
	//[board queueTouchEvent: e];
	[jigsaw onTouchBegan: p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// only single-touch at the moment (anyObject)
	UITouch *touch = [touches anyObject];
	
	// get touch point
	CGPoint touchPoint = [touch locationInView: self];
	struct JPoint p = {touchPoint.x, touchPoint.y, 0.0f};
	
	//struct EventJPoint e = {EVENT_TOUCH_MOVED, p};
	//[board queueTouchEvent: e];
	[jigsaw onTouchMoved: p];
}

@end
