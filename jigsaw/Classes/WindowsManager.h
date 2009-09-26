//
//  WindowsManager.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WindowsManager.h"

/************************************************************************
 * Views management class. All requests to change global windows go here.
 * The root view manager is UINavigationViewController.
 ************************************************************************/
@interface WindowsManager : NSObject {
	//NSDictionary* viewControllers;		
}

/**********************************************************************
 * Singleton pattern
 * - returns NULL when window and main navigation controller is not set.
 * - otherwise, return the singleton instance
 **********************************************************************/
+ (WindowsManager*) getWindowsManager: (UIApplication*) application: (UIWindow*) window: (UINavigationController*) controller;
+ (WindowsManager*) getWindowsManager;

/*********************************************
 * Set the main window for the windows manager
 *********************************************/
//- (void) setMainWindow: (UIWindow*) window;

/**********************************************
 * Set the main navigation controller.
 * New views will be added as children of this.
 **********************************************/
//- (void) setMainNavigationController: (UINavigationViewController*) controller;

/**********************************************************************
 * Register a new view controller with the manager with a unique name
 **********************************************************************/
- (void) registerViewController: (NSString*) name: (UIViewController*) controller;
- (BOOL) isViewControllerExisted: (NSString*) name;
- (void) bringViewControllerToFront: (NSString*) name;

/***********************************************
 * Hide main navigation view's top blue bar
 ***********************************************/
- (void) hideNavigationBar: (BOOL)hidden;
- (void) hideStatusBar: (BOOL)hidden;
/************************************************
 * Go to main navigation view
 ************************************************/
- (void) goToMainNavigationView;

/*****************************************************************************
 * Map window point to screen's top left (0, 0)
 * for easier manipulation.
 * Necessary when the status bar is hidden and the window frame is shifted up.
 ******************************************************************************/
//- (CGPoint) mapWindowPointToScreen: (CGPoint) point;
@end
