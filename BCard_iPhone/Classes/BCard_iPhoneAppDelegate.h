//
//  BCard_iPhoneAppDelegate.h
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 14/02/10.
//  Copyright Cokoala 2010. All rights reserved.
//

@class MainNavigationController;

@interface BCard_iPhoneAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow* m_Window;
	MainNavigationController* m_MainNavigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet MainNavigationController* mainNavigationController;

@end
