//
//  TextureManager.m
//  Jigsaw
//
//  Created by Son Hua on 26/09/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "TextureManager.h"
#import "ImageLoader.h"

@implementation TextureManager
static TextureManager* texManager;
+ (TextureManager*) instance {
	if (texManager == NULL) {
		texManager = [[TextureManager alloc] init];
	}
	return texManager;
}

- (id) init {
	if ((self = [super init]) != NULL) {
		dictTexture = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void) dealloc {
	[dictTexture release];
	[super dealloc];
}

- (GLuint) getJigsawPhoto {
	return curJigsawPhoto;
}

/*
- (GLuint) getJigsawPhoto: (NSString*) file {
	return [(NSNumber*) [dictTexture valueForKey:file] unsignedIntValue];;
}*/

- (GLuint) loadTexture3: (NSString*) file {
	GLuint tex;
	if ([dictTexture valueForKey:file] == NULL) {
		// load texture unit
		ImageLoader* imgLoader = [ImageLoader instance];
		CGImageRef imgRef = [imgLoader loadImage:file];
		unsigned char* pixels = [imgLoader getImagePixelData: imgRef: 3];
		
		glGenTextures(1, &tex);
		glBindTexture(GL_TEXTURE_2D, tex);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, CGImageGetWidth(imgRef), CGImageGetHeight(imgRef), 0, GL_RGB, GL_UNSIGNED_BYTE, pixels);
		
		
		// house keeping
		[dictTexture setValue:[NSNumber numberWithUnsignedInt:tex] forKey:file];
		free(pixels);
		//[imgLoader saveImage:imgRef :@"/Users/sonhua/Workspace/Jigsaw/manutd0"];
	} else {
		tex = [(NSNumber*) [dictTexture valueForKey:file] unsignedIntValue];
	}
	return tex;
}	

- (GLuint) loadTexture4: (NSString*) file {
	GLuint tex;
	if ([dictTexture valueForKey:file] == NULL) {
		// load texture unit
		ImageLoader* imgLoader = [ImageLoader instance];
		CGImageRef imgRef = [imgLoader loadImage:file];
		unsigned char* pixels = [imgLoader getImagePixelData: imgRef: 4];
		
		glGenTextures(1, &tex);
		glBindTexture(GL_TEXTURE_2D, tex);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, CGImageGetWidth(imgRef), CGImageGetHeight(imgRef), 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
		
		// house keeping
		[dictTexture setValue:[NSNumber numberWithUnsignedInt:tex] forKey:file];
		free(pixels);
		//[imgLoader saveImage:imgRef :@"/Users/sonhua/Workspace/Jigsaw/manutd0"];
	} else {
		tex = [(NSNumber*) [dictTexture valueForKey:file] unsignedIntValue];
	}
	return tex;
}	
@end
