//
//  MainNavigationController.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 18/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "MainNavigationController.h"

#import "Notifications.h"
#import "AlertManager.h"
#import <AddressBookUI/AddressBookUI.h>

// Model
#import "DataManager.h"
#import "BCard.h"
#import "Group.h"
#import "Photo.h"
#import "ABContactW.h"

// Controller
#import "FrontRowViewController.h"
#import "GroupsTableViewController.h"
#import "ContactsTableViewController.h"
#import "DisplayBCardViewController.h"


@interface MainNavigationController ()
- (void)orientationChanged:(NSNotification*)notification;
- (void)updateLandscapeView;
// Notifications
- (void)modelWillReload;
- (void)modelDidReload;
@end


@implementation MainNavigationController

@synthesize frontRowViewController		= m_FrontRowViewController;
@synthesize groupsTableViewController	= m_GroupsTableViewController;
@synthesize contactsTableViewController = m_ContactsTableViewController;
@synthesize currentGroup = m_CurrentGroup;
@synthesize currentBCard = m_CurrentBCard;

- (void)awakeFromNib {
	// Set Up UI
	m_GroupsTableViewController   = [[GroupsTableViewController alloc]   initWithNibName:@"GroupsTableViewController"   bundle:nil];
	m_ContactsTableViewController = [[ContactsTableViewController alloc] initWithNibName:@"ContactsTableViewController" bundle:nil];
	
	[self setViewControllers:[NSArray arrayWithObjects:m_GroupsTableViewController, m_ContactsTableViewController, nil] animated:NO];
	
	NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
	[notifCenter addObserver:self selector:@selector(modelWillReload) name:ntf_ModelWillReload object:nil];
	[notifCenter addObserver:self selector:@selector(modelDidReload)  name:ntf_ModelDidReload  object:nil];
	
	[super awakeFromNib];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	self.frontRowViewController		 = nil;
	self.groupsTableViewController	 = nil;
	self.contactsTableViewController = nil;
	
	[m_CurrentBCard release];
	[m_CurrentGroup release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController methods
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor blackColor];
	[self.navigationBar setTintColor:[UIColor colorWithRed:50./256. green:80./256. blue:112./256. alpha:1.]];
	[self.navigationBar setBarStyle:UIBarStyleDefault];
	
	/*
	// Portrait controllers are standard state, MainNavigationController displays the landscape view controller itself
	FrontRowViewController* viewController = [[FrontRowViewController alloc] initWithNibName:@"FrontRowView" bundle:nil];
	self.frontRowViewController = viewController;
	[viewController release];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	 */
}

- (void)viewDidUnload {
	self.frontRowViewController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark UINavigationViewController
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	UIViewController* controller = [super popViewControllerAnimated:animated];
	
	if ([controller isKindOfClass:[ContactsTableViewController class]]) {
		self.currentGroup = nil;
		self.currentBCard = nil;
		
	} else if ([controller isKindOfClass:[DisplayBCardViewController class]]) {
		if (nil != self.currentBCard) {
			[[[DataManager sharedManager] managedObjectContext] refreshObject:self.currentBCard mergeChanges:NO];
			self.currentBCard = nil;
		}
		
	} else if ([controller isKindOfClass:[ABPersonViewController class]]) {
		// Check if the contact have been edited
		[[DataManager sharedManager] updateDataOfBCard:self.currentBCard];
	}
	return controller;
}


#pragma mark -
#pragma mark Public methods
- (void)save {
	if (nil != self.currentGroup) {
		NSString* currentGroupName = self.currentGroup.groupName;
		[[NSUserDefaults standardUserDefaults] setObject:currentGroupName forKey:@"SavedGroupName"];
	}
	/*	
	if (nil != self.currentBCard) {
		NSNumber* currentBCardID = self.currentBCard.identifier;
		[[NSUserDefaults standardUserDefaults] setObject:currentBCardID forKey:@"SavedBCardIdentifier"];
	}*/
}


#pragma mark -
#pragma mark <DisplayBCardViewControllerDelegate>
- (void)displayBCardViewControllerWantsRemovalOfBCard:(BCard*)bCard {
	[[DataManager sharedManager] destroyBCard:bCard];
	[m_ContactsTableViewController update];
	
	// Display Contacts table view
	UIViewController* controller = [self topViewController];
	if ([controller isKindOfClass:[DisplayBCardViewController class]]) {
		[self popViewControllerAnimated:YES];
	}
/*
	if (([self.currentGroup numberOfBCards] > 0) || (nil == self.currentGroup)) {
		self.currentGroup = nil;
		[self popViewControllerAnimated:YES];
	}	*/
}

