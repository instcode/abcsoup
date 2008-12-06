//
//  OptionTableController.m
//  JouzuGomoku
//
//  Created by Tuan Luu on 12/2/08.
//  Copyright 2008 NUS. All rights reserved.
//

#import "Constant.h"
#import "Gomoku.h"
#import "OptionTableController.h"

@implementation OptionTableController
@synthesize keys, objects;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    keys		= [NSArray arrayWithObjects:
				   @"Difficulty", 
				   @"Human",
				   //@"Color", 
				   nil];
	objects	= [NSArray arrayWithObjects:
			   @"Hard",
			   @"Human/Computer",
			   //@"Black & White", 
			   nil];
	gomokuModel = [Gomoku getGomokuModel];
	return [keys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	cell.text = [keys objectAtIndex:indexPath.row];
	
	switch (indexPath.row) {
		case 0: {
			UISlider* difficulty = [[[UISlider alloc] initWithFrame:CGRectMake(0, 12, 160, 20)] autorelease];
			[difficulty setMinimumValue:MIN_SEARCH_DEPTH];
			[difficulty setMaximumValue:MAX_SEARCH_DEPTH];
			[difficulty setValue:gomokuModel.searchDepth];
			[difficulty setContinuous:false];
			[difficulty addTarget:self action:@selector(difficultyValueChanged:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = difficulty;
			break;
		}
		case 1: {
			NSString* blackName = [[NSBundle mainBundle] pathForResource:@"black" ofType:@"png"];
			NSString* whiteName = [[NSBundle mainBundle] pathForResource:@"white" ofType:@"png"];
			
			UIImage* imgBlack = [[UIImage imageWithContentsOfFile:blackName] autorelease];
			UIImage* imgWhite = [[UIImage imageWithContentsOfFile:whiteName] autorelease];
			
			//NSArray* items = [NSArray arrayWithObjects:@"Black", @"White", nil];
			NSArray* items = [NSArray arrayWithObjects:imgBlack, imgWhite, nil];
			UISegmentedControl* mode = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
			[mode setFrame:CGRectMake(0, 12, 160, 35)];
			/*
			if (gomokuModel.computerMoveFirst) // computer black, human white
				mode.selectedSegmentIndex = 1;
			else // human black, computer white
				mode.selectedSegmentIndex = 0;
			 */
			mode.selectedSegmentIndex = gomokuModel.computerMoveFirst;
			mode.momentary = false;
			[mode addTarget:self action:@selector(modeValueChanged:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = mode;
			break;
		}
		default: {
			UILabel* rhsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 160, 20)];
			rhsLabel.textAlignment = UITextAlignmentRight;
			rhsLabel.textColor = [UIColor colorWithRed:0.1961 green:0.3098 blue:0.5216 alpha:1];
			//rhsLabel.numberOfLines = 2;
			//rhsLabel.font = [UIFont systemFontOfSize:12.0];
			rhsLabel.text = [objects objectAtIndex:indexPath.row];
			cell.accessoryView = rhsLabel;
			[rhsLabel release];
			break;
		}
	}
	
	return cell;
}

- (void) difficultyValueChanged: (id)sender {
	UISlider* slider = (UISlider*)sender;
	int d = round(slider.value);
	if (d % 2 == 0) d++;
	if (d > MAX_SEARCH_DEPTH) d = MAX_SEARCH_DEPTH;
	
	slider.value = d;
	gomokuModel.searchDepth = d;
}

- (void) modeValueChanged: (id)sender {
	UISegmentedControl* mode = (UISegmentedControl*)sender;
	if (gomokuModel.computerMoveFirst != mode.selectedSegmentIndex) { // changed
		gomokuModel.computerMoveFirst = mode.selectedSegmentIndex;
		[gomokuModel restart];
	}
	/*
	if (mode.selectedSegmentIndex == 0) { // human black
		gomokuModel.computerMoveFirst = 0;
		[gomokuModel restart];
	} else { // human white
		gomokuModel.computerMoveFirst = 1;
		[gomokuModel restart];
	}*/
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/

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

