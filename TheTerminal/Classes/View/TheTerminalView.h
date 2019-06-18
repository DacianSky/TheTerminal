//
//  TheTerminalView.h
//  TheTerminal
//
//  Created by TheMe on 2019/1/4.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern int const kTheTerminalViewTag;

@interface TheTerminalView : UIView

@property (nonatomic,strong) UIButton *refreshBtn;
@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,assign) CGPoint lastPoint;

- (void)anywayInit;
- (void)configParam;
- (void)configView;
- (void)configConstraint;
- (void)configData;

- (void)close;
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
