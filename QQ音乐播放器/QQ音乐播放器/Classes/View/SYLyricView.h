//
//  SYLyricView.h
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/16.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYLyricView;

@protocol SYLyricViewDelegate <NSObject>

@optional
- (void) lyricView:(SYLyricView *) lyricView hScrollViewScrollProgress:(CGFloat) progress;

@end
@interface SYLyricView : UIView
@property (nonatomic, weak) id<SYLyricViewDelegate> delegate;

/// 歌词数组
@property (nonatomic, strong) NSArray *lyrics;

/// 每一句歌词高度
@property (nonatomic, assign) CGFloat rowHeight;

/// 当前第几行
@property (nonatomic, assign) NSInteger currentLyricIndex;

@property (nonatomic, assign) CGFloat rowProgress;

@end
