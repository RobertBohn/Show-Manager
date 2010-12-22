//
//  ActivityViewController.h
//  GA Seating
//
//  Created by William and Mary on 7/2/10.
//  Copyright 2010 Universalis, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController {
	UIWindow *window;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UILabel *activityLabel;
+ (ActivityViewController *)sharedActivityViewController;
- (void)openActivityView:(NSString *)message;
- (void)closeActivityView;

@end
