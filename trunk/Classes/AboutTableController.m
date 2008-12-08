//
//  AboutTableController.m
//  JouzuGomoku
//
//  Created by Son Hua on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AboutTableController.h"


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
				   nil];
	objects	= [NSArray arrayWithObjects:
			   @"1.0",
			   @"08/12/2008",
			   @"Aptus Ventures", 
			   nil];
	
	return [keys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

