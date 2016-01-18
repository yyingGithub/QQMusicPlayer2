//
//  SYPlayerMananger.m
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/12.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import "SYPlayerMananger.h"
#import <AVFoundation/AVFoundation.h>
#import "SYMusicModel.h"

@interface SYPlayerMananger()<AVAudioPlayerDelegate>

//音乐播放器
@property(nonatomic,strong)AVAudioPlayer *player;
//记录当前的模型
@property (nonatomic,strong)SYMusicModel *currentModel;
// 定义了一个block
@property (nonatomic, copy) void(^complete)();

@end

@implementation SYPlayerMananger

//单例创建方法
static SYPlayerMananger *_playerManager;

+ (instancetype) sharedPlayerManager {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _playerManager = [[SYPlayerMananger alloc]init];
    });
    return _playerManager;
}

//代理方法调用
-(void)playMusicWithModel:(SYMusicModel *)model didComplete:(void(^)())complete
{
    NSLog(@"%@",model.mp3);
    //若是同一个model，则不必加载
    if (self.currentModel != model) {
        //获取url地址
        NSURL *url = [[NSBundle mainBundle]URLForResource:model.mp3 withExtension:nil];
        NSLog(@"%@",url);
        //创建播放器
        NSError *error;
        self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //用于调试
        if (error) {
            NSLog(@"error: %@",error);
        }
        //记录当前选中的模型
        self.currentModel = model;
        
        //block
        self.complete = complete;
        
        //设置代理
        self.player.delegate = self;
    }
    //播放音乐
    [self.player play];
    
}

//暂停播放
-(void)pause{

    [self.player pause];
}

#pragma mark 重写属性的get方法，返回当前时间
- (NSTimeInterval) currentTime {

    return self.player.currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    self.player.currentTime = currentTime;
}


#pragma mark 重写属性的get方法，返回歌曲总时间
- (NSTimeInterval) duration {

    return self.player.duration;
}

#pragma mark AVAudioPlayer的代理方法  使用代理方法自动播放下一首
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // 调用block
    self.complete();
}

@end
