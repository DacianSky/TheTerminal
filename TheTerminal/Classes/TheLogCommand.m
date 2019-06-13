//
//  TheLogCommand.m
//  TheTerminal
//
//  Created by TheMe on 2017/7/21.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheLogCommand.h"
#import "TheTextView.h"
#import "TheTerminal.h"
#import "NSString+Terminal.h"

#define kConfigLogRedirectMode @"config_log_redirect_mode"

static int originH1 = 0;
NSInteger theTerminalLogFlag = 0;

__attribute__((constructor)) void before_load()
{
    originH1 = dup(STDERR_FILENO);
    theTerminalLogFlag = [[[NSUserDefaults standardUserDefaults] objectForKey:kConfigLogRedirectMode] integerValue];;
    if (theTerminalLogFlag == 1) {
        [logcmd__ configRedirect];
    }
}

@interface TheLogCommand()<TheTextViewDelegate>

@property (nonatomic,strong) TheTextView *logTextView;
@property (nonatomic,strong) NSString *logPath;

@property (nonatomic,strong) NSFileHandle *outHandle;
@property (nonatomic,strong) NSFileHandle *errHandle;
@property (nonatomic,strong) NSFileHandle *writeHandle;

@end

@implementation TheLogCommand

static TheLogCommand *_instance;
+ (instancetype)sharedLog
{
    if (_instance == nil) {
        _instance = [[TheLogCommand alloc] init];
    }
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    
    return _instance;
}

+ (BOOL)couldParse:(NSString *)commandString
{
    if ([commandString hasPrefix:@"log"]) {
        return YES;
    }
    return NO;
}

- (void)execute
{
    if ([self havaParam:@"mode"]) {
        NSInteger logFlag = 1;
        if ( [self.params[@"mode"] isEqualToString:@"console"]) {
            logFlag = 0;
        }else if ( [self.params[@"mode"] isEqualToString:@"file"]) {
            logFlag = 1;
        }else if( [self.params[@"mode"] isEqualToString:@"view"]){
            logFlag = 2;
        }else if([self.params[@"mode"] integerValue] == 2){
            logFlag = 2;
        }else if ([self.params[@"mode"] integerValue] == 1) {
            logFlag = 1;
        }else if ([self.params[@"mode"] integerValue] == 0) {
            logFlag = 0;
        }
        
        [self saveLogFlag:logFlag];
        if(logFlag == 2){
            [self showTerminalView:nil];
            [self configRedirect];
        }else if (logFlag == 1) {
            [self hideTerminalView];
            [self configRedirect];
        }else{
            [self hideTerminalView];
            [self closeHandle];
        }
    }
}

- (void)saveLogFlag:(NSInteger)logFlag
{
    theTerminalLogFlag = logFlag;
    if (logFlag == 2) {
        return; // 输出到面板只是临时展示
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(logFlag) forKey:kConfigLogRedirectMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 重定向
- (void)configRedirect
{
    if (!self.writeHandle) {
        NSFileHandle *pipeWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.logPath];
        [pipeWriteHandle seekToEndOfFile];
        self.writeHandle = pipeWriteHandle;
    }
    
    if (!self.outHandle) {
        self.outHandle = [self redirectSTD:STDOUT_FILENO];
    }
    if (!self.errHandle) {
        self.errHandle = [self redirectSTD:STDERR_FILENO];
    }
}

- (void)closeHandle
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.outHandle closeFile];
    [self.errHandle closeFile];
    [self.writeHandle closeFile];
    
    _outHandle = nil;
    _errHandle = nil;
    _writeHandle = nil;
    _logTextView = nil;
    
    dup2(originH1, STDOUT_FILENO);
    dup2(originH1, STDERR_FILENO);
}

- (NSFileHandle *)redirectSTD:(int)fd{
    NSPipe * pipe = [NSPipe pipe] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logHandle:) name:NSFileHandleReadCompletionNotification object:pipeReadHandle] ;
    [pipeReadHandle readInBackgroundAndNotify];
    
    return pipeReadHandle;
}

- (void)logHandle:(NSNotification *)nf{
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (theTerminalLogFlag == 2) {
        // 重定向到log视图
        [self.logTextView inputText:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }else if (theTerminalLogFlag == 1){
        // 重定向到文件
        [self writeLogFile:data];
    }
    [[nf object] readInBackgroundAndNotify];
}

- (void)writeLogFile:(NSData *)data
{
    [self.writeHandle writeData:data];
}

#pragma mark - lazy load

- (TheTextView *)logTextView
{
    if (!_logTextView) {
        _logTextView = [[TheTextView alloc] initWithFrame:[self suggestFrame]];
        _logTextView.logDelegate = self;
        _logTextView.tag = [self terminalTag];
    }
    return _logTextView;
}

- (NSString *)logPath
{
    if (!_logPath) {
        _logPath = [[NSString alloc] init];
        
        NSString *documentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        documentpath = [NSString stringWithFormat:@"%@/debug",documentpath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fileName = [NSString stringWithFormat:@"%@.log",[NSDate date]];
        NSString *logFilePath = [documentpath stringByAppendingPathComponent:fileName];
        
        if (![fileManager fileExistsAtPath:documentpath]) {
            [fileManager createDirectoryAtPath:documentpath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        [fileManager createFileAtPath:logFilePath contents:nil attributes:nil];
        
        _logPath = logFilePath;
    }
    return _logPath;
}


#pragma mark - terminal view
- (UIView *)buildTerminalView:(id)parameter
{
    return self.logTextView;
}

- (NSInteger)terminalTag
{
    return kTheTextViewTag;
}

- (void)close
{
    [self closeHandle];
}

- (void)dealloc
{
    [self closeHandle];
}

@end


BOOL theTerminalCouldLog = NO;
void enableTheLog(BOOL flag)
{
    theTerminalCouldLog = flag;
}

BOOL printCheck()
{
#ifdef DEBUG
    BOOL printFlag = theTerminalCouldLog;
#else
    BOOL printFlag = theTerminalLogFlag>0 && theTerminalCouldLog;
#endif
    return printFlag;
}


NSString *theDefaultLogType = @"TheLog";
void setupDefaultLogType(NSString *type)
{
    if (!type) {
        return;
    }
    theDefaultLogType = type;
}

void TheLog(NSString *format, ...)
{
    va_list args;
    va_start (args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end (args);
    TheLogFormat(nil, TheLogLevelVerbose, log,nil);
}

void TheLogWarn(NSString *format, ...)
{
    va_list args;
    va_start (args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end (args);
    TheLogFormat(nil, TheLogLevelWarn, log,nil);
}

void TheLogError(NSString *format, ...)
{
    va_list args;
    va_start (args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end (args);
    TheLogFormat(nil, TheLogLevelError, log,nil);
}

void TheLogImportant(NSString *format, ...)
{
    va_list args;
    va_start (args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end (args);
    TheLogFormat(nil, TheLogLevelImportant, log,nil);
}

void TheLogTemp(NSString *format, ...)
{
    va_list args;
    va_start (args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end (args);
    TheLogFormat(nil, TheLogLevelTemp, log,nil);
}

void TheLogFormat(NSString * _Nullable type,int level,NSString *format, ...)
{
    if (level < 0) {
        return;
    }
    if (!printCheck()) {
        return;
    }
    if (!type) {
        type = theDefaultLogType;
    }
    va_list args;
    va_start (args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end (args);
    NSLog(@"%@::%d::%@",type,level,log);
}
