//
//  Group.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 23/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "Group.h"
#import "BCard.h"

@implementation Group

@synthesize groupName = m_GroupName;
@synthesize bCardList = m_BCardList;

- (id)init {
	if (self = [super init]) {
		m_BCardList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[m_BCardList release];
	[m_GroupName release];
	[super dealloc];
}

- (void)addBCard:(BCard*)bCard {
	[m_BCardList addObject:bCard];
}

- (void)removeBCard:(BCard*)bCard {
	[m_BCardList removeObject:bCard];
}

- (NSUInteger)numberOfBCards {
	return [m_BCardList count];
}

@end
