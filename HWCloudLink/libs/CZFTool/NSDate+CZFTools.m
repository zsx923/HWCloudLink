//
//  NSDate+CZFTools.m
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import "NSDate+CZFTools.h"
#import "NSString+CZFTools.h"

@implementation NSDate (CZFTools)


/**
 *  根据一个过去的时间与现在时间做对比，获取间隔多少分钟
 *
 *  @param oldDate 过去时间
 *
 *  @return 差值多少秒
 */
+ (long)getMinuteByOldDateBetweenNowDate:(NSDate *)oldDate {
    long betweenMinutes = 0;
    
    // 获取本地时间
    NSDate *nowdate = [self dateFromString:[NSString getLocalTime] andFormatterString:@"yyyy-MM-dd HH:mm:ss" andTimeZone:[NSTimeZone systemTimeZone]];
    betweenMinutes = [nowdate timeIntervalSinceDate:oldDate]/60;
    
    return betweenMinutes;
}


/**
 *  NSString转换成NSDate，根据 自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"
 */
+ (NSDate *)dateFromString:(NSString *)dateString andFormatterString:(NSString *)strFormater andTimeZone:(NSTimeZone *)timeZone {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:strFormater];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    NSTimeZone *zone = timeZone == nil ? [NSTimeZone systemTimeZone] : timeZone;
    NSInteger interval = [zone secondsFromGMTForDate: destDate];
    NSDate *dateCurrent = [destDate  dateByAddingTimeInterval: interval];
    
    return dateCurrent;
}


/**
 *  NSDate转换成NSString，根据 自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"  忽略时区的转换
 */
+ (NSString *)stringIgnoreZoneFromDate:(NSDate *)date andFormatterString:(NSString *)strFormater {
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: -interval];
    
    return [self stringFromDate:localeDate andFormatterString:strFormater];
}


/**
 *  根据日期获取对应的星期几
 *
 *  @param strInputDate 输入日期字符串
 *
 *  @return 星期几
 */
+ (NSString*)weekdayStringFromDate:(NSString *)strInputDate {
    
    NSDate *inputDate = [self dateFromString:strInputDate andFormatterString:@"yy-MM-dd" andTimeZone:[NSTimeZone systemTimeZone]];
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];  // 设置时区
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}



/**
 格式化为可读的时间显示字符串
 
 @param date 时间
 @return 可读时间字符串
 */
+ (NSString *)stringNormalReadWithDate:(NSDate *)date {
    NSArray *dateInfoArray = [self getDateYearMonthDayWithDate:date];
    NSArray *currentDateInfoArray = [self getDateYearMonthDayWithDate:[NSDate date]];
    
    if ([dateInfoArray[0] integerValue] == [currentDateInfoArray[0] integerValue]) {
        // 年相等
        if ([dateInfoArray[1] integerValue] == [currentDateInfoArray[1] integerValue]) {
            // 月相等
            if ([dateInfoArray[2] integerValue] == [currentDateInfoArray[2] integerValue]) {
                // 日相等
                return [self stringFromDate:date andFormatterString:@"今天 HH:mm"];
            } else {
                NSInteger gapValue = [currentDateInfoArray[2] integerValue] - [dateInfoArray[2] integerValue] ;
                if (gapValue == 1) {
                    return [self stringFromDate:date andFormatterString:@"昨天 HH:mm"];
                } else if (gapValue == -1) {
                    return [self stringFromDate:date andFormatterString:@"明天 HH:mm"];
                }
                return [self stringFromDate:date andFormatterString:@"M月d日 HH:mm"];
            }
        } else {
            return [self stringFromDate:date andFormatterString:@"M月d日 HH:mm"];
        }
    }
    
    return [self stringFromDate:date andFormatterString:@"yyyy年M月d日 HH:mm"];
}

/**
 格式化为可读的时间显示字符串
 
 @param dateStr 时间  yyyy-MM-dd HH:mm:ss
 @return 可读时间字符串
 */
