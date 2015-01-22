//
//  ScheduleTableViewController.h
//  ClassRooms
//
//  Created by Stephan Hoogland on 22/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"

@interface ScheduleTableViewController : UITableViewController

@property (nonatomic, strong) ESTBeacon *beacon;
@property (copy, nonatomic) NSString *roomName;

- (void)setDetailBeacon:(ESTBeacon *)detailBeacon classRoom:(NSString *)roomName;

@end
