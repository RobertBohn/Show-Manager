//
//  EventListViewController.h
//  Show Manager
//
//  Created by Robert Bohn on 7/8/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DateListViewController;
@class MerchantPackageViewController;

@interface EventListViewController : UITableViewController <UIActionSheetDelegate> {
	NSMutableArray *events;
	NSMutableDictionary *vendorDictionary;
	DateListViewController *dateListViewController;
	MerchantPackageViewController *merchantPackageViewController;
}
@property (nonatomic, assign) NSMutableDictionary *vendorDictionary;

@end
