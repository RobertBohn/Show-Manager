//
//  CygnusServices.h
//
//  Created by Robert Bohn on 6/24/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CygnusServices : NSObject <NSXMLParserDelegate> {
	id delegate;
	NSMutableData *xmlData;
	NSString *host;
	float connectionTimeoutInterval;
	float requestTimeoutInterval;
	NSURLConnection *connection;
	NSString *tagName;
	NSMutableArray *elements;
	NSTimer * timer;
}
+ (CygnusServices *)sharedCygnusServices;
- (void)requestService:(NSString *)requestString delegate:(id)delegate;
- (NSMutableArray *)getElements:(NSString *)tag;
@end

@protocol CygnusServicesDelegate
@optional
- (void)requestCompleted:(NSString *)error;
@end
