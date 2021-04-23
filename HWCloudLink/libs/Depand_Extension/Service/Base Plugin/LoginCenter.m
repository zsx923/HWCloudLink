//
//  LoginCenter.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "LoginCenter.h"
#import "Initializer.h"
#import "Defines.h"
#include <arpa/inet.h>
#import "tsdk_error_def.h"
#import "tsdk_login_def.h"
#import "tsdk_login_interface.h"
#import "tsdk_manager_interface.h"
#import "CommonUtils.h"
#import "ManagerService.h"
#import "securec.h"
#import "Logger.h"
#import "RecordNotifycationManager.h"
#import "NSString+CZFTools.h"
#import "NetworkUtils.h"

#define PEM_PATH(path) [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",path] ofType:nil]
#define STR(path,path1) [NSString stringWithFormat:@"%@/%@",path,path1]

NSString * const UPortalTokenKey = @"UPortalTokenKey";
NSString * const CallRegisterStatusKey = @"CallRegisterStatusKey";
NSString * const PushTimeEnableRecoud = @"PushTimeEnableRecoud";

static LoginCenter *g_loginCenter = nil;
// change at xuegd 2021-01-07 : SDK未处理，发送事件过多，暂时通过全局变量进行规避，SDK解决后可删除相关判断
static int userOnlineState = 1; // 0: 在线, 1: 离线

@interface LoginCenter ()<TupLoginNotification>
{
    dispatch_queue_t _uportalPushConfigQueue;           //push设置队列(串行)
}
@property (nonatomic, strong)LoginServerInfo *loginServerInfo;                           // LoginServerInfo
@property (nonatomic, assign)BOOL bSTGTunnel;                                             // is connected STG or not
@property (nonatomic, assign)TUP_FIREWALL_MODE firewallMode;                               // fire wall mode
@property (nonatomic, strong)void (^loginCallBackAction)(BOOL, NSError*);                // 登陆block回调
@property (nonatomic, strong)void (^logoutCallBackAction)(BOOL, NSError*);               // 登出block回调
@property (nonatomic, strong)void (^changePasswordCallBackAction)(BOOL, NSError*);       // 修改密码block回调
@property (nonatomic, copy)NSString *ipAddress;                                          // ip address
@property (nonatomic, assign) UserLoginStatus uLoginStatus;                              // user login status
@end

@implementation LoginCenter

/**
 * This method is used to init this class
 * 初始化该类
 */
- (id)init
{
    if (self = [super init]) {
        _uportalPushConfigQueue = dispatch_queue_create("com.huawei.tsdk.uportalPushConfig", DISPATCH_QUEUE_SERIAL);
        [Initializer registerLoginCallBack:self];
    }
    return self;
}

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_loginCenter = [[LoginCenter alloc] init];
        g_loginCenter.uLoginStatus = kUserLoginStatusUnLogin;
    });
    return g_loginCenter;
}

/**
 * This method is used to login uportal authorize.
 * 登陆uportal鉴权
 *@param account user account
 *@param pwd user password
 *@param serverUrl uportal address
 *@param port uportal port
 *@param loginCompletionBlock login result call back
 *@param changePawCompletionBlock  首次修改密码
 */
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)pwd
               serverUrl:(NSString *)serverUrl
              serverPort:(NSUInteger)port
                  sipUrl:(NSString *)sipUrl
         loginCompletion:(void (^)(BOOL isSuccess, NSError *error))loginCompletionBlock
     changePawCompletion:(void (^)(BOOL isSuccess, NSError *error))changePawCompletionBlock
{
    [self updateServerConfigInfo:true];
    TSDK_S_LOGIN_PARAM loginParam;
    memset_s(&loginParam, sizeof(TSDK_S_LOGIN_PARAM), 0, sizeof(TSDK_S_LOGIN_PARAM));
    
    // 用户id，需要APP生成
    loginParam.user_id = 1;
    // 鉴权类型
    loginParam.auth_type = TSDK_E_AUTH_NORMAL;
    // 账户用户名，鉴权类型为 TSDK_E_AUTH_NORMAL 时填写
    strcpy_s(loginParam.user_name, sizeof(loginParam.user_name), [account UTF8String]);
    // 账户密码，鉴权类型为 TSDK_E_AUTH_NORMAL 时填写
    strcpy_s(loginParam.password, sizeof(loginParam.password), [pwd UTF8String]);
    // 服务器类型，当前仅支持 TSDK_E_SERVER_TYPE_PORTAL 和 TSDK_E_SERVER_TYEP_SMC
    loginParam.server_type = TSDK_E_SERVER_TYPE_SMC;
    // 可选，SIP 域名
    strcpy_s(loginParam.sip_uri, sizeof(loginParam.sip_uri), [sipUrl UTF8String]);
    
    TSDK_RESULT result = tsdk_login(&loginParam);
    DDLogInfo(@"Login_Log: tsdk_login result = %#x",result);
    
    if (result != TSDK_SUCCESS) {
        if (loginCompletionBlock) {
            NSError *error = [NSError errorWithDomain:@"" code:result userInfo:nil];
            loginCompletionBlock(0, error);
        }
    } else {
        self.loginCallBackAction = loginCompletionBlock;
        self.changePasswordCallBackAction = changePawCompletionBlock;
        LoginServerInfo *loginAccessServer = [[LoginServerInfo alloc] init];
        loginAccessServer.eserverUri = serverUrl;
        loginAccessServer.maaUri = serverUrl;
        loginAccessServer.sipAccount = sipUrl.length ? sipUrl : account;
        loginAccessServer.sipPwd= pwd;
        loginAccessServer.sipUri = sipUrl;
        loginAccessServer.userName = account;
        loginAccessServer.authServerPort = port;
        loginAccessServer.httpsproxyUri = serverUrl;
        self.loginServerInfo = loginAccessServer;
    }
}

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
                                                NSError *error))completionBlock{
    TSDK_S_LOGIN_CHANGE_PASSWORD_PARAM passwordParam;
    memset_s(&passwordParam, sizeof(TSDK_S_LOGIN_CHANGE_PASSWORD_PARAM), 0, sizeof(TSDK_S_LOGIN_CHANGE_PASSWORD_PARAM));
    strcpy_s(passwordParam.oldPassword, sizeof(passwordParam.oldPassword), [oldPassword UTF8String]);
    strcpy_s(passwordParam.newPassword, sizeof(passwordParam.newPassword), [newPassword UTF8String]);
    TSDK_RESULT result = tsdk_change_password(&passwordParam);
    DDLogInfo(@"tsdk_change_password result = %d",result);
    if (result != TSDK_SUCCESS) {
        NSError *error = [NSError errorWithDomain:@"" code:result userInfo:nil];
        completionBlock(NO, error);
    } else {
        if (self.changePasswordCallBackAction) {
            self.changePasswordCallBackAction = completionBlock;
        }
    }
}

