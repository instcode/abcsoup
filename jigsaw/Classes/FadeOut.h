//
//  FadeOut.h
//  Jigsaw
//
//  Created by Son Hua on 2010-03-20.
//  Copyright 2010 Aptus Ventures, LLP. All rights reserved.
//

#import "Renderable.h"
#import "Jigsaw.h"

@interface FadeOut : Renderable {
	Jigsaw* jigsaw;
	int fadeInTime;		// in miliseconds
	int curTimeElapsed;	
	float alpha;
}

@end
