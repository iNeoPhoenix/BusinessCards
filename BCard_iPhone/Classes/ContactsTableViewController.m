//
//  ContactsTableViewController.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 18/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "ContactsTableViewController.h"

// General
#import "Notifications.h"

// Model
#import "DataManager.h"
#import "BCard.h"
#import "Group.h"

// Controller
#import "DisplayBCardViewController.h"
#import "MainNavigationController.h"


@interface ContactsTableViewController ()
- (void)configureSections;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
@end


@implementation ContactsTableViewController

@synthesize group				= m_Group;
@synthesize listContent			= m_ListContent;
@synthesize filteredListContent = m_FilteredListContent;
@synthesize savedSearchTerm		= m_SavedSearchTerm;
@synthesize searchWasActive		= m_SearchWasActive;
@synthesize sectionsArray		= m_SectionsArray;
@synthesize collation			= m_Collation;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:ntf_BCardAdded object:nil];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.group				 = nil;
	self.listContent		 = nil;
	self.filteredListContent = nil;
	self.savedSearchTerm	 = nil;
	self.sectionsArray		 = nil;
	self.collation			 = nil;
	[m_NoCardLabel release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Table view header with custom color
	UIView* toolbarTopBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -200, 320, 244)];
	toolbarTopBackground.backgroundColor = [UIColor colorWithRed:226./256 green:231./256 blue:237./256 alpha:1.];
	[self.tableView.tableHeaderView addSubview:toolbarTopBackground];
	[self.tableView.tableHeaderView sendSubviewToBack:toolbarTopBackground];
	[toolbarTopBackground release];
	
	// Create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
	
	// Restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm) {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:m_SavedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
}

- (void)viewDidUnload {
	// Save the state of the search UI so that it can be restored if the view is re-created.
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
	
	self.filteredListContent = nil;
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	// "Add Button"
	if (nil != self.group) {
		self.navigationItem.rightBarButtonItem = nil;
	} else {
		UIBarButtonItem* addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newBCard:)];
		self.navigationItem.rightBarButtonItem = addButtonItem;
		[addButtonItem release];
	}

	if (nil != m_ListContent) {
		[self configureSections];
	}

	[self.tableView reloadData];
	
	[super viewWillAppear:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger sections = 0;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        sections = 1;
    } else {
		sections = [m_SectionsArray count];
    }
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        rows = [self.filteredListContent count];
    } else {
		NSArray* contactsInSection = [m_SectionsArray objectAtIndex:section];
		rows = [contactsInSection count];
    }
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactsCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel* firstNameLabel = nil;
	UILabel* lastNameLabel = nil;
	UILabel* companyLabel = nil;
	UIImageView* imageView = nil;
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		// First Name
		firstNameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		firstNameLabel.textColor = [UIColor darkTextColor];
		firstNameLabel.font = [UIFont systemFontOfSize:18];
		firstNameLabel.lineBreakMode = UILineBreakModeWordWrap;
		firstNameLabel.tag = 1;
		[cell.contentView addSubview:firstNameLabel];
		
		// Last Name
		lastNameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		lastNameLabel.textColor = [UIColor darkTextColor];
		lastNameLabel.font = [UIFont boldSystemFontOfSize:18];
		lastNameLabel.lineBreakMode = UILineBreakModeWordWrap;
		lastNameLabel.tag = 2;
		[cell.contentView addSubview:lastNameLabel];
		
		// Company
		companyLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		companyLabel.textColor = [UIColor grayColor];
		companyLabel.font = [UIFont systemFontOfSize:14];
		companyLabel.lineBreakMode = UILineBreakModeWordWrap;
		companyLabel.tag = 3;
		[cell.contentView addSubview:companyLabel];
				
		// Image
		imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
		imageView.opaque = YES;
		imageView.tag = 4;
		imageView.frame = CGRectMake(0, 0, 75, 49);
		imageView.contentMode = UIViewContentModeCenter;
		[cell.contentView addSubview:imageView];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else {
		firstNameLabel	= (UILabel*) [cell.contentView viewWithTag:1];
		lastNameLabel	= (UILabel*) [cell.contentView viewWithTag:2];
		companyLabel	= (UILabel*) [cell.contentView viewWithTag:3];
		imageView		= (UIImageView*) [cell.contentView viewWithTag:4];
	}
