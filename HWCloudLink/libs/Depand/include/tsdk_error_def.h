/**
 * @file tsdk_error_def.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK error define.
 */

#ifndef __TSDK_ERROR_DEF_H__
#define __TSDK_ERROR_DEF_H__

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */


#define TSDK_SUCCESS             (0)
#define TSDK_UNKNOWN_ERR         (1)


/**
 * [en]This enumeration is used to describe error code definitions of service manager module.
 * [cn]业务管理模块错误码定义
 */
   typedef enum tagTSDK_E_MANAGER_ERR_ID
   {
      TSDK_E_MANAGER_ERR_BEGIN = 0x00FFFFFF,

      TSDK_E_MANAGER_ERR_UNKNOWN,                             /**< [en]0x00 Indicates unknown error
                                                                   [cn]0x00 未知错误 */
                                                                   //01
      TSDK_E_MANAGER_ERR_GENERAL_ERROR,                       /**< [en]0x01 Indicates general error
                                                                   [cn]0x01 一般错误 */
      TSDK_E_MANAGER_ERR_PARAM_ERROR,                         /**< [en]0x02 Indicates parameter error
                                                                   [cn]0x02 参数错误 */
      TSDK_E_MANAGER_ERR_MALLOC_FAILED,                       /**< [en]0x03 Indicates allocate memory failed
                                                                   [cn]0x03 分配内存错误 */
      TSDK_E_MANAGER_ERR_SYSTEM_ERROR,                        /**< [en]0x04 Indicates system error
                                                                   [cn]0x04 系统错误 */
      TSDK_E_MANAGER_ERR_LOAD_LIBRARY_FAILED,                 /**< [en]0x05 Indicates load library failed
                                                                   [cn]0x05 加载库错误 */
                                                                   //06
      TSDK_E_MANAGER_ERR_SDK_UNINITIALIZED,                   /**< [en]0x06 Indicates sdk uninitialized
                                                                   [cn]0x06 SDK未初始化 */
      TSDK_E_MANAGER_ERR_SDK_INIT_REPEAT,                     /**< [en]0x07 Indicates sdk Initialization repetition
                                                                   [cn]0x07 SDK初始化重复 */
      TSDK_E_MANAGER_ERR_MSGP_CREATE_ERR,                     /**< [en]0x08 Indicates message queue thread create failed.
                                                                   [cn]0x08 消息队列线程/进程创建失败 */
      TSDK_E_MANAGER_ERR_TIMER_START_ERR,                     /**< [en]0x09 Indicates timer thread start failed.
                                                                   [cn]0x09 定时器线程启动失败 */
      TSDK_E_MANAGER_ERR_SERVICE_ALREADY_EXIST_ERR,           /**< [en]0x0A Indicates WS service is already runing.
                                                                   [cn]0x0A ws服务已经存在*/
      TSDK_E_MANAGER_ERR_UNSUPPORT_SERVER_TYPE,               /**< [en]0x0B Indicates unsupport server type SMC2.0.
                                                                   [cn]0x0B 不支持SMC2.0组网*/
      TSDK_E_MANAGER_ERR_CMPT_NUMBER_OF_CERTIFICATE,          /**< [en]0x0C Indicates the number of certificates is
                                                                       greater than 20 or less than or equal to 0.
                                                                   [cn]0x0C 证书数量大于20或者小于等于0  */
      TSDK_E_MANAGER_ERR_CMPT_CERTIFICATE_FORMAT,             /**< [en]0x0D Indicates incorrect certificate format.
                                                                   [cn]0x0D 证书格式错误  */
      TSDK_E_MANAGER_ERR_CMPT_CERTIFICATE_PATH_IS_NULL,       /**< [en]0x0E Indicates the certificate path is empty.
                                                                   [cn]0x0E 证书路径为空值  */
      TSDK_E_MANAGER_ERR_CMPT_PATH_IS_INVALID,                /**< [en]0X0F Indicates the certificate path is invalid.
                                                                   [cn]0x0F 证书路径无效  */
      TSDK_E_MANAGER_ERR_PARAM_CONVERT_FAIL,                  /**< [en]0X10 Indicates the certificate path is invalid.
                                                                   [cn]0x10 参数转化错误  */
      TSDK_E_ERR_MANAGER_USER_NOT_LOGGED_IN,                  /**< [en]0X11 Indicates user unlogged in .
                                                                   [cn]0x11 用户未登录  */

      TSDK_E_MANAGER_ERR_BUTT
}TSDK_E_MANAGER_ERR_ID;



/**
 * [en]This enumeration is used to describe error code definitions of service manager and login module.
 * [cn]业务管理和登录模块错误码定义
 */
typedef enum tagTSDK_E_LOGIN_ERR_ID
{
    TSDK_E_LOGIN_ERR_BEGIN = 0x01FFFFFF,

    TSDK_E_LOGIN_ERR_UNKNOWN,                               /**< [en]0x00 Indicates unknown error
                                                                 [cn]0x00 未知错误 */

    TSDK_E_LOGIN_ERR_GENERAL_ERROR,                         /**< [en]0x01 Indicates general error
                                                                 [cn]0x01 一般错误 */
    TSDK_E_LOGIN_ERR_PARAM_ERROR,                           /**< [en]0x02 Indicates parameter error
                                                                 [cn]0x02 参数错误 */
    TSDK_E_LOGIN_ERR_MALLOC_FAILED,                         /**< [en]0x03 Indicates allocate memory failed
                                                                 [cn]0x03 分配内存错误 */
    TSDK_E_LOGIN_ERR_SYSTEM_ERROR,                          /**< [en]0x04 Indicates system error
                                                                 [cn]0x04 系统错误 */
    TSDK_E_LOGIN_ERR_LOAD_LIBRARY_FAILED,                   /**< [en]0x05 Indicates load library failed
                                                                 [cn]0x05 加载库错误 */
    //6
    TSDK_E_LOGIN_ERR_SDK_UNINITIALIZED,                     /**< [en]0x06 Indicates sdk uninitialized
                                                                 [cn]0x06 SDK未初始化 */
    TSDK_E_LOGIN_ERR_SDK_INIT_REPEAT,                       /**< [en]0x07 Indicates sdk Initialization repetition
                                                                 [cn]0x07 SDK初始化重复 */
    TSDK_E_LOGIN_ERR_AUTH_RESULT_INVAILD,                   /**< [en]0x08 Indicates authorize result invalid, like lack necessary field
                                                                 [cn]0x08 鉴权结果信息无效，如缺少必要字段 */
    TSDK_E_LOGIN_ERR_TIMEOUT,                               /**< [en]0x09 Indicates timeout.
                                                                 [cn]0x09 超时 */
    TSDK_E_LOGIN_ERR_XML_ERROR,                             /**< [en]0x0A Indicates XML parsing error.
                                                                 [cn]0x0A XML解析出错 */
    //11
    TSDK_E_LOGIN_ERR_PARSE_PTKT_ERROR,                      /**< [en]0x0B Indicates that the parse server PTKT package is abnormal.
                                                                 [cn]0x0B 解析服务器PTKT包异常 */
    TSDK_E_LOGIN_ERR_DNS_ERROR,                             /**< [en]0x0C Indicates DNS resolution exception.
                                                                 [cn]0x0C DNS解析异常 */
    TSDK_E_LOGIN_ERR_REQUEST_FAILED,                        /**< [en]0x0D Indicates that the request message is abnormal.
                                                                 [cn]0x0D 请求消息异常 */
    TSDK_E_LOGIN_ERR_AUTH_FAILED,                           /**< [en]0x0E Indicates authentication failure.
                                                                 [cn]0x0E 鉴权失败 */
    TSDK_E_LOGIN_ERR_SN_FAILED,                             /**< [en]0x0F Indicates that the sn match failed.
                                                                 [cn]0x0F sn匹配失败 */
    //16
    TSDK_E_LOGIN_ERR_SERVICE_ERROR,                         /**< [en]0x10 Indicates a server exception.
                                                                 [cn]0x10 服务器异常 */
    TSDK_E_LOGIN_ERR_ACCOUNT_LOCKED,                        /**< [en]0x11 Indicates that the account is locked.
                                                                 [cn]0x11 帐号被锁定 */
    TSDK_E_LOGIN_ERR_TIMER_ERROR,                           /**< [en]0x12 Indicates create timer error.
                                                                 [cn]0x12 创建定时器错误 */
    TSDK_E_LOGIN_ERR_WRONG_SERVERTYPE,                      /**< [en]0x13 Indicates wrong server type.
                                                                 [cn]0x13 错误的服务器类型 */
    TSDK_E_LOGIN_ERR_WRONG_SERVERVERSION,                   /**< [en]0x14 Indicates wrong server version.
                                                                 [cn]0x14 错误的服务器版本 */
    //21
    TSDK_E_LOGIN_ERR_INVALID_URL,                           /**< [en]0x15 Indicates invalid URL.
                                                                 [cn]0x15 无效的URL */
    TSDK_E_LOGIN_ERR_SEARCH_SERVER_FAIL,                    /**< [en]0x16 Indicates query server address failed.
                                                                 [cn]0x16 查询服务器地址失败 */
    TSDK_E_LOGIN_ERR_START_REFRESH_FAIL,                    /**< [en]0x17 Indicates start Token refresh failed.
                                                                 [cn]0x17 启动Token刷新失败 */
    TSDK_E_LOGIN_ERR_NOT_SUPPORT_MOD_PWD,                   /**< [en]0x18 Indicates The system does not support to change password.
                                                                 [cn]0x18 系统不支持修改密码 */
    TSDK_E_LOGIN_ERR_WRONG_OLD_PWD,                         /**< [en]0x19 Indicates the old password is incorrect.
                                                                 [cn]0x19 老密码错误 */
    //26
    TSDK_E_LOGIN_ERR_INVAILD_NEW_PWD_LEN,                   /**< [en]0x1A Indicates the new password length is illegal.
                                                                 [cn]0x1A 新密码长度非法 */
    TSDK_E_LOGIN_ERR_INVAILD_NEW_PWD_LEVEL,                 /**< [en]0x1B Indicates the new password does not meet complexity requirements.
                                                                 [cn]0x1B 新密码复杂度不满足要求 */
    TSDK_E_LOGIN_ERR_NEW_PWD_CANNOT_SAME_WITH_HISTROY_PWD,  /**< [en]0x1C Indicates the new password can not be the same as the last old passwords.
                                                                 [cn]0x1C 新密码不能与最近旧密码相同 */
    TSDK_E_LOGIN_ERR_NEW_PWD_REPEAT_CHAR_NUM_IS_BIG,        /**< [en]0x1D Indicates the new password can not contain three or more repeated characters.
                                                                 [cn]0x1D 新密码不能包含3个以上重复字符 */
    TSDK_E_LOGIN_ERR_MOD_PWD_TOO_FREQUENTLY,                /**< [en]0x1E Indicates the password cannot be modified twice within 5 minutes.
                                                                 [cn]0x1E 上次修改密码后5分钟内不能更新密码 */
    //31
    TSDK_E_LOGIN_ERR_NEW_PWD_CANNOT_CONTAIN_ACCOUNT,        /**< [en]0x1F Indicates the password can not contain the account or accounts in reverse.
                                                                 [cn]0x1F 密码不能包含帐号或其逆序帐号 */
    TSDK_E_LOGIN_ERR_NEW_PWD_CONTAIN_TOO_MANY_SAME_CHAR_WITH_OLD_PWD,/**< [en]0x20 Indicates the new password must have at least two different characters compared to the old password.
                                                                     [cn]0x20 新密码相较于老密码至少要有两个不同的字符 */
    TSDK_E_LOGIN_ERR_MOD_PWD_ON_HSS_FAIL,                   /**< [en]0x21 Indicates Change password on the HSS fails.
                                                                 [cn]0x21 HSS上修改密码失败 */
    TSDK_E_LOGIN_ERR_AUTH_NAME_OR_PWD_ERROR,                /**< [en]0x22 Indicates username or password is incorrect.
                                                                 [cn]0x22 用户名或者密码错误 */
    TSDK_E_LOGIN_ERR_USER_IS_LOCKED,                        /**< [en]0x23 Indicates the user is locked.
                                                                 [cn]0x23 用户已被锁定 */
    //36
    TSDK_E_LOGIN_ERR_NONCE_FAIL,                            /**< [en]0x24 Indicates nonce is incorrect.
                                                                 [cn]0x24 nonce接入码错误 */
    TSDK_E_LOGIN_ERR_CA_VERIFY_FAILED,                      /**< [en]0x25 Indicates server ca verify failed
                                                                 [cn]0x25 服务器ca证书校验失败 */
    TSDK_E_LOGIN_ERR_NETWORK_ERROR,                         /**< [en]0x26 Indicates abnormal network
                                                                 [cn]0x26 网络异常 */
    TSDK_E_LOGIN_ERR_RANDOM_ERROR,                          /**< [en]0x27 Indicates random is incorrect
                                                                 [cn]0x27 随机数错误 */
    TSDK_E_LOGIN_ERR_NEED_PASSWORD,                         /**< [en]0x28 Indicates password is missing, please input password
                                                                 [cn]0x28 缺少密码 ，请输入密码 */
    //41
    TSDK_E_LOGIN_ERR_CONF_ENDED,                            /**< [en]0x29 Indicates the conference has ended
                                                                 [cn]0x29 会议已经结束 */
    TSDK_E_LOGIN_ERR_IP_LOCKED,                             /**< [en]0x2A Indicates that the ip is locked.
                                                                 [cn]0x2A ip被锁定 */
    TSDK_E_LOGIN_ERR_SERVER_REDIRECT,                       /**< [en]0x2B Indicates the server has a redirect ip address
                                                                 [cn]0x2B 服务器返回重定向地址*/
    TSDK_E_LOGIN_ERR_CONF_LOCKED,                           /**< [en]0x2C Indicates that the conference is locked.
                                                                 [cn]0x2C 会议被锁定 */
    TSDK_E_LOGIN_ERR_CONF_NOT_CONVOKED,                     /**< [en]0x2D Indicates that the conference is not convoked.
                                                                 [cn]0x2D 会议没有召开 */
    //46
    TSDK_E_LOGIN_ERR_AUTH_TIMEOUT,                          /**< [en]0x2E Indicates that the authentication is time out.
                                                                 [cn]0x2E 鉴权超时 */
    TSDK_E_LOGIN_ERR_AUTH_ERROR,                            /**< [en]0x2F Indicates that the conference is not convoked.
                                                                 [cn]0x2F 鉴权失败 */
    TSDK_E_LOGIN_ERR_AUTH_UCCORP_DIACTIVE,                  /**< [en]0x30 Indicates that the enterprise is not activated.
                                                                 [cn]0x30 企业未激活 */
    TSDK_E_LOGIN_ERR_AUTH_UCSP_DIACTIVE,                    /**< [en]0x31 Indicates that the service provider is not activated.
                                                                 [cn]0x31 服务提供商未激活 */
    TSDK_E_LOGIN_ERR_AUTH_ACCOUNT_DIACTIVE,                 /**< [en]0x32 Indicates that the account is not activated.
                                                                 [cn]0x32 账号未激活 */
    // 51
    TSDK_E_LOGIN_ERR_USER_REPEAT_LOGIN,                     /**< [en]0x33 Indicates users repeat login.
                                                                 [cn]0x33 用户重复登录  */
    TSDK_E_LOGIN_ERR_FIRST_LOGIN_MODIFY_PWD,                /**< [en]0x34 Indicates smc3.0 users firstly modify pwd return 401.
                                                                 [cn]0x34 smc3.0 首次修改密码失败401  */
    TSDK_E_LOGIN_ERR_NEW_PWD_CANNOT_SAME_WITH_OLD_PWD,      /**< [en]0x35 Indicates smc3.0 users new pwd cannot same with old pwd.
                                                                 [cn]0x35 新密码不能与旧密码相同   */
    TSDK_E_LOGIN_ERR_JSON_ERROR,                            /**< [en]0x36 Indicates json error.
                                                                 [cn]0x36 JSON解析出错 */
    TSDK_E_LOGIN_ERR_ACCOUNT_EXPIRE,                        /**< [en]0x37 Indicates the account is expire.
                                                                 [cn]0x37 账号已过期 */
    // 56
    TSDK_E_LOGIN_ERR_NO_ACCESS_PERMISSION,                  /**< [en]0x38 Indicates that no access permission.
                                                                 [cn]0x38 无权限访问 */ 
    TSDK_E_LOGIN_ERR_TOKEN_IN_REPEATED_LOGIN,               /**< [en]0x39 Indicates that token repeated login.
                                                                 [cn]0x39 重复登录状态*/
    TSDK_E_LOGIN_ERR_TOKEN_IN_ACTIVATION,                   /**< [en]0x40 Indicates that token in activation.
                                                                 [cn]0x40 token激活状态 */ 
    TSDK_E_LOGIN_ERR_TOKEN_IN_LOCKED,                       /**< [en]0x41 Indicates that token in locked.
                                                                 [cn]0x41 token锁定状态 */
    TSDK_E_LOGIN_ERR_TOKEN_IN_EXPIRED,                      /**< [en]0x42 Indicates that token in expired.
                                                                 [cn]0x42 token过期状态 */
    // 61
    TSDK_E_LOGIN_ERR_TOKEN_NOT_EXIST,                       /**< [en]0x43 Indicates that token not exist.
                                                                 [cn]0x43 token 已不存在状态 */
    TSDK_E_LOGIN_ERR_USER_DELETED,                          /**< [en]0x44 Indicates that user deleted.
                                                                 [cn]0x44 用户被删除，token失效状态 */ 
    TSDK_E_LOGIN_ERR_USER_PERMISSION_MODIFIED,              /**< [en]0x45 Indicates that user premission modified.
                                                                 [cn]0x45 用户权限被管理修改，token失效状态 */ 
    TSDK_E_LOGIN_ERR_USER_PWD_MODIFIED,                     /**< [en]0x46 Indicates that user pwd modified.
                                                                 [cn]0x46 用户密码被管理修改，token失效状态 */
    TSDK_E_LOGIN_ERR_USER_WEAK_PASSWORD,                    /**< [en]0x47 Indicates that weak password.
                                                                 [cn]0x47 用户密码是弱密码 */
    TSDK_E_LOGIN_ERR_USER_REPEAT_LOGOUT,                    /**< [en]0x48 Indicates account already logout.
                                                                 [cn]0x48 账号已登出，请勿重复调用 */
    TSDK_E_LOGIN_ERR_BUTT
}TSDK_E_LOGIN_ERR_ID;


