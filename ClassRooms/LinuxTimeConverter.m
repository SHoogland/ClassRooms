//
//  LinuxTimeConverter.m
//  ClassRooms
//
//  Created by Stephan Hoogland on 22/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import "LinuxTimeConverter.h"

@implementation LinuxTimeConverter

- (NSDate*) TimestammpToDate:(NSString*)timestamp
{
    NSTimeInterval interval = (NSTimeInterval)timestamp.doubleValue;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval / 1000];
    
    return date;
}

- (NSString*) DateToString:(NSDate*)date format:(NSString*)format
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    dateformatter.dateFormat = format;
    
    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
    [dateformatter setTimeZone:timezone];
    NSString *time = [dateformatter stringFromDate:date];
    
    return time;
}


@end
