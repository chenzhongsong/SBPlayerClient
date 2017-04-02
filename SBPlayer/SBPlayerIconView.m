//
//  SBPlayerIconView.m
//  SBPlayer
//
//  Created by sycf_ios on 2017/3/14.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import "SBPlayerIconView.h"

@interface SBPlayerIconView ()
@property (weak) IBOutlet NSImageView *iconImgView;
@property (weak) IBOutlet NSTextField *titleLabel;

@end

@implementation SBPlayerIconView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor clearColor].CGColor;
    //给titleLabel添加阴影
    NSShadow *shadow = [[NSShadow alloc]init];
    shadow.shadowColor = [NSColor lightGrayColor];
    shadow.shadowOffset = NSMakeSize(3, -3);
    shadow.shadowBlurRadius = 2;
    self.titleLabel.shadow = shadow;
}

@end