- (BOOL)isCalibrateCerSuccess {
    BOOL isSuccess = true;
    NSDate *dateNow = [NSDate date];
    NSUInteger timeNow = (NSUInteger)[dateNow timeIntervalSince1970];

    for (NSNumber *type in @[@0, @1, @2]) {
        NSUInteger effectiveTime = [self calibrateCertificateVerify:[type intValue]];
        isSuccess = isSuccess && (timeNow < effectiveTime);
    }
    return  isSuccess;
}

/**
 *证书校验
 *@param cerType 证书类型: 0根证书, 1设备证书, 2国密
 */
- (NSUInteger)calibrateCertificateVerify:(int)cerType {
    /* add at xuegd: 这块验证设备证书时，如果报公钥长度 2048  把 type 改为 2，然后就不会对公钥长度进行校验
     TSDK_E_CERT_TYPE_ROOT = 0,  [cn]根证书
     TSDK_E_CERT_TYPE_DEVICES,   [cn]设备证书
     TSDK_E_CERT_TYPE_GM,        [cn]国密
     */
    int indexType = cerType;
    
    TSDK_S_CMPT_DATETIME  expireTime;
    TSDK_S_CMPT_CHECK_INFO acCheckInfo;
    memset_s(&acCheckInfo, sizeof(TSDK_S_CMPT_CHECK_INFO), 0, sizeof(TSDK_S_CMPT_CHECK_INFO));

    NSString *rootCertPath = PEM_PATH(@"vc_gm_cert_cloudlink/root");
    NSString *clientCertPath = PEM_PATH(@"vc_gm_cert_cloudlink/inCertificate");
    NSString *gmCertPath = PEM_PATH(@"vc_gm_cert_cloudlink/smCertificate");

    NSArray *pathsAndKeys = @[
        @[
            STR(rootCertPath, @"root_thundersoft.pem"),
            STR(rootCertPath, @"root_thundersoft.pem"),
        ],
        @[
            STR(clientCertPath, @"equip.pem"),
            STR(clientCertPath, @"equip_key.pem")
        ],
        @[
            STR(gmCertPath, @"equip_cloudlink.pem"),
            STR(gmCertPath, @"equip_key_cloudlink.pem"),
        ]
    ];
        
    acCheckInfo.certType = indexType;
    // 证书颁发机构通用名，校验用
    strcpy_s(acCheckInfo.acName, sizeof(acCheckInfo.acName), [@"thundersoft" UTF8String]);
    // 证书路径
    strcpy_s(acCheckInfo.acPath, sizeof(acCheckInfo.acPath), [pathsAndKeys[indexType][0] UTF8String]);
    // 证书私钥路径
    strcpy_s(acCheckInfo.acKeyPath, sizeof(acCheckInfo.acKeyPath), [pathsAndKeys[indexType][1] UTF8String]);
    // 秘钥签名密码：Change_Me
    strcpy_s(acCheckInfo.acPrivkeyPwd, sizeof(acCheckInfo.acPrivkeyPwd), [@"Change_Me" UTF8String]);
    TSDK_RESULT result = tsdk_certificate_verify(&acCheckInfo, &expireTime);
    DDLogInfo(@"tsdk_certificate_verify result = %d",result);
    if (result == TSDK_SUCCESS) {
        DDLogInfo(@"CalibrateCertificateVerify success!");
        return (NSUInteger)expireTime.sec64;
    } else {
        DDLogInfo(@"CalibrateCertificateVerify fail, code is %d", result);
        return 0;
    }
}

/**
 * 通过<ServerConfigInfo>设置服务器配置信息
 */
