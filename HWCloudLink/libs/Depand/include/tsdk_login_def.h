/**
 * @file tsdk_login_def.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK login enum and struct define.
 */

#ifndef __TSDK_LOGIN_DEF_H__
#define __TSDK_LOGIN_DEF_H__

#include "tsdk_def.h"
#include "tsdk_manager_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */



/**
 * [en]This enumeration is used to describe the type of authentication.
 * [cn]鉴权类型
 */
typedef enum tagTSDK_E_AUTH_TYPE
{
    TSDK_E_AUTH_NORMAL,                     /**< [en]Indicates password authentication.
                                                 [cn]密码鉴权 */
    TSDK_E_AUTH_BUTT
}TSDK_E_AUTH_TYPE;


/**
 * [en]This enumeration is used to describe the server type.
 * [cn]服务器类型
 */
typedef enum tagTSDK_E_SERVER_TYPE
{
    TSDK_E_SERVER_TYPE_SMC,                 /**< [en]Indicates the SMC server.
                                                 [cn]SMC服务器 */
    TSDK_E_SERVER_TYPE_UAP,                 /**< [en]Indicates the UAP server.
                                                 [cn]UAP服务器 */
    TSDK_E_SERVER_TYPE_BUTT
}TSDK_E_SERVER_TYPE;


/**
 * [en]This enumeration is used to describe the mode of firewall.
 * [cn]防火墙模式
 */
typedef enum tagTSDK_E_FIREWALL_MODE
{
    TSDK_E_FIREWALL_MODE_ONLY_HTTP,         /**< [en]Indicates that only http can pass through the firewall.
                                                 [cn]只有http能通过防火墙 */
    TSDK_E_FIREWALL_MODE_HTTP_AND_SVN,      /**< [en]Indicates that only http and svn (udp 443) can pass through the firewall.
                                                 [cn]只有http和svn(udp 443)能通过防火墙 */
    TSDK_E_FIREWALL_MODE_NULL               /**< [en]Indicates that there is no firewall.
                                                 [cn]无防火墙拦截 */
}TSDK_E_FIREWALL_MODE;


/**
 * [en]This enumeration is used to describe push operation type.
 * [cn]Push操作类型
 */
typedef enum tagTSDK_E_PUSH_OPERATION_TYPE
{
    TSDK_E_PUSH_REGISTER,                       /**< [en]Indicates register the push service.
                                                     [cn]注册PUSH服务 */
    TSDK_E_PUSH_UNREGISTER,                     /**< [en]Indicates deregister the push service.
                                                     [cn]注销PUSH服务 */
    TSDK_E_PUSH_ClOSE_PUSH,                     /**< [en]Indicates close the push service.
                                                     [cn]关闭PUSH服务 */
    TSDK_E_PUSH_TYPE_BUTT
}TSDK_E_PUSH_OPERATION_TYPE;


/**
 * [en]This enumeration is used to describe forcible logout reason.
 * [cn]被强制退出原因
 */
typedef enum tagTSDK_E_FORCE_LOGOUT_REASON
{
    TSDK_E_FORCE_LOGOUT_BY_LOGIN_ELSEWHERE,     /**< [en]Indicates the account has logged in to another terminal.
                                                     [cn]在其他终端上登录 */
    TSDK_E_FORCE_LOGOUT_BY_ACCOUNT_STOP_USE,    /**< [en]Indicates the account is disabled by the server.
                                                     [cn]账号被服务端停止使用 */
    TSDK_E_FORCE_LOGOUT_BY_ACCOUNT_EXPIRED,     /**< [en]Indicates the account has expired.
                                                     [cn]账号过期 */
    TSDK_E_FORCE_LOGOUT_REASON_BUTT
}TSDK_E_FORCE_LOGOUT_REASON;

/**
* [en]This enumeration is used to describe the stage of login.
* [cn]登录状态
*/
typedef enum tagTSDK_E_LOGIN_STATE {
    TSDK_E_ACCOUNT_NOT_AUTHENTICATED, // 初始状态，未鉴权
    TSDK_E_ACCOUNT_AUTHENTICATING, // 鉴权中
    TSDK_E_ACCOUNT_AUTHENTICATED, // 鉴权成功
    TSDK_E_ACCOUNT_REGISTERING,   // 注册中
    TSDK_E_ACCOUNT_REGSITERED,    // 已注册
    TSDK_E_ACCOUNT_BUTT
} TSDK_E_LOGIN_STATE;

