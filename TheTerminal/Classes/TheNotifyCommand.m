//
//  TheNotifyCommand.m
//  TheTerminal
//
//  Created by TheMe on 2017/5/27.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheNotifyCommand.h"
#import "NSString+Terminal.h"
#import <UIKit/UIKit.h>

@implementation TheNotifyCommand

+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"notify"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    
    localNoti.alertBody = self.params[@"msg"];
    
    NSString *type = self.params[@"t"];
    NSString *value = self.params[@"v"];
    
    if ([self havaParam:@"mode"] && [@"push" isEqualToString:self.params[@"mode"]]) {
        NSString *userInfoStr = [NSString stringWithFormat:@"{\"r\":\"0\",\"i\":\"128008096\",\"aps\":{\"badge\":\"5\",\"mutable-content\":\"1\",\"alert\":{\"subtitle\":\"胜利者是正义\",\"title\":\"胜利者是正义\",\"body\":\"南瓜电影精彩奉献\"},\"category\":\"南瓜电影精彩奉献\",\"sound\":\"default\"},\"m\":\"500031&&ALIYUN_25063857_500031&&ALIYUN_2eb3288a1e9948eb8e6d36d591afa736&&00&&@apns\",\"v\":\"%@\",\"t\":\"%@\"}",type,value];
        NSDictionary *userInfo =  [NSString dictionaryWithJsonString:userInfoStr];
        localNoti.userInfo = userInfo;
        localNoti.alertBody = userInfo[@"aps"][@"alert"][@"subtitle"];
        localNoti.alertTitle = userInfo[@"aps"][@"alert"][@"title"];
    }
    
    NSInteger delay = [self.params[@"delay"] integerValue];
    if (![self havaParam:@"deleay"]) {
        delay = 2;
    }
    localNoti.fireDate = [NSDate dateWithTimeIntervalSinceNow:delay];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    
}

@end