- (void)updateServerConfigInfo:(BOOL)isSetIP {
    // change at xuegd: 对应的是：ServerConfigInfo.valuesArray()
    NSArray *serverConfigInfo = [CommonUtils getUserDefaultValueWithKey:SERVER_CONFIG_INFO];
    NSString *address = serverConfigInfo[0];
    NSString *port = serverConfigInfo[1];
    NSString *srtp = serverConfigInfo[5];
    NSString *transport = serverConfigInfo[6];
    NSString *bfcp = serverConfigInfo[7];
    NSString *smSecurity = serverConfigInfo[10];
    NSString *tlsCompatible = serverConfigInfo[11];
    NSString *httpsPort = @"";
    if (serverConfigInfo.count > 12) {
        httpsPort = serverConfigInfo[12];
    }
    
    TSDK_RESULT configResult = 0;
    if (isSetIP) {
        // 本地 ip 地址
        TSDK_S_LOCAL_ADDRESS local_ip;
        memset_s(&local_ip, sizeof(TSDK_S_LOCAL_ADDRESS), 0, sizeof(TSDK_S_LOCAL_ADDRESS));

        //判断服务器地址是否 IPV6
        BOOL serverAddrIsIPV6 = [CommonUtils isValidateIPv6: address];
        BOOL isVPNConnect = [CommonUtils checkIsVPNConnect];
        NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN: isVPNConnect serverAddrIsIPV6: serverAddrIsIPV6];
        strcpy_s(local_ip.ip_address, sizeof(local_ip.ip_address), [ip UTF8String]);
        configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
        DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, [NSString encryptIPWithString:ip]);
    }
    

    //config security param
    if (serverConfigInfo == nil) {
        return;
    }
    
    TSDK_E_MEDIA_SRTP_MODE mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_DISABLE;
    SRTP_MODE srtpMode = [srtp intValue];
    switch (srtpMode) {
        case SRTP_MODE_DISABLE:
            mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_DISABLE;
            DDLogInfo(@"MEDIA_SRTP_MODE = DISABLE");
            break;
        case SRTP_MODE_OPTION:
            mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_OPTION;
            DDLogInfo(@"MEDIA_SRTP_MODE = OPTION");
            break;
        case SRTP_MODE_FORCE:
            mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_FORCE;
            DDLogInfo(@"MEDIA_SRTP_MODE = FORCE");
            break;
        default:
            break;
    }
    
    TSDK_E_SIP_TRANSPORT_MODE transportMode = TSDK_E_SIP_TRANSPORT_UDP;
    TRANSPORT_MODE transmode = [transport intValue];
    switch (transmode) {
        case TRANSPORT_MODE_UDP:
            transportMode = TSDK_E_SIP_TRANSPORT_UDP;
            DDLogInfo(@"SIP_TRANSPORT_MODE = UDP");
            break;
        case TRANSPORT_MODE_TLS:
            transportMode = TSDK_E_SIP_TRANSPORT_TLS;
            DDLogInfo(@"SIP_TRANSPORT_MODE = TLS");
            break;
        case TRANSPORT_MODE_TCP:
            transportMode = TSDK_E_SIP_TRANSPORT_TCP;
            DDLogInfo(@"SIP_TRANSPORT_MODE = TCP");
            break;
        default:
            break;
    }
    
    TSDK_E_BFCP_TRANSPORT_MODE bfcpModel = [bfcp intValue];
    DDLogInfo(@"BFCP_TRANSPORT_MODE = %d", bfcpModel);

    TSDK_S_SERVICE_SECURITY_PARAM securityParam;
    memset_s(&securityParam, sizeof(TSDK_S_SERVICE_SECURITY_PARAM), 0, sizeof(TSDK_S_SERVICE_SECURITY_PARAM));

    securityParam.bfcp_transport_mode = bfcpModel;
    securityParam.media_srtp_mode = mediaSrtpMode;
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_SECURITY_PARAM, &securityParam);
    DDLogInfo(@"config security param result: %d", configResult);

    //config network info
    TSDK_S_NETWORK_INFO_PARAM networkInfo;
    memset_s(&networkInfo, sizeof(TSDK_S_NETWORK_INFO_PARAM), 0, sizeof(TSDK_S_NETWORK_INFO_PARAM));
    networkInfo.sip_transport_mode = transportMode;
    networkInfo.sip_server_port = port.integerValue;
    if (httpsPort.length > 0) {
        networkInfo.https_server_port = httpsPort.integerValue;
    }
    strcpy_s(networkInfo.server_addr, sizeof(networkInfo.server_addr), [address UTF8String]);

    configResult = tsdk_set_config_param(TSDK_E_CONFIG_NETWORK_INFO, &networkInfo);
    DDLogInfo(@"config network info result: %d", configResult);

    NSString *clientCertPath = PEM_PATH(@"vc_gm_cert_cloudlink/inCertificate");
    NSString *gmCertPath = PEM_PATH(@"vc_gm_cert_cloudlink/smCertificate");
    NSString *rootCertPath = PEM_PATH(@"vc_gm_cert_cloudlink");
    NSString *gmRootPath = PEM_PATH(@"vc_gm_cert_cloudlink/smRoot/");

    // change at xuegd: TLS 证书路径配置
    TSDK_S_TLS_PARAM tlsParam;
    memset_s(&tlsParam, sizeof(TSDK_S_TLS_PARAM), 0, sizeof(TSDK_S_TLS_PARAM));
    tlsParam.tlsCompatible = (TSDK_BOOL)[tlsCompatible intValue];
    //cert
    strcpy_s(tlsParam.tlsInParam.caCertPath, sizeof(tlsParam.tlsInParam.caCertPath), [STR(rootCertPath, @"root/") UTF8String]);
    strcpy_s(tlsParam.tlsInParam.clientCertPath, sizeof(tlsParam.tlsInParam.clientCertPath), [STR(clientCertPath, @"equip.pem") UTF8String]);
    strcpy_s(tlsParam.tlsInParam.clientKeyPath, sizeof(tlsParam.tlsInParam.clientKeyPath), [STR(clientCertPath, @"equip_key.pem") UTF8String]);
    strcpy_s(tlsParam.tlsInParam.clientPrivkeyPwd, sizeof(tlsParam.tlsInParam.clientPrivkeyPwd), [@"Change_Me" UTF8String]);
    
    // change at xuegd: 国密证书路径配置
    NSString *gmIsOn = smSecurity;
    tlsParam.tlsGmParam.isOpenSm = (TSDK_BOOL)[gmIsOn intValue];
    strcpy_s(tlsParam.tlsGmParam.gmcaDirPath, sizeof(tlsParam.tlsGmParam.gmcaDirPath), [gmRootPath UTF8String]);
    
    strcpy_s(tlsParam.tlsGmParam.gmencSerCertPath, sizeof(tlsParam.tlsGmParam.gmencSerCertPath), [STR(gmCertPath, @"equip_cloudlink_enc.pem") UTF8String]);
    strcpy_s(tlsParam.tlsGmParam.gmencSerKeyCertPath, sizeof(tlsParam.tlsGmParam.gmencSerKeyCertPath), [STR(gmCertPath, @"equip_key_cloudlink_enc.pem") UTF8String]);
    strcpy_s(tlsParam.tlsGmParam.gmencSerKeyFilePsw, sizeof(tlsParam.tlsGmParam.gmencSerKeyFilePsw), [@"Change_Me" UTF8String]);
    strcpy_s(tlsParam.tlsGmParam.gmsignSerCertPath, sizeof(tlsParam.tlsGmParam.gmsignSerCertPath), [STR(gmCertPath, @"equip_cloudlink.pem") UTF8String]);
    strcpy_s(tlsParam.tlsGmParam.gmsignSerKeyCertPath, sizeof(tlsParam.tlsGmParam.gmsignSerKeyCertPath), [STR(gmCertPath, @"equip_key_cloudlink.pem") UTF8String]);
    strcpy_s(tlsParam.tlsGmParam.gmsignSerKeyFilePsw, sizeof(tlsParam.tlsGmParam.gmsignSerKeyFilePsw), [@"Change_Me" UTF8String]);
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_TLS_PARAM, &tlsParam);
    DDLogInfo(@"config tls param result: %d", configResult);
}

