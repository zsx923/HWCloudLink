/**
 * @file tsdk_call_interface.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK call service module.
 */

#ifndef __TSDK_CALL_INTERFACE_H__
#define __TSDK_CALL_INTERFACE_H__

#include "tsdk_call_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */


/**
 * @ingroup Call
 * @brief [en] This interface is used to start a normal VOIP call.
 *        [cn] 发起一路普通VOIP呼叫
 *
 * @param [out] callId                           [en] Indicates call ID, uniquely identifying a call.
 *                                               [cn] 呼叫的id，标识唯一的呼叫
 * @param [in] calleeNumber                      [en] Indicates called number, maximum valid length of 255 characters
 *                                               [cn] 被叫号码，最大有效长度255
 * @param [in] calleeName                        [en] Indicates called name, maximum valid length of 192 characters
 *                                               [cn] 被叫名字，最大有效长度192
 * @param [in] isVideo                           [en] Indicates whether to start video call
 *                                               [cn] 是否发起视频呼叫
 * @retval TSDK_RESULT                           [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                               [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_accept_call
 * @see tsdk_end_call
 **/
TSDK_API TSDK_RESULT tsdk_start_call(TSDK_UINT32 *callId, const TSDK_CHAR *calleeNumber, const TSDK_CHAR *calleeName, TSDK_BOOL isVideo);


/**
 * @ingroup Call
 * @brief [en] This interface is used to answer a call when receiving a call request.
 *        [cn] 接听呼叫
 *
 * @param [in] call_id                           [en] Indicates call ID
 *                                               [cn] 呼叫ID
 * @param [in] is_video                          [en] Indicates whether to answer video call.
 *                                               [cn] 是否接听视频呼叫
 * @retval TSDK_RESULT                           [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                               [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_start_call
 * @see tsdk_end_call
 **/
TSDK_API TSDK_RESULT tsdk_accept_call(IN TSDK_UINT32 call_id, IN TSDK_BOOL is_video);


/**
 * @ingroup Call
 * @brief [en] This interface is used to end a placed or received call.
 *        [cn] 结束和其他用户的通话或者来电
 *
 * @param [in] call_id                           [en] Indicates call ID
 *                                               [cn] 呼叫ID
 * @retval TSDK_RESULT                           [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                               [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_start_call
 * @see tsdk_accept_call
 **/
TSDK_API TSDK_RESULT tsdk_end_call(IN TSDK_UINT32 call_id);


/**
 * @ingroup Call
 * @brief [en] This interface is used to send two-stage dialing information during a call.
 *        [cn] 在通话中发送二次拨号信息
 *
 * @param [in] call_id                           [en] Indicates call ID
 *                                               [cn] 呼叫ID
 * @param [in] tone                              [en] Indicates DTMF tone
 *                                               [cn] DTMF键值
 * @retval TSDK_RESULT                           [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                               [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] This interface must be send during a call
 *            [cn] 通话中才可以发送
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_send_dtmf(IN TSDK_UINT32 call_id, IN TSDK_E_DTMF_TONE tone);


/**
 * @ingroup Call
 * @brief [en] This interface is used to set video window info(window handle)
 *        [cn] 设置视频窗口信息(窗口句柄)
 *
 * @param [in] call_id                              [en] Indicates call ID
 *                                                  [cn] 呼叫ID
 * @param [in] count                                [en] Indicates number of windows. Generally, the value is 2.
 *                                                  [cn] 窗口个数，一般为2
 * @param [in] window                               [en] Indicates window info.
 *                                                  [cn] 视频窗口信息
 * @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] When call is exist, fill in the corresponding effective value of call id； when call does not exist (not established, calling out breath), fill in illegal value
 *            [cn] 呼叫存在时，call_id填写对应的有效值，呼叫不存在(未建立，主叫呼出时)，call_id填写非法值
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_set_video_window(IN TSDK_UINT32 call_id, IN TSDK_UINT32 count, IN const TSDK_S_VIDEO_WND_INFO *window);

/**
* @ingroup Call
* @brief [en] This interface is used to set video window info(window handle)
*        [cn] 视频窗口去绑定(窗口句柄)
*
* @param [in] callId                              [en] Indicates call ID
*                                                  [cn] 呼叫ID
* @param [in] window                               [en] Indicates window info.
*                                                  [cn] 视频窗口信息
* @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] When call is exist, fill in the corresponding effective value of call id； when call does not exist (not established, calling out breath), fill in illegal value
*            [cn] 呼叫存在时，call_id填写对应的有效值，呼叫不存在(未建立，主叫呼出时)，call_id填写非法值
* @see NA
**/
TSDK_API TSDK_RESULT TsdkDeleteVideoWindow(IN TSDK_UINT32 callId, IN const TSDK_S_VIDEO_WND_INFO *window);