/**
 * [en]This structure is used to describe login parameters.
 * [cn]登录信息参数
 */
typedef struct tagTSDK_S_LOGIN_PARAM
{
    TSDK_UINT32 user_id;                                        /**< [en]Indicates the user id that requires APP generation.
                                                                     [cn]用户id，需要APP生成 */
    TSDK_E_AUTH_TYPE auth_type;                                 /**< [en]Indicates the type of authentication.
                                                                     [cn]鉴权类型 */
    TSDK_CHAR user_name[TSDK_D_MAX_ACCOUNT_LEN + 1];            /**< [en]Indicates the account username.
                                                                     [cn]账户用户名，鉴权类型为TSDK_E_AUTH_NORMAL时填写 */
    TSDK_CHAR password[TSDK_D_MAX_PASSWORD_LENGTH + 1];         /**< [en]Indicates the account password.
                                                                     [cn]账户密码，鉴权类型为TSDK_E_AUTH_NORMAL时填写 */
    TSDK_CHAR* user_ticket;                                     /**< [en]Indicates the Ticket value used by a third-party authentication Tiken scenario, max size is 64K bytes.
                                                                     [cn]Ticket值，鉴权类型为TSDK_E_AUTH_TICKET时填写, 最大64K字节 */
    TSDK_E_SERVER_TYPE server_type;                             /**< [en]Indicates the server type, Currently supports only TSDK_E_SERVER_TYPE_PORTAL and TSDK_E_SERVER_TYEP_SMC.
                                                                     [cn]服务器类型，当前仅支持 TSDK_E_SERVER_TYPE_PORTAL 和 TSDK_E_SERVER_TYEP_SMC */
    TSDK_CHAR sip_uri[TSDK_D_MAX_DOMAIN_LENGTH + 1];            /**< [en]Indicates the SIP domain, this param is optional.
                                                                     [cn]可选，SIP域名*/
} TSDK_S_LOGIN_PARAM;


/**
 *[en]This structure is used to describe server address info
 *[cn]服务器地址信息
 */
typedef struct tagTSDK_S_SERVER_ADDR_INFO
{
    TSDK_CHAR server_addr[TSDK_D_MAX_URL_LENGTH + 1];           /**< [en]Indicates the server address.
                                                                     [cn]服务器地址 */
    TSDK_UINT16 server_port;                                    /**< [en]Indicates the server port.
                                                                     [cn]服务器端口号 */
}TSDK_S_SERVER_ADDR_INFO;


/**
 *[en]This structure is used to describe server address info list
 *[cn]服务器地址信息列表
 */
typedef struct tagTSDK_S_SERVER_ADDR_INFO_LIST
{
    TSDK_UINT32 server_addr_info_num;                           /**< [en]Indicates server number
                                                                     [cn]服务器数量 */
    TSDK_S_SERVER_ADDR_INFO *server_addr_info;                  /**< [en]Indicates server address information
                                                                     [cn]服务器地址信息 */
}TSDK_S_SERVER_ADDR_INFO_LIST;


/**
 *[en]This structure is used to describe security tunnel info.
 *[cn]安全隧道信息
 */
typedef struct tagTSDK_S_SECURITY_TUNNEL_INFO
{
    TSDK_E_FIREWALL_MODE firewall_mode;                         /**< [en]Indicates firewall mode. Required for external network access.
                                                                     [cn]防火墙模式，外网接入时必选 */
    TSDK_S_SERVER_ADDR_INFO_LIST stg;                           /**< [en]Indicates stg server info. Required for external network access.
                                                                     [cn]stg服务器信息，外网接入时必选 */
    TSDK_S_SERVER_ADDR_INFO_LIST sip_stg;                       /**< [en]Indicates sip stg server info. Required for external network access.
                                                                     [cn]sip stg服务器信息，外网接入时必选 */
    TSDK_S_SERVER_ADDR_INFO_LIST e_server_stg;                  /**< [en]Indicates internal stg server. Required for external network access.
                                                                     [cn]通过STG接入的内网eServer地址，外网接入时必选 */
    TSDK_S_SERVER_ADDR_INFO_LIST maa_stg;                       /**< [en]Indicates maa stg server. Required for external network access.
                                                                     [cn]通过STG接入的内网MAA地址，外网接入时必选 */
    TSDK_S_SERVER_ADDR_INFO_LIST ms_stg;                        /**< [en]Indicates ms stg server. Required for external network access.
                                                                     [cn]通过STG接入的内网MS地址，外网接入时必选 */
    TSDK_S_SERVER_ADDR_INFO_LIST svn;                           /**< [en]Indicates the SVN proxy server address.
                                                                     [cn]SVN代理服务器地址 */
    TSDK_S_SERVER_ADDR_INFO_LIST https_proxy;                   /**< [en]Indicates the Https proxy server address.
                                                                     [cn]HTTPS反向代理地址 */

}TSDK_S_SECURITY_TUNNEL_INFO;


