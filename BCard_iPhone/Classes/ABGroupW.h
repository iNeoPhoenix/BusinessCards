//
//  ABGroupW.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 11/07/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class ABContactW;

@interface ABGroupW : NSObject {
	ABRecordRef		m_Record;
	NSMutableArray* m_ContactsList;
}

@property (nonatomic, readonly) NSArray* contactsList;
@property (nonatomic, readonly) NSString* groupName;

- (id)initWithRecord:(ABRecordRef)record;
- (void)addContact:(ABContactW*)contact;

@end
