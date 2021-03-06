/**
 * @file tsdk_manager_def.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK initialization and service config management.
 */

#ifndef __TSDK_MANAGER_DEF_H__
#define __TSDK_MANAGER_DEF_H__


#include "tsdk_def.h"
#include "tsdk_common_macro_def.h"


#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */



/**
 * [en]This enumeration is about notify event of several module
 * [cn]业务回调通知事件
 */
typedef enum tagTSDK_E_EVENT
{
    TSDK_E_EVENT_BEGIN = 0,

    TSDK_E_EVENT_SWITCH_THREAD = 1,

    TSDK_E_LOGIN_EVT_LOGIN_BEGIN = 1000,

    TSDK_E_LOGIN_EVT_AUTH_SUCCESS,                  /**< [en]Indicates authorize success(Used to render the login process, the application layer generally does not need to handle).
                                                         [cn]鉴权成功(用于呈现登录过程，应用层一般无需处理)。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：None
                                                            data：  TSDK_S_IM_LOGIN_PARAM* im_account_param [en]Indicates im account param.[cn]IM 帐号信息参数，用于支持原子级IM SDK兼容，只要鉴权结果中存在就返回 */

    TSDK_E_LOGIN_EVT_AUTH_FAILED,                   /**< [en]Indicates authorize failed.
                                                         [cn]鉴权失败。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Indicates reason code.[cn]原因码
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */

    TSDK_E_LOGIN_EVT_AUTH_REFRESH_FAILED,           /**< [en]Indicates authorize refresh failed.
                                                         [cn]鉴权刷新失败。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Indicates reason code.[cn]原因码
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */

    TSDK_E_LOGIN_EVT_LOGIN_SUCCESS,                 /**< [en]Indicates login success
                                                         [cn]登录成功。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 service_account_type [en]Indicates service account type.value of TSDK_E_SERVICE_ACCOUNT_TYPE [cn]服务帐号类型，取值参见：TSDK_E_SERVICE_ACCOUNT_TYPE
                                                            data：  TSDK_S_LOGIN_SUCCESS_INFO* login_success_info [en]Indicates login success info.[cn]登陆成功的相关信息*/
    //1005
    TSDK_E_LOGIN_EVT_LOGIN_FAILED,                  /**< [en]Indicates login failed.
                                                         [cn]登录失败。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 service_account_type [en]Indicates service account type. value of TSDK_E_SERVICE_ACCOUNT_TYPE [cn]服务帐号类型，取值参见： TSDK_E_SERVICE_ACCOUNT_TYPE
                                                            data：  TSDK_S_LOGIN_FAILED_INFO* login_failed_info [en]Indicates login failed info.[cn]登陆失败的信息*/

    TSDK_E_LOGIN_EVT_LOGOUT_SUCCESS,                /**< [en]Indicates login success
                                                         [cn]登出成功。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 service_account_type 
                                                                    [en]Indicates service account type.
                                                                        value of TSDK_E_SERVICE_ACCOUNT_TYPE.
                                                                    [cn]服务帐号类型，取值参见：TSDK_E_SERVICE_ACCOUNT_TYPE
                                                            data：   TSDK_ABNORMAL_INFO* logoutInfo 
                                                                    [en]Indicates abnormal logout info.
                                                                    [cn]异常退出的错误信息，正常登出时为TSDK_NULL_PTR */

    TSDK_E_LOGIN_EVT_LOGOUT_FAILED,                 /**< [en]Indicates logout failed.
                                                         [cn]登出失败。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Indicates reason code.[cn]原因码
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */

    TSDK_E_LOGIN_EVT_FORCE_LOGOUT,                  /**< [en]Indicates force logout
                                                         [cn]强制登出。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 service_account_type [en]Indicates service account type.value of TSDK_E_SERVICE_ACCOUNT_TYPE.[cn]服务帐号类型，取值参见：TSDK_E_SERVICE_ACCOUNT_TYPE
                                                            data：  TSDK_E_FORCE_LOGOUT_INFO *force_logout_info [en]Indicates force logout info.[cn]强制登出信息 */

    TSDK_E_LOGIN_EVT_VOIP_ACCOUNT_STATUS,           /**< [en]Indicates voip account info
                                                         [cn]VOIP帐号信息
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：None
                                                            data：  TSDK_S_VOIP_ACCOUNT_INFO* voip_account_info [en]Indicates voip account info.[cn]VOIP账号信息 */
    // 1010
    TSDK_E_LOGIN_EVT_IM_ACCOUNT_STATUS,             /**< [en]Indicates IM account info
                                                         [cn]IM帐号状态信息
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：None
                                                            data：  TSDK_S_IM_ACCOUNT_INFO* im_account_info [en]Indicates im account info.[cn]IM账号信息 */

    TSDK_E_LOGIN_EVT_FIREWALL_DETECT_FAILED,        /**< [en]Indicates firewall detect failed.
                                                         [cn]防火墙探测失败。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Indicates reason code.[cn]原因码
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */

    TSDK_E_LOGIN_EVT_BUILD_STG_TUNNEL_FAILED,        /**< [en]Indicates build stg tunnel failed.
                                                          [cn]创建stg通道失败。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Indicates reason code.[cn]原因码
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */

    TSDK_E_LOGIN_EVT_SECURITY_TUNNEL_INFO_IND,       /**< [en]Indicates security tunnel info notify.
                                                          [cn]安全隧道信息通知。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 firewall_mode [en]Indicates firewall mode.[cn]防火墙模式
                                                            data：  TSDK_S_SECURITY_TUNNEL_INFO*  security_tunnel_info [en]Indicates security tunnel info.[cn]安全隧道信息 */

    TSDK_E_LOGIN_EVT_GET_TEMP_USER_RESULT,            /**< [en]Indicates result of obtaining the temporary account for joining a conference anonymously.
                                                           [cn]获取用于匿名方式加入会议的临时用户结果通知。
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Indicates reason code.[cn]原因码
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */
    TSDK_E_LOGIN_EVT_GET_VERSION_INFO_RESULT,          /**< [en]Indicates result of obtaining the versionInfo .
                                                            [cn]获取版本信息结果通知
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Indicates reason code.[cn]原因码
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */
    TSDK_E_LOGIN_EVT_VERSION_UPDATE_IND,              /**< [en]Indicates result of obtaining the versionInfo .
                                                           [cn]版本信息更新通知
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 None
                                                            data：  LOGIN_S_VERSIONINFO *data reason_description [en]Indicates error reason description.[cn]错误原因描述 */
    TSDK_E_LOGIN_EVT_GET_CONF_PARAM_IND,              /**< [en]Indicates result of obtaining the versionInfo .
                                                           [cn]获取会议大参数结果事件通知
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：TSDK_UINT32 None
                                                            data：  TSDK_S_LOGIN_TEMPUSER_VC_INFO *data reason_description [en]Indicates error reason description.[cn]错误原因描述 */

    TSDK_E_LOGIN_EVT_PASSWORD_CHANGEED_RESULT,        /**< [en]Indicates the password modification result
                                                           [cn]密码修改结果
                                                            param1：TSDK_UINT32 user_id [en]User id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Reason code.[cn]原因码
                                                            data：  TSDK_S_LOGIN_FAILED_INFO* failedInfo 
                                                                    [en]failed info.[cn]错误信息 */

    TSDK_E_LOGIN_FIRST_MODIFY_PWD_NOTIFY,             /**< [en]Indicates the notify to change first password.
                                                           [cn]SMC3.0提示用户首次修改密码通知
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：None
                                                            data：  None  */

    TSDK_E_LOGIN_EVT_GET_USER_INFO_RESULT,            /**< [en]Indicates result of obtaining the user info.
                                                           [cn]获取用户信息结果事件通知
                                                            param1：TSDK_UINT32 user_id [en]User id.[cn]用户ID
                                                            param2：TSDK_UINT32 reason_code [en]Reason code.[cn]原因码
                                                            data：  LOGIN_S_SMC3_USER_INFO_RESULT* userInfoParam 
                                                                    [en]Indicates the user info.[cn]用户信息*/
    TSDK_E_LOGIN_EVT_LOGIN_STATUS,                    /**< [en]Indicates login state.
                                                           [cn]登录状态
                                                            param1：TSDK_UINT32 user_id [en]Indicates user id.[cn]用户ID
                                                            param2：0 - Online, 1 - Offline. [cn] 0 - 在线, 1 - 离线
                                                            data：  NULL */

    TSDK_E_LOGIN_EVT_LOGIN_BUTT = 1999,


    TSDK_E_CALL_EVT_CALL_BEGIN = 2000,
    TSDK_E_CALL_EVT_CALL_START_RESULT,              /**< [en]Indicates start a call result.
                                                         [cn]发起呼叫结果。
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：TSDK_UINT32 result  [en]Indicates start call result, value of CALL_E_ERR_ID.[cn]建立呼叫结果，取值参考CALL_E_ERR_ID
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_CALL_EVT_CALL_INCOMING,                  /**< [en]Indicates incoming call event
                                                         [cn]来电事件
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：TSDK_UINT32 maybe_video_call [en]Indicates maybe video call.[cn]可能是视频呼叫
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_CALL_OUTGOING,                  /**< [en]Indicates outgoing call event
                                                         [cn]呼出事件
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_CALL_RINGBACK,                  /**< [en]Indicates ring back event
                                                         [cn]回铃音事件(在需要APP播放回铃音时上报)
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  None */
    //2005
    TSDK_E_CALL_EVT_CALL_RTP_CREATED,               /**< [en]Indicates the RTP channel is already created, can do secondary call
                                                         [cn]RTP通道已建立，可以进行二次拨号
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  None */

    TSDK_E_CALL_EVT_CALL_CONNECTED,                 /**< [en]Indicates call is connected
                                                         [cn]通话已建立
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息*/

    TSDK_E_CALL_EVT_CALL_ENDED,                     /**< [en]Indicates call ended
                                                         [cn]呼叫结束
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_CALL_DESTROY,                   /**< [en]Indicates the destroy call control info
                                                         [cn]呼叫结束后销毁呼叫控制信息
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_OPEN_VIDEO_REQ,                 /**< [en]Indicates remote side request open video(audio call upgrade to video call).
                                                         [cn]远端请求打开视频(音频通话升级为视频通话)
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：TSDK_UINT32 orient_type [en]Indicates orient type. value of TSDK_E_VIDEO_ORIENTATION .[cn]横竖屏, 取值:TSDK_E_VIDEO_ORIENTATION
                                                            data：  None  */
    //2010
    TSDK_E_CALL_EVT_REFUSE_OPEN_VIDEO_IND,          /**< [en]Indicates remote side reject request open video(remote user reject or response overtime).
                                                         [cn]远端拒绝请求打开视频通知(远端用户拒绝或超时未响应)
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  None  */

    TSDK_E_CALL_EVT_CLOSE_VIDEO_IND,                /**< [en]Indicates close video indicate(video call transfer to audio call).
                                                         [cn]关闭视频通知(视频通话转为音频通话)
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  None */

    TSDK_E_CALL_EVT_OPEN_VIDEO_IND,                 /**< [en]Indicates open video indicates(audio call transfer to audio call).
                                                         [cn]打开视频通知(音频通话转为视频通话)
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  None */

    TSDK_E_CALL_EVT_REFRESH_VIEW_IND,               /**< [en]Indicates the notice of video view refresh
                                                         [cn]视频view刷新通知
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_VIDEO_VIEW_REFRESH* refresh_info [en]Indicates info of video refresh event.[cn]视频刷新事件信息 */


    TSDK_E_CALL_EVT_CALL_ROUTE_CHANGE,              /**< [en]Indicates the notice of mobile route change
                                                         [cn]移动路由变化通知(主要用于iOS)
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：TSDK_UINT32 route [en]Indicates route.[cn]路由的设备
                                                            data：  None  */
    //2015
    TSDK_E_CALL_EVT_PLAY_MEDIA_END,                 /**< [en]Indicates the audio file playback end notification
                                                         [cn]音频文件播放结束通知
                                                            param1：TSDK_UINT32 handle [en]Indicates file handle.[cn]文件句柄
                                                            param2：None
                                                            data：  None  */

    TSDK_E_CALL_EVT_SESSION_MODIFIED,               /**< [en]Indicates the session modification complete notification
                                                         [cn]会话修改完成通知
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_SESSION_MODIFIED* session_info [en]Indicates info of session modified completely result.[cn]会话修改完成结果信息 */

    TSDK_E_CALL_EVT_SESSION_CODEC,                  /**< [en]Indicates the session is using the codec notification
                                                         [cn]会话正在使用的codec通知
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_SESSION_CODEC* codec_info [en]Indicates codec info of session is using.[cn]会话正在使用的编解码器信息 */

    TSDK_E_CALL_EVT_HOLD_SUCCESS,                   /**< [en]Indicates the hold successfully
                                                         [cn]保持成功
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_HOLD_FAILED,                    /**< [en]Indicates the hold failed
                                                         [cn]保持失败
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */
    //2020
    TSDK_E_CALL_EVT_UNHOLD_SUCCESS,                 /**< [en]Indicates the recover successfully
                                                         [cn]恢复成功
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_UNHOLD_FAILED,                  /**< [en]Indicates the recover failed
                                                         [cn]恢复失败
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_ENDCALL_FAILED,                 /**< [en]Indicates the end call failed
                                                         [cn]结束通话失败
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：TSDK_UINT32 result  [en]Indicates end call failed.[cn]结束通话失败错误码
                                                            data：  None  */

    TSDK_E_CALL_EVT_DIVERT_FAILED,                  /**< [en]Indicates the divert call failed
                                                         [cn]偏转失败
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_BLD_TRANSFER_SUCCESS,           /**< [en]Indicates the blind transfer successfully
                                                         [cn]盲转成功
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */
    //2025
    TSDK_E_CALL_EVT_BLD_TRANSFER_FAILED,            /**< [en]Indicates the blind transfer failed
                                                         [cn]盲转失败
                                                            param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息 */

    TSDK_E_CALL_EVT_SET_IPT_SERVICE_RESULT,         /**< [en]Indicates the result of registration IPT service result
                                                         [cn]登记IPT业务结果
                                                            param1：TSDK_E_IPT_SERVICE_TYPE service_type [en]Indicates service type.[cn]业务类型
                                                            param2：None
                                                            data：  TSDK_S_SET_IPT_SERVICE_RESULT *set_service_result [en]Indicates set ipt service result.[cn]设置ipt业务结果 */

    TSDK_E_CALL_EVT_IPT_SERVICE_INFO,               /**< [en]Indicates ipt service info changed notification
                                                         [cn]ipt业务信息变更通知
                                                            param1：TSDK_UINT32 account_id [en]Indicates account id.[cn]帐号ID
                                                            param2：None
                                                            data：  TSDK_S_IPT_SERVICE_INFO_SET* service_info  [en]Indicates ipt service right info.[cn]ipt业务信息 */

    TSDK_E_CALL_EVT_STATISTIC_LOCAL_QOS,            /**< [en]Indicates the report the QOS of network information every 5 seconds,for displaying interface network status
                                                         [cn]定时5秒上报QOS网络信息上，用于界面网络状态显示
                                                            param1：TUP_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_LOCAL_QOS_INFO* localqos_info [en]Indicates Qos report info(report to local UI).[cn]QoS上报信息(上报本地UI) */
    //2029
    TSDK_E_CALL_EVT_AUX_SENDING,                    /**< [en]Indicates auxiliary sending success.
                                                         [cn]辅流发送成功
                                                            param1: TSDK_UINT32 call id,[en]Indicates call id.[cn]呼叫ID
                                                            param2: None.
                                                            data:  None*/
    //2030
    TSDK_E_CALL_EVT_AUX_SHARE_FAILED,               /**< [en]Indicates auxiliary stream sharing failed.
                                                         [cn]辅流共享失败
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息*/
	 //2031
    TSDK_E_CALL_EVT_AUX_DATA_RECVING,               /**< [en]Indicates auxiliary.received successfully
                                                         [cn]辅流接收成功
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
     //2032                                                       data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息*/
    TSDK_E_CALL_EVT_AUX_DATA_STOPPED,               /**< [en]Indicates auxiliary stop.
                                                         [cn]辅流停止
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：None
                                                            data：  TSDK_S_CALL_INFO* call_info [en]Indicates call info.[cn]呼叫信息*/
    //2033
    TSDK_E_CALL_EVT_DECODE_SUCCESS,                 /**< [en]Indicates decoding success notification
                                                         [cn]解码成功信息通知
                                                            param1: TSDK_UINT32 call id,[en]Indicates call id.[cn]呼叫ID
                                                            param2: None.
                                                            data:  TSDK_S_DECODE_SUCCESS* tsdk_decode_success [en]the decoding successfyl event information.[cn]解码成功信息 */
    //2034
    TSDK_E_CALL_EVT_NO_STREAM_DURATION,             /**< [en]Indicates the upper layer codeless flow duration, in seconds
                                                         [cn]通知上层无码流持续时间，单位:秒 
                                                            param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2：TSDK_UINT32 duration [en]Indicates codeless flow duration, unit is second.[cn]已经无码流持续时间，单位: 秒
                                                            data：None */

    // 2035
    TSDK_E_CALL_EVT_REFER_NOTIFY,                   /**< [en]Indicates transfer notification
                                                         [cn]转移通知
                                                            param1:TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            param2: None.
                                                            data:   None */
    // 2036
    TSDK_E_CALL_EVT_AUDIT_DIR,                      /**< [en]Indicates direction type of audience conference
                                                        [cn]上报观众会场会议方向类型
                                                        param1:TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                        param2:direction type [en]Indicates the direction type of audience conference. 0-one way, 1-two ways. [cn]会议方向，0-单向，1-双向
                                                        data:   None */
    // 2037
    TSDK_E_CALL_EVT_AUTH_TYPE_NOTIFY,                /**< [en]Indicates user auth type
                                                         [cn]上报用户认证类型，是否外部认证
                                                         param1:TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                         param2:auth type [en]Indicates the auth type of user. 0-not auth, 1-local auth, 2-external auth, 3-invalid type. [cn]认证方式，0-未认证，1-本地认证，2-外部认证，3-无效值
                                                         data:   None */
    // 2038
    TSDK_E_CALL_EVT_AUDIO_DEVICE_CHANGE_NOTIFY,     /**< [en]Indicates audio device change
                                                         [cn]音频设备改变通知
                                                         param1:TSDK_E_DEVICE_CHANGED deviceChangeType
                                                                  [en] Indicates changed device type.
                                                                  [cn]设备改变类型
                                                                TsdkMobileAudioDeviceStatus mobileDeviceChange 
                                                                  [en] Indicates mobile changed device type.
                                                                  [cn]手机端设备改变类型
                                                         param2:0
                                                         data:   None */
    // 2039
    TSDK_E_CALL_EVT_VIDEO_DEVICE_CHANGE_NOTIFY,     /**< [en]Indicates vedio device change
                                                         [cn]视频设备改变通知
                                                         param1:TSDK_UINT32 callId [en]Indicates call id.[cn]呼叫ID
                                                         param2:TSDK_UINT32 captureSourceLost [en]Indicates if device lost.[cn]设备是否丢失

                                                         data:TsdkVideoDeviceInfo* videoDeviceInfo [en]Indicates remaining device info.[cn]变更后剩余设备信息 */

    // 2040
    TSDK_E_CALL_EVT_AUDIO_START_DEVICE_FAIL,         /**< [en]Indicates play media fail
                                                         [cn]音频播放失败
                                                         param1:None.
                                                         param2:None.
                                                         data:   None */

    // 2041
    TSDK_E_CALL_EVT_CAMERA_STATE_CHANGE,             /**< [en]Indicates camera open close
                                                          [cn]通话中摄像头开启或关闭
                                                          param1:TSDK_UINT32 callId 
                                                              [en]Indicates call id.
                                                              [cn]呼叫ID
                                                          param2:TSDK_E_CAMERA_STATE cameraState 
                                                              [en]Indicates camera state.
                                                              [cn]摄像头状态
                                                          data:   None */
    // 2042
    TSDK_E_CALL_EVT_AUDIO_NET_QUALITY,             /**< [en]Indicates the network quality change notification
                                                        [cn]网络质量改变通知
                                                        param1：TSDK_UINT32 callId  [en]Indicates call id. [cn]呼叫ID
                                                        param2：None
                                                        data：TsdkCallNetQualityLevel netLevel
                                                        [en]Indicates notify of net quality level.
                                                        [cn]网络质量改变通知 */
    // 2043
    TSDK_E_CALL_EVT_VIDEO_NET_QUALITY,             /**< [en]Indicates the network quality statistics information
                                                        [cn]网络质量统计信息
                                                        param1：TSDK_UINT32 callId  [en]Indicates call id.[cn]呼叫ID
                                                        param2：None
                                                        data：TsdkCallNetQualityLevel videoNetLevel 
                                                        [en]Indicates statistics info of net quality level.
                                                        [cn]网络质量等级*/
    TSDK_E_CALL_EVT_MEDIA_ERROR_INFO,              /**< [en]Indicates media error information notification
                                                        [cn]媒体错误信息通知
                                                        param1：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                        param2：None
                                                        data：TsdkMediaErrorInfo* tsdkMediaErrorInfo [en]Indicates media error info.[cn]媒体错误信息 */
    TSDK_E_CALL_EVT_HOWL_STATUS,                   /**< [en]Indicates howl information notification
                                                        [cn]啸叫信息通知
                                                        param1：TSDK_UINT32 howlAutoMuteSwitch
                                                        param2：None
                                                        data：TSDK_NULL_PTR*/
    TSDK_E_CALL_EVT_AUDIO_DEVICE_STATUS,           /**< [en]Indicates audio device err information notification
                                                        [cn]音频设备异常通知
                                                        param1: TsdkSystemAudioErrType audioErrType;不同场景下音频异常的错误码类型.
                                                        param2: None.
                                                        data: None */
    TSDK_E_CALL_EVT_REAL_TIME_BAND_WIDTH_CHANGE,   /**< [en]Indicates Real-Time bandWidth info change
                                                        [cn]实时带宽信息变化通知(只适配SVC)
                                                        param1：TSDK_UINT32 callId  [en]Indicates call id.[cn]呼叫ID
                                                        param2：TSDK_UINT32 realTimeBandWidth [en]Indicates Real-Time bandwidth.[cn]实时带宽
                                                        data：None */
    TSDK_E_CALL_EVT_VIDEO_SWITCH_NOTIFY,           /**< [en]Indicates tmmbr bandwidth notification of turning on/off camera or data
                                                        [cn]上报根据主辅流tmmbr信息通知产品启停摄像头或辅流
                                                        param1：TSDK_UINT32 callid [en]Indicates account id.[cn]呼叫ID 
                                                        param2：TSDK_UINT32 msgType [en]Indicates camera on/off or data on/off. TsdkCallNotifyTmmbrMsgType.
                                                        [cn]通知类型，打开或关闭主流，打开或关闭辅流*/
    TSDK_E_CALL_EVT_DEVICE_STATE,                  /**< [en]Indicates report device state
                                                        [cn]上报设备状态
                                                        param1：TSDK_UINT32 callId [en]Indicates call id.[cn]呼叫ID
                                                        param2：TSDK_UINT32 preCallId [en]Indicates Previous Call ID.
                                                                                      [cn]上一路呼叫ID
                                                        data：TSDK_S_DEVICE_STATE *deviceInfo */
    TSDK_E_CALL_EVT_CALL_BUTT = 2999,


    TSDK_E_CONF_EVT_CONF_BEGIN = 3000,
    TSDK_E_CONF_EVT_BOOK_CONF_RESULT,               /**< [en]Indicates book conf result.
                                                         [cn]预约会议结果。
                                                            param1：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            param2：None
                                                            data：  TSDK_S_CONF_BASE_INFO* conf_base_info [en]Indicates conference info.[cn]会议信息(成功时返回)
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT,         /**< [en]Indicates query conference list result
                                                         [cn]查询会议列表结果
                                                            param1：TSDK_UINT32 result  [en]Indicates operate result [cn]操作结果
                                                            param2：None
                                                            data：  TSDK_S_CONF_LIST_INFO* conf_list_info [en]Indicates conference list info.[cn]会议列表信息(成功时返回)
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_CONF_EVT_QUERY_CONF_DETAIL_RESULT,       /**< [en]Indicates query conference detail result
                                                         [cn]查询会议详情结果
                                                            param1：TSDK_UINT32 result  [en]Indicates operate result [cn]操作结果
                                                            param2：None
                                                            data：  TSDK_S_CONF_DETAIL_INFO* conf_info [en]Indicates conference detail info.[cn]会议详情信息(成功时返回)
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_CONF_EVT_JOIN_CONF_RESULT,               /**< [en]Indicates join conf result.
                                                         [cn]加入会议结果。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            data：  TSDK_S_JOIN_CONF_IND_INFO *info [en]Indicates conference connect info.[cn]会议接通信息(成功时返回)
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */
    //3005
    TSDK_E_CONF_EVT_GET_DATACONF_PARAM_RESULT,      /**< [en]Indicates get data conf param result.
                                                         [cn]获取数据会议参数结果。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            data：  TSDK_S_CONF_DATACONF_PARAMS *data_conf_param [en]Indicates conference data conf param(it return when success), it's used to compatible atom SDK using scenes.[cn]数据会议参数(成功时返回)，用于兼容原子SDK使用场景
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT,      /**< [en]Indicates conf ctrl operation result.
                                                         [cn]会控操作结果。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_CONF_OPERATION_RESULT* result_info [en]Indicates conference info.[cn]会控操作结果信息 */

    TSDK_E_CONF_EVT_INFO_AND_STATUS_UPDATE,         /**< [en]Indicates conf info and status update.
                                                         [cn]会议信息及状态状态更新。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_CONF_STATUS_INFO* conf_status [en]Indicates conference status.[cn]会议状态 */

    TSDK_E_CONF_EVT_SPEAKER_IND,                    /**< [en]Indicates notice of the speaker
                                                         [cn]发言方通知。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_CONF_SPEAKER_INFO* conf_speakers [en]Indicates speaker info.[cn]发言方信息 */

    TSDK_E_CONF_EVT_REQUEST_CONF_RIGHT_FAILED,      /**< [en]Indicates request conference right failed(attendee will has no conference control right during conference, but can also join conference).
                                                         [cn]申请会控权限失败(与会者在会议中将无会控权限，但仍可参与会议)。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */
    //3010
    TSDK_E_CONF_EVT_CONF_INCOMING_IND,              /**< [en]Indicates conference incoming call indicate
                                                         [cn]会议来电通知。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                            data：  TSDK_S_CONF_INCOMING_INFO *incoming_info [en]Indicates conference incoming conf info.[cn]会议来电信息 */

    TSDK_E_CONF_EVT_CONF_END_IND,                   /**< [en]Indicates conference ending call indicate
                                                         [cn]会议结束通知。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  None */

    TSDK_E_CONF_EVT_JOIN_DATA_CONF_RESULT,          /**< [en]Indicates join data conf result.
                                                         [cn]加入数据会议结果。
                                                            param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2: TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_CONF_EVT_AS_SCREEN_DATA_UPDATE,          /**< [en]Indicates screen data update.
                                                         [cn]屏幕数据更新
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  None */

    TSDK_E_CONF_EVT_AS_OWNER_CHANGE,                /**< [en]Indicates the notice of app share owner change
                                                         [cn]屏幕共享权限拥有者变更通知
                                                            param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2: TSDK_UINT32 action_type [en]Indicates app share action type. refer to TSDK_E_CONF_AS_ACTION_TYPE.[cn]应用共享行为类型，取值参考TSDK_E_CONF_AS_ACTION_TYPE
                                                            data:   TSDK_S_ATTENDEE* owner [en]Indicates owner.[cn]拥有者*/
    //3015
    TSDK_E_CONF_EVT_AS_STATE_CHANGE,                /**< [en]Indicates the notice of app share state
                                                         [cn]屏幕共享状态变更通知
                                                            param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2: TSDK_UINT32 share_type [en]Indicates app share type. refer to TSDK_E_CONF_APP_SHARE_TYPE [cn]共享类型：屏幕或程序， 取值参考TSDK_E_CONF_APP_SHARE_TYPE
                                                            data:   TSDK_S_CONF_AS_STATE_INFO*s as_state_info [en]Indicates app share state info [cn]应用状态信息  */

    TSDK_E_CONF_EVT_RECV_CHAT_MSG,                  /**< [en]Indicates receive chat message notify in conf.
                                                         [cn]收到会议中的聊天消息通知。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_CONF_CHAT_MSG_INFO* chat_msg_info [en]Indicates chat message info.[cn]聊天信息 */

    TSDK_E_CONF_EVT_PRESENTER_GIVE_IND,             /**< [en]Indicates set presenter notify.
                                                         [cn]被设置为主讲人通知。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  None */

    TSDK_E_CONF_EVT_TRANS_TO_CONF_RESULT,           /**< [en]Indicates transport conference result.
                                                         [cn]转会议结果
                                                            param1：TSDK_UINT32 call_id [en]Indicates p2p call id.[cn]原点对点通话id
                                                            param2：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            data：  TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述 */

    TSDK_E_CONF_EVT_DS_DOC_LOAD_START,              /**< [en]Indicates notification of starting to load a document.
                                                         [cn]文档共享开始
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_BASE_INFO* doc_base_info [en]Indicates basic document information. [cn]文档基础信息.*/
    //3020
    TSDK_E_CONF_EVT_DS_DOC_NEW,                     /**< [en]Indicates create a new document.
                                                         [cn]新建一个共享文档
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_BASE_INFO* doc_base_info [en]Indicates basic document information. [cn]文档基础信息.*/

    TSDK_E_CONF_EVT_DS_DOC_PAGE_LOADED,             /**< [en]Indicates notification that a page is loaded.
                                                         [cn]成功加载一页
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* doc_page_info [en]Indicates document page information. [cn]文档页面信息.*/

    TSDK_E_CONF_EVT_DS_DOC_PAGE_NEW,                /**< [en]Indicates create a new page.
                                                         [cn]新建一页
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* doc_page_info [en]Indicates document page information. [cn]文档页面信息.*/

    TSDK_E_CONF_EVT_DS_DOC_LOAD_FINISH,             /**< [en]Indicates notification that a document is loaded.
                                                         [cn]加载文档结束
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            data：  TSDK_S_DOC_BASE_INFO* doc_base_info [en]Indicates basic document information. [cn]文档基础信息.*/

    TSDK_E_CONF_EVT_DS_DOC_PAGE_DEL,                /**< [en]Indicates delete a page.
                                                         [cn]删除一页
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* doc_page_info   [en]Indicates document page information. [cn]页面信息.*/
    //3025
    TSDK_E_CONF_EVT_DS_DOC_DEL,                     /**< [en]Indicates delete a document.
                                                         [cn]删除文档
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data:   TSDK_S_DOC_SHARE_DEL_DOC_INFO doc_del_info [en]Indicates document deletion information. [cn]文档删除信息. */

    TSDK_E_CONF_EVT_DS_DOC_CURRENT_PAGE,            /**< [en]Indicates notification that the current document or page changes.
                                                         [cn]同步翻页成功
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* doc_page_info [en]Indicates document page information. [cn]文档页面信息.*/

    TSDK_E_CONF_EVT_DS_DOC_CURRENT_PAGE_IND,        /**< [en]Indicates notification of synchronously turning pages.
                                                         [cn]同步翻页预先通知
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* doc_page_info [en]Indicates document page information. [cn]文档页面信息.*/

    TSDK_E_CONF_EVT_DS_DOC_DRAW_DATA_NOTIFY,        /**< [en]Indicates notification of updating the user interface.
                                                         [cn]文档界面数据
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* doc_page_info [en]Indicates document page information. [cn]文档页面信息.*/

    TSDK_E_CONF_EVT_DS_DOC_PAGE_DATA_DOWNLOAD,      /**< [en]Indicates notification that the data of document pages is downloaded.
                                                         [cn]文档页面数据下载完成
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* doc_page_info [en]Indicates document page information. [cn]文档页面信息.*/
    //3030
    TSDK_E_CONF_EVT_WB_DOC_NEW,                     /**< [en]Indicates create a whiteboard document.
                                                         [cn]新建一个白板文档
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_BASE_INFO* wb_doc_info [en]Indicates basic whiteboard information. [cn]白板基础信息.*/

    TSDK_E_CONF_EVT_WB_DOC_DEL,                     /**< [en]Indicates delete a whiteboard document.
                                                         [cn]删除一个白板文档
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_WB_DEL_DOC_INFO* wb_del_info [en]Indicates deleted whiteboard information. [cn]删除的白板信息.*/

    TSDK_E_CONF_EVT_WB_PAGE_NEW,                    /**< [en]Indicates create a whiteboard page.
                                                         [cn]新建一个白板页
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* wb_page_info [en]Indicates whiteboard page information. [cn]白板页面信息.*/

    TSDK_E_CONF_EVT_WB_PAGE_DEL,                    /**< [en]Indicates delete a whiteboard page.
                                                         [cn]删除一个白板页
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* wb_del_page_info [en]Indicates information about the deleted whiteboard. [cn]删除的白板页面信息.*/

    TSDK_E_CONF_EVT_WB_DOC_CURRENT_PAGE,            /**< [en]Indicates notification that the current document or page changes.
                                                         [cn]设置当前白板
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* wb_page_info [en]Indicates whiteboard page information. [cn]白板页面信息.*/
    //3035
    TSDK_E_CONF_EVT_WB_DOC_CURRENT_PAGE_IND,        /**< [en]Indicates notification of synchronously turning pages.
                                                         [cn]同步翻页预先通知
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* wb_page_info [en]Indicates whiteboard page information. [cn]白板页面信息.*/

    TSDK_E_CONF_EVT_WB_DOC_DRAW_DATA_NOTIFY,        /**< [en]Indicates notification of updating the user interface.
                                                         [cn]文档界面数据
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_DOC_PAGE_BASE_INFO* wb_page_info [en]Indicates whiteboard page information. [cn]白板页面信息.*/

    TSDK_E_CONF_EVT_SHARE_STATUS_UPDATE_IND,        /**< [en]Indicates notification of share ststus.
                                                         [cn]共享状态更新通知
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2: None
                                                            data：  TSDK_S_SHARE_STATUS_INFO* share_status_info [en]Indicates share ststus information. [cn]共享状态信息.*/

    TSDK_E_CONF_EVT_RECV_CUSTOM_DATA_IND,             /**< [en]Indicates notification of receiving a data message from a user
                                                          [cn]用户数据消息通知
                                                             param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                             param2：None
                                                             data：  TSDK_S_CONF_CUSTOM_DATA_INFO* data_info [en]Indicates user data message. [cn]用户数据消息. */
    TSDK_E_CONF_EVT_AS_SCREEN_KEYFRAME,             /**< [en]Indicates notification of share ststus.
                                                         [cn]共享关键帧通知
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2: None
                                                            data： None */

    //3040
    TSDK_E_CONF_EVT_AS_SCREEN_FIRST_KEYFRAME,       /**< [en]Indicates notification of share ststus.
                                                         [cn]共享首个关键帧通知
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2: None
                                                            data： None */
    
    TSDK_E_CONF_EVT_DATA_COMPONENT_LOAD_IND,        /**< [en]Indicates join data conf result.
                                                         [cn]数据会议功能组件加载通知。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：TSDK_UINT32 component_id [en]Indicates xxxx.[cn]数据会议功能组件ID
                                                            data: None */

    TSDK_E_CONF_EVT_CONF_BASE_INFO_IND,             /**< [en]Indicates query conference detail result.
                                                         [cn]当前会议基础信息通知
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_CONF_BASE_INFO *conf_base_info [en]Indicates conference base info.[cn]会议基础信息(自动查询成功时返回) */

    TSDK_E_CONF_EVT_AS_PRIVILEGE_CHANGE,            /**< [en]Indicates the notice of xxxxxx.
                                                         [cn]屏幕共享权限状态变更通知
                                                            param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data:   TSDK_S_CONF_AS_PRIVILEGE_INFO* as_privilege_info [en]Indicates app share privilege info [cn]共享权限信息  */

    TSDK_E_CONF_EVT_DATA_COMPT_TOKEN_MSG,           /**< [en]Indicates the notice of token.
                                                         [cn]令牌权限变更通知
                                                            param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data:   TSDK_S_CONF_TOKEN_MSG* token_info [en]Indicates token info [cn]令牌权限信息  */

    TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT,          /**< [en]notify VMR list request result.
                                                      [cn]请求vmr列表结果
                                                      param1: TSDK_UINT32 result [en]request result.[cn]请求结果
                                                      param2: None
                                                      data:   TSDK_S_VMR_INFO *vrm_list [en]vmr information list.[cn]vmr信息列表
                                                              TSDK_CHAR* reason_description[en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_CONF_EVT_SVC_WATCH_IND,                  /**< [en]Indicates video watch
                                                         [cn]视频观看指示。
                                                            param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data：  TSDK_S_SVC_REPORT_LIST_INFO* svc_report_info [en]Indicates svc watch info.[cn]多流视频观看信息 */

    TSDK_E_CONF_EVT_REQUEST_AUDIT_SITE_SWITCH_RESULT, /**< [en]Indicates the result of audit site switch report
                                                          <br>[cn]旁听会场切换单双向结果通知
                                                          <br>param1: TSDK_UINT32 handle   [en]Indicates handle of conference [cn]会控句柄
                                                          <br>param2：TSDK_UINT32 result   [en]Indicates operation result. 0 : success; 1 : failed. [cn]操作结果 0 :成功 1:失败
                                                          <br>data：  TSDK_UINT32* opration_type  [en]Indicates opration type. 0 : one way; 1 : two-way. [cn]请求类型 0: 切换为单向  1: 切换为双向*/

    TSDK_E_CONF_EVT_CANCEL_CONF_RESULT,                /**< [en]Indicates cancel book result
                                                          <br>[cn]SMC上报取消预约会议结果(3.0及以后版本)
                                                          <br>param1：TUP_UINT32 result  [en]Indicates result [cn]结果
                                                          <br>param2：None
                                                          <br>data：     None */ 
    TSDK_E_CONF_EVT_TIMEZONE_RESULT,                   /**<  [en]Indicates time zone list result
                                                         <br>[cn]查询时区列表(3.0及以后版本)
                                                         <br>param1：TSDK_UINT32 result  [en]Indicates result [cn]结果
                                                         <br>param2：None
                                                         <br>data：  TSDK_S_CONF_TIME_ZONE_LIST *time_zone_list [en]Indicates time zone list.[cn]时区列表信息 */
    TSDK_E_CONF_EVT_CHECKIN_RESULT,                    /**<  [en]Indicates checkin result
                                                             [cn]SMC上签到结果(3.0及以后版本)。
                                                              param1：TSDK_UINT32 result  [en]Indicates result [cn]结果
                                                              param2：None
                                                              data：  None */
    TSDK_E_CONF_EVT_SVC_WATCH_POLICY_IND,              /**<  [en]Indicates svc watch policy
                                                             [cn]大会议模式上报
                                                              param1：TSDK_UINT32 policy  [en]Indicates policy [cn]模式
                                                              param2：None
                                                              data：  None */
    TSDK_E_CONF_EVT_VMR_CHANGEED_RESULT,               /**< [en]Indicates the notice of update vmr info.
                                                            [cn]修改VMR信息返回事件
                                                            param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]请求结果
                                                            param2: None
                                                            data:   None  */
    TSDK_E_CONF_EVT_HAND_UP_IND,                        /**< [en]Indicates the notice of hand up.
                                                             [cn]举手事件通知
                                                           param1: TSDK_UINT32 handle [en]Indicates handle.[cn]会场句柄
                                                           param2: None
                                                           data:   TSDK_S_ATTENDEE *attendee [en]Indicates attendee.[cn] 与会者*/
    TSDK_E_CONF_EVT_AUXTOKEN_OWNER_IND,                 /**< [en]Indicates aux token indicate
                                                             [cn]辅流令牌指示
                                                             param1：TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                             param2：None
                                                             data:   TSDK_S_ATTENDEE *attendee [en]Indicates attendee.[cn] 与会者*/
    TSDK_E_CONF_EVT_BROADCAST_IND,                      /**< [en]Indicates the notice of broadcast.
                                                             [cn]广播事件通知
                                                             param1: TSDK_BOOL isBroadcast [en]Indicates broadcast status.[cn]广播标识
                                                             param2: None.
                                                             data: TSDK_S_ATTENDEE *attendee [en]Indicates attendee.[cn] 与会者*/
// 需要添加 js回调函数的事件  需要在 上面按顺序 添加事件    不需要添加 js回调事件的 在下面添加

    TSDK_E_CONF_EVT_ATTENDEE_INFO_UPDATE,           /**< [en]Indicates the attendee information.
                                                         [cn]与会者信息更新通知
                                                            param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                            param2：None
                                                            data:   TSDK_S_ATTENDEE_EX* attendee [en]Indicates attendee info [cn]与会者信息  */

    TSDK_E_CONF_EVT_INVITE_USER_DATA_SHARING,        /**< [en]Indicates ***.
                                                         [cn]邀请共享通知
                                                         param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                         param2: TSDK_E_CONF_AS_ACTION_TYPE [en]***. [cn] 邀请共享&结束邀请共享
                                                         data： TSDK_S_ATTENDEE *  [en]***. [cn] 发出邀请共享邀请的与会者信息*/

    TSDK_E_CONF_EVT_PHONE_VIDEO_CAPABLE_IND,         /**< [en]Indicates ***.
                                                          [cn]电话能力更新
                                                          param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                          param2: None
                                                          data： TSDK_BOOL *  [en]whether has the secondary stream token. [cn] 是否拥有辅流令牌*/

    TSDK_E_CONF_EVT_UPDATE_SHARE_MSG,               /**< [en]Indicates the notice of share type.
                                                         [cn]共享类型更新通知
                                                         param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                         param2：None
                                                         data:   TSDK_S_CONF_TOKEN_MSG* token_info [en]Indicates token info [cn]令牌权限信息  */

    TSDK_E_CONF_EVT_AS_AUX_DEC_FRIST_FRAME,       /**< [en]notify aux flow decode first frame
                                                       [cn]辅流解码第一帧成功的通知 
                                                          param1: TSDK_UINT32 handle [en]Indicates conference control handle.[cn]会控句柄
                                                          param2: None
                                                          data:   None */ 

    TSDK_E_CONF_EVT_CONF_BUTT = 3999,

    TSDK_E_MAINTAIN_EVT_MAINTAIN_BEGIN = 4000,

    TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT,               /**< [en]Indicates log upload result
                                                              <br>[cn]日志上传结果(3.0及以后版本)
                                                              <br>param1：TUP_UINT32 result  [en]Indicates result [cn]结果
                                                              <br>param2：None
                                                              <br>data：  None */
    TSDK_E_MAINTAIN_EVT_SOFTTERMINAL_DOWNLOAD_INFO_IND,  /**< [en]Indicates tsdk_get_softterminal_download_info
                                                              <br>[cn]查询软终端下载信息结果(3.0及以后版本)
                                                              <br>param1：TUP_UINT32 result  [en]Indicates result [cn]结果
                                                              <br>param2：None
                                                              <br>data：  TSDK_SMC_S_SOFTTERMINAL_DOWNLOAD_INFO */
    TSDK_E_MAINTAIN_EVT_MAINTAIN_BUTT = 4999,


    TSDK_E_EADDR_EVT_EADDR_BEGIN = 5000,

    TSDK_E_EADDR_EVT_SEARCH_CONTACTS_RESULT,        /**< [en]Indicates the search contacts result.
                                                         [cn]查询联系人结果
                                                            param1：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            param2：TSDK_UINT32 seq_no [en]Indicates sequence number.[cn]查询序号
                                                            data：  TSDK_S_SEARCH_CONTACTS_RESULT* search_contact_result [en]Indicates result of searching contactor.[cn]联系人搜索结果(成功时返回)
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_EADDR_EVT_SEARCH_DEPT_RESULT,            /**< [en]Indicates the search department result.
                                                         [cn]查询部门结果
                                                            param1：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            param2：TSDK_UINT32 seq_no [en]Indicates sequence number.[cn]查询序号
                                                            data：  TSDK_S_SEARCH_DEPARTMENT_RESULT* search_dept_result [en]Indicates result of searching department.[cn]部门查询结果(成功时返回)
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */

    TSDK_E_EADDR_EVT_GET_ICON_RESULT,               /**< [en]Indicates the get icon result.
                                                         [cn]获取头像结果
                                                            param1：TSDK_UINT32 result [en]Indicates operation result.[cn]操作结果
                                                            param2：TSDK_UINT32 seq_no [en]Indicates sequence number.[cn]查询序号
                                                            data：  TSDK_S_GET_ICON_RESULT* get_icon_result [en]Indicates result of getting user icon.[cn]头像查询结果
                                                                    TSDK_CHAR* reason_description [en]Indicates error reason description.[cn]错误原因描述(失败时返回) */
    TSDK_E_EADDR_EVT_EADDR_BUTT = 5999,


    TSDK_E_IM_EVT_IM_BEGIN = 6000,

    TSDK_E_IM_EVT_ADD_FRIEND_IND,                   /**< [en]Indicates notification of being added as a friend.
                                                         [cn]被其他用户加为好友通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_BE_ADDED_FRIEND_INFO* be_added_friend_info [en]Indicates notification of being added as a friend.[cn]被加为好友通知信息 */

    TSDK_E_IM_EVT_USER_STATUS_UPDATE,               /**< [en]Indicates friend status update notification.
                                                         [cn]好友状态更新通知
                                                             param1：None
                                                             param2：TSDK_UINT32 count [en]Indicates number of friend status update messages.[cn]好友状态更新信息数
                                                             data：  TSDK_S_IM_USER_STATUS_UPDATE_INFO* user_status_info_list [en]Indicates friend status update information.[cn]好友状态更新信息列表 */

    TSDK_E_IM_EVT_USER_INFO_UPDATE,                 /**< [en]Indicates User (friend) information update notification
                                                         [cn]用户(好友)信息更新通知
                                                             param1：None
                                                             param2：TSDK_UINT32 count [en]Indicates number of user (friend) information update messages.[cn]用户(好友)信息数
                                                             data：  TSDK_S_IM_USER_INFO *user_info_list [en]Indicates user(friend) information list.[cn]用户(好友)信息列表 */

    TSDK_E_IM_EVT_JOIN_CHAT_GROUP_REQ,              /**< [en]Indicates request for joining a chat group or inviting a user to a chat group
                                                         [cn]收到邀请加入或申请加入聊天群组的请求
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_REQ_JOIN_CHAT_GROUP_MSG* req_join_group_msg [en]Indicates request for joining a chat group or inviting a user to a chat group.[cn]请求加入(邀请加入或申请加入)聊天群组消息 */

    TSDK_E_IM_EVT_JOIN_CHAT_GROUP_RSP,              /**< [en]Indicates response for joining a chat group or inviting a user to a chat group
                                                         [cn]邀请加入或申请加入聊天群组的响应
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_RSP_JOIN_CHAT_GROUP_MSG* rsp_join_group_msg [en]Indicates response for joining a chat group or inviting a user to a chat group (received by the group administrator or invited user).[cn]加入(邀请加入或申请加入)聊天群组响应消息(群组管理员或被邀请人收到) */
    //6
    TSDK_E_IM_EVT_JOIN_CHAT_GROUP_IND,              /**< [en]Indicates notification of being added to a chat group
                                                         [cn]被加入聊天群组通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_BE_ADDED_TO_CHAT_GROUP_INFO* be_added_info [en]Indicates notification of being added to a chat group.[cn]被加入聊天群组通知信息 */

    TSDK_E_IM_EVT_DEL_CHAT_GROUP_MEMBER_RESULT,     /**< [en]Indicates result of deleting group members
                                                         [cn]删除群组成员结果
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_DEL_CHAT_GROUP_MEMBER_RESULT* del_member_result [en]Indicates result of deleting group members.[cn]删除群组成员结果信息 */

    TSDK_E_IM_EVT_LEAVE_CHAT_GROUP_RESULT,          /**< [en]Indicates result of leaving a chat group
                                                         [cn]离开聊天群组结果
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_LEAVE_CHAT_GROUP_RESULT* leave_group_result [en]Indicates result of leaving a chat group.[cn]离开聊天群组结果信息 */

    TSDK_E_IM_EVT_CHAT_GROUP_INFO_UPDATE,           /**< [en]Indicates group information update notification
                                                         [cn]群组信息更新通知
                                                             param1：None
                                                             param2：TSDK_UINT32 update_type [en]Indicates information update type.[cn]信息更新类型，取值参考: TSDK_E_CHAT_GROUP_INFO_UPDATE_TYPE
                                                             data：  TSDK_S_CHAT_GROUP_UPDATE_INFO* group_update_info [en]Indicates group information update.[cn]群组信息更新信息 */

    TSDK_E_IM_EVT_INPUTTING_STATUS_IND,             /**< [en]Indicates input status notification
                                                         [cn]输入状态信息通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_INPUTTING_STATUS_INFO* inputting_status_info [en]Indicates input status information.[cn]输入状态信息 */
    //11
    TSDK_E_IM_EVT_CHAT_MSG,                         /**< [en]Indicates notification of receiving a message
                                                         [cn]新消息通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_CHAT_MSG_INFO* chat_msg [en]Indicates new message received.[cn]收到的新消息 */

    TSDK_E_IM_EVT_BATCH_CHAT_MSG,                   /**< [en]Indicates notification of receiving messages in batches
                                                         [cn]批量新消息通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_BATCH_CHAT_MSG_INFO* batch_chat_msg [en]Indicates messages received in batches.[cn]收到的批量消息 */

    TSDK_E_IM_EVT_SYSTEM_BULLETIN,                   /**< [en]Indicates notification of system bulletin
                                                         [cn]系统公告通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_CHAT_MSG_INFO* system_bulletin [en]Indicates information for system bulletin.[cn]系统公告信息 */

    TSDK_E_IM_EVT_SMS,                              /**< [en]Indicates notification of receiving a sms
                                                         [cn]短信通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_SMS_INFO* sms_info [en]Indicates SMS information.[cn]短信信息 */

    TSDK_E_IM_EVT_UNDELIVER_IND,                    /**< [en]Indicates notification of a message is undelivered.
                                                         [cn]消息未送达通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_CHAT_MSG_UNDELIVER_INFO* msg_undeliver_info [en]Indicates information for message is undelivered .[cn]消息未送达信息 */
    //16
    TSDK_E_IM_EVT_MSG_READ_IND,                     /**< [en]Indicates notification of a message is read.
                                                         [cn]消息已读通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_MSG_READ_IND_INFO* msg_read_ind_info [en]Indicates information for message is read.[cn]消息已读通知信息 */

    TSDK_E_IM_EVT_MSG_SEND_RESULT,                  /**< [en]Indicates result of sending a chat message.
                                                         [cn]聊天消息发送结果通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_SEND_CHAT_MSG_RESULT* send_msg_result [en]Indicates result of sending a chat message.[cn]聊天消息发送结果信息 */


    TSDK_E_IM_EVT_MSG_WITHDRAW_RESULT,              /**< [en]Indicates result of withdrawing messages.
                                                         [cn]消息撤回结果
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_CHAT_MSG_WITHDRAW_RESULT* withdraw_msg_result [en]Indicates result of withdrawing messages.[cn]消息撤回结果信息 */

    TSDK_E_IM_EVT_MSG_WITHDRAW_IND,                 /**< [en]Indicates notification of a message is withdrawn.
                                                         [cn]消息撤回通知
                                                             param1：None
                                                             param2：None
                                                             data：  TSDK_S_CHAT_MSG_WITHDRAW_INFO* withdraw_msg_info [en]Indicates information for message is withdrawn.[cn]消息撤回通知信息 */

    TSDK_E_IM_EVT_IM_BUTT = 6999,


    TSDK_E_LDAP_FRONTSTAGE_EVT_LDAP_FRONTSTAGE_BEGIN = 7000,

    TSDK_E_LDAP_FRONTSTAGE_EVT_SEARCH_RESULT,                 /**< [en]Indicates notification of get search result.
                                                              [cn]查询结果通知
                                                              param1：TSDK_UINT32 resultCode
                                                              param2：None
                                                              data：  TSDK_S_LDAP_SEARCH_RESULT_INFO *search_result_info [en]Indicates search result message.[cn]查询结果通知信息 */
    TSDK_E_LDAP_FRONTSTAGE_EVT_START_SERVICE_RESULT,          /**< [en]notify notification of get start service result
                                                              [cn]LDAP启动结果的通知
                                                              param1: TSDK_UINT32 result 
                                                              param2: None
                                                              data:   None */
    TSDK_E_LDAP_FRONTSTAGE_EVT_LDAP_FRONTSTAGE_BUTT = 7999,



    TSDK_E_UI_PLUGIN_EVT_BEGIN = 10000,

    TSDK_E_UI_PLUGIN_EVT_FRAME_HWND_INFO_UPDATE,    /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件Frame和window句柄信息更新
                                                             param1: None
                                                             param2: None
                                                             data：  TSDK_S_UI_PLUGIN_FRAME_HWND_INFO* frame_hwnd_info [en]xxxx.[cn]UI插件Frame句柄信息  */


    TSDK_E_UI_PLUGIN_EVT_WINDOW_FOCUS,              /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件“聚焦插件窗口”事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_PLUGIN_WND_FOCUS_INFO  window_focus_info  [en]xxxx.[cn]聚焦窗口信息 */

    TSDK_E_UI_PLUGIN_EVT_SET_WINDOW_SIZE,           /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件“设置插件窗口大小”事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_PLUGIN_WND_SIZE_INFO window_size [en]xxxx.[cn]插件窗口大小信息 */

    TSDK_E_UI_PLUGIN_EVT_QUERY_USERINFO,            /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件“查询当前窗口用户信息”事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_QUERY_USER_INFO user_info [en]xxxx.[cn]用户信息 */

    TSDK_E_UI_PLUGIN_EVT_CPU_RATE_INFO,            /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件“CPU使用率”统计信息
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_CPU_RATE cpu_rate [en]xxxx.[cn]CPU使用率 */

    TSDK_E_UI_PLUGIN_EVT_CLICK_HANGUP_CALL,         /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“挂断呼叫”按钮事件
                                                             param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_MUTE_MIC,            /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“闭音麦克风”按钮事件
                                                             param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_MIC_BUTTON_STATE_INFO  mic_state [en]xxxx.[cn]麦克风按钮状态信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_MUTE_SPEAKER,        /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“闭音扬声器”按钮事件
                                                             param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_SPEAKER_BUTTON_STATE_INFO  speaker_state [en]xxxx.[cn]扬声器按钮状态信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_MUTE_CAMERA,         /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“关闭摄像头”按钮事件
                                                             param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_CAMERA_BUTTON_STATE_INFO  camera_state [en]xxxx.[cn]摄像头按钮状态信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_ADD_MEMBER,          /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“增加与会者”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_COORDINATES_AND_SIZE_INFO  frame_coordinate_info [en]xxxx.[cn]坐标及大小信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_SHOW_MEMBER_LIST,    /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“显示与会者列表”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_COORDINATES_AND_SIZE_INFO frame_coordinate_info [en]xxxx.[cn]坐标及大小信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_TRANS_AUDIO,         /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“转音频”按钮事件
                                                             param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_SEND_IM,             /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“发送即时消息”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_DEVICES_SETTING,     /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“设备设置”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CONF_CTRL_OPERATION,            /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件对指定窗口进行“会控操作”事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_CONF_CTRL_OPERATION conf_ctrl_operation [en]xxxx.[cn]会控操作信息 */

    TSDK_E_UI_PLUGIN_EVT_CLICK_SET_LAYOUT,          /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“设置布局类型”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_FRAME_LAYOUT_INFO layout_type [en]xxxx.[cn]布局信息 */

    TSDK_E_UI_PLUGIN_EVT_CLICK_PAGE_SWITCH,         /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“翻页”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_PAGE_SWITCH_INFO page_switch [en]xxxx.[cn]页面切换信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_WATCH_ATTENDEE,      /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“选看”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_WATCH_ATTENDEE watch_attendee [en]xxxx.[cn]选看窗口信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_CHAIRMAN_OPERATION,  /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“申请/释放主席”按钮事件
                                                             param1: TSDK_UINT32 handle [en]Indicates xxxxx.[cn]会议句柄
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_CHAIRMAN_OPERATION  chairman_operation_info [en]xxxx.[cn]申请或释放主席*/

    //TSDK_E_UI_PLUGIN_EVT_CLICK_SHOW_QOS,          /**< [en]Indicates xxxxxxxxxxx.
    //                                                     [cn]UI插件点击“显示QOS”按钮事件
    //                                                         param1: None
    //                                                         param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
    //                                                         data:   TSDK_S_UI_SHOW_QOS_INFO qos_info [en]xxxx.[cn]Qos信息 */


    //TSDK_E_UI_PLUGIN_EVT_CLICK_ACTIVE_BIDIRECTION,        /**< [en]Indicates xxxxxxxxxxx.
    //                                                     [cn]UI插件“主动切换单双向”事件
    //                                                         param1: None
    //                                                         param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
    //                                                         data:   TSDK_S_UI_ACTIVE_BIDIRECTION active_bidirection [en]xxxx.[cn]主动切换单双向信息*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_CONF_RECORDING,      /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“开启或者关闭会议录制”事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_NOTIFY_CONF_RECORDING conf_recording [en]xxxx.[cn]会议录制信息 */

    //TSDK_E_UI_PLUGIN_EVT_CLICK_SET_PAINT_PROP,       /**< [en]Indicates xxxxxxxxxxx.
    //                                                     [cn]UI插件点击“设置绘画属性”按钮事件
    //                                                         param1: None
    //                                                         param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
    //                                                         data:   TSDK_S_UI_PAINT_PROP paint_property [en]xxxx.[cn]绘画属性 */

    TSDK_E_UI_PLUGIN_EVT_CLICK_SET_SHARE_QUALITY,     /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“设置共享质量”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_SHARE_QUALITY share_quality [en]xxxx.[cn]共享质量*/

    TSDK_E_UI_PLUGIN_EVT_CLICK_SHOW_REMOTE_CONTROL,   /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件“显示远程控制”事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_REQUEST_REMOTE_CONTROL, /**< [en]Indicates xxxxxxxxxxx.
                                                              [cn]UI插件点击“申请远程控制”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_RELEASE_REMOTE_CONTROL, /**< [en]Indicates xxxxxxxxxxx.
                                                              [cn]UI插件点击“释放远程控制”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_GRANT_REMOTE_CONTROL, /**< [en]Indicates xxxxxxxxxxx.
                                                            [cn]UI插件点击“授予远程控制”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */


    TSDK_E_UI_PLUGIN_EVT_CLICK_START_SHARE,          /**< [en]Indicates xxxxxxxxxxx.
                                                          [cn]UI插件点击“开始共享”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_SHARE_INFO share_info [en]Indicates share information.[cn]共享信息 */

    TSDK_E_UI_PLUGIN_EVT_CLICK_STOP_SHARE,          /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件点击“停止共享”事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    //TSDK_E_UI_PLUGIN_EVT_CLICK_SHOW_WINDOW,          /**< [en]Indicates xxxxxxxxxxx.
    //                                                      [cn]UI插件点击“显示窗口”事件
    //                                                         param1: None
    //                                                         param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
    //                                                         data:   TSDK_S_UI_SHOW_WINDOW  */

    //TSDK_E_UI_PLUGIN_EVT_CLICK_SET_SPEAKER,          /**< [en]Indicates xxxxxxxxxxx.
    //                                                      [cn]UI插件点击“设置扬声器”按钮事件
    //                                                         param1: None
    //                                                         param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
    //                                                         data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_LEAVE_CONF,            /**< [en]Indicates xxxxxxxxxxx.
                                                           [cn]UI插件点击“离开会议”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_END_CONF,              /**< [en]Indicates xxxxxxxxxxx.
                                                           [cn]UI插件点击“结束会议”按钮事件
                                                             param1: None
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   None  */

    TSDK_E_UI_PLUGIN_EVT_CLICK_VIDEO_DIAL,          /**< [en]Indicates xxxxxxxxxxx.
                                                         [cn]UI插件二次拨号事件
                                                             param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                             param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                             data:   TSDK_S_UI_DIAL_PAD dial_pad [en]Indicates xxx.[cn]二次拨号信息*/

    TSDK_E_UI_PLUGIN_START_SHARE_FAILED,          /**< [en]Indicates xxxxxxxxxxx.
                                                        [cn]UI插件开始共享失败事件
                                                        param1: TSDK_UINT32 fail_reason [en]Indicates fail reason code.[cn]开始共享失败的错误码
                                                        param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                        data:  None */

    TSDK_E_UI_PLUGIN_EVT_CLICK_TRANS_VIDEO,         /**< [en]Indicates xxxxxxxxxxx.
                                                        [cn]UI插件点击“转视频”按钮事件
                                                        param1: TSDK_UINT32 call_id [en]Indicates call id.[cn]呼叫ID
                                                        param2: TSDK_UINT32 further_process_type [en]Indicates xxxxx.[cn]应用程序进一步处理类型, 取值参考: TSDK_E_FURTHER_PROCESS_TYPE.
                                                        data:   None  */
    TSDK_E_UI_PLUGIN_EVT_BUTT = 10999,


    TSDK_E_EVENT_BUTT

}TSDK_E_EVENT;



