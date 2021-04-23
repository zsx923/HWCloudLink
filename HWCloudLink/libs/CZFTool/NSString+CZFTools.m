//
//  NSString+CZFTools.m
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import "NSString+CZFTools.h"
#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"
#import "NSDate+CZFTools.h"
#import "CommonUtils.h"

@implementation NSString (CZFTools)

/**
 *  获取当前时间戳 - return转字符串
 */
+ (NSString *)getTimestamp {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%.f",timeInterval];
    return timestamp;
}


/**
 *  获取唯一字符串 设备id+时间戳的字符串
 *
 *  @return 唯一字符串
 */

+ (NSString *)getUniqueID {
    NSString *identifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *uniqueID = [identifier stringByAppendingString:[NSString stringWithFormat:@"%.f",timeInterval]];
    return uniqueID;
}


/**
 *  获取本地时间  （标准格式：yyyy-MM-dd HH:mm:ss）
 *
 *  @return 本地时间字符串
 */

+ (NSString *)getLocalTime {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *localTime = [formatter stringFromDate:date];
    return localTime;
}


/**
 *  将数字的字符串转成随机的pm2.5
 *
 *  @param string 源字符串
 *
 *  @return 目标字符串
 */

+ (NSString *)randomStringWithString:(NSString *) string {
    
    int pm2_5 = [string intValue];
    
    if (pm2_5 < 20) {
        int i = arc4random() % 4 - 2;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 30){
        int i = arc4random() % 10 - 5;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if (pm2_5< 40){
        int i = arc4random() % 12 - 6;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 60){
        int i = arc4random() % 16 - 8;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 70){
        int i = arc4random() % 16 - 8;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 80){
        int i = arc4random() % 18 - 9;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else {
        int i = arc4random() % 20 - 10;
        return [NSString stringWithFormat:@"%d",pm2_5 + i] ;
        
    }
}


+ (NSString *)formats:(NSString *)obj {
    
    NSRange foundObj=[obj rangeOfString:@"-" options:NSCaseInsensitiveSearch];
    
    if (foundObj.length > 0) {
        NSLog(@"%@", [obj substringFromIndex:1]);
        return [obj substringFromIndex:1];
    }else {
        return obj;
    }
}


/**
 *  可读格式化存储大小
 *
 *  @param size 存储大小   单位：B
 *
 *  @return B, K, M, G 为单位
 */
+ (NSString *)fileSizeWithInterge:(NSInteger)size {
    // 1k = 1024, 1m = 1024k
    if (size < 1024) {// 小于1k
        return [NSString stringWithFormat:@"%ldB",(long)size];
    }else if (size < 1024 * 1024){// 小于1m
        CGFloat aFloat = size/1024.0f;
        return [NSString stringWithFormat:@"%.1fK",aFloat];
    }else if (size < 1024 * 1024 * 1024){// 小于1G
        CGFloat aFloat = size/(1024.0f * 1024.0f);
        return [NSString stringWithFormat:@"%.1fM",aFloat];
    }else{
        CGFloat aFloat = size/(1024.0f*1024.0f*1024.0f);
        return [NSString stringWithFormat:@"%.2fG",aFloat];
    }
}


/**
 *  验证是否为手机号
 *
 *  @param phoneNum 要验证的手机号码
 *
 *  @return 是否为手机号
 */

+(BOOL)checkPhoneNumInputWithPhoneNum:(NSString *)phoneNum {
    NSString *pattern = @"1[3578]\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneNum];
    return isMatch;
    
}


/**
 验证邮箱
 
 @param email email
 @return 是否是邮箱
 */
+ (BOOL)checkEmailInputWithEmail:(NSString *)email
{
    NSString *emailRegex =@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


/**
 * 字母、数字、中文正则判断（不包括空格）
 */
+ (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
/**
 * 字母、数字、中文正则判断（包括空格）【注意3】
 */
+ (BOOL)isInputRuleAndBlank:(NSString *)str {
    
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}


/**
 *  获得 kMaxLength长度的字符
 */
+ (NSString *)getSubCharString:(NSString*)string andMaxLength:(int)mexLength
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data = [string dataUsingEncoding:encoding];
    NSInteger length = [data length];
    if (length > mexLength) {
        NSData *data1 = [data subdataWithRange:NSMakeRange(0, mexLength)];
        NSString *content = [[NSString alloc] initWithData:data1 encoding:encoding];//【注意4】：当截取kMaxLength长度字符时把中文字符截断返回的content会是nil
        if (!content || content.length == 0) {
            data1 = [data subdataWithRange:NSMakeRange(0, mexLength - 1)];
            content =  [[NSString alloc] initWithData:data1 encoding:encoding];
        }
        return content;
    }
    return nil;
}

/**
 *  获得 kMaxLength长度的字
 */
+ (NSString *)getSubWordString:(NSString*)string andMaxLength:(int)mexLength
{
    if (string.length > mexLength) {
        NSString *content = [string substringToIndex:mexLength];
        return content;
    }
    return nil;
}

/**
 *  过滤字符串中的emoji
 */
+ (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"‍‍" withString:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"‍‍‍" withString:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"‍" withString:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"•" withString:@""];
    //modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"?" withString:@""];
    return modifiedString;
}


/*
 *第二种方法，利用Emoji表情最终会被编码成Unicode，因此，
 *只要知道Emoji表情的Unicode编码的范围，
 *就可以判断用户是否输入了Emoji表情。
 */
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    // 过滤所有表情。returnValue为NO表示不含有表情，YES表示含有表情

    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {

        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0x2022 || hs == 0xd83e) {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}


/**
 *  校验字符串防止nil字符串操作
 *
 *  @param stringText 字符串
 *
 *  @return 校验后的字符串
 */
+ (NSString *)verifyString:(id)stringText {
    if ([stringText isKindOfClass:[NSNull class]]) {
        return @"";
    } else if ([stringText isEqual:NULL]) {
        return @"";
    } else if ([stringText isEqual:@"null"]) {
        return @"";
    } else if ([stringText isEqual:@"<null>"]) {
        return @"";
    }
    
    
    return stringText == nil ? @"" : stringText;
}


/**
 过滤字符串中HTML标签的方法
 
 @param html 含HTML标签的字符串
 @return    过滤后的字符串
 */
+ (NSString *)flattenHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    } // while //
    
    return html;
}


