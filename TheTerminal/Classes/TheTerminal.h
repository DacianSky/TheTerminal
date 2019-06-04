//
//  TheTerminal.h
//  TheTerminal
//
//  Created by TheMe on 2017/5/8.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheCommand.h"
#import "TheTerminalConst.h"

extern NSString *const kTheMeScheme;

@interface TheTerminal : TheCommand

+ (instancetype)sharedTerminal;

- (TheCommand *)parse:(NSString *)cmd;
- (void)consume:(NSString *)cmd;

@end
