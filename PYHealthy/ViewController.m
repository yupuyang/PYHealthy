//
//  ViewController.m
//  PYHealthy
//
//  Created by PodiMac on 17/3/6.
//  Copyright © 2017年 于浦洋. All rights reserved.
//

#import "ViewController.h"
#import "PYHealthyManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   [[PYHealthyManager sharedHealthyManager] setHealthyAuthority:^(BOOL success, NSError * _Nullable error) {
       if (success)
       {
           [[PYHealthyManager sharedHealthyManager] getTodayWalkingStepData];
       }
   }];
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
