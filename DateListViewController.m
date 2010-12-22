//
//  DateListViewController.m
//  Show Manager
//
//  Created by Robert Bohn on 7/11/10.
//  Copyright Barzutti, Co. All rights reserved.
//

#import "DateListViewController.h"
#import "CommonFunctions.h"
#import "ActivityViewController.h"
#import "CygnusServices.h"
#import "MerchantPackageViewController.h"

@implementation DateListViewController
@synthesize eventDictionary;


#pragma mark -
#pragma mark Initialization


- (id)init {	
	[super initWithStyle:UITableViewStyleGrouped];	
	return self;	
}


#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
    [super viewDidUnload];	
	[showdates release], showdates = nil;
}


- (void)dealloc {
	[showdates release];
    [super dealloc];
}


#pragma mark -
#pragma mark Overidden ViewController Methods


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
	[[self navigationItem] setTitle:description_1([eventDictionary valueForKey:@"event_desc"])];	
	
	if (merchantPackageViewController) {
		[merchantPackageViewController release], merchantPackageViewController = nil;
	}	
}


- (void)viewDidLoad 
{
    [super viewDidLoad];
	[[ActivityViewController sharedActivityViewController] openActivityView:@"Loading Show Dates..."];		
	[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='GetEventDateTimeList' device_id='%@' master_event_id='%@ ' />", [[UIDevice currentDevice] uniqueIdentifier],[eventDictionary valueForKey:@"event_id"]] delegate:self ];
}


#pragma mark -
#pragma mark Overidden UITableViewController Methods


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return [showdates count];	
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (!cell)	
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"] autorelease];
	
	NSString *startDate = [[showdates objectAtIndex:[indexPath row]] valueForKey:@"start_date"];	
	NSString *startTime = [[showdates objectAtIndex:[indexPath row]] valueForKey:@"start_time"];	
	NSDate *showdate = getDate(startDate, startTime);

	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"LLLL d, h:mma"];	
	[[cell textLabel] setText:[dateFormat stringFromDate:showdate]];	
	[dateFormat setDateFormat:@"EEEE"];	
	[[cell detailTextLabel] setText:[dateFormat stringFromDate:showdate]];	
	[dateFormat release];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (!merchantPackageViewController) 
		merchantPackageViewController = [[MerchantPackageViewController alloc] init];
	
	[merchantPackageViewController setEventDictionary:[self eventDictionary]];
	
	NSString *startDate = [[showdates objectAtIndex:[indexPath row]] valueForKey:@"start_date"];	
	NSString *startTime = [[showdates objectAtIndex:[indexPath row]] valueForKey:@"start_time"];		

	[merchantPackageViewController setShowDate:getDate(startDate, startTime)];
	[[self navigationController] pushViewController:merchantPackageViewController animated:YES];	
}


#pragma mark -
#pragma mark CygnusServices Delegates


- (void)requestCompleted:(NSString *)error
{	
	[[ActivityViewController sharedActivityViewController] closeActivityView];
	if (error) {		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:error delegate:nil cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil];
		[actionSheet showInView:[[self view] window]];
		[actionSheet autorelease];					
	} else {		
		showdates = [[CygnusServices sharedCygnusServices] getElements:@"showdate"];	
		[showdates retain];
		[[self tableView] reloadData];		
	}
}


@end
