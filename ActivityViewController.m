//
//  ActivityViewController.m
//  GA Seating
//
//  Created by Robert Bohn on 7/2/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import "ActivityViewController.h"

static ActivityViewController *sharedActivityViewController;

@implementation ActivityViewController
@synthesize window, activityLabel;


#pragma mark -
#pragma mark Singleton Implementation


+ (ActivityViewController *)sharedActivityViewController;
{
	if (!sharedActivityViewController) {
		sharedActivityViewController = [[ActivityViewController alloc] init];
	}
	return sharedActivityViewController;	
}


+ (id)allocwWithZone:(NSZone *)zone
{
	if (!sharedActivityViewController) {
		sharedActivityViewController = [super allocWithZone:zone];
		return sharedActivityViewController;
	} else {
		return nil;
	}
}	


- (id)copyWithZode:(NSZone *)zone
{
	return self;
}


- (void)release
{
	// No Op
}


#pragma mark -
#pragma mark Overridden View Methods


- (void)viewDidUnload {
    [super viewDidUnload];
	[activityIndicator release], activityIndicator = nil;
	[activityLabel release], activityLabel = nil;
}


#pragma mark -
#pragma mark Instance Methods


- (void)openActivityView:(NSString *)message
{	
	[window addSubview:[self view]];
	[activityLabel setText:message];	
}


- (void)closeActivityView
{
	[[self view] removeFromSuperview];
}


@end
