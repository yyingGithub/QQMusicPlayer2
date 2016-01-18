//
//  SYBlendLabel.m
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/15.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import "SYBlendLabel.h"

@implementation SYBlendLabel

//更改label的进度值
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    // 重新绘图
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    
    //1. 调用父类 --> 绘制文字
    [super drawRect:rect];
    
    //3. 设置进度
    rect.size.width *= self.progress;
    
    //2. 设置颜色
    [[UIColor greenColor] set];

    //CGBlendMode: 设置混合模式
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}

@end