/**
 * This method is used to get uportal login server info.
 * 获取当前登陆信息
 *@return server info
 */
- (LoginServerInfo *)currentServerInfo
{
    return _loginServerInfo;
}

/**
 * This method is used to judge whether server connect use stg tunnel.
 * 是否连接STG隧道
 *@return BOOL
 */
- (BOOL)isSTGTunnel
{
    return _bSTGTunnel;
}

/**
 * This method is used to logout server
 * 注销
 *@param completionBlock             Indicates change result callback
 *                                   登出结果回调
 */
- (void)logoutCompletionBlock:(void (^)(BOOL isSuccess, NSError *error))completionBlock
{
    TSDK_RESULT ret = tsdk_logout();
    BOOL result = (TSDK_SUCCESS == ret) ? YES : NO;
    if (!completionBlock) {
        return;
    }
    if (result) {
        completionBlock(result, nil);
    } else {
        self.logoutCallBackAction = completionBlock;
    }
    /*
    if (!result) {
        if (completionBlock) {
            completionBlock(result, nil);
        }
    } else {
        self.logoutCallBackAction = completionBlock;
    }
     */
}

/**
 * This method is used to deel login event callback and login sip event callback from service.
 * 分发登陆业务和登陆sip业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)loginModule:(TUP_MODULE)module notification:(Notification *)notification
{
    [self onRecvLoginNotification:notification];
}

-(void)onRecvLoginNotification:(Notification *)notify
{
    CallSipStatus sipStatus = kCallSipStatusUnRegistered;
    switch(notify.msgId) {
        case TSDK_E_LOGIN_EVT_AUTH_SUCCESS: // 鉴权成功(用于呈现登录过程，应用层一般无需处理)
        {
            /*
            TSDK_S_IM_LOGIN_PARAM *im_login_parama = (TSDK_S_IM_LOGIN_PARAM *)notify.data;

            LoginServerInfo *LoginAccessServer = [[LoginServerInfo alloc] init];
            LoginAccessServer.eserverUri = [NSString stringWithUTF8String:im_login_parama->e_server_uri];
            LoginAccessServer.maaUri = [NSString stringWithUTF8String:im_login_parama->maa_server_uri];
            LoginAccessServer.sipAccount = [NSString stringWithUTF8String:im_login_parama->account];
            LoginAccessServer.sipPwd= [NSString stringWithUTF8String:im_login_parama->password];
            LoginAccessServer.token = [NSString stringWithUTF8String:im_login_parama->token];
            self.loginServerInfo = LoginAccessServer;
            
            NSArray *pushTime = [CommonUtils getUserDefaultValueWithKey:PushTimeEnableRecoud];
            NSString *noPushStart = nil;
            NSString *noPushEnd = nil;
            BOOL enableNoPushByTime = NO;
            if (pushTime != nil) {
                enableNoPushByTime = [pushTime[0] boolValue];
                noPushStart = pushTime[1];
                noPushEnd = pushTime[2];
            }
            [self configUportalAPNSEnable:YES noPushStartTime:noPushStart noPushEndTime:noPushEnd enableNoPushByTime:enableNoPushByTime];
            */
            /*
             param1：TSDK_UINT32 user_id [cn]用户ID
             param2：None
             data：  TSDK_S_IM_LOGIN_PARAM* im_account_param [cn]IM 帐号信息参数，用于支持原子级IM SDK兼容，只要鉴权结果中存在就返回
             */
            DDLogInfo(@"TSDK_E_LOGIN_EVT_AUTH_SUCCESS");
            break;
        }
        case TSDK_E_LOGIN_EVT_AUTH_FAILED: // 鉴权失败
        {
            /*
             param1：TSDK_UINT32 user_id [cn]用户ID
             param2：TSDK_UINT32 reason_code [cn]原因码
             data：  TSDK_CHAR* reason_description [cn]错误原因描述
             */
            TSDK_UINT32 reasonCode = notify.param2;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_AUTH_FAILED object:nil userInfo:nil];
            });
            DDLogInfo(@"authorize failed, reason code: %d", reasonCode);
            break;
        }
        case TSDK_E_LOGIN_EVT_AUTH_REFRESH_FAILED: // 鉴权刷新失败
        {
            /*
             param1：TSDK_UINT32 user_id [cn]用户ID
             param2：TSDK_UINT32 reason_code [cn]原因码
             data：  TSDK_CHAR* reason_description [cn]错误原因描述
             */
            TSDK_UINT32 reasonCode = notify.param2;
            DDLogInfo(@"authorize refresh failed, reason code: %d", reasonCode);
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_SUCCESS: // 登录成功
        {
            /*
             param1：TSDK_UINT32 user_id [cn]用户ID
             param2：TSDK_UINT32 service_account_type [cn]服务帐号类型，取值参见：TSDK_E_SERVICE_ACCOUNT_TYPE
             data：  TSDK_S_LOGIN_SUCCESS_INFO* login_success_info [cn]登陆成功的相关信息
             */
            self.logoutCallBackAction = nil;
            DDLogInfo(@"sip have been login");
            // 设置用户状态：在线
            userOnlineState = 0;
            self.uLoginStatus = kUserLoginStatusOnline;
            sipStatus = kCallSipStatusRegistered;
            [self isSipRegistered:sipStatus error:nil];
            TSDK_S_LOGIN_SUCCESS_INFO *login_success_info = notify.data;
            if (login_success_info != NULL) {
                [ManagerService confService].uPortalConfType = [self configDeployMode: login_success_info->conf_env_type];
                [ManagerService callService].isSMC3 = (login_success_info->loginServerType == TSDK_E_LOGIN_E_SERVER_TYEP_SMC3);
                [ManagerService loginService].userType = [NSString stringWithUTF8String: login_success_info->userType];
                [ManagerService loginService].passwordExpire = [NSString stringWithFormat:@"%d", login_success_info->passwordExpire];
                DDLogInfo(@"TSDK_E_LOGIN_EVT_LOGIN_SUCCESS isSMC3: %d", [ManagerService callService].isSMC3 ? 3 : 2);
            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SIP_ACCOUNT_HAVE_LOGINED_KEY object:nil userInfo:nil];
//            });
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_FAILED:
        {
            sipStatus = kCallSipStatusUnRegistered;
            self.uLoginStatus = kUserLoginStatusUnLogin;
            TSDK_S_LOGIN_FAILED_INFO* login_failed_info = notify.data;
            DDLogInfo(@"sip login failed, reason code: %d", login_failed_info->reason_code);
            
            if (login_failed_info != NULL) {
                // 暂时使用，后期对登录失败error重新封装
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%d", login_failed_info->residual_retry_times],
                                          @"residualRetryTimes", // 剩余次数
                                          [NSString stringWithFormat:@"%d", login_failed_info->lock_interval],
                                          @"lockInterval", // 锁定时间
                                          nil];
                NSError *error = [NSError errorWithDomain:[NSString stringWithUTF8String:login_failed_info->reason_description]
                                                     code:login_failed_info->reason_code
                                                 userInfo:userInfo];
                [self isSipRegistered:sipStatus error:error];

            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:MAA_LOGIN_FAILED object:@(reasonCode) userInfo:nil];
//            });
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGOUT_SUCCESS:
        {
            DDLogInfo(@"sip unregister");
            if (self.logoutCallBackAction) {
                self.logoutCallBackAction(YES, nil);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOutSuccessClearPassword" object:@(true) userInfo:nil];
                });
            }
            self.uLoginStatus = kUserLoginStatusUnLogin;
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGOUT_FAILED:
        {
            TSDK_UINT32 reasonCode = notify.param2;
            DDLogInfo(@"sip logout failed, reason code: %d", reasonCode);
            NSError *error = [NSError errorWithDomain:[NSString stringWithUTF8String:notify.data]
                                                             code:reasonCode
                                                         userInfo:nil];
                        if (self.logoutCallBackAction) {
                            self.logoutCallBackAction(NO, error);
                        }
            break;
        }
        case TSDK_E_LOGIN_EVT_FORCE_LOGOUT: // 强制登出
        {
            [self logoutCompletionBlock:nil];
            DDLogInfo(@"sip unregister");
            sipStatus = kCallSipStatusUnRegistered;
            self.uLoginStatus = kUserLoginStatusUnLogin;
            [self isSipRegistered:sipStatus error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_C_FORCE_LOGOUT_SUCCESS_KEY object:nil userInfo:nil];
            });
            break;
        }
        case TSDK_E_LOGIN_EVT_VOIP_ACCOUNT_STATUS: //VOIP帐号信息
        {
            TSDK_S_VOIP_ACCOUNT_INFO *voip_account_info = (TSDK_S_VOIP_ACCOUNT_INFO *)notify.data;
            [[ManagerService callService]configBussinessAccount:[NSString stringWithUTF8String:voip_account_info->account] terminal:[NSString stringWithUTF8String:voip_account_info->number] token:nil];
            [ManagerService callService].definition = TSDK_E_VIDEO_DEFINITION_HD;
            break;
        }
        case TSDK_E_LOGIN_EVT_IM_ACCOUNT_STATUS:
        {
            break;
        }
        case TSDK_E_LOGIN_EVT_FIREWALL_DETECT_FAILED:
        {
            break;
        }
        case TSDK_E_LOGIN_EVT_BUILD_STG_TUNNEL_FAILED:
        {
            break;
        }
        case TSDK_E_LOGIN_EVT_GET_TEMP_USER_RESULT: // 获取用于匿名方式加入会议的临时用户结果通知
        {
            TSDK_UINT32 reasonCode = notify.param2;
            DDLogInfo(@"TSDK_E_LOGIN_EVT_GET_TEMP_USER_RESULT result is %d",reasonCode);
            if (reasonCode != TSDK_SUCCESS) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_C_GET_TEMP_USER_INFO_FAILD object:@{@"param1":@(notify.param1),@"param2":@(reasonCode)} userInfo:nil];
                });
            }
            break;
        }
        case TSDK_E_LOGIN_EVT_GET_CONF_PARAM_IND: // 获取用于登录以后，链接入会，加入会议的结果通知
        {
            TSDK_UINT32 reasonCode = notify.param1;
            TSDK_S_LOGIN_CONF_PARAM *confParam = (TSDK_S_LOGIN_CONF_PARAM *)notify.data;
            DDLogInfo(@"TSDK_E_LOGIN_EVT_GET_CONF_PARAM_IND result is %d",reasonCode);
            if (reasonCode == TSDK_SUCCESS) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *accessCode = [NSString stringWithFormat:@"%s",confParam->accessCode];
                    NSString *confPwd = [NSString  stringWithFormat:@"%s" , confParam->confPwd ];
                    NSString *mediaType = [NSString stringWithFormat:@"%s" , confParam->mediaType ];

                    // modify by wangyh
                    TSDK_S_SERVER_ADDR_INFO *serverInfos = confParam->serverAddr;
                    TSDK_UINT32 index = confParam->index;
                    NSString *accessURLS = [NSString stringWithFormat:@"%s",serverInfos[index].server_addr];

                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:accessCode,@"accessCode",  confPwd,@"confPwd",mediaType ,@"mediaType" ,accessURLS , @"accessURLS", nil];
                    DDLogInfo(@"dict:%@",dict);
                    DDLogInfo(@"code:%@==urls:%@===type:%@",accessCode,accessURLS,mediaType);
                    [[NSNotificationCenter defaultCenter] postNotificationName: LOGIN_STATUS_LINK_JOINMEETING_SUCCESS object:nil userInfo:dict];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATUS_LINK_JOINMEETING_ERROR object:nil userInfo:nil];
                });
            }
            break;
        }
        case TSDK_E_LOGIN_FIRST_MODIFY_PWD_NOTIFY:
                {
                    if (self.changePasswordCallBackAction) {
                        self.changePasswordCallBackAction(NO, nil);
                    }
                    break;
                }
        case TSDK_E_LOGIN_EVT_PASSWORD_CHANGEED_RESULT: // 1018 : 密码修改结果
        {
            /*
             param1：TSDK_UINT32 user_id [en]User id.[cn]用户ID
             param2：TSDK_UINT32 reason_code [en]Reason code.[cn]原因码
             data：  TSDK_S_LOGIN_FAILED_INFO* failedInfo [cn]错误信息
             */
            
            TSDK_UINT32 reasonCode = notify.param2;
            TSDK_S_LOGIN_FAILED_INFO* change_password_failed_info = notify.data;
            NSDictionary *userInfo;
            NSError *error = [NSError errorWithDomain:@"" code:reasonCode userInfo:nil];
            if (change_password_failed_info != NULL) {
                DDLogInfo(@"change password failed, reason code: %d", change_password_failed_info->reason_code);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%d", change_password_failed_info->residual_retry_times],
                                          @"residualRetryTimes", // 剩余次数
                                          [NSString stringWithFormat:@"%d", change_password_failed_info->lock_interval],
                                          @"lockInterval", // 锁定时间
                                          nil];
                error = [NSError errorWithDomain:[NSString stringWithUTF8String:change_password_failed_info->reason_description]
                                                     code:change_password_failed_info->reason_code
                                                 userInfo:userInfo];
            }
            if (self.changePasswordCallBackAction) {
                self.changePasswordCallBackAction(reasonCode == TSDK_SUCCESS, error);
            }
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_STATUS: // 用户在线状态
        {
            /*
             param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
             param2：0 - Online, 1 - Offline. [cn] 0 - 在线, 1 - 离线
             data：  NULL
             */
//            TSDK_UINT32 userId = notify.param1;
            TSDK_UINT32 isOnline = notify.param2;
            DDLogInfo(@"TSDK_E_LOGIN_EVT_LOGIN_STATUS : %d",isOnline);
            // 在线状态下提示用户离线
//            if (isOnline == 1 && userOnlineState == 0) {
//                userOnlineState = 1; // 用户离线
//                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_LOGOUT_SUCCESS_KEY
//                                                                    object:nil
//                                                                  userInfo:nil];
//            }
            
            if (isOnline == 1) {
//                用户在线状态发生变化时，离线状态下停止辅流
                [self updateRecordStatusToStop];
                self.uLoginStatus = kUserLoginStatusOffline;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_USER_OFFLINE_SUCCESS_KEY object:nil];
                });
            }
            if (isOnline == 0) {
                // chenf 二次重连成功后，的回调
                self.uLoginStatus = kUserLoginStatusOnline;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_RECONNECTION_SUCCESS_KEY
                                                                        object:nil
                                                                      userInfo:nil];
                });
            }
            break;
        }
        case TSDK_E_LOGIN_EVT_GET_USER_INFO_RESULT: // 获取用户信息(3.0/2.0)
        {
            TSDK_S_SMC3_USER_INFO_RESULT* userInfoParam  = (TSDK_S_SMC3_USER_INFO_RESULT *)notify.data;
            if (userInfoParam != NULL) {
                [[ManagerService callService]configBussinessAccount:[NSString stringWithUTF8String:userInfoParam->accountName] terminal:[NSString stringWithUTF8String:userInfoParam->terminalMiddleuri] token:nil];
                NSString *userName = [NSString stringWithUTF8String:userInfoParam->userName];
                DDLogInfo(@"TSDK_E_LOGIN_EVT_GET_USER_INFO_RESULT--> userName : %@",[NSString encryptNumberWithString:userName]);
                [[ManagerService loginService] setLoginInfoWithUserName:userName];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_GET_USER_INFO_SUCCESS_KEY
                                                                        object:nil
                                                                      userInfo:nil];
                });
            }
            
            break;
        }
        default:
            break;
    }
}

