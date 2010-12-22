//
//  CommonFunctions.m
//  Show Manager
//
//  Created by Robert Bohn on 7/9/10.
//  Copyright 2010 Barzutti, Co. All rights reserved.
//

#import "CommonFunctions.h"

int instr(NSString *target, NSString *substring, int offset) {
	NSRange searchRange;	
	searchRange.location = offset;
	searchRange.length = [target length] - offset;	
	NSRange foundRange = [target rangeOfString:substring options:0  range:searchRange];
	if(foundRange.length > 0) 
		return foundRange.location;
	else
		return -1;
}

NSString *substr(NSString *string, int offset, int length) {
	return [string substringWithRange: NSMakeRange(offset, length)];
}

NSString *trim(NSString *string) {
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];	
}

NSDate *getDate(NSString *date, NSString *time) {
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease]; 
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
	return [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@", substr(date,0,10), substr(time,11,5)]];  
}

NSString *description_1(NSString *desc) {
	int idx = instr(desc, @"-", 0);
	if (idx > 0) 
		return trim(substr(desc, 0, idx));
	else 
		return trim(desc);	
}

NSString *description_2(NSString *desc) {
	int idx = instr(desc, @"-", 0);
	if (idx > 0) 
		return trim(substr(desc, idx+1, [desc length] - idx - 1));
	else 
		return nil;	
}
