//
//  LoginCenter.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "LoginServerInfo.h"

typedef NS_ENUM(NSInteger, CallSipStatus)
{
    kCallSipStatusUnRegistered         = 0,     // sip status: unregistered
    kCallSipStatusRegistering          = 1,     // sip status: registering
    kCallSipStatusRegistered           = 2,     // sip status: registered
};

typedef NS_ENUM(NSInteger, UserLoginStatus)
{
    kUserLoginStatusUnLogin             = 0,        // user status: not login
    kUserLoginStatusOnline              = 1,        // user status: online
    kUserLoginStatusOffline             = 2,        // user status: offline
};

@interface LoginCenter : NSObject

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+ (instancetype)sharedInstance;

/**
 * This method is used to login uportal authorize.
 *登陆uportal鉴权
 *@param account user account
 *@param pwd user password
 *@param serverUrl uportal address
 *@param port uportal port
 *@param sipUrl  device current ip address
 *@param loginCompletionBlock login result call back
 *@param changePawCompletionBlock  首次修改密码
 */
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)pwd
               serverUrl:(NSString *)serverUrl
              serverPort:(NSUInteger)port
                  sipUrl:(NSString *)sipUrl
         loginCompletion:(void (^)(BOOL isSuccess, NSError *error))loginCompletionBlock
     changePawCompletion:(void (^)(BOOL isSuccess, NSError *error))changePawCompletionBlock;

/**
 * This method is used to change password.
 *修改密码
 *@param oldPassword 老密码
 *@param newPassword 新密码
 *@param completionBlock change result call back
 */
- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                           completion:(void (^)(BOOL isSuccess,
                                                NSError *error))completionBlock;

/**
 * This method is used to logout server
 * 注销
 *@param completionBlock             Indicates change result callback
 *                                   登出结果回调
 */
- (void)logoutCompletionBlock:(void (^)(BOOL isSuccess, NSError *error))completionBlock;

/**
 * This method is used to get uportal login server info.
 * 获取当前登陆信息
 *@return server info
 */
- (LoginServerInfo *)currentServerInfo;

/**
 * This method is used to judge whether server connect use stg tunnel
 * 是否连接STG隧道
 *@return BOOL
 */
- (BOOL)isSTGTunnel;

/**
 * This method is used to set configuration information
 * 设置配置信息
 * @param serverAddress 服务器地址
 * @param serverPort 服务器端口
 */
//-(void)configSipRelevantParamServerAddress:(NSString *)serverAddress
//                                serverPort:(NSString *)serverPort;

/**
 * 通过<ServerConfigInfo>设置服务器配置信息
 */
- (void)updateServerConfigInfo:(BOOL)isSetIP;

/**
 *证书校验
 */
- (BOOL)isCalibrateCerSuccess;

/*
 未设置本地ip地址，在未配置的情况下
 */
- (void)setLocalIp;

/// 二次重连设置ip地址
/// @param isNullIp false: 传本机的ip地址，true:下发空地址
- (void)setReconnectLocalIpWithInullIp:(BOOL)isNullIp;

/// 设置用户状态
/// @param loginStatus 用户状态
- (void)setUserLoginStatus:(UserLoginStatus)loginStatus;

/// 获取用户状态
- (UserLoginStatus)getUserLoginStatus;

@end

extern NSString * const UPortalTokenKey;
extern NSString * const CallRegisterStatusKey;
extern NSString * const PushTimeEnableRecoud;

