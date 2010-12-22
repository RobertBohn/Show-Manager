//
//  VendorListViewController.m
//  Show Manager
//
//  Created by Robert Bohn on 7/8/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import "VendorListViewController.h"
#import "CygnusServices.h"
#import "ActivityViewController.h"
#import "EventListViewController.h"

@implementation VendorListViewController


#pragma mark -
#pragma mark Initialization


- (id)init
{	
	[super initWithStyle:UITableViewStyleGrouped];	
	return self;	
}


#pragma mark -
#pragma mark Memory management


- (void)dealloc {
	[eventListViewController release];
	[vendors release];
    [super dealloc];
}


#pragma mark -
#pragma mark Overidden UITableViewController Methods


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return [vendors count];	
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[[ActivityViewController sharedActivityViewController] openActivityView:@"Loading Vendors..."];		
	[[CygnusServices sharedCygnusServices] requestService:[NSString stringWithFormat:@"<SERVICE request_type='GetVendorList' device_id='%@' />", [[UIDevice currentDevice] uniqueIdentifier]] delegate:self];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (!cell)	
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"] autorelease];
	
    [[cell textLabel] setText:[[vendors objectAtIndex:[indexPath row]] valueForKey:@"vendor_name"]];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!eventListViewController)
		eventListViewController = [[EventListViewController alloc] init];
	
	[eventListViewController setVendorDictionary:[vendors objectAtIndex:[indexPath row]]];
	
	[[self navigationController] pushViewController:eventListViewController animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];		
	[[self navigationItem] setTitle:@"Vendors"];
	
	if (eventListViewController) {
		[eventListViewController release], eventListViewController = nil;
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
		vendors = [[CygnusServices sharedCygnusServices] getElements:@"vendor"];	
		[vendors retain];
		[[self tableView] reloadData];		
	}
}


@end
