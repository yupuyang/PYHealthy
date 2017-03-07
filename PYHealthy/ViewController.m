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
           [[PYHealthyManager sharedHealthyManager] getTodayWalkingStepData:^(HKSampleQuery *query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error, int allStepCount) {
               NSLog(@"今天总步数  %d",allStepCount);
               
           }];
       }
   }];
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
