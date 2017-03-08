//
//  ABGroupW.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 11/07/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "ABGroupW.h"


@implementation ABGroupW

@dynamic groupName;
@synthesize contactsList = m_ContactsList;

- (id)initWithRecord:(ABRecordRef)record {
	if (self = [super init]) {
		m_Record = CFRetain(record);
		m_ContactsList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	CFRelease(m_Record);
	[m_ContactsList release];
	
	[super dealloc];
}

- (NSString*)groupName {
	return [(NSString*)ABRecordCopyCompositeName(m_Record) autorelease];
}

/*
 - (NSString *) firstname
 {return [self getRecordString:kABPersonFirstNameProperty];} - (NSString *) lastname
 {return [self getRecordString:kABPersonLastNameProperty];}
 
 ABRecordID abContactID = ABRecordGetRecordID(abContact);
 CFTypeRef abLastName   = ABRecordCopyValue(abContact, kABPersonLastNameProperty);
 
 */

- (void)addContact:(ABContactW*)contact {
	NSAssert(![m_ContactsList containsObject:contact], @"Try to add a contact twice");
	[m_ContactsList addObject:contact];
}

@end