typedef enum tagTSDK_E_CALL_ERR_ID
{
    TSDK_E_CALL_ERR_BEGIN = 0x02FFFFFF,

    TSDK_E_CALL_ERR_UNKNOWN,                                /**< [en]0x00 Indicates unknown error
                                                                 [cn]0x00 未知错误 */

    TSDK_E_CALL_ERR_GENERAL_ERROR,                          /**< [en]0x01 Indicates general error
                                                                 [cn]0x01 一般错误 */
    TSDK_E_CALL_ERR_PARAM_ERROR,                            /**< [en]0x02 Indicates parameter error
                                                                 [cn]0x02 参数错误 */
    TSDK_E_CALL_ERR_MALLOC_FAILED,                          /**< [en]0x03 Indicates allocate memory failed
                                                                 [cn]0x03 分配内存错误 */
    TSDK_E_CALL_ERR_SYSTEM_ERROR,                           /**< [en]0x04 Indicates system error
                                                                 [cn]0x04 系统错误 */
    TSDK_E_CALL_ERR_LOAD_LIBRARY_FAILED,                    /**< [en]0x05 Indicates load library failed
                                                                 [cn]0x05 加载库错误 */
    TSDK_E_CALL_ERR_SDK_UNINITIALIZED,                      /**< [en]0x06 Indicates sdk uninitialized
                                                                 [cn]0x06 SDK未初始化 */
    TSDK_E_CALL_ERR_SDK_INIT_REPEAT,                        /**< [en]0x07 Indicates sdk Initialization repetition
                                                                 [cn]0x07 SDK初始化重复 */
    TSDK_E_CALL_ERR_MSG_ERROR,                              /**< [en]0x08  Indicates send message error
                                                                 [cn]0x08 发送消息错误 */
    TSDK_E_CALL_ERR_CFG_ERROR,                              /**< [en]0x09  Indicates get system configuration error
                                                                 [cn]0x09 获取系统配置错误 */
    TSDK_E_CALL_ERR_NET_ERROR,                              /**< [en]0x0A  Indicates physics network error
                                                                 [cn]0x0A 物理网络错误 */
    TSDK_E_CALL_ERR_ACCESS_ERROR,                           /**< [en]0x0B Indicates network access error
                                                                 [cn]0x0B 网络接入错误 */
    TSDK_E_CALL_ERR_TIMER_ERROR,                            /**< [en]0x0C Indicates create timer error
                                                                 [cn]0x0C 创建定时器错误 */
    TSDK_E_CALL_ERR_STATE_ERROR,                            /**< [en]0x0D Indicates call status error
                                                                 [cn]0x0D 呼叫状态错误 */
    TSDK_E_CALL_ERR_OPERATE_ERROR,                          /**< [en]0x0E Indicates other operation errors are in progress
                                                                 [cn]0x0E 正在进行其他操作错误 */
    TSDK_E_CALL_ERR_REQSRV_ERROR,                           /**< [en]0x0F Indicates request the master to make a call start error
                                                                 [cn]0x0F [MODIFY]请求主控进行呼叫开始错误 */
    TSDK_E_CALL_ERR_REQRES_ERROR,                           /**< [en]0x10 Indicates request audio resource error
                                                                 [cn]0x10 申请音频资源错误 */
    TSDK_E_CALL_ERR_SERVICE_DOING,                          /**< [en]0x11 Indicates other supplementary services are in progress
                                                                 [cn]0x11 正在进行其他补充业务 */
    TSDK_E_CALL_ERR_CALLRECORD_ERROR,                       /**< [en]0x12 Indicates record a call log error
                                                                 [cn]0x12 记录通话记录错误 */
    TSDK_E_CALL_ERR_MPROC_ERROR,                            /**< [en]0x13 Indicates the media process returned an error
                                                                 [cn]0x13 媒体进程返回的错误 */
    TSDK_E_CALL_ERR_MAX_CALL_ERROR,                         /**< [en]0x14 Indicates the maximum number of calls is exceeded error
                                                                 [cn]0x14 超过最大呼叫路数 */
    TSDK_E_CALL_ERR_SIPID_NOTEXIT_ERROR,                    /**< [en]0x15 Indicates the SIP account ID does not exist error
                                                                 [cn]0x15 SIP账户ID不存在 */
    TSDK_E_CALL_ERR_CALLID_NOEXIT_ERROR,                    /**< [en]0x16 Indicates call ID does not exist error
                                                                 [cn]0x16 呼叫ID不存在 */
    TSDK_E_CALL_ERR_REGISTERING_ERROR,                      /**< [en]0x17 Indicates the error caused by a already exist registering
                                                                 [cn]0x17 正在注册中导致失败 */
    TSDK_E_CALL_ERR_REGIST_FALL_ERROR,                      /**< [en]0x18 Indicates register error
                                                                 [cn]0x18 注册失败 */
    TSDK_E_CALL_ERR_DEREGIST_FALL_ERROR,                    /**< [en]0x19 Indicates deregist error
                                                                 [cn]0x19 注销失败 */
    TSDK_E_CALL_ERR_SET_SIP_INFO_ERROR,                     /**< [en]0x1A Indicates set account information error
                                                                 [cn]0x1A 设置帐号信息错误 */
    TSDK_E_CALL_ERR_SETACCOUNT_ERROR,                       /**< [en]0x1B Indicates set sip account error
                                                                 [cn]0x1B 设置SIP帐号失败 */
    TSDK_E_CALL_ERR_NOTIFYSIPACCOUNT_ERROR,                 /**< [en]0x1C Indicates notify sip account information error
                                                                 [cn]0x1C 上报SIP帐号信息失败 */
    TSDK_E_CALL_ERR_SIPSEVER_ERROR,                         /**< [en]0x1D Indicates server information error
                                                                 [cn]0x1D 服务器信息错误 */
    TSDK_E_CALL_ERR_SIPACCOUNTINFO_ERROR,                   /**< [en]0x1E Indicates account information error
                                                                 [cn]0x1E 账户信息错误 */
    TSDK_E_CALL_ERR_SIPC_ERROR,                             /**< [en]0x1F Indicates SIPC execution error
                                                                 [cn]0x1F SIPC执行错误 */
    TSDK_E_CALL_ERR_UNREGISTER_ERROR,                       /**< [en]0x20 Indicates unregistered error
                                                                 [cn]0x20 未注册错误 */
    TSDK_E_CALL_ERR_SUB_FALL_ERROR,                         /**< [en]0x21 Indicates fail to invoke sip interface to subscribe error
                                                                 [cn]0x21 调用Sip接口订阅失败 */
    TSDK_E_CALL_ERR_DESUBING_ERROR,                         /**< [en]0x22 Indicates desubscribing error
                                                                 [cn]0x22 注销订阅中错误 */
    TSDK_E_CALL_ERR_SUBING_ERROR,                           /**< [en]0x23 Indicates subscribing error
                                                                 [cn]0x23 订阅中错误 */
    TSDK_E_CALL_ERR_LOCAL_MAX_CONFER_ERROR,                 /**< [en]0x24 Indicates allowing only one local conference
                                                                 [cn]0x24 只允许一个本地会议 */
    TSDK_E_CALL_ERR_LOCAL_CONFER_NOEXIT_ERROR,              /**< [en]0x25 Indicates the local conference is not created
                                                                 [cn]0x25 本地会议未创建 */
    TSDK_E_CALL_ERR_LOCAL_CONFER_NOMATCH_ERROR,             /**< [en]0x26 Indicates the attendee line does not match the chairman account error
                                                                 [cn]0x26 与会者线路与主席账户不匹配*/
    TSDK_E_CALL_ERR_CONF_STATE_ERROR,                       /**< [en]0x27 Indicates the local conference state error
                                                                 [cn]0x27 本地会议状态错误*/
    TSDK_E_CALL_ERR_JOINTSTATENOTIFY_ERROR,                 /**< [en]0x28 Indicates fail to report IP phone linkage state error
                                                                 [cn]0x28 IP Phone端联动状态上报失败*/
    TSDK_E_CALL_ERR_CONFID_NOTEXIST_ERROR,                  /**< [en]0x29 Indicates the conference ID does not exist error
                                                                 [cn]0x29 会议ID不存在 */
    TSDK_E_CALL_ERR_CONF_VIDEO_HOLD_ERROR,                  /**< [en]0x2A Indicates fail to hold video error
                                                                 [cn]0x2A 视频保持失败 */
    TSDK_E_CALL_ERR_CONF_VIDEO_UNHOLD_ERROR,                /**< [en]0x2B Indicates fail to recover video error
                                                                 [cn]0x2B 视频恢复失败 */
    TSDK_E_CALL_ERR_MAX_SERVER_CONF_ERROR,                  /**< [en]0x2C Indicates server conference number overflow error
                                                                 [cn]0x2C 服务器会议个数超出 */
    TSDK_E_CALL_ERR_AA_REQRANDOMNUM_ERROR,                  /**< [en]0x2D Indicates fail to get AA random number error
                                                                 [cn]0x2D 获取AA随机数失败 */
    TSDK_E_CALL_ERR_AA_LOGIN_ERROR,                         /**< [en]0x2E Indicates fail to login AA error
                                                                 [cn]0x2E AA登陆失败 */
    TSDK_E_CALL_ERR_CONF_VIDEO_TYPE_NO_MATCH,               /**< [en]0x2F Indicates conference type mismatching error
                                                                 [cn]0x2F 会议类型不匹配*/
    TSDK_E_CALL_ERR_CONF_VIDEO_START_ERROR,                 /**< [en]0x30 Indicates fail to start a video conference error
                                                                 [cn]0x30 视频会议开启失败*/
    TSDK_E_CALL_ERR_AA_NOMAINSERVER_ERROR,                  /**< [en]0x31 Indicates AA no master server error
                                                                 [cn]0x31 AA无主服务器 */
    TSDK_E_CALL_ERR_AA_PASSWORD_ERROR,                      /**< [en]0x32 Indicates password error
                                                                 [cn]0x32 密码错误 */
    TSDK_E_CALL_ERR_AA_USERNAME_ERROR,                      /**< [en]0x33 Indicates username error
                                                                 [cn]0x33 用户名错误 */
    TSDK_E_CALL_ERR_AA_USERLOGINED_ERROR,                   /**< [en]0x34 Indicates user logined error
                                                                 [cn]0x34 用户已登录 */
    TSDK_E_CALL_ERR_AA_ACCOUNTLOCKED_ERROR,                 /**< [en]0x35 Indicates account is locked error
                                                                 [cn]0x35 账户已锁定 */
    TSDK_E_CALL_ERR_AA_TERMINALTYPE_ERROR,                  /**< [en]0x36 Indicates terminal type mismatching error
                                                                 [cn]0x36 终端类型不匹配 */
    TSDK_E_CALL_ERR_AA_PARSEXML_ERROR,                      /**< [en]0x37 Indicates parse XML error
                                                                 [cn]0x37 解析XML错误 */
    TSDK_E_CALL_ERR_AA_CONNECT_ERROR,                       /**< [en]0x38 Indicates connect server error
                                                                 [cn]0x38 连接服务器错误 */
    TSDK_E_CALL_ERR_MEDIA_CFG_ERROR,                        /**< [en]0x39 Indicates fail to get media configuration
                                                                 [cn]0x39 获取媒体配置失败 */
    TSDK_E_CALL_ERR_AA_GETSRINFO_ERROR,                     /**< [en]0x3A Indicates fail to get service right
                                                                 [cn]0x3A 获取业务权限失败 */
    TSDK_E_CALL_ERR_AA_LACKSR_ERROR,                        /**< [en]0x3B Indicates lack of service right error
                                                                 [cn]0x3B 业务权限不足失败 */
    TSDK_E_CALL_ERR_NETWORKENV_ERROR,                       /**< [en]0x3C Indicates network environment error
                                                                 [cn]0x3C 网络环境错误 */
    TSDK_E_CALL_ERR_SERVICE_CONFLICT_ERROR,                 /**< [en]0x3D Indicates service conflict error
                                                                 [cn]0x3D 业务冲突 */
    TSDK_E_CALL_ERR_AA_TIMEOUT_ERROR,                       /**< [en]0x3E Indicates timeout error
                                                                 [cn]0x3E 连接超时 */
    TSDK_E_CALL_ERR_AA_UNKOWN_ERROR,                        /**< [en]0x3F Indicates unknown error
                                                                 [cn]0x3F 未知错误 */
    TSDK_E_CALL_ERR_PICKUP_ADDTIP_ERROR,                    /**< [en]0x40 Indicates fail to add ring information
                                                                 [cn]0x40 添加振铃信息失败 */
    TSDK_E_CALL_ERR_PICKUP_REMOVETIP_ERROR,                 /**< [en]0x41 Indicates fail to remove ring information
                                                                 [cn]0x41 删除加振铃信息失败 */
    TSDK_E_CALL_ERR_PICKUP_CREATERINGNUM_ERROR,             /**< [en]0x42 Indicates fail to Create ring number error
                                                                 [cn]0x42 创建振铃号码失败 */
    TSDK_E_CALL_ERR_VVM_PARAM_ERR,                          /**< [en]0x43 Indicates VVM parameter error
                                                                 [cn]0x43 VVM参数错误 */
    TSDK_E_CALL_ERR_GET_IPT_INFO_ERR,                       /**< [en]0x44 Indicates get register service error
                                                                 [cn]0x44 获取登记业务错误 */
    TSDK_E_CALL_ERR_VVM_GETVOICEMAIL_ERR,                   /**< [en]0x45 Indicates get voice mailbox error
                                                                 [cn]0x45 获取语音邮箱错误 */
    TSDK_E_CALL_ERR_ATTENDEE_ALREADY_EXIST,                 /**< [en]0x46 Indicates attendee already exist
                                                                 [cn]0x46 与会者已经存在 */
    TSDK_E_CALL_ERR_ATTENDEE_NOT_EXIST,                     /**< [en]0x47 Indicates attendee not exist
                                                                 [cn]0x47 与会者不存在 */
    TSDK_E_CALL_ERR_CREATE_CONF_WND_ERROR,                  /**< [en]0x48 Indicates fail to create server video conference window
                                                                 [cn]0x48 创建服务器视频会议窗口失败*/
    TSDK_E_CALL_ERR_CREATE_CONF_WND_EXIST,                  /**< [en]0x49 Indicates the video window exist
                                                                 [cn]0x49 [MODIFY]视频窗口已存在*/
    TSDK_E_CALL_ERR_GET_CONF_LIST_INFO_ERROR,               /**< [en]0x4A Indicates fail to get conference list
                                                                 [cn]0x4A 获取会议列表失败*/
    TSDK_E_CALL_ERR_NEED_CHAIRMAN_TO_OPERATE,               /**< [en]0x4B Indicates chairman privileges are required to operate
                                                                 [cn]0x4B 需要主持人权限才能操作*/
    TSDK_E_CALL_ERR_NO_VIDEO_DEVICE_TO_OPERATE,             /**< [en]0x4C Indicates no video device can be operated
                                                                 [cn]0x4C 没有视频设备可以操作*/
    TSDK_E_CALL_ERR_NOT_STOP_REFRESHREG,                    /**< [en]0x4D Indicates refresh registration is not stopped
                                                                 [cn]0x4D 没有关闭刷新注册*/
    TSDK_E_CALL_ERR_NOTIFY_ONLINE_STATE_ERROR,              /**< [en]0x4E Indicates the online status notify fails
                                                                 [cn]0x4E 在线状态上报失败*/
    TSDK_E_CALL_ERR_NOTIFY_NETADDR_ERROR,                   /**< [en]0x4F Indicates the network address of this subscription notify fails to report
                                                                 [cn]0x4F 网络地址本订阅notify上报失败*/
    TSDK_E_CALL_ERR_INFO_FORCEUNREG_ERROR,                  /**< [en]0x50 Indicates telepresence account was kicked, information reported failure
                                                                 [cn]0x50 智真帐号被踢,info上报失败*/
    TSDK_E_CALL_ERR_TLSROOTCERT_ERROR,                      /**< [en]0x51 Indicates TLS root certificate error
                                                                 [cn]0x51 TLS根证书错误*/
    TSDK_E_CALL_ERR_AD_AUTH_FAIL,                           /**< [en]0x52 Indicates AD authentication failed
                                                                 [cn]0x52 AD鉴权失败 */
    TSDK_E_CALL_ERR_GET_CONF_LIST_INFO_DOING,               /**< [en]0x53 Indicates conference list is getting
                                                                 [cn]0x53 会议列表正在获取中 */
    TSDK_E_CALL_ERR_CALL_PROHIBITED,                        /**< [en]0x54 Indicates calls are disabled
                                                                 [cn]0x54 禁止呼叫*/
    TSDK_E_CALL_ERR_CALL_NUMBER_UPPER_LIMIT,                /**< [en]0x55 Indicates call number upper limit
                                                                 [cn]0x55 呼叫数达上限*/
    TSDK_E_CALL_ERR_ENCRYPT_CALL_UPPER_LIMIT,               /**< [en]0x56 Indicates encrypted call upper limit
                                                                 [cn]0x56 加密呼叫数达上限*/
    TSDK_E_CALL_ERR_SHOULD_DEGRADE_TO_AUDIO,                /**< [en]0x57 Indicates video upper limit and degrade to audio
                                                                 [cn]0x57 超出视频呼叫数，需要降为音频 */
    TSDK_E_CALL_ERR_H323ID_NOTEXIST_ERROR,                  /**< [en]0x58 Indicates H323ID is not exist
                                                                 [cn]0x58 H323帐号ID不存在 */
    TSDK_E_CALL_ERR_H323_ACCOUNTINFO_ERROR,                 /**< [en]0x59 Indicates H323 account info is error
                                                                 [cn]0x59 H323帐号信息错误 */
    TSDK_E_CALL_ERR_NOTIFY_H323_ACCOUNT_ERROR,              /**< [en]0x5A Indicates H323 account notify error
                                                                 [cn]0x5A H323帐号信息上报失败  */
    TSDK_E_CALL_ERR_LOCAL_RESOURCE_NOT_ENOUGH,              /**< [en]0x5B Indicates local resource is not enough
                                                                 [cn]0x5B 本端资源不足 */
    TSDK_E_CALL_ERR_CALL_PROTOCOL_NOT_SUPPORT,              /**< [en]0x5C Indicates not support call protocol
                                                                 [cn]0x5C 不支持该呼叫协议*/
    TSDK_E_CALL_ERR_SET_H323_INFO_ERROR,                    /**< [en]0x5D Indicates set H323 account info error
                                                                 [cn]0x5D 设置H323帐号信息错误 */
    TSDK_E_CALL_ERR_NOTIFY_ACCESSNUM_ERROR,                 /**< [en]0x5E Indicates that notify access number to UI failed
                                                                 [cn]0x5E mediax会议接入号上报界面失败*/
    TSDK_E_CALL_ERR_NOTIFY_VMRINFO_ERROR,                   /**< [en]0x5F Indicates that notify vmr info to UI failed
                                                                 [cn]0x5F 上报Mediax VMR信息到界面失败*/
    TSDK_E_CALL_ERR_NOTIFY_CONFLIST_INFO_ERROR,             /**< [en]0x60 Indicates that get conference list to UI failed
                                                                 [cn]0x60 上报获取IMS会议列表信息到界面失败*/

    TSDK_E_CALL_ERR_REASON_CODE_OK,                         /**< [en]0x61 Indicates server return "success", reason code:200
                                                                 [cn]0x61 服务器返回"成功", 响应码:200 */
    TSDK_E_CALL_ERR_REASON_CODE_BADREQUEST,                 /**< [en]0x62 Indicates server return "bad request", reason code:400
                                                                 [cn]0x62 服务器返回"错误请求", 响应码:400 */
    TSDK_E_CALL_ERR_REASON_CODE_NOTAUTHORIZED,              /**< [en]0x63 Indicates server return "not authorized", reason code:401
                                                                 [cn]0x63 服务器返回"未经授权", 响应码:401 */
    TSDK_E_CALL_ERR_REASON_CODE_PAYMENTREQUIRED,            /**< [en]0x64 Indicates server return "payment required", reason code:402
                                                                 [cn]0x64 服务器返回"付费要求", 响应码:402  */
    TSDK_E_CALL_ERR_REASON_CODE_FORBIDDEN,                  /**< [en]0x65 Indicates server return "forbidden", reason code:403
                                                                 [cn]0x65 服务器返回"禁止", 响应码:403  */
    TSDK_E_CALL_ERR_REASON_CODE_NOTFOUND,                   /**< [en]0x66 Indicates server return "not found", reason code: 404
                                                                 [cn]0x66 服务器返回"未发现", 响应码:404  */
    TSDK_E_CALL_ERR_REASON_CODE_METHODNOTALLOWED,           /**< [en]0x67 Indicates server return "method no allowed", reason code: 405
                                                                 [cn]0x67 服务器返回"方法不允许", 响应码:405  */
    TSDK_E_CALL_ERR_REASON_CODE_RESNOTACCEPTABLE,           /**< [en]0x68 Indicates server return "not acceptable", reason code: 406
                                                                 [cn]0x68 服务器返回"不可接受", 响应码:406  */
    TSDK_E_CALL_ERR_REASON_CODE_NEEDPROXYAUTH,              /**< [en]0x69 Indicates server return "need proxy authorize", reason code: 407
                                                                 [cn]0x69 服务器返回"需要代理授权", 响应码:407  */
    TSDK_E_CALL_ERR_REASON_CODE_REQUESTTIMEOUT,             /**< [en]0x6A Indicates server return "request timeout", reason code: 408
                                                                 [cn]0x6A 服务器返回"请求超时", 响应码:408  */
    TSDK_E_CALL_ERR_REASON_CODE_GONE,                       /**< [en]0x6B Indicates server return "gone", reason code: 410
                                                                 [cn]0x6B 服务器返回"离开", 响应码:410  */
    TSDK_E_CALL_ERR_REASON_CODE_REQUESTENTITYTOOLARGE,      /**< [en]0x6C Indicates server return "request entity too large", reason code: 413
                                                                 [cn]0x6C 服务器返回"请求实体太大 ", 响应码:413 */
    TSDK_E_CALL_ERR_REASON_CODE_REQUESTURITOOLONG,          /**< [en]0x6D Indicates server return "request url too long", reason code: 414
                                                                 [cn]0x6D 服务器返回"请求URL太长", 响应码:414  */
    TSDK_E_CALL_ERR_REASON_CODE_UPSUPPORTEDMEDIATYPE,       /**< [en]0x6E Indicates server return "unsupported media type", reason code: 415
                                                                 [cn]0x6E 服务器返回"不支持的媒体类型", 响应码:415  */
    TSDK_E_CALL_ERR_REASON_CODE_UPSUPPORTEDURISCHEME,       /**< [en]0x6F Indicates server return "unsupported url scheme", reason code: 416
                                                                 [cn]0x6F 服务器返回"不支持的URL计划", 响应码:416  */
    TSDK_E_CALL_ERR_REASON_CODE_BADEXTENSION,               /**< [en]0x70 Indicates server return "bad extension", reason code: 420
                                                                 [cn]0x70 服务器返回"不良扩展", 响应码:420  */
    TSDK_E_CALL_ERR_REASON_CODE_EXTENSIONREQUIRED,          /**< [en]0x71 Indicates server return "extension required", reason code: 421
                                                                 [cn]0x71 服务器返回"需要扩展", 响应码:421   */
    TSDK_E_CALL_ERR_REASON_CODE_TEMPORARILYUNAVAILABLE,     /**< [en]0x72 Indicates server return "temporarily unavailable", reason code: 480
                                                                 [cn]0x72 服务器返回"临时失效", 响应码:480  */
    TSDK_E_CALL_ERR_REASON_CODE_CALLTRANSACTIONDOESNOTEXIST,/**< [en]0x73 Indicates server return "call/transaction does not exist", reason code: 481
                                                                 [cn]0x73 服务器返回"呼叫/事务不存在", 响应码:481  */
    TSDK_E_CALL_ERR_REASON_CODE_LOOPDETECTED,               /**< [en]0x74 Indicates server return "loop detected", reason code: 482
                                                                 [cn]0x74 服务器返回"发现环路", 响应码:482  */
    TSDK_E_CALL_ERR_REASON_CODE_TOOMANYHOPS,                /**< [en]0x75 Indicates server return "too many hops", reason code: 483
                                                                 [cn]0x75 服务器返回"跳数太多", 响应码:483  */
    TSDK_E_CALL_ERR_REASON_CODE_ADDRESSINCOMPLETE,          /**< [en]0x76 Indicates server return "address incomplete", reason code: 484
                                                                 [cn]0x76 服务器返回"地址不完整", 响应码:484  */
    TSDK_E_CALL_ERR_REASON_CODE_AMBIGUOUS,                  /**< [en]0x77 Indicates server return "ambiguous", reason code: 485
                                                                 [cn]0x77 服务器返回"不明朗", 响应码:485  */
    TSDK_E_CALL_ERR_REASON_CODE_BUSYHERE,                   /**< [en]0x78 Indicates server return "busy here", reason code: 486
                                                                 [cn]0x78 服务器返回"这里忙", 响应码:486  */
    TSDK_E_CALL_ERR_REASON_CODE_REQUESTTEMINATED,           /**< [en]0x79 Indicates server return "request terminated", reason code: 487
                                                                 [cn]0x79 服务器返回"请求终止", 响应码:487  */
    TSDK_E_CALL_ERR_REASON_CODE_NOTACCEPTABLEHERE,          /**< [en]0x7A Indicates server return "not acceptable here", reason code: 488
                                                                 [cn]0x7A 服务器返回"这里请求不可接受", 响应码:488  */
    TSDK_E_CALL_ERR_REASON_CODE_REQUESTPENDING,             /**< [en]0x7B Indicates server return "request pending", reason code: 491
                                                                 [cn]0x7B 服务器返回"未决请求", 响应码:491  */
    TSDK_E_CALL_ERR_REASON_CODE_UNDECIPHERABLE,             /**< [en]0x7C Indicates server return "undecipherable", reason code: 493
                                                                 [cn]0x7C 服务器返回"不可辨识", 响应码:493  */
    TSDK_E_CALL_ERR_REASON_CODE_SERVERINTERNALERROR,        /**< [en]0x7D Indicates server return "server internal error", reason code: 500
                                                                 [cn]0x7D 服务器返回"服务器内部错误", 响应码:500  */
    TSDK_E_CALL_ERR_REASON_CODE_NOTIMPLEMENTED,             /**< [en]0x7E Indicates server return "not implemented", reason code: 501
                                                                 [cn]0x7E 服务器返回"不可执行", 响应码:501  */
    TSDK_E_CALL_ERR_REASON_CODE_BADGATEWAY,                 /**< [en]0x7F Indicates server return "bad gateway", reason code: 502
                                                                 [cn]0x7F 服务器返回"坏网关", 响应码:502  */
    TSDK_E_CALL_ERR_REASON_CODE_SERVICEUNAVAILABLE,         /**< [en]0x80 Indicates server return "service unavailable", reason code: 503
                                                                 [cn]0x80 服务器返回"服务无效", 响应码:503  */
    TSDK_E_CALL_ERR_REASON_CODE_SERVERTIMEOUT,              /**< [en]0x81 Indicates server return "server time-out", reason code: 504
                                                                 [cn]0x81 服务器返回"服务器超时", 响应码:504  */
    TSDK_E_CALL_ERR_REASON_CODE_VERSIONNOTSUPPORTED,        /**< [en]0x82 Indicates server return "version not supported", reason code: 505
                                                                 [cn]0x82 服务器返回"版本不支持", 响应码:505  */
    TSDK_E_CALL_ERR_REASON_CODE_MESSAGETOOLARGE,            /**< [en]0x83 Indicates server return "message too large", reason code: 513
                                                                 [cn]0x83 服务器返回"消息太大", 响应码:513  */
    TSDK_E_CALL_ERR_REASON_CODE_BUSYEVERYWHERE,             /**< [en]0x84 Indicates server return "busy everywhere", reason code: 600
                                                                 [cn]0x84 服务器返回"全忙", 响应码:600  */
    TSDK_E_CALL_ERR_REASON_CODE_DECLINE,                    /**< [en]0x85 Indicates server return "decline", reason code: 603
                                                                 [cn]0x85 服务器返回"丢弃", 响应码:603  */
    TSDK_E_CALL_ERR_REASON_CODE_DOESNOTEXISTEVERYWHERE,     /**< [en]0x86 Indicates server return "does not exist anywhere", reason code: 604
                                                                 [cn]0x86 服务器返回"不存在", 响应码:604  */
    TSDK_E_CALL_ERR_REASON_CODE_NOTACCEPTABLE,              /**< [en]0x87 Indicates server return "not acceptable", reason code: 606
                                                                 [cn]0x87 服务器返回"不可接受", 响应码:606  */
    TSDK_E_CALL_ERR_REASON_CODE_TLS_CERTIFICATE_INVALIDE,   /**< [en]0x88 Indicates certificate error
                                                                 [cn]0x88 证书错误 */
    TSDK_E_CALL_ERR_REASON_CODE_TLS_RECV_CERTIFICATE_FAIL,  /**< [en]0x89 Indicates receive certificate fail
                                                                 [cn]0x89 接收证书失败 */
    TSDK_E_CALL_ERR_REASON_CODE_REGISTER_RESEND,            /**< [en]0x8A Indicates register info, need to resend(UI needn't deel)
                                                                 [cn]0x8A 注册信息，需要重发(UI不需要处理) */
    TSDK_E_CALL_ERR_REASON_CODE_REGINFO_FAIL,               /**< [en]0x8B Indicates register info  fall
                                                                 [cn]0x8B 注册信息错误 */
    TSDK_E_CALL_ERR_REASON_CODE_SERIALNO_EXCEEDTIME,        /**< [en]0x8C Indicates register table exceed time
                                                                 [cn]0x8C 注册表过期 */
    TSDK_E_CALL_ERR_REASON_CODE_GK_UNREGISTER,              /**< [en]0x8D Indicates GK logout
                                                                 [cn]0x8D GK注销 */
    TSDK_E_CALL_ERR_REASON_CODE_GK_URQ_REGISTER,            /**< [en]0x8E Indicates GK logout and demand register
                                                                 [cn]0x8E GK注销要求重新注册 */
    TSDK_E_CALL_ERR_REASON_CODE_REGISTER_AUTH_FAIL,         /**< [en]0x8F Indicates register auth fail
                                                                 [cn]0x8F 注册认证失败  */
    TSDK_E_CALL_ERR_REASON_CODE_CALLEE_OFFLINE,             /**< [en]0x90 Indicates callee off line
                                                                 [cn]0x90 被叫不在线 */
    TSDK_E_CALL_ERR_REASON_CODE_NOT_REGISTERED,             /**< [en]0x91 Indicates not register
                                                                 [cn]0x91 本端未注册 */
    TSDK_E_CALL_ERR_REASON_CODE_FULL_REGISTRATION_REQUIRED, /**< [en]0x92 Indicates registration exceed the time limit
                                                                 [cn]0x92 注册过期 */
    TSDK_E_CALL_ERR_REASON_CODE_SECURITY_ERROR,             /**< [en]0x93 Indicates security error
                                                                 [cn]0x93 安全原因 */
    TSDK_E_CALL_ERR_REASON_CODE_INVALID_INPUT,              /**< [en]0x94 Indicates invalid input
                                                                 [cn]0x94 非法输入 */
    TSDK_E_CALL_ERR_REASON_CODE_RESPONSE_TIMEOUT,           /**< [en]0x95 Indicates response timeout
                                                                 [cn]0x95 响应超时 */
    TSDK_E_CALL_ERR_REASON_CODE_ROUTE_CALL_TO_GK,           /**< [en]0x96 Indicates route call by GK
                                                                 [cn]0x96 GK 路由呼叫 */
    TSDK_E_CALL_ERR_REASON_CODE_MSD_FAILED,                 /**< [en]0x97 Indicates principal and subordinate affirm fall
                                                                 [cn]0x97 主从确定失败 */
    TSDK_E_CALL_ERR_REASON_CODE_INSUFFICIENT_ENCRYTION_RESOURCE,     /**< [en]0x98 Indicates MCU fail because resource insufficient
                                                                 [cn]0x98 MCU媒体加密资源不足而导致失败 */
    TSDK_E_CALL_ERR_REASON_CODE_NON_STD_REASON,             /**< [en]0x99 Indicates non mark reason   detailed reason by TSDK_E_CALL_ERR_NON_STD_REASON_CODE
                                                                 [cn]0x99 非标信令原因, 详细原因码见TSDK_E_CALL_ERR_NON_STD_REASON_CODE */
    TSDK_E_CALL_ERR_REASON_CODE_OTHER_ERROR,                /**< [en]0x9A Indicates other error
                                                                 [cn]0x9A 其他错误 */
    TSDK_E_CALL_ERR_REASON_CODE_REGISTER_DUPLICATE_ALIAS,   /**< [en]0X9B Indicates H323 register duplicate alias
                                                                 [cn]0x9B H323会场号码重名 */
    TSDK_E_CALL_ERR_REASON_CODE_REGISTER_TRANSPORTNOTSUPPORTED,      /**< [en]0x9C Indicates H323 no find GK
                                                                 [cn]0x9C H323找不到GK*/
    TSDK_E_CALL_ERR_REASON_CODE_DISCONNECT_NO_RESPONSE,     /**< [en]0x9D Indicates H323 the other side no response
                                                                 [cn]0x9D H323对端没有响应*/
    TSDK_E_CALL_ERR_REASON_CODE_FAIL_ENCRYPT_NEGOTIATION,   /**< [en]0x9E Indicates encrypt negotiation fall
                                                                 [cn]0x9E 媒体加密协商失败*/
    TSDK_E_CALL_ERR_REASON_CODE_BANDWIDTH_INSUFFICIENT,     /**< [en]0x9F Indicates fall by bandwidth insufficient
                                                                 [cn]0x9F 带宽不够导致呼叫失败*/
    TSDK_E_CALL_ERR_REASON_CODE_INSUFFICIENT_BANDWIDTH_UNITS,        /**< [en]0xA0 Indicates video negotiation fall by bandwidth insufficient
                                                                 [cn]0xA0 带宽能力不足导致视频协商失败 */
    TSDK_E_CALL_ERR_REASON_CODE_CODEC_NOT_AVAILABLE,        /**< [en]0xA1 Indicates ideo negotiation fall because code and decode mismatching
                                                                 [cn]0xA1 编解码不匹配导致视频协商失败*/
    TSDK_E_CALL_ERR_REASON_CODE_CODEC_INSUFFICIENT_SIZE_UNITS,       /**< [en]0xA2 Indicates ideo negotiation fall because resolution ratio is low
                                                                 [cn]0xA2 分辨率能力低导致视频协商失败 */
    TSDK_E_CALL_ERR_REASON_CODE_VIDEO_CODEC_NEGOTIATE_FAIL, /**< [en]0xA3 Indicates video negotiation fail
                                                                 [cn]0xA3 视频协商失败*/
    TSDK_E_CALL_ERR_REASON_CODE_ARQ_TIMEOUT,                /**< [en]0xA4 Indicates H323ARQ time out
                                                                 [cn]0xA4 H323ARQ超时*/
    TSDK_E_CALL_ERR_REASON_CODE_REGISTER_SECURITYDENIAL,    /**< [en]0xA5 Indicates H323 invalid security denial
                                                                 [cn]0xA5 H323注册码无效*/
    TSDK_E_CALL_ERR_REASON_CODE_REGISTER_RESOURCE_UNAVAILABLE,       /**< [en]0xA6 Indicates H323 duplicate security denial
                                                                 [cn]0xA6 H323注册序列号重复*/
    TSDK_E_CALL_ERR_REASON_CODE_DISCONNECT_TIMEOUT,         /**< [en]0xA7 Indicates H323 disconnect time out
                                                                 [cn]0xA7 H323断开呼叫超时 */
    TSDK_E_CALL_ERR_REASON_CODE_REG_INVALID_SVRIP,          /**< [en]0xA8 Indicates invalid server IP
                                                                 [cn]0xA8 服务器地址错误 */
    TSDK_E_CALL_ERR_REASON_CODE_TCP_ESTFAIL,                /**< [en]0xA9 Indicates STP TCP fail
                                                                 [cn]0xA9 SIP TCP建立失败 */
    TSDK_E_CALL_ERR_REASON_CODE_TLS_ESTFAIL,                /**< [en]0xAA Indicates SIP TLS fail
                                                                 [cn]0xAA SIP TLS建立失败 */
    TSDK_E_CALL_ERR_REASON_CODE_SESSION_TIMER_TIMEOUT,      /**< [en]0xAB Indicates sessiontimer timeout end
                                                                 [cn]0xAB SIP 会话心跳超时挂断 */
    TSDK_E_CALL_ERR_REASON_CODE_NOSTREAM_HANGUP,            /**< [en]0xAC Indicates no stream hangup
                                                                 [cn]0xAC 无码流被挂断 */
    TSDK_E_CALL_ERR_REASON_CODE_IP_CHANGED,                 /**< [en]0xAD Indicates local ip changed hangup
                                                                 [cn]0xAD IP地址变化导致的挂断 */
    TSDK_E_CALL_ERR_FUNC_NOT_SUPPORT,                       /**< [en]0xAE Indicates that the calling interface is not supported or not implemented.
                                                                 [cn]0xAE 调用的接口不支持或未实现 */
    TSDK_E_CALL_ERR_SPEAK_INDEX_ERROR,                      /**< [en]0xAF Indicates that input wrong speaking index
                                                                 [cn]0xAF 传入错误的扬声器设备序号*/
    TSDK_E_CALL_ERR_MIC_INDEX_ERROR,                        /**< [en]0xB0 Indicates that input wrong microphone index
                                                                 [cn]0xB0 传入错误的麦克风设备序号*/
    TSDK_E_CALL_ERR_CAMERA_INDEX_ERROR,                     /**< [en]0xB1 Indicates that input wrong camera index
                                                                 [cn]0xB1 传入错误的摄像头索引*/
    TSDK_E_CALL_ERR_START_PLAY_AUDIO_FILE_ERROR,            /**< [en]0xB2 Indicates that starting play audio file error
                                                                 [cn]0xB2 开始播放音频文件出错*/
    TSDK_E_CALL_ERR_STOP_PLAY_AUDIO_FILE_ERROR,             /**< [en]0xB3 Indicates that stopping play audio file error
                                                                 [cn]0xB3 停止播放音频文件出错*/
    TSDK_E_CALL_ERR_GET_SERVER_IP_ERROR,                    /**< [en]0xB4 Indicates that get server ip error
                                                                 [cn]0xB4 获区服务器IP地址出错*/
    TSDK_STR_TO_INT32_FAILED,                               /**< [en]0xB5 Indicates that str to int32 faile
                                                                 [cn]0xB5 字符转数字出错*/
    TSDK_E_CALL_ERR_BUTT
} TSDK_E_CALL_ERR_ID;

