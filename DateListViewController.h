//
//  DateListViewController.h
//  Show Manager
//
//  Created by Robert Bohn on 7/11/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MerchantPackageViewController;

@interface DateListViewController : UITableViewController {
	NSMutableArray *showdates;
	NSMutableDictionary *eventDictionary;
	MerchantPackageViewController *merchantPackageViewController;
}
@property (nonatomic, assign) NSMutableDictionary *eventDictionary;

@end
