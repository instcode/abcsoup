//
//  Splash.m
//  Jigsaw
//
//  Created by Son Hua on 2010-03-20.
//  Copyright 2010 Aptus Ventures, LLP. All rights reserved.
//

#import "Splash.h"
#import "TextureManager.h"

@implementation Splash
- (void) load {
	jigsaw = [Jigsaw instance];
	
	// load splash textures
	texSplash = [[TextureManager instance] loadTexture3: @"splashTexture.png"];
	
	isDone = false;
}


- (void) update: (int) delta {
	
}


- (void) render {
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glBindTexture(GL_TEXTURE_2D, texSplash);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	const float squareVertices[] = {
		1.0f, -1.0f,
		1.0f, 1.0f, 
		-1.0f, -1.0f,
		-1.0f, 1.0f
	};
	const float squareTexCoords[] = {
		320.0f / 512,	1.0f - 320.0f / 512, 
		320.0f / 512,	1.0f - 0.0f, 
		0.0f,			1.0f - 320.0f / 512,
		0.0f,			1.0f - 0.0f
	};
	float screenSize	= jigsaw.screenRect.size.width;
	float top			= 0.5f * (jigsaw.screenRect.size.height - jigsaw.screenRect.size.width);
	
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, squareTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glPushMatrix();
	glTranslatef(0.0f, top, 0.0f);
	glScalef(screenSize * 0.5f, screenSize * 0.5f, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
}

- (bool) isDone {
	return isDone;
}

- (void) reset {
	
}

- (void) onTouchMoved: (struct JPoint) p {
	
}

- (void) onTouchBegan: (struct JPoint) p {
	
}

- (void) onTouchEnded: (struct JPoint) p {
	isDone = true;
}



@end
