//
//  CustomerTypeListViewContoller.h
//  Show Manager
//
//  Created by Robert Bohn on 7/16/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerTypeListViewContoller : UITableViewController {
	NSMutableArray *customerTypes;
	NSMutableArray *packages;
	NSMutableArray *merchants;	
	NSMutableDictionary *eventDictionary;
	NSMutableDictionary *packageDictionary;
	NSMutableDictionary *merchantDictionary;
	NSDate *showDate;
}
@property (nonatomic, assign) NSMutableDictionary *eventDictionary;
@property (nonatomic, assign) NSMutableDictionary *packageDictionary;
@property (nonatomic, assign) NSMutableDictionary *merchantDictionary;
@property (nonatomic, assign) NSDate *showDate;

@end
