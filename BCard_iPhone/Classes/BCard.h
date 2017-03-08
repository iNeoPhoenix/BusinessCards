//
//  BCard.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 22/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Photo;

@interface BCard :  NSManagedObject {
	CGRect m_FrontCropRect;
	CGRect m_BackCropRect;
	NSString* m_Company;
} 

@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSNumber * identifier;

@property (nonatomic, retain) id frontThumbnail;
@property (nonatomic, retain) id backThumbnail;
@property (nonatomic, retain) Photo * frontPhoto;
@property (nonatomic, retain) Photo * backPhoto;
@property (nonatomic, retain) Photo * frontOriginalPhoto;
@property (nonatomic, retain) Photo * backOriginalPhoto;
@property (nonatomic, retain) NSString* frontCropRectAsString;
@property (nonatomic, retain) NSString* backCropRectAsString;

@property (nonatomic, assign) CGRect frontCropRect;
@property (nonatomic, assign) CGRect backCropRect;

- (NSString*)textForFiltering;

@end



