//
//  DisplayBCardViewController.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 10/03/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "DisplayBCardViewController.h"

// General
#import "BCard_iPhoneAppDelegate.h"
#import "AlertManager.h"

// Model
#import "BCard.h"
#import "Photo.h"
#import "DataManager.h"

// Useful
#import "UIImageExt.h"
#import "UIReflectedImageView.h"

// Controller
#import "DisplayContactController.h"
#import "MainNavigationController.h"


@interface DisplayBCardViewController ()

@property (nonatomic, retain) UIImage* tempFrontOriginalImage;
@property (nonatomic, readwrite) CGRect   tempFrontCropRect;
@property (nonatomic, retain) UIImage* tempBackOriginalImage;
@property (nonatomic, readwrite) CGRect   tempBackCropRect;
@property (nonatomic, retain) Photo* frontPhoto;
@property (nonatomic, retain) Photo* backPhoto;

- (void)setCardTransform;
- (CATransform3D)transformFront;
- (CATransform3D)transformBack;
- (CATransform3D)transformFrontReflected;
- (CATransform3D)transformBackReflected;
- (void)updateUI:(BOOL)animated;
- (void)updateBCardDataWithForceImageReload:(BOOL)forceImageReload;
- (void)updateBCarVisu;
- (BOOL)isFront;
- (void)presentFrontAndBackSides:(BOOL)animated;
- (void)presentOneSide:(BOOL)front animated:(BOOL)animated;
- (void)displayContact:(id)sender;
- (void)updateBCardImagesWithHiRes:(NSNumber*)hiRes;
- (void)imageSelected:(NSNumber*)isFront;
- (void)modifyFromLibrary;
- (void)modifyFromNewPhoto;
- (void)modifyCurrentPhoto;

// Gestures
- (void)tapGestureRecognized:(UITapGestureRecognizer*)tapGestureRecognizer;
- (void)panGestureRecognized:(UIPanGestureRecognizer*)panGestureRecognizer;
- (void)pinchGestureRecognized:(UIPinchGestureRecognizer*)pinchGestureRecognizer;
@end


@implementation DisplayBCardViewController

@synthesize delegate				= m_Delegate;
@synthesize state					= m_State;
@synthesize frontImage				= m_FrontImage;
@synthesize backImage				= m_BackImage;
@synthesize frontImageView			= m_FrontImageView;
@synthesize backImageView			= m_BackImageView;
@synthesize backgroundImageView		= m_BackgroundImageView;
@synthesize bCard					= m_BCard;
@synthesize mainContainer			= m_MainContainer;
@synthesize reflectedContainer		= m_ReflectedContainer;
@synthesize reflectedFrontImageView = m_ReflectedFrontImageView;
@synthesize reflectedBackImageView	= m_ReflectedBackImageView;
@synthesize editItem				= m_EditItem;
@synthesize mailItem				= m_MailItem;
@synthesize deleteItem				= m_DeleteItem;
@synthesize frontLabel				= m_FrontLabel;
@synthesize backLabel				= m_BackLabel;
@synthesize rotateFrontCardButton	= m_RotateFrontCardButton;
@synthesize rotateBackCardButton	= m_RotateBackCardButton;
@synthesize rotateFrontCardSpinner	= m_RotateFrontCardSpinner;
@synthesize rotateBackCardSpinner	= m_RotateBackCardSpinner;

@synthesize tempFrontCropRect		= m_TempFrontCropRect;
@synthesize tempFrontOriginalImage	= m_TempFrontOriginalImage;
@synthesize tempBackCropRect		= m_TempBackCropRect;
@synthesize tempBackOriginalImage	= m_TempBackOriginalImage;

@synthesize frontPhoto				= m_FrontPhoto;
@synthesize backPhoto				= m_BackPhoto;

const CGFloat kAnimationDuration  = 0.75;
const CGFloat kCardContainerWidth = 260.;
const NSInteger kExportActionSheetTag	  = 1;
const NSInteger kSelectCardActionSheetTag = 2;
const NSInteger kDeleteActionSheetTag	  = 3;
static NSString* kAnimationPresentFrontAndBackSides = @"Animation_PresentFrontAndBackSides";
static NSString* kAnimationPresentOneSide			= @"Animation_PresentOneSide";
static NSString* kAnimationBagroundAlpha			= @"Animation_BackgroundAlpha";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		m_State = DisplayBCardViewControllerStateConsult;
		m_FirstAppearance = YES;
	}
    return self;
}

