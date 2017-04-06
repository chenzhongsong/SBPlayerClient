//
//  ViewController.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "ViewController.h"
#import "SBView.h"
#import <Masonry.h>
#import "ISSoundAdditions.h"
#import "SBPlaylistItem.h"
#import "SBPlayerIconView.h"
#import "CommonHeader.h"

//NSTableView 背景颜色
#define kTableViewBackgroundColor [NSColor colorWithRed:0.15 green:0.20 blue:0.19 alpha:1.00]

@interface ViewController ()<NSSplitViewDelegate,NSDraggingDestination,SBViewDragFileDelegate,NSTableViewDelegate,NSTableViewDataSource,SBPlaylistItemDelegate,NSUserNotificationCenterDelegate,ColorPanelViewControllerDelegate>

@property (weak) IBOutlet NSView *controlBackgroundView;

@property (weak) IBOutlet NSSplitView *splitView;
//当前播放时间
@property (weak) IBOutlet NSTextField *currentTime;
//总时间
@property (weak) IBOutlet NSTextField *totalTime;

@property (nonatomic,strong) VLCMedia *movie;
//进度条
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *playOrPauseBtn;
//VLCPlayer视图
@property (nonatomic,strong) VLCVideoView *playerView;
//左SplitView
@property (weak) IBOutlet SBView *leftSplitView;
//右SplitView
@property (weak) IBOutlet NSView *rightSplitView;
//声音控制StackView
@property (weak) IBOutlet NSStackView *volumeStackView;
//工具箱
@property (weak) IBOutlet NSButton *toolBtn;

@property (weak) IBOutlet NSScrollView *tableScrollView;
//文件视图
@property (weak) IBOutlet NSView *fileView;
//文件操作有关
@property (nonatomic,strong) NSOpenPanel *openPanel;
//声音进度条
@property (weak) IBOutlet NSProgressIndicator *volumeProgressIndicator;
//视频数据
@property (nonatomic,strong) RLMResults *dataResults;
//当前URL
@property (nonatomic,strong) NSURL *currentURL;
//当前播放item
@property (nonatomic,strong) SBPlaylistItem *currentItem;
//加载Tip
@property (nonatomic,strong) SBAlertView *loadingTipView;
//播放器图标视图
@property (nonatomic,strong) SBPlayerIconView *iconVC;

//viusalEffectView
@property (nonatomic,strong) NSVisualEffectView *visualEffectView;
//颜色控制器
@property (nonatomic,strong) NSPopover *colorPanelPopover;
//标题视图
@property (nonatomic,strong) TitleViewController *titleView;
//播放列表
@property (weak) IBOutlet NSButton *playlist;

@end
//设置快进或者慢进参数比例
static CGFloat forwardRatio = 1;
@implementation ViewController{
    VLCMediaPlayer *player;
    CGFloat videoScaleRatio;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    //初始化播放器颜色
    [self addVisualEffectViewWithMaterial:NSVisualEffectMaterialDark];
    NSNumber *materialNumber = [[NSUserDefaults standardUserDefaults]objectForKey:@"material"];
    if (materialNumber) {
        [self addVisualEffectViewWithMaterial:materialNumber.integerValue];
    }
    NSData *data = ([[NSUserDefaults standardUserDefaults]objectForKey:@"currentColor"]);
    NSColor *currentColor;
    if(data != nil ){
        currentColor = [NSUnarchiver unarchiveObjectWithData:data];
    }
    if (currentColor) {
        self.controlBackgroundView.layer.backgroundColor = currentColor.CGColor;
    }
}
//添加visualEffect视觉效果
-(void)addVisualEffectViewWithMaterial:(NSVisualEffectMaterial)material {
    self.visualEffectView.material = material;
    [self.view addSubview:self.visualEffectView positioned:NSWindowBelow relativeTo:nil];
    [self.visualEffectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    //初始化someThing
    [self initSomething];
    [self setupUI];
}

-(void)viewDidAppear{
    [super viewDidAppear];
    self.tableView.backgroundColor = [NSColor clearColor];
    [self.splitView setPosition:self.view.frame.size.width ofDividerAtIndex:0];
    [self.splitView setNeedsLayout:YES];
    [self screenResize];
    [self.leftSplitView addSubview:self.fileView positioned:NSWindowAbove relativeTo:nil];
}
-(void)setupUI{
    //设置背景颜色
    [self setupBackground];
    //设置控制器
    [self setupControl];
    //设置播放列表
    [self setupPlaylist];
    //设置播放器初始化
    [self setupPlayerWithContentOfFile:[[NSURL alloc]init]];
    //添加iconView
    [self addIconView];

}

//添加iconView
-(void)addIconView{
    self.iconVC = [[SBPlayerIconView alloc]initWithNibName:@"SBPlayerIconView" bundle:nil];
    [self.playerView addSubview:self.iconVC.view];
    [self.iconVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.playerView).priorityLow();
        make.center.mas_equalTo(self.playerView);
        
    }];
}
//初始化something
-(void)initSomething {
    //设置消息中心代理
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    //设置NSTableView 选中状态颜色为空
    //    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    //设置NSTableView 双击事件
    [self.tableView setDoubleAction:@selector(doubleClickTableViewRow:)];
    self.leftSplitView.delegate = self;
    [self initPlaylistTableView];
    self.titleView = [[TitleViewController alloc]init];
}

