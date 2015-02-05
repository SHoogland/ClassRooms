//
//  MasterViewController.m
//  ClassRooms
//
//  Created by Stephan Hoogland on 21/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import "MasterViewController.h"
#import "NetworkingInterface.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <ESTBeaconManager.h>
#import "MasterViewCell.h"
#import "ScheduleTableViewController.h"

@interface MasterViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconArray;
@property (nonatomic, assign) BOOL beaconInfoRequested;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (strong, nonatomic) NSArray *beaconInfo;
@property (copy, nonatomic) NSString *roomName;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBeaconInfoRequested:NO];
    
    // request  alle beaconInformatie van de api
    NetworkingInterface *networkInterface = [[NetworkingInterface alloc]init];
    [networkInterface requestBeaconInfo:^(NSArray * info) {
        self.beaconInfo = info;
        [self setBeaconInfoRequested:YES];
    }];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"iBeaconRegion"];
    
    [self.beaconManager startMonitoringForRegion:self.region];
    [self.beaconManager startRangingBeaconsInRegion:self.region];
    [self.beaconManager requestAlwaysAuthorization];
    
    self.region.notifyOnEntry = YES;
    
    self.detailViewController = (ScheduleTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // set de target controller (ScheduleTableViewController) with the necesary information
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ESTBeacon *object = self.beaconArray[indexPath.row];
        NSString *roomName = @"";
        NSString *image = @"";
        // iterate through the beacons and find the linked classroom
        for (int i = 0;i<[self.beaconInfo count];i++) {
            NSDictionary *Dictionary= [self.beaconInfo objectAtIndex:i];
            
            NSString *major = [NSString stringWithFormat:@"%@", object.major];
            NSString *minor = [NSString stringWithFormat:@"%@", object.minor];
            NSString *dicMajor = [NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"Major"]];
            NSString *dicMinor = [NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"Minor"]];
            
            if ([dicMajor isEqualToString:major] && [dicMinor isEqualToString:minor]) {
                roomName = [Dictionary objectForKey:@"ClassRoom"];
                image = [Dictionary objectForKey:@"ImageUrl"];
            }
        }
        self.selectedIndexPath = indexPath;
        ScheduleTableViewController *controller = (ScheduleTableViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailBeacon:object classRoom:roomName imageString:image];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:NSLocalizedString(@"Local classrooms: %lu", nil), (unsigned long)[self.beaconArray count]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.beaconArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MasterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    ESTBeacon *beacon = [self.beaconArray objectAtIndex:indexPath.row];
    
    if([indexPath isEqual:self.selectedIndexPath]){
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    if (cell.textLabel.text.length == 0)
        cell.hidden = YES;
    
    if (self.beaconInfoRequested == YES) {
        
        // iterate through the beacons and find the linked classroom
        for (int i = 0;i<[self.beaconInfo count];i++) {
            NSDictionary *Dictionary= [self.beaconInfo objectAtIndex:i];
            
            NSString *major = [NSString stringWithFormat:@"%@", beacon.major];
            NSString *minor = [NSString stringWithFormat:@"%@", beacon.minor];
            NSString *dicMajor = [NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"Major"]];
            NSString *dicMinor = [NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"Minor"]];
            
            if ([dicMajor isEqualToString:major] && [dicMinor isEqualToString:minor]) {
                cell.beaconText.text = [NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"ClassRoom"]];
                cell.hidden = NO;
            }
        }
    }
    cell.beaconTextDetail.text = [NSString stringWithFormat:NSLocalizedString(@"Distance: ~%.2f meter", nil), [beacon.distance floatValue]];
    cell.beaconImage.image = [UIImage imageNamed:@"beacon"];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - BeaconManager

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region {
    
    NSLog(@"entering region");
    
    if (self.beaconArray.count > 0) {
        ESTBeacon* closestBeacon = [self.beaconArray objectAtIndex:0];
        NSLog(@"closestprox %d", closestBeacon.proximity);
        
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:0];
        NSString *room = cell.textLabel.text;
        NSLog(@"roooom %@", room);
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"You entered class room %@", nil), room];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertBody = NSLocalizedString(@"You entered a class room", nil);
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    self.beaconArray = beacons;
    [self.tableView reloadData];
}

- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Monitorfailed");
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Rangefailed");
}

@end
