//
//  TitleViewController.m
//  SBPlayer
//
//  Created by sycf_ios on 2017/3/29.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import "TitleViewController.h"

@interface TitleViewController ()

@end

@implementation TitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
    //设置标题的背景颜色
    self.view.layer.backgroundColor = [NSColor colorWithRed:0.15 green:0.21 blue:0.19 alpha:0.5].CGColor;
}

@end