/**
 * [en]This enumeration is about config param id
 * [cn]设置参数
 */
typedef enum tagTSDK_E_CONFIG_ID
{
    TSDK_E_CONFIG_LOG_PARAM,                        /**< [en]Indicates set the log parameters, before initialization, the corresponding data type is TSDK_S_LOG_PARAM *.
                                                         [cn]设置日志参数，初始化前设置，对应的数据类型为:TSDK_S_LOG_PARAM *. */
    TSDK_E_CONFIG_TLS_PARAM,                        /**< [en]Indicates set TLS parameters, it should config before initialization, the corresponding data type is TSDK_S_TLS_PARAM *.
                                                         [cn]设置TLS参数，初始化前设置，对应的数据类型为:TSDK_S_TLS_PARAM *. */
    TSDK_E_CONFIG_SECURITY_PARAM,                   /**< [en]Indicates set up business Security configuration parameters, it should config before login, corresponding data types is TSDK_S_SERVICE_SECURITY_PARAM *.
                                                         [cn]设置业务安全配置参数，登录前设置，对应的数据类型为:TSDK_S_SERVICE_SECURITY_PARAM *. */
    TSDK_E_CONFIG_LOCAL_ADDRESS,                    /**< [en]Indicates set local ip address params, it should config before login, the corresponding data type is TSDK_S_LOCAL_ADDRESS *.
                                                         [cn]设置本地ip地址，登录前设置，对应的数据类型为:TSDK_S_LOCAL_ADDRESS *. */
    TSDK_E_CONFIG_APP_FILE_PATH_INFO,               /**< [en]Indicates set application file path info, it should config before initialization, corresponding struct is:TSDK_S_APP_FILE_PATH_INFO *.
                                                         [cn]设置应用程序文件路径信息，初始化前设置，对应的数据类型为:TSDK_S_APP_FILE_PATH_INFO *. */
    TSDK_E_CONFIG_NETWORK_INFO,                     /**< [en]Indicates set network information parameters, it should config before login, the corresponding data type is TSDK_S_NETWORK_INFO_PARAM *.
                                                         [cn]设置网络信息参数，登录前设置，对应的数据类型为:TSDK_S_NETWORK_INFO_PARAM *. */
    TSDK_E_CONFIG_IPCALL_SWITCH,                    /**< [en]Indicates switch of ip call, it should config after configing local address, corresponding struct is:TSDK_BOOL *.
                                                         [cn]设置IP呼叫开关，配置本地地址后设置，对应的数据结构为:TSDK_BOOL * */
    TSDK_E_CONFIG_DATA_CONF_SEND_DATA_SWITCH,       /**< [en]Indicates switch of sending data in data conference.
                                                         [cn]设置数据会议通用消息通道发送数据开关，对应的数据结构为:TSDK_BOOL * */
    TSDK_E_CONFIG_WINDOWS_UI_PLUGIN_BASE_INFO,      /**< [en]Indicates xxxxxx.
                                                         [cn]设置Windows平台UI插件基础信息，登录前设置，对应的数据结构为:TSDK_S_UI_PLUGIN_BASE_INFO *. */
    TSDK_E_CONFIG_WINDOWS_UI_PLUGIN_FRAME_PARAM,    /**< [en]Indicates xxxxxx.
                                                         [cn]设置Windows平台UI插件Frame参数，登录前设置，对应的数据结构为:TSDK_S_UI_PLUGIN_FRAME_PARAM *. */
    TSDK_E_CONFIG_WINDOWS_UI_PLUGIN_VISIBLE_INFO,   /**< [en]Indicates Set the visible information of the Windows platform UI plug-in button.set before login, the corresponding data structure is:TSDK_S_UI_PLUGIN_WINDOW_VISIBLE_INFO.
                                                         [cn]设置Windows平台UI插件按钮可见信息，登录前设置，对应的数据结构为:TSDK_S_UI_PLUGIN_WINDOW_VISIBLE_INFO *. */
    TSDK_E_CONFIG_CALL_D_CFG_SIP_ANONYMOUSNUM,      /**< [en]Indicates Set the anonymous number.set before login, the corresponding data structure is:TSDK_CHAR.
                                                         [cn]设置匿名呼叫号码，登录前设置，对应的数据类型为:TSDK_CHAR * */
    TSDK_E_CONFIG_CALL_D_CFG_SERVER_REG_ADDRESS,    /**< [en]Indicates Set the server reg address.set before login, the corresponding data structure is:TSDK_S_SERVER_REGL_ADDRESS.
                                                         [cn]设置呼叫注册主服务器，登录前设置，对应的数据结构为:TSDK_S_SERVER_REGL_ADDRESS * */
    TSDK_E_CONFIG_CALL_D_CFG_SIP_PORT,              /**< [en]Indicates Set the SIP port.set before login, the corresponding data structure is:TSDK_S_UI_PLUGIN_WINDOW_VISIBLE_INFO.
                                                         [cn]设置SIP端口，登录前设置，对应的数据为:TSDK_UINT16 * */
    TSDK_E_CONFIG_CALL_D_CFG_VIDEO_TACTIC,          /**< [en]Indicates Set the video play tactic.
                                                         [cn]设置视频播放策略，对应数据为 :TSDK_UINT32 * */
    TSDK_E_CONFIG_SIP_SESSIONTIME_PARAM,            /**< [en]Indicates the sip session time length.
                                                         [cn]设置会议保活Update时长, 对应数据为: TsdkCallSipSessionTimeParam *. */
    TSDK_E_CONFIG_CONF_TERMINAL_LOCAL_NAME,         /**< [en]Indicates the terminal lacal name length.
                                                         [cn]设置会议中终端别名, 对应数据为: TSDK_S_TERMINAL_LOCAL_NAME *. */
    TSDK_E_CONFIG_AUDIO_ADVANCE_PARAM,              /**< [en]Indicates the audio advance param,
                                                             the corresponding data structure is:TsdkAudioAdvanceParam
                                                         [cn]设置音频高级配置，对应的数据结构：TsdkAudioAdvanceParam* */
    TSDK_E_CONFIG_BUTT
}TSDK_E_CONFIG_ID;




