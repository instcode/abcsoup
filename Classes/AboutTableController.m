//
//  AboutTableController.m
//  JouzuGomoku
//
//  Created by Son Hua on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AboutTableController.h"
#import "Constant.h"

@implementation AboutTableController
@synthesize keys, objects;

- (void)awakeFromNib {
		
}
- (id)init {
	return self;
}
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
    // why init in other functions, including awakeFromNib not worked?
	keys		= [NSArray arrayWithObjects:
				   @"Version", 
				   @"Build",
				   @"Copyright", 
				   
//#ifdef LITE_VERSION
//				   @"What's new?",
//#endif
				   nil];
	objects	= [NSArray arrayWithObjects:
#ifdef LITE_VERSION
			   @"1.0 Lite",
#else
			   @"1.0",
#endif
			   @"17/12/2008",
			   @"Aptus Ventures",
//#ifdef LITE_VERSION
//			   @"Undo, hint, auto scroll",
//#endif
			   nil];
	
	return [keys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.row != 3) {
		static NSString *CellIdentifier = @"dictAboutCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		// configure the cell
		cell.text = [keys objectAtIndex:indexPath.row];
		UILabel* rhsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 160, 20)];
		rhsLabel.textAlignment = UITextAlignmentRight;
		rhsLabel.textColor = [UIColor colorWithRed:0.1961 green:0.3098 blue:0.5216 alpha:1];
		//rhsLabel.numberOfLines = 2;
		//rhsLabel.font = [UIFont systemFontOfSize:12.0];
		rhsLabel.text = [objects objectAtIndex:indexPath.row];
		cell.accessoryView = rhsLabel;
		[rhsLabel release];		
		return cell;
	//} else {
	/*
		// add a custom height cell to advertise the full version
		NSString* adIdentifier = @"dictAdCell";
		UITableViewCell* cell;// = [tableView dequeueReusableCellWithIdentifier:adIdentifier];
		//if (cell == nil) {
			//cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, 300) reuseIdentifier:adIdentifier] autorelease];
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, 40)] autorelease];
		
		//}
		
		// create ad label
		UILabel* adLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 100)] autorelease];
		adLabel.text = [objects objectAtIndex:indexPath.row];
		adLabel.textColor = [UIColor colorWithRed:0.1961 green:0.3098 blue:0.5216 alpha:1];
		//adLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		[cell.contentView addSubview:adLabel];
		//cell.contentView = adLabel;
		return cell;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
#ifdef LITE_VERSION
	UIAlertView* adAlert = [[UIAlertView alloc] initWithTitle:@"What's New?" message:@"The full version of Gomoku offers intelligent scrolling, color hints, and undo features to give the game more fun. Please purchase from AppStore and get challenges from our Gomoku's true power!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[adAlert show];
#endif
}

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

