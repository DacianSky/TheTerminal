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
    [_theTerminal consume:cmd];
}

void __executeCommandOnly(NSString *cmd)
{
    __executeCommand(nsstrformatcat(@"thou://terminal?cmd=@[%@]",cmd));
}

void __executeAlert(NSString *msg)
{
    __executeCommandOnly(nsstrformatcat(@"alert?msg=%@",msg));
}

#define kCmdHistoryLimitCount 15

@interface TheTerminal()

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
        NSInteger count = self.cmdHistory.count - [self.params[@"last"] integerValue];
        if (count<0 || count >= self.cmdHistory.count) {
            __executeAlert(@"超出历史记录范围");
            return;
        }
        __executeCommand(self.cmdHistory[count]);
    }else if ([self havaParam:@"cmd"]) {
        // not record history parse cmd like @"thou://terminal?cmd=@[alert?title=ThisTitle&msg=ThisMsg]"
        NSString *cmd = [self.params[@"cmd"] urldecode];
        __executeCommand(cmd);
        [self.cmdHistory removeLastObject];
    }
}

#pragma mark - execute
- (void)consume:(NSString *)cmd
{
    TheCommand *thecmd = [self parse:cmd];
    if (!thecmd) {
        return;
    }
    [thecmd execute];
    [self putHistory:thecmd.command];
}

- (TheCommand *)parse:(NSString *)cmd
{
    if (![cmd supportScheme:kTheMeScheme] && ![cmd isAppUrl]) {
        return nil;
    }
    return [[self class] findCommand:[[self class] specialHandle:cmd]];
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
    if ([commandString isAppUrl]) {
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
    return _theTerminal.allCommands;
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
