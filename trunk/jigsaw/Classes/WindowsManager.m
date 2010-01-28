//
//  WindowsManager.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "WindowsManager.h"


@implementation WindowsManager

//--------------------------------------------------------------------------------------------
// Singleton
WindowsManager* instance = NULL;
UIApplication*	application	= NULL;
UIWindow*		window = NULL;
UINavigationController* navigationController = NULL;
NSMutableDictionary*	viewControllers = NULL;					// map view's name to the view object
float statusBarHeight = 0;

+ (WindowsManager*) getWindowsManager {
	if (instance == NULL) 
		instance = [[WindowsManager alloc] init];
	if (application != NULL && window != NULL && navigationController != NULL)
		return instance;
	else
		return NULL;
}

+ (WindowsManager*) getWindowsManager: (UIApplication*) _application: (UIWindow*) _window: (UINavigationController*) _controller {
	application = _application;
	window = _window;
	navigationController = _controller;
	
	// add navigation controller's first view to window by default
	[window addSubview: navigationController.view];
	
	// status bar height
	statusBarHeight = application.statusBarFrame.size.height;
	
	// create dictionary
	viewControllers = [[NSMutableDictionary alloc] init];
	
	return [self getWindowsManager];
}

//----------------------------------------------------------------------------------

- (void) registerViewController: (NSString*) name: (UIViewController*) controller {
	if ([viewControllers objectForKey:name] == NULL) { // name does not exist
		[viewControllers setObject:controller forKey:name];
	} else {
		[NSException raise:@"Name not unique" format:@"View controller name must be unique."];
	}
}

- (BOOL) isViewControllerExisted: (NSString*) name {
	return ([viewControllers objectForKey:name] != NULL);
}
	 
- (void) hideNavigationBar: (BOOL) hidden {
	// customize the navigation controller
	[navigationController setNavigationBarHidden:hidden animated:FALSE];
}

/**************************************************************************************************************************
 * CLAIM NOT CORRECT for iPhone 3.0 now!
 * Trick: if set [application setStatusBarHidden:hidden] before 
 * creating window and add sub view then the status bar is hidden and the window's (0, 0) is set at screen's (0, 24).
 * If the status bar is set to hide after the UIWindow is created, the status bar is just hidden then. The window position
 * in the screen remains unchanged. We need to set its position appropriately.
 * Assumption: at start, the status is shown. So the origin (0,0) of the window is about (0, 24) in the screen.
 **************************************************************************************************************************/

- (void) hideStatusBar: (BOOL) hidden {
	/// this hack is applied for iPhone SDK 2.1 only. 
	
	// set window position properly
	if (hidden)
		[window setFrame:CGRectMake(0, -application.statusBarFrame.size.height, 320, 480 + application.statusBarFrame.size.height)];
		//[window setFrame:CGRectMake(0, -16, 320, 480)];
	else 
		[window setFrame:CGRectMake(0, 0, 320, 480)];
	
	// hide application bar
	[application setStatusBarHidden:hidden animated:TRUE];
}

- (void) goToMainNavigationView {
	[navigationController popToRootViewControllerAnimated:TRUE];
}

- (void) bringViewControllerToFront: (NSString*) name {
	[navigationController pushViewController:[viewControllers objectForKey: name] animated:TRUE];
}
/*
- (CGPoint) mapWindowPointToScreen: (CGPoint) point {
	CGPoint newPoint = point;
	if (application.statusBarHidden)
		//newPoint.y += application.statusBarFrame.size.height;
		newPoint.y += statusBarHeight;
	return newPoint;
}*/
@end
