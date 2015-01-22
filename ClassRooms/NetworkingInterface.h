//
//  NetworkingInterface.h
//  ClassRooms
//
//  Created by Stephan Hoogland on 21/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeacon.h"

@interface NetworkingInterface : NSObject

- (void)requestBeaconInfo:(void (^)(NSArray *))completion;
- (void)requestTimeTable:(NSString*)roomName completion:(void (^)(NSArray *))timeTable;

@end
