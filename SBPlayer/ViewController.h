//
//  ViewController.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <VLCKit/VLCKit.h>
#import <Realm.h>
#import "SBApplication.h"
#import "Tools.h"
#import "SBAlertView.h"
#import "FilterVideoType.h"
#import "ToolViewController.h"
#import "ColorPanelViewController.h"
#import "VideoInfomation.h"
#import "TitleViewController.h"
#define REALM [RLMRealm defaultRealm]
//static int primaryId = 0;
@interface ViewController : NSViewController<VLCMediaPlayerDelegate>
//判断是否有视频文件拖入
@property (nonatomic,assign) BOOL hasDraggedFiles;
//播放列表
@property (weak) IBOutlet NSTableView *tableView;
//判断是否全屏
@property (nonatomic,assign) BOOL isFullScreen;
//是否已经获取视频信息
@property (nonatomic,assign) BOOL hasAccessVideoInfo;

//打开文件
- (IBAction)openFile:(id)sender;
//打开文件（网络或者路径文件）
-(void)sbViewGetFileURL:(NSURL *)url;
//将视频文件存入数据库
-(void)playlistDataAddToDatabase;
//添加通知
-(void)addNotificationCenterWithInformative:(NSString *)informative withTitle:(NSString *)title;
//清除所有播放记录
- (IBAction)clearAll:(id)sender;
//点击画板
- (IBAction)handleToolBox:(id)sender;
//播放
- (IBAction)play:(id)sender;
//下一个
- (IBAction)next:(id)sender;
//显示或者隐藏
- (IBAction)showOrHidePlaylist:(id)sender;
//控制播放进度
-(void)progressWithTime:(NSInteger)time;
//声音加
-(void)volumeUp;
//声音减
-(void)volumeDown;
@end