typedef enum tagTSDK_E_CALL_ERR_NON_STANDARD_REASON {
    TSDK_CALL_E_SIP_NOSTD_END_CALL_NORMAL = 0,

    TSDK_CALL_E_SIP_NOSTD_END_CALL_NO_STREAM = 0x00030005,     /**< [en]Indicates no modia stream has been received
                                                                    [cn]无码流挂断*/
    TSDK_CALL_E_SIP_NOSTD_END_CALL_LIVE_TIME_OUT = 0x00000071, /**< [en]Indicates call keep alive failed
                                                                    [cn]呼叫保活失败*/
    TSDK_CALL_E_SIP_NOSTD_END_CALL_BUTT
} TSDK_E_CALL_ERR_NON_STANDARD_REASON;

typedef enum tagTSDK_E_CONF_ERR_ID
{
    TSDK_E_CONF_ERR_BEGIN = 0x03FFFFFF,

    TSDK_E_CONF_ERR_UNKNOWN,                                /**< [en]0x00 Indicates unknown error
                                                                 [cn]0x00 未知错误 */

    TSDK_E_CONF_ERR_GENERAL_ERROR,                          /**< [en]0x01 Indicates general error
                                                                 [cn]0x01 一般错误 */
    TSDK_E_CONF_ERR_PARAM_ERROR,                            /**< [en]0x02 Indicates parameter error
                                                                 [cn]0x02 参数错误 */
    TSDK_E_CONF_ERR_MALLOC_FAILED,                          /**< [en]0x03 Indicates allocate memory failed
                                                                 [cn]0x03 分配内存错误 */
    TSDK_E_CONF_ERR_SYSTEM_ERROR,                           /**< [en]0x04 Indicates system error
                                                                 [cn]0x04 系统错误 */
    TSDK_E_CONF_ERR_LOAD_LIBRARY_FAILED,                    /**< [en]0x05 Indicates load library failed
                                                                 [cn]0x05 加载库错误 */
    TSDK_E_CONF_ERR_SDK_UNINITIALIZED,                      /**< [en]0x06 Indicates sdk uninitialized
                                                                 [cn]0x06 SDK未初始化 */
    TSDK_E_CONF_ERR_SDK_INIT_REPEAT,                        /**< [en]0x07 Indicates sdk Initialization repetition
                                                                 [cn]0x07 SDK初始化重复 */

    TSDK_E_CONF_ERR_CONF_BOOKING,                           /**< [en]0x08 Indicates be booking conf.
                                                                 [cn]0x08 会议预约中 */


    TSDK_E_CONF_ERR_TIMEOUT,                                /**< [en]0x09 Indicates timeout.
                                                                 [cn]0x09 超时 */
    TSDK_E_CONF_ERR_DNS_ERROR,                              /**< [en]0x0A Indicates DNS resolution exception.
                                                                 [cn]0x0A DNS解析异常 */
    TSDK_E_CONF_ERR_REQUEST_FAILED,                         /**< [en]0x0B Indicates that the request message is abnormal.
                                                                 [cn]0x0B 请求消息异常 */
    TSDK_E_CONF_ERR_AUTH_FAILED,                            /**< [en]0x0C Indicates authentication failure.
                                                                 [cn]0x0C 鉴权失败 */
    TSDK_E_CONF_ERR_SERVICE_ERROR,                          /**< [en]0x0D Indicates a server exception.
                                                                 [cn]0x0D 服务器异常 */
    TSDK_E_CONF_ERR_TIMER_ERROR,                            /**< [en]0x0E Indicates create timer error.
                                                                 [cn]0x0E 创建定时器错误 */
    TSDK_E_CONF_ERR_WRONG_SERVERADDR,                       /**< [en]0x0F Indicates wrong server addr.
                                                                 [cn]0x0F 错误的服务器地址 */
    TSDK_E_CONF_ERR_WRONG_SERVERVERSION,                    /**< [en]0x10 Indicates wrong server version.
                                                                 [cn]0x10 错误的服务器版本 */
    TSDK_E_CONF_ERR_INVALID_URL,                            /**< [en]0x11 Indicates invalid URL.
                                                                 [cn]0x11 无效的URL */
    TSDK_E_CONF_ERR_CONF_BLOCK_FULL,                        /**< [en]0x12 Indicates conference control block is full,please free someone no used
                                                                 [cn]0x12 会控控制块已满，请释放没在使用的控制块*/


    TSDK_E_CONF_ERR_INVALID_HANDLE,                         /**< [en]0x13 Indicates invalid conf handle.
                                                                 [cn]0x13 无效的会议句柄 */
    TSDK_E_CONF_ERR_INVALID_DATA_CONF_PARAM,                /**< [en]0x14 Indicates invalid data conf param, (data meeting param illegal or can't acquire data meeting param normally).
                                                                 [cn]0x14 无效的数据会议入会参数(数据会议参数非法或未能正常获取到数据会议参数) */
    TSDK_E_CONF_ERR_NON_EXISTENT_ATTENDEE,                  /**< [en]0x15 Indicates non existent attendee.
                                                                 [cn]0x15 不存在的与会者 */

    TSDK_E_CONF_ERR_DATA_CONF_UNKNOWN_ERROR,                /**< [en]0x16 Indicates unknown error.
                                                                 [cn]0x16 未知错误 */
    TSDK_E_CONF_ERR_WARNING ,                               /**< [en]0x17 Indicates a warning.
                                                                 [cn]0x17 警告 */
    TSDK_E_CONF_ERR_ERROR,                                  /**< [en]0x18 Indicates an error.
                                                                 [cn]0x18 错误 */
    TSDK_E_CONF_ERR_FAILURE,                                /**< [en]0x19 Indicates failure.
                                                                 [cn]0x19 失败 */
    TSDK_E_CONF_ERR_NULL_POINT,                             /**< [en]0x1A Indicates a null pointer.
                                                                 [cn]0x1A 空指针 */
    TSDK_E_CONF_ERR_NO_PRIVILEGE ,                          /**< [en]0x1B Indicates that there is no permission.
                                                                 [cn]0x1B 没有权限 */
    TSDK_E_CONF_ERR_FUNC_NOT_SUPPORT ,                      /**< [en]0x1C Indicates that the calling interface is not supported or not implemented.
                                                                 [cn]0x1C 调用的接口不支持或未实现 */
    TSDK_E_CONF_ERR_CALL_THREAD_ERROR ,                     /**< [en]0x1D Indicates that the calling thread is wrong.
                                                                 [cn]0x1D 调用线程错误  */
    TSDK_E_CONF_ERR_RESULT_USER_REJECTED  ,                 /**< [en]0x1E Indicates deny user request.
                                                                 [cn]0x1E 拒绝用户请求 */
    TSDK_E_CONF_ERR_RESULT_NETWORK_ERROR ,                  /**< [en]0x1F Indicates a network error.
                                                                 [cn]0x1F 网络错误 */
    TSDK_E_CONF_ERR_RESULT_VERSION_NOT_MATCH ,              /**< [en]0x20 Indicates version not match
                                                                 [cn]0x20 版本不支持 */
    TSDK_E_CONF_ERR_RESULT_PROTOCOL_NOT_RIGHT ,             /**< [en]0x21 Indicates protocol not right
                                                                 [cn]0x21 通信协议错误 */
    TSDK_E_CONF_ERR_RESULT_TOO_MANY_CONNECTIONS ,           /**< [en]0x22 Indicates the server exceeds the maximum number of connections
                                                                 [cn]0x22 服务器超出最大连接数 */
    TSDK_E_CONF_ERR_RESULT_EXPIRED,                         /**< [en]0x23 Indicates license expired
                                                                 [cn]0x23 license过期 */
    TSDK_E_CONF_ERR_RESULT_DOMAIN_TERMINATED,               /**< [en]0x24 Indicates the conference is over
                                                                 [cn]0x24 会议已结束 */
    TSDK_E_CONF_ERR_RESULT_SERVER_CONN_FAILED,              /**< [en]0x25 Indicates connection to parent server failed
                                                                 [cn]0x25 连接上级服务器失败 */
    TSDK_E_CONF_ERR_RESULT_SYS_SHUTINGDOWN,                 /**< [en]0x26 Indicates the connection is disconnected
                                                                 [cn]0x26 连接断开 */
    TSDK_E_CONF_ERR_RESULT_DOMAIN_MERGING,                  /**< [en]0x27 Indicates conference status error
                                                                 [cn]0x27 会议状态错误 */
    TSDK_E_CONF_ERR_RESULT_CHANNEL_NOT_AVAILABLE,           /**< [en]0x28 Indicates the threshold of channel is reached in the conference
                                                                 [cn]0x28 会议中channel达到阈值 */

    TSDK_E_CONF_ERR_RESULT_POOL_NOT_AVAILABLE,              /**< [en]0x29 Indicates audio open the number of MICs has exceeded the set maximum number of open MICs
                                                                 [cn]0x29 Audio打开MIC数量已超过设置的最大打开MIC数 */
    TSDK_E_CONF_ERR_RESULT_UNKNOWN,                         /**< [en]0x2A Indicates server return unknown error
                                                                 [cn]0x2A 服务器返回未知错误 */
    TSDK_E_CONF_ERR_RESULT_AUTH_REDIRECT,                   /**< [en]0x2B Indicates authentication redirect
                                                                 [cn]0x2B 鉴权重定向 */
    TSDK_E_CONF_ERR_RESULT_QUERY_PARENT_OR_TOP_AGENT_EXPIRED,/**< [en]0x2C Cluster service exception
                                                                  [cn]0x2C 集群服务异常 */
    TSDK_E_CONF_ERR_RESULT_DOMAIN_LOCKED,                   /**< [en]0x2D Indicates conference is locked
                                                                 [cn]0x2D 会议锁定 */
    TSDK_E_CONF_ERR_RESULT_AUTH_KEY_NOT_AVAILABLE,          /**< [en]0x2E Indicates conference key not available
                                                                 [cn]0x2E 会议密码错误 */
    TSDK_E_CONF_ERR_RESULT_TOO_MANY_CONFERENCE,             /**< [en]0x2F Indicates the number of conferences exceed the limit
                                                                 [cn]0x2F 会议数超过限制 */
    TSDK_E_CONF_ERR_RESULT_TOO_MANY_CONFERENCE_USER,        /**< [en]0x30 Indicates conference members exceed the limit
                                                                 [cn]0x30 会议成员超过限制 */
    TSDK_E_CONF_ERR_RESULT_NOT_DATA_USER_LICENSE,           /**< [en]0x31 Indicates that there is not enough data license, not allowed to join
                                                                 [cn]0x31 没有足够的数据License，不允许入会 */
    TSDK_E_CONF_ERR_RESULT_AUTH_LINCENSE_TIMEOUT,           /**< [en]0x32 Indicates authentication license timeout, not allowed to join
                                                                 [cn]0x32 鉴权License超时，不允许入会 */
    TSDK_E_CONF_ERR_RESULT_SVR_NOT_ALLOW,                   /**< [en]0x33 Indicates server zone is not allowed, membership is not allowed
                                                                 [cn]0x33 服务器区域不允许，不允许入会 */
    TSDK_E_CONF_ERR_RESULT_USER_NOT_ALLOW,                  /**< [en]0x34 Indicates users are not allowed to join when repeat join conf
                                                                 [cn]0x34 用户重复入会，不允许入会 */

    TSDK_E_CONF_ERR_REASON_USER_INITIATED,                  /**< [en]0x35 Indicates the conference will depart normally
                                                                 [cn]0x35 会议正常离会 */
    TSDK_E_CONF_ERR_REASON_USER_EJECTED,                    /**< [en]0x36 Indicates that the user is kicked.
                                                                 [cn]0x36 用户被踢 */
    TSDK_E_CONF_ERR_REASON_TOKEN_PURGED,                    /**< [en]0x37 Indicates that the token value is cleared.
                                                                 [cn]0x37 清除token值 */
    TSDK_E_CONF_ERR_REASON_NETWORK_ERROR,                   /**< [en]0x38 Indicates a network error.
                                                                 [cn]0x38 网络错误 */
    TSDK_E_CONF_ERR_REASON_EXTEND_MAX_LICENSE,              /**< [en]0x39 Indicates the maximum rangge of license.
                                                                 [cn]0x39 最大License范围 */
    TSDK_E_CONF_ERR_REASON_SYSTEM_ERROR,                    /**< [en]0x3A Indicates system error.
                                                                 [cn]0x3A 系统错误 */
    TSDK_E_CONF_ERR_REASON_USER_OFFLINE,                    /**< [en]0x3B Indicates user offline.
                                                                 [cn]0x3B 用户离线 */
    TSDK_E_CONF_ERR_REPEAT_JOIN,                            /**< [en]0x3C Indicates repeat join a conference
                                                                 [cn]0x3C 重复入会 */
    TSDK_E_CONF_ERR_NO_JOIN,                                /**< [en]0x3D Indicates not join a conference
                                                                 [cn]0x3D 未入会 */
    TSDK_E_CONF_ERR_NO_LOAD_COM,                            /**< [en]0x3E Indicates unload component
                                                                 [cn]0x3E 组件未加载 */
    TSDK_E_CONF_ERR_DATA_TOO_LAGE,                          /**< [en]0x3F Indicates data too lage
                                                                 [cn]0x3F 数据太大 */
    TSDK_E_CONF_ERR_SEND_TOO_FAST,                          /**< [en]0x40 Indicates send too fast
                                                                 [cn]0x40 发送太快 */
    TSDK_E_CONF_ERR_ALREADY_TERMINATE,                      /**< [en]0x41 Indicates conference is already over
                                                                 [cn]0x41 会议已结束 */
    TSDK_E_CONF_ERR_ALREADY_LEAVE,                          /**< [en]0x42 Indicates conference leave
                                                                 [cn]0x42 会议已离开 */
    TSDK_E_CONF_ERR_COM_LOADED,                             /**< [en]0x43 Indicates component is already loaded
                                                                 [cn]0x43 组件已加载 */
    TSDK_E_CONF_ERR_CON_UNLOADED,                           /**< [en]0x44 Indicates component is already unloaded
                                                                 [cn]0x44 组件已卸载 */
    TSDK_E_CONF_ERR_DISCONNECT_EXC,                         /**< [en]0x45 Indicates conference disconnect
                                                                 [cn]0x45 会议已断开 */
    TSDK_E_CONF_ERR_CONF_INFO,                              /**< [en]0x46 Indicates parameter error
                                                                 [cn]0x46 参数错误 */
    TSDK_E_CONF_ERR_CONF_NOT_INIT,                          /**< [en]0x47 Indicates the meeting environment has not yet been initialized
                                                                 [cn]0x47 会议环境尚未初始化完成 */
    TSDK_E_CONF_ERR_SELF_PRESENTER,                         /**< [en]0x48 Indicates presenter
                                                                 [cn]0x48 自己已经是主讲人 */
    TSDK_E_CONF_ERR_PHONE_INIT,                             /**< [en]0x49 Indicates phone is not initialized
                                                                 [cn]0x49 电话未初始化 */
    TSDK_E_CONF_ERR_PHONE_JOIN,                             /**< [en]0x4A Indicates fail to join a phone conference
                                                                 [cn]0x4A 加入电话会议失败 */
    TSDK_E_CONF_ERR_ALREADY_NEW,                            /**< [en]0x4B Indicates the same conference is already exist
                                                                 [cn]0x4B 相同的会议已经存在 */
    TSDK_E_CONF_ERR_PAAS_ID_INVALID,                        /**< [en]0x4C Indicates invalid conference id under pass mode
                                                                 [cn]0x4C Paas模式下，错误的会议ID，会议前12位不能有值 */
    TSDK_E_CONF_ERR_CERT_NOT_IN_USE,                        /**< [en]0x4D Indicates certificate has not been used
                                                                 [cn]0x4D 证书生效时间大于当前时间，代表证书还未生效*/
    TSDK_E_CONF_ERR_CERT_OVERDUE,                           /**< [en]0x4E Indicates certificate is overdue
                                                                 [cn]0x4E 证书过期时间小于当前时间，代表证书已过期*/
    TSDK_E_CONF_ERR_CHAT_INVALIDSESSION,                    /**< [en]0x4F Indicates channel not added
                                                                 [cn]0x4F 通道未加入 */
    TSDK_E_CONF_ERR_INVALIDUSERID,                          /**< [en]0x50 Indicates error user id
                                                                 [cn]0x50 错误的用户ID */
    TSDK_E_CONF_ERR_INVALIDGROUPID,                         /**< [en]0x51 Indicates error group id
                                                                 [cn]0x51 错误的分组ID */
    TSDK_E_CONF_ERR_TOO_MANY_CHAR,                          /**< [en]0x52 Indicates the string exceeds the length limit
                                                                 [cn]0x52 字符串超过长度限制 */
    TSDK_E_CONF_ERR_TOO_MIN_INTERVAL,                       /**< [en]0x53 Indicates the sending interval is too short
                                                                 [cn]0x53 发送间隔太短 */
    TSDK_E_CONF_ERR_DOC_NOTEXIST,                           /**< [en]0x54 Indicates document does not exist
                                                                 [cn]0x54 文档不存在 */
    TSDK_E_CONF_ERR_PAGE_NOTEXIST,                          /**< [en]0x55 Indicates page does not exist
                                                                 [cn]0x55 页面不存在 */
    TSDK_E_CONF_ERR_PARAM_NOTEXIST,                         /**< [en]0x56 Indicates parameter does not exist
                                                                 [cn]0x56 参数不存在 */
    TSDK_E_CONF_ERR_DE_NOTEXIST,                            /**< [en]0x57 Indicates the element does not exist
                                                                 [cn]0x57 元素不存在 */
    TSDK_E_CONF_ERR_DOC_ALREADYEXIST,                       /**< [en]0x58 Indicates the document already exists, and this error occurs when the file is created repeatedly
                                                                 [cn]0x58 文档已经存在,重复创建时会有此错误 */
    TSDK_E_CONF_ERR_PAGE_ALREADYEXIST,                      /**< [en]0x59 Indicates page already exists
                                                                 [cn]0x59 页面已存在 */
    TSDK_E_CONF_ERR_NOT_VALID_CWP,                          /**< [en]0x5A Indicates the given file is not a valid CPP file
                                                                 [cn]0x5A 给定的文件不是一个有效的CWP文件 */
    TSDK_E_CONF_ERR_PROP_NOT_EXIT,                          /**< [en]0x5B Indicates the document property does not exist
                                                                 [cn]0x5B 文档属性不存在 */
    TSDK_E_CONF_ERR_DOC_ALREADY_OPEN,                       /**< [en]0x5C Indicates document already opens
                                                                 [cn]0x5C 文档已经打开 */
    TSDK_E_CONF_ERR_DOC_NO_INIT,                            /**< [en]0x5D Indicates module is not initialized
                                                                 [cn]0x5D 模块未初始化 */
    TSDK_E_CONF_ERR_DOC_NO_SINK,                            /**< [en]0x5E Indicates callback interface is not set
                                                                 [cn]0x5E 回调接口未设置 */
    TSDK_E_CONF_ERR_DOC_NO_SESSION_JOIN,                    /**< [en]0x5F Indicates channel not added
                                                                 [cn]0x5F 通道未加入 */
    TSDK_E_CONF_ERR_DOC_USER_OFFLINE,                       /**< [en]0x60 Indicates user offline
                                                                 [cn]0x60 用户已离线 */
    TSDK_E_CONF_ERR_DOC_PRINTING,                           /**< [en]0x61 Indicates document is being printed
                                                                 [cn]0x61 文档正在打印中 */
    TSDK_E_CONF_ERR_DOC_PAGE_DOWN,                          /**< [en]0x62 Indicates document page data is being downloaded
                                                                 [cn]0x62 文档页面数据正在下载中 */
    TSDK_E_CONF_ERR_DOC_FORMAT_ERROR,                       /**< [en]0x63 Indicates a saved whiteboard file is opened when the document is shared, or a saved document is loaded when the whiteboard is shared
                                                                 [cn]0x63 在文档共享时打开了保存的白板文件，或在白板共享时加载了保存的文档共享文档 */
    TSDK_E_CONF_ERR_DOC_PAGE_NOT_UPLOAD,                    /**< [en]0x64 Indicates the page data is not uploaded to the server, and the sharer is no longer in conference
                                                                 [cn]0x64 页面数据没有上传到服务器，并且此时共享者已不在会议中 */

    TSDK_E_CONF_ERR_COM,                                    /**< [en]0x65 Indicates COM call failed
                                                                 [cn]0x65 COM调用失败 */
    TSDK_E_CONF_ERR_NO_PAGE,                                /**< [en]0x66 Indicates the document 0 page
                                                                 [cn]0x66 该文档0页 */
    TSDK_E_CONF_ERR_CANCELED,                               /**< [en]0x67 Indicates cancel printing
                                                                 [cn]0x67 取消打印 */
    TSDK_E_CONF_ERR_NOT_SUPPORT,                            /**< [en]0x68 Indicates the document format is not supported
                                                                 [cn]0x68 文档格式不支持 */
    TSDK_E_CONF_ERR_OFFICE_NOT_SUPPORT,                     /**< [en]0x69 Indicates office versions are not supported
                                                                 [cn]0x69 Office版本不支持 */
    TSDK_E_CONF_ERR_TRANSFORM,                              /**< [en]0x6A Indicates transform failed
                                                                 [cn]0x6A 转换失败 */
    TSDK_E_CONF_ERR_FILE_EMPTY,                             /**< [en]0x6B Indicates the file is empty
                                                                 [cn]0x6B 文件为空 */
    TSDK_E_CONF_ERR_FORMAT_ERROR,                           /**< [en]0x6C Indicates the document format error
                                                                 [cn]0x6C 文件格式错误 */
    TSDK_E_CONF_ERR_PRINT_TIMEOUT,                          /**< [en]0x6D Indicates print timeout
                                                                 [cn]0x6D 打印超时 */
    TSDK_E_CONF_ERR_PRINTER_UNINSTALL,                      /**< [en]0x6E Indicates the printer uninstalled
                                                                 [cn]0x6E 打印机未安装 */
    TSDK_E_CONF_ERR_PPT_THREAD_ERROR,                       /**< [en]0x6F Indicates PPT loading thread error
                                                                 [cn]0x6F PPT加载线程错误 */
    TSDK_E_CONF_ERR_PPT_LOAD_ERROR,                         /**< [en]0x70 Indicates PPT loading error
                                                                 [cn]0x70 PPT加载错误 */
    TSDK_E_CONF_ERR_PAGE_OVER_MAX,                          /**< [en]0x71 Indicates exceed the maximum number of page
                                                                 [cn]0x71 超出最大页数(200页) */
    TSDK_E_CONF_ERR_PRINTER_ERROR,                          /**< [en]0x72 Indicates printer error
                                                                 [cn]0x72 打印机错误 */
    TSDK_E_CONF_ERR_PRINT_SERVICE_ERROR,                    /**< [en]0x73 Indicates the print service has encountered an error
                                                                 [cn]0x73 打印服务出现错误 */
    TSDK_E_CONF_ERR_PPT2003_RUNNING,                        /**< [en]0x74 Indicates powerpoint2003 is running, can not be loaded
                                                                 [cn]0x74 PowerPoint2003运行中，不能加载 */
    TSDK_E_CONF_ERR_NO_PERMISSION,                          /**< [en]0x75 Indicates no permission to open
                                                                 [cn]0x75 没有权限打开 */
    TSDK_E_CONF_ERR_WPS_NOT_INSTALLED,                      /**< [en]0x76 Indicates WPS does not install
                                                                 [cn]0x76 WPS没有安装 */
    TSDK_E_CONF_ERR_LASER_EXIST,                            /**< [en]0x77 Indicates the laser spot already exists
                                                                 [cn]0x77 激光点已经存在 */
    TSDK_E_CONF_ERR_CUSTOMERTYPE_NOTEXIST,                  /**< [en]0x78 Indicates the custom label type does not exist
                                                                 [cn]0x78 自定义标注类型不存在 */
    TSDK_E_CONF_ERR_EXCEL_MACRO_UNSUPPORTED,                /**< [en]0x79 Indicates excel with macro is unsupported
                                                                 [cn]0x79 excel宏不支持 */
    TSDK_E_CONF_ERR_INVALIDUSER,                            /**< [en]0x7A Indicates invalid user
                                                                 [cn]0x7A 角色异常 */
    TSDK_E_CONF_ERR_AS_INVALIDSESSION,                      /**< [en]0x7B Indicates invalid channel
                                                                 [cn]0x7B 通道异常 */
    TSDK_E_CONF_ERR_NULLCOMHANDLE,                          /**< [en]0x7C Indicates module handle exception
                                                                 [cn]0x7C 模块句柄异常 */
    TSDK_E_CONF_ERR_INVALIDSTATE,                           /**< [en]0x7D Indicates invalid shared state
                                                                 [cn]0x7D 共享状态异常 */
    TSDK_E_CONF_ERR_INVALIDWND,                             /**< [en]0x7E Indicates window handle setting exception
                                                                 [cn]0x7E 窗口句柄设置异常 */
    TSDK_E_CONF_ERR_CREATETASKFAIL,                         /**< [en]0x7F Indicates create a shared process exception
                                                                 [cn]0x7F 创建共享进程异常 */
    TSDK_E_CONF_ERR_USERDROPPED,                            /**< [en]0x80 Indicates user is dropped
                                                                 [cn]0x80 用户已掉线 */
    TSDK_E_CONF_ERR_XMLERROR,                               /**< [en]0x81 Indicates XML read/write exception
                                                                 [cn]0x81 XML读写异常 */
    TSDK_E_CONF_ERR_MODULELOCKED,                           /**< [en]0x82 Indicates module is locked
                                                                 [cn]0x82 模块被锁定 */
    TSDK_E_CONF_ERR_WAITFIRSTFRAME,                         /**< [en]0x83 Indicates waiting for the first frame to be sent
                                                                 [cn]0x83 等待首帧发送 */
    TSDK_E_CONF_ERR_UNSUPPORT,                              /**< [en]0x84 Indicates the current version is not supported
                                                                 [cn]0x84 当前版本不支持 */
    TSDK_E_CONF_ERR_FORBID_SCALE,                           /**< [en]0x85 Indicates zooming is not supported
                                                                 [cn]0x85 不支持放大 */
    TSDK_E_CONF_ERR_NULLCTRLHANDLE,                         /**< [en]0x86 Indicates blank screen shared handle
                                                                 [cn]0x86 空屏幕共享句柄 */
    TSDK_E_CONF_ERR_INVALIDCHANNEL,                         /**< [en]0x87 Indicates illegal data channel
                                                                 [cn]0x87 非法数据通道 */
    TSDK_E_CONF_ERR_GDI_ALLOC_FAILED,                       /**< [en]0x88 Indicates fail to request GDI object
                                                                 [cn]0x88 GDI对象申请失败 */
    TSDK_E_CONF_ERR_P2P_CONNECTION_FAILED,                  /**< [en]0x89 Indicates P2P connection error
                                                                 [cn]0x89 P2P连接出错 */
    TSDK_E_CONF_ERR_FIRST_USER_JOIN,                        /**< [en]0x8A Indicates the first user join
                                                                 [cn]0x8A 第一个用户加入 */
    TSDK_E_CONF_ERR_ANNOT_DOC_NOTEXIST,                     /**< [en]0x8B Indicates document does not exist
                                                                 [cn]0x8B 文档不存在 */
    TSDK_E_CONF_ERR_ANNOT_PAGE_NOTEXIST,                    /**< [en]0x8C Indicates page does not exist
                                                                 [cn]0x8C 页面不存在 */
    TSDK_E_CONF_ERR_ANNOT_PARAM_NOTEXIST,                   /**< [en]0x8D Indicates parameter does not exist
                                                                 [cn]0x8D 属性不存在 */
    TSDK_E_CONF_ERR_ANNOT_DE_NOTEXIST,                      /**< [en]0x8E Indicates the page element does not exist
                                                                 [cn]0x8E 页面元素不存在 */
    TSDK_E_CONF_ERR_ANNOT_DOC_ALREADYEXIST,                 /**< [en]0x8F Indicates the document is already exist
                                                                 [cn]0x8F 文档已经存在 */
    TSDK_E_CONF_ERR_ANNOT_PAGE_ALREADYEXIST,                /**< [en]0x90 Indicates the page is already exist
                                                                 [cn]0x90 页面已存在 */
    TSDK_E_CONF_ERR_ANNOT_NOT_VALID_CWP,                    /**< [en]0x91 Indicates the given file is not a valid CWP file
                                                                 [cn]0x91 给定的文件不是一个有效的CWP文件 */
    TSDK_E_CONF_ERR_ANNOT_CUSTOMERTYPE_NOTEXIST,            /**< [en]0x92 Indicates user-defined type does not exist
                                                                 [cn]0x92 用户自定义类型不存在 */
    TSDK_E_CONF_ERR_SC_UNKNOW,                              /**< [en]0x93 Indicates collect unknow error
                                                                 [cn]0x93 采集未知错误 */
    TSDK_E_CONF_ERR_SC_GDI_OBJECT,                          /**< [en]0x94 Indicates fail to create GDI object
                                                                 [cn]0x94 创建GDI对象失败 */
    TSDK_E_CONF_ERR_SERVER_ADDRESS_ERROR,                   /**< [en]0x95 Indicates server address error
                                                                 [cn]0x95 服务器地址错误*/

    TSDK_E_CONF_ERR_NOT_CHAIRMAN,                           /**< [en]0x96 Indicates only the conference chair has the operation rights
                                                                 [cn]0x96 不是主席，没有操作权限 */
    TSDK_E_CONF_ERR_NOT_SUPPORT_LIVE_BROADCAST,             /**< [en]0x97 Indicates the conference does not support live broadcast
                                                                 [cn]0x97 会议不支持直播 */
    TSDK_E_CONF_ERR_NOT_SUPPORT_RECORD_BROADCAST,           /**< [en]0x98 Indicates the conference does not support recording
                                                                 [cn]0x98 会议不支持录播 */
    TSDK_E_CONF_ERR_NEED_ENTER_PASSWORD_TO_BE_CHAIRMAN,     /**< [en]0x99 Indicates nedd enter password to be chairman
                                                                 [cn]0x99 请输入密码来申请主席 */
    TSDK_E_CONF_ERR_HANDUP_STATUS,                          /**< [en]0x9A Hands up is the same
                                                                 [cn]0x9A 举手状态一致 */

    TSDK_E_CONF_ERR_NO_EXIST_USER,                          /**< [en]0x9B Indicates terminal user is not exist(remove, broadcast)
                                                                 [cn]0x9B 操作的终端不存在(remove, broadcast) */
    TSDK_E_CONF_ERR_NO_CHAIR_FUNC,                          /**< [en]0x9C Indicates no chairman function in conference
                                                                 [cn]0x9C 会议没有主席功能 */
    TSDK_E_CONF_ERR_NO_CAP_TO_BE_CHAIR,                     /**< [en]0x9D Indicates no chairman function in operated conference
                                                                 [cn]0x9D 所操纵的终端没有主席功能 */
    TSDK_E_CONF_ERR_CHAIR_EXIST,                            /**< [en]0x9E Indicates chairman is exist in conference
                                                                 [cn]0x9E 会议中已有主席 */
    TSDK_E_CONF_ERR_CHAIR_PWD_ERR,                          /**< [en]0x9F Indicates chairman's password is error
                                                                 [cn]0x9F 主席密码错误 */
    TSDK_E_CONF_ERR_SERVER_IS_PROCEEDING,                   /**< [en]0xA0 Indicates server is proceeding,please wait
                                                                 [cn]0xA0 正在处理中，请等待 */
    TSDK_E_CONF_ERR_SVC_LARGE_SPECIFIED,                    /**< [en]0xA1 Indicates the large picture can not be specified in svc conference
                                                                 [cn]0xA1 多流中大画面会场不能指定 */
    TSDK_E_CONF_ERR_SVC_UNSUPPORT_WATCH_FORLARGECONF,       /**< [en]0xA2 Indicates the large svc conference is not support watch
                                                                 [cn]0xA2 多流中大会不能发起选看 */
    TSDK_E_CONF_ERR_WATCHED_SITE_UNCONF,                    /**< [en]0xA3 Indicates the watched site is not in conference
                                                                 [cn]0xA3 选看的会场当前不在会议中 */
    TSDK_E_CONF_ERR_UNSUPPORT_IN_FOUR_PIC_BROADCAST,        /**< [en]0xA4 Indicates that server unsupport this operation in four multipictrue boardcase or roll call state
                                                                 [cn]0xA4 服务器不支持在四画面广播或者点名发言中进行此操作 */
    TSDK_E_CONF_ERR_UNSUPPORT_IN_ONE_PIC_BROADCAST,         /**< [en]0xA5 Indicates that server unsupport this operation in one multipictrue boardcase or roll call state
                                                                 [cn]0xA5 服务器不支持在单画面广播或者点名发言中进行操作其他MCU的会场 */
    TSDK_E_CONF_ERR_WATCHED_SITE_ABNORMAL,                  /**< [en]0xA6 Indicates the watched site is abnormal
                                                                 [cn]0xA6 被观看的会场当前处于异常状态 */
    TSDK_E_CONF_ERR_UNSUPPORT_IN_AUDIO_CONF,                /**< [en]0xA7 Indicates the conference is a audio conference
                                                                 [cn]0xA7 会议为音频会议 */
    TSDK_E_CONF_ERR_UNSUPPORT_BY_NONVIDEO_SITE,             /**< [en]0xA8 Indicates the nonvideo site unsupport this operation
                                                                 [cn]0xA8 非视频会场不支持此操作 */
    TSDK_E_CONF_ERR_WATCHED_SITE_IS_NO_VIDEO_SITE,          /**< [en]0xA9 Indicates that the watched site is no a video site
                                                                 [cn]0xA9 被观看的会场不是视频会场 */
    TSDK_E_CONF_ERR_CONFERENCE_IS_BROADCAST,                /**< [en]0xAA Indicates the conference is boardcase,no support watch site
                                                                 [cn]0xAA 广播状态不支持观看会场 */
    TSDK_E_CONF_ERR_INSUFFICIENT_VIDEO_RESOURCE,            /**< [en]0xAB Indicates the video resource is insufficient
                                                                 [cn]0xAB 视频资源不足 */
    TSDK_E_CONF_ERR_UNSUPPORT_NONCHAIRMAN_IN_CASCONF,       /**< [en]0xAC Indicates the nonchairman has no permission to watch casecade site
                                                                 [cn]0xAC 非主席不支持观看级联会场 */
    TSDK_E_CONF_ERR_UNSUPPORT_IN_NO_MULTIPIC_CONFERENCE,    /**< [en]0xAD Indicates that in no multipictrue conference,server do not support watch multipictrue
                                                                 [cn]0xAD 非多画面会议，不支持观看多画面 */
    TSDK_E_CONF_ERR_ATTENDEE_NOT_IN_ROLL_CALL,              /**< [en]0xAE Indicates attendee is not in roll call.
                                                                 [cn]0xAE 与会者不在点名状态 */
    TSDK_E_CONF_ERR_NO_CHAIRMAN,                            /**< [en]0xAF Indicates chairman is not exist in conference
                                                                 [cn]0xAF 会议中无主席 */
    TSDK_E_CONF_ERR_INVALID_USER,                           /**< [en]0xB0 Indicates user info invalid
                                                                 [cn]0xB0 用户信息不合法 */
    TSDK_E_CONF_ERR_CONFERENCE_COLLIDE,                     /**< [en]0xB1 Indicates conference collide
                                                                 [cn]0xB1 会议冲突 */
    TSDK_E_CONF_ERR_CARD_ALREADY_ON_LINE,                   /**< [en]0xB2 Indicates card user already on line
                                                                 [cn]0xB2 卡号用户已在线 */
    TSDK_E_CONF_ERR_USER_FORBIDDENED,                       /**< [en]0xB3 Indicates calling user is forbidden
                                                                 [cn]0xB3 主叫用户已被暂停 */
    TSDK_E_CONF_ERR_PWD_CHG_INVALID,                        /**< [en]0xB4 Indicates password can't be changed
                                                                 [cn]0xB4 密码不能修改 */
    TSDK_E_CONF_ERR_OUT_OF_MONEY,                           /**< [en]0xB5 Indicates out of money
                                                                 [cn]0xB5 余额不足 */
    TSDK_E_CONF_ERR_EXIST_SITECALL,                         /**< [en]0xB6 Indicates it's exist in site call
                                                                 [cn]0xB6 已经在主叫呼集过程中 */
    TSDK_E_CONF_ERR_FAIL_PEER_NOCAPS,                       /**< [en]0xB7 Indicates no calling ability or ability change fail
                                                                 [cn]0xB7 没有呼集能力或能力交换失败(E1专用) */
    TSDK_E_CONF_ERR_FAIL_SENDDATA_TOMCU,                    /**< [en]0xB8 Indicates send calling set to MCU failed
                                                                 [cn]0xB8 向MCU发送主叫呼集数据失败(E1专用) */
    TSDK_E_CONF_ERR_FAIL_CANNOT_SETUPCHANNE,                /**< [en]0xB9 Indicates calling set data channel set up failed
                                                                 [cn]0xB9 呼集数据传输通道建立失败(E1专用) */
    TSDK_E_CONF_ERR_FAIL_E1_LINEBUSY,                       /**< [en]0xBA Indicates E1 line is busy, please try again later
                                                                 [cn]0xBA E1线路忙,请稍后再试 */
    TSDK_E_CONF_ERR_FAIL_PEER_REJECT,                       /**< [en]0xBB Indicates calling set is reject by MCU
                                                                 [cn]0xBB MCU拒绝主叫呼集(E1专用) */
    TSDK_E_CONF_ERR_TIME_OUT,                               /**< [en]0xBC Indicates calling set is time out
                                                                 [cn]0xBC 主叫呼集超时 */
    TSDK_E_CONF_ERR_GK_AUTHOR_FAILED,                       /**< [en]0xBD Indicates GK author failed
                                                                 [cn]0xBD gk密码认证失败 */
    TSDK_E_CONF_ERR_END_IN_THE_PAST,                        /**< [en]0xBE Indicates conference end in the past
                                                                 [cn]0xBE 会议结束在过去*/
    TSDK_E_ERR_NO_ACCESS_RIGHT,                             /**< [en]0xBF Indicates no access right
                                                                 [cn]0xBF 没有权限*/
    TSDK_E_ERR_CONFERENCE_IS_ACTIVE,                        /**< [en]0xC0 Indicates conference is active
                                                                 [cn]0xC0 会议在激活态 */
    TSDK_E_ERR_CONFERENCE_NOT_EXIST,                        /**< [en]0xC1 Indicates param error
                                                                 [cn]0xC1 会议不存在 */
    TSDK_E_ERR_CONFERENCE_UPPER_LIMIT,                      /**< [en]0xC2 The number of scheduled meetings has reached the upper li
                                                                 [cn]0xC2 会议预约数达到上限 */
    TSDK_E_ERR_CONFERENCE_NO_ACCESS,                        /**< [en]0xC3 The user does not have the access permission
                                                                 [cn]0xC3 该用户没有访问权限 */
    TSDK_E_ERR_CONFERENCE_HIGHER_CAPABILITY,                /**< [en]0xC4 The participant capability is higher than the meeting cap
                                                                 [cn]0xC4 会场能力高于会议能力 */
    TSDK_E_ERR_CONFERENCE_NUMBER_REPEAT,                    /**< [en]0xC5 Duplicate participant number
                                                                 [cn]0xC5 会场号码重复 */
    TSDK_E_ERR_CONFERENCE_MAX_NUM,                          /**< [en]0xC6 A meeting can contain a maximum of 3000 participants
                                                                 [cn]0xC6 会议中最多包含3000个会场 */
    TSDK_E_ERR_CONFERENCE_SMC,                              /**< [en]0xC7 The SMC prohibits endpoints from creating meetings
                                                                 [cn]0xC7 SMC禁止终端创建会议 */
    TSDK_E_ERR_CONFERENCE_LICENSE,                          /**< [en]0xC8 The encryption function is disabled in the license. Forci
                                                                 [cn]0xC8 license已禁用加密功能，不支持召开强制加密会议 */
    TSDK_E_ERR_CONFERENCE_NOT_LOADED,                       /**< [en]0xC9 The conference service has not been loaded. Please try ag
                                                                 [cn]0xC9 会议服务未完全加载好，请稍后再试 */
    TSDK_E_ERR_CONFERENCE_SERVICE_ERR,                      /**< [en]0xCA Failed to modify the password configuration because a con
                                                                 [cn]0xCA 系统有未结束会议，无法修改国密配置 */
    TSDK_E_ERR_CONFERENCE_FAIL,                             /**< [en]0xCB Failed to create the conference. The encryption mode must
                                                                 [cn]0xCB 创建会议失败，加密方式必须设置为强制加密 */
    TSDK_E_ERR_CONFERENCE_MCU_SET,                          /**< [en]0xCC The number of MCU cascades exceeds the maximum limit
                                                                 [cn]0xCC MCU级联数量超过最大限制 */
    TSDK_E_ERR_CONFERENCE_ERR_SET,                          /**< [en]0xCD Voice participants and cascaded participants cannot be se
                                                                 [cn]0xCD 语音会场和级联会场不能设置为主会场 */
    TSDK_E_ERR_CONFERENCE_MCU_INSUFFICIENT,                 /**< [en]0xCE Insufficient MCU resources
                                                                 [cn]0xCE MCU资源不足 0x20040001-0x20040004 */
    TSDK_E_ERR_CONFERENCE_MCU_VIDEO_INSUFFICIENT,           /**< [en]0xCF Insufficient MCU resources
                                                                 [cn]0xCF MCU资源不足 0x20040001-0x20040004 */
    TSDK_E_ERR_CONFERENCE_PORT_INSUFFICIENT,                /**< [en]0xD0 Insufficient SVC port resources
                                                                 [cn]0xD0 SVC端口资源不足 */
    TSDK_E_ERR_CONFERENCE_ENCRYPTION_ERR,                   /**< [en]0xD1 Encryption and decryption resources are insufficient
                                                                 [cn]0xD1 加解密资源不足 */
    TSDK_E_ERR_CONFERENCE_BANDWIDTH_INSUFFICIENT,           /**< [en]0xD2 The network bandwidth is insufficient
                                                                 [cn]0xD2 带宽资源不足 */
    TSDK_E_ERR_CONFERENCE_RESOURCES,                        /**< [en]0xD3 The site resources are insufficient
                                                                 [cn]0xD3 会场资源不足 */
    TSDK_E_ERR_CONFERENCE_AUDIO_RESOURCES,                  /**< [en]0xD4 Audio resources are insufficient
                                                                 [cn]0xD4 音频资源不足 */
    TSDK_E_ERR_CONFERENCE_MCU_VIDEO,                        /**< [en]0xD5 The MCU does not support the corresponding video protocol
                                                                 [cn]0xD5 MCU不支持对应的视频协议 */
    TSDK_E_ERR_CONFERENCE_MCU_RESOLUTION,                   /**< [en]0xD6 The MCU does not support the video resolution
                                                                 [cn]0xD6 MCU不支持对应的视频分辨率 */
    TSDK_E_ERR_CONFERENCE_MCU_AUDIO,                        /**< [en]0xD7 The MCU does not support the corresponding audio protocol
                                                                 [cn]0xD7 MCU不支持对应的音频协议 */
    TSDK_E_ERR_CONFERENCE_MCU_DATA,                         /**< [en]0xD8 The MCU does not support the corresponding data meeting p
                                                                 [cn]0xD8 MCU不支持对应的数据会议协议 */
    TSDK_E_ERR_CONFERENCE_MCU_ENCRYPTION,                   /**< [en]0xD9 The MCU does not support the encryption or decryption typ
                                                                 [cn]0xD9 MCU不支持对应的加解密类型 */
    TSDK_E_ERR_CONFERENCE_BEING_RECORD_BROADCAST,           /**< [en]0xDA The conference is being recorded broadcast
                                                                 [cn]0xDA 会议正在录播中 */
    TSDK_E_ERR_CONFERENCE_NOT_RECORD_BROADCAST,             /**< [en]0xDB The conference was not recorded broadcast
                                                                 [cn]0xDB 会议未开始录播 */
    TSDK_E_ERR_CONFERENCE_USER_NOT_LOGGED_IN,               /**< [en]0xDC The user logged in
                                                                 [cn]0xDC 用户未登录 */
    TSDK_E_ERR_CONFERENCE_IP_ADDR_ERROR_TYPE = 0x40000E1,   /**< [en]0xE1 The ip addr erro type
                                                                 [cn]0xE1 服务器ip类型错误 */
    TSDK_E_ERR_CONFERENCE_ATTENDEE_LIST_NULL,               /**< [en]0xE2 The attendee list is null
                                                                 [cn]0xE2 会场列表为空 */
    TSDK_E_ERR_CONFERENCE_LOCK_CONF_STATUS,                 /**< [en]0xE3 Hands up is the same
                                                                 [cn]0xE3 锁定会议状态一致 */
    TSDK_E_ERR_CONFERENCE_PERSONAL_VMR_INFO,                /**< [en]0xE4 Users no VMR info in SMC3.0
                                                                 [cn]0xE4 当前用户未分配个人VMR号码 */
    TSDK_E_ERR_CONFERENCE_NOT_THE_CURRENT_USER_VMR_NUMBER,  /**< [en]0xE5 Organization no VMR info in SMC3.0
                                                                 [cn]0xE5 不是当前账号的VMR号码 */
    TSDK_E_ERR_CONFERENCE_NOT_ENABLE_VMR,                   /**< [en]0xE6 SMC3.0 not enable VMR
                                                                 [cn]0xE6 SMC3.0未开启VMR，不支持访问 */
    TSDK_E_ERR_CONFERENCE_VMR_QUERY_FAIL,                   /**< [en]0xE7 VMR cannot be found
                                                                 [cn]0xE7 VMR查询不到 */
    TSDK_E_ERR_CONFERENCE_VMR_TIME_CONFLICT,                /**< [en]0xE8 Appointment of meeting time conflict through VMR
                                                                 [cn]0xE8 通过VMR预约会议时间冲突 */
    TSDK_E_ERR_CONFERENCE_VMR_NUMBER_ERR,                   /**< [en]0xE9 VMR number error
                                                                 [cn]0xE9 VMR号码错误 */
    TSDK_E_ERR_CONFERENCE_GUEST_RIGHT,                      /**< [en]0xEA Guest activation not allowed
                                                                 [cn]0xEA 不允许来宾激活 */
    TSDK_E_ERR_CONFERENCE_VMR_CONF_PARAM_ERR,               /**< [en]0xEB Failed to get VMR conference parameters
                                                                 [cn]0xEB 获取VMR会议参数失败 */
    TSDK_E_ERR_CONFERENCE_NO_VMR_CONF,                      /**< [en]0xEC Update non-existent VMR Conference
                                                                 [cn]0xEC 尝试更新不存在的VMR会议 */
    TSDK_E_ERR_CONFERENCE_VMR_NUM_BEYOND,                   /**< [en]0xED The number of VMR conference creation exceeds the specification
                                                                 [cn]0xED VMR会议创建数目超出规格 */
    TSDK_E_ERR_CONFERENCE_VMR_CHANGE_ERR,                   /**< [en]0xEE Not allowed modify VMR information
                                                                 [cn]0xEE 不允许修改VMR信息 */
    TSDK_E_CONF_ERR_BUTT

} TSDK_E_CONF_ERR_ID;


