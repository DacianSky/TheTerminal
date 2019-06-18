//
//  UserCommand.m
//  TheTerminalDemo
//
//  Created by TheMe on 2017/7/7.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "UserCommand.h"

@implementation UserCommand

+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"user"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    BOOL vipFlag = YES;
    if (self.params[@"vip"] && ![self.params[@"vip"] boolValue]) {
        vipFlag = NO;
    }
    if (vipFlag) {
    }
    // TODO : set vip flag
}

@end