/**
 判断本地是否存在该文件
 
 @param fileName 文件名称或者路径
 @return 存在的文件路径，不存在则返回nil
 */
+ (NSString *)checkFilePathExistWithFileName:(NSString *)fileName {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *fileNameArray = [fileName componentsSeparatedByString:@"/"];
    NSString *exitFilePath = [cachesPath stringByAppendingPathComponent:fileNameArray[fileNameArray.count-1]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:exitFilePath]) {
        return exitFilePath;
    }
    return nil;
}


/**
 统计目录文件下文件的总大小
 
 @param folderPath 目录地址
 @return 总大小
 */
+ (long long)folderSizeWithPath:(NSString *)folderPath {
    // 获取默认的文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 判断文件是否存在
    if (![fileManager fileExistsAtPath:folderPath]) return 0;
    
    //文件的枚举器
    NSEnumerator *fileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName = nil;
    long long filesAllSize = 0;
    while ((fileName = [fileEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        if ([fileAbsolutePath hasSuffix:@"doc"] || [fileAbsolutePath hasSuffix:@"DOC"]  || [fileAbsolutePath hasSuffix:@"docx"] || [fileAbsolutePath hasSuffix:@"DOCX"] || [fileAbsolutePath hasSuffix:@"pdf"] || [fileAbsolutePath hasSuffix:@"PDF"] || [fileAbsolutePath hasSuffix:@"ppt"] || [fileAbsolutePath hasSuffix:@"PPT"] || [fileAbsolutePath hasSuffix:@"xls"] || [fileAbsolutePath hasSuffix:@"XLS"] || [fileAbsolutePath hasSuffix:@"txt"] || [fileAbsolutePath hasSuffix:@"TXT"] || [fileAbsolutePath hasSuffix:@"wav"] || [fileAbsolutePath hasSuffix:@"WAV"] || [fileAbsolutePath hasSuffix:@"amr"] || [fileAbsolutePath hasSuffix:@"AMR"]) {
            // 计算某个文件的大小
            filesAllSize += [self fileSizeWithPath:fileAbsolutePath];
        }
    }
    
    return filesAllSize;
}


/**
 计算指定文件的大小
 
 @param filePath 文件地址
 @return 大小
 */
+ (long long)fileSizeWithPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        return [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    
    return 0;
}



/**
 删除指定目录下的所有文件
 
 @param folderPath 目录地址
 */
+ (void)removeFolderPathAndFileWithPath:(NSString *)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 目录是否存在
    if (![fileManager fileExistsAtPath:folderPath]) return;
    
    // 文件枚举器
    NSEnumerator *fileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName = nil;
    while ((fileName = [fileEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([fileAbsolutePath hasSuffix:@"doc"] || [fileAbsolutePath hasSuffix:@"DOC"]  || [fileAbsolutePath hasSuffix:@"docx"] || [fileAbsolutePath hasSuffix:@"DOCX"] || [fileAbsolutePath hasSuffix:@"pdf"] || [fileAbsolutePath hasSuffix:@"PDF"] || [fileAbsolutePath hasSuffix:@"ppt"] || [fileAbsolutePath hasSuffix:@"PPT"] || [fileAbsolutePath hasSuffix:@"xls"] || [fileAbsolutePath hasSuffix:@"XLS"] || [fileAbsolutePath hasSuffix:@"txt"] || [fileAbsolutePath hasSuffix:@"TXT"] || [fileAbsolutePath hasSuffix:@"wav"] || [fileAbsolutePath hasSuffix:@"WAV"] || [fileAbsolutePath hasSuffix:@"amr"] || [fileAbsolutePath hasSuffix:@"AMR"]) {
            // 删除指定的文件
            NSError *error = nil;
            [fileManager removeItemAtPath:fileAbsolutePath error:&error];
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
        }
    }
}


/**
 url参数字符串转字典
 
 @param urlStr url参数字符串
 @return 结果字典
 */
+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr
{
    urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (urlStr.length > 0) {
        NSArray *array = [urlStr componentsSeparatedByString:@"&"];
        NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
        for (NSString *param in array) {
            if (param.length > 0) {
                NSArray *parArr = [param componentsSeparatedByString:@"="];
                if (parArr.count == 2) {
                    [paramsDict setValue:parArr[1] forKey:parArr[0]];
                }
            }
        }
        return paramsDict;
    }else{
        return nil;
    }
}


/**
 json 字符串转字典的方法
 
 @param jsonString json字符串
 @return 转换后的字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


/**
 改变字符start 和 end 之间的字符的颜色 和 字体大小
 
 @param theTextView UITextView
 @param start 开始字符串
 @param end 结束字符串
 @param allColor 整体颜色
 @param markColor 想要标注的颜色
 @param fontSize 字体大小
 */
+ (void)messageAction:(UITextView *)theTextView startString:(NSString *)start endString:(NSString *)end andAllColor:(UIColor *)allColor andMarkColor:(UIColor *)markColor andMarkFondSize:(float)fontSize {
    NSString *tempStr = theTextView.text;
    NSMutableAttributedString *strAtt = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [strAtt addAttribute:NSForegroundColorAttributeName value:allColor range:NSMakeRange(0, [strAtt length])];
    // 'x''y'字符的范围
    NSRange tempRange = NSMakeRange(0, 0);
    if ([NSString judgeStringIsNull:start]) {
        tempRange = [tempStr rangeOfString:start];
    }
    NSRange tempRangeOne = NSMakeRange([strAtt length], 0);
    if ([NSString judgeStringIsNull:end]) {
        tempRangeOne =  [tempStr rangeOfString:end];
    }
    // 更改字符颜色
    NSRange markRange = NSMakeRange(tempRange.location+tempRange.length, tempRangeOne.location-(tempRange.location+tempRange.length));
    [strAtt addAttribute:NSForegroundColorAttributeName value:markColor range:markRange];
    // 更改字体
    // [strAtt addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20] range:NSMakeRange(0, [strAtt length])];
    [strAtt addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:fontSize] range:markRange];
    theTextView.attributedText = strAtt;
}


/**
 *判断字符串是否不全为空
 */
+ (BOOL)judgeStringIsNull:(NSString *)string {
    if ([[string class] isSubclassOfClass:[NSNumber class]]) {
        return YES;
    }
    BOOL result = NO;
    if (string != nil && string.length > 0) {
        for (int i = 0; i < string.length; i ++) {
            NSString *subStr = [string substringWithRange:NSMakeRange(i, 1)];
            if (![subStr isEqualToString:@" "] && ![subStr isEqualToString:@""]) {
                result = YES;
            }
        }
    }
    return result;
}


/**
 判断字符串是否为纯数字
 
 @param checkedNumString 字符串
 @return 结果Bool类型
 */
+ (BOOL)isNum:(NSString *)checkedNumString {
    checkedNumString = [checkedNumString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(checkedNumString.length > 0) {
        return NO;
    }
    return YES;
}


/**
 判断字符串是否为格式字符串中的字符

 @param string 要匹配的字符串
 @param formatStr 字符串格式 (字母数字：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789，
 字母：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz，
 数字：0123456789，
 数字与小数点：.0123456789)
 @return yes,no
 */
+(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string andFormat:(NSString *)formatStr {
    
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:formatStr] invertedSet];
    
    NSString *filter=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filter];
}


/**
 根据字符串中后缀的格式类型返回对应的本地文件类型图标
 
 @param checkString 判断字符串
 @return 本地文件类型的图标地址
 */
+ (NSString *)getLocalImageWithCheckString:(NSString *)checkString {
    if ([checkString hasSuffix:@"doc"] || [checkString hasSuffix:@"DOC"]) {
        return @"findcase_file_icon.jpg";     // word 格式
    } else if ([checkString hasSuffix:@"docx"] || [checkString hasSuffix:@"DOCX"]) {
        return @"findcase_file_icon.jpg";     // word 格式
    } else if ([checkString hasSuffix:@"pdf"] || [checkString hasSuffix:@"PDF"]) {
        return @"findcase_file2_icon.jpg";
    } else if ([checkString hasSuffix:@"ppt"] || [checkString hasSuffix:@"PPT"]) {
        return @"case_filetype001.jpg";
    }else if ([checkString hasSuffix:@"xls"] || [checkString hasSuffix:@"XLS"]) {
        return @"findcase_file3_icon.jpg";
    }else if ([checkString hasSuffix:@"txt"] || [checkString hasSuffix:@"TXT"]) {
        return @"findcase_file4_icon.jpg";
    }else {
        return @"findcase_file5_icon.jpg";  // 位置格式
    }
}


// 字符串进行UTF8编码
+ (NSString *)stringAddEncodeWithString:(NSString *)str {
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// 字符串进行UTF8解码
+ (NSString *)stringReplaceEncodeWithString:(NSString *)str {
    return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// MARK: 隐藏手机中间4位为*号
+ (NSString *)stringPhoneNumEncodeStartWithString:(NSString *)str {
    return  [str stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
}



/**
 根据PM2.5值获取污染程度描述

 @param pm25Value pm2.5值
 @return pm2.5描述
 */
+ (NSString *)stringPm25LevelDescription:(NSInteger)pm25Value {
    if (pm25Value >= 0 && pm25Value < 50) {
        return @"优";
    } else if (pm25Value >= 50 && pm25Value < 100) {
        return @"良";
    } else if (pm25Value >= 100 && pm25Value < 150) {
        return @"轻度污染";
    } else if (pm25Value >= 150 && pm25Value < 200) {
        return @"中度污染";
    } else if (pm25Value >= 200 && pm25Value < 300) {
        return @"重度污染";
    } else if (pm25Value >= 300) {
        return @"严重污染";
    } else {
        return @"未知";
    }
}



/**
 将距离变成可读的格式

 @param distance 距离
 @return 可读字符串
 */
+ (NSString *)stringReadDistanceWith:(CGFloat)distance {
    if (distance < 1.0) {
        return @"<1米";
    } else if (distance < 1000) {
        return [NSString stringWithFormat:@"%.0f米", distance];
    } else if (distance < 10000) {
        return [NSString stringWithFormat:@"%.1f千米", distance / 1000];
    } else if (distance < 10000000) {
        return [NSString stringWithFormat:@"%.0f千米", distance / 1000];
    } else {
        return [NSString stringWithFormat:@"%.1f千公里", distance / 1000000];
    }
}



/**
 调用系统的MD5加密

 @param input 源字符串
 @return 目标字符串
 */
+ (NSString *)md5:(NSString *)input {
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, (int)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return  output;
}



/**
 获取指定开始和结束的字符串-- str

 @param startStr 开始的字符串
 @param endStr 结束的字符串
 @param string 待处理字符串
 @return 目标字符串
 */
+ (NSString *)getStringRangeOfStringWithStart:(NSString *)startStr andEnd:(NSString *)endStr andDealStr:(NSString *)string {
    NSRange startRange = [string rangeOfString:startStr];
    if ([startStr isEqual:@""]) {
        startRange = NSMakeRange(0, 0);
    }
    
    NSRange endRange = [string rangeOfString:endStr];
    
    NSRange range = NSMakeRange(startRange.location
                        + startRange.length,
                        endRange.location
                        - startRange.location
                        - startRange.length);
    
    return [string substringWithRange:range];
}


/// 获取指定开始和结束的字符串-- index
/// @param startIndex index
/// @param endIndex index
/// @param string string
+ (NSString *)getStringRangeOfIndexWithStart:(NSInteger)startIndex andEnd:(NSInteger)endIndex andDealStr:(NSString *)string {
    if (startIndex > endIndex || string.length < startIndex || string.length < (endIndex - startIndex)) {
        return @"";
    }
    
    return [string substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
}


/**
 根据详细地址字符串获取城市名称

 @param addressStr 地址字符串
 @return 城市名
 */
+ (NSString *)getCityNameWithAddressStr:(NSString *)addressStr {
    NSString *cityName = @"";
    if ([addressStr rangeOfString:@"省"].location != NSNotFound) {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            cityName = [self getStringRangeOfStringWithStart:@"省" andEnd:@"市" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@市", cityName];
        } else {
            cityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"省" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@省", cityName];
        }
    } else {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            cityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"市" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@市", cityName];
            return cityName;
        }
        
        if ([addressStr rangeOfString:@"自治州"].location != NSNotFound) {
            cityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"自治州" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@自治州", cityName];
        } else {
            if ([addressStr rangeOfString:@"地区"].location != NSNotFound) {
                cityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"地区" andDealStr:addressStr];
                cityName = [NSString stringWithFormat:@"%@地区", cityName];
            }
        }
    }
    
    return cityName;
}


/**
 根据详细地址字符串获取省和城市名称
 
 @param addressStr 地址字符串
 @return 省和城市名
 */
+ (NSString *)getCityAndProinceNameWithAddressStr:(NSString *)addressStr {
    NSString *pcityName = @"";
    if ([addressStr rangeOfString:@"省"].location != NSNotFound) {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            pcityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"市" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@市", pcityName];
        } else {
            pcityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"省" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@省", pcityName];
        }
    } else {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            pcityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"市" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@市", pcityName];
            return pcityName;
        }
        
        if ([addressStr rangeOfString:@"自治州"].location != NSNotFound) {
            pcityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"自治州" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@自治州", pcityName];
        } else {
            if ([addressStr rangeOfString:@"地区"].location != NSNotFound) {
                pcityName = [self getStringRangeOfStringWithStart:@"" andEnd:@"地区" andDealStr:addressStr];
                pcityName = [NSString stringWithFormat:@"%@地区", pcityName];
            }
        }
    }
    
    return pcityName;
}




/**
 去掉小数点后边多余的0

 @param string 源字符串
 @return 目标字符串
 */
+(NSString*)removeFloatAllZero:(NSString*)string
{
    if ([string isEqualToString:@"--"]) {
        return string;
    }
    
    NSString * testNumber = string;
    NSString * outNumber = [NSString stringWithFormat:@"%@",@(testNumber.floatValue)];
    
    //    价格格式化显示
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    NSString *formatterString = [formatter stringFromNumber:[NSNumber numberWithFloat:[outNumber doubleValue]]];
    
    NSRange range = [formatterString rangeOfString:@"."]; //现获取要截取的字符串位置
    NSLog(@"--------%lu",(unsigned long)range.length);
    
    if (range.length>0) {
        
        NSString * result = [formatterString substringFromIndex:range.location]; //截取字符串
        
        if (result.length>=4) {
            
            formatterString=[formatterString substringToIndex:formatterString.length-1];
        }
        
    }
    
    NSLog(@"Formatted number string:%@",formatterString);
    
    NSLog(@"Formatted number string:%@",outNumber);
    //    输出结果为：[1223:403] Formatted number string:123,456,789
    
    return outNumber;
}



/**
 
 *  验证手机号以及固话方法
 
 *  @param number 电话号
 
 *  @return BOOL yes格式正确 no格式错误
 
 */
+ (BOOL)checkContactNumber:(NSString *)number {
    //验证输入的固话中不带 "-"符号
    NSString * strNum = @"^(\\(\\d{3,4}\\)|\\d{3,4}-)?\\d{7,8}(-\\d{1,4})?$";
    
    //验证输入的固话中带 "-"符号
//    NSString * strNum =@"^(0[0-9]{2,3}-)?([2-9][0-9]{6,7})+(-[0-9]{1,4})?$|(^(13[0-9]|14[5|7|9]|15[0-9]|17[0|1|3|5|6|7|8]|18[0-9])\\d{8}$)";
    
    NSPredicate *checktest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strNum];
    
    return [checktest evaluateWithObject:number];
}


