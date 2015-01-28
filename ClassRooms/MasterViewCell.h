//
//  MasterViewCell.h
//  ClassRooms
//
//  Created by Stephan Hoogland on 27/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *beaconImage;
@property (weak, nonatomic) IBOutlet UILabel *beaconText;
@property (weak, nonatomic) IBOutlet UILabel *beaconTextDetail;

@end