- (void)dealloc {
	self.delegate					= nil;
	self.bCard						= nil;
	self.editItem					= nil;
	self.mailItem					= nil;
	self.deleteItem					= nil;
	self.backgroundImageView		= nil;
	self.mainContainer				= nil;
	self.reflectedContainer			= nil;
	self.frontImage					= nil;
	self.backImage					= nil;
	self.frontImageView				= nil;
	self.backImageView				= nil;
	self.reflectedFrontImageView	= nil;
	self.reflectedBackImageView		= nil;
	self.frontLabel					= nil;
	self.backLabel					= nil;
	self.rotateFrontCardButton		= nil;
	self.rotateBackCardButton		= nil;
	self.rotateFrontCardSpinner		= nil;
	self.rotateBackCardSpinner		= nil;
	self.tempFrontOriginalImage		= nil;
	self.tempBackOriginalImage		= nil;
	self.frontPhoto					= nil;
	self.backPhoto					= nil;
	
	[m_DisplayContactController release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Set perspective & doubleSided
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	perspectiveTransform.m34 = -0.002;
	
	[[self.frontImageView.layer superlayer] setSublayerTransform:perspectiveTransform];
	self.frontImageView.layer.doubleSided = NO;
	[[self.backImageView.layer superlayer]  setSublayerTransform:perspectiveTransform];
	self.backImageView.layer.doubleSided  = NO;
	
	[[self.reflectedFrontImageView.layer superlayer] setSublayerTransform:perspectiveTransform];
	self.reflectedFrontImageView.layer.doubleSided = NO;
	[[self.reflectedBackImageView.layer superlayer]  setSublayerTransform:perspectiveTransform];
	self.reflectedBackImageView.layer.doubleSided  = NO;
	
	self.frontLabel.text = NSLocalizedString(@"FrontLabel_Text_Key", nil);
	self.backLabel.text  = NSLocalizedString(@"BackLabel_Text_Key",  nil);
	
	
	// Gestures
	UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)]; 
	[self.frontImageView addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];

	tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)]; 
	[self.backImageView addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];

	UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]; 
	[self.view addGestureRecognizer:panGestureRecognizer];
	[panGestureRecognizer release];	
	
	UIPinchGestureRecognizer* pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognized:)]; 
	[self.view addGestureRecognizer:pinchGestureRecognizer];
	[pinchGestureRecognizer release];
	
	
	// Spinner
	self.rotateFrontCardSpinner.hidden = YES;
	self.rotateBackCardSpinner.hidden  = YES;
	
	// Alpha gradient for reflected card
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	[gradientLayer setFrame:CGRectMake(0, 0, 320, 50)];
	[gradientLayer setMasksToBounds:NO];
	[gradientLayer setColors:[NSArray arrayWithObjects:
							  (id)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor], 
							  (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor], nil]];
	[gradientLayer setStartPoint:CGPointMake(0., 0.)];
	[gradientLayer setEndPoint:CGPointMake(0., 1.)];
	
	[m_ReflectedContainer.layer setMask:gradientLayer];
	[m_ReflectedContainer.layer setMasksToBounds:NO];
	[gradientLayer release];
	
#if 0
	// DEBUG ++
	m_MainContainer.backgroundColor		 = [UIColor colorWithRed:1. green:1. blue:0. alpha:0.2];
	m_ReflectedContainer.backgroundColor = [UIColor colorWithRed:0. green:1. blue:1. alpha:0.2];
	
	self.frontImageView.backgroundColor  = [UIColor colorWithRed:1. green:0. blue:0. alpha:0.2];
	self.backImageView.backgroundColor   = [UIColor colorWithRed:0. green:0. blue:1. alpha:0.2];
	
	self.reflectedFrontImageView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:1. alpha:0.4];
	self.reflectedBackImageView.backgroundColor  = [UIColor colorWithRed:1. green:0. blue:1. alpha:0.4];
	// DEBUG --
#endif
}

