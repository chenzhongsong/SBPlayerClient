//
//  FilterVideoType.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/2/13.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterVideoType : NSObject

/**
 筛选视频或者音频路径存入数组

 @param urls 拖拽所有文件的路径数组
 @return 返回筛选后的音频路径数组
 */
+(NSArray *)filterURLs:(NSArray *)urls;
@end
