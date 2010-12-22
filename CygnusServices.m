//
//  CygnusServices.m
//
//  Created by Robert Bohn on 6/24/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import "CygnusServices.h"

static CygnusServices *sharedCygnusServices;

@implementation CygnusServices

#pragma mark -
#pragma mark Initialization


- (id)init
{
	[super init];
	host = [[NSString alloc] initWithString:@"https://secure.prestigeticketing.com/ceGateway/servlet/gateway"];
	connectionTimeoutInterval = 10.0;
	requestTimeoutInterval = 40.0;		
	return self;	
}


#pragma mark -
#pragma mark Singleton Implementation


+ (CygnusServices *)sharedCygnusServices;
{
	if (!sharedCygnusServices) {
		sharedCygnusServices = [[CygnusServices alloc] init];
	}
	return sharedCygnusServices;	
}


+ (id)allocwWithZone:(NSZone *)zone
{
	if (!sharedCygnusServices) {
		sharedCygnusServices = [super allocWithZone:zone];
		return sharedCygnusServices;
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
#pragma mark Instance Methods


// Method returning an NSMutableArray of NSDictionary elements from the response XML for a requested tag
- (NSMutableArray *)getElements:(NSString *)tag
{
	[tagName release];
	tagName = [[NSString alloc] initWithString:tag];
	
	[elements release];
	elements = [[NSMutableArray alloc] init];
	
	// Parse the XML from the response data
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	return elements;
}


// Method returning the Cycnus Status
- (NSString *)status 
{
	if (!xmlData)
		return @"No response data found.";
	
	NSMutableArray *serviceElement = [self getElements:@"SERVICE"];	
	if ([serviceElement count] < 1)
		return @"SERVICE emelent not found.";
	
	NSDictionary *dict = [serviceElement objectAtIndex:0];	
	NSString *serviceStatus = [dict valueForKey:@"status"];	
	NSString *serviceError = [dict valueForKey:@"error_msg"];	
	
	if (!serviceStatus)
		return @"STATUS not found in SERVICE element.";
	
	if ([serviceStatus compare:@"OK"] == 0)
		return nil;
	
	if (!serviceError)
		return serviceStatus;		 
	
	return serviceError;
}


// Method to send a Cygnus Service Request
- (void)requestService:(NSString *)requestString delegate:(id)caller
{	
	delegate = caller;
	
	// Build the request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:host] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:connectionTimeoutInterval]; 
    [request setHTTPMethod:@"POST"]; 
    [request setHTTPBody:[[NSString stringWithFormat:@"%@", requestString] dataUsingEncoding:NSUTF8StringEncoding]]; 
	
	// Instanciate the object to hold the response
	[xmlData release];
	xmlData = [[NSMutableData alloc] init];
	
	// Create a timer to catch request timeout errors
	timer = [NSTimer scheduledTimerWithTimeInterval:requestTimeoutInterval target:self selector:@selector(timeout:) userInfo:nil repeats:NO];	
	
	// Create and initiate the connection
	[connection cancel];
	[connection release];

	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	// Was there an error starting the connection?
	if (!connection) {
		[timer invalidate];
		[xmlData release], xmlData = nil;
		
		if (delegate && [delegate respondsToSelector:@selector(requestCompleted:)])
			[delegate requestCompleted:@"Unable to create the connection."];	
	}
}

#pragma mark -
#pragma mark Connection Delegates


// Delegate to assemble data returned from the connection
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[xmlData appendData:data];
}

// Delegate to handle the completion of the request
- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
	[timer invalidate];
	if (delegate && [delegate respondsToSelector:@selector(requestCompleted:)]) 
		[delegate requestCompleted:[self status]];	
}

// Delegate to catch connection errors
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
	[timer invalidate];
	[xmlData release], xmlData = nil;
	
	// Notify delegate of the error
	if (delegate && [delegate respondsToSelector:@selector(requestCompleted:)])
		[delegate requestCompleted:[NSString stringWithFormat:@"Connection Error: %@", [error localizedDescription]]];	
}

// Delegate to catch timeout errors
- (void)timeout:(NSTimer*)theTimer
{
	[connection cancel];
	if (delegate && [delegate respondsToSelector:@selector(requestCompleted:)])
		[delegate requestCompleted:@"Timeout Error"];	
}


#pragma mark -
#pragma mark Parser Delegates


// Delegate to examine each XML element as it is encountered
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{	
	if ([elementName isEqual:tagName]) {	
		[elements addObject:[attributeDict mutableCopy]];
	}	
}


@end