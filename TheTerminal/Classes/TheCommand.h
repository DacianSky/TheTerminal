//
//  TheCommand.h
//  TheTerminal
//
//  Created by TheMe on 2017/5/8.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kCommandPrefix @"thou://"
//const kProjectName;

@interface TheCommand : NSObject

@property (nonatomic,strong,readonly) NSString *command;
@property (nonatomic,strong,readonly) NSString *body;
@property (nonatomic,strong,readonly) NSString *urlArg;
@property (nonatomic,strong,readonly) NSDictionary *params;

+ (BOOL)couldParse:(NSString *)commandString;
- (void)execute;

- (instancetype)initWithCommand:(NSString *)command;
- (BOOL)havaParam:(NSString *)param;
- (id)valueWithParam:(NSString *)param;

- (void)showTerminalView:(id)parameter;
- (void)hideTerminalView;
- (NSInteger)terminalTag;
- (CGRect)suggestFrame;
- (UIView *)buildTerminalView:(id)parameter;

@end