/**

 *  验证只能输入数字、汉字、字母
 *  @param text 需要验证字符串
 *  @return BOOL yes格式正确 no格式错误
 
 */
+ (BOOL)checkIsNumHanZimu:(NSString *)text {
    NSString *regex = @"[^a-zA-Z0-9\u4E00-\u9FA5]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:text];
}


/**
 获取地址中的Ip和端口
 
 @param webUrlStr 请求地址（必须包含ip和端口）
 @return ip和端口的数据
 */
+ (NSArray<NSString *> *)getWebUrlIpAndPort:(NSString *)webUrlStr {
    NSMutableArray<NSString *> *dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    if ([webUrlStr hasPrefix:@"http"]) {
        NSString *temp = [[webUrlStr componentsSeparatedByString:@"://"] lastObject];
        temp = [[temp componentsSeparatedByString:@"/"] firstObject];
        NSArray *arr1 = [temp componentsSeparatedByString:@"."];
        
        if (arr1.count == 4) {
            [dataArray addObject:arr1[0]];
            [dataArray addObject:arr1[1]];
            [dataArray addObject:arr1[2]];
            NSString *temp2 = arr1[3];
            NSArray *arr2 = [temp2 componentsSeparatedByString:@":"];
            if (arr2.count == 2) {
                [dataArray addObject:arr2[0]];
                [dataArray addObject:arr2[1]];
                
                return dataArray;
            }
        }
    }
    
    return nil;
}


