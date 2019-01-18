//
//  TheListView.m
//  TheTerminal
//
//  Created by TheMe on 2017/8/3.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheListView.h"
#import "NSString+Terminal.h"
#import "TheTerminal.h"

int const kTheLisgViewTag = 2090;

#define kListViewCellReuseId @"kListViewCellReuseId"
@interface TheListView() <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation TheListView

- (void)configView
{
    [super configView];
    [self addSubview:self.tableView];
}

- (void)configData{}

#pragma mark - lazy load
- (UITableView *)tableView
{
    if (!_tableView) {
        CGRect frame = CGRectMake(0, self.headerView.frame.size.height, self.bounds.size.width, self.bounds.size.height - self.headerView.frame.size.height);
        _tableView = [[UITableView alloc] initWithFrame:frame];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kListViewCellReuseId];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark - delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.dataSources[indexPath.row];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(tableView.frame.size.width - 32, MAXFLOAT) ];
#pragma clang diagnostic pop
    return size.height + 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kListViewCellReuseId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row%2==0) {
        cell.backgroundColor = UIColor.whiteColor;
    }else{
        cell.backgroundColor = UIColor.grayColor;
    }
    
    cell.textLabel.text = self.dataSources[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}

@end
