//
//  SBApplication.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/2/13.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "SBApplication.h"

@implementation SBApplication
+(instancetype)share{
    static SBApplication *application = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        application = [[self alloc]init];
    });
    return application;
}
@end