/**
* @ingroup Call
* @brief [en] This interface is used to add video window info(window handle)
*        [cn] 添加视频窗口信息(窗口句柄)
*
* @param [in] call_id                              [en] Indicates call ID
*                                                  [cn] 呼叫ID
* @param [in] window                                   [en] Indicates window info.
*                                                  [cn] 视频窗口信息
* @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] When call is exist, fill in the corresponding effective value of call id； when call does not exist (not established, calling out breath), fill in illegal value
*            [cn] 呼叫存在时，call_id填写对应的有效值，呼叫不存在(未建立，主叫呼出时)，call_id填写非法值
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_add_svc_video_window(IN TSDK_UINT32 call_id, IN const TSDK_S_SVC_VIDEO_WND_INFO *window);

/**
* @ingroup Call
* @brief [en] This interface is used to remove video window info(window handle)
*        [cn] 删除视频窗口信息(窗口句柄)
*
* @param [in] call_id                              [en] Indicates call ID
*                                                  [cn] 呼叫ID
* @param [in] window                                   [en] Indicates window info.
*                                                  [cn] 视频窗口信息
* @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] When call is exist, fill in the corresponding effective value of call id； when call does not exist (not established, calling out breath), fill in illegal value
*            [cn] 呼叫存在时，call_id填写对应的有效值，呼叫不存在(未建立，主叫呼出时)，call_id填写非法值
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_remove_svc_video_window(IN TSDK_UINT32 call_id, IN const TSDK_S_SVC_VIDEO_WND_INFO *window);

/**
* @ingroup Call
* @brief [en] This interface is used to update video window info(window handle)
*        [cn] 更新视频窗口信息(窗口句柄)
*
* @param [in] call_id                              [en] Indicates call ID
*                                                  [cn] 呼叫ID
* @param [in] window                                   [en] Indicates window info.
*                                                  [cn] 视频窗口信息
* @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] When call is exist, fill in the corresponding effective value of call id； when call does not exist (not established, calling out breath), fill in illegal value
*            [cn] 呼叫存在时，call_id填写对应的有效值，呼叫不存在(未建立，主叫呼出时)，call_id填写非法值
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_update_svc_video_window(IN TSDK_UINT32 call_id, IN const TSDK_S_SVC_VIDEO_WND_INFO *window);

/**
* @ingroup Call
* @brief [en] This interface is used to set all svc video window info
*        [cn] 批量绑定和移除解码器
*
* @param [in] call_id                              [en] Indicates call ID
*                                                  [cn] 呼叫ID
* @param [in] window_array                                        [en] Indicates window array info.
*                                                  [cn] 视频窗口信息
* @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] When call is exist, fill in the corresponding effective value of call id； when call does not exist (not established, calling out breath), fill in illegal value
*            [cn] 呼叫存在时，call_id填写对应的有效值，呼叫不存在(未建立，主叫呼出时)，call_id填写非法值
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_all_svc_video_windows(IN TSDK_UINT32 callid, IN const TSDK_S_SVC_SET_WATCH_LIST_INFO *window_array);
/**
 * @ingroup Call
 * @brief [en] This interface is used to initiate a request for adding a video (converting an audio call into a video call).
 *        [cn] 发起音频转视频呼叫请求
 *
 * @param [in] call_id                               [en] Indicates call ID
 *                                                   [cn] 呼叫ID
 * @retval TSDK_RESULT                               [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                   [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_reply_add_video
 * @see tsdk_del_video
 **/
TSDK_API TSDK_RESULT tsdk_add_video(IN TSDK_UINT32 call_id);