/**
 * [en]This enumeration is used to describe the log level
 * [cn]日志级别
 */
typedef enum tagTSDK_E_LOG_LEVEL
{
    TSDK_E_LOG_ERROR = 0,                           /**< [en]Indicates the error level
                                                         [cn]错误级别 */
    TSDK_E_LOG_WARNING,                             /**< [en]Indicates the warning level
                                                         [cn]警告级别 */
    TSDK_E_LOG_INFO,                                /**< [en]Indicates the info level
                                                         [cn]信息(一般)级别 */
    TSDK_E_LOG_DEBUG                                /**< [en]Indicates the debug level
                                                         [cn]调试级别 */
}TSDK_E_LOG_LEVEL;


/**
 * [en]This enumeration is used to describe client type.
 * [cn]客户端类型
 */
typedef enum tagTSDK_E_CLIENT_TYPE
{
    TSDK_E_CLIENT_PC          = 0,                  /**< [en]Indicates EC PC
                                                         [cn]EC PC终端 */
    TSDK_E_CLIENT_MOBILE      = 1,                  /**< [en]Indicates mobile
                                                         [cn]EC 移动客户端 */
    TSDK_E_CLIENT_BUTT
}TSDK_E_CLIENT_TYPE;


/**
 * [en]This enumeration is used to describe the signaling transport mode.
 * [cn]SIP信令传输模式(若选择设置，则需初始化后登录前设置)
 */
