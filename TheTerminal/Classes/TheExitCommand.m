//
//  TheExitCommand.m
//  TheTerminal
//
//  Created by TheMe on 2017/5/26.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheExitCommand.h"

@implementation TheExitCommand

+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"exit"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    exit(0);
}

@end
