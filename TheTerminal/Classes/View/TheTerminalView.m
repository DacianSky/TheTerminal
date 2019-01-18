//
//  TheTerminalView.m
//  TheTerminal
//
//  Created by TheMe on 2019/1/4.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheTerminalView.h"
#import "NSString+Terminal.h"
#import "TheTerminal.h"

int const kTheTerminalViewTag = 4270;

@interface TheTerminalView() <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *searchBar;

@end

@implementation TheTerminalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self anywayInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self anywayInit];
}

- (void)anywayInit
{
    [self configParam];
    [self configView];
    [self configData];
    [self configConstraint];
}

- (void)configParam
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 6;
    self.layer.masksToBounds = YES;
}

- (void)configView
{
    [self.headerView addSubview:self.closeBtn];
    [self.headerView addSubview:self.refreshBtn];
    [self.headerView addSubview:self.searchBar];
    [self addSubview:self.headerView];
}

- (void)configConstraint
{
}

- (void)configData{}

#pragma mark - lazy load

- (UIView *)headerView
{
    if (!_headerView) {
        CGRect frame = CGRectMake(0, 0, self.bounds.size.width, 44);
        _headerView = [[UIView alloc] initWithFrame:frame];
        _headerView.backgroundColor = UIColor.darkGrayColor;//[UIColor colorWithPatternImage:ThemeImage(@"common/wood")];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_headerView addGestureRecognizer:pan];
        
        UITapGestureRecognizer *doubleTap= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [_headerView addGestureRecognizer:doubleTap];
    }
    return _headerView;
}

#define kBtnWidth 25
#define kPadding 15
- (UITextField *)searchBar
{
    if (!_searchBar) {
        CGRect frame = CGRectMake(kPadding * 2 + kBtnWidth, 4, (self.headerView.bounds.size.width - (kPadding * 2 + kBtnWidth)*2), 36);
        _searchBar = [[UITextField alloc] initWithFrame:frame];
        _searchBar.delegate = self;
        
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.backgroundColor = UIColor.whiteColor;
        _searchBar.textColor = UIColor.blackColor;
        _searchBar.font = [UIFont boldSystemFontOfSize:13];
        _searchBar.placeholder = @"input command";
        
        _searchBar.layer.cornerRadius = 10;
        _searchBar.clipsToBounds = YES;
        
        _searchBar.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        _searchBar.leftViewMode = UITextFieldViewModeAlways;
        _searchBar.clearButtonMode = UITextFieldViewModeAlways;
        _searchBar.returnKeyType = UIReturnKeySend;
    }
    return _searchBar;
}

#define kBtnColor UIColor.whiteColor
- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        CGRect frame = CGRectMake(self.headerView.bounds.size.width - kBtnWidth - kPadding, (self.headerView.bounds.size.height - kBtnWidth) / 2, kBtnWidth, kBtnWidth);
        _closeBtn = [[UIButton alloc] initWithFrame:frame];
        UIImage *img = [UIImage imageWithContentsOfFile:[NSString imagePath:@"icon_close"]];
        img = nil;
        if (img) {
            [_closeBtn setImage:img forState:UIControlStateNormal];
        }else{
            [_closeBtn setTitle:@"关" forState:UIControlStateNormal];    // 如果是打包静态库显示文字
            [_closeBtn setTitleColor:kBtnColor forState:UIControlStateNormal];
            
            _closeBtn.layer.borderWidth = 1.0;
            _closeBtn.layer.borderColor = kBtnColor.CGColor;
            _closeBtn.layer.cornerRadius = 10;
            _closeBtn.layer.masksToBounds = YES;
        }
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)refreshBtn
{
    if (!_refreshBtn) {
        CGRect frame = CGRectMake(kPadding, (self.headerView.bounds.size.height - kBtnWidth) / 2, kBtnWidth, kBtnWidth);
        _refreshBtn = [[UIButton alloc] initWithFrame:frame];
        UIImage *img = [UIImage imageWithContentsOfFile:[NSString imagePath:@"refresh_command"]];
        img = nil;
        if (img) {
            [_refreshBtn setImage:img forState:UIControlStateNormal];
        }else{
            [_refreshBtn setTitle:@"再" forState:UIControlStateNormal];
            [_refreshBtn setTitleColor:kBtnColor forState:UIControlStateNormal];
            
            _refreshBtn.layer.borderWidth = 1.0;
            _refreshBtn.layer.borderColor = kBtnColor.CGColor;
            _refreshBtn.layer.cornerRadius = 10;
            _refreshBtn.layer.masksToBounds = YES;
            
        }
        [_refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

#pragma mark - action

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    __executeCommand(textField.text);
    return YES;
}

- (void)close
{
    [self removeFromSuperview];
}

- (void)refresh
{
    __executeCommand(@"thou://terminal?last=1");
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGPoint panLocation = [sender locationInView:window];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = panLocation;
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGFloat offsetX = panLocation.x - self.lastPoint.x;
        CGFloat offsetY = panLocation.y - self.lastPoint.y;
        
        CGRect frame = self.frame;
        frame.origin.x += offsetX;
        frame.origin.y += offsetY;
        
        self.frame = frame;
        
        self.lastPoint = panLocation;
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)sender
{
    CGRect frame = self.frame;
    if (frame.size.height == 44) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGSize size = window.frame.size;
        frame.size.height = size.height * 0.6;
    }else{
        frame.size.height = 44;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
    }];
}

@end