/*
	firstNameLabel.backgroundColor = [UIColor redColor];
	lastNameLabel.backgroundColor = [UIColor redColor];
	companyLabel.backgroundColor = [UIColor redColor];
*/
	BCard* bCard = nil;
	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        bCard = [self.filteredListContent objectAtIndex:indexPath.row];
		
    } else {
		NSArray* contactsInSection = [m_SectionsArray objectAtIndex:indexPath.section];
		bCard = [contactsInSection objectAtIndex:indexPath.row];
    }
	
	// Frame
	CGFloat firstLineYOrigin = 5.;
	if ((nil != bCard.company) && ((nil != bCard.firstName) || (nil != bCard.lastName))) {
		companyLabel.frame	 = CGRectMake(80, 27, 180, 18);
	} else {
		firstLineYOrigin = 14;
		companyLabel.frame	 = CGRectZero;
	}

	CGSize firstNameSize = [bCard.firstName sizeWithFont:[firstNameLabel font]];
	CGFloat firstNameWidth = MIN(firstNameSize.width, 180);
	
	NSUInteger pixelsBetweenNames = (nil == bCard.firstName) ? 0 : 7;
	
	firstNameLabel.frame = CGRectMake(80, firstLineYOrigin, firstNameWidth, 22);
	lastNameLabel.frame	 = CGRectMake(80 + firstNameWidth + pixelsBetweenNames, firstLineYOrigin, MAX(180 - pixelsBetweenNames - firstNameWidth, 0.) , 22);

	// Text
	firstNameLabel.text = bCard.firstName;
	
	if ((nil != bCard.firstName) || (nil != bCard.lastName)) {
		lastNameLabel.text	= bCard.lastName;
		companyLabel.text	= bCard.company;
	} else {
		lastNameLabel.text	= bCard.company;

	}

	imageView.image = bCard.frontThumbnail;
	
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return nil;
    } else {
		NSArray* contactsInSection = [m_SectionsArray objectAtIndex:section];
		if ([contactsInSection count] > 0) {		
			return [[m_Collation sectionTitles] objectAtIndex:section];
		} else {
			return nil;
		} 
    }
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return nil;
    } else {
		return [m_Collation sectionIndexTitles];
    }
}

- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return 0;
    } else {
		return [m_Collation sectionForSectionIndexTitleAtIndex:index];
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	DisplayBCardViewController* displayBCardViewController = [[DisplayBCardViewController alloc] initWithNibName:@"DisplayBCardViewController" bundle:nil];
	
	MainNavigationController* mainNavigationController = (MainNavigationController*)self.parentViewController;
	displayBCardViewController.delegate = mainNavigationController;
	
	BCard* selectedBCard = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		selectedBCard = [self.filteredListContent objectAtIndex:indexPath.row];
		
	} else {
		NSArray* contactsInSection = [m_SectionsArray objectAtIndex:indexPath.section];
		selectedBCard = [contactsInSection objectAtIndex:indexPath.row];
	}
	
	mainNavigationController.currentBCard = selectedBCard;
	displayBCardViewController.bCard = selectedBCard;
	
	[[self navigationController] pushViewController:displayBCardViewController animated:YES];
	[displayBCardViewController release];
}


