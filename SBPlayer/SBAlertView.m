//
//  SBAlertView.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/3/7.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "SBAlertView.h"
#import <Masonry.h>
@interface SBAlertView ()

@end

@implementation SBAlertView

-(instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        [self setupUIWithTitle:(NSString *)title];
    }
    return self;
}
-(void)setupUIWithTitle:(NSString *)title{
    self.label = [[NSTextField alloc]init];
    self.label.stringValue = title;
    self.label.bezeled = NO;
    self.label.editable = NO;
    self.label.focusRingType = NSFocusRingTypeNone;
    self.label.drawsBackground = NO;
    self.label.selectable = NO;
    self.label.font = [NSFont systemFontOfSize:17];
    self.label.textColor = [NSColor blackColor];
    self.label.alignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self addLabelConstraint];
    self.wantsLayer = YES;
    self.layer.cornerRadius = dirtyRect.size.height/2;
    self.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
}
-(void)addLabelConstraint{
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(NSEdgeInsetsMake(0, 20, 0, 20));
        make.centerY.mas_equalTo(self).priorityHigh();
    }];
}
@end
