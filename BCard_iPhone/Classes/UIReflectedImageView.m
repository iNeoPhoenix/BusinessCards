//
//  UIReflectedImageView.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 14/04/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "UIReflectedImageView.h"


@implementation UIReflectedImageView

@synthesize image = m_Image;

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext(); 
	
	// Memory
	//CGContextScaleCTM(context, 1, -1);
	//CGContextTranslateCTM(context, 0, -rect.size.height);
	//[self.image drawInRect:rect];
	
	CGRect myFrame   = self.frame;
	CGSize imageSize = m_Image.size;
	
	CGFloat wRatio = myFrame.size.width  / imageSize.width;
	CGFloat hRatio = myFrame.size.height / imageSize.height;
	
	CGRect finalRect;
	
	if (wRatio < hRatio) {
		NSUInteger newHeight = (NSUInteger) (m_Image.size.height * wRatio);
		CGFloat y = (myFrame.size.height - newHeight) / 2;
		finalRect = CGRectMake(0, y, myFrame.size.width, newHeight);
	} else {
		NSUInteger newWidth = (NSUInteger) (m_Image.size.width * hRatio);
		CGFloat x = (myFrame.size.width - newWidth) / 2;
		finalRect = CGRectMake(x, 0, newWidth, myFrame.size.height);
	}
	
	CGContextDrawImage(context, finalRect, [self.image CGImage]);
}

- (void)dealloc {
	self.image = nil;
    [super dealloc];
}

@end
