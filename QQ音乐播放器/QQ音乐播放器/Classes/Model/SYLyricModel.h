//
//  SYLyricModel.h
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/12.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYLyricModel : NSObject

/** 歌词的开始时间*/
@property (nonatomic) NSTimeInterval beginTime;

/** 歌词的内容*/
@property (nonatomic, copy) NSString *content;

@end
