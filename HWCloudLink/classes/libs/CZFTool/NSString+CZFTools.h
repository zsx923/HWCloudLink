//
//  NSString+CZFTools.h
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

@interface NSString (CZFTools)

/**
 *  获取当前时间戳 - return转字符串
 */
+ (NSString *)getTimestamp;

/**
 *  获取唯一字符串 设备id+时间戳的字符串
 *
 *  @return 唯一字符串
 */

+ (NSString *)getUniqueID;


/**
 *  获取本地时间  （标准格式：yyyy-MM-dd HH:mm:ss）
 *
 *  @return 本地时间字符串
 */

+ (NSString *)getLocalTime;


/**
 *  将数字的字符串转成随机的pm2.5
 *
 *  @param string 源字符串
 *
 *  @return 目标字符串
 */

+ (NSString *)randomStringWithString:(NSString *) string;


/**
 *  可读格式化存储大小
 *
 *  @param size 存储大小   单位：B
 *
 *  @return B, K, M, G 为单位
 */
+ (NSString *)fileSizeWithInterge:(NSInteger)size;


/**
 *  验证是否为手机号
 *
 *  @param phoneNum 要验证的手机号码
 *
 *  @return 是否为手机号
 */

+(BOOL)checkPhoneNumInputWithPhoneNum:(NSString *)phoneNum;


/**
 验证邮箱
 
 @param email email
 @return 是否是邮箱
 */
+ (BOOL)checkEmailInputWithEmail:(NSString *)email;


/**
 * 字母、数字、中文正则判断（不包括空格）
 */
+ (BOOL)isInputRuleNotBlank:(NSString *)str;


/**
 * 字母、数字、中文正则判断（包括空格）【注意3】
 */
+ (BOOL)isInputRuleAndBlank:(NSString *)str;


/**
 *  获得 kMaxLength长度的字符
 */
+ (NSString *)getSubCharString:(NSString*)string andMaxLength:(int)mexLength;


/**
 *  获得 kMaxLength长度的字
 */
+ (NSString *)getSubWordString:(NSString*)string andMaxLength:(int)mexLength;


/**
 *  过滤字符串中的emoji
 */
+ (NSString *)disable_emoji:(NSString *)text;


/*
 *第二种方法，利用Emoji表情最终会被编码成Unicode，因此，
 *只要知道Emoji表情的Unicode编码的范围，
 *就可以判断用户是否输入了Emoji表情。
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;


/**
 *  校验字符串防止nil字符串操作
 *
 *  @param stringText 字符串
 *
 *  @return 校验后的字符串
 */
+ (NSString *)verifyString:(id)stringText;


/**
 过滤字符串中HTML标签的方法
 
 @param html 含HTML标签的字符串
 @return    过滤后的字符串
 */
+ (NSString *)flattenHTML:(NSString *)html;


/**
 判断本地是否存在该文件
 
 @param fileName 文件名称或者路径
 @return 存在的文件路径，不存在则返回nil
 */
+ (NSString *)checkFilePathExistWithFileName:(NSString *)fileName;


/**
 统计目录文件下文件的总大小
 
 @param folderPath 目录地址
 @return 总大小
 */
+ (long long)folderSizeWithPath:(NSString *)folderPath;


/**
 计算指定文件的大小
 
 @param filePath 文件地址
 @return 大小
 */
+ (long long)fileSizeWithPath:(NSString *)filePath;


/**
 删除指定目录下的所有文件
 
 @param folderPath 目录地址
 */
+ (void)removeFolderPathAndFileWithPath:(NSString *)folderPath;


/**
 url参数字符串转字典
 
 @param urlStr url参数字符串
 @return 结果字典
 */
+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr;


/**
 json 字符串转字典的方法
 
 @param jsonString json字符串
 @return 转换后的字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


/**
 改变字符start 和 end 之间的字符的颜色 和 字体大小
 
 @param theTextView UITextView
 @param start 开始字符串
 @param end 结束字符串
 @param allColor 整体颜色
 @param markColor 想要标注的颜色
 @param fontSize 字体大小
 */
+ (void)messageAction:(UITextView *)theTextView startString:(NSString *)start endString:(NSString *)end andAllColor:(UIColor *)allColor andMarkColor:(UIColor *)markColor andMarkFondSize:(float)fontSize;


/**
 *判断字符串是否不全为空
 */
+ (BOOL)judgeStringIsNull:(NSString *)string;


/**
 判断字符串是否为纯数字
 
 @param checkedNumString 字符串
 @return 结果Bool类型
 */
+ (BOOL)isNum:(NSString *)checkedNumString;


/**
 判断字符串是否为格式字符串中的字符
 
 @param string 要匹配的字符串
 @param formatStr 字符串格式 (字母数字：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789，
 字母：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz，
 数字：0123456789，
 数字与小数点：.0123456789)
 @return yes,no
 */
