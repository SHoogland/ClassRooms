//
//  MasterViewController.m
//  ClassRooms
//
//  Created by Stephan Hoogland on 21/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ESTBeaconManager.h"
#import "NetworkingInterface.h"

@interface MasterViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconArray;

@property (strong, nonatomic) NSMutableArray *classRooms;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"ClassRoomRegion"];
    
    [self.beaconManager startMonitoringForRegion:self.region];
    [self.beaconManager startRangingBeaconsInRegion:self.region];
    [self.beaconManager requestAlwaysAuthorization];
    
    self.region.notifyOnEntry = YES;
    self.region.notifyOnExit = YES;


    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.classRooms[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.classRooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    ESTBeacon *beacon = [self.beaconArray objectAtIndex:indexPath.row];
    
    if (cell.textLabel.text.length == 0)
    {
        NetworkingInterface *networkInterface = [[NetworkingInterface alloc]init];
        [networkInterface requestClassRoom:beacon completion:^(NSString *classroom) {
            NSLog(@"Requested and complete %@", classroom);
            cell.textLabel.text = classroom;
        }];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - BeaconManager

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    
    NSLog(@"entering region");
    
    if (self.beaconArray.count > 0) {
        
        ESTBeacon* closestBeacon = [self.beaconArray objectAtIndex:0];
        NSLog(@"closestprox %d", closestBeacon.proximity);
        
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:0];
        NSString *room = cell.textLabel.text;
        NSLog(@"roooom %@", room);
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.alertBody = @"It workssss";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertBody = @"You entered the room";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    
}

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconArray = beacons;
    [self.tableView reloadData];
}



- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Monitorfailed");
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Rangefailed");
}

-(void)beaconManager:(ESTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(ESTBeaconRegion *)region
{
    NSLog(@"did determine state");
}

@end
