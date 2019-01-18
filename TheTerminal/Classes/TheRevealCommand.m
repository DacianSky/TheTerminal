//
//  TheRevealCommand.m
//  TheTerminal
//
//  Created by TheMe on 2017/6/7.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheRevealCommand.h"

@implementation TheRevealCommand

#ifdef DEBUG
+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"reveal"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id debugClass = NSClassFromString(@"UIDebuggingInformationOverlay");
    [debugClass performSelector:NSSelectorFromString(@"prepareDebuggingOverlay")];
    
    if ([self.params[@"show"] boolValue]) {
        id obj = [debugClass performSelector:NSSelectorFromString(@"overlay")];
        [obj performSelector:NSSelectorFromString(@"toggleVisibility")];
    }
#pragma clang diagnostic pop
}
#endif

@end