#pragma mark -
#pragma mark Setters / Getters
- (void)setListContent:(NSMutableArray*)newArray {
	if (newArray != m_ListContent) {
		[m_ListContent release];
		m_ListContent = [newArray retain];
	}
	
	if (m_ListContent == nil) {
		self.sectionsArray = nil;
	} else {
		[self configureSections];
	}
	
	if (m_ListContent.count > 0) {
		[m_NoCardLabel removeFromSuperview];
		[m_NoCardLabel release]; m_NoCardLabel = nil;
		
	} else {
		if (nil == m_NoCardLabel) {
			m_NoCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 175, 320, 44)];
			m_NoCardLabel.text = NSLocalizedString(@"NoBusinessCard_Label_Key", nil);
			m_NoCardLabel.textAlignment = UITextAlignmentCenter;
			m_NoCardLabel.font = [UIFont boldSystemFontOfSize:20];
			m_NoCardLabel.textColor = [UIColor lightGrayColor];
			m_NoCardLabel.backgroundColor = [UIColor clearColor];
		}
		[self.tableView addSubview:m_NoCardLabel];
	}
}

- (void)setGroup:(Group*)iGroup {
	if (m_Group != iGroup) {
		NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter removeObserver:self name:ntf_GroupUpdated object:m_Group];
		
		[m_Group release];
		m_Group = [iGroup retain];
		
		self.title		 = m_Group.groupName;
		self.listContent = m_Group.bCardList;
		
		[notificationCenter addObserver:self selector:@selector(update) name:ntf_GroupUpdated object:m_Group];	
	}
}


#pragma mark -
#pragma mark Public methods
- (void)newBCard:(id)sender {
	DisplayBCardViewController* displayBCardViewController = [[DisplayBCardViewController alloc] initWithNibName:@"DisplayBCardViewController" bundle:nil];
	displayBCardViewController.state = DisplayBCardViewControllerStateCreate;
	displayBCardViewController.delegate = (MainNavigationController*)self.parentViewController;
    [[self navigationController] pushViewController:displayBCardViewController animated:YES];
    [displayBCardViewController release];
}

#pragma mark -
#pragma mark Private methods
- (void)update {
	if (nil != m_Group) {
		self.title = m_Group.groupName;
		self.listContent = m_Group.bCardList;
	} else {
		self.title = NSLocalizedString(@"AllContactsGroup_Label_Key", nil);
		self.listContent = [[DataManager sharedManager] bCardList];
	}

	self.filteredListContent = nil;
	
	[self.tableView reloadData];
}

- (void)configureSections {
	self.collation = [UILocalizedIndexedCollation currentCollation];

	NSInteger sectionTitlesCount = [[m_Collation sectionTitles] count];
	
	NSMutableArray* newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	
	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (NSInteger index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray* array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
		[array release];
	}
	
	// Segregate the BCards into the appropriate arrays.
	for (NSString* string in m_ListContent) {
		
		// Ask the collation which section number the BCard belongs in, based on its locale name.
		NSInteger sectionNumber = [m_Collation sectionForObject:string collationStringSelector:@selector(textForFiltering)];
		
		// Get the array for the section.
		NSMutableArray* sectionContacts = [newSectionsArray objectAtIndex:sectionNumber];
		
		// Add the BCard to the section
		[sectionContacts addObject:string];
	}
	
	// Now that all the data's in place, each section array needs to be sorted.
	for (NSInteger index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray* contactsArrayForSection = [newSectionsArray objectAtIndex:index];
		
		// If the table view or its contents were editable, you would make a mutable copy here.
		NSArray *sortedContactsArrayForSection = [m_Collation sortedArrayFromArray:contactsArrayForSection collationStringSelector:@selector(textForFiltering)];
		
		// Replace the existing array with the sorted array.
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedContactsArrayForSection];
	}
	
	self.sectionsArray = newSectionsArray;
	[newSectionsArray release];	
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text and scope.
	[self.filteredListContent removeAllObjects];
	
	// Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	for (BCard* bCard in m_ListContent) {
		NSComparisonResult result = [[bCard textForFiltering] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
		if (result == NSOrderedSame) {
			[self.filteredListContent addObject:bCard];
		}
	}
}


#pragma mark -
#pragma mark <UISearchDisplayController>
- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString*)searchString {
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

@end
