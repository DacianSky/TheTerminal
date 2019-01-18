//
//  TheLogCommand.h
//  TheTerminal
//
//  Created by TheMe on 2017/7/21.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheCommand.h"

#define logcmd__ [TheLogCommand sharedLog]
@interface TheLogCommand : TheCommand

+ (instancetype)sharedLog;
- (void)configRedirect;

@end
