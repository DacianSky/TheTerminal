//
//  TheListView.h
//  TheTerminal
//
//  Created by TheMe on 2017/8/3.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheTerminalView.h"

extern int const kTheLisgViewTag;

@interface TheListView : TheTerminalView

@property (nonatomic,strong) NSArray *dataSources;

@end
