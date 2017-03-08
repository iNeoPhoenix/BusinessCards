//
//  Group.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 23/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCard;

@interface Group : NSObject {
	NSString* m_GroupName;
	NSMutableArray* m_BCardList;
}

@property (nonatomic, copy) NSString* groupName;
@property (nonatomic, readonly) NSArray* bCardList;

- (void)addBCard:(BCard*)bCard;
- (void)removeBCard:(BCard*)bCard;
- (NSUInteger)numberOfBCards;

@end