/// 去掉前后中间的空格
/// @param str str
/// @param isRemoveMiddle 是否去掉中间的空格
+ (NSString *)removeWhiteSpace:(NSString *)str andIsRemoveMiddle:(BOOL)isRemoveMiddle {
    NSString *theString = str;
    
    if (isRemoveMiddle) {
        NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
        NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
        NSArray *parts = [theString componentsSeparatedByCharactersInSet:whitespaces];
        NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
        theString = [filteredArray componentsJoinedByString:@""];
    } else {
        //如果仅仅是去前后空格，用whitespaceCharacterSet
        NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        theString = [theString stringByTrimmingCharactersInSet:set];
    }
    
    
    return theString;
}



/// 获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
/// @param aString 传入汉字字符串
+ (NSString *)firstCharactor:(NSString *)aString {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}


///  获取联系人对象中所有手机号
/// @param contact CNContact对象
+ (NSMutableDictionary *)phonesWithCNContact:(CNContact *)contact {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    if(contact.phoneNumbers.count > 0) {
        for (int k = 0; k < contact.phoneNumbers.count; k++) {
            CNLabeledValue<CNPhoneNumber*>* phoneObject = contact.phoneNumbers[k];
            NSString *label = phoneObject.label;
            NSString *number = [phoneObject.value stringValue];
            NSString *labelLower = [label lowercaseString];
            labelLower = [labelLower stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
            labelLower = [labelLower stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
            if ([labelLower isEqualToString:@"work"]) [dict setValue:number forKey:@"WORK"];
            else { //类型解析不出来的
                [dict setValue:number forKey:@"MOBILE"];
            }
        }
    }
    
    return dict;
}


/// ios9之后的通讯录转Vcard(版本2.1)字符串-- 太大的通讯录会内存溢出，要使用存入本地文件, 返回的是vcf格式文件个地址
/// @param contacts contacts description
+ (NSString *)generateVCard21StringWithContacts:(NSArray<CNContact *> *)contacts {
    NSInteger counter = 0;
    
    // 获取带毫秒的时间戳
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    
    NSString *writePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@.%@", timeSp, @"vcf"]];
    
    for(CFIndex i = 0; i < contacts.count; i++) {
        NSString *vcard = @"";
        
        CNContact *contact = contacts[i];
        NSString *firstName = contact.givenName;
        firstName = (firstName ?
                     firstName : @"");
        NSString *lastName = contact.familyName;
        lastName = (lastName ? lastName : @"");
        NSString *middleName = contact.middleName;
        NSString *prefix = contact.namePrefix;
        NSString *suffix = contact.nameSuffix;
        
        // 编码
        firstName = [NSString URLencode:firstName stringEncoding:NSUTF8StringEncoding];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"%" withString:@"="];
        lastName = [NSString URLencode:lastName stringEncoding:NSUTF8StringEncoding];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"%" withString:@"="];
        middleName = [NSString URLencode:middleName stringEncoding:NSUTF8StringEncoding];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"%" withString:@"="];
        
//        NSString *nickName = contact.nickname;
//        NSString *firstNamePhonetic = contact.phoneticGivenName;
//        NSString *lastNamePhonetic = contact.phoneticFamilyName;
//        NSString *organization = contact.organizationName;
//        NSString *jobTitle = contact.jobTitle;
//        NSString *department = contact.departmentName;
        
        NSString *compositeName = [NSString stringWithFormat:@"%@%@",firstName,lastName];
        
        if(i > 0) {
            vcard = [vcard stringByAppendingFormat:@"\n"];
        }
        
        vcard = [vcard stringByAppendingFormat:@"BEGIN:VCARD\nVERSION:2.1\nN;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:%@;%@;%@;%@;%@\n",
                 (firstName ?
                  firstName : @""),
                 (lastName ? lastName : @""),
                 (middleName ? middleName : @""),
                 (prefix ?
                  prefix : @""),
                 (suffix ? suffix : @"")
                 ];
        
        vcard = [vcard stringByAppendingFormat:@"FN;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:%@\n",compositeName];
        
        // Tel
        if(contact.phoneNumbers.count > 0) {
            for (int k = 0; k < contact.phoneNumbers.count; k++) {
                CNLabeledValue<CNPhoneNumber*>* phoneObject = contact.phoneNumbers[k];
                NSString *label = phoneObject.label;
                NSString *number = [phoneObject.value stringValue];
                NSString *labelLower = [label lowercaseString];
                labelLower = [labelLower stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
                labelLower = [labelLower stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
                
                if ([labelLower isEqualToString:@"mobile"]) vcard = [vcard stringByAppendingFormat:@"TEL;CELL:%@\n",number];
                else if ([labelLower isEqualToString:@"home"]) vcard = [vcard stringByAppendingFormat:@"TEL;HOME:%@\n",number];
                else if ([labelLower isEqualToString:@"work"]) vcard = [vcard stringByAppendingFormat:@"TEL;WORK:%@\n",number];
                else if ([labelLower isEqualToString:@"main"]) vcard = [vcard stringByAppendingFormat:@"TEL;MAIN:%@\n",number];
                else if ([labelLower isEqualToString:@"homefax"]) vcard = [vcard stringByAppendingFormat:@"TEL;HOME;type=FAX:%@\n",number];
                else if ([labelLower isEqualToString:@"workfax"]) vcard = [vcard stringByAppendingFormat:@"TEL;WORK;FAX:%@\n",number];
                else if ([labelLower isEqualToString:@"pager"]) vcard = [vcard stringByAppendingFormat:@"TEL;PAGER:%@\n",number];
                else if([labelLower isEqualToString:@"other"]) vcard = [vcard stringByAppendingFormat:@"TEL;OTHER:%@\n",number];
                else { //类型解析不出来的
                    counter++;
//                    vcard = [vcard stringByAppendingFormat:@"item%i.TEL:%@\nitem%i.X-ABLabel:%@\n",counter,number,counter,label];
                }
            }
        }
        
        // Mail
        if(contact.emailAddresses.count > 0) {
            for (int k = 0; k < contact.emailAddresses.count; k++) {
                CNLabeledValue<NSString*>* emailObject = contact.emailAddresses[k];
                NSString *label = emailObject.label;
                NSString *email = emailObject.value;
                NSString *labelLower = [label lowercaseString];
                
                vcard = [vcard stringByAppendingFormat:@"EMAIL;WORK:%@\n",email];
                
                if ([labelLower isEqualToString:@"home"]) vcard = [vcard stringByAppendingFormat:@"EMAIL;HOME:%@\n",email];
                else if ([labelLower isEqualToString:@"work"]) vcard = [vcard stringByAppendingFormat:@"EMAIL;WORK:%@\n",email];
                else {//类型解析不出来的
                    counter++;
//                    vcard = [vcard stringByAppendingFormat:@"item%i.EMAIL;type=INTERNET:%@\nitem%i.X-ABLabel:%@\n",counter,email,counter,label];
                }
            }
        }
        
        // Address
        if(contact.postalAddresses.count > 0) {
            for (int k = 0; k < contact.postalAddresses.count; k++) {
                CNLabeledValue<CNPostalAddress*>* addressObject = contact.postalAddresses[k];
                NSString *label = addressObject.label;
                CNPostalAddress *address = addressObject.value;
                NSString *labelLower = [label lowercaseString];
                NSString* country = address.country;
                NSString* city = address.city;
                NSString* state = address.state;
                NSString* street = address.street;
                NSString* zip = address.postalCode;
//                NSString* countryCode = address.ISOCountryCode;
                NSString *type = @"";
//                NSString *labelField = @"";
                counter++;
                
                if([labelLower isEqualToString:@"work"]) type = @"WORK";
                else if([labelLower isEqualToString:@"home"]) type = @"HOME";
//                else if(label && [label length] > 0)
//                {
//                    labelField = [NSString stringWithFormat:@"item%li.X-ABLabel:%@\n",(long)counter,label];
//                }
                
                vcard = [vcard stringByAppendingFormat:@"ADR;%@:;;%@;%@;%@;%@;%@\n",
                         type,
                         (street ? street : @""),
                         (city ? city : @""),
                         (state ? state : @""),
                         (zip ? zip : @""),
                         (country ? country : @"")];
            }
        }
        
        
        // 剩下的不经常使用，我就不写了，要是须要。自己补全
        // url
        // TODO:
        
        // IM
        // TODO:
        
        // Photo
        // TODO:
        if (contact.imageDataAvailable) {
//            UIImage *profileImage = [UIImage imageWithData:contact.imageData];
//            profileImage = [UIImage scalToSize:profileImage size:CGSizeMake(100, 100)];
//            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.2);
            
            //  iphone base64解码 NSDataBase64EncodingEndLineWithLineFeed
//            NSString *imageBase64Str = [contact.thumbnailImageData base64EncodedStringWithOptions: NSDataBase64EncodingEndLineWithLineFeed];
            
            // 安卓   base64解码
            NSString *imageBase64Str2 = [GTMBase64 stringByEncodingData:contact.thumbnailImageData];  // iOS 和安卓通用base64
            
            vcard = [vcard stringByAppendingFormat:@"PHOTO;ENCODING=BASE64;JPG:%@\n\n", imageBase64Str2];

            vcard = [vcard stringByAppendingFormat:@"X-CMCC-STAR:%@\n", @"0"];

        }
        
        vcard = [vcard stringByAppendingString:@"END:VCARD"];
        
        // 写入文件
        NSError *error;
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:writePath];
        if (fh == nil) {
            [vcard writeToFile:writePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        
        [fh truncateFileAtOffset:[fh seekToEndOfFile]];
        NSData *encoded = [vcard dataUsingEncoding:NSUTF8StringEncoding];
        [fh writeData:encoded];
        if (error) {
            NSLog(@"写入vcard失败");
        }
    }
    
    return writePath;
}



// 写字符串到文件中
+ (NSString *)writeStringToFile:(NSString *)writeStr andFileSuffix:(NSString *)fileType {
    // 获取带毫秒的时间戳
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    
    NSString *writePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@.%@", timeSp, fileType]];
    NSError *error;
    [writeStr writeToFile:writePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"导出失败");
        return nil;
    }else {
        NSLog(@"导出成功");
        return writePath;
    }
}


//解析vcf
+(void)parseVCard21String:(NSString*)vcardString
{
    NSArray *lines = [vcardString componentsSeparatedByString:@"\n"];
    
    for(NSString* line in lines)
    {
        
        if ([line hasPrefix:@"BEGIN"])
        {
            NSLog(@"parse start");
        }
        else if ([line hasPrefix:@"END"])
        {
            NSLog(@"parse end");
        }
        else if ([line hasPrefix:@"N:"])
        {
            NSArray *upperComponents = [line componentsSeparatedByString:@":"];
            NSArray *components = [[upperComponents objectAtIndex:1] componentsSeparatedByString:@";"];
            
            NSString * lastName = [components objectAtIndex:0];
            NSString * firstName = [components objectAtIndex:1];
            
            NSLog(@"name %@ %@",lastName,firstName);
            
        }
        else if ([line hasPrefix:@"EMAIL;"])
        {
            NSArray *components = [line componentsSeparatedByString:@":"];
            NSString *emailAddress = [components objectAtIndex:1];
            NSLog(@"emailAddress %@",emailAddress);
            
        }
        else if ([line hasPrefix:@"TEL;"])
        {
            NSArray *components = [line componentsSeparatedByString:@":"];
            NSString *phoneNumber = [components objectAtIndex:1];
            NSLog(@"phoneNumber %@",phoneNumber);
        }
    }
}

// //Unicode转化为汉字:
+(NSString *)replaceUnicode:(NSString*)unicodeStr {
    NSString *tempStr1=[unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2=[tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3=[[@"\"" stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData=[tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr =[NSPropertyListSerialization propertyListFromData:tempData
                                                          mutabilityOption:NSPropertyListImmutable
                                                                    format:NULL
                                                          errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
    
}


//中文转unicode
+ (NSString *)utf8ToUnicode:(NSString *)string {
    NSUInteger length = [string length];
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    for (int i = 0;i < length; i++){
        NSMutableString *s = [NSMutableString stringWithCapacity:0];
        unichar _char = [string characterAtIndex:i];
        // 判断是否为英文和数字
        if (_char <= '9' && _char >='0'){
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
        }else if(_char >='a' && _char <= 'z'){
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
        }else if(_char >='A' && _char <= 'Z')
        {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
        }else{
            // 中文和字符
            [s appendFormat:@"\\u%x",[string characterAtIndex:i]];
            // 不足位数补0 否则解码不成功
            if(s.length == 4) {
                [s insertString:@"00" atIndex:2];
            } else if (s.length == 5) {
                [s insertString:@"0" atIndex:2];
            }
        }
        [str appendFormat:@"%@", s];
    }
    return str;
}

// 获取中英文字符长度
- (int)convertToInt {
    int strlength = 0;
    // NSUTF8StringEncoding(中文占3个字节)，NSUnicodeStringEncoding(中文占2个字节)
    char *p = (char *)[self cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ;i++) { // NSUnicodeStringEncoding
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

// url 对应安卓 编码
+ (NSString*)URLencode:(NSString *)originalString
        stringEncoding:(NSStringEncoding)stringEncoding {
    //!  @  $  &  (  )  =  +  ~  `  ;  '  :  ,  /  ?
    //%21%40%24%26%28%29%3D%2B%7E%60%3B%27%3A%2C%2F%3F
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" ,    @"$" , @"," ,
                            @"!", @"'", @"(", @")", @"*", nil];
    
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
                             @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" , @"%2C" ,
                             @"%21", @"%27", @"%28", @"%29", @"%2A", nil];
    
    int len = [escapeChars count];
    
    NSMutableString *temp = [[originalString
                              stringByAddingPercentEscapesUsingEncoding:stringEncoding]
                             mutableCopy];
    
    int i;
    for (i = 0; i < len; i++) {
        
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    NSString *outStr = [NSString stringWithString: temp];
    return outStr;
}


// url 对应安卓 解码
+ (NSString*)URLdecode:(NSString *)originalString
        stringEncoding:(NSStringEncoding)stringEncoding {
    //!  @  $  &  (  )  =  +  ~  `  ;  '  :  ,  /  ?
    //%21%40%24%26%28%29%3D%2B%7E%60%3B%27%3A%2C%2F%3F
    NSArray *replaceChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" ,    @"$" , @"," ,
                            @"!", @"'", @"(", @")", @"*", nil];
    
    NSArray *escapeChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
                             @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" , @"%2C" ,
                             @"%21", @"%27", @"%28", @"%29", @"%2A", nil];
    
    int len = [escapeChars count];
    
    NSMutableString *temp = [[originalString stringByReplacingPercentEscapesUsingEncoding:stringEncoding] mutableCopy];
    
    int i;
    for (i = 0; i < len; i++) {
        
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    NSString *outStr = [NSString stringWithString: temp];
    return outStr;
}


/**
 添加联系人
 */
+ (void)addContact:(CNContact *)contact {
    // 创建联系人请求
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    
    [saveRequest addContact:[contact mutableCopy] toContainerWithIdentifier:nil];
    // 写入联系人
    CNContactStore *store = [[CNContactStore alloc] init];
    [store executeSaveRequest:saveRequest error:nil];
}


/// 可读化开始时间和结束时间  格式：yyyy-MM-dd HH:mm:ss
/// @param startTime starttime
/// @param endTime endtime
+ (NSString *)getStringReadTimeWithStartTime:(NSString *)startTime andEndTime:(NSString *)endTime {
    NSString *startYear = [NSString getStringRangeOfIndexWithStart:0 andEnd:4 andDealStr:startTime];
    NSString *startMonth = [NSString getStringRangeOfIndexWithStart:5 andEnd:7 andDealStr:startTime];
    NSString *startDay = [NSString getStringRangeOfIndexWithStart:8 andEnd:10 andDealStr:startTime];
    NSString *startHour = [NSString getStringRangeOfIndexWithStart:11 andEnd:13 andDealStr:startTime];
    NSString *startMinute = [NSString getStringRangeOfIndexWithStart:14 andEnd:16 andDealStr:startTime];
    
//    NSString *endYear = [NSString getStringRangeOfIndexWithStart:0 andEnd:4 andDealStr:endTime];
//    NSString *endMonth = [NSString getStringRangeOfIndexWithStart:5 andEnd:7 andDealStr:endTime];
//    NSString *endDay = [NSString getStringRangeOfIndexWithStart:8 andEnd:10 andDealStr:endTime];
    NSString *endHour = [NSString getStringRangeOfIndexWithStart:11 andEnd:13 andDealStr:endTime];
    NSString *endMinute = [NSString getStringRangeOfIndexWithStart:14 andEnd:16 andDealStr:endTime];
    
    // current date
//    NSArray *dateArray = [NSDate getDateYearMonthDayWithDate:[NSDate date]];
//
//    NSString *result = @"";
    
//    if (![startYear isEqualToString:[NSString stringWithFormat:@"%@", dateArray[0]]]) {
//        result = [NSString stringWithFormat:@"%@%@年", result, startYear];
//    } else if (![startMonth isEqualToString:[NSString stringWithFormat:@"%02d", [dateArray[1] intValue]]]) {
//        result = [NSString stringWithFormat:@"%@%@月", result, startMonth];
//    } else if (![startDay isEqualToString:[NSString stringWithFormat:@"%02d", [dateArray[2] intValue]]]) {
//        result = [NSString stringWithFormat:@"%@%@日", result, startDay];
//    }
//    result = [NSString stringWithFormat:@"%@%@:%@-", result, startHour, startMinute];
//
//    if (![endYear isEqualToString:[NSString stringWithFormat:@"%@", dateArray[0]]] && ![startYear isEqualToString:endYear]) {
//        result = [NSString stringWithFormat:@"%@%@年", result, endYear];
//    } else if (![endMonth isEqualToString:[NSString stringWithFormat:@"%02d", [dateArray[1] intValue]]] && ![startMonth isEqualToString:endMonth]) {
//        result = [NSString stringWithFormat:@"%@%@月", result, endMonth];
//    } else if (![endDay isEqualToString:[NSString stringWithFormat:@"%02d", [dateArray[2] intValue]]] && ![startDay isEqualToString:endDay]) {
//        result = [NSString stringWithFormat:@"%@%@日", result, endDay];
//    }
//    result = [NSString stringWithFormat:@"%@%@:%@", result, endHour, endMinute];
    
    
    
    NSString *result = [NSString stringWithFormat:@"%@/%@/%@ %@:%@-%@:%@", startYear, startMonth, startDay, startHour, startMinute, endHour, endMinute];
    if ([endTime isEqual:@""]) {
        result = [NSString stringWithFormat:@"%@/%@/%@ %@:%@-", startYear, startMonth, startDay, startHour, startMinute];
    } else {
        // 是否夸天
        if ([startHour intValue] > [endHour intValue]) {
            result = [NSString stringWithFormat:@"%@+1", result];
        }
    }
    
    return result;
}



/// sip 帐号修正
/// @param account account
+ (NSString *)getSipaccount:(NSString *)account {
    if (account == nil) {
        return @"";
    }
    NSArray *array = [account componentsSeparatedByString:@"\\"];
    NSString *realNumber = array[0];
    if (array.count > 1) {
        realNumber = array[1];
    }
    
    NSArray *array2 = [realNumber componentsSeparatedByString:@"@"];
    if (array2.count > 1) {
        NSString *ipStr = array2[1];
        if ([CommonUtils isValidateIP:ipStr]) {
            return array2[0];
        }
        if ([CommonUtils isValidateIPv6:ipStr]) {
            return array2[0];
        }
    }
    
    return realNumber;
}

/// SeacrhAttendeeNumber 帐号修正
/// @param account account
+ (NSString *)getSeacrhAttendeeNumber:(NSString *)account{
    return account;
}


/// 匹配字符串是否全时某个字符
/// @param inputStr 目标字符串
/// @param c 字符
+ (BOOL)matchSingleCharAllStr:(NSString *)inputStr MatchChar:(NSString *)c {
    // 编写正则表达式，验证mobilePhone是否为手机号码
    NSString *regex = [NSString stringWithFormat:@"^[%@]+$", c];
    // 创建谓词对象并设定条件表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    // 字符串判断，然后BOOL值
    BOOL result = [predicate evaluateWithObject:inputStr];
    
    return result;
}


/// 字符串截取
/// @param goalStr 目标字符串
/// @param str 分隔符
+ (NSArray *)getArraySplitChar:(NSString *)goalStr componentsSeparatedByString:(NSString *)str {
    if (goalStr == nil || goalStr.length == 0 || str == nil || str.length == 0) {
        return nil;
    }
    
    NSArray *array = [goalStr componentsSeparatedByString:str];
    return array;
}



/// 获取APP 的信息
/// @param key key
+ (NSString *)getAppInfoWithKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    return [infoDictionary objectForKey:key];
}

+ (CGFloat)getStrHight:(NSString *)str maxWidth:(CGFloat)width fontSize:(int)font{
   
    CGSize  size = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
    return size.height  + 1  ;
}

+ (CGFloat)getStrWidth:(NSString *)str maxHight:(CGFloat)hight fontSize:(int)font {
    CGSize  size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, hight) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
    return size.width  + 1  ;
}

- (NSInteger)getStringLenthOfBytes {
    NSInteger length = 0;
    for (int i = 0; i < [self length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        if ([self validateChineseChar:s]) {
            length += 3;
        } else {
            length += 1;
        }
    }
    return length;
}

- (NSString *)subBytesOfstringToIndex:(NSInteger)index {
    NSInteger length = 0;
    NSInteger chineseNum = 0;
    NSInteger zifuNum = 0;
    for (int i = 0; i < [self length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        if ([self validateChineseChar:s]) {
            if (length + 3 > index) {
                return [self substringToIndex:chineseNum + zifuNum];
            }
            length += 3;
            chineseNum += 1;
        } else {
            if (length + 1 > index) {
                return [self substringToIndex:chineseNum + zifuNum];
            }
            length += 1;
            zifuNum += 1;
        }
    }
    return [self substringToIndex:index];
}

//检测中文或者中文符号
- (BOOL)validateChineseChar:(NSString *)string {
    if (string && string.length > 0) {
        if ([string stringGetCharLength] % 3 == 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isMatchesRegularExp:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

/// 计算C char的字符长度（包含中英文字符）
- (NSInteger)stringGetCharLength {
    int strLength = 0;
    const char *p = [self cStringUsingEncoding:NSUTF8StringEncoding];
    if (!p) { return 3; }
    for(int i = 0; i < strlen(p); i++) {
        char ch = p[i];
         if ((ch & 0x80) == 1) {
             strLength += 3;
         } else {
             strLength += 1;
         }
    }
    return strLength;
}

+ (NSString *)dealMeetingIdWithSpaceString:(NSString *)number {
    
    if (number.length < 5) { return number; }
    
    // 3+2 3+3 3+4 3+3+2 3+3+3 3+3+4
    NSMutableString *mStr = [[NSMutableString alloc] initWithString:number];
    if (number.length < 8) {
        [mStr insertString:@" " atIndex:3];
    } else {
        [mStr insertString:@" " atIndex:3];
        [mStr insertString:@" " atIndex:7];
    }
    return mStr;
}

+ (NSString *)encryptNumberWithString:(NSString *)string {
    if (string.length < 1) { return nil; }
    if (string.length < 2) {
        return @"*";
    } else if (string.length < 7) {
        string = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"*"];
        return [string stringByReplacingCharactersInRange:NSMakeRange(string.length - 1, 1) withString:@"*"];
    } else {
        NSString *startStr = [NSString getStringRangeOfIndexWithStart:0 andEnd:2 andDealStr:string];
        NSString *endStr = [NSString getStringRangeOfIndexWithStart:string.length - 2 andEnd:string.length andDealStr:string];
        return [NSString stringWithFormat:@"%@***%@", startStr, endStr];
    }
}

+ (NSString *)encryptIPWithString:(NSString *)string {
    if (![string containsString:@"."]) { return string; }
    NSArray *ipArray = [string componentsSeparatedByString:@"."];
    if (ipArray.count < 4) { return string; }
    return [NSString stringWithFormat:@"%@.***.***.%@", ipArray.firstObject, ipArray.lastObject];
}

- (BOOL)validateEmail {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-zA-Z0-9]+([-_.][a-zA-Z0-9]+)*@[a-zA-Z0-9]+([-_.][a-zA-Z0-9]+)*\\.[a-z]{2,}$"];
    return [predicate evaluateWithObject:self];
}

// 获取APP当前语言
+ (BOOL) isCNlanguageOC {
    NSString *str = [NSUserDefaults.standardUserDefaults stringForKey:@"LOCALIZABLE_LANGUAGE_SWITCH"];
    if (str == nil || str.length<=0) {
        NSString *lan = NSLocale.preferredLanguages.firstObject;
        return [lan hasPrefix:@"zh"];
    } else {
        return !([str isEqualToString:@"en"]);
    }
}

@end