typedef enum tagTSDK_E_LDAP_FRONTSTAGE_ERR_ID
{
    TSDK_E_LDAP_FRONTSTAGE_ERR_BEGIN = 0x07FFFFFF,

    TSDK_E_LDAP_FRONTSTAGE_ERR_UNKNOWN,                             /**< [en]0x800 0000‬ Indicates unknown error
                                                                         [cn]0x800 0000‬ 未知错误 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_PARAM_IS_NULL_POINT,                 /**< [en]0x800 0001 Param is null point
                                                                         [cn]0x800 0001 参数为空 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_LOAD_LIBRARY_FAILED,                 /**< [en]0x800 0002 Indicates load library failed
                                                                         [cn]0x800 0002 加载库错误 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_LDAP_SERVICE_NOT_START,              /**< [en]0x800 0003 Ldap service not started failed
                                                                         [cn]0x800 0003 LDAP 服务未开启 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_USER_NOT_LOGIN,                      /**< [en]0x800 0004 User not login
                                                                         [cn]0x800 0004 用户未登录 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_MALLOC_FAILED,                       /**< [en]0x800 0005 Indicates allocate memory failed
                                                                         [cn]0x800 0005 分配内存错误 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_KEYWORDS_IS_INVALID,                 /**< [en]0x800 0006 Search keyword is illegal
                                                                         [cn]0x800 0006 搜索关键字不合法 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_NETWORK_ERROR,                       /**< [en]0x800 0007 Indicates abnormal network
                                                                         [cn]0x800 0007 网络异常 */
    TSDK_E_LDAP_FRONTSTAGE_ERR_BUTT
}TSDK_E_LDAP_FRONTSTAGE_ERR_ID;


