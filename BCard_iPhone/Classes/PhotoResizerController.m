//
//  PhotoResizerController.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 15/06/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "PhotoResizerController.h"

#import <QuartzCore/QuartzCore.h>
#import "CropRectView.h"

@implementation PhotoResizerController

@synthesize delegate		= m_Delegate;
@synthesize originalImage	= m_OriginalImage;
@dynamic cropRect;
@synthesize contentView		= m_ContentView;
@synthesize imageView		= m_ImageView;
@synthesize scrollView		= m_ScrollView;
@synthesize cropRectView	= m_CropRectView;
@synthesize titleItem		= m_TitleItem;

- (void)dealloc {
	self.delegate		= nil;
	self.originalImage  = nil;
	self.contentView	= nil;
	self.imageView		= nil;
	self.scrollView		= nil;
	self.cropRectView	= nil;
	self.titleItem		= nil;
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	CGSize imageSize  =  m_OriginalImage.size;
	CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
	
	// Content View
	self.contentView.frame = imageFrame;
	
	// Crop Rect View
	self.cropRectView.frame = imageFrame;
	
	self.cropRectView.cropRect = m_CropRect;
	
	// Image View
	self.imageView.image = m_OriginalImage;
	self.imageView.frame = imageFrame;
	
	// Scroll View
	self.scrollView.contentSize = imageSize;
	self.scrollView.contentInset = UIEdgeInsetsMake(30, 30, 30, 30);
	self.scrollView.contentOffset = CGPointMake(300, 300);
	
	if (imageSize.width / imageSize.height > 320. / 430.) {
		self.scrollView.minimumZoomScale = 260. / imageSize.width;
	} else {
		self.scrollView.minimumZoomScale = 370 / imageSize.height;
	}
	
	self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale * 5.;
	self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
	
	self.titleItem.title = NSLocalizedString(@"PhotoResizerController_Title_Key", nil);
	
	// Center content
	//self.contentView.center = self.scrollView.center;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.contentView	= nil;
	self.scrollView		= nil;
	self.imageView		= nil;
	self.cropRectView	= nil;
	self.titleItem		= nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.cropRectView setSuperViewScale:self.scrollView.zoomScale];
	[self.cropRectView showPins];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark -
#pragma mark Setters / Getters
- (CGRect)cropRect {
	m_CropRect = self.cropRectView.cropRect;
	return m_CropRect;
}

- (void)setCropRect:(CGRect)rect {
	m_CropRect = rect;
	self.cropRectView.cropRect = m_CropRect;
}
	

#pragma mark -
- (IBAction)cancelButtonAction:(id)sender {
	if ([self.delegate respondsToSelector:@selector(photoResizerControllerDidCancel:)]) {
		[self.delegate performSelectorOnMainThread:@selector(photoResizerControllerDidCancel:) withObject:self waitUntilDone:NO];
	}
}

- (IBAction)saveButtonAction:(id)sender {
	if ([self.delegate respondsToSelector:@selector(photoResizerControllerDidSave:)]) {
		[self.delegate performSelectorOnMainThread:@selector(photoResizerControllerDidSave:) withObject:self waitUntilDone:NO];
	}
}


#pragma mark -
#pragma mark <UIScrollViewDelegate>
// called on finger up if user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self.cropRectView showPins];
}

// return a view that will be scaled. if delegate returns nil, nothing happens
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	[self.cropRectView hidePins];
	return self.contentView;
}

// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	[self.cropRectView setSuperViewScale:scale];
	[self.cropRectView showPins];
}

@end
