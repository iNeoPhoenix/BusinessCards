//
//  ContactsTableViewController.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 18/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Group;

@interface ContactsTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
	Group*			m_Group;
	NSArray*		m_ListContent;			// The master content.
	NSMutableArray*	m_FilteredListContent;	// The content filtered as a result of a search.
	NSMutableArray* m_SectionsArray;
	UILocalizedIndexedCollation* m_Collation;

	UILabel*			m_NoCardLabel;
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString*		m_SavedSearchTerm;
    BOOL			m_SearchWasActive;
}

@property (nonatomic, retain) Group* group;
@property (nonatomic, retain) NSArray* listContent;
@property (nonatomic, retain) NSMutableArray* filteredListContent;
@property (nonatomic, retain) NSMutableArray* sectionsArray;
@property (nonatomic, retain) UILocalizedIndexedCollation* collation;

@property (nonatomic, copy) NSString* savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

- (void)newBCard:(id)sender;
- (void)update;

@end
