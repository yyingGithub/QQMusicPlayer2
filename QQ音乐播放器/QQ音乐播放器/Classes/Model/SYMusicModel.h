//
//  SYMusicModel.h
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/12.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 定义类型枚举*/
typedef enum {
    HMMusicTypeLocal,
    HMMusicTypeRomote
    
} SYMusicType;

@interface SYMusicModel : NSObject
/// 图片
@property (nonatomic, copy) NSString *image;
/// 歌词
@property (nonatomic, copy) NSString *lrc;
/// 音乐
@property (nonatomic, copy) NSString *mp3;
/// 名称
@property (nonatomic, copy) NSString *name;
/// 歌手
@property (nonatomic, copy) NSString *singer;
/// 专辑
@property (nonatomic, copy) NSString *album;
/// 类型 远程 /本地
@property (nonatomic, assign) SYMusicType type;

@end