- (void)viewDidUnload {
	self.navigationItem.rightBarButtonItem = nil;
	self.editItem				 = nil;
	self.mailItem				 = nil;
	self.deleteItem				 = nil;
	self.backgroundImageView	 = nil;
	self.mainContainer			 = nil;
	self.reflectedContainer		 = nil;
	self.frontImage				 = nil;
	self.backImage				 = nil;
	self.frontImageView			 = nil;
	self.backImageView			 = nil;
	self.reflectedFrontImageView = nil;
	self.reflectedBackImageView  = nil;
	self.frontLabel				 = nil;
	self.backLabel				 = nil;
	self.rotateFrontCardButton	 = nil;
	self.rotateBackCardButton	 = nil;
	self.rotateFrontCardSpinner	 = nil;
	self.rotateBackCardSpinner	 = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];	
		
	[self updateBCardDataWithForceImageReload:m_FirstAppearance];
	[self updateUI:NO];
	
	m_FirstAppearance = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (m_DisplayCropView) {
		[[AlertManager sharedManager] showSpinnerAlertViewWithMessage:NSLocalizedString(@"ProcessingAlert_Message_Key", nil)];
	}
	
	[self updateBCardDataWithForceImageReload:m_FirstAppearance];
	
	if (m_DisplayCropView) {
		m_DisplayCropView = NO;
		[[AlertManager sharedManager] hideAlertViewAnimated:YES];
		[self modifyCurrentPhoto];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark -
#pragma mark Gestures
- (void)tapGestureRecognized:(UITapGestureRecognizer*)tapGestureRecognizer {
	if (m_State == DisplayBCardViewControllerStateConsult) {
		
		// Small delta
		CATransform3D transform = CATransform3DMakeRotation(0.01, 0., 1., 0);
		m_Transform = CATransform3DConcat (m_Transform, transform);
		[self setCardTransform];
		
		BOOL side;
		if (!((m_Scale > 0.95) && (m_Scale < 1.05)) || !CGPointEqualToPoint(m_Translation, CGPointZero)) {
			side = [self isFront];
		} else {
			side = ![self isFront];
		}
		
		[self presentOneSide:side animated:YES];
		
	} else {
		if (tapGestureRecognizer.view == m_FrontImageView) {
			[self performSelector:@selector(imageSelected:) withObject:[NSNumber numberWithBool:YES] afterDelay:0];
		} else if (tapGestureRecognizer.view == m_BackImageView) {
			[self performSelector:@selector(imageSelected:) withObject:[NSNumber numberWithBool:NO] afterDelay:0];
		}
	}
}

- (void)panGestureRecognized:(UIPanGestureRecognizer*)panGestureRecognizer {
	if (m_State == DisplayBCardViewControllerStateConsult) {
		if ([panGestureRecognizer numberOfTouches] == 0) {
			if (CGPointEqualToPoint(m_Translation, CGPointZero)) {
				[self presentOneSide:[self isFront] animated:YES];
			}
				
		} else if ([panGestureRecognizer numberOfTouches] == 1) {
			m_Translation = CGPointZero;
			
			CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view]; 
			CGFloat norme = sqrt(translation.x*translation.x + translation.y*translation.y);
			CGFloat angle = norme * 3.14 / 180;
			
			CGFloat axeX = -translation.y;
			CGFloat axeY = translation.x;
			
			CATransform3D transform = CATransform3DMakeRotation(angle, axeX, axeY, 0);
			m_Transform = CATransform3DConcat ([self transformFront], transform);
			
			[self setCardTransform];
			
			[panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
			
		} else if ([panGestureRecognizer numberOfTouches] == 2) {
			CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view]; 
			
			CATransform3D transform = CATransform3DMakeTranslation (translation.x, translation.y, 0.);
			m_Transform = CATransform3DConcat ([self transformFront], transform);
			
			[self setCardTransform];
			
			m_Translation.x += translation.x;
			m_Translation.y += translation.y;
			[panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
			
			CGFloat norme = sqrt(m_Translation.x*m_Translation.x + m_Translation.y*m_Translation.y);
			self.reflectedContainer.alpha = 1 - MIN(norme, 5.) / 5.;
		}
	}
}

- (void)pinchGestureRecognized:(UIPinchGestureRecognizer*)pinchGestureRecognizer {
	if (m_State == DisplayBCardViewControllerStateConsult) {
		CGFloat scale = pinchGestureRecognizer.scale;
		
		CATransform3D transform = CATransform3DMakeScale(scale, scale, scale);
		m_Transform = CATransform3DConcat ([self transformFront], transform);
		
		[self setCardTransform];
		
		m_Scale *= scale;
		pinchGestureRecognizer.scale = 1.;
		
		if (m_Scale > 1.) {
			CGFloat alpha = 1. - MAX(MIN(m_Scale - 1., 1.), 0.) * 5;
			self.reflectedContainer.alpha = alpha;
		} else {
			self.reflectedContainer.alpha = 1.;
		}
	}
}


#pragma mark -
#pragma mark Public methods
- (IBAction)editButtonAction:(id)sender {
	if (m_State == DisplayBCardViewControllerStateConsult) {
		m_State = DisplayBCardViewControllerStateEdit;
	} else if (m_State == DisplayBCardViewControllerStateEdit) {
		m_State = DisplayBCardViewControllerStateConsult;
	}
	
	[self updateUI:YES];
}

- (IBAction)mailButtonAction:(id)sender {
	UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil/*NSLocalizedString(@"ExportPanel_Title_key", nil)*/ delegate:self 
													cancelButtonTitle:NSLocalizedString(@"ExportPanel_Cancel_Key", nil) 
													destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"EportPanel_Mail_Key", nil), nil];
	actionSheet.tag = kExportActionSheetTag;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)deleteButtonAction:(id)sender {
	UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DeletePanel_Cancel_Key", nil) 
																					    destructiveButtonTitle:NSLocalizedString(@"DeletePanel_Delete_Key", nil) 
																					    otherButtonTitles:nil];
	actionSheet.tag = kDeleteActionSheetTag;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)saveButtonAction:(id)sender {
	[[AlertManager sharedManager] showSpinnerAlertViewWithMessage:NSLocalizedString(@"SavingAlert_Message_Key", nil)];
	
	DataManager* sharedManager = [DataManager sharedManager];
	
	BCard* newBCard				 = [sharedManager createNewBCard];
	Photo* newFrontPhoto		 = [sharedManager createNewPhoto];
	Photo* newBackPhoto			 = [sharedManager createNewPhoto];
	Photo* newFrontOriginalPhoto = [sharedManager createNewPhoto];
	Photo* newBackOriginalPhoto  = [sharedManager createNewPhoto];
	
	newBCard.frontThumbnail	= [self.frontImage resizedImageToFitInSize:CGSizeMake(75, 49)];
	newBCard.backThumbnail  = [self.backImage  resizedImageToFitInSize:CGSizeMake(75, 49)];
	
	newFrontPhoto.image = self.frontImage;
	newBackPhoto.image  = self.backImage;
	
	newFrontOriginalPhoto.image = self.tempFrontOriginalImage;
	newBackOriginalPhoto.image  = self.tempBackOriginalImage;
	
	newBCard.frontPhoto = newFrontPhoto;
	newBCard.backPhoto  = newBackPhoto;
	newBCard.frontOriginalPhoto = newFrontOriginalPhoto;
	newBCard.backOriginalPhoto  = newBackOriginalPhoto;
	
	newBCard.frontCropRect = self.tempFrontCropRect;
	newBCard.backCropRect  = self.tempBackCropRect;
	
	[sharedManager save];

	self.bCard = newBCard;
	self.frontPhoto = newFrontPhoto;
	self.backPhoto  = newBackPhoto;
	[(MainNavigationController*)self.parentViewController setCurrentBCard:newBCard];
	
	[self updateBCardImagesWithHiRes:[NSNumber numberWithBool:YES]];
	
	self.state = DisplayBCardViewControllerStateConsult;
	[self updateUI:YES];
	
	[[AlertManager sharedManager] hideAlertViewAnimated:YES];
}

