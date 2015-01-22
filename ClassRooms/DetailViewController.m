//
//  DetailViewController.m
//  ClassRooms
//
//  Created by Stephan Hoogland on 21/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailBeacon:(ESTBeacon *)detailBeacon classRoom:(NSString *)roomName {
    if (_detailBeacon != detailBeacon) {
        _detailBeacon = detailBeacon;
        if(_roomName != roomName){
            _roomName = roomName;
        }
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailBeacon) {
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"Major: %@ Minor: %@ Room: %@", [self.detailBeacon major], [self.detailBeacon minor], self.roomName];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


@end
