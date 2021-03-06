//
//  CommonUtils.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Defines.h"
#import <UIKit/UIKit.h>

@interface CommonUtils : NSObject

/**
 *This method is used to transform UTC date to local date
 *将UTC时间转为本地时间
 @param utcDate UTC date
 @return string
 */
+(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;

/**
 *This method is used to decode string from base64
 *对base64编码的字符串进行解码
 *@param base64 destination string
 *@return string
 */
+ (NSString *)textFromBase64String:(NSString *)base64;

/**
 *This method is used to check string is empty or not
 *判断字符串是否为非空
 *@param string destination string
 *@return YES or NO
 */
+(BOOL)checkIsNotEmptyString:(NSString *)string;

/**
 *This method is used to save user config
 *保存用户数据
 *@param anyValue value
 *@param key destination string
 */
+(void)userDefaultSaveValue:(id)anyValue forKey:(NSString *)key;

/**
 *This method is used to get user default value
 *获取用户存储的值
 @param key key
 @return value
 */
+(id)getUserDefaultValueWithKey:(NSString *)key;

/**
 *This method is used to check is VPN connect or not
 *检查vpn是否连接
 *@return YES or NO
 */
+(BOOL)checkIsVPNConnect;

/**
 *This method is used to get local IP address
 *获取本地ip地址
 @param isVpnAddress YES or NO
 @return ipv4
 */
+(NSString *)getLocalIpAddressWithIsVPN:(BOOL)isVpnAddress;

/**
 *This method is used to get local IP address
 *获取本地ipv6地址
 @param isVpnAddress YES or NO
 @param serverAddrIsIPv6 YES or NO  用户配置的服务器是否ipv6地址
 @return ipv6 or ipv4
 */
+ (NSString *)getLocalIpAddressWithIsVPN:(BOOL)isVpnAddress serverAddrIsIPV6:(BOOL)serverAddrIsIPv6;

/**
 *This method is used to judge whether ip address is valid
 *判断ip地址是否有效
 */
+ (BOOL)isValidateIP:(NSString *)ipAddress;

/**
 * 判断是否ipv6地址
 @param address 用户配置的服务器
 @return YES or NO
 */
+ (BOOL)isValidateIPv6:(NSString *)address;

/**
 *This method is used to set view controller orientation
 *旋转屏幕
 *@param toOrientation 方向
 */
+ (void)setToOrientation:(UIDeviceOrientation)toOrientation;

@end
