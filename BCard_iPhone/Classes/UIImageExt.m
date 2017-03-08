//
//  UIImageExt.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 01/03/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "UIImageExt.h"


CGContextRef createBitmapContext(int pixelsWide, int pixelsHigh) {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef bitmapContext = CGBitmapContextCreate (nil, pixelsWide, pixelsHigh, 8, 0, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);
	
	return bitmapContext;
}


@implementation UIImage (UIImageCreationExt)

+ (UIImage*)imageWithName:(NSString*)name {
	NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
	UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
	return image;
}

@end


@implementation UIImage (UIImageResizeCropRotExt)
- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize {
	return [self resizedImageToFitInSize:boundingSize withTranspBorder:0];
}

- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize withTranspBorder:(NSUInteger)borderSize {
	// 1. Compute the final size to keep the aspect ratio
	CGSize dstSize = CGSizeZero;

	CGFloat wRatio = boundingSize.width / self.size.width;
	CGFloat hRatio = boundingSize.height / self.size.height;
	
	if (wRatio < hRatio) {
		dstSize = CGSizeMake(boundingSize.width, (NSUInteger) (self.size.height * wRatio));
	} else {
		dstSize = CGSizeMake((NSUInteger) (self.size.width * hRatio), boundingSize.height);
	}
	
	if (borderSize > 0) {
		dstSize = CGSizeMake(dstSize.width + borderSize * 2, dstSize.height + borderSize * 2);
	}
	
	// 2. Resize image
	CGAffineTransform transform = CGAffineTransformIdentity;
	BOOL transpose = NO;
	
	switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, dstSize.width, dstSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, dstSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
			transpose = YES;
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, dstSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
			transpose = YES;
            break;
    }
	
	CGContextRef context = createBitmapContext(dstSize.width, dstSize.height);

	CGContextConcatCTM(context, transform);
	
	if (transpose) {
		dstSize = CGSizeMake(dstSize.height, dstSize.width);
	}
	
	CGContextDrawImage(context, CGRectMake(borderSize, borderSize, dstSize.width - borderSize * 2, dstSize.height - borderSize *2 ), [self CGImage]);
	
	// 3. Get thumbnail
	UIImage* image = nil;
	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	
	if (borderSize > 0) {
		CGImageRef maskImageRef = [self newBorderMask:borderSize size:dstSize];
		CGImageRef transparentBorderImageRef = CGImageCreateWithMask(cgImage, maskImageRef);
		image = [UIImage imageWithCGImage:transparentBorderImageRef];
		
		CGImageRelease(maskImageRef);
		CGImageRelease(transparentBorderImageRef);
		
	} else {
		image = [UIImage imageWithCGImage:cgImage];
	}

	CGImageRelease(cgImage);
	CGContextRelease(context);
	
	return image;
}

- (UIImage*)croppedImageFromRect:(CGRect)cropRect {
	CGImageRef imageRef = CGImageCreateCopy(self.CGImage);
	CGImageRef newImageRef = CGImageCreateWithImageInRect(imageRef, cropRect);
	CGImageRelease(imageRef);
	
	UIImage* image = [UIImage imageWithCGImage:newImageRef];
	CGImageRelease(newImageRef);
	
	return image;
}

CGRect swapWidthAndHeight(CGRect rect) {
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

- (UIImage*)rotate:(UIImageOrientation)orientation {
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = self.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
	
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orientation) {
        case UIImageOrientationUp:
			// would get you an exact copy of the original
			assert(false);
			return nil;
			
        case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
        case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
        case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
        case UIImageOrientationLeft:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationLeftMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationRight:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        case UIImageOrientationRightMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
    }
	
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
	
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
        default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
    }
	
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return copy;
}




@end


@implementation UIImage (UIImageAlphaExt)

- (UIImage*)transparentBorderImage:(NSUInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
	// New image size with border
    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
    
    // Build a context that's the same dimensions as the new size
	CGContextRef bitmap = createBitmapContext(newRect.size.width, newRect.size.height);
	
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, self.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage* transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage*)imageWithAlpha {
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
	if (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast) {
		return self;
	}
    
    CGImageRef imageRef = self.CGImage;
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = createBitmapContext(width, height);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage* imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL, size.width, size.height,
                                                     8, // 8-bit grayscale
                                                     0, colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}

@end