- (IBAction)rotateFrontCardAction:(id)sender {
	self.rotateFrontCardButton.hidden  = YES;
	self.rotateFrontCardSpinner.hidden = NO;
	[self.rotateFrontCardSpinner startAnimating];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.]];
	
	if (m_State == DisplayBCardViewControllerStateEdit) {
		m_BCard.frontPhoto.image = [m_BCard.frontPhoto.image rotate:UIImageOrientationRight];
		m_BCard.frontThumbnail   = [m_BCard.frontPhoto.image resizedImageToFitInSize:CGSizeMake(75, 49)];
		self.frontImage = m_BCard.frontPhoto.image;
		
		[[DataManager sharedManager] save];
		
	} else if (m_State == DisplayBCardViewControllerStateCreate) {
		self.frontImage = [self.frontImage rotate:UIImageOrientationRight];
	}
	
	[self updateBCarVisu];
	
	[self.rotateFrontCardSpinner stopAnimating];
	self.rotateFrontCardButton.hidden  = NO;
	self.rotateFrontCardSpinner.hidden = YES;
}

- (IBAction)rotateBackCardAction:(id)sender {
	self.rotateBackCardButton.hidden  = YES;
	self.rotateBackCardSpinner.hidden = NO;
	[self.rotateBackCardSpinner startAnimating];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.]];
	
	if (m_State == DisplayBCardViewControllerStateEdit) {
			m_BCard.backPhoto.image = [m_BCard.backPhoto.image rotate:UIImageOrientationRight];
			m_BCard.backThumbnail	= [m_BCard.backPhoto.image resizedImageToFitInSize:CGSizeMake(75, 49)];
			self.backImage = m_BCard.backPhoto.image;
		
		[[DataManager sharedManager] save];
		
	} else if (m_State == DisplayBCardViewControllerStateCreate) {
			self.backImage = [self.backImage rotate:UIImageOrientationRight];
	}
	
	[self updateBCarVisu];
	
	[self.rotateBackCardSpinner stopAnimating];
	self.rotateBackCardButton.hidden  = NO;
	self.rotateBackCardSpinner.hidden = YES;
}
	

#pragma mark -
#pragma mark Private methods
- (void)setCardTransform {
	self.frontImageView.layer.transform			 = [self transformFront];
	self.backImageView.layer.transform			 = [self transformBack];
	self.reflectedFrontImageView.layer.transform = [self transformFrontReflected];
	self.reflectedBackImageView.layer.transform  = [self transformBackReflected];
}

- (CATransform3D)transformFront {
	return m_Transform;
}

- (CATransform3D)transformBack {
	CATransform3D rotationTransform = CATransform3DMakeRotation (M_PI, 0., 1., 0.);
	return CATransform3DConcat(rotationTransform, [self transformFront]);
}

- (CATransform3D)transformFrontReflected {
	CATransform3D rotationTransformY = CATransform3DMakeRotation (M_PI, 0., 1., 0.);
	return CATransform3DConcat([self transformBack], rotationTransformY);
}

- (CATransform3D)transformBackReflected {
	CATransform3D rotationTransformY = CATransform3DMakeRotation (M_PI, 0., 1., 0.);
	return CATransform3DConcat([self transformFront], rotationTransformY);
}