/**
*.此枚举值只用作高层SDK,APP不能直接返回错误码，需要转换。
* [en]This enumeration is used to describe error code definition for failure of safety function call.
* [cn]安全函数调用失败错误码定义
*/
typedef enum tagTSDK_E_SECURE_FUNC_ERR_ID
{
    TSDK_E_SECURE_FUNC_ERR_BEGIN = 0x08FFFFFF,

    TSDK_E_SECURE_FUNC_ERR_STRCPY_S_FAILED,                       /**< [en]0x00 Indicates the strcpy_s call failed
                                                                       [cn]0x00 strcpy_s调用失败*/
    TSDK_E_SECURE_FUNC_ERR_STRCAT_S_FAILED,                       /**< [en]0x01 Indicates the strcat_s call failed
                                                                       [cn]0x01 strcat_s调用失败*/
    TSDK_E_SECURE_FUNC_ERR_MEMCPY_S_FAILED,                       /**< [en]0x02 Indicates the memcpy_s call failed
                                                                       [cn]0x02 memcpy_s调用失败*/
    TSDK_E_SECURE_FUNC_ERR_SPRINTF_S_FAILED,                      /**< [en]0x03 Indicates the sprintf_s call failed
                                                                       [cn]0x03 sprintf_s调用失败*/
    TSDK_E_SECURE_FUNC_ERR_SNPRINTF_S_FAILED,                     /**< [en]0x04 Indicates the snprintf_s call failed
                                                                       [cn]0x04 _snprintf_s调用失败*/
    TSDK_E_SECURE_FUNC_ERR_STRNCPY_S_FAILED,                      /**< [en]0x05 Indicates the strncpy_s call failed
                                                                       [cn]0x05 _strncpy_s调用失败*/
    TSDK_E_SECURE_FUNC_ERR_BUTT
}TSDK_E_SECURE_FUNC_ERR_ID;


