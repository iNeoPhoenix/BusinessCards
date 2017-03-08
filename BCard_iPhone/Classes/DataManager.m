//
//  DataManager.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 23/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "DataManager.h"

#import <AddressBook/AddressBook.h>
#import "Group.h"
#import "BCard.h"
#import "Photo.h"
#import "Notifications.h"
#import "ABGroupW.h"
#import "ABContactW.h"
#import "AlertManager.h"


@interface DataManager ()
- (NSString*)applicationDocumentsDirectory;
- (void)presentUnrecoverableError:(NSString*)userInfo;
- (BOOL)reloadABTree;
void abChanged (ABAddressBookRef addressBook, CFDictionaryRef info, void *context);
@end


@implementation DataManager

static DataManager* s_SharedManager = nil;

@synthesize bCardList = m_BCardList;
@synthesize groupList = m_GroupList;
@synthesize bCardEntityDescription = m_BCardEntityDescription;
@synthesize photoEntityDescription = m_PhotoEntityDescription;

+ (DataManager*)sharedManager {
	if (nil == s_SharedManager) {
		s_SharedManager = [[DataManager alloc] init];
	}
	return s_SharedManager;
}


#pragma mark -
- (id)init {
	if (self = [super init]) {
		NSManagedObjectContext *context = [self managedObjectContext];
		if (!context) {
			[self presentUnrecoverableError:nil];
		}
		ABAddressBookRef addressBookRef = ABAddressBookCreate();
		ABAddressBookRegisterExternalChangeCallback(addressBookRef, abChanged, self);
		CFRelease(addressBookRef);
	}
	return self;
}

- (void)dealloc {	
	ABAddressBookRef addressBookRef = ABAddressBookCreate();
	ABAddressBookUnregisterExternalChangeCallback(addressBookRef, abChanged, self);
	CFRelease(addressBookRef);
	
	[m_ManagedObjectContext		  release];
    [m_ManagedObjectModel		  release];
    [m_PersistentStoreCoordinator release];
	[m_BCardEntityDescription	  release];
	[m_PhotoEntityDescription	  release];
	
	[m_ABGroupWList   release];
	[m_ABContactWDic  release];
	
	[m_BCardList release];
	[m_GroupList release];
	
	[super dealloc];
}


#pragma mark -
- (BCard*)createNewBCard {
	BCard* newBCard = (BCard*)[NSEntityDescription insertNewObjectForEntityForName:@"BCard" inManagedObjectContext:self.managedObjectContext];
	//BCard* newBCard = [[[BCard alloc] initWithEntity:self.bCardEntityDescription insertIntoManagedObjectContext:self.managedObjectContext] autorelease];
	
	newBCard.lastName	= NSLocalizedString(@"UnknownContact_Name_Key", nil);
	newBCard.firstName	= NSLocalizedString(@"UnknownContact_FirstName_Key", nil);
	
	[m_BCardList addObject:newBCard];
	[[NSNotificationCenter defaultCenter] postNotificationName:ntf_BCardAdded object:self];
	
	return newBCard;
}

- (void)destroyBCard:(BCard*)bCard {
	for (Group* group in m_GroupList) {
		[group removeBCard:bCard];
		if ([group numberOfBCards] == 0) {
			[m_GroupList removeObject:group];
		}
	}
	
	[m_BCardList removeObject:bCard];
	
	[self.managedObjectContext deleteObject:bCard];
	
	[self save];
}

- (Photo*)createNewPhoto {
	Photo* newPhoto = (Photo*)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
	//Photo* newPhoto = [[[Photo alloc] initWithEntity:self.photoEntityDescription insertIntoManagedObjectContext:self.managedObjectContext] autorelease];
	return newPhoto;
}

- (void)save {
	NSError *error = nil;
	if (m_ManagedObjectContext != nil) {
		if ([m_ManagedObjectContext hasChanges] && ![m_ManagedObjectContext save:&error]) {
			[self presentUnrecoverableError:[error localizedDescription]];
		} 
	}
}

