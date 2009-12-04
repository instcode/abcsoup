//
//  Created by Son Hua on 01/08/09.
//  Copyright 2009 Aptus Ventures. All rights reserved.
//

// default is commercial version with full features
//#define LITE_VERSION

#define VIEW_BOARD_SIZE 10
#define DEFAULT_BOARD_SIZE 19

#define MIN_SEARCH_DEPTH 3
#define MAX_SEARCH_DEPTH 7
#define DEFAULT_SEARCH_DEPTH 5

// option
#define CUR_DEPTH 2
#define NUM_DEPTHS 3

// the surrounding area that do not allow the cursor to focus on
#define EPSILON_SIZE 2

//-------------------------------------------------------------------
#define LIMIT_X 64		// the upper left bound region to touch to return to the main navigation view
#define LIMIT_Y 64

//
// Event ID
//
#define EVENT_TOUCH_BEGAN 1
#define EVENT_TOUCH_MOVED 2

//
// Mathematics constant
//
#define FLOAT_INFINITY 1.0e16
#define max(a, b) (a > b ? a : b)
#define min(a, b) (a < b ? a : b)
