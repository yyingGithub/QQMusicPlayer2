//
//  SYLyricTool.m
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/13.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import "SYLyricTool.h"
#import "SYLyricModel.h"

@implementation SYLyricTool
//根据文件名来解析歌词数据，并返回数据
+(NSArray *)parserLyricWithName: (NSString *)lycName{

    //加载本地歌词文件
    NSString *path = [[NSBundle mainBundle]pathForResource:lycName ofType:nil];
    
    NSError *error;
    NSString *lyricStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
   // NSLog(@"%@",lyricStr);
    //用于调试使用
    if (error) {
        NSLog(@"error: %@",error);
    }
    //创建歌词数组  componentsSeparatedByString：截取字符串
    NSArray *lyricArray = [lyricStr componentsSeparatedByString:@"\n"];
    NSLog(@"%@",lyricArray);
    //歌词截取
    //[04:19.00][03:40.00][01:44.00]我的牵挂我的渴望 直至以后
    //截取成
    //[04:19.00]我的牵挂我的渴望 直至以后
    //[03:40.00]我的牵挂我的渴望 直至以后
    //[01:44.00]我的牵挂我的渴望 直至以后
    //创建临时数组，用来盛放歌词模型类
    NSMutableArray *tempArray = [NSMutableArray array];
    //遍历数组
    for (NSString *lyricStr in lyricArray) {
        // 创建正则表达式
        // [0-9]{2}  或者  \d = [0-9]
        // 单"\"是转义符, 所以如果不希望转义, 需要在加一个"\"
        //NSString *pattern = @"\\[[0-9]d{2}:[0-9]d{2}.[0-9]d{2}\\]";
        NSString *pattern = @"\\[\\d{2}:\\d{2}.\\d{2}\\]";
        //NSRegularExpressionCaseInsensitive: 忽略大小写
        NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
       // NSLog(@"%@",regular);
        //匹配
        NSArray *resultArr = [regular matchesInString:lyricStr options:NSMatchingReportCompletion range:NSMakeRange(0, lyricStr.length)];
        
        //获取歌词内容
        //获取匹配到的最后一个结果
        NSTextCheckingResult *lastResult = [resultArr lastObject];
        NSLog(@"lastResult: %@",lastResult);
        //截取字符串：index  最后一个结果的location ＋ length
        NSString *contentStr = [lyricStr substringFromIndex:lastResult.range.location + lastResult.range.length];
        //打印歌词内容
        NSLog(@"contentStr: %@",contentStr);
        
        //获取歌词时间  ---> 遍历匹配结果
        for (NSTextCheckingResult *result in resultArr) {
            //获取每一个结果值
            NSString *timeStr = [lyricStr substringWithRange:result.range];
            //打印歌词的时间
            NSLog(@"timeStr: %@",timeStr);
            //时间字符串转换成NSTimeInterver
            //创建日期格式化类
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"[mm:ss.SS]";
            //时间转换  将时间timeStr字符串转换成 NSTimeInterval
            NSDate *currentDate = [formatter dateFromString:timeStr];
            NSDate *beginDate = [formatter dateFromString:@"[00:00.00]"];
            //使用当前时间和初始化时间比较，得出秒数的差值
            NSTimeInterval time = [currentDate timeIntervalSinceDate:beginDate];
            NSLog(@"time: %f",time);
            //创建歌词模型类
            SYLyricModel *lyricModel = [[SYLyricModel alloc]init];
            lyricModel.beginTime = time;
            lyricModel.content = contentStr;
            [tempArray addObject:lyricModel];
        }
    }
    //所有数据加载完成之后进行排序
    //sortUsingDescriptors : 可变数组的排序方法, 可以传多个排序条件
    //NSSortDescriptor : 排序描述类 ,需要告诉按照那个key, 升序还是降序
    //ascending: 是否升序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES];
    //不排序的话，时间不按顺序来
    [tempArray sortUsingDescriptors:@[sort]];
    //再把时间打印一下 用于调试
    for (SYLyricModel * model in tempArray) {
        NSLog(@"time : %f",model.beginTime);
    }
    return tempArray;
}

@end
