//
//  ISLogFileManager.h
//  CloudLink Share
//
//  Created by mac on 2020/5/10.
//  Copyright © 2020 zhu dongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ISLogFileManager : NSObject


/**
 获取日志的压缩文件

 @return 压缩文件的data值
 */
+ (NSData *)getISLog;

//+ (NSData *)getISLogWithDateStr:(NSString *)dateStr images:(NSArray<UIImage *> *)images
//2.0 邮件上传用的
+ (NSData *)getISLogWithDateArray:(NSArray *)dateArray images:(NSArray<UIImage *> *)images sdkLogPathArray:(NSArray *)pathArray;

//3.0 接口上传用的
+ (NSString *)getLogPathThreeVersionWithDateArray:(NSArray *)dateArray images:(NSArray<UIImage *> *)images sdkLogPathArray:(NSArray *)pathArray;
/**
 清除压缩日志文件，清理图片，清理txt文件
 @return 是否成功
 */
+ (BOOL)clearZip;
/*
 用户输入的文字信息写入本地txt文件中
 */
+ (void)writeToTXTFileWithString:(NSString *)textStr;



@end

