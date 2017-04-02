//
//  URLAsset.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/3/1.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "URLAsset.h"
#define OPTS [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]
@implementation URLAsset
-(NSString *)getTotalTimeFromUrl:(NSURL *)url{
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:OPTS];
    // 初始化视频媒体文件
    CGFloat second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale;
    return [self convertTime:second];
}
//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

@end