typedef enum tagTSDK_E_SIP_TRANSPORT_MODE
{
    TSDK_E_SIP_TRANSPORT_UDP,                       /**< [en]Indicates UDP
                                                         [cn]UDP */
    TSDK_E_SIP_TRANSPORT_TLS,                       /**< [en]Indicates TLS
                                                         [cn]TLS */
    TSDK_E_SIP_TRANSPORT_TCP,                       /**< [en]Indicates TCP
                                                         [cn]TCP */
    TSDK_E_SIP_TRANSPORT_BUTT
} TSDK_E_SIP_TRANSPORT_MODE;

/**
* [en]This enumeration is used to describe the bfcp transport mode.
* [cn]BFCP消息传输模式(若选择设置，则需初始化后登录前设置)
*/
typedef enum tagTSDK_E_BFCP_TRANSPORT_MODE
{
    TSDK_E_BFCP_TRANSPORT_UDP = 1,                  /**< [en]Indicates UDP
                                                         [cn]UDP */
    TSDK_E_BFCP_TRANSPORT_TCP = 2,                  /**< [en]Indicates TCP
                                                         [cn]TCP */
    TSDK_E_BFCP_TRANSPORT_TLS = 4,                  /**< [en]Indicates TLS, default value
                                                         [cn]TLS,默认值 */
    TSDK_E_BFCP_TRANSPORT_AUTO = 7,                 /**< [en]Indicates Automatic transmission
                                                             mode selection
                                                         [cn]自动选择传输模式 */
    TSDK_E_BFCP_TRANSPORT_BUTT
} TSDK_E_BFCP_TRANSPORT_MODE;

