/**
 * @file tsdk_conference_interface.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK conference service module.
 */

#ifndef __TSDK_CONFERENCE_INTERFACE_H__
#define __TSDK_CONFERENCE_INTERFACE_H__


#include "tsdk_conference_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */

/**
 * @ingroup conference
 * @brief [en]This interface is used to schedule a conference (scheduled or instant conference).
 *        [cn]预约会议(立即或延时召开)
 *
 * @param [in] book_conf_info                               [en]Indicates info of book conference.
 *                                                          [cn]预约会议信息
 *
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code, value of TSDK_E_CONF_ERR_ID.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码，取值参考TSDK_E_CONF_ERR_ID
 *
 * @attention [en]If you create an instant meeting, the SDK automatically joins the meeting after the meeting is successfully created
 *            [cn]如果创建的是立即会议，会议创建成功后，SDK会自动加入会议
 * @see TSDK_E_CONF_EVT_BOOK_CONF_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_book_conference(IN TSDK_S_BOOK_CONF_INFO *book_conf_info);

/**
 * @ingroup conference
 * @brief [en]This interface is used to cancel a book conference.
 *        [cn]取消预约会议
 *
 * @param [in] conf_id                   [en]Indicates ID of book conference.
 *                                       [cn]预约会议ID
 *
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code, value of TSDK_E_CONF_ERR_ID.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码，取值参考TSDK_E_CONF_ERR_ID
 *
 * @attention [en] corresponding callback event is TSDK_E_CONF_EVT_CANCEL_CONF_RESULT.
 *            [cn] 对应的回调事件为 TSDK_E_CONF_EVT_CANCEL_CONF_RESULT
 * @see TSDK_E_CONF_EVT_CANCEL_CONF_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_cancel_conference(IN TSDK_CHAR *conf_id);

/**
 * @ingroup ConfMng
 * @brief [en]This interface is used to get conference list.
 *        [cn]获取会议列表
 *
 * @param [in] query_req                                    [en]Indicates to get conference list info request structure.
 *                                                          [cn]获取会议列表信息请求结构
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] corresponding callback event is TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT.
 *            [cn] 对应的回调事件为TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT
 * @see TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_query_conference_list(IN TSDK_S_QUERY_CONF_LIST_REQ *query_req);

/**
* @ingroup ConfCtrl
* @brief [en]This interface is used to Requested VMR list.
*        [cn]请求vmr列表
*
* @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
*                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] corresponding callback event is TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT.
*            [cn] 对应的回调事件为TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT
* @see TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT
**/
TSDK_API TSDK_RESULT tsdk_get_vmr_list(TSDK_VOID);

/**
* @ingroup ConfCtrl
* @brief [en]This interface is used to Update VMR info.
*        [cn]更新vmr列表
*
* @param [in] vmrInfo                       [en]Indicates get detail info of VMR list structure.
*                                                          [cn]更新vmr列表请求结构
* @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
*                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] corresponding callback event is TSDK_E_CONF_EVT_VMR_CHANGEED_RESULT.
*            [cn] 对应的回调事件为TSDK_E_CONF_EVT_VMR_CHANGEED_RESULT
* @see TSDK_E_CONF_EVT_VMR_CHANGEED_RESULT
**/
TSDK_API TSDK_RESULT tsdk_update_vmr_info(IN TSDK_S_VMR_INFO *vmrInfo);


/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to proactively join a conference.
 *        [cn]主动加入会议
 *
 * @param [in] conf_join_param                              [en]Indicates conf join param.
 *                                                          [cn]入会参数
 * @param [in] join_number                                  [en]Indicates join number.
 *                                                          [cn]入会号码
 * @param [in] is_video_join                                [en]Indicates whether video join conference.
 *                                                          [cn]是否视频接入会议
 * @param [out] call_id                                     [en]Indicates the call ID corresponding to the meeting is valid when the SIP terminal number is used.
 *                                                          [cn]会议对应的呼叫ID，在使用SIP终端号码入会时有效。
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see TSDK_E_CONF_EVT_JOIN_CONF_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_join_conference(IN TSDK_S_CONF_JOIN_PARAM* conf_join_param, IN TSDK_CHAR* join_number, IN TSDK_BOOL is_video_join, OUT TSDK_UINT32 *call_id);




/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is invoked by a participant to proactively leave a conference.
 *        [cn]离开会议
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see NA.
 **/
