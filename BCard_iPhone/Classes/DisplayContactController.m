//
//  DisplayContactViewController.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 27/04/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "DisplayContactController.h"

// Model
#import "BCard.h"
#import "DataManager.h"

// Controller
#import "AskContactViewController.h"


@interface DisplayContactController () <AskContactViewControllerDelegate>
- (void)displayRegistredContact:(BOOL)animated;
- (void)askForContact:(BOOL)animated;
- (void)registerPerson:(ABRecordRef)person;
- (void)update:(BOOL)animated;
@end


@implementation DisplayContactController

@synthesize bCard				 = m_BCard;
@synthesize navigationController = m_NavigationController;

- (void)dealloc {
	self.bCard = nil;
	self.navigationController = nil;
	
    [super dealloc];
}

- (void)showInEdition:(BOOL)inEdition {
	m_UserWantsEdition = inEdition;
	[self update:YES];
}

- (void)update:(BOOL)animated {
	if (([self.bCard.identifier integerValue] != 0) && (!m_UserWantsEdition)) {
		[self displayRegistredContact:animated];
	} else {
		[self askForContact:animated];
	}
}

- (void)displayRegistredContact:(BOOL)animated {
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.bCard.identifier integerValue]);
	if (person != nil) {
		ABPersonViewController *picker = [[ABPersonViewController alloc] init];
		picker.personViewDelegate = self;
		picker.displayedPerson = person;
		picker.allowsEditing = YES;
		[self.navigationController pushViewController:picker animated:animated];
		[picker release];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ABErrorPanel_Title_Key", nil) message:NSLocalizedString(@"ABErrorPanel_Messag_Key", nil) 
													   delegate:nil cancelButtonTitle:NSLocalizedString(@"ABErrorPanel_Button_Key", nil) otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	CFRelease(addressBook);
}

- (void)askForContact:(BOOL)animated {
	AskContactViewController* askContactController = [[AskContactViewController alloc] initWithNibName:@"AskContactViewController" bundle:nil];
	askContactController.delegate = self;
	[self.navigationController pushViewController:askContactController animated:animated];
	[askContactController release];
}


#pragma mark -
#pragma mark <AskContactViewControllerDelegate>
- (void)registerPerson:(ABRecordRef)person {
	if (NULL != person) {
		[[DataManager sharedManager] unregisterBCardInGroups:m_BCard];
		
		ABRecordID abContactID  = ABRecordGetRecordID(person);
		CFTypeRef abLastName    = ABRecordCopyValue(person, kABPersonLastNameProperty);
		CFTypeRef abFirstName   = ABRecordCopyValue(person, kABPersonFirstNameProperty);
		CFTypeRef abCompany		= ABRecordCopyValue(person, kABPersonOrganizationProperty);
		
		m_BCard.identifier = [NSNumber numberWithInt:abContactID];

		if (NULL != abLastName) {
			m_BCard.lastName = (NSString*)abLastName;
			CFRelease(abLastName);
		} else {
			m_BCard.lastName = nil;
		}
		
		if (NULL != abFirstName) {
			m_BCard.firstName = (NSString*)abFirstName;
			CFRelease(abFirstName);
		} else {
			m_BCard.firstName = nil;
		}
		
		if (NULL != abCompany) {
			m_BCard.company = (NSString*)abCompany;
			CFRelease(abCompany);
		} else {
			m_BCard.company = nil;
		}
		
		[[DataManager sharedManager] save];
		
		m_UserWantsEdition = NO;
		
		[[DataManager sharedManager] registerBCardInGroups:m_BCard];
	}
}

- (void)askContactControllerDidFinish:(AskContactViewController*)controller {
	[self.navigationController popViewControllerAnimated:NO];

	[self update:NO];
}


#pragma mark -
#pragma mark <ABPersonViewControllerDelegate>
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return YES;
}

@end