/**
 * [en]This structure is used to describe VOIP account account info(return when login success).
 * [cn]VOIP帐号信息(登录成功时返回)
 */
typedef struct tagTSDK_S_VOIP_ACCOUNT_INFO
{
    TSDK_CHAR account[TSDK_D_MAX_ACCOUNT_LEN + 1];              /**< [en]Indicates account.
                                                                     [cn]帐号 */
    TSDK_CHAR number[TSDK_D_MAX_NUMBER_LEN + 1];                /**< [en]Indicates the voice register number .
                                                                     [cn]voip 注册号码 */
    TSDK_CHAR terminal[TSDK_D_MAX_NUMBER_LEN + 1];              /**< [en]Indicates the terminal number(short number).
                                                                     [cn]terminal 号码(短号) */
}TSDK_S_VOIP_ACCOUNT_INFO;

/**
 * [en]This structure is used to describe information about login success.
 * [cn]登录成功信息
 */
typedef struct tagTSDK_S_LOGIN_SUCCESS_INFO
{
    TSDK_E_CONF_ENV_TYPE conf_env_type;                                 /**< [en]Indicates conference enviroment type.
                                                                             [cn]会议组网类型 */
    TSDK_E_LOGIN_SERVER_TYPE loginServerType;                           /**< [en]Indicates login smc server type.
                                                                             [cn]登录SMC组网类型 */
    TSDK_UINT32 passwordExpire;                                         /**< [en]Indicates the password expire.
                                                                             [cn]密码到期剩余天数,255表示未过期，其他数表示到期的剩余天数 */
    TSDK_CHAR userType[TSDK_D_LOGIN_MAX_USER_TYPE_LEN];                 /**< [en]Indicates the user type.
                                                                             [cn]登录用户类型 */
}TSDK_S_LOGIN_SUCCESS_INFO;


/**
 * [en]This structure is used to describe information about login failed.
 * [cn]登录失败信息
 */
typedef struct tagTSDK_S_LOGIN_FAILED_INFO
{
    TSDK_INT32 reason_code;                                             /**< [en]Indicates reason code
                                                                             [cn]原因码*/
    TSDK_CHAR reason_description[TSDK_D_MAX_REASON_DESCRPTION_LEN + 1]; /**< [en]Indicates reason description
                                                                             [cn]原因描述*/
    TSDK_INT32 residual_retry_times;                                    /**< [en]Indicates remaining number of login attempts.
                                                                             [cn]登录重试剩余次数，Smc3.0登录密码错误时有效 */
    TSDK_INT32 lock_interval;                                           /**< [en]Indicates remaining time for locking an account (in seconds).
                                                                             [cn]帐号被锁定剩余时间（单位：秒） */
}TSDK_S_LOGIN_FAILED_INFO;

/**
* [en]This structure is used to describe abnormal information
* [cn]异常信息
*/
typedef struct tagTSDK_S_ABNORMAL_INFO
{
    TSDK_INT32 reasonCode;                                             /**< [en]Indicates reason code
                                                                            [cn]原因码*/
    TSDK_CHAR reasonDescription[TSDK_D_MAX_REASON_DESCRPTION_LEN + 1]; /**< [en]Indicates reason description
                                                                            [cn]原因描述*/
} TSDK_S_ABNORMAL_INFO;

