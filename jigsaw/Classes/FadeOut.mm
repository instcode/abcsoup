//
//  FadeOut.m
//  Jigsaw
//
//  Created by Son Hua on 3/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FadeOut.h"

@implementation FadeOut
- (void) reset {
	curTimeElapsed	= 0;
	alpha			= 0.0f;
}

- (void) load {
	jigsaw			= [Jigsaw instance];
	fadeInTime		= 1000;
	[self reset];
}

- (void) update: (int) delta {
	curTimeElapsed += delta;
	
	alpha = curTimeElapsed * 1.0f / fadeInTime;
}

- (void) render {
	const float squareVertices[] = {
		1.0f, -1.0f,
		1.0f, 1.0f, 
		-1.0f, -1.0f,
		-1.0f, 1.0f
	};
	glEnable(GL_BLEND);
	//glDisable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_TEXTURE_2D);
	glColor4f(0.0f, 0.0f, 0.0f, alpha);
	//glColor4f(alpha, alpha, alpha, 1.0f);
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glPushMatrix();
	glScalef(jigsaw.screenRect.size.width * 0.5f, jigsaw.screenRect.size.height * 0.5f, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
}

- (bool) isDone {
	return (curTimeElapsed > fadeInTime);
}


- (void) onTouchMoved: (struct JPoint) p {
	
}

- (void) onTouchBegan: (struct JPoint) p {
	
}

- (void) onTouchEnded: (struct JPoint) p {
	
}
@end