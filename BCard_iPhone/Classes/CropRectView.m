//
//  CropRectView.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 19/06/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "CropRectView.h"


@implementation CropRectView

@synthesize topLeftPin		= m_TopLeftPin;
@synthesize bottomRightPin	= m_BottomRightPin;
@synthesize cropRect		= m_CropRect;

- (void)awakeFromNib {
	// Gestures
	UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]; 
	[self.topLeftPin addGestureRecognizer:panGestureRecognizer];
	[panGestureRecognizer release];	
	
	panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
	[self.bottomRightPin addGestureRecognizer:panGestureRecognizer];
	[panGestureRecognizer release];	
}

- (void)dealloc {
	self.topLeftPin		= nil;
	self.bottomRightPin = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark UIView methods
- (void)drawRect:(CGRect)rect {
	CGSize contentSize   = self.frame.size;
	CGPoint topLeftPoint = self.topLeftPin.center;
	CGPoint bottomRigthPoint = self.bottomRightPin.center;
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	CGContextSetRGBFillColor(context, 0., 0., 0., .5);	

	// Top Rect
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, 0., 0.);
	CGPathAddLineToPoint(path, NULL, contentSize.width, 0.);
	CGPathAddLineToPoint(path, NULL, contentSize.width, topLeftPoint.y);
	CGPathAddLineToPoint(path, NULL, 0., topLeftPoint.y);
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// Right Rect
	path = CGPathCreateMutable(); 
	CGPathMoveToPoint(path, NULL, bottomRigthPoint.x, topLeftPoint.y);
	CGPathAddLineToPoint(path, NULL, contentSize.width, topLeftPoint.y);
	CGPathAddLineToPoint(path, NULL, contentSize.width, bottomRigthPoint.y);
	CGPathAddLineToPoint(path, NULL, bottomRigthPoint.x, bottomRigthPoint.y);
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// Right Rect
	path = CGPathCreateMutable(); 
	CGPathMoveToPoint(path, NULL, 0., bottomRigthPoint.y);
	CGPathAddLineToPoint(path, NULL, contentSize.width, bottomRigthPoint.y);
	CGPathAddLineToPoint(path, NULL, contentSize.width, contentSize.height);
	CGPathAddLineToPoint(path, NULL, 0., contentSize.height);
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);

	// Left Rect
	path = CGPathCreateMutable(); 
	CGPathMoveToPoint(path, NULL, 0., topLeftPoint.y);
	CGPathAddLineToPoint(path, NULL, topLeftPoint.x, topLeftPoint.y);
	CGPathAddLineToPoint(path, NULL, topLeftPoint.x, bottomRigthPoint.y);
	CGPathAddLineToPoint(path, NULL, 0., bottomRigthPoint.y);
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);

	// Center Rect
	CGContextSetRGBStrokeColor(context, 1./256., 93./256., 230./256., 1.);
	CGContextSetLineWidth(context, m_Scale);
	CGContextStrokeRect(context, CGRectMake(topLeftPoint.x, topLeftPoint.y, bottomRigthPoint.x - topLeftPoint.x, bottomRigthPoint.y - topLeftPoint.y));
}


#pragma mark -
#pragma mark Public methods
- (void)hidePins {
	self.topLeftPin.hidden		= YES;
	self.bottomRightPin.hidden  = YES;
	
	self.topLeftPin.alpha		= 0.;
	self.bottomRightPin.alpha	= 0.;
}

- (void)showPins {
	self.topLeftPin.hidden		= NO;
	self.bottomRightPin.hidden	= NO;
	
	[UIView beginAnimations:@"CropRectViewHediPinsAnimation" context:nil];
	[UIView setAnimationDuration:0.3];
	self.topLeftPin.alpha		= 1.;
	self.bottomRightPin.alpha	= 1.;
	[UIView commitAnimations];
}

- (void)setSuperViewScale:(CGFloat)scale {
	m_Scale = 1./scale;
	self.topLeftPin.transform		= CGAffineTransformMakeScale(m_Scale, m_Scale);
	self.bottomRightPin.transform	= CGAffineTransformMakeScale(m_Scale, m_Scale);
	
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Setters / Getters
- (CGRect)cropRect {
	CGRect rect = CGRectZero;
	
	rect.origin.x	 = m_TopLeftPin.center.x;
	rect.origin.y	 = m_TopLeftPin.center.y;
	rect.size.width  = m_BottomRightPin.center.x - m_TopLeftPin.center.x;
	rect.size.height = m_BottomRightPin.center.y - m_TopLeftPin.center.y;
	
	return rect;
}

- (void)setCropRect:(CGRect)rect {
	CGPoint point = CGPointMake(rect.origin.x, rect.origin.y);
	m_TopLeftPin.center = point;

	point = CGPointMake(self.topLeftPin.center.x + rect.size.width, self.topLeftPin.center.y + rect.size.height);
	m_BottomRightPin.center = point;
	
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Gestures
- (void)panGestureRecognized:(UIPanGestureRecognizer*)panGestureRecognizer {
	if (panGestureRecognizer.numberOfTouches > 0) {
		CGPoint newCenter = [panGestureRecognizer locationInView:self];

		CGFloat delta = 30 * m_Scale;
		if (panGestureRecognizer.view == m_TopLeftPin) {
			newCenter.x -= delta;
			newCenter.y -= delta;
			
		} else {
			newCenter.x += delta;
			newCenter.y += delta;
		}
		
		// Set limits
		// - Frame
		if (newCenter.x < 0) newCenter.x = 0;
		if (newCenter.x > self.frame.size.width) newCenter.x = self.frame.size.width;
		if (newCenter.y < 0) newCenter.y = 0;
		if (newCenter.y > self.frame.size.height) newCenter.y = self.frame.size.height;
		// - Pin1 > Pin2
		if (panGestureRecognizer.view == m_TopLeftPin) {
			if (newCenter.x > m_BottomRightPin.center.x - 200) newCenter.x = m_BottomRightPin.center.x - 200;
			if (newCenter.y > m_BottomRightPin.center.y - 200) newCenter.y = m_BottomRightPin.center.y - 200;
			
		} else {
			if (newCenter.x < m_TopLeftPin.center.x + 200) newCenter.x = m_TopLeftPin.center.x + 200;
			if (newCenter.y < m_TopLeftPin.center.y + 200) newCenter.y = m_TopLeftPin.center.y + 200;
			
		}
		
		panGestureRecognizer.view.center = newCenter;
		[panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
		
		[self setNeedsDisplay];
	}
}

@end