- (void)updateUI:(BOOL)animated {
	if (m_State == DisplayBCardViewControllerStateConsult) {
		// Update available buttons
		NSString* imageName = ([self.bCard.identifier integerValue] == 0) ? @"AskContactIcon" : @"DisplayContactIcon";
		UIBarButtonItem* displayContactBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStyleBordered target:self action:@selector(displayContact:)];
		self.navigationItem.rightBarButtonItem = displayContactBarButtonItem;
		[displayContactBarButtonItem release];
		
		self.editItem.enabled	= YES;
		self.mailItem.enabled   = YES;
		self.deleteItem.enabled = YES;
		
		// Background alpha
		if (animated) {
			[UIView beginAnimations:kAnimationBagroundAlpha context:nil];
			[UIView setAnimationDuration:kAnimationDuration];   
			self.backgroundImageView.alpha = 1.;
			self.reflectedContainer.alpha  = 1.;
			[UIView commitAnimations];
		} else {
			self.backgroundImageView.alpha = 1.;
			self.reflectedContainer.alpha  = 1.;
		}

		// Card position
		//m_Transform = CATransform3DIdentity;
		//[self setCardTransform];
		m_Scale = 1.;
		m_Translation = CGPointZero;
		
		[self presentOneSide:YES animated:animated];
		
	} else if (m_State == DisplayBCardViewControllerStateEdit) {
		// Update available buttons
		UIBarButtonItem* askContactBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AskContactIcon"] style:UIBarButtonItemStyleBordered target:self action:@selector(displayContact:)];
		self.navigationItem.rightBarButtonItem = askContactBarButtonItem;
		[askContactBarButtonItem release];
		
		self.editItem.enabled	= YES;
		self.mailItem.enabled   = NO;
		self.deleteItem.enabled = NO;
		
		// Background alpha
		if (animated) {
			[UIView beginAnimations:kAnimationBagroundAlpha context:nil];
			[UIView setAnimationDuration:kAnimationDuration];   
			self.backgroundImageView.alpha = 0.;
			self.reflectedContainer.alpha  = 0.;
			[UIView commitAnimations];
		} else {
			self.backgroundImageView.alpha = 0.;
			self.reflectedContainer.alpha  = 0.;
		}
		
		// Card position
		[self presentFrontAndBackSides:animated];
		
	} else if (m_State == DisplayBCardViewControllerStateCreate) {
		// Save BCard bar button item
		UIBarButtonItem* saveBCardBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonAction:)];
		saveBCardBarButtonItem.style = UIBarButtonItemStyleDone;
		if ((self.frontImage == nil) && (self.backImage == nil)) {
			saveBCardBarButtonItem.enabled = NO;
		}
		self.navigationItem.rightBarButtonItem = saveBCardBarButtonItem;
		[saveBCardBarButtonItem release];	 
		
		self.editItem.enabled	= NO;
		self.mailItem.enabled   = NO;
		self.deleteItem.enabled = NO;
		
		// Background alpha
		if (animated) {
			[UIView beginAnimations:kAnimationBagroundAlpha context:nil];
			[UIView setAnimationDuration:kAnimationDuration];   
			self.backgroundImageView.alpha = 0.;
			self.reflectedContainer.alpha  = 0.;
			[UIView commitAnimations];
		} else {
			self.backgroundImageView.alpha = 0.;
			self.reflectedContainer.alpha  = 0.;
		}
		
		// Card position
		[self presentFrontAndBackSides:animated];
	}
}

- (BOOL)isFront {
	BOOL isFront = NO;
	
	if (-m_Transform.m33 < 0) {
		isFront = YES;
	}
	
	return isFront;
}

- (void)presentFrontAndBackSides:(BOOL)animated {
	CATransform3D frontTransform = CATransform3DScale (CATransform3DTranslate (CATransform3DIdentity, 0., -62., 0.), 0.6, 0.6, 0.6);
	CATransform3D backTransform  = CATransform3DScale (CATransform3DTranslate (CATransform3DIdentity, 0., 112., 0.), 0.6, 0.6, 0.6);
	
	if (animated) {
		[UIView beginAnimations:kAnimationPresentFrontAndBackSides context:nil];
		[UIView setAnimationDuration:kAnimationDuration];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationDelegate:self];
		self.frontImageView.layer.transform = frontTransform;
		self.backImageView.layer.transform  = backTransform;
		if (nil == self.frontImage) { 
			self.frontLabel.alpha = 1.;
			self.rotateFrontCardButton.alpha = 0.;
		} else {
			self.rotateFrontCardButton.alpha = 1.;
		}
		
		if (nil == self.backImage) {
			self.backLabel.alpha  = 1.;
			self.rotateBackCardButton.alpha = 0.;
		} else {
			self.rotateBackCardButton.alpha = 1.;
		}
		[UIView commitAnimations];
		
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		
	} else {
		self.frontImageView.layer.transform = frontTransform;
		self.backImageView.layer.transform  = backTransform;
		if (nil == self.frontImage) { 
			self.frontLabel.alpha = 1.;
			self.rotateFrontCardButton.alpha = 0.;
		} else {
			self.rotateFrontCardButton.alpha = 1.;
		}

		if (nil == self.backImage) {
			self.backLabel.alpha  = 1.;
			self.rotateBackCardButton.alpha = 0.;
		} else {
			self.rotateBackCardButton.alpha = 1.;
		}

	}
}

