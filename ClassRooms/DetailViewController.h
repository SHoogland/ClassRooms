//
//  DetailViewController.h
//  ClassRooms
//
//  Created by Stephan Hoogland on 21/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) ESTBeacon *detailBeacon;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (void)setDetailBeacon:(ESTBeacon *)detailBeacon classRoom:(NSString *)roomName;

@end