typedef struct tagTSDK_S_LOGIN_VERSION_INFO
{
    TSDK_CHAR pcVersionInfo[TSDK_LOGIN_MAX_RECORD_VERSION_LEN];          /**< [en]PC version information. [cn]PC版本信息 */
    TSDK_CHAR iosVersionInfo[TSDK_LOGIN_MAX_RECORD_VERSION_LEN];         /**< [en]IOS version information. [cn]IOS版本信息 */
    TSDK_CHAR androidVersionInfo[TSDK_LOGIN_MAX_RECORD_VERSION_LEN];     /**< [en]Android version information. [cn]安卓版本信息 */
    TSDK_CHAR pcLink[TSDK_LOGIN_D_MAX_URL_LENGTH];                           /**< [en]Software package information on the PC. [cn]PC端软件包信息 */
    TSDK_CHAR iosLink[TSDK_LOGIN_D_MAX_URL_LENGTH];                          /**< [en]iOS Link. [cn]IOS链接地址 */
    TSDK_CHAR androidLink[TSDK_LOGIN_D_MAX_URL_LENGTH];                      /**< [en]Android Link. [cn]安卓连接地址 */
}TSDK_S_LOGIN_VERSION_INFO;

/**
 * [en]random auth result
 * [cn]链接入会相关信息
 */

typedef struct tagTSDK_S_LOGIN_CONF_PARAM
{
    TSDK_CHAR accessCode[TSDK_D_MAX_ACCESS_NUM_LEN];  /**< [en]Indicates conference access code. [cn]会议接入码 */
    TSDK_CHAR confPwd[TSDK_LOGIN_D_MAX_PASSWORD_LEN];   /**< [en]Indicates conference password. [cn]会议密码 */
    TSDK_CHAR mediaType[TSDK_LOGIN_D_MAX_MEDIATYPE_LEN];   /**< [en]Indicates media type. similar to: voice; video. [cn]媒体类型. 类似：voice; video */
    TSDK_UINT32 index;   /**< [en]Indicates arrary of sc address index. [cn]记录SC接入地址当前数组索引 */
    TSDK_S_SERVER_ADDR_INFO serverAddr[TSDK_LOGIN_D_MAX_NUM];  /**< [en]Indicates arrary of sc address. [cn]SC接入地址列表 */
}TSDK_S_LOGIN_CONF_PARAM;
/**
 * [en]This structure is used to describe forcible logout information.
 * [cn]帐号被强制登出信息
 */
typedef struct tagTSDK_E_FORCE_LOGOUT_INFO
{
    TSDK_E_FORCE_LOGOUT_REASON reason;                                  /**< [en]Indicates reason why the account is forcibly logged out..
                                                                             [cn]帐号被强制登出原因 */
}TSDK_E_FORCE_LOGOUT_INFO;



/**
 * [en]This structure is used to describe information about push service information.
 * [cn]Push服务信息
 */
typedef struct tagTSDK_S_PUSH_SERVICE_INFO
{
    TSDK_E_PUSH_OPERATION_TYPE push_operation;                          /**< [en]Indicates push operation type.
                                                                             [cn]Push操作类型 */
    TSDK_BOOL enable_no_push_by_time;                                   /**< [en]Indicates whether to enable the DND function (shielding the push service  based on the time segment). The default value is False, indicating that the DND function is disabled.
                                                                             [cn]是否开启时段免打扰(根据时间段屏蔽Push)，默认为False，不开启 */
    TSDK_CHAR no_push_start_time[TSDK_D_MAX_TIME_FORMATE_LEN + 1];      /**< [en]Indicates start time of the DND period. The value is a UTC time string in the 24-hour format of HH:MM, for example, 13:00.
                                                                             [cn]免打扰开始时间，格式为00:00的24小时制的UTC时间字符串，如:"13:00" */
    TSDK_CHAR no_push_end_time[TSDK_D_MAX_TIME_FORMATE_LEN + 1];        /**< [en]Indicates end time of the DND period. The value is a UTC time string in the 24-hour format of HH:MM, for example, 14:00..
                                                                             [cn]免打扰结束时间，格式为00:00的24小时制的UTC时间字符串，如:"14:00" */
}TSDK_S_PUSH_SERVICE_INFO;

 /**
 * [en]This structure is used to describe the login device param.
 * [cn]获取登录设备信息
 */