-(void)isSipRegistered:(CallSipStatus)sipStatus error:(NSError *)error
{
    if (sipStatus == kCallSipStatusRegistered) {
        if (self.loginCallBackAction) {
            self.loginCallBackAction(YES, nil);
        }
    } else if (sipStatus == kCallSipStatusUnRegistered) {
        if (self.loginCallBackAction) {
            self.loginCallBackAction(NO, error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_UNREGISTERED_RESULT object:nil userInfo:nil];
    }
    
}

/**
 *This method is used to config deploy mode
 *配置部署模式（uportal 会议类型）
 */
- (EC_CONF_TOPOLOGY_TYPE)configDeployMode:(TSDK_E_CONF_ENV_TYPE)deployMode
{
    EC_CONF_TOPOLOGY_TYPE uPortalConfType = CONF_TOPOLOGY_BUTT;
    switch (deployMode) {
        case TSDK_E_CONF_ENV_HOSTED_CONVERGENT_CONFERENCE:
            // mediax组网， mediax会议
            uPortalConfType = CONF_TOPOLOGY_MEDIAX;
            break;
        case TSDK_E_CONF_ENV_ON_PREMISES_CONVERGENT_CONFERENCE:
            // smc组网， smc会议
            uPortalConfType = CONF_TOPOLOGY_SMC;
            break;
        case TSDK_E_CONF_ENV_ON_PREMISES_CONFERENCING_ONLY:
            // smc组网， smc会议
            uPortalConfType = CONF_TOPOLOGY_SMC;
            break;
        default:
            DDLogInfo(@"deploy is error, ignore!");
            break;
    }
    return uPortalConfType;
}

- (void)setLocalIp{
    // ip
    TSDK_S_LOCAL_ADDRESS local_ip;
    memset_s(&local_ip, sizeof(TSDK_S_LOCAL_ADDRESS), 0, sizeof(TSDK_S_LOCAL_ADDRESS));
    
    //检查是否连接VPN
    BOOL isVPNConnect = [CommonUtils checkIsVPNConnect];
    NSString *localIp = [CommonUtils getLocalIpAddressWithIsVPN:isVPNConnect] ;
    
    //判断服务器地址是否IPV6
    BOOL serverAddrIsIPV6 = [CommonUtils isValidateIPv6:localIp ];
    NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN: isVPNConnect serverAddrIsIPV6: serverAddrIsIPV6];
    strcpy_s(local_ip.ip_address, sizeof(local_ip.ip_address), [ip UTF8String]);
    TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
    DDLogInfo(@"config local address result: %d", configResult);
    
    //设置业务安全配置参数
    TSDK_S_SERVICE_SECURITY_PARAM securityParam;
    memset_s(&securityParam, sizeof(TSDK_S_SERVICE_SECURITY_PARAM), 0, sizeof(TSDK_S_SERVICE_SECURITY_PARAM));
    // 1:4   0:1
    securityParam.bfcp_transport_mode = TSDK_E_BFCP_TRANSPORT_TLS;//tls  TSDK_E_BFCP_TRANSPORT_TLS   TSDK_E_BFCP_TRANSPORT_UDP
    securityParam.media_srtp_mode = TSDK_E_MEDIA_SRTP_MODE_OPTION;//2    TSDK_E_MEDIA_SRTP_MODE_OPTION   TSDK_E_MEDIA_SRTP_MODE_DISABLE
    
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_SECURITY_PARAM, &securityParam);
    DDLogInfo(@"config security param result: %d", configResult);
    
    //net
    TSDK_E_SIP_TRANSPORT_MODE transportMode = TSDK_E_SIP_TRANSPORT_TLS;
    TSDK_S_NETWORK_INFO_PARAM networkInfo;
    memset_s(&networkInfo, sizeof(TSDK_S_NETWORK_INFO_PARAM), 0, sizeof(TSDK_S_NETWORK_INFO_PARAM));
        networkInfo.sip_transport_mode = transportMode;
    networkInfo.sip_server_port = 5061;
    networkInfo.https_server_port = 443;
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_NETWORK_INFO, &networkInfo);
    DDLogInfo(@"config network info result: %d", configResult);
    
     
    NSString *clientCertPath = PEM_PATH(@"vc_gm_cert_cloudlink/inCertificate");
    NSString *gmCertPath = PEM_PATH(@"vc_gm_cert_cloudlink/smCertificate");
    NSString *rootCertPath = PEM_PATH(@"vc_gm_cert_cloudlink");
    
    NSArray *array = [CommonUtils getUserDefaultValueWithKey:SRTP_TRANSPORT_MODE];
    
    //config TLS param
    TSDK_S_TLS_PARAM tlsParam;
    memset_s(&tlsParam, sizeof(TSDK_S_TLS_PARAM), 0, sizeof(TSDK_S_TLS_PARAM));
    //cert
    strcpy_s(tlsParam.tlsInParam.caCertPath, sizeof(tlsParam.tlsInParam.caCertPath), [STR(rootCertPath, @"root/") UTF8String]);
    strcpy_s(tlsParam.tlsInParam.clientCertPath, sizeof(tlsParam.tlsInParam.clientCertPath), [STR(clientCertPath, @"equip.pem") UTF8String]);
    strcpy_s(tlsParam.tlsInParam.clientKeyPath, sizeof(tlsParam.tlsInParam.clientKeyPath), [STR(clientCertPath, @"equip_key.pem") UTF8String]);
    strcpy_s(tlsParam.tlsInParam.clientPrivkeyPwd, sizeof(tlsParam.tlsInParam.clientPrivkeyPwd), [@"Change_Me" UTF8String]);
    //config GM param
    NSString *gmIsOn = array.lastObject;
    tlsParam.tlsGmParam.isOpenSm = (TSDK_BOOL)[gmIsOn intValue];//,,,,,
    strcpy_s(tlsParam.tlsGmParam.gmcaDirPath, sizeof(tlsParam.tlsGmParam.gmcaDirPath), [STR(rootCertPath, @"root/") UTF8String]);//,,,,
    strcpy_s(tlsParam.tlsGmParam.gmencSerCertPath, sizeof(tlsParam.tlsGmParam.gmencSerCertPath), [STR(gmCertPath, @"equip_cloudlink_enc.pem") UTF8String]);//,,,,,,,,
    strcpy_s(tlsParam.tlsGmParam.gmencSerKeyCertPath, sizeof(tlsParam.tlsGmParam.gmencSerKeyCertPath), [STR(gmCertPath, @"equip_key_cloudlink_enc.pem") UTF8String]);//,,,,,,,,
    strcpy_s(tlsParam.tlsGmParam.gmencSerKeyFilePsw, sizeof(tlsParam.tlsGmParam.gmencSerKeyFilePsw), [@"Change_Me" UTF8String]);//,,,,
    strcpy_s(tlsParam.tlsGmParam.gmsignSerCertPath, sizeof(tlsParam.tlsGmParam.gmsignSerCertPath), [STR(gmCertPath, @"equip_cloudlink.pem") UTF8String]);//,,,,,,,
    strcpy_s(tlsParam.tlsGmParam.gmsignSerKeyCertPath, sizeof(tlsParam.tlsGmParam.gmsignSerKeyCertPath), [STR(gmCertPath, @"equip_key_cloudlink.pem") UTF8String]);//,,,,,,
    strcpy_s(tlsParam.tlsGmParam.gmsignSerKeyFilePsw, sizeof(tlsParam.tlsGmParam.gmsignSerKeyFilePsw), [@"Change_Me" UTF8String]);
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_TLS_PARAM, &tlsParam);//,,,,,,,
    DDLogInfo(@"config tls param result: %d", configResult);
    
}


