//
//  TheTerminalConst.h
//  TheTerminal
//
//  Created by TheMe on 2019/1/4.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define _theTerminal [TheTerminal sharedTerminal]

// 执行命令
void __executeCommand(NSString *cmd);

// 开启后才会输出日志，然后根据命令来确定日志输出重定向位置
void enableTheLog(BOOL flag);
void TheLog(NSString *format, ...);

NS_ASSUME_NONNULL_END
