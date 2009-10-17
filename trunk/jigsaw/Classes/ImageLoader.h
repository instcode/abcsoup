//
//  ImageLoader.h
//  Jigsaw
//
//  Created by Son Hua on 26/09/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>


unsigned char* GetImagePixelData(CGImageRef inImage);

@interface ImageLoader : NSObject {
@private
	NSMutableDictionary* dictImage; // keep track of the number of loaded images
}

/**
 Singleton
 */
+ (ImageLoader*) instance;

/**
 Load an image into current dictionary
 */
- (CGImageRef) loadImage: (NSString*) file;

/**
 Render CGImage into a RGBA context and read back the pixels
 */
- (unsigned char*) getImagePixelData: (CGImageRef) inImage: (int) channels;

/**
 Save to PPM format (for debug)
 */
- (void) saveImage: (CGImageRef) inImage: (NSString*) file;

@end