/**
 * @ingroup Call
 * @brief [en] This interface is used to initiate a request for deleting a video (converting a video call into an audio call).
 *        [cn] 发起视频转音频呼叫请求
 *
 * @param [in] call_id                                [en] Indicates call ID
 *                                                    [cn] 呼叫ID
 * @retval TSDK_RESULT                                [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                    [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_reply_add_video
 * @see tsdk_add_video
 **/
TSDK_API TSDK_RESULT tsdk_del_video(IN TSDK_UINT32 call_id);


/**
 * @ingroup Call
 * @brief [en] This interface is used to when the peer party sends a request to convert an audio call into a video call, the local party invokes this interface to accept or reject the request.
 *        [cn] 对方请求音频转视频呼叫时，本方选择同意或者拒绝
 *
 * @param [in] call_id                                [en] Indicates call ID
 *                                                    [cn] 呼叫ID
 * @param [in] is_accept                              [en] Indicates whether to accept the request.
 *                                                    [cn] 是否同意
 * @retval TSDK_RESULT                                [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                    [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_add_video
 * @see tsdk_del_video
 **/
TSDK_API TSDK_RESULT tsdk_reply_add_video(IN TSDK_UINT32 call_id, IN TSDK_BOOL is_accept);


/**
 * @brief [en] This interface is used to control video
 *        [cn] 视频控制
 *
 * @param [in] call_id                                [en] Indicates Call ID.
 *                                                    [cn] 呼叫ID
 *
 * @param [in] video_control                          [en] Indicates video control param
 *                                                    [cn] 视频控制参数
 * @retval TSDK_RESULT                                [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                    [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码*
 * @attention NA
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_video_control(IN TSDK_UINT32 call_id, IN TSDK_S_VIDEO_CTRL_INFO *video_control);

/**
 * @ingroup Call
 * @brief [en] This interface is used to set whether mute the microphone
 *        [cn] 设置(或取消)麦克风静音
 *
 * @param [in] call_id                                [en] Indicates call ID.
 *                                                    [cn] 呼叫ID
 * @param [in] is_mute                                [en] Indicates whether to mute the microphone.
 *                                                    [cn] 是否静音
 * @retval TSDK_RESULT                                [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                    [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_mute_mic(IN TSDK_UINT32 call_id, IN TSDK_BOOL is_mute);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to play local audio file(ringing tone,ring back tone,dial tone,DTMF tone,busy tone and keypad tone)
 *        [cn] 播放本地音频文件(振铃音、回铃音、拨号(提示)音、DTMF音、忙碌提示音和本地按健音等)
 *
 * @param [in] loops                                    [en] Indicates number of cycles("0" indicates loop play )
 *                                                      [cn] 循环次数，只支持0或1（0表示循环播放,1表示只播放一次）
 * @param [in] play_file                                [en] Indicates audio file to be played(Only support wav format)
 *                                                      [cn] 待播放的音频文件（目前支持wav格式）
 * @param [out] play_handle                             [en] Indicates play handle
 *                                                      [cn] 播放句柄(用于停止播放时的参数)
 * @retval TSDK_RESULT                                  [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                      [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] Only support wav format, support PCMA, PCMU, G.729 or PCM(sampling rate: 8~48 kHz; precision: 8~16-bit),support double channel
 *            [cn] WAV文件，目前支持PCMA、PCMU、G.729格式或采样精度为8或16位、采样率8k～48K的PCM数据，支持双声道
 * @see tsdk_stop_play_media
 **/
