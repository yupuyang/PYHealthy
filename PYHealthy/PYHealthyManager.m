//
//  PYHealthyManager.m
//  PYHealthy
//
//  Created by PodiMac on 17/3/6.
//  Copyright © 2017年 于浦洋. All rights reserved.
//

#import "PYHealthyManager.h"
#import <HealthKit/HealthKit.h>

#ifdef DEBUG
#define PYLog(fmt,...) NSLog((@"\n\n[行号]%d\n" "[函数名]%s\n" "[日志]" fmt"\n"),__LINE__,__FUNCTION__,##__VA_ARGS__);
#else
#define PYLog(fmt,...);
#endif

@interface PYHealthyManager()
@property (nonatomic,strong) HKHealthStore *healthStore;
@end
@implementation PYHealthyManager
static PYHealthyManager *_instance;

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[super allocWithZone:zone];
    });
    return _instance;
}
+(PYHealthyManager*)sharedHealthyManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[[self alloc] init];
        _instance.healthStore=[[HKHealthStore alloc]init];
    });
    return _instance;
}
-(PYHealthyManager*)copyWithZone:(NSZone *)zone
{
    return _instance;
}

-(BOOL)isHealthyAuthority
{
    return [HKHealthStore isHealthDataAvailable];
}

- (void)setHealthyAuthority:(void (^)(BOOL success, NSError * _Nullable error))completion
{
    //设置需要获取的权限 这里仅设置了步数
    HKObjectType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *healthSet = [NSSet setWithObjects:stepType, nil];
    //从健康应用中获取权限
    [_instance.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error)
    {
        if (completion)
        {
            completion(success,error);
        }
    }];
}
- (void)getTodayWalkingStepData
{
    //查询采样信息
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //NSSortDescriptor来告诉healthStore怎么样将结果排序
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    //获取当前时间
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calender components:unitFlags fromDate:now];
    int hour = (int)[dateComponent hour];
    int minute = (int)[dateComponent minute];
    int second = (int)[dateComponent second];

    NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:[now timeIntervalSince1970]-(hour*3600 + minute * 60 + second)];
    
    NSDate *nowDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second) ];
    //时间结果与想象中不同是因为它显示的是0区
    PYLog(@"今天%@",nowDay);
    NSDate *nextDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second)  + 86400];
    PYLog(@"明天%@",nextDay);
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:nowDay endDate:nextDay options:(HKQueryOptionNone)];
    
    /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个HKSample类所以对应的查询类是HKSampleQuery。下面的limit参数传1表示查询最近一条数据，查询多条数据只要设置limit的参数值就可以了*/
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc]initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        //设置一个int型变量来作为步数统计
        //        NSLog(@"%u",results.count);
        int allStepCount = 0;
        for (int i = 0; i < results.count; i ++) {
            //把结果转换为字符串类型
            HKQuantitySample *result = results[i];
            HKQuantity *quantity = result.quantity;
            NSMutableString *stepCount = (NSMutableString *)quantity;
            NSString *stepStr =[ NSString stringWithFormat:@"%@",stepCount];
            //获取51 count此类字符串前面的数字
            NSString *str = [stepStr componentsSeparatedByString:@" "][0];
            int stepNum = [str intValue];
            PYLog(@"%d    %d",i,stepNum);
            //把一天中所有时间段中的步数加到一起
            allStepCount = allStepCount + stepNum;
        }
        
        //查询要放在多线程中进行，如果要对UI进行刷新，要回到主线程
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            PYLog(@"%@",[NSString stringWithFormat:@"%d",allStepCount]);
        }];
    }];
    //执行查询
    [self.healthStore executeQuery:sampleQuery];
}
@end
