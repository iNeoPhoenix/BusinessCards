// 
//  BCard.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 22/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "BCard.h"

#import "Photo.h"

#import "UIImageToDataTransformer.h"

@implementation BCard 

@dynamic firstName;
@dynamic lastName;
@dynamic company;
@dynamic frontThumbnail;
@dynamic backThumbnail;
@dynamic identifier;
@dynamic frontPhoto;
@dynamic backPhoto;
@dynamic frontOriginalPhoto;
@dynamic backOriginalPhoto;
@dynamic frontCropRectAsString;
@dynamic backCropRectAsString;
@synthesize frontCropRect = m_FrontCropRect;
@synthesize backCropRect  = m_BackCropRect;

+ (void)initialize {
	if (self == [BCard class]) {
		UIImageToDataTransformer *transformer = [[UIImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"UIImageToDataTransformer"];
	}
}

- (CGRect)frontCropRect {
	[self willAccessValueForKey:@"frontCropRect"];
	CGRect aRect = m_FrontCropRect; 
	[self didAccessValueForKey:@"frontCropRect"]; 
	if (aRect.size.width == 0) {
		NSString *frontCropRectAsString = [self frontCropRectAsString];
		if (frontCropRectAsString != nil) {
			m_FrontCropRect = CGRectFromString(frontCropRectAsString);
		}
	}
	return m_FrontCropRect;
}

- (void)setFrontCropRect:(CGRect)aRect {
	[self willChangeValueForKey:@"frontCropRect"]; 
	m_FrontCropRect = aRect; 
	[self didChangeValueForKey:@"frontCropRect"];
	
	NSString *rectAsString = NSStringFromCGRect(aRect); 
	[self setValue:rectAsString forKey:@"frontCropRectAsString"];
}

- (CGRect)backCropRect {
	[self willAccessValueForKey:@"backCropRect"];
	CGRect aRect = m_BackCropRect; 
	[self didAccessValueForKey:@"backCropRect"]; 
	if (aRect.size.width == 0) {
		NSString *backCropRectAsString = [self backCropRectAsString];
		if (backCropRectAsString != nil) {
			m_BackCropRect = CGRectFromString(backCropRectAsString);
		}
	}
	return m_BackCropRect;
}

- (void)setBackCropRect:(CGRect)aRect {
	[self willChangeValueForKey:@"backCropRect"]; 
	m_BackCropRect = aRect; 
	[self didChangeValueForKey:@"backCropRect"];
	
	NSString *rectAsString = NSStringFromCGRect(aRect); 
	[self setValue:rectAsString forKey:@"backCropRectAsString"];
}

- (NSString*)textForFiltering {
	if (nil != self.lastName) {
		return self.lastName;
	} else if (nil != self.firstName) {
		return self.firstName;
	} else if (nil != self.company) {
		return self.company;
	}
	
	return nil;	
}

@end
