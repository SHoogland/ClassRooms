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


//@property (nonatomic, copy)     void (^completion)(NSString *);
@property (strong, nonatomic) NSMutableArray *responseClassRooms;

@end

@implementation NetworkingInterface

- (void)requestClassRoom:(ESTBeacon*)beacon completion:(void (^)(NSString *))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://beacon-app-proxy.azurewebsites.net/beacons"]];
    
    NSString *major = [NSString stringWithFormat:@"%@", beacon.major];
    NSString *minor = [NSString stringWithFormat:@"%@", beacon.minor];
    
    self.responseClassRooms = [[NSMutableArray alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.responseClassRooms addObjectsFromArray:responseObject];
        NSLog(@"%@", responseObject);
        NSLog(@"requested beacons");
        for (int i = 0; i<[self.responseClassRooms count]; i++) {
            NSDictionary *Dictionary= [self.responseClassRooms objectAtIndex:i];
            NSString *dicMajor = [NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"Major"]];
            NSString *dicMinor = [NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"Minor"]];
            
            if ([dicMajor isEqualToString:major] && [dicMinor isEqualToString:minor])
            {
                completion([NSString stringWithFormat:@"%@", [Dictionary objectForKey:@"ClassRoom"]]);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"ERROR");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. The messages couldn't be loaded" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Retry",nil];
        [alert show];
    }];

    [operation start];
}

@end
