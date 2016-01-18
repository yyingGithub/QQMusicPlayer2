//
//  ViewController.m
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/11.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import "ViewController.h"
#import "SYPlayerMananger.h"
#import "SYMusicModel.h"
#import "SYLyricTool.h"
#import "SYLyricModel.h"
#import "SYBlendLabel.h"
#import "SYLyricView.h"

@interface ViewController ()<SYLyricViewDelegate>
//切换前一个首歌按钮
@property (weak, nonatomic) IBOutlet UIButton *preButton;
//播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playerButton;
//后一首歌的按钮
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
//进度条
@property (weak, nonatomic) IBOutlet UISlider *slider;
//歌曲总时长
@property (weak, nonatomic) IBOutlet UILabel *durationTime;
//当前播放到的时长
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
//竖直方向的图片
@property (weak, nonatomic) IBOutlet UIImageView *vImageView;
//歌手名
@property (weak, nonatomic) IBOutlet UILabel *singerName;
//歌词
@property (strong, nonatomic) IBOutletCollection(SYBlendLabel) NSArray *lyricLabel;
//专辑名
@property (weak, nonatomic) IBOutlet UILabel *blumbLabel;
//水平方向的图片
@property (weak, nonatomic) IBOutlet UIImageView *hImageView;
//背景图
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
//竖屏中间的view
@property (weak, nonatomic) IBOutlet UIView *vCenterView;
//歌词View
@property (weak, nonatomic) IBOutlet SYLyricView *lyricView;

//当前歌曲的索引
@property (nonatomic, assign) NSInteger currentSongIndex;
//音乐数据数组
@property (nonatomic, strong) NSArray *songArray;
//计时器
@property (nonatomic, strong) NSTimer *timer;
//歌词数据数组
@property (nonatomic, strong) NSArray *lyricArray;
//当前歌词索引
@property (nonatomic, assign) NSInteger currentLyricIndex;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建工具栏
    UIToolbar *bar = [[UIToolbar alloc]init];
    bar.barStyle = UIBarStyleBlack;
    [self.bgImageView addSubview:bar];
    
//    [bar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.bgImageView);
//    }];
    //使用宏定义
    [bar makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgImageView);
    }];
    
    self.navigationController.navigationBar.barStyle =  UIBarStyleBlack;
    
    //一开始就播放
    [self changeMusic];
    
    //3. 为了一开始图像变圆. 强制更新约束
    [self.view layoutIfNeeded];
    
    //注册通知
    self.lyricView.delegate = self;
}

#pragma mark 代理方法 滑动隐藏垂直中间视图
- (void)lyricView:(SYLyricView *)lyricView hScrollViewScrollProgress:(CGFloat)progress
{
    //透明度
    self.vCenterView.alpha = 1- progress;
}

#pragma mark 当子控件布局完成的时候
- (void) viewDidLayoutSubviews{

    //设置中间的图像为圆形
    self.vImageView.layer.cornerRadius = self.vImageView.bounds.size.width * 0.5;
    self.vImageView.layer.masksToBounds = YES;
}

#pragma mark 懒加载  音乐数据懒加载
-(NSArray *)songArray{

    if (_songArray == nil) {
        #pragma mark 使用框架MJExtension来解析数据
        _songArray = [SYMusicModel objectArrayWithFilename:@"mlist.plist"];
        NSLog(@"%ld",_songArray.count);
    }
    return _songArray;
}

#pragma mark 切换前一首
- (IBAction)preBtnClick:(id)sender {
    
    //索引自增
    if (self.currentSongIndex == 0) {
        //若是第一首，下一次就播放最后首歌
        self.currentSongIndex = self.songArray.count - 1;
    }else {
        
        self.currentSongIndex --;
    }
    //切换歌曲
    [self changeMusic];
}

#pragma mark 播放当前歌曲
- (IBAction)playerBtnClick {
    //获取单例类
    SYPlayerMananger *manager = [SYPlayerMananger sharedPlayerManager];
    NSLog(@"manager: %@",manager);
    //若按钮显示的是暂停图像，应该点击暂停
    //判断按钮状态
    if (self.playerButton.selected) {
        //暂停按钮
        [manager pause];
        //若暂停，计时器就失效
        [self stopUpdate];
    }else{
    
        //若按钮显示的是播放按钮，应该点击播放
        //调用播放音乐的方法
        [manager playMusicWithModel:self.songArray[self.currentSongIndex]didComplete:^{
            // 播放下一曲
            [self nextBtnClick];
        }];
            //若播放，就开始计时器
            [self startUpdate];
    }
    //切换按钮状态
    self.playerButton.selected = !self.playerButton.selected;
}

#pragma mark 切换下一首歌曲
- (IBAction)nextBtnClick {
    //索引自增
    if (self.currentSongIndex == self.songArray.count - 1) {
        //若最后一曲，下一次就播放第一首歌
        self.currentSongIndex = 0;
    }else {
    
        self.currentSongIndex ++;
    }
    //切换歌曲
    [self changeMusic];
    
}

