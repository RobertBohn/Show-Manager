//
//  EventListViewController.m
//  Show Manager
//
//  Created by Robert Bohn on 7/8/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import "EventListViewController.h"
#import "CygnusServices.h"
#import "ActivityViewController.h"
#import "DateListViewController.h"
#import "MerchantPackageViewController.h"
#import "CommonFunctions.h"

@implementation EventListViewController
@synthesize vendorDictionary;

#pragma mark -
#pragma mark Initialization


- (id)init
{	
	[super initWithStyle:UITableViewStyleGrouped];	
	return self;	
}


#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
    [super viewDidUnload];	
	[events release], events = nil;
}


- (void)dealloc {
	[events release];
    [super dealloc];
}


#pragma mark -
#pragma mark Overidden ViewController Methods


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
	[[self navigationItem] setTitle:[vendorDictionary valueForKey:@"vendor_name"]];	

	if (dateListViewController) {
		[dateListViewController release], dateListViewController = nil;
	}	
	if (merchantPackageViewController) {
		[merchantPackageViewController release], merchantPackageViewController = nil;
	}	
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[[ActivityViewController sharedActivityViewController] openActivityView:@"Loading Events..."];		
	[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='GetVendorEventList' device_id='%@' vendor_id='%@ ' />", [[UIDevice currentDevice] uniqueIdentifier],[vendorDictionary valueForKey:@"vendor_id"]] delegate:self ];
}


#pragma mark -
#pragma mark Overidden UITableViewController Methods


- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
	return [events count];	
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	// get a cell object
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (!cell)	
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"] autorelease];
	
	// cleanup the event description	
	[[cell textLabel] setText:description_1([[events objectAtIndex:[indexPath row]] valueForKey:@"event_desc"])];
	
	// format the show dates	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	NSString *minDate = [[events objectAtIndex:[indexPath row]] valueForKey:@"min_date"];	
	NSString *minTime = [[events objectAtIndex:[indexPath row]] valueForKey:@"min_time"];	
	NSString *maxDate = [[events objectAtIndex:[indexPath row]] valueForKey:@"max_date"];	
	NSString *maxTime = [[events objectAtIndex:[indexPath row]] valueForKey:@"max_time"];	
	NSDate *minShow = getDate(minDate, minTime);
	NSDate *maxShow = getDate(maxDate, maxTime);
	
	if ([minDate isEqual:maxDate]==YES) {		
		if ([minTime isEqual:maxTime]==YES) {
			// one show only		
			[dateFormat setDateFormat:@"EEEE, LLLL d, h:mma"];
			[[cell detailTextLabel] setText:[dateFormat stringFromDate:minShow]];
		} else {
			// one date - multiple times			
			[dateFormat setDateFormat:@"EEEE, LLLL d, h:mma"];
			NSString *temp = [dateFormat stringFromDate:minShow];
			[dateFormat setDateFormat:@"h:mma"];			
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ & %@", temp, [dateFormat stringFromDate:maxShow]]];
		}		
	} else {
		// range of dates
		[dateFormat setDateFormat:@"LLLL d"];
		[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %@",[dateFormat stringFromDate:minShow],[dateFormat stringFromDate:maxShow]]];
	}	
	[dateFormat release];

	return cell;
}


- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *minDate = [[events objectAtIndex:[indexPath row]] valueForKey:@"min_date"];	
	NSString *minTime = [[events objectAtIndex:[indexPath row]] valueForKey:@"min_time"];	
	NSString *maxDate = [[events objectAtIndex:[indexPath row]] valueForKey:@"max_date"];	
	NSString *maxTime = [[events objectAtIndex:[indexPath row]] valueForKey:@"max_time"];	
	
	if ([minDate isEqual:maxDate]==YES &&[minTime isEqual:maxTime]==YES) {		
		if (!merchantPackageViewController) 
			merchantPackageViewController = [[MerchantPackageViewController alloc] init];
		
		[merchantPackageViewController setEventDictionary:[events objectAtIndex:[indexPath row]]];		
		[merchantPackageViewController setShowDate:getDate(minDate, minTime)];
		[[self navigationController] pushViewController:merchantPackageViewController animated:YES];			
	} else {
		if (!dateListViewController) 
			dateListViewController = [[DateListViewController alloc] init];
		
		[dateListViewController setEventDictionary:[events objectAtIndex:[indexPath row]]];
		[[self navigationController] pushViewController:dateListViewController animated:YES];
	}	
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
		events = [[CygnusServices sharedCygnusServices] getElements:@"event"];	
		[events retain];
		[[self tableView] reloadData];		
	}
}


@end
