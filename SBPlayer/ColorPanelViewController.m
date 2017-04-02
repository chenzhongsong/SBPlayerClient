//
//  ColorPanelViewController.m
//  SBPlayer
//
//  Created by sycf_ios on 2017/3/16.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import "ColorPanelViewController.h"

@interface ColorPanelViewController ()

@end

@implementation ColorPanelViewController
-(void)awakeFromNib{
    [super awakeFromNib];
        [self setupColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)setupColor{
    //setup normal color
    //在此处可以定制自己界面想要的颜色,更好颜色值就可以
    [self setButton:self.colorOne withColor:[NSColor redColor]];
    [self setButton:self.colorTwo withColor:[NSColor greenColor]];
    [self setButton:self.colorThree withColor:[NSColor blueColor]];
    [self setButton:self.colorFour withColor:[NSColor blackColor]];
    [self setButton:self.colorFive withColor:[NSColor purpleColor]];
    [self setButton:self.colorSix withColor:[NSColor underPageBackgroundColor]];
    [self setButton:self.colorSeven withColor:[NSColor orangeColor]];
    [self setButton:self.colorEight withColor:[NSColor brownColor]];
}
-(void)setButton:(NSButton *)button withColor:(NSColor *)color{
    button.wantsLayer = YES;
    button.bordered = NO;
    button.layer.backgroundColor = color.CGColor;
}
- (IBAction)clickedColorPanel:(id)sender {
    NSButton *button = (NSButton *)sender;
    self.currentButton = button;
    if ([self.delegate respondsToSelector:@selector(colorPanel:changeColorWithButtonColor:)]) {
        [self.delegate colorPanel:self changeColorWithButtonColor:button.layer.backgroundColor];
    }
}

@end
