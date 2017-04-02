//
//  SBOpenURLWindowController.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/3/8.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "SBOpenURLWindowController.h"
#import "ViewController.h"
#import "AppDelegate.h"
@interface SBOpenURLWindowController ()
@property (weak) IBOutlet NSTextField *urlField;

@end

@implementation SBOpenURLWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window standardWindowButton:NSWindowMiniaturizeButton].hidden = YES;
    [self.window standardWindowButton:NSWindowZoomButton].hidden = YES;
}
- (IBAction)openURLAction:(id)sender {
    if (self.urlField.stringValue.length > 0) {
        AppDelegate *delgate = [NSApp delegate];
        ViewController *rootVc = (ViewController *)delgate.mainWindowController.contentViewController;
        [rootVc sbViewGetFileURL:[NSURL URLWithString:self.urlField.stringValue]];
    }
    [self close];
}
-(BOOL)acceptsFirstResponder{
    return YES;
}

@end