+ (NSString *)stringNormalType2ReadWithDate:(NSString *)dateStr {
    NSString *readYear = [NSString getStringRangeOfIndexWithStart:0 andEnd:4 andDealStr:dateStr];
    NSString *readMonth = [NSString getStringRangeOfIndexWithStart:5 andEnd:7 andDealStr:dateStr];
    NSString *readDay = [NSString getStringRangeOfIndexWithStart:8 andEnd:10 andDealStr:dateStr];
    NSString *readHour = [NSString getStringRangeOfIndexWithStart:11 andEnd:13 andDealStr:dateStr];
    NSString *readMinute = [NSString getStringRangeOfIndexWithStart:14 andEnd:16 andDealStr:dateStr];
    
    NSArray *currentDateInfoArray = [self getDateYearMonthDayWithDate:[NSDate date]];
    
    if ([readYear integerValue] == [currentDateInfoArray[0] integerValue]) {
        // 年相等
        if ([readMonth integerValue] == [currentDateInfoArray[1] integerValue]) {
            // 月相等
            if ([readDay integerValue] == [currentDateInfoArray[2] integerValue]) {
                // 日相等
                return [NSString stringWithFormat:@"%@:%@", readHour, readMinute];
            } else {
                return [NSString stringWithFormat:@"%@/%@ %@:%@", readMonth, readDay, readHour, readMinute];
            }
        } else {
            return [NSString stringWithFormat:@"%@/%@ %@:%@", readMonth, readDay, readHour, readMinute];
        }
    }
    
    return [NSString stringWithFormat:@"%@/%@/%@ %@:%@", readYear, readMonth, readDay, readHour, readMinute];
}



/**
 获取日期的年月日时分秒毫秒周
 
 @param date 日期
 @return 年月日时分秒毫秒周数组
 */
+ (NSArray *)getDateYearMonthDayWithDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSInteger unitFlags = NSCalendarUnitYear |
    
    NSCalendarUnitMonth |
    
    NSCalendarUnitDay |
    
    NSCalendarUnitWeekday |
    
    NSCalendarUnitHour |
    
    NSCalendarUnitMinute |
    
    NSCalendarUnitSecond |
    
    NSCalendarUnitNanosecond;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    return @[@([comps year]),
             @([comps month]),
             @([comps day]),
             @([comps hour]),
             @([comps minute]),
             @([comps second]),
             @([comps nanosecond]),
             @([comps weekday]-1)];
}

/**
 获取日期的年月日时分秒毫秒周
 
 @param dateStr 日期
 @return 年月日时分秒毫秒数组
 */
+ (NSArray *)getDateYearMonthDayWithDatestandrdStr:(NSString *)dateStr {
    NSString *year = [NSString getStringRangeOfIndexWithStart:0 andEnd:4 andDealStr:dateStr];
    NSString *month = [NSString getStringRangeOfIndexWithStart:5 andEnd:7 andDealStr:dateStr];
    NSString *day = [NSString getStringRangeOfIndexWithStart:8 andEnd:10 andDealStr:dateStr];
    NSString *hour = [NSString getStringRangeOfIndexWithStart:11 andEnd:13 andDealStr:dateStr];
    NSString *minute = [NSString getStringRangeOfIndexWithStart:14 andEnd:16 andDealStr:dateStr];
    NSString *second = [NSString getStringRangeOfIndexWithStart:17 andEnd:19 andDealStr:dateStr];
    return @[@([year integerValue]),
    @([month integerValue]),
    @([day integerValue]),
    @([hour integerValue]),
    @([minute integerValue]),
    @([second integerValue])];
}


/**
 *  NSDate转换成NSString，根据 自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"
 */
+ (NSString *)stringFromDate:(NSDate *)date andFormatterString:(NSString *)strFormater {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    [dateFormatter setDateFormat:strFormater];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}


/**
 *  获取时间字符串，从当前某个时间开始算起，正数表示向后推算几天，负数表示向前推算几天
 *  return Date
 */
+ (NSDate *)DateToStringForOtherDateFromNowDays:(NSInteger)dayValue andOriginalDate:(NSDate *)originDate {
    NSDate* date = originDate;
    date = [date dateByAddingTimeInterval:dayValue*3600*24];
    
    return date;
}


/**
 *  获取时间字符串，从某个日期算起，正数表示向后推算几小时，负数表示向前推算几小时
 *  自定义格式  @"yyyy-MM-dd HH:mm:ss zzz"
 */
