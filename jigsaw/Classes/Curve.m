//
//  Curve.m
//  Jigsaw
//
//  Created by Son Hua on 8/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "Curve.h"

#include "Point.h"
#include "Triangle.h"
#include <stdio.h>

@implementation Curve


@synthesize nbPoints, points;
@synthesize width, height;

- (id) initWithFile: (NSString*) _file {
	if ((self = [super init]) != NULL) {
		file = _file;
		
		[self parseCurve];
	}
	return self;
}

- (void) parseCurve {
	NSString* path = [[NSBundle mainBundle] pathForResource: file ofType: NULL];
	const char* cFile = [path cStringUsingEncoding: [NSString defaultCStringEncoding]];
	FILE* f = fopen(cFile, "r");
	NSAssert(f != NULL, @"Curve file not loaded.");
	
	fscanf(f, "%d %d", &width, &height);
	fscanf(f, "%d", &nbPoints);
	
	points = (struct JPoint*) malloc(sizeof(struct JPoint) * nbPoints);
	int x, y;
	for (int i = 0; i < nbPoints; ++i) {
		fscanf(f, "%d %d", &x, &y); // integer read in.
		
		points[i].x = x;	// convert to float
		points[i].y = y;
		points[i].z = 0.0f; // assume z = 0 for 2D
		
		//printf("Read in: %f %f\n", points[i].x, points[i].y);
	}
	fclose(f);
}


@end
