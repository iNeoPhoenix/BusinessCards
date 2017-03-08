//
//  GroupsTableViewController.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 18/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "GroupsTableViewController.h"

// Model
#import "DataManager.h"
#import "Group.h"

// Controller
#import "ContactsTableViewController.h"
#import "MainNavigationController.h"


@interface GroupsTableViewController ()
- (void)update;
@property (nonatomic, retain) NSArray* groupList;
@end


@implementation GroupsTableViewController

@synthesize groupList = m_GroupList;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = NSLocalizedString(@"GroupsTableView_Title_Key", nil);
    }
    return self;
}

- (void)dealloc {
	self.groupList = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController methods
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self update];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger groupNumber = [m_GroupList count] + 1; //+1 for the "All Contacts" group
    return groupNumber;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"GroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	NSInteger row = [indexPath row];
	if (row == 0) {
		cell.textLabel.text = NSLocalizedString(@"AllContactsGroup_Label_Key", nil);
	} else {
		Group* group = (Group*)[m_GroupList objectAtIndex:row - 1]; //-1 for the "All Contacts" group
		cell.textLabel.text = group.groupName;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ContactsTableViewController* contactsTableViewController = [[ContactsTableViewController alloc] initWithNibName:@"ContactsTableViewController" bundle:nil];
	
	MainNavigationController* mainNavigationController = (MainNavigationController*)self.parentViewController;
	
	NSInteger row = [indexPath row];
	if (row == 0) {
		contactsTableViewController.title = NSLocalizedString(@"AllContactsGroup_Label_Key", nil);
		contactsTableViewController.listContent = [[DataManager sharedManager] bCardList];
		mainNavigationController.currentGroup = nil;
	} else {
		Group* group = (Group*)[m_GroupList objectAtIndex:row - 1]; //-1 for the "All Contacts" group
		contactsTableViewController.title = group.groupName;
		contactsTableViewController.group = group;
		mainNavigationController.currentGroup = group;
	}
	
	[self.navigationController pushViewController:contactsTableViewController animated:YES];
	[contactsTableViewController release];
}


#pragma mark -
#pragma mark Private Methods
- (void)update {
	self.groupList = [DataManager sharedManager].groupList;
	[self.tableView reloadData];
}

@end
