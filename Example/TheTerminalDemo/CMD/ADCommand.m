//
//  ADCommand.m
//  TheTerminalDemo
//
//  Created by TheMe on 2018/10/17.
//  Copyright © 2018 sdqvsqiu@gmail.com. All rights reserved.
//

#import "ADCommand.h"

@implementation ADCommand

+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"ad"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    BOOL quickstart = NO;
    if ((self.params[@"qs"] || self.params[@"quickstart"]) && ([self.params[@"qs"] boolValue] || [self.params[@"quickstart"] boolValue])) {
        quickstart = YES;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(quickstart) forKey:@"debug_quick_start"];
}

@end
