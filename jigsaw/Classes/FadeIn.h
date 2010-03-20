//
//  FadeIn.h
//  Jigsaw
//
//  Created by Son Hua on 2010-03-20.
//  Copyright 2010 Aptus Ventures, LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Renderable.h"
#import "Jigsaw.h"

@interface FadeIn : Renderable {
	Jigsaw* jigsaw;
	int fadeInTime;		// in miliseconds
	int curTimeElapsed;	
	float alpha;
}

@end