//设置leftSplitView
-(void)setupLeftSplitView{
    NSTrackingArea *allArea = [[NSTrackingArea alloc]initWithRect:self.view.bounds options:NSTrackingMouseMoved|NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited|NSTrackingInVisibleRect owner:self userInfo:nil];
    [self.view addTrackingArea:allArea];
}
//左splitView进入全屏后的定时器
NSTimer *leftSplitTimer;
#pragma mark - Mouse Event 鼠标事件
-(void)mouseEntered:(NSEvent *)event{
    [super mouseEntered:event];
    if (self.movie.url.relativePath.length != 0) {
            self.titleView.view.hidden = NO;
        [self setSystemCloseMiniaturiazeAndZoomButtonsHide:NO];
    }
    
}
-(void)mouseExited:(NSEvent *)event{
    [super mouseExited:event];
    self.titleView.view.hidden = YES;
    if (self.movie.url.relativePath.length != 0) {
        [self setSystemCloseMiniaturiazeAndZoomButtonsHide:YES];
    }
    
}
-(void)mouseMoved:(NSEvent *)event{
    [super mouseMoved:event];
    [NSCursor unhide];
    if (self.movie.url.relativePath.length != 0) {
        self.titleView.view.hidden = NO;
        [self setSystemCloseMiniaturiazeAndZoomButtonsHide:NO];
    }
    [self.controlBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@60);
    }];
    if (!_isFullScreen) {
        return;
    }
    if (!leftSplitTimer) {
        leftSplitTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
            if ([leftSplitTimer isValid]) {
                [self.controlBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(@0);
                }];
                [NSCursor hide];
                self.titleView.view.hidden = YES;
                [leftSplitTimer invalidate];
                leftSplitTimer = nil;
            }
        }];
    }
}
-(void)mouseUp:(NSEvent *)event{
    if (event.clickCount == 2) {
        [self openFile:self];
    }
}
//设置系统关闭，最小化和最大化按钮的显示与隐藏
-(void)setSystemCloseMiniaturiazeAndZoomButtonsHide:(BOOL)isHide{
    [kCurrentWindow standardWindowButton:NSWindowCloseButton].hidden = isHide;
    [kCurrentWindow standardWindowButton:NSWindowMiniaturizeButton].hidden = isHide;
    [kCurrentWindow standardWindowButton:NSWindowZoomButton].hidden = isHide;
}
- (IBAction)openFile:(id)sender {
    self.openPanel = [[NSOpenPanel alloc]init];
    [self.openPanel setAllowsMultipleSelection:YES];
    [self.openPanel setCanChooseFiles:YES];
    //    [self.openPanel setCanChooseDirectories:YES];
    [self.openPanel setCanCreateDirectories:YES];
    NSInteger i = [self.openPanel runModal];
    if (i == NSModalResponseOK) {
        NSURL *url = self.openPanel.URL;
        if (!url) {
            return;
        }else{
            //打开文件
            [SBApplication share].filePaths = @[url.relativePath];
            [self sbViewGetFileURL:url];
            
        }
    }
}

-(void)setupBackground{
    self.splitView.delegate = self;
    [self.splitView setPosition:self.view.frame.size.width ofDividerAtIndex:0];
    [self.splitView setNeedsLayout:YES];
}
-(void)setupControl{
    NSClickGestureRecognizer *progessGesture = [[NSClickGestureRecognizer alloc]initWithTarget:self action:@selector(acquireIndicatorPoint:)];
    [self.progressIndicator addGestureRecognizer:progessGesture];
    //初始化声音大小
    self.volumeProgressIndicator.minValue = 0.0;
    self.volumeProgressIndicator.maxValue = 1.0;
    CGFloat currentSound = [NSSound systemVolume];
    self.volumeProgressIndicator.doubleValue = currentSound;
    NSClickGestureRecognizer *volumeGesture = [[NSClickGestureRecognizer alloc]initWithTarget:self action:@selector(volumeValue:)];
    [self.volumeProgressIndicator addGestureRecognizer:volumeGesture];
    //监听进度条值的改变并改变系统声音
    [self addVolumeKVO];
    
}
-(void)volumeValue:(NSClickGestureRecognizer *)gesture
{
    NSPoint point = [gesture locationInView:self.volumeProgressIndicator];
    self.volumeProgressIndicator.doubleValue = self.volumeProgressIndicator.maxValue/self.volumeProgressIndicator.bounds.size.width*(point.x);
}
-(void)addVolumeKVO{
    [self.volumeProgressIndicator addObserver:self forKeyPath:@"doubleValue" options:NSKeyValueObservingOptionNew context:nil];
}
//点击indicator所在点的播放位置
-(void)acquireIndicatorPoint:(NSClickGestureRecognizer *)gesture{
    
    NSPoint point = [gesture locationInView:self.progressIndicator];
    self.progressIndicator.doubleValue = self.progressIndicator.maxValue/self.progressIndicator.bounds.size.width*(point.x);
    
    VLCTime *tmpTime = [VLCTime timeWithNumber:[NSNumber numberWithDouble:self.progressIndicator.doubleValue]];
    [player setTime:tmpTime];
    //暂停时设置拖拽后的当前时间
    self.currentTime.stringValue = tmpTime.stringValue;
}
//设置播放器
-(void)setupPlayerWithContentOfFile:(NSURL *)url {
    self.playlist.hidden = NO;
    self.progressIndicator.doubleValue = 0;
    self.currentTime.stringValue = @"00:00";
    CGFloat currentSound = [NSSound systemVolume];
    self.volumeProgressIndicator.doubleValue = currentSound;
    forwardRatio = 1;
    self.playerView = [[VLCVideoView alloc]init];
    self.playerView.frame = self.leftSplitView.bounds;
    [self.leftSplitView addSubview:self.playerView];
    [self.playerView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    self.playerView.fillScreen = YES;
    VLCMediaPlayer *mediaPlayer = [[VLCMediaPlayer alloc]initWithVideoView:self.playerView];
    player = mediaPlayer;
    //    player.scaleFactor = 1.2;
    [player setDelegate:self];
    self.currentURL = url;
    self.movie = [VLCMedia mediaWithURL:url];
    NSMutableDictionary *mediaDicionary = [[NSMutableDictionary alloc]init];
    [self.movie addOptions:mediaDicionary];
    [player setMedia:self.movie];
    //添加Notification
    [self addNotification];
    //添加KVO
    [self addKVO];
    //重置总时间
    self.totalTime.stringValue = @"00:00";
    self.loadingTipView = nil;
    //设置leftSplitView
    [self setupLeftSplitView];
    //添加VisualEffectView到playerView上
    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc]init];
    visualEffectView.material = NSVisualEffectMaterialDark;
    visualEffectView.state = NSVisualEffectStateActive;
    visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    [self.playerView addSubview:visualEffectView];
    [visualEffectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.playerView);
    }];
    [NSApp activateIgnoringOtherApps:YES];
    //添加标题
    [self addTitleView];
}
-(void)addTitleView{

    [self.view addSubview:self.titleView.view];
    [self.titleView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.leftSplitView.mas_right).offset(0);
        make.top.mas_equalTo(self.leftSplitView.mas_top).offset(0);
        make.left.mas_equalTo(self.leftSplitView.mas_left).offset(0);
    }];
    self.titleView.view.hidden = YES;
}
//MARK : 添加Notification
-(void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaPlayerStateChanged:) name:VLCMediaPlayerStateChanged object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaPlayerTimeChanged:) name:VLCMediaPlayerTimeChanged object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaPlayerTitleChanged:) name:VLCMediaPlayerTitleChanged object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaPlayerChapterChanged:) name:VLCMediaPlayerChapterChanged object:nil];
    //观察窗口拉伸
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenResize) name:NSWindowDidResizeNotification object:nil];
    //即将进入全屏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterFull:) name:NSWindowWillEnterFullScreenNotification object:nil];
    //即将推出全屏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willExitFull:) name:NSWindowWillExitFullScreenNotification object:nil];
    //已经推出全屏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didExitFull:) name:NSWindowDidExitFullScreenNotification object:nil];
    //NSWindowDidMiniaturizeNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didMiniaturize:) name:NSWindowDidMiniaturizeNotification object:nil];
    //窗口即将关闭
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willClose:) name:NSWindowWillCloseNotification object:nil];
}

