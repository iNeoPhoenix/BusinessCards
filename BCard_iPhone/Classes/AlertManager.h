//
//  AlertManager.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 13/07/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertManager : NSObject {
	NSUInteger m_ClientsForNetworkActicityIndicator;
	UIAlertView* m_AlertView;
}

+ (id)sharedManager;
+ (void)requestDealloc;
+ (BOOL)sharedManagerExists;

- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;

- (void)showSpinnerAlertViewWithMessage:(NSString*)message;
- (void)hideAlertViewAnimated:(BOOL)animated;

@end