typedef struct tagTSDK_S_LOGIN_GET_DEVICE_INFO_PARAM
{
    TSDK_CHAR serverUrl[TSDK_D_LOGIN_MAX_SERVICE_LEN];                  /**< [en]Indicates the server address. 
                                                                             [cn]服务器地址 */
    TSDK_INT32 serverPort;                                              /**< [en]Indicates the server port. 
                                                                             [cn]服务器端口 */
}TSDK_S_LOGIN_GET_DEVICE_INFO_PARAM;

 /**
 * [en]This structure is used to describe login change password param.
 * [cn]登录修改密码信息参数
 */
typedef struct tagTSDK_S_LOGIN_CHANGE_PASSWORD_PARAM {

    TSDK_CHAR oldPassword[TSDK_D_LOGIN_MAX_PASSWORD_LENGTH + 1];           /**< [en]Indicates the account old password.
                                                                            [cn]账户旧密码，鉴权类型为TSDK_E_AUTH_NORMAL时填写 */
    TSDK_CHAR newPassword[TSDK_D_LOGIN_MAX_PASSWORD_LENGTH + 1];           /**< [en]Indicates the account new password.
                                                                            [cn]账户新密码，鉴权类型为TSDK_E_AUTH_NORMAL时填写 */
}TSDK_S_LOGIN_CHANGE_PASSWORD_PARAM;

 /**
 * [en]This structure is used to describe the login user id param.
 * [cn]获取用户id信息
 */
typedef struct tagTSDK_S_LOGIN_USER_INFO_PARAM
{
    TSDK_CHAR serverUrl[TSDK_D_LOGIN_MAX_SERVICE_LEN];                 /**< [en]Indicates the server address. 
                                                                            [cn]服务器地址 */
    TSDK_CHAR account[TSDK_D_LOGIN_MAX_USERNAME_LEN];                  /**< [en]Indicates the server address. 
                                                                            [cn]用户账号 */
    TSDK_INT32 serverPort;                                             /**< [en]Indicates the server port. 
                                                                            [cn]服务器端口 */
}TSDK_S_LOGIN_USER_INFO_PARAM;

typedef struct tagTSDK_S_CMPT_DATETIME
{
    TSDK_UINT16 year;      /**< Year,the value domain is from 0 to 65536 */
    TSDK_UINT8  month;     /**< Month,the value domain is from 1 to 12 */
    TSDK_UINT8  day;       /**< Day,the value domain is from 1 to 31 */
    TSDK_UINT8  hour;      /**< Hour,the value domain is from 0 to 23 */
    TSDK_UINT8  minute;    /**< Minute,the value domain is from 0 to 59 */
    TSDK_UINT8  second;    /**< Second,the value domain is from 0 to 59 */
#ifdef __LP64__
    TSDK_ULONG  utcSec;    /**< Second to UTC, 自00:00:00 UTC, January 1, 1970 以来经过的秒数。*/
    TSDK_ULONG sec64;      /**< Second to Juanry 1, 1970, 从1970年1月1日经过秒数 */
#else
    TSDK_UINT64  utcSec;    /**< Second to UTC, 自00:00:00 UTC, January 1, 1970 以来经过的秒数。*/
    TSDK_UINT64 sec64;      /**< Second to Juanry 1, 1970, 从1970年1月1日经过秒数 */
#endif
}TSDK_S_CMPT_DATETIME;

typedef enum tagTSDK_E_CERT_TYPE
{
    TSDK_E_CERT_TYPE_ROOT = 0,  /**< [en]Indicates the root cert.
                                     [cn]根证书 */
    TSDK_E_CERT_TYPE_DEVICES,   /**< [en]Indicates the device cert.
                                     [cn]设备证书 */
    TSDK_E_CERT_TYPE_GM,        /**< [en]Indicates the gm cert.
                                     [cn]国密 */
    TSDK_E_CERT_TYPE_BUTT
}TSDK_E_CERT_TYPE;

typedef struct tagTSDK_S_CMPT_CERTVERIFY_INFO
{
    TSDK_CHAR  acCertIssuerName[TSDK_S_MAX_ISSUER_NAME];           /**< [en]Indicates Common name of the CA, which is used for verification. 
                                                                        [cn]证书颁发机构通用名，校验用 */
    TSDK_BOOL  verifySignAlg;                                      /**< [en]Indicates Whether to verify the certificate signature algorithm 
                                                                        [cn]是否校验证书签名算法 */
    TSDK_BOOL  verifyPubKeyLen;                                    /**< [en]Indicates Whether to verify the length of the certificate public key 
                                                                        [cn]是否校验证书公钥长度 */
}TSDK_S_CMPT_CERTVERIFY_INFO;

