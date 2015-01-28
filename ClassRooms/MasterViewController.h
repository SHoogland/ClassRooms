//
//  MasterViewController.h
//  ClassRooms
//
//  Created by Stephan Hoogland on 21/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScheduleTableViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) ScheduleTableViewController *detailViewController;

@end

