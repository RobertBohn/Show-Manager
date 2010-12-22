//
//  VendorListViewController.h
//  Show Manager
//
//  Created by Robert Bohn on 7/8/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventListViewController;

@interface VendorListViewController : UITableViewController {
	NSMutableArray *vendors;
	EventListViewController *eventListViewController;
}

@end