TSDK_API TSDK_RESULT tsdk_leave_conference(IN TSDK_UINT32 conf_handle);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is invoked by the chairman to end an ongoing conference.
 *        [cn]结束会议
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see TSDK_E_CONF_EVT_CONF_END_IND.
 **/
TSDK_API TSDK_RESULT tsdk_end_conference(IN TSDK_UINT32 conf_handle);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to mute or unmute a conference.
 *        [cn]设置或取消闭音会场
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] is_mute                                      [en]Indicates whether mute.
 *                                                          [cn]是否闭音
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]corresponding result event notification is TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT.
 *            [cn]对应的结果事件通知为TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT；
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_mute_conference(IN TSDK_UINT32 conf_handle, IN TSDK_BOOL is_mute);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is invoked by the chairman to add a new participant to a conference.
 *        [cn]添加与会者
 *
 * @param [in] conf_handle                                  [en]Indicates conference control handle.
 *                                                          [cn]会控句柄·
 * @param [in] add_attendees_info                           [en]Indicates add attendee info.
 *                                                          [cn]添加与会者信息
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA
 *            [cn]NA
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_add_attendee(IN TSDK_UINT32 conf_handle, IN const TSDK_S_ADD_ATTENDEES_INFO* add_attendees_info);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to redial the number of a participant.
 *        [cn]重拨与会者
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] attendee                                     [en]Indicates attendee number.
 *                                                          [cn]与会者号码
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_redial_attendee(IN TSDK_UINT32 conf_handle, IN const TSDK_CHAR* attendee);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to hang up attendee.
 *        [cn]挂断与会者
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] attendee                                     [en]Indicates attendee number.
 *                                                          [cn]与会者号码
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_hang_up_attendee(IN TSDK_UINT32 conf_handle, IN const TSDK_CHAR* attendee);


/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to remove attendee.
 *        [cn]删除与会者
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] attendee                                     [en]Indicates attendee number.
 *                                                          [cn]与会者号码
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_remove_attendee(IN TSDK_UINT32 conf_handle, IN const TSDK_CHAR* attendee);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to mute attendee.
 *        [cn]闭音与会者
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] attendee                                     [en]Indicates attendee number.
 *                                                          [cn]与会者号码
 * @param [in] is_mute                                      [en]Indicates whether mute.
 *                                                          [cn]是否闭音
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]Chairman can mute all attendee, normal attendee can only mute themselves, attendee can only listen not speak when they are muted.
 *            [en]corresponding result event notification is TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT.
 *            [cn]主席可对所有与会者设置或取消闭音，普通与会者只可对自己设置或取消闭音，被设置闭音时，与会者可听不可说；
 *            [cn]对应的结果事件通知为TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT；
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_mute_attendee(IN TSDK_UINT32 conf_handle, IN const TSDK_CHAR* attendee, IN TSDK_BOOL is_mute);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is invoked by a common participant in a conference to set their hands-up or cancel the setting or is invoked by the moderator to cancel hands-up of the other participants.
 *        [cn]设置或取消举手
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] is_handup                                    [en]Indicates whether hand up.
 *                                                          [cn]是否举手
 * @param [in] attendee                                     [en]Indicates attendee number(It's no need if it's config oneself).
 *                                                          [cn]与会者号码(若设置自己，则无需填写)
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]Corresponding result event notify is TSDK_E_CONF_SET_HANDUP or TSDK_E_CONF_CANCLE_HANDUP.
 *            [cn]对应的结果事件通知为TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_set_handup(IN TSDK_UINT32 conf_handle, IN TSDK_BOOL is_handup, IN const TSDK_CHAR* attendee);