+ (NSString *)DateToStringForOtherHourFromNowHours:(NSInteger)dayValue andFormatterString:(NSString *)strFormater andDate:(NSDate *)date {
//    NSDate *dateTemp = [date dateByAddingTimeInterval:(dayValue-8)*3600];
    NSDate *dateTemp = [date dateByAddingTimeInterval:(dayValue-0)*3600];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:strFormater];
    NSString *strDate = [dateFormatter stringFromDate:dateTemp];
    
    return strDate;
}


/**
 格式化数据发布时间
 
 @param oldDate oldDate
 */
+ (NSString *)formattingTimeCanEasyRead:(NSDate *)oldDate {
    NSString *timeStr = nil;
    long betweenMinutes = [NSDate getMinuteByOldDateBetweenNowDate:oldDate];
    if (betweenMinutes < 60) {
        timeStr = [NSString stringWithFormat:@"%li分钟前发布", betweenMinutes];
    } if (betweenMinutes >= 60 && betweenMinutes < 3600) {
        timeStr = [NSString stringWithFormat:@"%li小时前发布", betweenMinutes/60];
    } if (betweenMinutes >=3600) {
        timeStr = [NSString stringWithFormat:@"%li天前发布", betweenMinutes/3600];
    }
    
    return timeStr;
}



/**
 获取指定时间的前一个月或后一个月的时间

 @param date 指定时间
 @param month 正数便是后一个月，负数表示前一月
 @return 结果日期
 */
+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setMonth:month];
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];// NSGregorianCalendar
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    
    return mDate;
}



/**
 获取当月的天数

 @param date 计算时期
 @return 返回天数
 */
+ (NSInteger)getNumberOfDaysInMonthWithDate:(NSDate *)date {
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法 NSGregorianCalendar - ios 8
    NSDate * currentDate = date;
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit: NSCalendarUnitMonth forDate:currentDate];
    
    return range.length;
}


/// 可读时间戳
/// @param totalSeconds 时间戳
+ (NSString *)stringReadStampHourSecondWithFormatted:(NSInteger)totalSeconds {
    int seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60);

//    NSInteger minutes = (totalSeconds / 60) % 60;
//    NSInteger hours = totalSeconds / 3600;

    return [NSString stringWithFormat:@"%02ld:%02d", minutes, seconds];
}

/// 可读时间戳
/// @param totalSeconds 时间戳
+ (NSString *)stringReadStampHourMinuteSecondWithFormatted:(NSInteger)totalSeconds {
    int seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;

    return [NSString stringWithFormat:@"%02ld:%02ld:%02d", hours, minutes, seconds];
}


/// 获取两个时间差的天数
/// @param startTime 开始时间
/// @param endTime 结束时间
+ (NSInteger)gapDayCountWithStartTime:(NSString *)startTime EndTime:(NSString *)endTime {
    if (startTime == nil || endTime == nil) {
        return 0;
    }
    
    NSDate *startDate = [self dateFromString:startTime andFormatterString:@"yyyy-MM-dd HH:mm:ss" andTimeZone:nil];
    NSDate *endDate = [self dateFromString:endTime andFormatterString:@"yyyy-MM-dd HH:mm:ss" andTimeZone:nil];
    NSString *startHour = [NSString getStringRangeOfIndexWithStart:11 andEnd:13 andDealStr:startTime];
    NSString *endHour = [NSString getStringRangeOfIndexWithStart:11 andEnd:13 andDealStr:endTime];
    
    NSLog(@"获取两个时间差的天数startHour = %@, endHour = %@", startHour, endHour);
    NSLog(@"获取两个时间差的天数timeIntervalSinceDate = %f", [endDate timeIntervalSinceDate:startDate]/60/60/24);
    
    if ([startHour intValue] > [endHour intValue]) {
        return 1;
    }
    
    return [endDate timeIntervalSinceDate:startDate]/60/60/24;
}

//当前时间减去时间差值
+ (NSString *)dateCurrentString:(NSString *)string withCutTime:(NSInteger)time{
    //设置转换格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString转NSDate
    NSDate *nowDate=[formatter dateFromString:string];
    NSTimeInterval nowTime = [nowDate timeIntervalSince1970];
    NSInteger reslutTime = nowTime - time;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:reslutTime];
    NSString *destDateString = [formatter stringFromDate:date];
    return destDateString;
}


@end
