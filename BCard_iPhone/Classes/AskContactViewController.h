//
//  AskContactViewController.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 14/05/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>


@class AskContactViewController;

@protocol AskContactViewControllerDelegate <NSObject>
- (void)registerPerson:(ABRecordRef)person;
- (void)askContactControllerDidFinish:(AskContactViewController*)controller;
@end

@interface AskContactViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, ABNewPersonViewControllerDelegate> {
	id <AskContactViewControllerDelegate> m_Delegate;
}

@property (nonatomic, assign) id <AskContactViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton* existingButton;
@property (nonatomic, retain) IBOutlet UIButton* createNewButton;

- (IBAction)linkToExistingContact;
- (IBAction)createNewContact;

@end
