//
//  BCard_iPhoneAppDelegate.m
//  BCard_iPhone
//
//  Created by Stéphane Chrétien on 14/02/10.
//  Copyright Cokoala 2010. All rights reserved.
//

#import "BCard_iPhoneAppDelegate.h"

// Model
#import "DataManager.h"

// Controller
#import "MainNavigationController.h"


@implementation BCard_iPhoneAppDelegate

@synthesize window = m_Window;
@synthesize mainNavigationController = m_MainNavigationController;

- (void)applicationDidFinishLaunching:(UIApplication*)application {    
	m_Window.backgroundColor = [UIColor blackColor];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	[m_Window addSubview:m_MainNavigationController.view];
	[m_Window makeKeyAndVisible];
}

- (void)dealloc {
	[m_MainNavigationController release];
	[m_Window					release];
	
	[super dealloc];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Bide some memory (15 Mo)
	//void* mem = malloc(sizeof(int) * 4000000);
	//free(mem);
	[[DataManager sharedManager] reloadData];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[DataManager sharedManager] save];
	[m_MainNavigationController  save];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"MEMORY WARNING");
}

@end
