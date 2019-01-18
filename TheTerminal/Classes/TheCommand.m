//
//  TheCommand.m
//  TheTerminal
//
//  Created by TheMe on 2017/5/8.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheCommand.h"
#import "NSString+Terminal.h"
#import "TheTerminalView.h"

@interface TheCommand()

@property (nonatomic,strong,readwrite) NSString *command;
@property (nonatomic,strong,readwrite) NSString *body;
@property (nonatomic,strong,readwrite) NSString *urlArg;
@property (nonatomic,strong,readwrite) NSDictionary *params;

@end

@implementation TheCommand

- (instancetype)initWithCommand:(NSString *)command
{
    self = [super init];
    if (self) {
        _command = command;
        _params = [command getAllParameterDict];
        _body = [command getUrlBody];
        _urlArg = [command getUrlArg];
        if (!_urlArg) {
            _urlArg = @"";
        }
    }
    return self;
}

+ (BOOL)couldParse:(NSString *)commandString
{
    return NO;
}

- (void)execute{}

- (BOOL)havaParam:(NSString *)param
{
    if ([self.params.allKeys containsObject:param]) {
        return YES;
    }
    return NO;
}

- (id)valueWithParam:(NSString *)param
{
    return self.params[param];
}

- (void)showTerminalView:(id)parameter
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSInteger tag = [self terminalTag];
    
    UIView *view = [window viewWithTag:tag];
    view.hidden = NO;
    if (!view) {
        view = [self buildTerminalView:parameter];
    }
    [window addSubview:view];
}

- (void)hideTerminalView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSInteger tag = [self terminalTag];
    
    UIView *view = [window viewWithTag:tag];
    [view removeFromSuperview];
}

- (UIView *)buildTerminalView:(id)parameter
{
    TheTerminalView *view = [[TheTerminalView alloc] initWithFrame:[self suggestFrame]];
    view.tag = [self terminalTag];
    return view;
}

- (NSInteger)terminalTag
{
    return kTheTerminalViewTag;
}

- (CGRect)suggestFrame
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize size = window.frame.size;
    
    CGFloat width = size.width * 0.8;
    CGFloat height = size.height * 0.6;
    CGFloat x = size.width * 0.1;
    CGFloat y = size.height * 0.2;
    
    return CGRectMake(x,y,width,height);
}

@end
