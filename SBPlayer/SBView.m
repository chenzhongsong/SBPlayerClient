//
//  SBView.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/20.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//
//鼠标拖拽文件响应的操作
#import "SBView.h"
#import "FilterVideoType.h"
#import <Realm.h>
#import "SBApplication.h"
@implementation SBView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSString *UTTypeString =  (__bridge NSString *)kUTTypeURL;
    //所有格式的文件
    [self registerForDraggedTypes:[NSArray arrayWithObject:UTTypeString]];
    
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    //所有音频或者视频格式的文件
    NSString *audiovisualContent = (__bridge NSString *)kUTTypeAudiovisualContent;
    NSDictionary *filteringOptions = [NSDictionary dictionaryWithObject:audiovisualContent forKey:NSPasteboardURLReadingFileURLsOnlyKey];
    if ([pasteboard canReadObjectForClasses:@[[NSURL class]] options:filteringOptions]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}
-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSArray *pboardArray = [[sender draggingPasteboard]propertyListForType:@"NSFilenamesPboardType"];
    NSLog(@"pboardArray:%@",pboardArray);
    //筛选正确的视频路径并存入数组
    NSArray *urlsPath = [FilterVideoType filterURLs:pboardArray];
    [SBApplication share].filePaths = urlsPath;
    if (urlsPath.count>0) {
        if ([self.delegate respondsToSelector:@selector(sbViewGetFileURL:)]) {
            [self.delegate sbViewGetFileURL:[NSURL fileURLWithPath:urlsPath[0]]];
        }
        return YES;
    }
    return NO;
}

@end