- (void)presentOneSide:(BOOL)front animated:(BOOL)animated {
	if (front) {
		m_Transform = CATransform3DIdentity;
	} else {
		m_Transform = CATransform3DMakeRotation(M_PI, 0., 1., 0.);
	}
		
	m_Scale = 1.;
	m_Translation = CGPointZero;
	
	if (animated) {
		[UIView beginAnimations:kAnimationPresentOneSide context:nil];
		[UIView setAnimationDuration:kAnimationDuration];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationDelegate:self];
		[self setCardTransform];
		self.frontLabel.alpha = 0.;
		self.backLabel.alpha  = 0.;
		self.rotateFrontCardButton.alpha = 0.;
		self.rotateBackCardButton.alpha = 0.;
		self.reflectedContainer.alpha = 1.;
		
		[UIView commitAnimations];
		
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		
	} else {
		self.frontLabel.alpha = 0.;
		self.backLabel.alpha  = 0.;
		self.rotateFrontCardButton.alpha = 0.;
		self.rotateBackCardButton.alpha = 0.;
		self.reflectedContainer.alpha = 1.;
		
		[self setCardTransform];
	}
}

- (void)displayContact:(id)sender {
	if (nil == m_DisplayContactController) {
		m_DisplayContactController = [[DisplayContactController alloc] init];
		m_DisplayContactController.bCard = self.bCard;
		m_DisplayContactController.navigationController = self.navigationController;
	}
	
	[m_DisplayContactController showInEdition:(m_State != DisplayBCardViewControllerStateConsult)];
}

- (void)updateBCardDataWithForceImageReload:(BOOL)forceImageReload {
	if (self.bCard != nil) {
		NSString* title = @"";
		if (nil != m_BCard.firstName) {
			title = [title stringByAppendingString:m_BCard.firstName];
		} 
		if (nil != m_BCard.lastName) {
			title = [title stringByAppendingFormat:@" %@",[m_BCard.lastName uppercaseString]];
		}
		if (([title length] == 0)  && (nil != m_BCard.company)) {
			title = [title stringByAppendingString:m_BCard.company];
		}
		
		self.title = title;
		
		if ([self.bCard isFault]) {
			NSLog(@"BCard returned to Fault");
			forceImageReload = YES;
		}
		if (forceImageReload) {
			[self updateBCardImagesWithHiRes:[NSNumber numberWithBool:NO]];
			[NSThread detachNewThreadSelector:@selector(updateBCardImagesWithHiRes:) toTarget:self withObject:[NSNumber numberWithBool:YES]];
		}
	} else {
		self.title = NSLocalizedString(@"UnknownContact_Name_Key", nil);
		[self updateBCarVisu];
	}
}

- (void)updateBCarVisu {
	UIImage* resizedFrontImage = nil;
	UIImage* resizedBackImage  = nil;
	
	BOOL isFrontEmpty = NO;
	BOOL isBackEmpty  = NO;
	
	CGFloat cardScale = 3.;
	
	if (nil != self.frontImage) {
		resizedFrontImage = [self.frontImage resizedImageToFitInSize:CGSizeMake(kCardContainerWidth * cardScale - 2, kCardContainerWidth * cardScale - 2) withTranspBorder:1];
	} else {
		resizedFrontImage = [UIImage imageWithName:@"EmptyCard"];
		isFrontEmpty = YES;
	}

	if (nil != self.backImage) {
		resizedBackImage = [self.backImage  resizedImageToFitInSize:CGSizeMake(kCardContainerWidth * cardScale - 2, kCardContainerWidth * cardScale - 2) withTranspBorder:1];
	} else {
		resizedBackImage = [UIImage imageWithName:@"EmptyCard"];
		isBackEmpty = YES;
	}
		
	self.frontImageView.image = resizedFrontImage;
	self.backImageView.image  = resizedBackImage;

	CGSize imageSize = self.frontImageView.image.size;
	
	CGFloat diag = 0.;
	CGFloat halfSquareSize = kCardContainerWidth / 2.;
	if (imageSize.width >= imageSize.height) {
		diag = sqrt(pow(halfSquareSize, 2.) + pow(imageSize.height / (2. * cardScale), 2.));
		
	} else {
		diag = sqrt(pow(halfSquareSize, 2.) + pow(imageSize.width / (2. * cardScale), 2.));
	}
	
	CGFloat newHeight = diag + halfSquareSize + 30;
	
	self.mainContainer.frame = CGRectMake(0, 0, 320, newHeight);
	self.reflectedContainer.frame = CGRectOffset(self.mainContainer.frame, 0, newHeight + 7/* - 150*/);
	
	self.reflectedFrontImageView.frame = CGRectMake(self.frontImageView.frame.origin.x, 7 + diag - imageSize.height / (2. * cardScale), self.frontImageView.frame.size.width, self.frontImageView.image.size.height / cardScale);
	//self.reflectedFrontImageView.frame = CGRectMake(self.frontImageView.frame.origin.x, 7 + diag - imageSize.height / 2., self.frontImageView.frame.size.width, self.frontImageView.frame.size.height);
	self.reflectedFrontImageView.image = isFrontEmpty ? nil : resizedFrontImage;
	self.reflectedBackImageView.frame  = CGRectMake(self.frontImageView.frame.origin.x, 7 + diag - imageSize.height / (2. * cardScale), self.frontImageView.frame.size.width, self.frontImageView.image.size.height / cardScale);
	//self.reflectedBackImageView.frame  = CGRectMake(self.frontImageView.frame.origin.x, 7 + diag - imageSize.height / 2., self.frontImageView.frame.size.width, self.frontImageView.frame.size.height);
	self.reflectedBackImageView.image  = isBackEmpty ? nil : resizedBackImage;

	[self.reflectedFrontImageView setNeedsDisplay];
	[self.reflectedBackImageView  setNeedsDisplay];
}

