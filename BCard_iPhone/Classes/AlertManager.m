//
//  AlertManager.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 13/07/10.
//  Copyright 2010 Cokoala. All rights reserved.
//

#import "AlertManager.h"


@interface AlertManager ()
@property (nonatomic, retain) UIAlertView* alertView;
@end


@implementation AlertManager

static AlertManager* s_SharedAlertManager = nil;

@synthesize alertView = m_AlertView;

+ (id)sharedManager {
	if (nil == s_SharedAlertManager) {
		s_SharedAlertManager = [[AlertManager alloc] init];
	}
	return s_SharedAlertManager;
}

+ (void)requestDealloc {
	[s_SharedAlertManager release];
}

+ (BOOL)sharedManagerExists {
	return (nil != s_SharedAlertManager);
}


#pragma mark -
#pragma mark Singleton management
+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if(nil == s_SharedAlertManager) {
			s_SharedAlertManager = [super allocWithZone:zone];
			return s_SharedAlertManager;
		}
	}
	return nil;
}

- (id)init {
	if (self = [super init]) {
		m_ClientsForNetworkActicityIndicator = 0;
	}
	return self;	
}

- (void)dealloc {
	self.alertView = nil;	
	[super dealloc];
}

#pragma mark -
#pragma mark Public methods
- (void)showNetworkActivityIndicator {
	m_ClientsForNetworkActicityIndicator++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkActivityIndicator {
	if (m_ClientsForNetworkActicityIndicator > 0) {
		m_ClientsForNetworkActicityIndicator--;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}


- (void)showSpinnerAlertViewWithMessage:(NSString*)message {
	if (nil == self.alertView) {
		self.alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
		[self.alertView show];
		
		// Create and add the activity indicator 
		UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]; 
		activityIndicator.center = CGPointMake(self.alertView.bounds.size.width / 2.0f, self.alertView.bounds.size.height - 40.0f); 
		[activityIndicator startAnimating];
		[self.alertView addSubview:activityIndicator]; 
		[activityIndicator release];
				
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
}

- (void)hideAlertViewAnimated:(BOOL)animated {
	[self.alertView dismissWithClickedButtonIndex:0 animated:animated];
	self.alertView = nil;
}


#pragma mark -
#pragma mark Private methods




@end