- (NSEntityDescription*)bCardEntityDescription {
    if (m_BCardEntityDescription == nil) {
        m_BCardEntityDescription = [[NSEntityDescription entityForName:@"BCard" inManagedObjectContext:self.managedObjectContext] retain];
    }
    return m_BCardEntityDescription;
}

- (NSEntityDescription*)photoEntityDescription {
    if (m_PhotoEntityDescription == nil) {
        m_PhotoEntityDescription = [[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext] retain];
    }
    return m_PhotoEntityDescription;
}

void abChanged (ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
	// Something changed in the address book
	[[AlertManager sharedManager] showSpinnerAlertViewWithMessage:NSLocalizedString(@"ABExternalReload_Message_Key", nil)];
	[[DataManager sharedManager] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (BOOL)reloadABTree {
	[m_ABGroupWList release];
	m_ABGroupWList = [[NSMutableArray alloc] init];
	
	[m_ABContactWDic release];
	m_ABContactWDic = [[NSMutableDictionary alloc] init];
	
	
	ABAddressBookRef addressBookRef = ABAddressBookCreate();
	
	// 1 - Search for all contacts
	CFArrayRef contactsArrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
	for (CFIndex i = 0; i < CFArrayGetCount(contactsArrayRef); i++) {
		ABRecordRef contactRef = CFArrayGetValueAtIndex(contactsArrayRef, i);
		ABContactW* contact = [[ABContactW alloc] initWithRecord:contactRef];
		NSNumber* contactID = [NSNumber numberWithInt:ABRecordGetRecordID(contactRef)];
		[m_ABContactWDic setObject:contact forKey:contactID];
		[contact release];
	}
	CFRelease(contactsArrayRef);
	
	// 2 - Search for all groups
	CFArrayRef groupsArrayRef = ABAddressBookCopyArrayOfAllGroups(addressBookRef);
	
	for (CFIndex i = 0; i < CFArrayGetCount(groupsArrayRef); i++) {
		ABRecordRef groupRef = CFArrayGetValueAtIndex(groupsArrayRef, i);
		ABGroupW* group = [[ABGroupW alloc] initWithRecord:groupRef];
		
		CFArrayRef contactsArrayRef = ABGroupCopyArrayOfAllMembers(groupRef);
		if (NULL != contactsArrayRef) {
			for (CFIndex j = 0; j < CFArrayGetCount(contactsArrayRef); j++) {
				ABRecordRef contactRef  = CFArrayGetValueAtIndex(contactsArrayRef, j);
				
				NSNumber* contactID = [NSNumber numberWithInt:ABRecordGetRecordID(contactRef)];
				ABContactW* contact = [m_ABContactWDic objectForKey:contactID];
				[m_ABContactWDic setObject:contact forKey:contactID];
				
				[group	 addContact:contact];
				[contact addGroup:group];
			}
			CFRelease(contactsArrayRef);
		}			

		[m_ABGroupWList addObject:group];
		[group release];
	}
	
	CFRelease(groupsArrayRef);
	CFRelease(addressBookRef);
	
	return YES;
}

- (void)reloadData {
	[[NSNotificationCenter defaultCenter] postNotificationName:ntf_ModelWillReload object:nil];
	
	BOOL needCoreDataSave = NO;
	
	// 0 - Remove all Data
	[m_BCardList	 removeAllObjects];
	[m_GroupList	 removeAllObjects];
	[m_ABGroupWList	 removeAllObjects];
	[m_ABContactWDic removeAllObjects];
	[self.managedObjectContext reset];
	
	// 1 - Reload all data from Address Book
	[self reloadABTree];
	
	
	// 2 - Retrieve all BCards stored in CoreData
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"BCard" inManagedObjectContext:m_ManagedObjectContext];
	[request setEntity:entity];
	
	NSError* error;
	NSMutableArray* mutableFetchResults = [[m_ManagedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	NSAssert(nil != mutableFetchResults, @"DataManager:reloadData - nil mutableFetchResults");
	
	self.bCardList = mutableFetchResults;
	[mutableFetchResults release];
	[request release];
	
	m_GroupList = [[NSMutableArray array] retain];
	
	
	// 3 - Match data
	NSString* lastName   = nil;
	NSString* firstName  = nil;
	NSString* company	 = nil;
	NSInteger identifier = 0;
	ABContactW* foundABContactW = nil;
	
	for (BCard* bCard in m_BCardList) {
		lastName   = bCard.lastName;
		firstName  = bCard.firstName;
		company	   = bCard.company;
		identifier = [bCard.identifier integerValue];
		foundABContactW = nil;
		
		// - 1st try : match with an ABPerson with its record identifier + 'first name' or 'last name' or 'company'
		for (ABContactW* abContactW in [m_ABContactWDic allValues]) {
			if ((identifier == abContactW.identifier) && ([lastName isEqualToString:abContactW.lastName] || [firstName isEqualToString:abContactW.firstName] || [company isEqualToString:abContactW.company])) {
				foundABContactW = [abContactW retain];
			}
		}
		
		// - 2nd try : match with an ABPerson with is name and first name (maybe the record identifier has changed during a sync session..)
		if (nil == foundABContactW) {
			for (ABContactW* abContactW in [m_ABContactWDic allValues]) {
				// Note : contacts with just firstName, or just lastName or a compan y will pass through this test.
				//
				if ([lastName isEqualToString:abContactW.lastName] && [firstName isEqualToString:abContactW.firstName]) {
					foundABContactW = [abContactW retain];
					
					// If we find the corresponding person, we update its identifier in CoreData
					bCard.identifier = [NSNumber numberWithInt:abContactW.identifier];
					needCoreDataSave = YES;
				}
			}
		}
		
		if (nil != foundABContactW) {
			for (ABGroupW* abGroupW in foundABContactW.groupsList) {
				NSString* groupName = abGroupW.groupName;
				Group* foundGroup = nil;
				for (Group* group in m_GroupList) {
					if ([groupName isEqualToString:group.groupName]) {
						[group addBCard:bCard];
						foundGroup = group;
						break;
					}
				}
				
				if (nil == foundGroup) {
					Group* group = [[Group alloc] init];
					group.groupName = groupName;
					[group addBCard:bCard];
					[m_GroupList addObject:group];
					[group release];
				}
			}
			
			[foundABContactW release];
		}
	}
	

	// 4 - Save
	if (needCoreDataSave) {
		[self save];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ntf_ModelDidReload object:nil];
}

- (void)registerBCardInGroups:(BCard*)bCard {
	ABContactW* contact = [m_ABContactWDic objectForKey:bCard.identifier];
	NSArray* arrayOfGroupW = contact.groupsList;
	
	Group* group = nil;
	for (ABGroupW* groupW in arrayOfGroupW) {
		group = [self groupByName:groupW.groupName];
		if (nil != group) {
			[group addBCard:bCard];
		} else {
			Group* group = [[Group alloc] init];
			group.groupName = groupW.groupName;
			[m_GroupList addObject:group];
			[group addBCard:bCard];
			[group release];
		}
	}
}

- (void)unregisterBCardInGroups:(BCard*)bCard {
	for (Group* group in m_GroupList) {
		[group removeBCard:bCard];
		if ([group numberOfBCards] == 0) {
			[m_GroupList removeObject:group];
		}		
	}
}

- (Group*)groupByName:(NSString*)name {
	Group* foundGroup = nil;
	
	if (nil != name) {
		for (Group* group in m_GroupList) {
			if ([group.groupName isEqualToString:name]) {
				foundGroup = group;
				break;
			}
		}	
	}
		
	return foundGroup;
}

- (void)updateDataOfBCard:(BCard*)bCard {
	ABAddressBookRef addressBookRef = ABAddressBookCreate();
	ABRecordRef ABPersonRef = ABAddressBookGetPersonWithRecordID(addressBookRef, [bCard.identifier intValue]);
	
	BOOL needSave = NO;
	
	if (NULL != ABPersonRef) {
		ABContactW* contact = [[ABContactW alloc] initWithRecord:ABPersonRef];
		
		if (![bCard.lastName isEqualToString:contact.lastName]) {
			bCard.lastName = contact.lastName;
			needSave = YES;
		}
		
		if (![bCard.firstName isEqualToString:contact.firstName]) {
			bCard.firstName =  contact.firstName;
			needSave = YES;
		}
		
		if (![bCard.company isEqualToString:contact.company]) {
			bCard.company = contact.company;
			needSave = YES;
		}

		[contact release];
	}
	
	CFRelease(addressBookRef);
	
	if (needSave) {
		[self save];
	}
}


#pragma mark -
#pragma mark Core Data
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext*)managedObjectContext {
    if (m_ManagedObjectContext != nil) {
        return m_ManagedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        m_ManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [m_ManagedObjectContext setPersistentStoreCoordinator:coordinator];
		[m_ManagedObjectContext setUndoManager:nil];
    }
    return m_ManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
- (NSManagedObjectModel*)managedObjectModel {
    if (m_ManagedObjectModel != nil) {
        return m_ManagedObjectModel;
    }
    m_ManagedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return m_ManagedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if (m_PersistentStoreCoordinator != nil) {
        return m_PersistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"BCard_iPhone.sqlite"]];
	
	/*
	 // Allow inferred migration from the original version of the application.
	 NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
	 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
	 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	 */
	
	NSError *error = nil;
    m_PersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![m_PersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		[self presentUnrecoverableError:[error localizedDescription]];
    }    
	
    return m_PersistentStoreCoordinator;
}


#pragma mark -
// Returns the path to the application's Documents directory.
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)presentUnrecoverableError:(NSString*)userInfo {
	// Typical reasons for an error here include:
	// * The persistent store is not accessible
	// * The schema for the persistent store is incompatible with current managed object model

	NSString* title	  = NSLocalizedString(@"UnrecoverableErrorPanel_Title_Key", nil);
	NSString* message = NSLocalizedString(@"UnrecoverableErrorPanel_Message_Key", nil);
	
	if (nil != userInfo) {
		message = [NSString stringWithFormat:@"\n\n%@", message];
	}
	
	UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	
	[errorAlert show];
	[errorAlert release];
}

#pragma mark -
#pragma mark AB Utilities
+ (NSInteger)contactsCount {
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSInteger count = ABAddressBookGetPersonCount(addressBook);
	CFRelease(addressBook);
	return count;
}

/*
+ (NSArray *) contacts {
	ABAddressBookRef addressBook = ABAddressBookCreate(); NSArray *thePeople = (NSArray *)
	ABAddressBookCopyArrayOfAllPeople(addressBook); NSMutableArray *array = [NSMutableArray
																			 arrayWithCapacity:thePeople.count]; for (id person in thePeople)
																				 [array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
	[thePeople release];
Recipe: Working with the Address Book	725
	return array;
}
The ABContact class hides an internal ABRecordRef, the CF type that corresponds to each contact record.The remaining portion of the wrapper involves nothing more than generating properties and methods that allow you to reach into the ABRecordRef to set and access its subrecords.
@interface ABContact : NSObject {
	ABRecordRef record;
} @end
*/

/*
 + (int) numberOfGroups {
 
 ABAddressBookRef addressBook = ABAddressBookCreate(); NSArray *groups =
 (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook); int ncount = groups.count; [groups release]; return ncount;
 }
 
 */


@end
