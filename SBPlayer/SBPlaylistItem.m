//
//  SBPlaylistItem.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/2/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "SBPlaylistItem.h"
#import <Masonry.h>
#define BLACKCOLOR [NSColor blackColor]
@interface SBPlaylistItem (){
    //视频资产
    URLAsset *_asset;
    //底部白线
    NSView *_whiteLine;
}
@property (nonatomic,strong) NSImageView *disableView;

@end
@implementation SBPlaylistItem
-(void)awakeFromNib{
    //添加白线
    [self addWhiteLine];
}
-(void)addWhiteLine{
    _whiteLine = [[NSView alloc]init];
    _whiteLine.wantsLayer = YES;
    _whiteLine.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    [self addSubview:_whiteLine];
    //添加白线的约束
    [self addWhiteLineConstraint];
}
-(void)addWhiteLineConstraint{
    [_whiteLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(@1);
    }];
    [_whiteLine setNeedsLayout:YES];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [_whiteLine layoutSubtreeIfNeeded];
    self.title.usesSingleLineMode = NO;
    self.title.cell.wraps = YES;
    self.title.cell.scrollable = NO;
    self.title.maximumNumberOfLines = 2;
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]initWithRect:dirtyRect options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    //设置删除按钮
    self.closeBtn.hidden = YES;
    self.closeBtn.target = self;
    self.closeBtn.action = @selector(removeCurrentItem:);
    [self addHandleItemPathIsAvaliable];
}
-(void)addHandleItemPathIsAvaliable{
    if (!self.isItemAvailable) {
        [self.disableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.height.mas_equalTo(@24);
        }];
    }else{
        if (_disableView) {
            [_disableView removeFromSuperview];
        }
    }
}
//失效视图
-(NSImageView *)disableView{
    if (!_disableView) {
        _disableView = [[NSImageView alloc]init];
        _disableView.image = [NSImage imageNamed:@"notplay"];
        [self addSubview:_disableView];
    }
    return _disableView;
}
//删除NSTableView当前Item
-(void)removeCurrentItem:(NSButton *)button {
    if ([self.delegate respondsToSelector:@selector(sbPlaylistItemDeleteCurrentItem:)]) {
        [self.delegate sbPlaylistItemDeleteCurrentItem:self];
    }
}
//鼠标进入
-(void)mouseEntered:(NSEvent *)event{
    self.closeBtn.hidden = NO;
}
//鼠标移出
-(void)mouseExited:(NSEvent *)event{
    self.closeBtn.hidden = YES;
}

@end
