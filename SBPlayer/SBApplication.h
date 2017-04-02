//
//  SBApplication.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/2/13.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBApplication : NSObject
//每次拖进或者选择的视频文件数组
@property (nonatomic,strong) NSArray *filePaths;
+(instancetype)share;
//判断是否是双击打开的文件，如果是双击打开的播放器，播放完不会继续播下一个视频
@property (nonatomic,assign) BOOL isDoubleClickOpen;

@end
