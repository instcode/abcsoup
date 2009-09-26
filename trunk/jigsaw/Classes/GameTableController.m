//
//  GameTableController.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "GameTableController.h"
#import "EAGLView.h"
#import "WindowsManager.h"
#include "Text.h"

@implementation GameTableController

#define GAME_TABLE_NB_SECTIONS 2
#define GAME_TABLE_NB_LOAD_GAME_SLOTS 5
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
	// add a custom table header
	CGRect titleRect = CGRectMake(0, 0, 320, 40);
    NSString* title = @"Jigsaw";
	
	UINavigationBar* tableTitle = [[UINavigationBar alloc] initWithFrame:titleRect];
	UINavigationItem* barItem = [[UINavigationItem alloc] initWithTitle:title];
	[tableTitle pushNavigationItem:barItem animated:FALSE];
	/*
	
	UILabel *tableTitle = [[UILabel alloc] initWithFrame:titleRect];
    tableTitle.textColor = [UIColor blackColor];
    tableTitle.backgroundColor = [UIColor clearColor];
	tableTitle.shadowColor = [UIColor grayColor];
	tableTitle.shadowOffset = CGSizeMake(1, 1);
    tableTitle.opaque = YES;
    tableTitle.font = [UIFont boldSystemFontOfSize:24];
	tableTitle.textAlignment = UITextAlignmentCenter;
	
    tableTitle.text = @"Jigsaw";*/
	
		
	UITableView* tableView = (UITableView*)self.view;
	tableView.tableHeaderView = tableTitle;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return GAME_TABLE_NB_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) { 
		case 0: // first section, new game 
			return 1;
		case 1: // second section, load game
			return GAME_TABLE_NB_LOAD_GAME_SLOTS;
	}
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	switch (indexPath.section) {
		case 0:
		{
			cell.text = @GAME_TABLE_ROW_NEW_GAME;
			break;
		}
		case 1:
		{
			NSString* slot = [NSString stringWithFormat: @GAME_TABLE_ROW_SAVED_SLOT, (indexPath.row + 1)];
			cell.text = slot;
			break;
		}
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Returns section title 
    switch (section) {
		case 0:
		{
			return @GAME_TABLE_SECTION_NEW_GAME;
		}
		case 1:
		{
			return @GAME_TABLE_SECTION_LOAD_GAME;
		}
	}
	return @"";
}

/**********************************************
 * When a cell is selected, load game.
 **********************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
		
		// register with windows manager
		[manager registerViewController: glViewName: glViewController];
		
		// clear
		[glViewController release];
		[glView release];
	} 
	
	
	// now bring the new view to front
	[manager bringViewControllerToFront: glViewName];
}


/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
    [super dealloc];
}


@end