typedef struct tagTSDK_S_CMPT_CHECK_INFO 
{
    TSDK_E_CERT_TYPE certType;                                    /**< [en]Indicates Certificate Type 
                                                                       [cn]证书类型 */
    TSDK_CHAR acName[TSDK_S_MAX_ISSUER_NAME];                     /**< [en]Indicates
                                                                       [cn]证书颁发机构通用名，校验用 */
    TSDK_CHAR acPath[TSDK_D_MAX_CA_PATH_LEN + 1];                 /**< [en]Indicates certificate Path 
                                                                       [cn]证书路径 */
    TSDK_CHAR acKeyPath[TSDK_D_MAX_CA_PATH_LEN + 1];              /**< [en]Indicates Certificate private key path
                                                                       [cn]证书私钥路径 */
    TSDK_CHAR acPrivkeyPwd[TSDK_D_MAX_PASSWORD_LENGTH + 1];       /**< [en]Indicates Key signature password 
                                                                       [cn]秘钥签名密码 */
}TSDK_S_CMPT_CHECK_INFO;

typedef struct tagTSDK_S_SMC3_USER_INFO_RESULT {
    TSDK_CHAR userId[TSDK_D_MAX_ACCOUNT_LEN + 1];                    /**< [en]Indicates the user id. [cn]用户ID */
    TSDK_CHAR userName[TSDK_D_MAX_DISPLAY_NAME_LEN + 1];             /**< [en]Indicates the user_name. [cn]用户名 */
    TSDK_CHAR accountId[TSDK_D_MAX_ACCOUNT_LEN + 1];                 /**< [en]Indicates the account_id. [cn]帐号ID */
    TSDK_CHAR accountName[TSDK_D_MAX_ACCOUNT_LEN + 1];               /**< [en]Indicates the user id. [cn]帐号名 */
    TSDK_CHAR accountStatus[TSDK_D_MAX_SMC3_USER_INFO_STRING_LEN];   /**< [en]Indicates the account_status. [cn]帐号状态 */
    TSDK_CHAR accountRoleType[TSDK_D_MAX_SMC3_USER_INFO_STRING_LEN]; /**< [en]Indicates the account_role_type. [cn]角色类型   */
    TSDK_CHAR accountOrgName[TSDK_D_MAX_SMC3_USER_INFO_STRING_LEN];  /**< [en]Indicates the account_org_name. [cn]组织名称   */
    TSDK_CHAR accountEmail[TSDK_D_MAX_SMC3_USER_INFO_STRING_LEN];    /**< [en]Indicates the account_email. [cn]邮箱 */
    TSDK_CHAR accountMobile[TSDK_D_MAX_SMC3_USER_INFO_STRING_LEN];   /**< [en]Indicates the account_mobile. [cn]手机 */
    TSDK_CHAR position[TSDK_D_MAX_SMC3_USER_INFO_STRING_LEN];        /**< [en]Indicates the position. [cn]职位 */
    TSDK_CHAR remarks[TSDK_D_MAX_EXTRA_PARAMETER_NUM];               /**< [en]Indicates the remarks. [cn]备注 */
    TSDK_CHAR serviceZoneId[TSDK_D_MAX_ACCOUNT_LEN + 1];             /**< [en]Indicates the service_zone_id. [cn]服务区域索引 */
    TSDK_CHAR serviceZoneName[TSDK_D_MAX_ACCOUNT_LEN + 1];           /**< [en]Indicates the service_zone_name. [cn]服务区域名称 */
    TSDK_CHAR terminalId[TSDK_D_MAX_ACCOUNT_LEN + 1];                /**< [en]Indicates the terminal_id. [cn]终端索引 */
    TSDK_CHAR terminalType[TSDK_MAX_TERMINAL_TYPE_NUMBER_LEN + 1];       /**< [en]Indicates the terminal_type. [cn]终端类型 */
    TSDK_CHAR terminalMiddleuri[TSDK_D_MAX_URL_LENGTH + 1];          /**< [en]Indicates the terminal_middleuri. [cn]终端绑定号码 */
} TSDK_S_SMC3_USER_INFO_RESULT;

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_LOGIN_DEF_H__ */