/**
 * [en]This enumeration is used to describe SRTP mode.
 * [cn]SRTP模式
 */
typedef enum tagTSDK_E_MEDIA_SRTP_MODE
{
    TSDK_E_MEDIA_SRTP_MODE_DISABLE,                 /**< [en]Indicates disable
                                                         [cn]不启用 */
    TSDK_E_MEDIA_SRTP_MODE_OPTION,                  /**< [en]Indicates optional
                                                         [cn]可选 */
    TSDK_E_MEDIA_SRTP_MODE_FORCE,                   /**< [en]Indicates force
                                                         [cn]强制 */
    TSDK_E_MEDIA_SRTP_MODE_BUTT
}TSDK_E_MEDIA_SRTP_MODE;


/**
 * [en]This enumeration is used to describe security tunnel usage mode.
 * [cn]安全隧道使用模式
 */
typedef enum tagTSDK_E_SECURITY_TUNNEL_MODE
{
    TSDK_E_SECURITY_TUNNEL_MODE_DEFAULT,            /**< [en]Indicates default mode, judge according to system push.
                                                         [cn]默认，根据系统推送自动判别 */
    TSDK_E_SECURITY_TUNNEL_MODE_DISABLE,            /**< [en]Indicates disable mode
                                                         [cn]不启用 */
    TSDK_E_SECURITY_TUNNEL_MODE_FORCE,              /**< [en]Indicates force mode, force to use.
                                                         [cn]强制使用 */
    TSDK_E_SECURITY_TUNNEL_MODE_BUTT
}TSDK_E_SECURITY_TUNNEL_MODE;


