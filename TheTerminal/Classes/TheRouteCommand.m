//
//  TheRouteCommand.m
//  TheTerminal
//
//  Created by TheMe on 2017/5/26.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheRouteCommand.h"
#import "NSString+Terminal.h"
#import "TheListView.h"

@class Intent;

@implementation TheRouteCommand

+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"route"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    if (self.params[@"url"]) {
        NSString *url = [self.params[@"url"] stringByDecodingURLFormat];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([UIViewController respondsToSelector:@selector(startViewController:)]) {
            Intent *intent = [NSClassFromString(@"Intent") performSelector:@selector(intentWithRouteName:) withObject:url];
            [UIViewController performSelector:@selector(startViewController:) withObject:intent];
#pragma clang diagnostic pop
        }else{
            Class vc = NSClassFromString(url);
            if ([vc isKindOfClass:[UIViewController class]]) {
                [[TheRouteCommand getAppCurrentNavigation] pushViewController:[vc new] animated:YES];
            }
        }
        
    }
}

+ (__kindof UINavigationController *)getAppCurrentNavigation
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarVC = (UITabBarController *)vc;
        nav = tabbarVC.selectedViewController;
    }else if ([vc isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController *)vc;
    }
    return nav;
}

@end
