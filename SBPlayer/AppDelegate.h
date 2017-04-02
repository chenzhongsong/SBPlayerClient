//
//  AppDelegate.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowController.h"
#import "SBApplication.h"
#import "CommonHeader.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic,strong) WindowController *mainWindowController;

@end

