//
//  AskContactViewController.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 14/05/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "AskContactViewController.h"


@implementation AskContactViewController

@synthesize delegate = m_Delegate;
@synthesize existingButton;
@synthesize createNewButton;

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.existingButton  setTitle:NSLocalizedString(@"AskContactExisting_ButtonTitle_Key", nil) forState:UIControlStateNormal]; 
	[self.createNewButton setTitle:NSLocalizedString(@"AskContactNew_ButtonTitle_Key", nil)		 forState:UIControlStateNormal]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	self.delegate		 = nil;
	self.existingButton  = nil;
	self.createNewButton = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Public methods
- (IBAction)linkToExistingContact {
	ABPeoplePickerNavigationController* pickerController = [[ABPeoplePickerNavigationController alloc] init];
	pickerController.peoplePickerDelegate = self;
	// Navigation bar style
	[pickerController.navigationBar setTintColor:[UIColor colorWithRed:50./256. green:80./256. blue:112./256. alpha:1.]];
	[pickerController.navigationBar setBarStyle:UIBarStyleDefault];
	
	[self presentModalViewController:pickerController animated:YES];
	[pickerController release];
}

- (IBAction)createNewContact {
	ABNewPersonViewController* newPersonController = [[ABNewPersonViewController alloc] init];
	newPersonController.newPersonViewDelegate = self;
	
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:newPersonController];
	// Navigation bar style
	[navigationController.navigationBar setTintColor:[UIColor colorWithRed:50./256. green:80./256. blue:112./256. alpha:1.]];
	[navigationController.navigationBar setBarStyle:UIBarStyleDefault];
	
	[self presentModalViewController:navigationController animated:YES];
	
	[newPersonController release];
	[navigationController release];
}


#pragma mark -
#pragma mark <ABPeoplePickerNavigationControllerDelegate>
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	[m_Delegate registerPerson:person];
	[self dismissModalViewControllerAnimated:YES];
	
	[m_Delegate askContactControllerDidFinish:self];
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	[self dismissModalViewControllerAnimated:YES];
	
	return NO;
}


#pragma mark -
#pragma mark <ABNewPersonViewControllerDelegate>
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
	[m_Delegate registerPerson:person];
	[self dismissModalViewControllerAnimated:YES];
	
	[m_Delegate askContactControllerDidFinish:self];
}

@end
