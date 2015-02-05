//
//  InfoViewController.m
//  ClassRooms
//
//  Created by Stephan Hoogland on 05/02/15.
//  Copyright (c) 2015 SHoogland. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *str = NSLocalizedString(@"Info text", nil);
    UITextView *_textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 200)];
    _textView.text = str;
    [self.view addSubview:_textView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
