//
//  CommonHeader.h
//  SBPlayer
//
//  Created by sycf_ios on 2017/3/15.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h
//MAC 工具栏高度
#define kToolBarHeight (23)
//可见屏幕高度
#define kScreenHeight [NSScreen mainScreen].visibleFrame.size.height
//可见屏幕宽度
#define kScreenWidth  [NSScreen mainScreen].visibleFrame.size.width
//窗口尺寸
#define kWindowSize (self.view.window.frame.size)
//movie url string
#define kMovieUrlRelativeString (self.movie.url.relativeString)
//播放器的size
#define kPlayerSize (self.playerView.frame.size)
//当前window
#define kCurrentWindow (self.view.window)
#endif /* CommonHeader_h */
