//
//  Show_ManagerAppDelegate.m
//  Show Manager
//
//  Created by Robert Bohn on 7/8/10.
//  Copyright Barzutti, Co. 2010. All rights reserved.
//

#import "Show_ManagerAppDelegate.h"
#import "VendorListViewController.h"
#import "ActivityViewController.h"

@implementation Show_ManagerAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	[[ActivityViewController sharedActivityViewController] setWindow:window];
	vendorListViewController = [[VendorListViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vendorListViewController];
	[window addSubview:[navController view]];
    [window makeKeyAndVisible];	
	return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}
@end
