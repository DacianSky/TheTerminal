//
//  ViewController.m
//  TheTerminalDemo
//
//  Created by TheMe on 2019/1/17.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "TheTerminal.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *searchBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    enableTheLog(YES);
    self.view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.searchBar];
    self.searchBar.frame = CGRectMake(30, 100, self.view.bounds.size.width * 0.7, 44);
}

- (UITextField *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UITextField alloc] init];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    __executeCommand(textField.text);
    return YES;
}

@end
