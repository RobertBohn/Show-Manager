//
//  Show_ManagerAppDelegate.h
//  Show Manager
//
//  Created by Robert Bohn on 7/8/10.
//  Copyright Barzutti, Co. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VendorListViewController;

@interface Show_ManagerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	VendorListViewController *vendorListViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

