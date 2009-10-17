//
//  ImageLoader.m
//  Jigsaw
//
//  Created by Son Hua on 26/09/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "ImageLoader.h"

/*************************************************************
 * Create a RGBA context for bitmap
 *************************************************************/
CGContextRef CreateRGBABitmapContext (CGImageRef inImage)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
	
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
	
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
	
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast); // RGBA, if first is used then ARGB
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
	
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
	
    return context;
}

/*************************************************************
 * Create a RGB (3 channels) context for bitmap
 *************************************************************/
CGContextRef CreateRGBBitmapContext (CGImageRef inImage)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
	
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    // Use the generic RGB color space.
    //colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
	
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
	
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaNoneSkipFirst); // RGBA, if first is used then ARGB
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
	
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
	
    return context;
}


@implementation ImageLoader

static ImageLoader* imgLoader;
+ (ImageLoader*) instance {
	if (imgLoader == NULL) {
		imgLoader = [[ImageLoader alloc] init];
	}
	return imgLoader;
}

- (unsigned char*) getImagePixelData: (CGImageRef) inImage: (int) channels;
{
    // Create the bitmap context
	CGContextRef cgctx;
	switch (channels) {
		case 3:
			cgctx = CreateRGBBitmapContext(inImage);
			break;
		case 4:
			cgctx = CreateRGBABitmapContext(inImage);
			break;
		default:
			break;
	}
    if (cgctx == NULL) 
    { 
        // error creating context
        return NULL;
    }
	
	// Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}}; 
	
    // Draw the image to the bitmap context. Once we draw, the memory 
    // allocated for the context for rendering will then contain the 
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage); 
	
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    void *data = CGBitmapContextGetData (cgctx);
    unsigned char* buffer = NULL;
	if (data != NULL)
    {
		int size = w * h * channels;
		buffer = malloc(size);
		memcpy(buffer, data, size);
        // **** You have a pointer to the image data ****
		
        // **** Do stuff with the data here ****
		
    }
	
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
	return buffer;
}

- (CGImageRef) loadImage: (NSString*) file {
	CGImageRef imgRef;
	if ([dictImage valueForKey:file] == NULL) {
		// load an UIImage
		//NSString* sampleFileName = [[NSBundle mainBundle] pathForResource:@"frame0" ofType:@"png"];
		NSString* sampleFileName = [[NSBundle mainBundle] pathForResource:file ofType: nil];
		UIImage* imgSample = [UIImage imageWithContentsOfFile:sampleFileName];
		
		// house keeping
		[dictImage setValue:(id)(imgSample.CGImage) forKey:file];
		
		imgRef = imgSample.CGImage;
	} else {
		imgRef = (CGImageRef)[dictImage valueForKey:file];
	}
	return imgRef;
}
	 
- (id) init {
	if ((self = [super init]) != NULL) {
		dictImage = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void) saveImage: (CGImageRef) inImage: (NSString*) file 
{
	unsigned char* data = [self getImagePixelData:inImage :3];
	int width = CGImageGetWidth(inImage);
	int height = CGImageGetHeight(inImage);
	FILE *pFile;
	char szFilename[256];
	
	// Open file
	sprintf(szFilename, "%s.ppm", [file UTF8String]);
	pFile=fopen(szFilename, "wb"); // w, not wb (we write in ascii)
	if(pFile==NULL)
		return;
	
	// Write header
	fprintf(pFile, "P6\n%d %d\n255\n", width, height);
	
	// Write pixel data
	int size = width * height * 4;//!!!
	fwrite(data, 1, size, pFile);
	
	// Close file
	fclose(pFile);
	
	free(data);
}
/*
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
	
	// == Load the ffmpeg test
	// Load an UIImage
	NSString* sampleFileName = [[NSBundle mainBundle] pathForResource:@"frame0" ofType:@"png"];
	
	UIImage* imgSample = [UIImage imageWithContentsOfFile:sampleFileName];
	
	// Read raw data and pass to ffmpeg test
	CGDataProviderRef provider = CGImageGetDataProvider(imgSample.CGImage);
	CFDataRef bitmapData = CGDataProviderCopyData(provider);
	
	int size = imgSample.size.width * imgSample.size.height * 3;
	
	// for safety, copy the mage to another location before passing in
	/*
	 UInt8* buffer = malloc(size);
	 CFDataGetBytes(bitmapData, CFRangeMake(0, CFDataGetLength(bitmapData)), buffer);
	 encode_main(buffer, imgSample.size.width, imgSample.size.height);
	 free(buffer);
	 */
	/*
	 UInt8* data = CFDataGetBytePtr(bitmapData); //get the internal byte pointer, read-only
	 encode_main(data, imgSample.size.width, imgSample.size.height);
	 */
	
/*
	unsigned char* data4 = GetImagePixelData(imgSample.CGImage);
	//encode_main(data4, imgSample.size.width, imgSample.size.height);
	encode_main_stream(data4, imgSample.size.width, imgSample.size.height);
	
}
*/

@end
