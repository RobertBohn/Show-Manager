//
//  MerchantPackageViewController.h
//  Show Manager
//
//  Created by Robert Bohn on 7/15/10.
//  Copyright 2010 UBarzutti, Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@class	CustomerTypeListViewContoller;

@interface MerchantPackageViewController : UITableViewController <UIActionSheetDelegate> {
	NSMutableArray *packages;
	NSMutableArray *merchants;
	NSMutableDictionary *eventDictionary;
	NSDate *showDate;
	CustomerTypeListViewContoller *customerTypeListViewContoller;
}
@property (nonatomic, assign) NSMutableDictionary *eventDictionary;
@property (nonatomic, assign) NSDate *showDate;

typedef enum {
	MerchantSection,
	PackageSection
} MerchantPackageViewControllerSections;

@end
