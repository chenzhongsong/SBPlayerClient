//
//  FilterVideoType.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/2/13.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "FilterVideoType.h"

@implementation FilterVideoType
//过滤非视频或者音频格式的文件
+(NSArray *)filterURLs:(NSArray *)urls{
    NSMutableArray *mutArr = [NSMutableArray array];
    for (NSString *url in urls) {
        NSString *file = url; // path to some file
        CFStringRef fileExtension = (__bridge CFStringRef) [file pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) NSLog(@"这是图片类");
//        else if (UTTypeConformsTo(fileUTI, kUTTypeText)) NSLog(@"这是文本类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeApplication)) NSLog(@"这是应用程序类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeGNUZipArchive)) NSLog(@"这是压缩文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeSpreadsheet)) NSLog(@"这是Spreadsheet文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeVCard)) NSLog(@"这是vCard文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeInternetLocation)) NSLog(@"这是InternetLocation文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeInkText)) NSLog(@"这是InternetLocation文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeFolder)) NSLog(@"这是kUTTypeFolder文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeHTML)) NSLog(@"这是kUTTypeHTML文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeSourceCode)) NSLog(@"这是kUTTypeSourceCode文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeScript)) NSLog(@"这是kUTTypeScript文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeJSON)) NSLog(@"这是kUTTypeJSON文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypePDF)) NSLog(@"这是kUTTypePDF文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeBzip2Archive)) NSLog(@"这是kUTTypeBzip2Archive文件类");
        else if (UTTypeConformsTo(fileUTI, kUTTypeZipArchive)) NSLog(@"这是kUTTypeZipArchive文件类");
        else{
            [mutArr addObject:url];
        }
        
        CFRelease(fileUTI);
    }
    return mutArr;
}
@end
