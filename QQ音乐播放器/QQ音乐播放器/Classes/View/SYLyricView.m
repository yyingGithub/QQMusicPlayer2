//
//  SYLyricView.m
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/16.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import "SYLyricView.h"
#import "SYBlendLabel.h"
#import "SYLyricModel.h"

@interface SYLyricView ()<UIScrollViewDelegate>
{
    NSInteger _currentLyricIndex;
}
@property (nonatomic, weak) UIScrollView *hScrollView;

@property (nonatomic, weak) UIScrollView *vScrollView;

@end

@implementation SYLyricView


- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

//歌词侧滑：一种使用scrollView来做；第二种：使用手势来做
//水平scrollView嵌套了垂直的scrollView
- (void) setupUI{
    //  1.创建子控件  水平scrollView
    UIScrollView *hScrollView = [[UIScrollView alloc] init];
    [self addSubview:hScrollView];
    self.hScrollView = hScrollView;
    
    //垂直scrollView
    UIScrollView *vScrollView = [[UIScrollView alloc] init];
    [hScrollView addSubview:vScrollView];  //在水平scrollview中嵌套垂直的scrollView
    self.vScrollView = vScrollView;
    
    //2. 设置约束
    [hScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //  设置只要设置一次属性
    hScrollView.showsHorizontalScrollIndicator = NO;
    hScrollView.pagingEnabled = YES;
    hScrollView.delegate = self;
    self.vScrollView.delegate = self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //垂直方向的scrollView的布局
    [self.vScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.width.equalTo(self);
        make.left.equalTo(self.bounds.size.width);
    }];
    
    //设置水平scrollview的contentSize的大小
    self.hScrollView.contentSize = CGSizeMake(self.hScrollView.bounds.size.width * 2, self.hScrollView.bounds.size.height);
    
    // 增加视图的可滚动区域
    CGFloat top = (self.bounds.size.height - self.rowHeight) / 2.0;
    self.vScrollView.contentInset = UIEdgeInsetsMake(top, 0, top, 0);
}

#pragma mark ScrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.hScrollView) {
        
        if ([self.delegate respondsToSelector:@selector(lyricView:hScrollViewScrollProgress:)]) {
            
            CGFloat progress = scrollView.contentOffset.x / self.bounds.size.width;
            
            [self.delegate lyricView:self hScrollViewScrollProgress:progress];
        }
    }
}

//重写当前歌词索引
- (void)setCurrentLyricIndex:(NSInteger)currentLyricIndex{
    if (_currentLyricIndex != currentLyricIndex || currentLyricIndex == 0) {
        
        SYBlendLabel *label = self.vScrollView.subviews[self.currentLyricIndex];
        //将绿色的清空
        label.progress = 0;
        
        _currentLyricIndex = currentLyricIndex;
        
        CGFloat offsetY = currentLyricIndex * self.rowHeight - self.vScrollView.contentInset.top;
        
        self.vScrollView.contentOffset = CGPointMake(0, offsetY);
    }
    
}

//播放进度
- (void)setRowProgress:(CGFloat)rowProgress{
    _rowProgress = rowProgress;
    SYBlendLabel *label = self.vScrollView.subviews[self.currentLyricIndex];
    label.progress = rowProgress;
}

//重写歌词数组的Lyrics的set方法
- (void)setLyrics:(NSArray *)lyrics{
    
    _lyrics = lyrics;
    
    // 清空之前的Label
    [self.vScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //根据歌词的数量，创建label
    for (int i = 0; i < lyrics.count; i++) {
        SYLyricModel *lyricModel = lyrics[i];
        
        //创建歌词label
        SYBlendLabel *label = [[SYBlendLabel alloc]init];
        label.textColor = [UIColor whiteColor];
        label.text = lyricModel.content;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [self.vScrollView addSubview:label];
    
            [label makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.height.equalTo(self.rowHeight);
                make.top.equalTo(i * self.rowHeight);
                make.width.equalTo(self.bounds.size.width);
            }];
     
    }
    
    self.vScrollView.contentSize = CGSizeMake(0, self.rowHeight * lyrics.count);
}

- (NSInteger)currentLyricIndex{
    
    if (_currentLyricIndex <= 0) {
        _currentLyricIndex = 0;
    }else if(_currentLyricIndex >= self.vScrollView.subviews.count - 1){
        _currentLyricIndex = self.vScrollView.subviews.count - 1;
    }
    return _currentLyricIndex;
}

//每行歌词的高度是44
- (CGFloat)rowHeight{
    return 44;
}

@end
