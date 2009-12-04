//
//  JigsawAppDelegate.m
//  Jigsaw
//
//  Created by Son Hua on 7/28/09.
//  Copyright 2009 Aptus Ventures. All rights reserved.
//

#import "JigsawAppDelegate.h"
#import "EAGLView.h"

@implementation JigsawAppDelegate

@synthesize window;
@synthesize tabController;
@synthesize gameTableController;
@synthesize mainNavigationController;

- (void) testPutGlView {
	// hide the status bar first so the view is created with more space
	WindowsManager* manager = [WindowsManager getWindowsManager];
	[manager hideStatusBar:TRUE];
	
	// create view
	NSString* glViewName = @"EAGLView";
	
	if ([manager isViewControllerExisted:glViewName] == FALSE) {
		// create a new view controller containing EAGLView
		CGRect rect = [[UIScreen mainScreen] bounds];
		EAGLView* glView = [[EAGLView alloc] initWithFrame:rect];
		UIViewController* glViewController = [[UIViewController alloc] init];
		[glViewController.view addSubview:glView];
		
		// start animation loop also
		[glView startAnimation];
		
		// register with windows manager
		[manager registerViewController: glViewName: glViewController];
		
		// clear
		[glViewController release];
		[glView release];
	} 
	
	
	// now bring the new view to front
	[manager bringViewControllerToFront: glViewName];
	
}
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // hide application bar (must set before add views to windows)
	//[application setStatusBarHidden:TRUE];
	
	// create windows manager
	windowManager = [WindowsManager getWindowsManager: application: window: mainNavigationController];
	//[windowManager hideStatusBar:TRUE];
	[windowManager hideNavigationBar:TRUE];
	
	// put EAGLView at first
	[self testPutGlView];
		
	// get gameViewController pointer ready
	gameTableController = [tabController.viewControllers objectAtIndex:0];
	// show UIWindow in MainWindow.xib
	[window makeKeyAndVisible];
}

- (void)respondToButtonStartClick:(id)sender {	
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	//glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[window release];
	//[glView release];
	[super dealloc];
}

@end
