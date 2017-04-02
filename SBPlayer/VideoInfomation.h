//
//  VideoInfo.h
//  SBPlayer
//
//  Created by sycf_ios on 2017/3/27.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm.h>
@interface VideoInfomation : RLMObject
//标题
@property (nonatomic,copy) NSString *title;
//总时间
@property (nonatomic,copy) NSString *totalTime;
//大小
@property (nonatomic,copy) NSString *size;
//路径
@property (nonatomic,copy) NSString *url;
//路径数据 ---此数据是在沙盒的环境下用到的
@property (nonatomic,strong) NSData *urlData;
//@property (nonatomic,assign) int id;

@end
