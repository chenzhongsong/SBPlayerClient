//
//  ColorPanelViewController.h
//  SBPlayer
//
//  Created by sycf_ios on 2017/3/16.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ColorPanelViewController;
@protocol ColorPanelViewControllerDelegate <NSObject>

/**
 点击获取颜色板上对应的色彩

 @param colorPanelVC 色彩板
 @param color 颜色
 */
-(void)colorPanel:(ColorPanelViewController *)colorPanelVC changeColorWithButtonColor:(CGColorRef)color;
@end
@interface ColorPanelViewController : NSViewController
@property (weak) IBOutlet NSButton *materialDark;
@property (weak) IBOutlet NSButton *materialMediumLight;
@property (weak) IBOutlet NSButton *materialUltraDark;

@property (weak) IBOutlet NSButton *colorOne;
@property (weak) IBOutlet NSButton *colorTwo;
@property (weak) IBOutlet NSButton *colorThree;
@property (weak) IBOutlet NSButton *colorFour;
@property (weak) IBOutlet NSButton *colorFive;
@property (weak) IBOutlet NSButton *colorSix;
@property (weak) IBOutlet NSButton *colorSeven;
@property (weak) IBOutlet NSButton *colorEight;

@property (nonatomic,weak) id<ColorPanelViewControllerDelegate> delegate;
@property (nonatomic,strong) NSButton *currentButton;
@end