- (void)displayBCardViewControllerWantsEmailBCard:(BCard*)bCard {	
	MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
	
	NSString* mailSubject = [NSString stringWithFormat:NSLocalizedString(@"MailContent_Subject_Key", nil), bCard.firstName, [bCard.lastName uppercaseString]];
	[mailController setSubject:mailSubject];

	// Fill mail
	NSString* messageBody = @"";
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [bCard.identifier integerValue]);
	if (person != nil) {
		ABContactW* contact = [[ABContactW alloc] initWithRecord:person];
		
		if (nil != contact.firstName) {
			messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"MailContent_FirstName_Key", nil), contact.firstName]];
		}
		
		if (nil != contact.lastName) {
			messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"MailContent_LastName_Key", nil), contact.lastName]];
		}
		
		messageBody = [messageBody stringByAppendingString:@"<br>"];
		
		if (nil != contact.company) {
			messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"MailContent_Company_Key", nil), contact.company]];
		}
		
		if (nil != contact.job) {
			messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"MailContent_Job_Key", nil), contact.job]];
		}
		
		messageBody = [messageBody stringByAppendingString:@"<br>"];
		
		NSArray* phones = contact.phones;
		if (nil != phones) {
			NSMutableString* phoneString = [[NSMutableString alloc] init];
			for (NSString* string in phones) {
				[phoneString appendString:string];
				[phoneString appendString:@"<br>"];
			}
			messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"MailContent_Phones_Key", nil), phoneString]];
			[phoneString release];
		}
		
		NSArray* mails = contact.mails;
		if (nil != mails) {
			NSMutableString* mailString = [[NSMutableString alloc] init];
			for (NSString* string in mails) {
				[mailString appendString:string];
				[mailString appendString:@"<br>"];
			}
			messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"MailContent_Mails_Key", nil), mailString]];
			[mailString release];
		}
		
		[contact release];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ABErrorPanel_Title_Key", nil) message:NSLocalizedString(@"ABErrorPanel_Messag_Key", nil) 
													   delegate:nil cancelButtonTitle:NSLocalizedString(@"ABErrorPanel_Button_Key", nil) otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	CFRelease(addressBook);
	
	

	messageBody = [messageBody stringByAppendingString:NSLocalizedString(@"MailContent_MessageFooter_Key", nil)];
	[mailController setMessageBody:messageBody isHTML:YES];

	// Attach photos
	NSData* data = nil;
	if (nil != bCard.backPhoto.image) {
		data = UIImagePNGRepresentation(bCard.backPhoto.image);
		[mailController addAttachmentData:data mimeType:@"image/png" fileName:@"Back.png"];
	}
	if (nil != bCard.frontPhoto.image) {
		data = UIImagePNGRepresentation(bCard.frontPhoto.image);
		[mailController addAttachmentData:data mimeType:@"image/png" fileName:@"Front.png"];
	}
	
	// Display controller
	mailController.mailComposeDelegate = self;
	[self presentModalViewController:mailController animated:YES];
	
	[mailController release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];

	if (result == MFMailComposeResultFailed) {
    	NSString* title	  = NSLocalizedString(@"MailErrorPanel_Title_Key", nil);
		NSString* message = NSLocalizedString(@"MailErrorPanel_Message_Key", nil);
		
		UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[errorAlert show];
		[errorAlert release];
	}
}

#pragma mark -
#pragma mark Private methods
- (void)orientationChanged:(NSNotification*)notification {
	// We must add a delay here, otherwise we'll swap in the new view too quickly and we'll get an animation glitch
	[self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0];
}

- (void)updateLandscapeView {
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView) {
		[self presentModalViewController:self.frontRowViewController animated:YES];
		isShowingLandscapeView = YES;
	} else if (deviceOrientation == UIDeviceOrientationPortrait && isShowingLandscapeView) {
		[self dismissModalViewControllerAnimated:YES];
		isShowingLandscapeView = NO;
	}    
}


#pragma mark Notifications
- (void)modelWillReload {
	[[AlertManager sharedManager] showNetworkActivityIndicator];
	
	// TODO IF BCARD LIST > X THEN AFFICHER WAIT ALERT VIEW
	
	[self save];
}

- (void)modelDidReload {
	[[AlertManager sharedManager] hideNetworkActivityIndicator];
	
	NSString* currentGroupName = [[NSUserDefaults standardUserDefaults] stringForKey:@"SavedGroupName"];
	//NSNumber* currentBCardID   = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedBCardIdentifier"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SavedGroupName"];
	//[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SavedBCardIdentifier"];
	
	Group* currentGroup = [[DataManager sharedManager] groupByName:currentGroupName];
	
	if (nil != currentGroup) {
		m_ContactsTableViewController.title = currentGroup.groupName;
		m_ContactsTableViewController.listContent = currentGroup.bCardList;
		self.currentGroup = currentGroup;
				
	} else {
		m_ContactsTableViewController.listContent = [[DataManager sharedManager] bCardList];
		m_ContactsTableViewController.title = NSLocalizedString(@"AllContactsGroup_Label_Key", nil);
		self.currentGroup = nil;
	}
	/*
	if (nil != currentBCardID) {
		NSInteger index = 0;
		BOOL found = NO;
		for (BCard* bCard in m_ContactsTableViewController.listContent) {
			if ([bCard.identifier isEqualToNumber:currentBCardID]) {
				found = YES;
				break;
			}
			index++;
		}
		if (found) {
			NSInteger temp = [m_ContactsTableViewController.tableView numberOfSections];
			
			[m_ContactsTableViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		}
	}*/
	
	
	if ([self.viewControllers containsObject:m_ContactsTableViewController]) {
		[self popToViewController:m_ContactsTableViewController animated:NO];
		self.currentBCard = nil;
	}
}

@end
