//
//  ABContactW.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 11/07/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "ABContactW.h"

#import "ABGroupW.h"


@implementation ABContactW

@synthesize groupsList = m_GroupsList;
@dynamic firstName, lastName, identifier, company, job, phones, mails;

- (id)initWithRecord:(ABRecordRef)record {
	if (self = [super init]) {
		m_Record = CFRetain(record);
		m_GroupsList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	CFRelease(m_Record);
	[m_GroupsList release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public methods
- (void)addGroup:(ABGroupW*)group {
	NSAssert(![m_GroupsList containsObject:group], @"Try to add a group twice");
	[m_GroupsList addObject:group];
}

#pragma mark -
#pragma mark Getters
- (NSString*)firstName {
	return [(NSString*)ABRecordCopyValue(m_Record, kABPersonFirstNameProperty) autorelease];
}

- (NSString*)lastName {
	return [(NSString*)ABRecordCopyValue(m_Record, kABPersonLastNameProperty) autorelease];
}

- (NSInteger)identifier {
	return (NSInteger)ABRecordGetRecordID(m_Record);
}

- (NSString*)company {
	return [(NSString*)ABRecordCopyValue(m_Record, kABPersonOrganizationProperty) autorelease];
}

- (NSString*)job {
	return [(NSString*)ABRecordCopyValue(m_Record, kABPersonJobTitleProperty) autorelease];
}

- (NSArray*)phones {
	ABMutableMultiValueRef multiValueRef = ABRecordCopyValue(m_Record, kABPersonPhoneProperty);
	CFArrayRef arrayRef = ABMultiValueCopyArrayOfAllValues(multiValueRef);
	CFRelease(multiValueRef);

	return [(NSArray*)arrayRef autorelease];
}

- (NSArray*)mails {
	ABMutableMultiValueRef multiValueRef = ABRecordCopyValue(m_Record, kABPersonEmailProperty);
	CFArrayRef arrayRef = ABMultiValueCopyArrayOfAllValues(multiValueRef);
	CFRelease(multiValueRef);
	
	return [(NSArray*)arrayRef autorelease];
}
/*
- (NSString*)vCardRepresentation {
	NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
	
	[mutableArray addObject:@"BEGIN:VCARD"];
	[mutableArray addObject:@"VERSION:3.0"];
	
	[mutableArray addObject:[NSString stringWithFormat:@"FN:%@", self.name]];
	
	[mutableArray addObject:[NSString stringWithFormat:@"ADR:;;%@",
							 [self addressWithSeparator:@";"]]];
	
	if (self.phone != nil)
		[mutableArray addObject:[NSString stringWithFormat:@"TEL:%@", self.phone]];
	
	[mutableArray addObject:[NSString stringWithFormat:@"GEO:%g;%g",
							 self.latitudeValue, self.longitudeValue]];
	
	[mutableArray addObject:[NSString stringWithFormat:@"URL:http://%@",
							 self.website]];
	
	[mutableArray addObject:@"END:VCARD"];
	
	NSString *string = [mutableArray componentsJoinedByString:@"\n"];
	
	[mutableArray release];
	
	return string;
}
*/
@end
