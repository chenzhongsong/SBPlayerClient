//
//  NSView+Moveable.m
//  SBPlayerClient
//
//  Created by Mac on 2017/1/30.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "NSView+Moveable.h"

@implementation NSView (Moveable)
-(BOOL)acceptsFirstResponder{
    return  YES;
}
-(BOOL)mouseDownCanMoveWindow{
    return YES;
}
@end

@implementation NSTableView (Moveable)

-(BOOL)mouseDownCanMoveWindow{
    return YES;
}

@end
@implementation NSImageView (Moveable)

-(BOOL)mouseDownCanMoveWindow{
    return YES;
}

@end
