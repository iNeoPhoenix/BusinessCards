//
//  CropRectView.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 19/06/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CropRectView : UIView <UIGestureRecognizerDelegate> {
	UIImageView* m_TopLeftPin;
	UIImageView* m_BottomRightPin;
	CGFloat		 m_Scale;
}

@property (nonatomic, retain) IBOutlet UIImageView* topLeftPin;
@property (nonatomic, retain) IBOutlet UIImageView* bottomRightPin;
@property (nonatomic, readwrite) CGRect cropRect;

- (void)hidePins;
- (void)showPins;
- (void)setSuperViewScale:(CGFloat)scale;

@end
