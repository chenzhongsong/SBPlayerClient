//
//  URLAsset.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/3/1.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface URLAsset : NSObject

/**
 通过URL获取视频总时长

 @param url 视频URL
 @return 返回总时长
 */
-(NSString *)getTotalTimeFromUrl:(NSURL *)url;

@end