TSDK_API TSDK_RESULT tsdk_start_play_media(IN TSDK_UINT32 loops, IN const TSDK_CHAR* play_file, OUT TSDK_INT32* play_handle);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to stop playing tone
 *        [cn] 停止铃音播放
 *
 * @param [in] play_handle                              [en] Indicates play handle
 *                                                      [cn] 播放句柄
 * @retval TSDK_RESULT                                  [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                      [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_start_play_media
 **/
TSDK_API TSDK_RESULT tsdk_stop_play_media(IN TSDK_INT32 play_handle);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to get the audio and video device list
 *        [cn] 获取音频视频设备列表
 *
 * @param [in] device_type                              [en] Indicates device type.
 *                                                      [cn] 设备类型
 * @param [in/out] TSDK_UINT32* num                     [en] Indicates when it is the input parameter, it indicates the number of devices that the upper layer allocates. When it is the output parameter, it indicates the number of devices obtained.
 *                                                      [cn] 输入时表示上层分配的设备个数，输出时表示获取到得设备的个数
 * @param [out] device_info                             [en] Indicates which is the pointer of the device information array.
 *                                                      [cn] 设备信息数组指针
 *
 * @retval TSDK_RESULT                                  [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                      [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_get_devices(IN TSDK_E_DEVICE_TYPE device_type, IO TSDK_UINT32* num, OUT TSDK_S_DEVICE_INFO* device_info);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to set microphone device index
 *        [cn] 设置使用的麦克风设备序号
 *
 * @param [in] index                                   [en] Indicates device index.
 *                                                     [cn] 麦克风设备序号
 * @retval TSDK_RESULT                                 [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                     [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] Device index is generally obtained after the system initialization by tsdk_get_devices, used for PC
 *            [cn] 设备序号一般在系统初始化后通过tsdk_get_devices获取，用于PC
 * @see tsdk_get_mic_index
 * @see tsdk_get_devices
 **/
TSDK_API TSDK_RESULT tsdk_set_mic_index(IN TSDK_UINT32 index);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to get microphone device index.
 *        [cn] 获取使用的麦克风设备序号
 *
 * @param [out] index                                  [en] Indicates device index.
 *                                                     [cn] 麦克风设备序号
 * @retval TSDK_RESULT                                 [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                     [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] Only for interface test or device test
 *            [cn] 用于接口测试或产品调试，实际产品业务场景中无需调用
 * @see tsdk_set_mic_index
 **/
TSDK_API TSDK_RESULT tsdk_get_mic_index(OUT TSDK_UINT32* index);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to set speakerphone device index.
 *        [cn] 设置使用的扬声器设备序号
 *
 * @param [in] index                                   [en] Indicates device index.
 *                                                     [cn] 扬声器设备序号
 * @retval TSDK_RESULT                                 [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                     [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] Device index is generally obtained after the system initialization by tsdk_get_devices, used for PC
 *            [cn] 设备序号一般在系统初始化后通过tsdk_get_devices获取，用于PC
 * @see tsdk_get_speak_index
 * @see tsdk_get_devices
 **/
TSDK_API TSDK_RESULT tsdk_set_speak_index(IN TSDK_UINT32 index);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to get speakerphone device index.
 *        <br>[cn] 获取使用的扬声器设备序号
 *
 * @param [out] index                                  [en] Indicates device index.
 *                                                     [cn] 扬声器设备序号
 * @retval TSDK_RESULT                                 [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                     [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] Only for interface test or device test
 *            [cn] 用于接口测试或产品调试，实际产品业务场景中无需调用
 * @see tsdk_set_speak_index
 **/
TSDK_API TSDK_RESULT tsdk_get_speak_index(OUT TSDK_UINT32* index);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to set video device index.
 *        [cn] 设置使用的视频设备序号
 *
 * @param [in] index                                  [en] Indicates device index.
 *                                                    [cn] 视频设备序号
 * @retval TSDK_RESULT                                [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                    [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] Device index is generally obtained after the system initialization by tsdk_get_devices, used for PC
 *            [cn] 设备序号一般在系统初始化后通过tsdk_get_devices获取
 * @see tsdk_get_video_index
 * @see tsdk_get_devices
 **/
TSDK_API TSDK_RESULT tsdk_set_video_index(IN TSDK_UINT32 index);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to get video device index.
 *        [cn] 获取使用的视频设备序号
 *
 * @param [out] index                                [en] Indicates device index.
 *                                                   [cn] 视频设备序号
 * @retval TSDK_RESULT                               [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                   [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] only for interface test or device test
 *            [cn] 用于接口测试或产品调试，实际产品业务场景中无需调用
 * @see tsdk_set_video_index
 **/
TSDK_API TSDK_RESULT tsdk_get_video_index(OUT TSDK_UINT32* index);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to set output volume
 *        [cn] 设置当前输出设备音量大小
 *
 * @param [in] volume                               [en] Indicates volume range from 0 to 100
 *                                                  [cn] 音量大小，取值范围[0, 100]
 *
 * @retval TSDK_RESULT                               [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                   [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_get_speak_volume
 **/
TSDK_API TSDK_RESULT tsdk_set_speak_volume(IN TSDK_UINT32 volume);


/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to get output volume
 *        [cn] 获取输出音量大小
 *
 * @param [out] volume                               [en] Indicates volume range from 0 to 100
 *                                                   [cn] 音量大小，取值范围[0, 100]
 * @retval TSDK_RESULT                               [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                   [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_set_speak_volume
 **/
TSDK_API TSDK_RESULT tsdk_get_speak_volume(OUT TSDK_UINT32* volume);

/**
* @ingroup MediaAndDevices
* @brief [en] This interface is used to set audio device volume
*        [cn] 设置音频设备音量大小
*
* @param [in] volume                                [en] Indicates volume range from 0 to 100
*                                                   [cn] 音量大小，取值范围[0, 100]
* @param [in] device                                [en] Indicates the audio input and output device type
*                                                   [cn] 音频设备类型
*
* @retval TSDK_RESULT                               [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                   [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention NA
* @see tsdk_set_mic_volume
**/
TSDK_API TSDK_RESULT tsdk_set_mic_volume(IN TSDK_E_AUDDEV_ROUTE device, IN TSDK_UINT32 volume);

/**
* @ingroup MediaAndDevices
* @brief [en] This interface is used to get input volume
*        [cn] 获取输入音量大小
*
* @param [out] volume                               [en] Indicates volume range from 0 to 100
*                                                   [cn] 音量大小，取值范围[0, 100]
* @retval TSDK_RESULT                               [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                   [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention NA
* @see tsdk_get_mic_volume
**/
TSDK_API TSDK_RESULT tsdk_get_mic_volume(OUT TSDK_UINT32* volume);

/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to open local preview window, checking whether the local video can be normally displayed
 *        [cn] 打开本地预览窗口
 *
 * @param [in] handle                                [en] Indicates window handle.
 *                                                   [cn] 窗口句柄
 * @param [in] index                                 [en] Indicates camera index
 *                                                   [cn] 摄相头索引
 * @retval TSDK_RESULT                               [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                   [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_close_video_preview
 **/
TSDK_API TSDK_RESULT tsdk_open_video_preview(IN TSDK_UPTR handle, IN TSDK_UINT32 index);

/**
 * @ingroup MediaAndDevices
 * @brief [en] This interface is used to close and delete local preview window
 *        [cn] 关闭并删除本地预览窗口
 *
 * @param [in] TUP_VOID
 * @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_open_video_preview
 **/
TSDK_API TSDK_RESULT tsdk_close_video_preview(TSDK_VOID);

/**
 * @brief [en] This interface is used to set the attributes of the video display window.
 *        [cn] 设置视频显示窗口属性
 *
 * @param [in] callid                                  [en]Indicates call id
 *                                                     [cn]呼叫ID
 * @param [in] render                                  [en]Indicates video display window attribute
 *                                                     [cn]视频显示窗口属性
 * @retval TSDK_RESULT                                 [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                     [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_set_video_render(IN TSDK_UINT32 call_id, IN const TSDK_S_VIDEO_RENDER_INFO* video_render);

/**
 * @ingroup Call
 * @brief [en]This interface is used to set set camera picture
 *        [cn] 设置摄像头图片
 *
 * @param [in] callid                       [en] Indicates call ID.
 *                                          [cn] 呼叫ID
 * @param [in] file_name                    [en] Indicates file name, BMP format picture no more than 1920*1200
 *                                          [cn] 文件名，不超过1920*1200的BMP格式图片
 * @retval TSDK_RESULT                      [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                          [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 * @attention NA
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_set_camera_picture(IN TSDK_UINT32 call_id, IN TSDK_CHAR *file_name);

/**
 * @ingroup Call
 * @brief [en] This interface is used to set whether mute the microphone
 *        [cn] 设置(或取消)扬声器静音
 *
 * @param [in] call_id                                [en] Indicates call ID.
 *                                                    [cn] 呼叫ID
 * @param [in] is_mute                                [en] Indicates whether to mute the microphone.
 *                                                    [cn] 是否静音
 * @retval TSDK_RESULT                                [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                    [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see NA
 **/
TSDK_API TSDK_RESULT tsdk_mute_speaker(IN TSDK_UINT32 call_id, IN TSDK_BOOL is_mute);

/**
* @ingroup Call
* @brief [en]This interface is used to get the audio and video media info
*        [cn]获取呼叫流通道信息
*
* @param [in] call_id                                 [en] Indicates call ID.
*                                                     [cn] 呼叫ID                                              
* @retval TSDK_S_CALL_STREAM_INFO* call_stream_info   [en] return media information.
*                                                     [cn] 媒体信息
* @attention NA
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_get_call_stream_info(IN TSDK_UINT32 call_id, OUT TSDK_S_CALL_STREAM_INFO* call_stream_info);

/**
 * @brief [en] This interface is used to start data.
 *        [cn] 启动辅流
 *
 * @param [in] call_id                            [en] Indicates call id.
 *                                                [cn] 呼叫ID
 * @retval TSDK_RESULT                            [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_aux_stop_data
 **/
TSDK_API TSDK_RESULT tsdk_aux_start_data(IN TSDK_UINT32 call_id);


/**
 * @brief [en] This interface is used to stop data.
 *        [cn] 停止辅流
 *
 * @param [in] call_id                            [en] Indicates call id.
 *                                                [cn] 呼叫ID
 * @retval TSDK_RESULT                            [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_aux_start_data
 **/
TSDK_API TSDK_RESULT tsdk_aux_stop_data(IN TSDK_UINT32 call_id);

/**
* @ingroup Call
* @brief [en] This interface is used to start an anonymous VOIP call.
*        [cn] 发起一路匿名VOIP呼叫
*
* @param [out] call_id                          [en] Indicates call ID, uniquely identifying a call.
*                                               [cn] 呼叫的id，标识唯一的呼叫
* @param [in] callee_number                     [en] Indicates called number, maximum valid length of 255 characters
*                                               [cn] 被叫号码，最大有效长度255
* @param [in] is_video                          [en] Indicates whether to start video call
*                                               [cn] 是否发起视频呼叫
* @retval TSDK_RESULT                           [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                               [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention NA
* @see tsdk_accept_call
* @see tsdk_end_call
**/
TSDK_API TSDK_RESULT tsdk_start_anonymous_call(OUT TSDK_UINT32 *call_id, IN const TSDK_CHAR* callee_number, IN TSDK_BOOL is_video);

/**
* @ingroup Call
* @brief [en] This interface is used to set video resolution according to video definition policy.
*        [cn] 设置视频图像清晰度策略
*
* @param [in] video_definition_policy                                   [en] Indicates video definition policy
*                                                                       [cn] 视频图像清晰度策略
* @retval TSDK_RESULT                                                   [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                                       [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
* @attention NA
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_video_definition_policy( IN TSDK_E_VIDEO_DEFINITION_POLICY  video_definition_policy);

/**
* @ingroup Call
* @brief [en] This interface is used to user-defined bandwidth.
*        [cn] 用户自定义会会场带宽
*
* @param [in] bandwidth_level                                           [en] Indicates user-defined bandwidth level
*                                                                       [cn] 用户自定义会会场带宽
* @retval TSDK_RESULT                                                   [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                                       [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
* @attention NA
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_user_def_bandwidth(IN TSDK_E_USER_DEF_BANDWIDTH_LEVEL bandwidth_level);

/**
* @ingroup Call
* @brief [en]This interface is used to set screen capture
*        [cn]设置屏幕抓取回调函数
*
* @param [in] callback                                      [en] Indicates **.
*                                                           [cn] 抓屏函数指针
* @attention NA
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_capture_callback(IN CALL_WRAPPER_CAPTURE_CALLBACK_FUN callback);

/**
* @ingroup Call
* @brief [en]This interface is used to set auto adjust bandwidth
*        [cn]开启或关闭自动降速
*
* @param [in] enable                                        [en] Indicates enable auto bandwidth or not.
*                                                           [cn] 是否是否开启自动降速
* @attention NA
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_auto_adjust_bandwidth(IN TSDK_BOOL enable);

/**
* @ingroup MediaAndDevices
* @brief [en] This interface is used to set mobile audio route device
*        [cn] 设置移动音频路由设备
*
* @param [in] route                                [en] Indicates mobile route device type
*                                                  [cn] 移动音频路由设备类型
* @retval TSDK_RESULT                              [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                  [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] Interface for mobile devices.
*            [cn] 用于移动设备
* @see tsdk_get_mobile_audio_route
**/
TSDK_API TSDK_RESULT tsdk_set_mobile_audio_route(IN TSDK_E_MOBILE_AUIDO_ROUTE route);

/**
* @ingroup MediaAndDevices
* @brief [en] This interface is used to get mobile audio route device
*        [cn] 获取移动音频路由设备
*
* @param [out] route                              [en] Indicates mobile route device type
*                                                 [cn] 移动音频路由设备类型
* @retval TSDK_RESULT                             [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                 [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] Interface for mobile devices.
*            [cn] 用于移动设备
* @see tsdk_set_mobile_audio_route
**/
TSDK_API TSDK_RESULT tsdk_get_mobile_audio_route(OUT TSDK_E_MOBILE_AUIDO_ROUTE *route);

/**
* @brief [en] This interface is used to set the camera image capture direction.
*        [cn] 设置摄像头采集方向
*
* @param [in] callid                                                      [en]Indicates call id
*                                                                         [cn]呼叫ID
* @param [in] camera_index                                                [en]Indicates camera index.The value range is {0, 1}.
*                                                                         [cn]采集设备(摄像头)索引 {0,1}
* @param [in] capture_rotation                                            [en]Indicates camera image capture angle, which is available only on the mobile platform. The value range is {0, 1, 2, 3}. The default value is 0.
*                                                                         [cn]摄像头采集角度 {0,1,2,3} 仅对移动平台有效，默认为0
* @retval TSDK_RESULT                                                     [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                                         [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
* @attention NA
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_capture_rotation(IN TSDK_UINT32 call_id, IN TSDK_E_VIDEO_CAPTURE_INDEX_TYPE camera_index, IN TSDK_E_VIDEO_CAPTURE_ROTATOIN_TYPE capture_rotation);

/**
* @brief [en] This interface is used to set window display rotation
*        [cn] 设置窗口显示方向
*
* @param [in] callid                                                    [en]Indicates call id
*                                                                       [cn]呼叫ID
* @param [in] window_type                                               [en]Indicates window type
*                                                                       [cn]视频窗口类型
* @param [in] display_rotation                                          [en]Indicates window display angle, which is available only on the mobile platform. The value range is {0, 1, 2, 3}. The default value is 0.
*                                                                       [cn]窗口显示角度 {0,1,2,3} 仅对移动平台有效，默认为0
* @retval TSDK_RESULT                                                   [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                                       [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
* @attention NA
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_display_rotation(IN TSDK_UINT32 call_id, IN TSDK_E_VIDEO_WND_TYPE window_type, IN TSDK_E_VIDEO_DISPLAY_ROTATOIN_TYPE display_rotation);

/**
* @ingroup Call
* @brief [en] This interface is used to set mobile video device information.
*        [cn] 设置视频方向
*
* @param [in] callid                                 [en] Indicates call Id
*                                                    [cn] 呼叫ID
* @param [in] index                                  [en] Indicates device index
*                                                    [cn] 设备(摄相头)索引
* @param [in] video_orient                           [en] Indicates video orient param
*                                                    [cn] 视频方向(横竖屏)参数
* @retval TSDK_RESULT                                [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                    [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en]Interface for mobile devices.
*            <br>[cn] 用于移动设备
* @see NA
**/
TSDK_API TSDK_RESULT tsdk_set_video_orient(IN TSDK_UINT32 call_id, IN TSDK_UINT32 index, IN TSDK_S_VIDEO_ORIENT *video_orient);

/**
* @brief [en] This interface is used to control data.
*        [cn] 辅流控制
*
* @param [in] call_id                            [en] Indicates call id.
*                                                [cn] 呼叫ID
* @retval TSDK_RESULT                            [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention NA
**/
TSDK_API TSDK_RESULT tsdk_aux_data_control(IN TSDK_UINT32 call_id, IN TSDK_S_VIDEO_CTRL_INFO *data_control);

/**
* @brief [en] This interface is used to restart audio stream at IOS app.
*        [cn] 在IOS端调用此接口重新打开音频流
**/
TSDK_API TSDK_VOID tsdk_call_audio_restart_stream(TSDK_VOID);

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif

