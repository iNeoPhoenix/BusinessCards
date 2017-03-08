//
//  MainNavigationController.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 18/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DisplayBCardViewController.h"
#import <MessageUI/MessageUI.h>

@class FrontRowViewController, GroupsTableViewController, ContactsTableViewController;
@class BCard, Group;

@interface MainNavigationController : UINavigationController <DisplayBCardViewControllerDelegate,MFMailComposeViewControllerDelegate> {
	BOOL isShowingLandscapeView;
	FrontRowViewController*		 m_FrontRowViewController;
	GroupsTableViewController*   m_GroupsTableViewController;
	ContactsTableViewController* m_ContactsTableViewController;

	Group* m_CurrentGroup;
	BCard* m_CurrentBCard;
}

@property (nonatomic, retain) FrontRowViewController* frontRowViewController;
@property (nonatomic, retain) GroupsTableViewController* groupsTableViewController;
@property (nonatomic, retain) ContactsTableViewController* contactsTableViewController;
@property (nonatomic, retain) Group* currentGroup;
@property (nonatomic, retain) BCard* currentBCard;

- (void)save;

@end