/**
 * [en]This enum is used to describe conference enviroment type.
 * [cn]会议环境类型
 */
typedef enum tagTSDK_E_CONF_ENV_TYPE
{
    TSDK_E_CONF_ENV_HOSTED_CONVERGENT_CONFERENCE,     /**< [en]Indicates Hosted convergent conference
                                                           [cn]Hosted 融合会议*/
    TSDK_E_CONF_ENV_ON_PREMISES_CONVERGENT_CONFERENCE,/**< [en]Indicates On-Premises convergent conference
                                                           [cn]On-Premises 融合会议*/
    TSDK_E_CONF_ENV_HOSTED_CONFERENCING_ONLY,         /**< [en][Reserved, not support at present]Indicates pure Hosted conference
                                                           [cn][预留，暂不支持]Hosted 纯会议 */
    TSDK_E_CONF_ENV_ON_PREMISES_CONFERENCING_ONLY,    /**< [en][Reserved, not support at present]Indicates pure On-Premises conference
                                                           [cn][预留，暂不支持]On-Premises 纯会议 */
    TSDK_E_CONF_ENV_ON_PREMISES_IPT,                  /**< [en][Reserved, not support at present]Indicates enterprise premises ipt
                                                           [cn][预留，暂不支持]企业入驻式，IPT */
    TSDK_E_CONF_ENV_BUTT
}TSDK_E_CONF_ENV_TYPE;



