//
//  DisplayContactViewController.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 27/04/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>


@class BCard;

@interface DisplayContactController : NSObject <ABPersonViewControllerDelegate> {
	BOOL m_UserWantsEdition;
	BCard*  m_BCard;
	UIView* m_NoContactView;
	UINavigationController* m_NavigationController;
}

@property (nonatomic, retain) BCard* bCard;
@property (nonatomic, retain) UINavigationController* navigationController;

- (void)showInEdition:(BOOL)inEdition; // If NO, the controller chooses according to the given bCard

@end
