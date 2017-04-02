//
//  Tools.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/3/1.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "Tools.h"
#import <AVFoundation/AVFoundation.h>
@interface Tools()

@end
@implementation Tools

+(NSString *)getVideoNameByPath:(NSString *)path{
    NSArray *allStrArr = [path componentsSeparatedByString:@"/"];
    NSString *resultStr = allStrArr.lastObject;
    resultStr = resultStr.lastPathComponent;
    resultStr = [resultStr stringByDeletingPathExtension];
    return resultStr;
}
+(NSString *)getVideoNameWithPathExtensionByPath:(NSString *)path{
    NSArray *allStrArr = [path componentsSeparatedByString:@"/"];
    NSString *resultStr = allStrArr.lastObject;
    resultStr = resultStr.lastPathComponent;
    return resultStr;
}
+(NSString *)getVideoFileSizeInfoByPath:(NSString *)path{
    NSError *error = nil;
    NSDictionary *dic = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:&error];
    if (error) {
        NSLog(@"GetFileSizeError:%@",error);
        return @"__M ";
    }
    //视频文件大小
    CGFloat fileSize = [[dic objectForKey:@"NSFileSize"]floatValue]/(1000*1000);
    //视频文件宽高比
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    NSInteger height = 0;
    NSInteger width = 0;
    if ([tracks count]>0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        width = videoTrack.naturalSize.width;
        height = videoTrack.naturalSize.height;
    }
    return [NSString stringWithFormat:@"%.1fM    %ld x %ld",fileSize,(long)width,(long)height];
}
@end
