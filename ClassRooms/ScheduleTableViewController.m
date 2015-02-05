//
//  ScheduleTableViewController.m
//  ClassRooms
//
//  Created by Stephan Hoogland on 22/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "NetworkingInterface.h"
#import "LinuxTimeConverter.h"
#import "ScheduleTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface ScheduleTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;

@property (strong, nonatomic) UILabel *loadingLabel;
@property (strong, nonatomic) UIActivityIndicatorView* loadingSpinner;

@end

@implementation ScheduleTableViewController

- (void)setDetailBeacon:(ESTBeacon *)detailBeacon classRoom:(NSString *)roomName imageString:(NSString *)image {
    if (_beacon != detailBeacon) {
        _beacon = detailBeacon;
        if(_roomName != roomName){
            _roomName = roomName;
            if(_image != image){
                _image = image;
            }
        }
        // Update the view.
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Viewloaded");
    self.title = NSLocalizedString(@"Classroom info", nil);
    
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,
                                                                  self.tableView.bounds.size.height / 2 - 10,
                                                                  200,
                                                                  20)];
    self.loadingLabel.text = NSLocalizedString(@"Downloading schedule", nil);
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
//    self.loadingLabel.center = self.tableView.center;
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.frame = CGRectMake(50 + 200,
                                           self.tableView.bounds.size.height / 2 - 10,
                                           20,
                                           20);
    [self.loadingSpinner startAnimating];
    [self.tableView addSubview: self.loadingSpinner];
    [self.tableView addSubview: self.loadingLabel];
    
    if (self.beacon != nil){
        [self.loadingLabel setHidden:NO];
        [self.loadingSpinner startAnimating];
    }
    else{
        [self.loadingLabel setHidden:YES];
        [self.loadingSpinner stopAnimating];
    }
    
    //ophalen van het rooster via HTTP interface
    NetworkingInterface *networkInterface = [[NetworkingInterface alloc]init];
    if (self.roomName != nil){
        [networkInterface requestTimeTable:self.roomName completion:^(NSArray *roomTimeTable) {
            
            self.sections = [NSMutableDictionary dictionary];
            
            //ittereren over alle activiteiten van het lokaal (deze week), en deze opsplitsen in dagen
            for(int i = 0; i < [roomTimeTable count]; i++) {
                NSDictionary *dictionary= [roomTimeTable objectAtIndex:i];
                NSDate *dateForActivity = [self beginningOfCurrentDay:[[[LinuxTimeConverter alloc] init] TimestammpToDate:[dictionary objectForKey:@"startDate"]]];
                
                NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateForActivity];
                if (eventsOnThisDay == nil) {
                    eventsOnThisDay = [NSMutableArray array];
                    
                    [self.sections setObject:eventsOnThisDay forKey:dateForActivity];
                }
                [eventsOnThisDay addObject:dictionary];
            }
            self.sortedDays = [[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)];
            
            [self.tableView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // aantal sections +1, vanwege de eerste section die gebruik wordt voor een plaatje
    return [self.sections count] +1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section != 0) {
        NSDate *dateForRow = [self.sortedDays objectAtIndex:section - 1];
        NSArray *activitiesOnThisDay = [self.sections objectForKey:dateForRow];
        return [activitiesOnThisDay count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
    if(indexPath.section != 0) {
        [self.loadingLabel setHidden:YES];
        [self.loadingSpinner stopAnimating];
        
        NSDate *date = [self.sortedDays objectAtIndex:indexPath.section - 1];
        NSArray *activitiesForDate= [self.sections objectForKey:date];
        NSDictionary *rowActivity = [activitiesForDate objectAtIndex:indexPath.row];
        
        cell.detailName.text = [rowActivity objectForKey:@"name"];
        
        //API start & einddatum converteren naar leesbare tekst voor de user
        NSString *startTime = [NSString stringWithFormat:@"%@", [[[LinuxTimeConverter alloc] init] DateToString:[[[LinuxTimeConverter alloc] init] TimestammpToDate:[rowActivity objectForKey:@"startDate"]] format:@"HH:mm" ]];
        NSString *endTime = [NSString stringWithFormat:@"%@", [[[LinuxTimeConverter alloc] init] DateToString:[[[LinuxTimeConverter alloc] init] TimestammpToDate:[rowActivity objectForKey:@"endDate"]] format:@"HH:mm" ]];
        
        cell.detailTime.text = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
        
        NSArray *studentSets = [rowActivity objectForKeyedSubscript:@"studentSets"];
        NSString *sets;
        
        for (int i = 0; i < studentSets.count; i++) {
            if (sets != nil)
                sets = [NSString stringWithFormat:@"%@, %@", sets, [studentSets objectAtIndex:i]];
            else
                sets = [studentSets objectAtIndex:i];
        }
        
        cell.detailStudents.text = sets;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // plaatje bovenaan de detailpagina
    if (section == 0) {
        NSLog(@"%@", self.image);
        
        UIImageView *imageView;
        UIImage *myImage = [UIImage imageNamed:@"school"];
        imageView= [[UIImageView alloc] initWithImage:myImage];
        if(self.image != nil){
            NSURL* url=[[NSURL alloc] initWithString:self.image];
            [imageView setImageWithURL:url];
        }
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *roomName = [[UILabel alloc] initWithFrame:CGRectMake(500, 20, imageView.bounds.size.width /2 , 30)];
        roomName.textColor = [UIColor whiteColor];
        roomName.textAlignment = NSTextAlignmentCenter;
        roomName.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:121.0f/255.0f blue:224.0f/255.0f alpha:1.0];
        
        if(self.beacon != nil){
            roomName.text = self.roomName;
        }
        else{
            roomName.text = NSLocalizedString(@"Choose a classroom", nil);
        }
        
        [imageView addSubview:roomName];
        
        return imageView;
    }
    else {
        NSDate *dateForSectionTitle= [self.sortedDays objectAtIndex:section -1];
        
        UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.tableView.bounds.size.width , 30)];
        sectionHeader.backgroundColor = [UIColor orangeColor];
        sectionTitle.textColor = [UIColor whiteColor];
        sectionTitle.text = [[[LinuxTimeConverter alloc]init] DateToString:dateForSectionTitle format:@"EEEE dd MMM yyyy"];
        
        [sectionHeader addSubview:sectionTitle];
        
        return sectionHeader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 200;
    else
        return 30;
}

// functie die het begin van een bepaalde dag terugstuurd
- (NSDate *)beginningOfCurrentDay:(NSDate *)inputDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inputDate];
    
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

@end