+(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string andFormat:(NSString *)formatStr;


/**
 根据字符串中后缀的格式类型返回对应的本地文件类型图标
 
 @param checkString 判断字符串
 @return 本地文件类型的图标地址
 */
+ (NSString *)getLocalImageWithCheckString:(NSString *)checkString;


// 字符串进行UTF8编码
+ (NSString *)stringAddEncodeWithString:(NSString *)str;


// 字符串进行UTF8解码
+ (NSString *)stringReplaceEncodeWithString:(NSString *)str;


// MARK: 隐藏手机中间4位为*号
+ (NSString *)stringPhoneNumEncodeStartWithString:(NSString *)str;


/**
 根据PM2.5值获取污染程度描述
 
 @param pm25Value pm2.5值
 @return pm2.5描述
 */
+ (NSString *)stringPm25LevelDescription:(NSInteger)pm25Value;


/**
 将距离变成可读的格式
 
 @param distance 距离
 @return 可读字符串
 */
+ (NSString *)stringReadDistanceWith:(CGFloat)distance;


/**
 调用系统的MD5加密
 
 @param input 源字符串
 @return 目标字符串
 */
+ (NSString *)md5:(NSString *)input;


/**
 获取指定开始和结束的字符串
 
 @param startStr 开始的字符串
 @param endStr 结束的字符串
 @param string 待处理字符串
 @return 目标字符串
 */
+ (NSString *)getStringRangeOfStringWithStart:(NSString *)startStr andEnd:(NSString *)endStr andDealStr:(NSString *)string;

/// 获取指定开始和结束的字符串-- index
/// @param startIndex index
/// @param endIndex index
/// @param string string
+ (NSString *)getStringRangeOfIndexWithStart:(NSInteger)startIndex andEnd:(NSInteger)endIndex andDealStr:(NSString *)string;


/**
 根据详细地址字符串获取城市名称
 
 @param addressStr 地址字符串
 @return 城市名
 */
+ (NSString *)getCityNameWithAddressStr:(NSString *)addressStr;

/**
 根据详细地址字符串获取省和城市名称
 
 @param addressStr 地址字符串
 @return 省和城市名
 */
+ (NSString *)getCityAndProinceNameWithAddressStr:(NSString *)addressStr;


/**
 去掉小数点后边多余的0
 
 @param string 源字符串
 @return 目标字符串
 */
+(NSString*)removeFloatAllZero:(NSString*)string;


/**
 
 *  验证手机号以及固话方法
 
 *  @param number 电话号
 
 *  @return BOOL yes格式正确 no格式错误
 
 */
+ (BOOL)checkContactNumber:(NSString *)number;


/**
 
 *  验证只能输入数字、汉字、字母
 *  @param text 需要验证字符串
 *  @return BOOL yes格式正确 no格式错误
 
 */
+ (BOOL)checkIsNumHanZimu:(NSString *)text;


//+ (BOOL)

/**
 获取地址中的Ip和端口
 
 @param webUrlStr 请求地址（必须包含ip和端口）
 @return ip和端口的数据
 */
+ (NSArray<NSString *> *)getWebUrlIpAndPort:(NSString *)webUrlStr;


/// 去掉前后中间的空格
/// @param str str
/// @param isRemoveMiddle 是否去掉中间的空格
+ (NSString *)removeWhiteSpace:(NSString *)str andIsRemoveMiddle:(BOOL)isRemoveMiddle;

/// 获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
/// @param aString 传入汉字字符串
+ (NSString *)firstCharactor:(NSString *)aString;

///  获取联系人对象中所有手机号
/// @param contact CNContact对象
+ (NSMutableDictionary *)phonesWithCNContact:(CNContact *)contact;

/// ios9之后的通讯录转Vcard(版本2.1)字符串-- 太大的通讯录会内存溢出，要使用存入本地文件, 返回的是vcf格式文件个地址
/// @param contacts contacts description
+ (NSString *)generateVCard21StringWithContacts:(NSArray<CNContact *> *)contacts;

/**
 添加联系人
 */
+ (void)addContact:(CNContact *)contact;

/// 可读化开始时间和结束时间  格式：yyyy-MM-dd HH:mm:ss
/// @param startTime starttime
/// @param endTime endtime
+ (NSString *)getStringReadTimeWithStartTime:(NSString *)startTime andEndTime:(NSString *)endTime;

/// sip 帐号修正
/// @param account account
+ (NSString *)getSipaccount:(NSString *)account;

/// SeacrhAttendeeNumber 帐号修正
/// @param account account
+ (NSString *)getSeacrhAttendeeNumber:(NSString *)account;

/// 匹配字符串是否全时某个字符
/// @param inputStr 目标字符串
/// @param c 字符
+ (BOOL)matchSingleCharAllStr:(NSString *)inputStr MatchChar:(NSString *)c;

/// 字符串截取
/// @param goalStr 目标字符串
/// @param str 分隔符
+ (NSArray *)getArraySplitChar:(NSString *)goalStr componentsSeparatedByString:(NSString *)str;

/// 获取APP 的信息
/// @param key key
+ (NSString *)getAppInfoWithKey:(NSString *)key;



/// 获取文字的高度
/// @param str 输入的文字信息
/// @param width 宽度
/// @param font 字体大小
+ (CGFloat)getStrHight:(NSString *)str maxWidth:(CGFloat)width fontSize:(int)font;


+ (CGFloat)getStrWidth:(NSString *)str maxHight:(CGFloat)hight fontSize:(int)font;


- (NSInteger)getStringLenthOfBytes;

- (NSString *)subBytesOfstringToIndex:(NSInteger)index;

//检测中文或者中文符号
- (BOOL)validateChineseChar:(NSString *)string;

// 获取中英文字符长度
- (int)convertToInt;

//检测中文
//- (BOOL)validateChinese:(NSString *)string;

- (BOOL)isMatchesRegularExp:(NSString *)regex;

/// 会议ID添加空格
+ (NSString *)dealMeetingIdWithSpaceString:(NSString *)number;

/// 加密打印信息
+ (NSString *)encryptNumberWithString:(NSString *)string;

+ (NSString *)encryptIPWithString:(NSString *)string;

// 是否合法邮箱
- (BOOL)validateEmail;

// 获取APP当前语言
+ (BOOL) isCNlanguageOC;

@end
