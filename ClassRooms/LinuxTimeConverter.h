//
//  LinuxTimeConverter.h
//  ClassRooms
//
//  Created by Stephan Hoogland on 22/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinuxTimeConverter : NSObject

- (NSDate*) TimestammpToDate:(NSString*)timestamp;
- (NSString*) DateToString:(NSDate*)date format:(NSString*)format;

@end