/**
 * [en]This enumeration is used to describe error code definitions of ui plugin module.
 * [cn]UI Plugin模块错误码定义
 */
typedef enum tagTSDK_E_UI_PLUGIN_ERR_ID
{
    TSDK_E_UI_PLUGIN_ERR_BEGIN = 0x10FFFFFF,

    TSDK_E_UI_PLUGIN_ERR_UNKNOWN,                             /**< [en]0x00 Indicates unknown error
                                                                 [cn]0x00 未知错误 */
    TSDK_E_UI_PLUGIN_ERR_GENERAL_ERROR,                       /**< [en]0x01 Indicates general error
                                                                 [cn]0x01 一般错误 */
    TSDK_E_UI_PLUGIN_ERR_PARAM_ERROR,                         /**< [en]0x02 Indicates parameter error
                                                                 [cn]0x02 参数错误 */
    TSDK_E_UI_PLUGIN_ERR_MALLOC_FAILED,                       /**< [en]0x03 Indicates allocate memory failed
                                                                 [cn]0x03 分配内存错误 */
    TSDK_E_UI_PLUGIN_ERR_SYSTEM_ERROR,                        /**< [en]0x04 Indicates system error
                                                                 [cn]0x04 系统错误 */

    TSDK_E_UI_PLUGIN_LOAD_LIBRARY_FAILED,                      /**< [en]0x05 Indicates load library failed
                                                                 [cn]0x05 加载库错误 */
    TSDK_E_UI_PLUGIN_SDK_UNINITIALIZED,                        /**< [en]0x06 Indicates sdk uninitialized
                                                                 [cn]0x06 SDK未初始化 */
    TSDK_E_UI_PLUGIN_SDK_INIT_REPEAT,                          /**< [en]0x07 Indicates sdk Initialization repetition
                                                                 [cn]0x07 SDK初始化重复 */
    TSDK_E_UI_PLUGIN_CREATE_BASE_FRAME_FAILED,               /**< [en]xxxx
                                                                   [cn]xxxx */
    TSDK_E_UI_PLUGIN_SET_UI_PARAM_FAILED,               /**< [en]xxxx
                                                                   [cn]xxxx */
    TSDK_E_UI_PLUGIN_ERR_BUTT
}TSDK_E_UI_PLUGIN_ERR_ID;

