//
//  CustomerTypeListViewContoller.m
//  Show Manager
//
//  Created by Robert Bohn on 7/16/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import "CustomerTypeListViewContoller.h"
#import "CommonFunctions.h"
#import "ActivityViewController.h"
#import "CygnusServices.h"

@implementation CustomerTypeListViewContoller
@synthesize eventDictionary, packageDictionary, merchantDictionary, showDate;


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
	[customerTypes release], customerTypes = nil;	
	[packages release], packages = nil;	
	[merchants release], merchants = nil;	
	[showDate release], showDate = nil;
}


- (void)dealloc {
	[customerTypes release];	
	[packages release];	
	[merchants release];	
	[showDate release];
    [super dealloc];
}


#pragma mark -
#pragma mark Overidden ViewController Methods


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
	[[self navigationItem] setTitle:@"Customer Types"];	
}


- (void)viewDidLoad 
{
    [super viewDidLoad];	
	[showDate retain];	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyyMMdd"];	
	NSString *start_date = [dateFormat stringFromDate:showDate];	
	[dateFormat setDateFormat:@"HH:mm"];	
	NSString *start_time = [dateFormat stringFromDate:showDate];	
	[dateFormat release];		

	[[ActivityViewController sharedActivityViewController] openActivityView:@"Loading Customer Types..."];		
	if (packageDictionary) 
		[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='GetMerchantPackageCustomerTypes' device_id='%@' package_id='%@' start_date='%@' start_time='%@' />", [[UIDevice currentDevice] uniqueIdentifier],[packageDictionary valueForKey:@"package_id"],start_date,start_time] delegate:self ];
	else 
		[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='GetMerchantPackageCustomerTypes' device_id='%@' master_event_id='%@' merchant_id='%@' start_date='%@' start_time='%@'/>", [[UIDevice currentDevice] uniqueIdentifier],[eventDictionary valueForKey:@"event_id"],[merchantDictionary valueForKey:@"merchant_id"],start_date,start_time] delegate:self ];
}


#pragma mark -
#pragma mark Overidden UITableViewController Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (packageDictionary) 
		return [merchants count];
	else 
		return [packages count];
}


- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	if (packageDictionary) 
		return trim([[merchants objectAtIndex:section] valueForKey:@"merchant_name"]);	
	else
		return trim([[packages objectAtIndex:section] valueForKey:@"package_desc"]);	
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{	
	if (packageDictionary) 
		return [[[merchants objectAtIndex:section] valueForKey:@"count"] intValue];	
	else
		return [[[packages objectAtIndex:section] valueForKey:@"count"] intValue];	
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (!cell)	
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"] autorelease];
	
	if (packageDictionary) {
		NSString *merchant_id = [[merchants objectAtIndex:[indexPath section]] valueForKey:@"merchant_id"];	
		int idx = -1;
		for (int i=0; i<[customerTypes count]; i++) {
			if ([merchant_id isEqual:[[customerTypes objectAtIndex:i] valueForKey:@"merchant_id"]]) {
				idx++;
				if (idx == [indexPath row]) {
					[[cell textLabel] setText:[[customerTypes objectAtIndex:i] valueForKey:@"customer_type_desc"]];	
					[[cell detailTextLabel] setText:[NSString stringWithFormat:@"$%@",[[customerTypes objectAtIndex:i] valueForKey:@"retail_price"]]];	
				}			
			}			
		}		
	} else {		
		NSString *package_id = [[packages objectAtIndex:[indexPath section]] valueForKey:@"package_id"];	
		int idx = -1;
		for (int i=0; i<[customerTypes count]; i++) {
			if ([package_id isEqual:[[customerTypes objectAtIndex:i] valueForKey:@"package_id"]]) {
				idx++;
				if (idx == [indexPath row]) {
					[[cell textLabel] setText:[[customerTypes objectAtIndex:i] valueForKey:@"customer_type_desc"]];	
					[[cell detailTextLabel] setText:[NSString stringWithFormat:@"$%@",[[customerTypes objectAtIndex:i] valueForKey:@"retail_price"]]];	
				}			
			}			
		}	
	}	
	return cell;
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
		customerTypes = [[CygnusServices sharedCygnusServices] getElements:@"detail"];	
		[customerTypes retain];		
		
		if (packageDictionary) {
			merchants = [[CygnusServices sharedCygnusServices] getElements:@"merchant"];	
			[merchants retain];	
		} else {
			packages = [[CygnusServices sharedCygnusServices] getElements:@"package"];	
			[packages retain];		
		}		
		
		[[self tableView] reloadData];		
	}
}


@end
