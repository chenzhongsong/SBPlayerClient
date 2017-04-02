//
//  SBPlaylistItem.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/2/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "URLAsset.h"
@class SBPlaylistItem;
//SBPlaylistItem协议
@protocol SBPlaylistItemDelegate <NSObject>
@required
-(void)sbPlaylistItemDeleteCurrentItem:(SBPlaylistItem *)item;
@end
@interface SBPlaylistItem : NSTableCellView
//视频标题
@property (weak) IBOutlet NSTextField *title;
//总时间
@property (weak) IBOutlet NSTextField *totalTime;
//删除按钮
@property (weak) IBOutlet NSButton *closeBtn;
//视频地址
@property (nonatomic,strong) NSURL *url;
//视频大小
@property (weak) IBOutlet NSTextField *size;
//代理
@property (nonatomic,weak) id<SBPlaylistItemDelegate> delegate;
//路径是否已经失效
@property (nonatomic,assign) BOOL isItemAvailable;


@end