//设置时间
-(void)setupTime{
    self.totalTime.stringValue = self.movie.length.stringValue;
    //    //当无法通过AVAsset获取总时间时走此方法
    //    if ([self.currentItem.totalTime.stringValue isEqualToString:@"00:00"]) {
    //        self.currentItem.totalTime.stringValue = self.totalTime.stringValue;
    //        [self.tableView reloadData];
    //    }
}
//MARK: 添加KVO
-(void)addKVO{
    
    [player addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        VLCMediaPlayerState state = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (state) {
            case VLCMediaPlayerStateStopped:
            {
                [self setStop];
                self.loadingTipView.hidden = YES;
                [self.loadingTipView removeFromSuperview];
                self.loadingTipView = nil;
                [self nextVideos];
            }
                break;
            case VLCMediaPlayerStateOpening:{
                
            }
                
                break;
            case VLCMediaPlayerStateBuffering:
            {
                if (self.movie.url == nil ||kMovieUrlRelativeString.length == 0) {
                    return;
                }
                
                if (!_loadingTipView && [self isStream]) {
                    [kCurrentWindow setContentSize:NSMakeSize(800, 600)];
                    self.loadingTipView = [[SBAlertView alloc]initWithTitle:NSLocalizedString(@"loading...", nil)];
                    self.loadingTipView.frame = NSMakeRect(5, 5, 130, 23);
                    self.loadingTipView.wantsLayer = YES;
                    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                        context.duration = 1;
                        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                        [self.playerView addSubview:self.loadingTipView];
                    } completionHandler:nil];
                    
                }else{
                    if (_loadingTipView) {
                        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                            context.duration = 1;
                            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            self.loadingTipView.animator.alphaValue= 0;
                            [self.loadingTipView.animator removeFromSuperview];
                        } completionHandler:nil];
                        
                    }
                }
            }
                break;
            case VLCMediaPlayerStateEnded:{
                //处理视频播放结束后出现的一丁点误差
                self.progressIndicator.doubleValue = self.progressIndicator.maxValue;
                [self removeObservesAndNotifications];
                [self setStop];
            }
                
                break;
            case VLCMediaPlayerStateError:{
                [self.loadingTipView removeFromSuperview];
                self.loadingTipView = nil;
                if (self.movie.url.relativePath.length == 0) {
                    [self play:nil];
                    return;
                }
                [self removeVideoAndInitPlayer];
                [self addNotificationCenterWithInformative:NSLocalizedString(@"Play Error!", nil) withTitle:NSLocalizedString(@"Alert", @"alert")];\
                //                [self setStop];
                
            }
                
                break;
            case VLCMediaPlayerStatePlaying:{
                [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Pause"]];
                if (self.movie.length.intValue == 0 ) {
                    //添加警告
                    return;
                }
                [self.iconVC.view removeFromSuperview];
                [self setupSize];
                //设置时间
                [self setupTime];
                [self setupProgressValue];
                NSString *messageStr = [Tools getVideoNameWithPathExtensionByPath:[self.movie.url relativePath]];
                messageStr = [messageStr stringByRemovingPercentEncoding];
                self.titleView.titleLabel.stringValue = messageStr;
                [self addVideoInfo];
            }
                break;
            case VLCMediaPlayerStatePaused:
            {
                if (![player hasVideoOut]&&(![self isMusicFormat])) {
                    if (kMovieUrlRelativeString != 0) {
                        [self sbViewGetFileURL:self.movie.url];
                    }
                }
                [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Play"]];
                if ((long long)self.progressIndicator.doubleValue/1000 >= (long long)self.progressIndicator.maxValue/1000-2) {
                    [self setStop];
                }
            }
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"doubleValue"]){
        double currentValue = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        [NSSound setSystemVolume:currentValue];
        player.audio.volume = 100;
    }else if ([keyPath isEqualToString:@"hasDraggedFiles"]){
        _hasDraggedFiles = NO;
        //将拖进的文件添加到数据库
        [self playlistDataAddToDatabase];
    }
}
//判断是否为音乐
-(BOOL)isMusicFormat{
    NSString *path = self.movie.url.relativePath;
    if ([path.pathExtension isEqualToString:@"mp3"]||
        [path.pathExtension isEqualToString:@"wma"]||
        [path.pathExtension isEqualToString:@"wav"]||
        [path.pathExtension isEqualToString:@"asf"]||
        [path.pathExtension isEqualToString:@"aac"]||
        [path.pathExtension isEqualToString:@"vqf"]||
        [path.pathExtension isEqualToString:@"mp3pro"]||
        [path.pathExtension isEqualToString:@"flac"]||
        [path.pathExtension isEqualToString:@"ape"]||
        [path.pathExtension isEqualToString:@"mid"]||
        [path.pathExtension isEqualToString:@"ogg"]
        )
    {
        return YES;
    }
    return NO;
}
-(BOOL)isStream {
    NSString *string = kMovieUrlRelativeString;
    if ([string containsString:@"HTTP://"] ||
        [string containsString:@"http://"] ||
        [string containsString:@"https://"] ||
        [string containsString:@"HTTPS://"] ||
        [string containsString:@"rtmp://"] ||
        [string containsString:@"rtsp://"] ||
        [string containsString:@"mms://"]
        ) {
        return YES;
    }
    return NO;
}
// MARK: 播放列表后的视频
-(void)nextVideos{
    [self setSystemCloseMiniaturiazeAndZoomButtonsHide:NO];
    if ([SBApplication share].isDoubleClickOpen) {
        [SBApplication share].isDoubleClickOpen = NO;
        [self removeVideoAndInitPlayer];
        //进度条置0
        self.progressIndicator.doubleValue = 0.0;
        return;
    }
    VideoInfomation *aVideo = [[VideoInfomation alloc]init];
    aVideo.url = self.currentURL.relativePath;
    NSInteger index = 0;
    for (VideoInfomation *tmpVideo in self.dataResults) {
        if ([tmpVideo.url isEqualToString:aVideo.url]) {
            index = [self.dataResults indexOfObject:tmpVideo];
            index += 1;
            if (index<=self.dataResults.count-1) {
                SBPlaylistItem *item = [self.tableView viewAtColumn:0 row:index makeIfNecessary:YES];
                [self sbViewGetFileURL:item.url];
                if (_isFullScreen) {
                    return;
                }
            }else{
                [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Play"]];
                [player pause];
                //移除视频并初始化播放器
                [self removeVideoAndInitPlayer];
                if (_isFullScreen) {
                    [kCurrentWindow setContentSize:[NSScreen mainScreen].frame.size];
                }
            }
            break;
        }else{
            [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Play"]];
            [player pause];
            //移除视频并初始化播放器
            [self removeVideoAndInitPlayer];
            if (_isFullScreen) {
                [kCurrentWindow setContentSize:[NSScreen mainScreen].frame.size];
            }

        }
        
    }
    //进度条置0
    self.progressIndicator.doubleValue = 0.0;
}
//移除视频并初始化播放器
-(void)removeVideoAndInitPlayer{
    
    [player stop];
    [self removeObservesAndNotifications];
    self.playerView = nil;
    self.movie = nil;
    player = nil;
    [self setupPlayerWithContentOfFile:[NSURL new]];
    [kCurrentWindow setContentSize:NSMakeSize(800, 600)];
    [self addIconView];
}
//添加消息中心
-(void)addNotificationCenterWithInformative:(NSString *)informative withTitle:(NSString *)title{
    NSUserNotification *notification =[[ NSUserNotification alloc]init];
    notification.title = title;
    notification.informativeText = informative;
//        notification.soundName = NSUserNotificationDefaultSoundName;
    [notification setDeliveryDate: [NSDate dateWithTimeIntervalSinceNow: 5]];
    [[NSUserNotificationCenter defaultUserNotificationCenter]deliverNotification:notification];
}
//MARK: NSNotificationCenterDelegate
-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

-(void)viewWillLayout{
    [super viewWillLayout];
    
}
//设置播放停止
-(void)setStop{
    [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Play"]];
    [player stop];
    [self.currentItem.url stopAccessingSecurityScopedResource];
}
-(void)setupSize {
    //获取视频比例
    CGFloat width = player.videoSize.width;
    CGFloat height = player.videoSize.height;
    videoScaleRatio = width/height;
    if (!_isFullScreen) {
            [self.leftSplitView setFrameSize:NSMakeSize(width*videoScaleRatio, height)];
            [kCurrentWindow setContentSize:NSMakeSize(kScreenHeight/4*3*videoScaleRatio, kScreenHeight/4*3+60)];
        if (width<=0&&height<=0) {
            self.playlist.hidden = YES;
            if (_loadingTipView) {
                _loadingTipView.hidden = YES;
            }
            [kCurrentWindow setFrame:NSMakeRect(0, 0, 550, 80) display:YES];
            [kCurrentWindow center];
            return;
        }
        if ([SBApplication share].isDoubleClickOpen) {
            [kCurrentWindow center];
        }
    }
    [self.view layoutSubtreeIfNeeded];
    //添加视频view约束
    [self setupPlayerViewConstraint];
    [kCurrentWindow updateConstraintsIfNeeded];
    
}
//添加视频View约束
-(void)setupPlayerViewConstraint {
    [self hideRightSplitView];
    CGFloat width = player.videoSize.width;
    CGFloat height = player.videoSize.height;
    if (width<=0&&height<=0) {
        [kCurrentWindow setFrame:NSMakeRect(0, 0, 550, 80) display:YES];
        return;
    }
    [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:videoScaleRatio constant:0]];
    [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self.leftSplitView);
        if (width<height) {
            make.top.bottom.mas_equalTo(self.leftSplitView);
        }else{
            make.left.right.mas_equalTo(self.leftSplitView);
        }
    }];
    [self.view layoutSubtreeIfNeeded];

    
}
//设置进度条的值
-(void)setupProgressValue{
    self.progressIndicator.maxValue = self.movie.length.intValue;
    self.progressIndicator.minValue = 0;
}
//设置播放列表
-(void)setupPlaylist{
    [self.rightSplitView.widthAnchor constraintLessThanOrEqualToConstant:300].active = YES;
    [self addPlaylistKVO];
}
//添加播放列表KVO
-(void)addPlaylistKVO {
    [self addObserver:self forKeyPath:@"hasDraggedFiles" options:NSKeyValueObservingOptionNew context:nil];
}
//MARK: 点击工具箱
- (IBAction)handleToolBox:(id)sender {
    if (_colorPanelPopover.isShown) {
        [_colorPanelPopover close];
        return;
    }
    [self.colorPanelPopover showRelativeToRect:self.toolBtn.bounds ofView:self.toolBtn preferredEdge:NSRectEdgeMinY];
}

