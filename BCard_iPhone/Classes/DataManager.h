//
//  DataManager.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 23/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCard, Group;
@class Photo;

@class ABGroupW, ABContactW;

@interface DataManager : NSObject {
    NSManagedObjectModel*		  m_ManagedObjectModel;
    NSManagedObjectContext*		  m_ManagedObjectContext;	    
    NSPersistentStoreCoordinator* m_PersistentStoreCoordinator;
	NSEntityDescription*		  m_BCardEntityDescription;
	NSEntityDescription*		  m_PhotoEntityDescription;
	
	NSMutableArray* m_BCardList;
	NSMutableArray* m_GroupList;
	
	NSMutableArray*		 m_ABGroupWList;
	NSMutableDictionary* m_ABContactWDic;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel*		  managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext*		  managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSEntityDescription*		  bCardEntityDescription;
@property (nonatomic, retain, readonly) NSEntityDescription*		  photoEntityDescription;

@property (nonatomic, retain) NSArray* bCardList;
@property (nonatomic, readonly) NSArray* groupList;

+ (DataManager*)sharedManager;
- (BCard*)createNewBCard;
- (void)destroyBCard:(BCard*)bCard;
- (Photo*)createNewPhoto;
- (void)save;
- (void)reloadData;

- (void)registerBCardInGroups:(BCard*)bCard;
- (void)unregisterBCardInGroups:(BCard*)bCard;

- (Group*)groupByName:(NSString*)name;
- (void)updateDataOfBCard:(BCard*)bCard;

@end