/**
 * [en]This enumeration is used to describe language type.
 * [cn]语言类型
 */
typedef enum tagTSDK_E_LANGUAGE_TYPE
{
    TSDK_E_LANGUAGE_ZH,                       /**< [en]Indicates Chinese.
                                                   [cn]中文 */
    TSDK_E_LANGUAGE_EN,                       /**< [en]Indicates English.
                                                   [cn]英语 */
    TSDK_E_LANGUAGE_PT,                       /**< [en]Indicates Portuguese.
                                                   [cn]葡萄牙语 */
    TSDK_E_LANGUAGE_FR,                       /**< [en]Indicates French.
                                                   [cn]法语 */
    TSDK_E_LANGUAGE_RU,                       /**< [en]Indicates Russian.
                                                   [cn]俄语 */
    TSDK_E_LANGUAGE_TR,                       /**< [en]Indicates Turkey.
                                                   [cn]土耳其语 */
    TSDK_E_LANGUAGE_PL,                       /**< [en]Indicates Polish.
                                                   [cn]波兰语 */
    TSDK_E_LANGUAGE_BUTT
}TSDK_E_LANGUAGE_TYPE;


/**
 * [en]This enumeration is used to describe Apple push server environment type.
 * [cn]苹果推送服务器环境类型
 */
typedef enum tagTSDK_E_APNS_ENV_TYPE
{
    TSDK_E_APNS_PRODUCTION_ENV = 1,         /**< [en]Indicates production environment.
                                                 [cn]生产环境 */
    TSDK_E_APNS_TEST_ENV,                   /**< [en]Indicates test environment.
                                                 [cn]测试环境 */
    TSDK_E_APNS_ENV_BUTT
}TSDK_E_APNS_ENV_TYPE;


/**
 * [en]This enumeration is used to describe Apple push service certificate type.
 * [cn]苹果推送服务证书类型
 */
typedef enum tagTSDK_E_APNS_CRET_TYPE
{
    TSDK_E_APNS_CRET_1 = 1,                 /**< [en]Indicates certificate type 1.
                                                 [cn]证书类型1 */
    TSDK_E_APNS_CRET_2,                     /**< [en]Indicates certificate type 2.
                                                 [cn]证书类型2 */
    TSDK_E_APNS_CRET_3,                     /**< [en]Indicates certificate type 3.
                                                 [cn]证书类型3 */
    TSDK_E_APNS_CRET_4,                     /**< [en]Indicates certificate type 4.
                                                 [cn]证书类型4 */
    TSDK_E_APNS_CRET_5,                     /**< [en]Indicates certificate type 5.
                                                 [cn]证书类型5 */

    TSDK_E_APNS_CRET_BUTT
}TSDK_E_APNS_CRET_TYPE;


/**
 * [en]This enumeration is used to describe conference control protocol type.
 * [cn]会控协议类型
 */
typedef enum tagTSDK_E_CONF_CTRL_PROTOCOL
{
    TSDK_E_CONF_CTRL_PROTOCOL_REST,         /**< [en]Indicates conference control protocol: REST
                                                 [cn]会控协议:REST*/
    TSDK_E_CONF_CTRL_PROTOCOL_IDO,          /**< [en]Indicates conference control protocol: IDO.
                                                 [cn]会控协议:IDO*/
    TSDK_E_CONF_CTRL_PROTOCOL_BUTT
}TSDK_E_CONF_CTRL_PROTOCOL;


/**
 * [en]This enumeration is used to describe service account type.
 * [cn]服务账号类型
 */
typedef enum tagTSDK_E_SERVICE_ACCOUNT_TYPE
{
    TSDK_E_VOIP_SERVICE_ACCOUNT,            /**< [en]Indicates VOIP service account.
                                                 [cn]VOIP服务账号 */
    TSDK_E_IM_SERVICE_ACCOUNT,              /**< [en]Indicates IM service account.
                                                 [cn]即时消息服务账号 */
    TSDK_E_UNKNOWN_SERVICE_ACCOUNT,         /**< [en]Indicates unknown service account.
                                                 [cn]未知服务 */
    TSDK_E_SERVICE_ACCOUNT_BUTT
}TSDK_E_SERVICE_ACCOUNT_TYPE;


/**
* [en]This enumeration is about video play tactic
* [cn]视频播放策略
*/
typedef enum tagTSDK_E_VIDEO_TACTIC
{
    TSDK_E_VIDEO_TACTIC_IMAGE_QUALITE_PRIORTY = 0,      /**< [en]Indicates the image qualite priorty
                                                             [cn]图像质量优先 */
    TSDK_E_VIDEO_TACTIC_SMOOTH_PRIORTY = 1,             /**< [en]Indicates the smooth priorty
                                                             [cn]流畅优先 */
    TSDK_E_VIDEO_TACTIC_BUTT
}TSDK_E_VIDEO_TACTIC;


/**
 * [en]Indicates the service event notification callback function definition.
 * [cn]业务事件通知回调函数定义
 *
 * @param [in] msgid                         [en]Indicates event ID, value of TSDK_E_EVENT.
 *                                           [cn]事件ID，取值TSDK_E_EVENT
 * @param [in] param1                        [en]Indicates parameter 1, see the description of the different event IDs.
 *                                           [cn]参数1，具体参见不同事件ID的说明
 * @param [in] param2                        [en]Indicates parameter 2, see the description of the different event IDs.
 *                                           [cn]参数2，具体参见不同事件ID的说明
 * @param [in] data                          [en]Indicates the message to attach data, see the description of the different event IDs.
 *                                           [cn]消息附加数据，具体参见不同事件ID的说明
 * @retval TSDK_RESULT                       [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                           [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]The developer need achieve the callback function, the callback message pointer parameters must be internal deep copy, otherwise the bottom layer may be released, resulting to program crashes.
 *            [cn]开发者要实现回调函数，回调消息指针参数必须在内部深拷贝，否则底层可能会释放，导致程序崩溃
 * @see tsdk_init
 **/
typedef TSDK_VOID  (*TSDK_FN_CALLBACK_PTR)(TSDK_UINT32 msgid, TSDK_UINT32 param1, TSDK_UINT32 param2, TSDK_VOID *data);



/**
 * [en]This structure is used to describe the application param.
 * [cn]应用程序信息参数
 */
typedef struct tagTSDK_S_APP_INFO_PARAM
{
    TSDK_E_CLIENT_TYPE  client_type;                                /**< [en]Indicates the client type.
                                                                         [cn]终端类型 */
    TSDK_CHAR product_name[TSDK_D_MAX_PRODUCT_NAME_LEN + 1];        /**< [en]Indicates the product name, eg."HUAWEI SDK MOBILE".
                                                                         [cn]产品名信息，如: "HUAWEI SDK MOBILE" */
    TSDK_CHAR device_sn[TSDK_D_MAX_DEVICE_SN_LEN + 1];              /**< [en]Indicates the sn number. Option parameter.
                                                                         [cn]设备sn号，可选参数。*/
    TSDK_BOOL support_audio_and_video_call;                         /**< [en]Indicates whether support audio and video call.
                                                                         [cn]是否支持音视频呼叫 */
    TSDK_BOOL support_audio_and_video_conf;                         /**< [en]Indicates whether support audio and video conference.
                                                                         [cn]是否支持音视频会议 */
    TSDK_BOOL support_data_conf;                                    /**< [en]Indicates whether support data conference.
                                                                         [cn]是否支持数据会议 */
    TSDK_BOOL use_ui_plugin;                                        /**< [en]Indicates whether .
                                                                         [cn]是否使用UI插件 */
    TSDK_BOOL is_ws_invoke_mode;                                    /**< [en]Indicates whether .
                                                                         [cn]是否使用WebSocket调用模式 */
    TSDK_BOOL support_ldap_frontstage;                              /**< [en]Indicates whether support ldap frontstage.
                                                                         [cn]是否使用WebSocket调用模式 */
    TSDK_BOOL is_close_security_channel;                            /**< [en]Indicates close security channel.
                                                                         [cn]是否关闭安全通道 */
}TSDK_S_APP_INFO_PARAM;


/**
 * [en]This structure is used to describe the log param.
 * [cn]日志参数(若选择设置，则需初始化前设置)
 */
typedef struct tagTSDK_S_LOG_PARAM
{
    TSDK_E_LOG_LEVEL level;                                         /**< [en]Indicates log level。
                                                                         [cn]日志级别 */
    TSDK_INT32 max_size_kb;                                         /**< [en]Indicates maximum size(KB) of a log file, which is the maximum value that can be obtained using suggest 10*1024.
                                                                         [cn]每个日志文件的最大值，单位: KB，最大10*1024 KB */
    TSDK_INT32 file_count;                                          /**< [en]Indicates number of log files. The maximum value is the one that can be obtained using suggest 4.
                                                                         [cn]日志文件个数，最大值为所能取到的最大值，建议为4 */
    TSDK_CHAR path[TSDK_D_MAX_LOG_PATH_LEN + 1];                    /**< [en]Indicates directory for storing log files.
                                                                         [cn]日志存放路径 */
} TSDK_S_LOG_PARAM;


typedef struct tagTSDK_S_TLS_IN_PARAM
{
    TSDK_CHAR caCertPath[TSDK_D_MAX_CA_PATH_LEN + 1];                /**< [en]Indicates the CA certificate path
                                                                          [cn]ca根证书存储路径 */
    TSDK_CHAR clientCertPath[TSDK_D_MAX_CA_PATH_LEN + 1];            /**< [en]Indicates the client certificate path
                                                                          [cn]客户端证书存储路径*/
    TSDK_CHAR clientKeyPath[TSDK_D_MAX_CA_PATH_LEN + 1];             /**< [en]Indicates the client key path
                                                                          [cn]客户端私钥存储路径*/
    TSDK_CHAR clientPrivkeyPwd[TSDK_D_MAX_PASSWORD_LENGTH + 1];      /**< [en]Indicates the client key password
                                                                          [cn]客户端私钥密码*/
}TSDK_S_TLS_IN_PARAM;

/**
* [en]This structure is used to describe the tls param.
* [cn]TLS参数国密参数
*/
typedef struct tagTSDK_S_TLS_GM_PARAM
{
    TSDK_CHAR gmsignSerCertPath[TSDK_D_MAX_CA_PATH_LEN + 1];                                   /**< [en]Indicates the Signing Device Certificate Path.
                                                                                                    [cn]签名设备证书路径*/
    TSDK_CHAR gmsignSerKeyCertPath[TSDK_D_MAX_CA_PATH_LEN + 1];                                /**< [en]Indicates the Path of the private key file of the signed device certificate.
                                                                                                    [cn]签名设备证书私钥文件路径*/
    TSDK_CHAR gmsignSerKeyFilePsw[TSDK_D_MAX_PASSWORD_LENGTH + 1];                             /**< [en]Indicates the Encryption password for signing the private key file of the device certificate.
                                                                                                    [cn]签名设备证书私钥文件的加密口令*/
    TSDK_CHAR gmencSerCertPath[TSDK_D_MAX_CA_PATH_LEN + 1];                                    /**< [en]Indicates the Encrypted device certificate path.
                                                                                                    [cn]加密设备证书路径*/
    TSDK_CHAR gmencSerKeyCertPath[TSDK_D_MAX_CA_PATH_LEN + 1];                                 /**< [en]Indicates the Path of the private key file of the encrypted device certificate.
                                                                                                    [cn]加密设备证书私钥文件路径*/
    TSDK_CHAR gmencSerKeyFilePsw[TSDK_D_MAX_PASSWORD_LENGTH + 1];                              /**< [en]Indicates the Encrypting password of the private key file of the device certificate.
                                                                                                    [cn]加密设备证书私钥文件的加密口令*/
    TSDK_CHAR gmcaDirPath[TSDK_D_MAX_CA_PATH_LEN + 1];                                         /**< [en]Indicates the CA certificate path.
                                                                                                    [cn]CA证书路径*/
    TSDK_BOOL isOpenSm;                                                                        /**< [en]Indicates the Enable State Encryption.
                                                                                                    [cn]是否开启国密*/
}TSDK_S_TLS_GM_PARAM;

