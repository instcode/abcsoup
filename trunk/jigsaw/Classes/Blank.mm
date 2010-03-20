//
//  Blank.m
//  Jigsaw
//
//  Created by Son Hua on 2010-03-20.
//  Copyright 2010 Aptus Ventures, LLP. All rights reserved.
//

#import "Blank.h"

@implementation Blank

- (void) render {
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
}

- (bool) isDone {
	return true;
}

@end