//播放暂停
- (IBAction)play:(id)sender {
    //如果url地址为空
    [self movieURLIsEmpty];
    [self.playOrPauseBtn setAlternateImage:[NSImage new]];
    if (![player isPlaying]) {
        [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Pause"]];
        [player play];
    }else{
        if ([player canPause]) {
            [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Play"]];
            [player pause];
        }
    }
    
    
}
//视频为空
-(void)movieURLIsEmpty{
    NSString *relativeURL = kMovieUrlRelativeString;
    if (relativeURL == nil || relativeURL.length==0) {
        if (self.tableView.numberOfRows != 0) {
            SBPlaylistItem *item = [self.tableView viewAtColumn:0 row:0 makeIfNecessary:YES];
            if (item) {
                [self sbViewGetFileURL:item.url];
            }
        }
        return;
    }
}
//播放下一个视频
- (IBAction)next:(id)sender {
    [SBApplication share].isDoubleClickOpen = NO;
    //如果url地址为空
    [self movieURLIsEmpty];
    [self nextVideos];
}

//显示或者隐藏播放列表
- (IBAction)showOrHidePlaylist:(id)sender {
    [self.splitView setNeedsLayout:YES];
    if (self.splitView.frame.size.width != self.leftSplitView.frame.size.width) {
        [self.splitView setPosition:self.view.frame.size.width ofDividerAtIndex:0];
        if (!_isFullScreen) {
            if (self.movie.url.relativePath.length != 0) {
                [self setupSize];
            }
        }
    }else{
        [self showRightSplitView];
    }
}
//显示SplitView的右视图
-(void)showRightSplitView{
    CGFloat width = player.videoSize.width;
    CGFloat height = player.videoSize.height;
    if (!_isFullScreen) {
        if (width<height) {
            [self.leftSplitView setFrameSize:NSMakeSize(self.playerView.frame.size.width+200, self.playerView.frame.size.height)];
            [self.splitView setFrameSize:NSMakeSize(self.leftSplitView.frame.size.width+self.rightSplitView.frame.size.width, self.leftSplitView.frame.size.width)];
            [self.controlBackgroundView setFrameSize:NSMakeSize(self.leftSplitView.frame.size.width+self.rightSplitView.frame.size.width, 60)];
            [kCurrentWindow setContentSize:NSMakeSize(self.splitView.frame.size.width, self.splitView.frame.size.height+self.controlBackgroundView.frame.size.height)];

        }
    }
    [self.splitView setPosition:self.view.frame.size.width - 200 ofDividerAtIndex:0];
    [self.tableView reloadData];
}
//隐藏SplitView的右视图
-(void)hideRightSplitView{
    [self.splitView setPosition:self.view.frame.size.width ofDividerAtIndex:0];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
//设置时间和进度条为0
-(void)setTimeZero{
    self.progressIndicator.doubleValue = self.progressIndicator.maxValue/self.progressIndicator.bounds.size.width*(5);
    VLCTime *tmpTime = [VLCTime timeWithNumber:[NSNumber numberWithDouble:self.progressIndicator.doubleValue]];
    [player setTime:tmpTime];
    //暂停时设置拖拽后的当前时间
    self.currentTime.stringValue = tmpTime.stringValue;
}
#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    if (kMovieUrlRelativeString.length == 0) {
        [self.playOrPauseBtn setImage:[NSImage imageNamed:@"Play"]];
        [player pause];
        return;
    }
}
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification;
{
    
    //    if (![player hasVideoOut]) {
    //        [self setTimeZero];
    //    }
    //    NSLog(@"player.audio.volume:%d",player.audio.volume);
    //    NSString *path = @"/Users/sycf_ios_13579/Downloads/imags";
    //    BOOL success = [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    //    if (!success) {
    //        NSLog(@"error");
    //    }
    //    [player saveVideoSnapshotAt:path withWidth:player.videoSize.width andHeight:player.videoSize.height];
    self.currentTime.stringValue = player.time.stringValue;
    self.progressIndicator.doubleValue = player.time.intValue;
}
- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification{
    
}
- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification{
    
}

#pragma mark - Window Resize
-(void)screenResize{
    [self hideRightSplitView];
    self.volumeStackView.hidden = kWindowSize.width<550 ? YES : NO ;
    self.toolBtn.hidden = kWindowSize.width <340 ? YES : NO ;
    self.iconVC.view.hidden = kWindowSize.height <190 ? YES : NO ;
    self.playlist.hidden = kWindowSize.height <100 ? YES : NO;
    [self setupLeftSplitView];
    
}
#pragma mark - Window will enter full Screen
-(void)willEnterFull:(NSNotification *)notification{
    _isFullScreen = YES;
    [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self.controlBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@0);
        }];
    }];
}
-(void)willExitFull:(NSNotification *)notification {
    [NSCursor unhide];
    [leftSplitTimer invalidate];
    leftSplitTimer = nil;
    [self.controlBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@60);
    }];
}
-(void)didExitFull:(NSNotification *)notification{
    _isFullScreen = NO;
    if (kMovieUrlRelativeString.length == 0) {
        return;
    }
    [self.controlBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@60);
    }];
    [self setupSize];
}
-(void)didMiniaturize:(NSNotification *)notification{
    [self pauseMovie];
}
-(void)willClose:(NSNotification *)notification{
    if (_isFullScreen) {
        return;
    }
    [self pauseMovie];
}

