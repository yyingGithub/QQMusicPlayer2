//
//  SYLyricTool.h
//  QQ音乐播放器
//
//  Created by 申颖 on 16/1/13.
//  Copyright © 2016年 Ying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYLyricTool : NSObject

//根据文件名来解析歌词数据，并返回数据
+ (NSArray *)parserLyricWithName: (NSString *)lycName;

@end
