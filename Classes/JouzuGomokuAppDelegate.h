//
//  JouzuGomokuAppDelegate.h
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JouzuGomokuViewController;

@interface JouzuGomokuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    JouzuGomokuViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JouzuGomokuViewController *viewController;

@end

