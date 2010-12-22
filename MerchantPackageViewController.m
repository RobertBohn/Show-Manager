//
//  MerchantPackageViewController.m
//  Show Manager
//
//  Created by Robert Bohn on 7/15/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import "MerchantPackageViewController.h"
#import "CommonFunctions.h"
#import "ActivityViewController.h"
#import	"CustomerTypeListViewContoller.h"
#import "CygnusServices.h"

@implementation MerchantPackageViewController
@synthesize eventDictionary, showDate;

int row, section, isOn;

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
	[packages release], packages = nil;
	[merchants release], merchants = nil;
	[showDate release], showDate = nil;
}


- (void)dealloc {
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
	[[self navigationItem] setTitle:@"Merchant Packages"];	
	
	if (customerTypeListViewContoller) {
		[customerTypeListViewContoller release], customerTypeListViewContoller = nil;
	}	
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
	
	[[ActivityViewController sharedActivityViewController] openActivityView:@"Loading Merchant Packages..."];		
	[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='GetMerchantsAndPackagesList' device_id='%@' master_event_id='%@' start_date='%@' start_time='%@' />", [[UIDevice currentDevice] uniqueIdentifier],[eventDictionary valueForKey:@"event_id"],start_date,start_time] delegate:self ];
}


#pragma mark -
#pragma mark Overidden UITableViewController Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return (packages) ? 2 : 0;
}


- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return (section==MerchantSection) ? @"Merchants" : @"Packages";	
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return (section==MerchantSection) ? [merchants count] : [packages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (!cell)	
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"] autorelease];
	
	UISwitch *activeControl = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
	[activeControl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
	[activeControl setTag: ([indexPath section]*1000)+[indexPath row]];	
	[cell addSubview:activeControl];
	[cell setAccessoryView:activeControl];	
	
	if ([indexPath section]==MerchantSection) {		
		[[cell textLabel] setText:description_1([[merchants objectAtIndex:[indexPath row]] valueForKey:@"merchant_name"])];
		[[cell detailTextLabel] setText:description_2([[merchants objectAtIndex:[indexPath row]] valueForKey:@"merchant_name"])];
		NSString *flag = [[merchants objectAtIndex:[indexPath row]] valueForKey:@"active_flag"];	
		if ([flag isEqual:@"1"]==YES) [activeControl setOn:YES];
		
	} else {
		[[cell textLabel] setText:description_1([[packages objectAtIndex:[indexPath row]] valueForKey:@"package_desc"])];
		[[cell detailTextLabel] setText:description_2([[packages objectAtIndex:[indexPath row]] valueForKey:@"package_desc"])];
		NSString *flag = [[packages objectAtIndex:[indexPath row]] valueForKey:@"active_flag"];	
		if ([flag isEqual:@"1"]==YES) [activeControl setOn:YES];				
	}
	return cell;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if (!customerTypeListViewContoller) 
		customerTypeListViewContoller = [[CustomerTypeListViewContoller alloc] init];
	
	[customerTypeListViewContoller setEventDictionary:[self eventDictionary]];
	[customerTypeListViewContoller setShowDate:showDate];	
	
	if ([indexPath section]==MerchantSection)
		[customerTypeListViewContoller setMerchantDictionary:[merchants objectAtIndex:[indexPath row]]];
	else
		[customerTypeListViewContoller setPackageDictionary:[packages objectAtIndex:[indexPath row]]];	
	
	[[self navigationController] pushViewController:customerTypeListViewContoller animated:YES];	
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
		[packages release],	[merchants release];		
		packages = [[CygnusServices sharedCygnusServices] getElements:@"package"];		
		[packages retain];		
		merchants = [[CygnusServices sharedCygnusServices] getElements:@"merchant"];	
		[merchants retain];			
	}
	[[self tableView] reloadData];		
}


#pragma mark -
#pragma mark On/Off Switch Delegates


- (void)switchAction:(UISwitch*)sender
{	
	row = [sender tag] % 1000;
	section = [sender tag] / 1000;	
	isOn = [sender isOn];
	NSString *onOff = (isOn==1) ? @"on" : @"off";	
	NSString *merchantPackage = (section==MerchantSection) ? @"merchant" : @"package";
	NSString *name = (section==MerchantSection) ? trim([[merchants objectAtIndex:row] valueForKey:@"merchant_name"]) : trim([[packages objectAtIndex:row] valueForKey:@"package_desc"]);		
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat: @"Are you sure you want to turn %@ %@ %@?", onOff, merchantPackage, name] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet autorelease];	
}


#pragma mark -
#pragma mark UIActionSheet Delegates


- (void)actionSheet:(UIActionSheet *)actionSheet 
didDismissWithButtonIndex:(NSInteger)buttonIndex
{		
	// Did the user Cancel the turn on/off request?
	if (buttonIndex==1) {
		[[self tableView] reloadData];			
	} else {		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyyMMdd"];	
		NSString *start_date = [dateFormat stringFromDate:showDate];	
		[dateFormat setDateFormat:@"HH:mm"];	
		NSString *start_time = [dateFormat stringFromDate:showDate];	
		[dateFormat release];	
	
		[[ActivityViewController sharedActivityViewController] openActivityView:@"Processing Request..."];		
		if (section==MerchantSection) 			 
			[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='SetMerchantPackageActiveFlag' device_id='%@' master_event_id='%@' merchant_id='%@' start_date='%@' start_time='%@' active_flag='%d' />", [[UIDevice currentDevice] uniqueIdentifier],[eventDictionary valueForKey:@"event_id"],[[merchants objectAtIndex:row] valueForKey:@"merchant_id"],start_date,start_time,isOn] delegate:self ];
		else
			[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='SetMerchantPackageActiveFlag' device_id='%@' package_id='%@' start_date='%@' start_time='%@' active_flag='%d' master_event_id='%@' />", [[UIDevice currentDevice] uniqueIdentifier],[[packages objectAtIndex:row] valueForKey:@"package_id"],start_date,start_time,isOn,[eventDictionary valueForKey:@"event_id"]] delegate:self ];
	}
}

@end
