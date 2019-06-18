//
//  TheTextView.m
//  TheTerminal
//
//  Created by TheMe on 2019/1/4.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheTextView.h"

int const kTheTextViewTag = 6011;

#define kLimitLineNumber 250
@interface TheTextView()

@property (nonatomic,strong) UITextView *textView;

@end

@implementation TheTextView

- (void)configParam
{
    [super configParam];
    self.limitNumber = kLimitLineNumber;
}

- (void)configView
{
    [super configView];
    [self addSubview:self.textView];
}

#pragma mark - lazyload

- (UITextView *)textView
{
    if (!_textView) {
        CGRect frame = CGRectMake(0, self.headerView.frame.size.height, self.bounds.size.width, self.bounds.size.height - self.headerView.frame.size.height);
        _textView = [[UITextView alloc] initWithFrame:frame];
        _textView.backgroundColor = UIColor.lightGrayColor;
        _textView.editable = NO;
    }
    return _textView;
}

- (void)close
{
    if ([self.logDelegate respondsToSelector:@selector(close)]) {
        [self.logDelegate close];
    }
    
    [super close];
}

- (void)inputText:(NSString *)input
{
    NSString *text = self.textView.text;
    NSInteger limitLength = [self limitLineNumberRange:text];
    if (limitLength) {
        text = [text substringFromIndex:limitLength];
    }
    
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",text, input];
    NSRange range;
    range.location = [self.textView.text length] - 1;
    range.length = 0;
    [self.textView scrollRangeToVisible:range];
}

- (NSInteger)limitLineNumberRange:(NSString *)text
{
    NSInteger limitLocation = 0;
    NSString * linefeed = @"\n";
    NSRange range;
    NSUInteger count = 0;
    for (NSInteger i = text.length - linefeed.length + 1; i >= linefeed.length ; i--) {
        range.location = i-linefeed.length;
        range.length = linefeed.length;
        if ([[text substringWithRange:range] isEqualToString:linefeed]) {
            count++;
            if (count >= self.limitNumber) {
                break;
            }
        }
    }
    limitLocation = range.location + range.length;
    if (count < self.limitNumber) {
        limitLocation = 0;
    }
    return limitLocation;
}

@end
