//
//  ScheduleTableViewCell.h
//  ClassRooms
//
//  Created by Stephan Hoogland on 27/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *detailName;
@property (weak, nonatomic) IBOutlet UILabel *detailTime;
@property (weak, nonatomic) IBOutlet UILabel *detailStudents;

@end