/**
* [en]This enumeration is used to describe error code definitions of cert.
* [cn]UI Plugin模块错误码定义
*/
typedef enum tagTSDK_E_CERT_ERROR_ID
{
    TSDK_E_CMPT_ERR_BEGIN = 0x12FFFFFF,

    TSDK_E_CMPT_INVALID_PARAM,                            /**< [en]0x13000000 Indicates invalid input parameter.
                                                               [cn]0x13000000 非法入参 */
    TSDK_E_CMPT_GENERAL_ERROR,                                  /**< [en]0x13000001 Indicates minor error
                                                               [cn]0x13000001 一般错误 */
    TSDK_E_CMPT_ALLOC_MEM_FAIL,                           /**< [en]0x13000002 Indicates failed to allocate memory.
                                                               [cn]0x13000002 内存分配失败 */
    TSDK_E_CMPT_CERT_OPEN_FAILED,                         /**< [en]0x13000003 Indicates failed to open the certificate due to the certificate format.
                                                               [cn]0x13000003 证书格式等问题，打开失败 */
    TSDK_E_CMPT_CERT_NOT_IN_USE,                          /**< [en]0x13000004 Indicates the certificate 
                                                                   does not take effect.
                                                               [cn]0x13000004 证书未生效 */
    TSDK_E_CMPT_CERT_OVERDUE,                             /**< [en]0x13000005 Indicates the certificate has expired.
                                                               [cn]0x13000005 证书已过期 */
    TSDK_E_CMPT_CERT_ISSUER_ERROR,                              /**< [en]0x13000006 Indicates authority error
                                                               [cn]0x13000006 颁发机构错误 */
    TSDK_E_CMPT_CERT_REVOKED,                             /**< [en]0x13000007 Indicates certificate revoked
                                                               [cn]0x13000007 证书已吊销 */
    TSDK_E_CMPT_SIGNALG_NOTSAFE,                          /**< [en]0x13000008 Indicates the signature algorithm is insecure.
                                                               [cn]0x13000008 签名算法不安全 */
    TSDK_E_CMPT_PUBKEY_LENGTH_TOO_SHORT,                  /**< [en]0x13000009 Indicates the length of the public key is less than 2048.
                                                               [cn]0x13000009 公钥长度低于2048 */
    TSDK_E_CMPT_DETECT_UNINIT,                            /**< [en]0x1300000A Indicates the network detection module is not initialized.
                                                               [cn]0x1300000A 网络检测模块未初始化等 */
    TSDK_E_CMPT_DETECT_STARTED,                           /**< [en]0x1300000B Indicates the client or server has been started and cannot be started repeatedly.
                                                               [cn]0x1300000B 客户端或者服务端已经启动，不能重复启动等 */
    TSDK_E_CMPT_DETECT_SOCKET_ERROR,                      /**< [en]0x1300000C Indicates socket errors, including socket creation and socket initialization
                                                               [cn]0x1300000C Socket错误，包括创建socket、socket初始化等 */
    TSDK_E_CMPT_DETECT_SOCKET_BIND_ERROR,                 /**< [en]0x1300000D Indicates socket binding error.
                                                               [cn]0x1300000D Socket绑定错误 */
    TSDK_E_CMPT_DETECT_SOCKET_CONN_ERROR,                 /**< [en]0x1300000E Indicates socket connection error.
                                                               [cn]0x1300000E Socket链接错误 */
    TSDK_E_CMPT_DETECT_THREAD_ERROR,                      /**< [en]0x1300000F Indicates an error occurred when creating the thread.
                                                               [cn]0x1300000F thread创建错误 */
    TSDK_E_CMPT_DETECT_INVALID_PARAM,                     /**< [en]0x13000010 Indicates invalid input parameter.
                                                               [cn]0x13000010 非法入参 */
    TSDK_E_CMPT_PRIVKEY_PWD_ERROR,                        /**< [en]0x13000011 Indicates the private 
                                                                   key password is incorrect.
                                                               [cn]0x13000011 私钥密码错误 */
    TSDK_E_CMPT_ERR_BUTT
}TSDK_E_CERT_ERROR_ID;

