//
//  SBAlertView.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/3/7.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SBAlertView : NSView

/**
 初始化提示标题

 @param title 标题
 @return 返回实例SBAlertView
 */
-(instancetype)initWithTitle:(NSString *)title;

@property (nonatomic,strong) NSTextField *label;
@end
