//
//  NetworkingInterface.m
//  ClassRooms
//
//  Created by Stephan Hoogland on 21/01/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import "NetworkingInterface.h"
#import "AFNetworking.h"
#import "MasterViewController.h"

@interface NetworkingInterface()

@property (nonatomic, copy)     void (^completion)(NSString *);
@property (nonatomic, copy)     void (^timeTable)(NSArray *);

@end

@implementation NetworkingInterface

// ophalen van alle gegevens betreffende de beacons (koppeling van beacons aan lokalen)
- (void)requestBeaconInfo:(void (^)(NSArray *))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://beacon-app-proxy.azurewebsites.net/beacons"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(responseObject);
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geen Internetverbinding" message:@"Controleer of je bent verbonden met het internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert setTag:2];
        [alert show];
    }];
    
    [operation start];
}

// ophalen van het rooster voor een betreffend lokaal via onze eigen webserver
// de webserver doet 2 calls naar de API van timetables en returnt een custom JSON voor het betreffende lokaal.
- (void)requestTimeTable:(NSString*)roomName completion:(void (^)(NSArray *))timeTable {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://beacon-app-proxy.azurewebsites.net/classroomSchedule/%@", roomName]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        timeTable([responseObject objectForKey:@"activities"]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"ERROR");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geen Internetverbinding" message:@"Controleer of je bent verbonden met het internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert setTag:1];
        [alert show];
    }];
    
    [operation start];
    
}

@end
