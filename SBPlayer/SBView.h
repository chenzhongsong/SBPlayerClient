//
//  SBView.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/20.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
//拖拽文件到窗口协议
@protocol SBViewDragFileDelegate <NSObject>

//拖拽文件进窗口时获取文件url
-(void)sbViewGetFileURL:(NSURL *)url;
@end
@interface SBView : NSView
@property (nonatomic,weak) id<SBViewDragFileDelegate> delegate;
@end
