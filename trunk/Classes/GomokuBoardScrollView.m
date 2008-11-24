//
//  GomokuBoardScrollView.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GomokuBoardScrollView.h"
#import "GomokuBoardView.h"

@implementation GomokuBoardScrollView

- (void) awakeFromNib {
	// attach scroll view delegate
	self.delegate = self;	
	self.alwaysBounceVertical	= true;
	self.alwaysBounceHorizontal = true;	
	self.clipsToBounds = true;
	self.autoresizesSubviews = false; // do not auto resize so that boardView is placed properly in scrollview
	
	// reference to boardView
	boardView = (GomokuBoardView*)[self viewWithTag:1]; // boardView is tag with number 1
	/*
	// set scrollview's content size
	CGRect boardFrame = [boardView frame];
	[self setContentSize:boardFrame.size];
	
	[self setFrame:boardFrame];
	[self setContentOffset:[boardView getScrollOffset]];
	*/
	
	// set content size for scroll view here
	//CGSize fullSize = [boardView getFullBoardSize];	
	//[self setContentSize:fullSize];	
	//[self setContentOffset:CGPointMake(0, 0)];
		
	// set zooming scale
	self.minimumZoomScale = 1;
	self.maximumZoomScale = 2;
	
	/*
	//[boardView release];
	
	// add sub view
	int a = [[self subviews] count];
	boardView = [[GomokuBoardView alloc] initWithFrame:[self frame]];
	
	//[self addSubview:(UIView*)boardView];
	UIView* uiView = [[UIView alloc] init];
	[uiView addSubview:boardView];
	int c = [[uiView subviews] count];
	[self addSubview:uiView];
	//[self insertSubview:boardView atIndex:0];
	//[self bringSubviewToFront:boardView];
	//[boardView release];
	
	int b = [[self subviews] count];
	int x = [[self subviews] indexOfObject:boardView];
	*/
}

/*
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}*/

/*
- (void)drawRect:(CGRect)rect {
    //NSArray* subviews = [self subviews];
	//UIView* last = [subviews lastObject];
	//[last drawRect:rect];
	int a = [[self subviews] count];
	//[boardView drawRect:rect];
}*/

/*
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	return true;
}*/


// scroll event
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// ask for a redraw, a bit waste. Only need to move the buffer only?
	//[self setNeedsDisplay];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	// bounces
	//self.alwaysBounceVertical	= false;
	//self.alwaysBounceHorizontal = false;
}

// -- handles zooming --
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {	
	return boardView;
	//return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	// notify subviews with new scale here. This is a hidden observer pattern.
	// for efficiency, we send new scale message to boardView only
	//[view onZoomScaleChanged:scale];
	//[self setNeedsDisplay];
	// no more zoom
	
	return;
	
	
	CGRect myFrame = [self frame];
	CGRect frame = [boardView frame];
	[self setContentSize:frame.size];
	return;
	
	/*
	[self setMaximumZoomScale:1];
	[self _setZoomed:YES];

	// set scale ratio to update cell size
	[boardView onZoomScaleChanged:scale];
		
	[self layoutSubviews];
	[self setNeedsDisplay];
	
	[self setMaximumZoomScale:10];
	
	//[boardView onZoomScaleChanged:scale];
	*/
}

- (void)dealloc {
    [super dealloc];
}


@end
