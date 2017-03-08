//
//  UIImageToDataTransformer.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 22/02/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "UIImageToDataTransformer.h"


@implementation UIImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value {
	return [[[UIImage alloc] initWithData:value] autorelease];
}

@end

