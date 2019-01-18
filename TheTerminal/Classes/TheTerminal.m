//
//  TheTerminal.m
//  TheTerminal
//
//  Created by TheMe on 2017/5/8.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheTerminal.h"
#import "NSString+Terminal.h"

NSString *const kTheMeScheme = @"thou";

void __executeCommand(NSString *cmd)
{
    if (![cmd supportScheme:kTheMeScheme]) {
        cmd = nsstrformatcat(@"%@://%@", kTheMeScheme,cmd);
    }
    TheLog(@"command: %@",cmd);
    if ([cmd__ couldParse:cmd] ) {
        [cmd__ parse:cmd];
    }
}

#define kCmdHistoryLimitCount 15

@interface TheTerminal()
{
    TheCommand *_thecmd;
}

@property (nonatomic,strong) NSMutableArray *cmdHistory;
@property (nonatomic,strong) NSMutableArray *allCommands;

@end

@implementation TheTerminal

static TheTerminal *_instance;
+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    
    return _instance;
}

+ (instancetype)sharedTerminal
{
    if (_instance == nil) {
        _instance = [[TheTerminal alloc] init];
    }
    return _instance;
}

#pragma mark - terminal command
+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"terminal"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    if ([self havaParam:@"last"]) {
        NSInteger last = [self.params[@"last"] integerValue];
        if (last<=0 || last > self.cmdHistory.count) {
            __executeCommand(@"alert?msg=超出历史记录范围");
            return;
        }
        NSInteger count = self.cmdHistory.count - last;
        if (last>=0) {
            __executeCommand(self.cmdHistory[count]);
        }
    }
}

#pragma mark - execute
- (BOOL)couldParse:(NSString *)commandString
{
    if (![commandString supportScheme:kTheMeScheme] && ![commandString isTerminalUrl]) {
        return NO;
    }
    commandString = [[self class] specialHandle:commandString];
    _thecmd = [[self class] findCommand:commandString];
    return (BOOL)_thecmd;
}

- (void)parse:(NSString *)commandString
{
    if (!_thecmd) {
        return;
    }
    [_thecmd execute];
    [self putHistory:_thecmd.command];
    _thecmd = nil;
}

#pragma mark - tool
+ (TheCommand *)findCommand:(NSString *)commandString
{
    TheCommand *cmd = nil;
    Class cls = nil;
    NSArray<NSString *> *commmandClzs = [TheTerminal allCommands];
    for (NSString *commandClzStr in commmandClzs) {
        id commandClass = NSClassFromString(commandClzStr);
        if ([commandClass couldParse:commandString]) {
            cls = commandClass;
            break;
        }
    }
    if (cls) {
        cmd = [[cls alloc] initWithCommand:commandString];
    }
    return cmd;
}

+ (NSString *)specialHandle:(NSString *)commandString
{
    if ([commandString isTerminalUrl]) {
        // 原生scheme配合路由命令使用
        commandString = [NSString stringWithFormat:@"thou://route?url=@[%@]",commandString];
    }
    
    // 去除scheme
    commandString = [commandString stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:@""];
    
    // 参数编码使用@[]形式对指定参数编码,如 thou://route?url=@[http://www.baidu.com]
    commandString = [commandString paramUrlEncoded];
    return commandString;
}

+ (NSArray<NSString *> *)allCommands
{
    return cmd__.allCommands;
}

- (void)putHistory:(NSString *)history
{
    if ([NSString isEmptyOrNull:history]) {
        return;
    }
    for (NSString *cmd in self.cmdHistory) {
        if ([cmd isEqualToString:history]) {
            [self.cmdHistory removeObject:cmd];
            break;
        }
    }
    if (self.cmdHistory.count >= kCmdHistoryLimitCount) {
        [self.cmdHistory removeObjectAtIndex:0];
    }
    [self.cmdHistory addObject:history];
}

#pragma makr - lazy load
- (NSMutableArray *)allCommands
{
    if (!_allCommands) {
        _allCommands = [@[@"TheTerminal",@"TheRouteCommand",@"TheRevealCommand",@"TheLogCommand",@"TheAlertCommand",@"TheNotifyCommand",@"TheExitCommand"] mutableCopy];
        NSArray *customCommands = themeTerminalJson(@"command")[@"AllCommand"];
        if ([customCommands isKindOfClass:[NSArray class]]) {
            [_allCommands addObjectsFromArray:customCommands];
        }
    }
    return _allCommands;
}

- (NSMutableArray *)cmdHistory
{
    if (!_cmdHistory) {
        _cmdHistory = [[NSMutableArray alloc] init];
    }
    return _cmdHistory;
}

@end
