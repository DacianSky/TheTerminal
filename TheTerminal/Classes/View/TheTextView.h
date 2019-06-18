//
//  TheTextView.h
//  TheTerminal
//
//  Created by TheMe on 2019/1/4.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheTerminalView.h"

extern int const kTheTextViewTag;

NS_ASSUME_NONNULL_BEGIN

@protocol TheTextViewDelegate <NSObject>

@optional
- (void)close;

@end

@interface TheTextView : TheTerminalView

@property (nonatomic,weak) id<TheTextViewDelegate> logDelegate;

@property (nonatomic,assign) NSInteger limitNumber;
- (void)inputText:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