- (void)updateBCardImagesWithHiRes:(NSNumber*)hiRes {
	/*
	// Blocks 
	dispatch_async(main_queue, ^{ [viewController displayNewStuff];
	});
	/ Multithreading Core Data : Lock or pass object ID 
	- (NSManagedObject *)objectWithID:(NSManagedObjectID *)objectID;   
	*/
	
	@synchronized(self) {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		[[DataManager sharedManager].managedObjectContext lock];
		
		UIImage *frontImg = nil;
		UIImage *backImg  = nil;
		
		BOOL isHiRes = [hiRes boolValue];
		if (isHiRes) {
			self.frontPhoto = m_BCard.frontPhoto;
			self.backPhoto	= m_BCard.backPhoto;
			frontImg = m_BCard.frontPhoto.image;
			backImg  = m_BCard.backPhoto.image;
		} else {
			frontImg = m_BCard.frontThumbnail;
			backImg  = m_BCard.backThumbnail;
		}
		
		self.frontImage = frontImg;
		self.backImage  = backImg;
		
		[self performSelectorOnMainThread:@selector(updateBCarVisu) withObject:nil waitUntilDone:NO];
				
		[[DataManager sharedManager].managedObjectContext unlock];
		
		[pool release];
	}
}

- (void)imageSelected:(NSNumber*)isFront {
	m_IsModifyingFrontPhoto = [isFront boolValue];

	NSString* sheetTitle = (m_IsModifyingFrontPhoto) ? NSLocalizedString(@"SelectCardPanel_TitleFront_Key", nil) : NSLocalizedString(@"SelectCardPanel_TitleBack_Key", nil);
	UIActionSheet* actionSheet = nil;
	
	BOOL existingImage = m_IsModifyingFrontPhoto ? (nil != self.frontImage) : (nil != self.backImage);
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		if (existingImage) {
			actionSheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"SelectCardPanel_Cancel_Key", nil) destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"SelectCardPanel_NewPict_Key", nil), NSLocalizedString(@"SelectCardPanel_Library_Key", nil), NSLocalizedString(@"SelectCardPanel_Modify_Key", nil), nil];
		} else {
			actionSheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"SelectCardPanel_Cancel_Key", nil) destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"SelectCardPanel_NewPict_Key", nil), NSLocalizedString(@"SelectCardPanel_Library_Key", nil), nil];
		}
		
	} else {
		if (existingImage) {
			actionSheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"SelectCardPanel_Cancel_Key", nil) destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"SelectCardPanel_Library_Key", nil), NSLocalizedString(@"SelectCardPanel_Modify_Key", nil), nil];
		} else {
			actionSheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"SelectCardPanel_Cancel_Key", nil) destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"SelectCardPanel_Library_Key", nil), nil];
		}
	}

	actionSheet.tag = kSelectCardActionSheetTag;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)modifyFromLibrary {
	NSAssert([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary], @"modifyFromNewPhoto : Library not available");
	
	UIImagePickerController* picker = [[UIImagePickerController alloc] init]; 
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)modifyFromNewPhoto {
	NSAssert([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera], @"modifyFromNewPhoto : Camera not available");
	
	UIImagePickerController* picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)modifyCurrentPhoto {
	PhotoResizerController* resizer = [[PhotoResizerController alloc] init];
	resizer.delegate = self;

	if (m_State == DisplayBCardViewControllerStateEdit) {
		if (m_IsModifyingFrontPhoto) {
			resizer.originalImage = m_BCard.frontOriginalPhoto.image;
			resizer.cropRect = m_BCard.frontCropRect;
		} else {
			resizer.originalImage = m_BCard.backOriginalPhoto.image;
			resizer.cropRect = m_BCard.backCropRect;
		}
		
	} else if (m_State == DisplayBCardViewControllerStateCreate) {
		if (m_IsModifyingFrontPhoto) {
			resizer.originalImage = self.tempFrontOriginalImage;
			resizer.cropRect = self.tempFrontCropRect;
		} else {
			resizer.originalImage = self.tempBackOriginalImage;
			resizer.cropRect = self.tempBackCropRect;
		}
		
	}	

	[self presentModalViewController:resizer animated:YES];
	[resizer release];
}


#pragma mark -
#pragma mark UIView(CAAnimationDelegate)
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
}


