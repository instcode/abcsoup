//
//  TextureManager.h
//  Jigsaw
//
//  Created by Son Hua on 26/09/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

@interface TextureManager : NSObject {
@private
	NSMutableDictionary* dictTexture;
	GLuint curJigsawPhoto;
}

/**
 Singleton
 */
+ (TextureManager*) instance;

/**
 Get current texture 
 */
- (GLuint) getJigsawPhoto;
/**
 File name to get correspondent texture
 */
- (GLuint) getJigsawPhoto: (NSString*) file;
/**
 Full file path to load texture
 */
- (GLuint) loadJigsawPhoto: (NSString*) file;

@end
