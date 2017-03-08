//
//  PhotoResizerController.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 15/06/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CropRectView;
@protocol PhotoResizerControllerDelegate;

@interface PhotoResizerController : UIViewController <UIScrollViewDelegate> {
	NSObject<PhotoResizerControllerDelegate>* m_Delegate;
	UIImage* m_OriginalImage;
	
	CGRect m_CropRect;
	
	UIView*			m_ContentView;
	UIScrollView*	m_ScrollView;
	UIImageView*	m_ImageView;
	CropRectView*	m_CropRectView;
	
	UIBarButtonItem* m_TitleItem;
}

@property(nonatomic, assign) NSObject<PhotoResizerControllerDelegate>* delegate;
@property(nonatomic, retain) UIImage* originalImage;
@property(nonatomic, readwrite) CGRect cropRect;
@property(nonatomic, retain) IBOutlet UIView* contentView;
@property(nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property(nonatomic, retain) IBOutlet UIImageView* imageView;
@property(nonatomic, retain) IBOutlet CropRectView* cropRectView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* titleItem;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;

@end

@protocol PhotoResizerControllerDelegate <NSObject>
@optional
- (void)photoResizerControllerDidSave:(PhotoResizerController*)picker;
- (void)photoResizerControllerDidCancel:(PhotoResizerController*)picker;
@end
