//
//  AppDelegate.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SBOpenURLWindowController.h"
#import <CoreServices/CoreServices.h>
#import "FilterVideoType.h"

@interface AppDelegate ()
//根控制器
@property (nonatomic,strong) ViewController *rootVC;
//打开Network控制器
@property (nonatomic,strong) SBOpenURLWindowController *openURLWindow;
@property (nonatomic, copy) NSString *pendingURL;
@property (nonatomic,assign) BOOL isReady;

@end

@implementation AppDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];// 1
    [appleEventManager setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.rootVC = (ViewController *)self.mainWindowController.contentViewController;
    if (!self.rootVC.isFullScreen) {
        [self.mainWindowController.window setFrame:NSMakeRect(0, 0, 800, 600) display:YES];
    };
    [self.mainWindowController.window center];
    
    if (_pendingURL) {
        NSArray *usefulUrlArr = [FilterVideoType filterURLs:@[_pendingURL]];
        if (usefulUrlArr.count == 1) {
            for (NSString *tmpUrl in usefulUrlArr) {
                [SBApplication share].isDoubleClickOpen = YES;
                [self.rootVC sbViewGetFileURL:[NSURL fileURLWithPath:tmpUrl]];
                _pendingURL = nil;
                break;
            }
        }
    }
}
//添加播放链接到数据库
-(void)addURLToDataBaseWithURL:(NSString *)urlString{
    [SBApplication share].filePaths = @[urlString];
    [self.rootVC playlistDataAddToDatabase];
}
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
    [self addURLToDataBaseWithURL:filename];
    _pendingURL = filename;
    [self.rootVC sbViewGetFileURL:[NSURL fileURLWithPath:filename]];
    [self.mainWindowController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

//-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
//    [self.mainWindowController.window makeKeyAndOrderFront:self];
//    return YES;
//}
- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    //这个里面的方法都是无用代码，一开始我是不情愿使用的，但在Apple文档中看到似乎又要添加这个方法。测试过很多次没走过里面的方法。可以无视NSAppleEventManager
    _isReady = YES;
    url = [url substringFromIndex:5];
    if ([[url substringToIndex:6] isEqual: @"http//"]) {        url = [url substringFromIndex:6];
    }
    if([url isEqualToString:@"open_without_gui"]){
        return;
    }
    _pendingURL = url;

    [self.rootVC sbViewGetFileURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]]];
    [NSApp activateIgnoringOtherApps:YES];
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}
//添加Dock菜单
-(NSMenu *)applicationDockMenu:(NSApplication *)sender{
    NSMenu *dockMenu = [[NSMenu alloc]init];
    [dockMenu addItemWithTitle:NSLocalizedString(@"Play/Pause", nil) action:@selector(playOrPause:) keyEquivalent:@""];
    [dockMenu addItemWithTitle:NSLocalizedString(@"Next", nil) action:@selector(nextVideo:) keyEquivalent:@""];
    return dockMenu;
}
//工具栏点击事件
#pragma mark - 文件

//打开文件
- (IBAction)openFile:(NSMenuItem *)sender {
    [self.rootVC openFile:self];
}
//打开网络链接
- (IBAction)openURL:(id)sender {
    self.openURLWindow = [[SBOpenURLWindowController alloc]initWithWindowNibName:@"SBOpenURLWindowController"];
    NSWindow *urlWindow = self.openURLWindow.window;
    [urlWindow center];
    [self.mainWindowController.window addChildWindow:urlWindow ordered:NSWindowAbove];
}
#pragma mark - 控制

//删除所有记录
- (IBAction)deleteAllRecords:(id)sender {
    [self.rootVC clearAll:sender];
}
//播放/暂停
- (IBAction)playOrPause:(id)sender {
    [self.rootVC play:sender];
}
//下一个视频
- (IBAction)nextVideo:(id)sender {
    [self.rootVC next:sender];
}

//皮肤
- (IBAction)setSkin:(id)sender {
    [self.rootVC handleToolBox:sender];
}
//右栏
- (IBAction)showRightView:(id)sender {
    [self.rootVC showOrHidePlaylist:sender];
}
//显示sbplayer
- (IBAction)showSBPlayer:(id)sender {
    [self.mainWindowController.window makeKeyAndOrderFront:self];
}
//跳转到帮助
- (IBAction)sbPlayerHelp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://shibiao.github.io"]];
}
//声音减小
- (IBAction)soundReduction:(id)sender {
    [self.rootVC volumeDown];
}
//声音大
- (IBAction)soundPlus:(id)sender {
    [self.rootVC volumeUp];
}
//后退10秒
- (IBAction)backToTenSeconds:(id)sender {
    [self.rootVC progressWithTime:-10000];
}
//前进10秒
- (IBAction)ForwardTenSeconds:(id)sender {
    [self.rootVC progressWithTime:10000];
}



@end