/**
* [en]This enumeration is used to describe error code definitions of miantain module.
* [cn]miantain模块错误码定义
*/
typedef enum tagTSDK_E_MAINTAIN_ERR_ID
{
    TSDK_E_MAINTAIN_ERR_BEGIN = 0x11FFFFFF,

    TSDK_E_MAINTAIN_ERR_UNKNOWN,                             /**< [en]0x00 Indicates unknown error
                                                                  [cn]0x00 未知错误 */
    TSDK_E_MAINTAIN_ERR_GENERAL_ERROR,                       /**< [en]0x01 Indicates general error
                                                                  [cn]0x01 一般错误 */
    TSDK_E_MAINTAIN_ERR_PARAM_ERROR,                         /**< [en]0x02 Indicates parameter error
                                                                  [cn]0x02 参数错误 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_FILE_UNEXIST,             /**< [en]0x03 Indicates log upload file unexist error
                                                                  [cn]0x03 上传文件路径错误 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_FILE_FORMAT_ERROR,        /**< [en]0x04 Indicates log upload file format error
                                                                  [cn]0x04 上传文件格式错误 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_FILE_SIZE_ERROR,          /**< [en]0x05 Indicates log upload file size error
                                                                  [cn]0x05 上传文件大小错误 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOADING,                       /**< [en]0x06 Indicates log uploading
                                                                  [cn]0x06 上传文件中 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_SMC_NOT_RETURN_FTP_INFOS, /**< [en]0x07 when uploading log SMC does not return ftp information
                                                                  [cn]0x07 上传日志SMC未返回ftp信息 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_SMC_NOT_RESPONSE,         /**< [en]0x08 when uploading log SMC does not response
                                                                  [cn]0x08 上传日志SMC未响应 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_REQUEST_SMC_FAILED,       /**< [en]0x09 when uploading request SMC failed
                                                                  [cn]0x09 上传日志请求SMC失败 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_FTP_SENDRECV_NET_DATA_FAILED,    /**< [en]0x0A Failed to send/recv network data through FTP
                                                                         [cn]0x0A FTP发送/接收网络数据失败 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_FILE_EXIST_AND_COMPLETE,  /**< [en]0x0B The file exists and is complete
                                                                  [cn]0x0B FTP上传失败，文件存在且完整 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_FTP_TLS_ABNORMAL,         /**< [en]0x0C The FTP TLS is abnormal
                                                                  [cn]0x0C FTP TLS异常 */
    TSDK_E_MAINTAIN_ERR_LOG_UPLOAD_FTP_LOGIN_FAILED,         /**< [en]0x0D Failed to log in to the FTP server
                                                                  [cn]0x0D FTP 服务器登录失败 */
    TSDK_E_MAINTAIN_ERR_REQUEST_FAILED,                      /**< [en]0x0E when uploading to ftp failed
                                                                  [cn]0x0E 请求消息异常 */
    TSDK_E_MAINTAIN_ERR_BUTT

}TSDK_E_MAINTAIN_ERR_ID;

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_ERROR_DEF_H__ */

