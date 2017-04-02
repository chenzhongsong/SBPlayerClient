//
//  Tools.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/3/1.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

/**
 通过文件路径获取文件名

 @param path 文件路径
 @return 文件名
 */
+(NSString *)getVideoNameByPath:(NSString *)path;

/**
 通过文件路径获取带有后缀的文件名

 @param path 文件路径
 @return 带有后缀的文件名
 */
+(NSString *)getVideoNameWithPathExtensionByPath:(NSString *)path;

/**
 通过文件路径获取文件大小和文件宽高比

 @param path 文件路径
 @return 文件大小和宽高比的描叙文字
 */
+(NSString *)getVideoFileSizeInfoByPath:(NSString *)path;

@end
