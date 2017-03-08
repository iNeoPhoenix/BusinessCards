//
//  DisplayBCardViewController.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 10/03/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "PhotoResizerController.h"

@class BCard, Photo, UIReflectedImageView, DisplayContactController;

typedef enum {
    DisplayBCardViewControllerStateConsult  = 0,
    DisplayBCardViewControllerStateEdit     = 1,
	DisplayBCardViewControllerStateCreate	= 2
} DisplayBCardViewControllerState;

@protocol DisplayBCardViewControllerDelegate <NSObject>
@required
- (void)displayBCardViewControllerWantsRemovalOfBCard:(BCard*)bCard;
- (void)displayBCardViewControllerWantsEmailBCard:(BCard*)bCard;
@end

@interface DisplayBCardViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoResizerControllerDelegate> {
	DisplayBCardViewControllerState m_State;
	
	BCard* m_BCard;
	
	Photo* m_FrontPhoto;
	Photo* m_BackPhoto;
	
	BOOL m_FirstAppearance;
	
	NSObject<DisplayBCardViewControllerDelegate>* m_Delegate;
	
	// IU & Controls
	UIBarButtonItem* m_EditItem;
	UIBarButtonItem* m_MailItem;
	UIBarButtonItem* m_DeleteItem;
	UIImageView*	 m_BackgroundImageView;
	
	// Card
	UIView* m_MainContainer;
	UIView* m_ReflectedContainer;
	
	UIImage* m_FrontImage;
	UIImage* m_BackImage;
		
	UILabel* m_FrontLabel;
	UILabel* m_BackLabel;
	
	UIButton* m_RotateFrontCardButton;
	UIButton* m_RotateBackCardButton;
	UIActivityIndicatorView* m_RotateFrontCardSpinner;
	UIActivityIndicatorView* m_RotateBackCardSpinner;
	
	UIImageView* m_FrontImageView;
	UIImageView* m_BackImageView;
	UIReflectedImageView* m_ReflectedFrontImageView;
	UIReflectedImageView* m_ReflectedBackImageView;
	
	DisplayContactController* m_DisplayContactController;
	
	CATransform3D m_Transform;
	CGFloat m_Scale;
	CGPoint m_Translation;
	
	BOOL m_IsModifyingFrontPhoto;
	
	UIImage* m_TempFrontOriginalImage;
	CGRect	 m_TempFrontCropRect;
	UIImage* m_TempBackOriginalImage;
	CGRect	 m_TempBackCropRect;
	
	BOOL m_DisplayCropView;
}

@property (nonatomic, assign) NSObject<DisplayBCardViewControllerDelegate>* delegate;

@property (nonatomic, readwrite) DisplayBCardViewControllerState state;
@property (nonatomic, retain) BCard* bCard; 

@property (nonatomic, retain) IBOutlet UIBarButtonItem* editItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* mailItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* deleteItem;
@property (nonatomic, retain) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, retain) IBOutlet UIView* mainContainer;
@property (nonatomic, retain) IBOutlet UIView* reflectedContainer;
@property (nonatomic, retain) IBOutlet UILabel* frontLabel;
@property (nonatomic, retain) IBOutlet UILabel* backLabel;
@property (nonatomic, retain) IBOutlet UIButton* rotateFrontCardButton;
@property (nonatomic, retain) IBOutlet UIButton* rotateBackCardButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* rotateFrontCardSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* rotateBackCardSpinner;

@property (nonatomic, retain) UIImage* frontImage;
@property (nonatomic, retain) UIImage* backImage;
@property (nonatomic, retain) IBOutlet UIImageView* frontImageView;
@property (nonatomic, retain) IBOutlet UIImageView* backImageView;
@property (nonatomic, retain) IBOutlet UIReflectedImageView* reflectedFrontImageView;
@property (nonatomic, retain) IBOutlet UIReflectedImageView* reflectedBackImageView;

- (IBAction)editButtonAction:(id)sender;
- (IBAction)mailButtonAction:(id)sender;
- (IBAction)deleteButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)rotateFrontCardAction:(id)sender;
- (IBAction)rotateBackCardAction:(id)sender;

@end
