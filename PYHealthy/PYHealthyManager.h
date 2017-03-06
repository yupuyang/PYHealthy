//
//  PYHealthyManager.h
//  PYHealthy
//
//  Created by PodiMac on 17/3/6.
//  Copyright © 2017年 于浦洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
@interface PYHealthyManager : NSObject

//单例
+(PYHealthyManager*)sharedHealthyManager;
//健康权限
- (BOOL)isHealthyAuthority;
//跳到设置获取步行授权界面
- (void)setHealthyAuthority:(void (^ _Nullable )(BOOL success, NSError * _Nullable error))completion;
//获取当日步行信息
- (void)getTodayWalkingStepData;
@end