//暂停视频
-(void)pauseMovie{
    if (kMovieUrlRelativeString.length == 0) {
        return;
    }
    if (!player.isPlaying)   {
        return;
    }
    if ([player canPause]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [player pause];
        });
    }
}
#pragma mark - NSSplitViewDelegate
-(BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview{
    return YES;
}
-(BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex{
    return YES;
}
#pragma mark - SBViewDragFileDelegate 拖拽视频文件到窗口会经过此代理方法
-(void)sbViewGetFileURL:(NSURL *)url{
    [url startAccessingSecurityScopedResource];
    _hasAccessVideoInfo = YES;
    //筛选链接是否可用
    if (![self filterFileURL:url]) {
        //add some code to describe
        return;
    }
    slowBtn.enabled = YES;
    fastBtn.enabled = YES;
    [self hideRightSplitView];
    self.hasDraggedFiles = YES;
    [player stop];
    [self removeObservesAndNotifications];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    self.movie = nil;
    player = nil;
    [self setupPlayerWithContentOfFile:url];
    [player play];

}
//筛选链接是否可用
-(BOOL)filterFileURL:(NSURL *)url{
    NSArray *filteredURLs = [FilterVideoType filterURLs:@[url.relativePath]];
    if (filteredURLs.count>0) {
        return YES;
    }else{
        return NO;
    }
}
// MARK: 视频路径存入数据库 playlistDataAddToDatabase
-(void)playlistDataAddToDatabase {
    [SBApplication share].filePaths = [FilterVideoType filterURLs:[SBApplication share].filePaths];
    if ([SBApplication share].filePaths.count == 0) {
        return;
    }
    
    RLMResults *tmpArray = [VideoInfomation allObjectsInRealm:REALM];
    for (NSString *path in [SBApplication share].filePaths) {
        for (VideoInfomation *obj in tmpArray) {
            if ([path isEqualToString:obj.url]) {
                return;
            }
        }
        VideoInfomation *aVideoInfo = [[VideoInfomation alloc]init];
        aVideoInfo.url = path;
        aVideoInfo.title = [Tools getVideoNameWithPathExtensionByPath:path];
        URLAsset *totalTimeAsset = [[URLAsset alloc]init];
        NSURL *tmpURL = [[NSURL alloc]initFileURLWithPath:path];
        aVideoInfo.totalTime =  [totalTimeAsset getTotalTimeFromUrl:tmpURL];
        aVideoInfo.size = [Tools getVideoFileSizeInfoByPath:path];
        aVideoInfo.urlData = [tmpURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
        if (aVideoInfo.urlData == nil) {
            aVideoInfo.urlData = [tmpURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
        }
//        primaryId += 1;
//        aVideoInfo.id = primaryId;
//        NSLog(@"date:%d",primaryId);
        [REALM transactionWithBlock:^{
            [REALM addObject:aVideoInfo];
            [REALM commitWriteTransaction];
        }];
        [self.tableView reloadData];
    }
    [SBApplication share].filePaths = nil;
    
    
}
//MARK:在播放的时候添加VideoInfomation
-(void)addVideoInfo{
    if (self.movie.mediaType == VLCMediaTypeStream) {
        return;
    }
    
    if (_hasAccessVideoInfo) {
        NSString *path = [self.movie.url.relativePath stringByRemovingPercentEncoding];
        RLMResults<VideoInfomation *> *result = [VideoInfomation objectsWhere:[NSString stringWithFormat:@"title = '%@'",[Tools getVideoNameWithPathExtensionByPath:path]]];
        if (result.count>0) {
            VideoInfomation *aVideoInfo = result[0];
            if (![aVideoInfo.totalTime isEqualToString:self.movie.length.stringValue]) {
                [REALM beginWriteTransaction];
                aVideoInfo.totalTime = self.movie.length.stringValue;
                CGFloat fileSize = [[[NSFileManager defaultManager]attributesOfItemAtPath:self.movie.url.relativePath error:nil]fileSize];
                aVideoInfo.size = [NSString stringWithFormat:@"%.1fM  %ld x %ld",fileSize/(1000*1000),(long)player.videoSize.width,(long)player.videoSize.height];
                [REALM commitWriteTransaction];
                [self.tableView reloadData];
                _hasAccessVideoInfo = NO;
            }
            
        }
    }
    
    
}
// !!!: - 初始化播放列表
-(void)initPlaylistTableView{
    self.dataResults = [VideoInfomation allObjectsInRealm:REALM];
}
// !!!: NSTableViewDataSource&NSTableViewDelegate ---播放列表
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dataResults.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    SBPlaylistItem *item = (SBPlaylistItem *)[self.tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    item.delegate = self;
    
    RLMResults *result = [VideoInfomation allObjectsInRealm:REALM];
    VideoInfomation *aVideo = result[row];
    item.size.stringValue = aVideo.size;
    item.title.stringValue = aVideo.title;
    item.totalTime.stringValue = aVideo.totalTime;
    NSURL *tmpURL = [NSURL URLByResolvingBookmarkData:aVideo.urlData options:NSURLBookmarkResolutionWithSecurityScope|NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:nil];
    item.url = tmpURL;
    item.isItemAvailable = [[NSFileManager defaultManager]fileExistsAtPath:aVideo.url];
    item.wantsLayer = YES;
    item.layer.backgroundColor = [NSColor clearColor].CGColor;
    if (![self.movie.url.relativePath isEqualToString:@""]) {
        self.currentItem = item;
        NSString *itemPath = item.url.relativePath.stringByRemovingPercentEncoding;
        NSString *moviePath = self.movie.url.relativePath.stringByRemovingPercentEncoding;
        if ([itemPath isEqualTo:moviePath]) {
            item.layer.backgroundColor = [NSColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.00].CGColor;
        }
    }
    return item;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 50;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    return YES;
}

//双击NSTableView Row的响应事件
-(void)doubleClickTableViewRow:(NSTableView *)tableView{
    [SBApplication share].isDoubleClickOpen = NO;
    if (tableView.selectedRow == -1) return;
    SBPlaylistItem *item = [tableView viewAtColumn:0 row:tableView.selectedRow makeIfNecessary:YES];
    if (!item) return;
    
    [self sbViewGetFileURL:item.url];
}

#pragma mark - SBPlaylistItemDelegate 点击item右边移除按钮时，删除当前item
-(void)sbPlaylistItemDeleteCurrentItem:(SBPlaylistItem *)item{
    REALM.autorefresh = YES;
    RLMResults *tmpArray = [VideoInfomation allObjectsInRealm:REALM];
    for (VideoInfomation *aVideo in tmpArray) {
        if ([aVideo.url isEqualToString:item.url.relativePath]) {
            [REALM transactionWithBlock:^{
                [REALM deleteObject:aVideo];
                [REALM commitWriteTransaction];
                [self.tableView reloadData];
            }];
            break;
        }else{
            if (!item.isItemAvailable && [aVideo.url.lastPathComponent isEqualToString:item.url.relativePath.lastPathComponent]) {
                [REALM transactionWithBlock:^{
                    [REALM deleteObject:aVideo];
                    [REALM commitWriteTransaction];
                    [self.tableView reloadData];
                }];
            }
        }
    }
}
#pragma mark - ColorPanelViewControllerDelegate
-(void)colorPanel:(ColorPanelViewController *)colorPanelVC changeColorWithButtonColor:(CGColorRef)color{
    self.controlBackgroundView.wantsLayer = YES;
    if (color == nil) {
        NSVisualEffectMaterial material;
        if ([colorPanelVC.currentButton.image.name isEqualToString:@"MaterialDark"]) {
            material = NSVisualEffectMaterialDark;
        }else if ([colorPanelVC.currentButton.image.name isEqualToString:@"MaterialMediumLight"]){
            material = NSVisualEffectMaterialMediumLight;
        }else {
            material = NSVisualEffectMaterialUltraDark;
        }
        self.visualEffectView.material = material;
        self.controlBackgroundView.layer.backgroundColor = [NSColor clearColor].CGColor;
        [[NSUserDefaults standardUserDefaults]setObject:@(material) forKey:@"material"];
    }else{
        self.controlBackgroundView.layer.backgroundColor = color;
        NSColor *selectedColor = [NSColor colorWithCGColor:color];
        NSData *selectedColorData = [NSArchiver archivedDataWithRootObject:selectedColor];
        [[NSUserDefaults standardUserDefaults]setObject:selectedColorData forKey:@"currentColor"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}
#pragma mark - 慢放和快放
//慢速按钮
NSButton *slowBtn;
//快速按钮
NSButton *fastBtn;
- (IBAction)rewind:(NSButton *)sender {
    if (fastBtn.enabled == NO) {
        fastBtn.enabled =YES;
    }
    slowBtn = sender;
    slowBtn.enabled = YES;
    if (forwardRatio <= 0.5){
        slowBtn.enabled = NO;
        return;
    }
    forwardRatio -= 0.5;
    [player fastForwardAtRate:forwardRatio];
    [self addTipWithRate:forwardRatio];
}
- (IBAction)forward:(NSButton *)sender {
    fastBtn = sender;
    if (slowBtn.enabled == NO) {
        slowBtn.enabled = YES;
    }
    if (forwardRatio >= 2){
        fastBtn.enabled = NO;
        return;
    }
    forwardRatio += 0.5;
    [player fastForwardAtRate:forwardRatio];
    [self addTipWithRate:forwardRatio];
}
//添加快放慢放提示
-(void)addTipWithRate:(CGFloat)rate{
    SBAlertView *alertView;
    if (rate == (CGFloat)1.0) {
        alertView = [[SBAlertView alloc]initWithTitle:NSLocalizedString(@"Speed Normal", nil)];
    }else{
        alertView = [[SBAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ x %.0f%%",NSLocalizedString(@"Speed", nil),rate*100]];
    }
    alertView.label.font = [NSFont systemFontOfSize:13];
    alertView.frame = NSMakeRect(5+self.leftSplitView.frame.size.width/2-65, 5, 130, 20);
    alertView.layer.backgroundColor = [NSColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.00].CGColor;
    [self.leftSplitView addSubview:alertView];
    NSTimer *timer;
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [alertView removeFromSuperview];
            if ([timer isValid]) {
                [timer invalidate];
                timer = nil;
            }
        }];
    }
}
#pragma mark - 控制声音
//设置最小声音
- (IBAction)minVolume:(id)sender {
    self.volumeProgressIndicator.doubleValue = 0;
    [NSSound setSystemVolume:0];
}
//设置最大声音
- (IBAction)maxVolume:(NSButton *)sender {
    self.volumeProgressIndicator.doubleValue = 1.0;
    [NSSound setSystemVolume:1.0];
    
    
}
//MARK: 右上角RightSplitView 清除所有视频记录
- (IBAction)clearAll:(id)sender {
    RLMResults *result = [VideoInfomation allObjectsInRealm:REALM];
    NSAlert *alert = [[NSAlert alloc]init];
    if (result.count>0) {
        alert.messageText = NSLocalizedString(@"Warning", nil);
        alert.informativeText = NSLocalizedString(@"You will delete all video records ?", nil);
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Done", nil)];
        [alert beginSheetModalForWindow:kCurrentWindow completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertSecondButtonReturn) {
                [REALM transactionWithBlock:^{
                    [REALM deleteAllObjects];
                    [REALM commitWriteTransaction];
                    [self.tableView reloadData];
                    //显示右边RightSplitView
                    [self showRightSplitView];
                    SBAlertView *alertView = [[SBAlertView alloc]initWithTitle:NSLocalizedString(@"Deleting completed", nil)];
                    alertView.frame = NSMakeRect(5, 5, 190, 23);
                    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                        context.duration = 1;
                        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        [self.rightSplitView addSubview:alertView];
                    } completionHandler:nil];
                    [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        [alertView removeFromSuperview];
                        [self hideRightSplitView];
                    }];
                }];
            }
        }];
    }
    
}
//声音增大
-(void)volumeUp{
    if (self.volumeProgressIndicator.doubleValue>=self.volumeProgressIndicator.maxValue) {
        return;
    }
    self.volumeProgressIndicator.doubleValue += self.volumeProgressIndicator.maxValue/self.volumeProgressIndicator.bounds.size.width*(self.volumeProgressIndicator.bounds.size.width/10);
}
//声音减小
-(void)volumeDown{
    if (self.volumeProgressIndicator.doubleValue <= 0) {
        return;
    }
    self.volumeProgressIndicator.doubleValue -= self.volumeProgressIndicator.maxValue/self.volumeProgressIndicator.bounds.size.width*(self.volumeProgressIndicator.bounds.size.width/10);
}
//进度随着设置的时间间隔改变
-(void)progressWithTime:(NSInteger)time{
    VLCTime *tmpTime = [VLCTime timeWithNumber:[NSNumber numberWithDouble:player.time.intValue + time]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [player setTime:tmpTime];
        self.currentTime.stringValue = tmpTime.stringValue;
        self.progressIndicator.doubleValue = tmpTime.intValue;
    });
}
#pragma mark - 懒加载

-(NSVisualEffectView *)visualEffectView{
    if (!_visualEffectView) {
        _visualEffectView = [[NSVisualEffectView alloc]init];
        _visualEffectView.state = NSVisualEffectStateActive;
        _visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    }
    return _visualEffectView;
}
-(NSPopover *)colorPanelPopover{
    if (!_colorPanelPopover) {
        _colorPanelPopover = [[NSPopover alloc]init];
        _colorPanelPopover.behavior = NSPopoverBehaviorSemitransient;
        _colorPanelPopover.contentSize = NSMakeSize(180, 150);
        ColorPanelViewController *colorPanelVC = [[ColorPanelViewController alloc]initWithNibName:@"ColorPanelViewController" bundle:nil];
        colorPanelVC.delegate = self;
        _colorPanelPopover.contentViewController = colorPanelVC;
    }
    return _colorPanelPopover;
}
#pragma mark - 移除观察和监听
-(void)removeObservesAndNotifications{
    
    [player removeObserver:self forKeyPath:@"state"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VLCMediaPlayerStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VLCMediaPlayerTimeChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VLCMediaPlayerTitleChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VLCMediaPlayerChapterChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
}


@end

