/// 二次重连设置ip地址
/// @param isNullIp false: 传本机的ip地址，true:下发空地址
- (void)setReconnectLocalIpWithInullIp:(BOOL)isNullIp {    
    // ip
    TSDK_S_LOCAL_ADDRESS local_ip;
    memset_s(&local_ip, sizeof(TSDK_S_LOCAL_ADDRESS), 0, sizeof(TSDK_S_LOCAL_ADDRESS));
    
    //检查是否连接VPN
    BOOL isVPNConnect = [CommonUtils checkIsVPNConnect];
    NSString *localIp = [CommonUtils getLocalIpAddressWithIsVPN:isVPNConnect] ;
    
    //判断服务器地址是否IPV6
    BOOL serverAddrIsIPV6 = [CommonUtils isValidateIPv6:localIp ];
    NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN: isVPNConnect serverAddrIsIPV6: serverAddrIsIPV6];
    if (isNullIp) {
        strcpy_s(local_ip.ip_address, sizeof(local_ip.ip_address), [@"" UTF8String]);
        TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
        DDLogInfo(@"setReconnectLocalIpWithInullIp result（）: %d", configResult);
    } else {
        // 检测ip是否有变化
        NSString *beforeIp = [CommonUtils getUserDefaultValueWithKey:SAVE_CURRENT_LOCAL_IP_KEY];
        if (!(beforeIp != nil && [beforeIp isEqual:ip])) {
            DDLogInfo(@"ip changed.");
            [CommonUtils userDefaultSaveValue:ip forKey:SAVE_CURRENT_LOCAL_IP_KEY];
            
            strcpy_s(local_ip.ip_address, sizeof(local_ip.ip_address), [ip UTF8String]);
            TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
            DDLogInfo(@"setReconnectLocalIpWithInullIp result: %d", configResult);
        } else {
            DDLogInfo(@"not update sdk ip, because ip not change.");
        }
    }
}

/// 设置用户状态
/// @param loginStatus 用户状态
- (void)setUserLoginStatus:(UserLoginStatus)loginStatus {
    _uLoginStatus = loginStatus;
}

/// 获取用户状态
- (UserLoginStatus)getUserLoginStatus {
    return _uLoginStatus;
}

-(void)updateRecordStatusToStop {
    RecordNotifycationManager *recordShare = [[RecordNotifycationManager alloc]init];
    [recordShare postNotificationWithName:@"STOPSHARED" ];
}

@end
