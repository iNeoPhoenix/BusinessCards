//
//  ABContactW.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 11/07/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class ABGroupW;

@interface ABContactW : NSObject {
	ABRecordRef		m_Record;
	NSMutableArray* m_GroupsList;
}

@property (nonatomic, readonly) NSArray* groupsList;

@property (nonatomic, readonly) NSString* firstName;
@property (nonatomic, readonly) NSString* lastName;
@property (nonatomic, readonly) NSInteger identifier;
@property (nonatomic, readonly) NSString* company;
@property (nonatomic, readonly) NSString* job;
@property (nonatomic, readonly) NSArray*  phones;
@property (nonatomic, readonly) NSArray*  mails;

- (id)initWithRecord:(ABRecordRef)record;
- (void)addGroup:(ABGroupW*)group;

@end
