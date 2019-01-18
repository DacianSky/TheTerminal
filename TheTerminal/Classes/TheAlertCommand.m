//
//  TheAlertCommand.m
//  TheTerminal
//
//  Created by TheMe on 2017/5/26.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheAlertCommand.h"
#import <UIKit/UIKit.h>

@implementation TheAlertCommand

+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"alert"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    NSString *title = self.params[@"title"];
    NSString *msg = self.params[@"msg"];
    
    BOOL alertFlag = YES;
    if (self.params[@"mode"] && ![self.params[@"mode"] boolValue]) {
        alertFlag = NO;
    }
    
    if (self.params[@"type"]) {
        if ([self.params[@"type"] isEqualToString:@"xycode"]) {
            title = @"推送ID";
            msg = @"这是推送ID:XYZ123456";
        }
    }
    
    if (alertFlag) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
    }else{
        NSLog(@"%@",msg);
    }
}

@end
