//
//  SYPlayerMananger.h
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/12.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYMusicModel;

@interface SYPlayerMananger : NSObject

//当前时间
@property (nonatomic)NSTimeInterval currentTime;
//总时长 歌曲总时长不需要修改，故设为readonly属性
@property (nonatomic, readonly) NSTimeInterval duration;
//单例创建方法
+ (instancetype) sharedPlayerManager;

//传入模型来播放对应的音乐文件
-(void)playMusicWithModel:(SYMusicModel *)model didComplete:(void(^)())complete;

//暂停播放
-(void)pause;

@end
