//
//  JigsawAppDelegate.h
//  Jigsaw
//
//  Created by Son Hua on 7/28/09.
//  Copyright 2009 Aptus Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameTableController.h"
#import "WindowsManager.h"

@class EAGLView;

@interface JigsawAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;								// main window
	UITabBarController* tabController;				// main tab (bottom)
	GameTableController* gameTableController;		// main game view in the first tab. When click Start, the game view will become fullscreen.
	UINavigationController* mainNavigationController; // the outmost navigation controller. Serve as a view transition place.

	WindowsManager* windowManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController* tabController;
@property (nonatomic, retain) IBOutlet GameTableController* gameTableController;
@property (nonatomic, retain) IBOutlet UINavigationController* mainNavigationController;
//@property (nonatomic, retain) IBOutlet EAGLView *glView;

- (IBAction)respondToButtonStartClick:(id)sender;	// handle start button click
@end

