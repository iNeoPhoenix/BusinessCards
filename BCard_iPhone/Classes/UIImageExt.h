//
//  UIImageExt.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 01/03/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "Foundation/Foundation.h"

@interface UIImage (UIImageCreationExt)
+ (UIImage*)imageWithName:(NSString*)name; // load from main bundle
@end

@interface UIImage (UIImageResizeCropRotExt)
- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize;
- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize withTranspBorder:(NSUInteger)borderSize;
- (UIImage*)croppedImageFromRect:(CGRect)cropRect;
- (UIImage*)rotate:(UIImageOrientation)orientation;
@end

@interface UIImage (UIImageAlphaExt)
- (UIImage*)transparentBorderImage:(NSUInteger)borderSize;
- (UIImage *)imageWithAlpha;
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;
@end