/**
 * @ingroup ConfCtrl.
 * @brief [en]This interface is invoked by the chairman to select the participant to view among the participants who are being broadcast.
 *        [cn]请求观看指定与会者画面
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] watch_attendee_info                                [en]Indicates watch attendee param info.
 *                                                          [cn]选看与会者画面参数信息
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_watch_attendee(IN TSDK_UINT32 conf_handle, IN TSDK_S_WATCH_ATTENDEES_INFO* watch_attendee_info);

/**
 * @ingroup ConfCtrl.
 * @brief [en]This interface is used to broadcast or cancel broadcasting a specified participant.
 *        [cn]广播或取消广播指定与会者（会场）
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] attendee                                     [en]Indicates attendee number.
 *                                                          [cn]与会者号码
 * @param [in] is_broadcast                                  [en]Indicates broadcast or cancel broadcast.
 *                                                          [cn]广播或是取消广播
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]NA.
 *            [cn]NA.
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_broadcast_attendee(IN TSDK_UINT32 conf_handle, IN TSDK_CHAR* attendee, IN TSDK_BOOL is_broadcast);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to apply for chair rights.
 *        [cn]申请主席权限
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] password                                     [en]Indicates chairman password.
 *                                                          [cn]主席密码
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]corresponding result event notify is TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT.
 *            [cn]对应的结果事件通知为TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT；
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_request_chairman(IN TSDK_UINT32 conf_handle, IN TSDK_CHAR* password);


/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to release chair rights.
 *        [cn]释放主席权限
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]Corresponding result event notify is TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT.
 *            [cn]对应的结果事件通知为TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_release_chairman(IN TSDK_UINT32 conf_handle);


/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to postpone conference.
 *        [cn]延长会议
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] time                                         [en]Indicates postpone time, the unit is minute.
 *                                                          [cn]延长时间，单位：分钟
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]Corresponding result event notify is TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT.
 *            [cn]对应的结果事件通知为TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_postpone_conference(IN TSDK_UINT32 conf_handle, IN TSDK_UINT16 time);

/**
 * @ingroup conference
 * @brief [en]This interface is used to join a conference anonymously.
 *        [cn]通过匿名方式加入会议
 *
 * @param [in] conf_join_param                                     [en]Indicates info of book conference.
 *                                                                 [cn]用于匿名方式加入会议的会议信息
 *
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code, value of TSDK_E_CONF_ERR_ID.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码，取值参考TSDK_E_CONF_ERR_ID
 *
 * @attention [en]NA.
 *            [cn]NA
 *
 * @see TSDK_E_CONF_EVT_JOIN_CONF_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_join_conference_by_anonymous(IN TSDK_S_CONF_ANONYMOUS_JOIN_PARAM *conf_join_param);

/**
 * @ingroup ConfCtrl
 * @brief [en]This interface is used to set the conference recording status.
 *        [cn]设置会议录播
 *
 * @param [in] conf_handle                                  [en]Indicates conference handle.
 *                                                          [cn]会控句柄
 * @param [in] record_broadcast                             [en]Indicates conference recording status.
 *                                                          [cn]录播状态
 * @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
 *                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en]The corresponding result event notification is TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT.
 *            [cn]对应的结果事件通知为 TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 * @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
 **/
TSDK_API TSDK_RESULT tsdk_set_record_broadcast(IN TSDK_UINT32 conf_handle, IN TSDK_E_CONF_RECORD_STATUS record_broadcast);

/**
* @ingroup ConfCtrl.
* @brief [en]This interface is invoked by the chairman to select the participant to view among the participants who are being broadcast.
*        [cn]多流会议请求观看指定与会者画面
*
* @param [in] conf_handle                                               [en]Indicates conference handle.
*                                                                       [cn]会控句柄
* @param [in] watch_attendee_info                                       [en]Indicates watch attendee param info.
*                                                                       [cn]选看与会者画面参数信息
* @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
*                            [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en]NA.
*            [cn]NA.
* @see TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT
**/
TSDK_API TSDK_RESULT tsdk_watch_svc_attendee(IN TSDK_UINT32 conf_handle, IN TSDK_S_WATCH_SVC_ATTENDEES_INFO* watch_attendee_info);

/*****************************************************************************
函 数 名  : tsdk_confctrl_switch_audit_sites_dir
功能描述  : 会场切换单双向
输入参数  : IN TSDK_UINT32 conf_handle
            IN TSDK_UINT32 dir
输出参数  : 无
返 回 值  : TSDK_RESULT

修改历史  :
日    期  : 2020年05月19日
作    者  : VC Open development Team
修改内容  : 新生成函数

*****************************************************************************/
TSDK_API TSDK_RESULT tsdk_confctrl_switch_audit_sites_dir(IN TSDK_UINT32 conf_handle, IN TSDK_UINT32 dir);

/*****************************************************************************
函 数 名  : tsdk_confctrl_get_time_zone_list
功能描述  : 获取时区列表
输入参数  : IN TSDK_E_CONF_LANGUAGE_TYPE language_type
输出参数  : 无
返 回 值  : TSDK_RESULT

修改历史  :
日    期  : 2020年08月17日
作    者  : VC Open development Team
修改内容  : 新生成函数

*****************************************************************************/
TSDK_API TSDK_RESULT tsdk_confctrl_get_time_zone_list(IN TSDK_E_CONF_LANGUAGE_TYPE language_type);


#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_CONFERENCE_INTERFACE_H__ */