#pragma mark -
#pragma mark <UIActionSheetDelegate> Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSInteger tag = actionSheet.tag;
	
	if (tag == kExportActionSheetTag) {
		switch (buttonIndex) {
			case 0:
				[self.delegate performSelectorOnMainThread:@selector(displayBCardViewControllerWantsEmailBCard:) withObject:self.bCard waitUntilDone:NO];
				break;
		}
		
	} else if (tag == kSelectCardActionSheetTag) {
		BOOL existingImage = m_IsModifyingFrontPhoto ? (nil != self.frontImage) : (nil != self.backImage);
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			if (existingImage) {
				switch (buttonIndex) {
					case 0: [self modifyFromNewPhoto];  break;
					case 1: [self modifyFromLibrary]; break;
					case 2: [self modifyCurrentPhoto]; break;
				}
			} else {
				switch (buttonIndex) {
					case 0: [self modifyFromNewPhoto];  break;
					case 1: [self modifyFromLibrary]; break;
				}
			}
			
		} else {
			if (existingImage) {
				switch (buttonIndex) {
					case 0: [self modifyFromLibrary];  break;
					case 1: [self modifyCurrentPhoto]; break;
				}
			} else {
				switch (buttonIndex) {
					case 0: [self modifyFromLibrary];  break;
						
				}
			}
			
		}
		
	} else if (tag == kDeleteActionSheetTag) {
		switch (buttonIndex) {
			case 0:
				[self.delegate performSelectorOnMainThread:@selector(displayBCardViewControllerWantsRemovalOfBCard:) withObject:self.bCard waitUntilDone:NO];
				break;
		}
	}
}


#pragma mark -
#pragma mark <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
	
	UIImage* newImage = [[info objectForKey:UIImagePickerControllerOriginalImage] resizedImageToFitInSize:CGSizeMake(1000, 1000)];
	
	if (m_State == DisplayBCardViewControllerStateEdit) {
		// If we are in 'Edit' mode, we directly update the photo
		if (m_IsModifyingFrontPhoto) {
			m_BCard.frontThumbnail = [newImage resizedImageToFitInSize:CGSizeMake(75, 49)];
			m_BCard.frontPhoto.image = newImage;
			m_BCard.frontOriginalPhoto.image = newImage;
			m_BCard.frontCropRect = CGRectMake(0., 0., newImage.size.width, newImage.size.height);
			self.frontImage = newImage;
			self.frontLabel.alpha = 0.;
		} else {
			m_BCard.backThumbnail = [newImage resizedImageToFitInSize:CGSizeMake(75, 49)];
			m_BCard.backPhoto.image = newImage;
			m_BCard.backOriginalPhoto.image = newImage;
			m_BCard.backCropRect = CGRectMake(0., 0., newImage.size.width, newImage.size.height);
			self.backImage = newImage;
			self.backLabel.alpha = 0.;
		}
		
		DataManager* sharedManager = [DataManager sharedManager];
		[sharedManager save];
		
		[self updateBCarVisu];
		
	} else if (m_State == DisplayBCardViewControllerStateCreate) {
		// If we are in 'Create' mode we need to wait for 'Save' button
		if (m_IsModifyingFrontPhoto) {
			self.frontImage = newImage;
			self.tempFrontOriginalImage = newImage;
			self.tempFrontCropRect = CGRectMake(60., 60., newImage.size.width - 120., newImage.size.height - 120.);
			self.frontLabel.alpha = 0.;
		} else {
			self.backImage = newImage;
			self.tempBackOriginalImage = newImage;
			self.tempBackCropRect = CGRectMake(60., 60., newImage.size.width - 120., newImage.size.height - 120.);
			self.backLabel.alpha = 0.;
		}
		[self updateBCarVisu];
	}

	[self dismissModalViewControllerAnimated:YES];
	m_DisplayCropView = YES;
}


#pragma mark -
#pragma mark <PhotoResizerControllerDelegate>
- (void)photoResizerControllerDidSave:(PhotoResizerController*)picker {
	CGRect cropRect = picker.cropRect;
	
	if (m_State == DisplayBCardViewControllerStateEdit) {
		if (m_IsModifyingFrontPhoto) {
			m_BCard.frontCropRect = cropRect;
			m_BCard.frontPhoto.image = [m_BCard.frontOriginalPhoto.image croppedImageFromRect:cropRect];
			m_BCard.frontThumbnail = [m_BCard.frontPhoto.image resizedImageToFitInSize:CGSizeMake(75, 49)];
			self.frontImage = m_BCard.frontPhoto.image;
			
		} else {
			m_BCard.backCropRect = cropRect;
			m_BCard.backPhoto.image = [m_BCard.backOriginalPhoto.image croppedImageFromRect:cropRect];
			m_BCard.backThumbnail = [m_BCard.backPhoto.image resizedImageToFitInSize:CGSizeMake(75, 49)];
			self.backImage = m_BCard.backPhoto.image;
		}
		
		[[DataManager sharedManager] save];
		
	} else if (m_State == DisplayBCardViewControllerStateCreate) {
		if (m_IsModifyingFrontPhoto) {
			self.tempFrontCropRect = cropRect;
			self.frontImage = [self.tempFrontOriginalImage croppedImageFromRect:cropRect];
			
		} else {
			self.tempBackCropRect = cropRect;
			self.backImage = [self.tempBackOriginalImage croppedImageFromRect:cropRect];
	
		}
	}
		
	[self updateBCarVisu];
	[self updateUI:NO];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)photoResizerControllerDidCancel:(PhotoResizerController*)picker {
	[self dismissModalViewControllerAnimated:YES];
}

@end
