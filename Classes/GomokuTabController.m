//
//  GomokuTabController.m
//  JouzuGomoku
//
//  Created by Tuan Luu on 11/12/08.
//  Copyright 2008 NUS. All rights reserved.
//

#import "GomokuTabController.h"
#import "Gomoku.h"
#import "GomokuModel.h"

@implementation GomokuTabController

- (void)awakeFromNib {
	1 == 1;
}

- (void)respondToButtonNewClick:(id)sender {
	GomokuModel* model = [Gomoku getGomokuModel];
	[model restart];
}
/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