#pragma mark 切换歌曲
-(void)changeMusic{

    //计时器先停止  注意代码书写顺序
    [self stopUpdate];
    //头像归原位
    self.vImageView.transform = CGAffineTransformMakeRotation(0);
    
    //当前歌词索引归零  若歌词索引不归零，则在切换到下首歌时，会引起程序崩溃，数组会越界
    self.currentLyricIndex = 0;

  //获取模型数据
    SYMusicModel *musicModel = self.songArray[self.currentSongIndex];
    //加载歌词信息
    self.lyricArray = [SYLyricTool parserLyricWithName:musicModel.lrc];
    //赋值
    self.lyricView.lyrics = self.lyricArray;
    //切换界面相关信息
    //导航栏文字
    self.title = musicModel.name;
    //歌手
    self.singerName.text = musicModel.singer;
    //专辑
    self.blumbLabel.text = musicModel.album;
    //获取图片
    UIImage *image = [UIImage imageNamed:musicModel.image];
    //背景图
    self.bgImageView.image = image;
    //竖屏中间图像
    self.vImageView.image = image;
    //横屏中间图像
    self.hImageView.image = image;
    //调用按钮播放
    self.playerButton.selected = NO;
    
    [self playerBtnClick];
    
    //获取歌曲总时长
    SYPlayerMananger *manager = [SYPlayerMananger sharedPlayerManager];
    self.durationTime.text = [self stringWithTime:manager.duration];
    
}

#pragma mark 转换成时间字符串的方法
- (NSString *)stringWithTime:(NSTimeInterval)time{
     //获取分钟
    NSInteger min = time / 60;
    //获取秒数
    NSInteger sec = (NSInteger)time % 60;
    
    return [NSString stringWithFormat:@"%02zd:%02zd",min,sec];
    
}

#pragma mark 计算歌曲走的时间
- (IBAction)sliderAction:(id)sender {
    //获取manager
    SYPlayerMananger *manager = [SYPlayerMananger sharedPlayerManager];
    //更改播放器的当前时间来更改进度
    manager.currentTime = self.slider.value * manager.duration;
}

#pragma mark 计时器更新方法
-(void)startUpdate{

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInfo) userInfo:nil repeats:YES];
}

#pragma mark 计时器停止更新的方法
-(void)stopUpdate{
    //让计时器失效
    [self.timer invalidate];
    //置空nil
    self.timer = nil;
}

#pragma mark 计时器绑定的更新信息的方法
- (void)updateInfo
{
    SYPlayerMananger *manager = [SYPlayerMananger sharedPlayerManager];
    //1. 歌曲当前时间
    self.currentTime.text = [self stringWithTime:manager.currentTime];
    //2. 滑块的值
    self.slider.value = manager.currentTime / manager.duration;
    //3. 竖屏中间图像的旋转
    self.vImageView.transform = CGAffineTransformRotate(self.vImageView.transform, M_PI_4 * 0.1);
    //4. 歌词
    [self updateLyric];
}

#pragma mark 更新歌词信息
-(void)updateLyric{

    //获取音乐工具类
    SYPlayerMananger *manager = [SYPlayerMananger sharedPlayerManager];
    //获取当前索引指向的歌词模型
    //NSLog(@"%@",self.lyricArray);
    SYLyricModel *currentModel = self.lyricArray[self.currentLyricIndex];
    
    //获取下一行歌词的模型
    SYLyricModel *nextModel = [[SYLyricModel alloc]init];
    
    //此处不判断，程序也会崩溃
    if (self.currentLyricIndex == self.lyricArray.count - 1) {
        nextModel.beginTime = currentModel.beginTime;
    } else {
        nextModel = self.lyricArray[self.currentLyricIndex + 1];
    }
    
    //比较时间
    // 比如后退: 当前播放器15S, 但是当前获取是23S, 需要回退歌词  若不判断&&后面的条件程序会崩溃
    if (manager.currentTime < currentModel.beginTime && self.currentLyricIndex != 0) {
        self.currentLyricIndex --;
        [self updateLyric];
        
        //比如快进: 当前播放器50S, 但是当前获取是19S, 需要快进歌词  若不判断&&后面的条件程序会崩溃
    } else if (manager.currentTime >= nextModel.beginTime && self.currentLyricIndex != self.lyricArray.count - 1){
        self.currentLyricIndex ++;
        [self updateLyric];
    }
    
    //4.播放器的时间大于等于当前时间, 小于下一句歌词的时间, 就设置显示此句歌词,那么就可以显示歌词了
    [self.lyricLabel setValue:currentModel.content forKey:@"text"];
    
    //改变文字颜色
    //进度 = (播放器当前时间 - 当前歌词的开始时间) / (下一句歌词的开始时间 - 当前歌词的开始时间)
    CGFloat lyricProgress = (manager.currentTime - currentModel.beginTime) / (nextModel.beginTime - currentModel.beginTime);
    //使用forin赋值，或者是使用KVC进行赋值
    [self.lyricLabel setValue:@(lyricProgress) forKey:@"progress"];
    
    //设置歌词视图改变
    self.lyricView.currentLyricIndex = self.currentLyricIndex;
    
    //设置歌词视图变色
    self.lyricView.rowProgress = lyricProgress;

}
@end
