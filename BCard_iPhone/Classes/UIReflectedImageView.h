//
//  UIReflectedImageView.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 14/04/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIReflectedImageView : UIView {
	UIImage* m_Image;
}

@property (nonatomic, retain) UIImage* image;

@end
