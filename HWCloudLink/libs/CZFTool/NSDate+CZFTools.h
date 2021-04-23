//
//  NSDate+CZFTools.h
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CZFTools)


/**
 *  根据一个过去的时间与现在时间做对比，获取间隔多少分钟
 *
 *  @param oldDate 过去时间
 *
 *  @return 差值多少秒
 */
+ (long)getMinuteByOldDateBetweenNowDate:(NSDate *)oldDate;


/**
 *  NSString转换成NSDate，根据 自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"
 */
+ (NSDate *)dateFromString:(NSString *)dateString andFormatterString:(NSString *)strFormater andTimeZone:(NSTimeZone *)timeZone;


/**
 *  NSDate转换成NSString，根据 自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"  忽略时区的转换
 */
+ (NSString *)stringIgnoreZoneFromDate:(NSDate *)date andFormatterString:(NSString *)strFormater;


/**
 *  根据日期获取对应的星期几
 *
 *  @param strInputDate 输入日期字符串
 *
 *  @return 星期几
 */
+ (NSString*)weekdayStringFromDate:(NSString *)strInputDate;


/**
 格式化为可读的时间显示字符串
 
 @param date 时间
 @return 可读时间字符串
 */
+ (NSString *)stringNormalReadWithDate:(NSDate *)date;

/**
 格式化为可读的时间显示字符串
 
 @param dateStr 时间  yyyy-MM-dd HH:mm:ss
 @return 可读时间字符串 (09:12 , 12/13 09:12, 2017/12/13 09:12)
 */
+ (NSString *)stringNormalType2ReadWithDate:(NSString *)dateStr;


/**
 获取日期的年月日时分秒毫秒周
 
 @param date 日期
 @return 年月日时分秒毫秒周数组
 */
+ (NSArray *)getDateYearMonthDayWithDate:(NSDate *)date;

/**
 获取日期的年月日时分秒毫秒周
 
 @param dateStr 日期
 @return 年月日时分秒毫秒数组
 */
+ (NSArray *)getDateYearMonthDayWithDatestandrdStr:(NSString *)dateStr;


/**
 *  NSDate转换成NSString，根据 自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"
 */
+ (NSString *)stringFromDate:(NSDate *)date andFormatterString:(NSString *)strFormater;


/**
 *  获取时间字符串，从当前某个时间开始算起，正数表示向后推算几天，负数表示向前推算几天
 *  return Date
 */
+ (NSDate *)DateToStringForOtherDateFromNowDays:(NSInteger)dayValue andOriginalDate:(NSDate *)originDate;


/**
 *  获取时间字符串，从某个日期算起，正数表示向后推算几小时，负数表示向前推算几小时
 *  自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"
 */
+ (NSString *)DateToStringForOtherHourFromNowHours:(NSInteger)dayValue andFormatterString:(NSString *)strFormater andDate:(NSDate *)date;

/**
 格式化数据发布时间
 
 @param oldDate oldDate
 */
+ (NSString *)formattingTimeCanEasyRead:(NSDate *)oldDate;


/**
 获取指定时间的前一个月或后一个月的时间
 
 @param date 指定时间
 @param month 正数便是后一个月，负数表示前一月
 @return 结果日期
 */
+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month;



/**
 获取当月的天数
 
 @param date 计算时期
 @return 返回天数
 */
+ (NSInteger)getNumberOfDaysInMonthWithDate:(NSDate *)date;

/// 可读时间戳
/// @param totalSeconds 时间戳
+ (NSString *)stringReadStampHourSecondWithFormatted:(NSInteger)totalSeconds;

/// 可读时间戳
/// @param totalSeconds 时间戳
+ (NSString *)stringReadStampHourMinuteSecondWithFormatted:(NSInteger)totalSeconds;

/// 获取两个时间差的天数
/// @param startTime 开始时间
/// @param endTime 结束时间
+ (NSInteger)gapDayCountWithStartTime:(NSString *)startTime EndTime:(NSString *)endTime;

//当前时间减去时间差值
+ (NSString *)dateCurrentString:(NSString *)string withCutTime:(NSInteger)time;

@end