/**
 * [en]This structure is used to describe the tls param.
 * [cn]TLS参数(若选择设置，则需初始化前设置)
 */
typedef struct tagTSDK_S_TLS_PARAM
{
    TSDK_S_TLS_IN_PARAM tlsInParam;                               /**< [en]Indicates In param.
                                                                       [cn]非国密参数 */
    TSDK_S_TLS_GM_PARAM tlsGmParam;                               /**< [en]Indicates gm param.
                                                                       [cn]国密参数 */
    TSDK_BOOL tlsCompatible;                                      /**< [en]Indicates the TLS compatible.
                                                                       [cn]是否开启 TLS 兼容模式 */
} TSDK_S_TLS_PARAM;

/**
 * [en]This structure is used to describe the http proxy information.
 * [cn]代理信息(若选择设置，则需初始化后登录前设置)
 */
typedef struct tagTSDK_S_PROXY_PARAM
{
    TSDK_CHAR user_name[TSDK_D_MAX_ACCOUNT_LEN + 1];                /**< [en]Indicates the account username.
                                                                         [cn]账户用户名 */
    TSDK_CHAR password[TSDK_D_MAX_PASSWORD_LENGTH + 1];             /**< [en]Indicates the account password.
                                                                         [cn]账户密码 */
    TSDK_CHAR proxy_uri[TSDK_D_MAX_URL_LENGTH + 1];                 /**< [en]Indicates the proxy address.
                                                                         [cn]服务器地址 */
    TSDK_UINT16 proxy_port;                                         /**< [en]Indicates the proxy port.
                                                                         [cn]代理服务器端口号 */
} TSDK_S_PROXY_PARAM;



/**
 * [en]This structure is used to describe security parameters.
 * [cn]业务安全配置参数(若选择设置，则需初始化后登录前设置)
 */
typedef struct tagTSDK_S_SERVICE_SECURITY_PARAM
{
    TSDK_E_MEDIA_SRTP_MODE media_srtp_mode;                         /**< [en]Indicates media srtp mode, the default value is TSDK_E_MEDIA_SRTP_MODE_DISABLE, it's valid when is_apply_config_priority is TRUE
                                                                         [cn]媒体SRTP模式，默认值为 TSDK_E_MEDIA_SRTP_MODE_DISABLE，在is_apply_config_priority为TRUE时有效。*/
    TSDK_E_BFCP_TRANSPORT_MODE bfcp_transport_mode;                 /**< [en]Indicates signaling transmission mode, the default value is UDP, it's valid when is_apply_config_priority is TRUE
                                                                         [cn]BFCP传输模式，默认为 UDP，在is_apply_config_priority为TRUE时有效。*/
} TSDK_S_SERVICE_SECURITY_PARAM;


/**
 * [en]This structure is used to describe local ip address.
 * [cn]本地ip地址
 */
typedef struct tagTSDK_S_LOCAL_ADDRESS
{
    TSDK_CHAR ip_address[TSDK_D_MAX_URL_LENGTH + 1];                /**< [en]Indicates local ip address
                                                                         [cn]本地ip地址 */
}TSDK_S_LOCAL_ADDRESS;


/**
 * [en]This structure is used to describe service address.
 * [cn]服务地址
 */
typedef struct tagTSDK_S_SERVER_ADDRESS
{
    TSDK_CHAR server_reg_address[TSDK_D_MAX_URL_LENGTH + 1];                /**< [en]Indicates ip address
                                                                             [cn]服务ip地址 */
    TSDK_UINT32 server_reg_port;                                            /**< [en]Indicates ip port
                                                                             [cn]服务端口 */
}TSDK_S_SERVER_ADDRESS;

/**
 * [en]This structure is used to describe call registration server.
 * [cn]呼叫注册服务地址
 */
typedef struct tagTSDK_S_SERVER_REGL_ADDRESS
{
    TSDK_S_SERVER_ADDRESS server_reg_primary;                                /**< [en]Indicates server reg primary address
                                                                             [cn]呼叫注册主服务地址 */
    TSDK_S_SERVER_ADDRESS server_reg_backup1;                                /**< [en]Indicates server reg backup1 address
                                                                             [cn]呼叫注册备份服务器1 */
    TSDK_S_SERVER_ADDRESS server_reg_backup2;                                /**< [en]Indicates server reg backup2 address
                                                                             [cn]呼叫注册备份服务器2 */
    TSDK_S_SERVER_ADDRESS server_reg_backup3;                                /**< [en]Indicates server reg backup3 address
                                                                             [cn]呼叫注册备份服务器3 */

}TSDK_S_SERVER_REGL_ADDRESS;

/**
 * [en]This structure is used to describe the application file path info.
 * [cn]应用程序文件路径信息
 */
typedef struct tagTSDK_S_APP_FILE_PATH_INFO
{
    TSDK_CHAR icon_file_path[TSDK_D_MAX_PATH_LEN + 1];              /**< [en]Indicates the icon File Save path.
                                                                         [cn]头像文件保存路径 */
    TSDK_CHAR dept_file_path[TSDK_D_MAX_PATH_LEN + 1];              /**< [en]Indicates the department query results File save path.
                                                                         [cn]部门查询结果文件保存路径 */
}TSDK_S_APP_FILE_PATH_INFO;



/**
 * [en]This structure is used to describe device DPI info.
 * [cn]设备DPI信息
 */
typedef struct tagTSDK_S_DEVICE_DPI_INFO
{
    TSDK_UINT32 dpi_x;                                              /**< [en]Indicates the device horizontal dpi.
                                                                         [cn]设备横向Dpi */
    TSDK_UINT32 dpi_y;                                              /**< [en]Indicates the device vertical dpi.
                                                                         [cn]设备纵向Dpi */
}TSDK_S_DEVICE_DPI_INFO;


/**
 * [en]This structure is used to describe network information parameters.
 * [cn]网络信息参数
 */
typedef struct tagTSDK_S_NETWORK_INFO_PARAM
{
    TSDK_CHAR server_addr[TSDK_D_MAX_URL_LENGTH + 1];                /**< [en]Indicates the server address.
                                                                          [cn]服务器地址 */
    TSDK_E_SIP_TRANSPORT_MODE sip_transport_mode;                    /**< [en]Indicates signaling transmission mode, the default value is TSDK_E_SIP_TRANSPORT_UDP.
                                                                          [cn]信令传输模式，默认值为TSDK_E_SIP_TRANSPORT_UDP.*/
    TSDK_UINT16 sip_server_port;                                     /**< [en]Indicates the SIP port.
                                                                          [cn]SIP端口号 */
    TSDK_UINT16 https_server_port;                                    /**< [en]Indicates the HTTPS port.
                                                                          [cn]HTTPS端口号 */
}TSDK_S_NETWORK_INFO_PARAM;



/**
 * [en]This structure is used to describe information about push parameters for the Android client.
 * [cn]Android客户端PUSH信息参数
 */
typedef struct tagTSDK_S_ANDROID_PUSH_PARAM
{
    TSDK_UINT32 app_id;                                                 /**< [en]Indicates app id.
                                                                             [cn]应用ID */
    TSDK_E_LANGUAGE_TYPE language;                                      /**< [en]Indicates language type.
                                                                             [cn]语言类型 */
    TSDK_CHAR push_token[TSDK_D_MAX_TOKEN_LEN + 1];                     /**< [en]Indicates push Token.
                                                                             [cn]Push Token */
    TSDK_CHAR push_class_name[TSDK_D_MAX_PATH_LEN + 1];                 /**< [en]Indicates path of the first activity class when the Android app starts.
                                                                             [cn]Android App启动的第一个activity类路径 */
    TSDK_UINT32 heart_beat_time;                                        /**< [en]Indicates heartbeat timeout duration of the Android background process.
                                                                             [cn]安卓后台进程心跳超时时长 */
}TSDK_S_ANDROID_PUSH_PARAM;


/**
 * [en]This structure is used to describe information about push parameters for the iOS client.
 * [cn]iOS客户端PUSH信息参数
 */
typedef struct tagTSDK_S_IOS_PUSH_PARAM
{
    TSDK_UINT32 app_id;                                                 /**< [en]Indicates App ID.
                                                                             [cn]应用ID */
    TSDK_E_LANGUAGE_TYPE language;                                      /**< [en]Indicates language type.
                                                                             [cn]语言类型 */
    TSDK_E_APNS_ENV_TYPE apns_env_type;                                 /**< [en]Indicates Apple push server environment type.
                                                                             [cn]APNS 环境类型 */
    TSDK_E_APNS_CRET_TYPE apns_cret_type;                               /**< [en]Indicates Apple push service certificate type.
                                                                             [cn]APNS 证书类型 */
    TSDK_CHAR device_token[TSDK_D_MAX_TOKEN_LEN + 1];                   /**< [en]Indicates device push token.
                                                                             [cn]设备Push Token */
    TSDK_CHAR voip_token[TSDK_D_MAX_TOKEN_LEN + 1];                     /**< [en]Indicates VoIP service push token.
                                                                             [cn]Voip业务Push Token */
    TSDK_CHAR push_im_active[TSDK_D_MAX_PATH_LEN + 1];                  /**< [en]Indicates IM notification bar or transparent transmission action.
                                                                             [cn]IM通知栏或者透传action */
    TSDK_CHAR push_voip_active[TSDK_D_MAX_PATH_LEN + 1];                /**< [en]Indicates VoIP background incoming call action.
                                                                             [cn]VOIP后台来电 action */
}TSDK_S_IOS_PUSH_PARAM;



/**
 * [en]This structure is used to describe Conference control parameters.
 * [cn]会议控制参数
 */
typedef struct tagTSDK_S_CONF_CTRL_PARAM
{
    TSDK_E_CONF_CTRL_PROTOCOL protocol;                             /**< [en]Indicates conference control protocol.
                                                                         [cn]会议控制协议 */
}TSDK_S_CONF_CTRL_PARAM;

 /**
 * [en]This enum is used to describe login server type.
 * [cn]登录组网类型
 */
typedef enum tagTSDK_E_LOGIN_SERVER_TYPE
{
    TSDK_E_LOGIN_E_SERVER_TYEP_SMC2 = 2,                            /**< [en]Indicates SMC2.0 server
                                                                         [cn]SMC2.0组网 */
    TSDK_E_LOGIN_E_SERVER_TYEP_SMC3 = 4,                            /**< [en]Indicates SMC3.0 server
                                                                         [cn]SMC3.0组网 */
    TSDK_E_LOGIN_E_SERVER_TYEP_BUTT
}TSDK_E_LOGIN_SERVER_TYPE;

/**
* [en]This enum is used to ldap server start.
* [cn]LDAP 服务启动结果
*/
typedef enum tagTSDK_E_LDAP_FRONTSTAGE_RESULT
{
    TSDK_E_LDAP_SERVICE_START_SUCCESS = 0,                      /**< [en]Indicates ladp service start success
                                                                     [cn]LDAP 服务启动成功 */
    TSDK_E_LDAP_SERVICE_START_FAILURE = 1,                      /**< [en]Indicates ladp service start failure
                                                                     [cn]LDAP 服务启动失败 */
    TSDK_E_LDAP_SERVICE_CONFIG_FAILURE = 2                      /**< [en]Indicates ladp service config failure
                                                                     [cn]LDAP 服务配置失败 */
} TSDK_E_LDAP_FRONTSTAGE_RESULT;

/**
* [en]This structure is used to describe termial local name in conf.
* [cn]会议中终端别名
*/
typedef struct tagTSDK_S_TERMINAL_LOCAL_NAME {
    TSDK_CHAR localName[TSDK_CONF_TERMINAL_LOCAL_NAME_LEN + 1];   /**< [en]Indicates termial local name in conf
                                                                       [cn]会议中终端别名  */
} TSDK_S_TERMINAL_LOCAL_NAME;

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_MANAGER_DEF_H__ */

