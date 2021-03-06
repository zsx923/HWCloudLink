/**
 * @file tsdk_call_def.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK call service module.
 */

#ifndef __TSDK_CALL_DEF_H__
#define __TSDK_CALL_DEF_H__

#include "tsdk_def.h"
#include "tsdk_manager_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */


#define TSDK_D_MAX_ACCESS_CODE_LEN                     (31)        /**< [en]Indicates the maximum length of access code.
                                                                        [cn]最大接入码长度*/
#define TSDK_D_MAX_VOLUME                             (100)        /**< [en]Indicates the maximum value of device volume.
                                                                        [cn]设备音量最大值*/

#define TSDK_D_MAX_CONF_TOKEN_LEN                     (256)        /**< [en]Indicates the maximum length of conference token.
                                                                        [cn]最大会控token长度*/

/**
 * [en]This enumeration is used to describe DTMF tone
 * [cn]DTMF键值
 */
typedef enum tagTSDK_E_DTMF_TONE
{
    TSDK_E_DTMF_0,       /**< [en]Indicates the DTMF button0
                              [cn]dtmf按键0 */
    TSDK_E_DTMF_1,       /**< [en]Indicates the DTMF button1
                              [cn]dtmf按键1 */
    TSDK_E_DTMF_2,       /**< [en]Indicates the DTMF button2
                              [cn]dtmf按键2 */
    TSDK_E_DTMF_3,       /**< [en]Indicates the DTMF button3
                              [cn]dtmf按键3 */
    TSDK_E_DTMF_4,       /**< [en]Indicates the DTMF button4
                              [cn]dtmf按键4 */
    TSDK_E_DTMF_5,       /**< [en]Indicates the DTMF button5
                              [cn]dtmf按键5 */
    TSDK_E_DTMF_6,       /**< [en]Indicates the DTMF button6
                              [cn]dtmf按键6 */
    TSDK_E_DTMF_7,       /**< [en]Indicates the DTMF button7
                              [cn]dtmf按键7 */
    TSDK_E_DTMF_8,       /**< [en]Indicates the DTMF button8
                              [cn]dtmf按键8 */
    TSDK_E_DTMF_9,       /**< [en]Indicates the DTMF button9
                              [cn]dtmf按键9 */
    TSDK_E_DTMF_STAR,    /**< [en]Indicates the DTMF button *
                              [cn]dtmf按键'*' */
    TSDK_E_DTMF_POUND,   /**< [en]Indicates the DTMF button #
                              [cn]dtmf按键'#' */
    TSDK_E_DTMF_A,       /**< [en]Indicates the DTMF button A
                              [cn]dtmf按键A */
    TSDK_E_DTMF_B,       /**< [en]Indicates the DTMF button B
                              [cn]dtmf按键B */
    TSDK_E_DTMF_C,       /**< [en]Indicates the DTMF button C
                              [cn]dtmf按键C */
    TSDK_E_DTMF_D,       /**< [en]Indicates the DTMF button D
                              [cn]dtmf按键D */
    TSDK_E_DTMF_FLASH,   /**< [en]Indicates the DTMF button FLASH, reserved, no use at present
                              [cn]dtmf按键FLASH，预留，暂无使用 */
    TSDK_E_BUTT
} TSDK_E_DTMF_TONE;


/**
 * [en]This enumeration is used to describe call basic state.
 * [cn]呼叫基本状态
 */
typedef enum tagTSDK_E_CALL_STATE
{
    TSDK_E_CALL_STATE_IDLE,                 /**< [en]Indicates idle state
                                                 [cn]空闲态 */
    TSDK_E_CALL_STATE_IN,                   /**< [en]Indicates call incoming
                                                 [cn]呼入态 */
    TSDK_E_CALL_STATE_OUT,                  /**< [en]Indicates call outgoing
                                                 [cn]呼出态 */
    TSDK_E_CALL_STATE_LIVE,                 /**< [en]Indicates calling
                                                 [cn]通话态 */
    TSDK_E_CALL_STATE_HOLD,                 /**< [en]Indicates holding
                                                 [cn]保持态 */
    TSDK_E_CALL_STATE_END,                  /**< [en]Indicates call end
                                                 [cn]结束态 */
    TSDK_E_CALL_STATE_BUTT
} TSDK_E_CALL_STATE;

/**
*[en]This structure is used to describe share status
*[cn]辅流共享状态
*/
typedef enum tagTSDK_AUX_SHARE_STATUS {
    TSDK_E_AUX_STOPED,                      /**< [en]Indicates aux share stoped
                                                 [cn]停止共享 */
    TSDK_E_AUX_SENDING,                     /**< [en]Indicates aux sharing
                                                 [cn]共享中 */
    TSDK_E_AUX_RECEIVING,                   /**< [en]Indicates aux reciving
                                                 [cn]共享接收端 */
    TSDK_E_AUX_BUTT
}TSDK_AUX_SHARE_STATE;

/**
 * [en]This enumeration is used to describe the device type.
 * [cn]设备类型
 */
typedef enum tagTSDK_E_DEVICE_TYPE
{
    TSDK_E_DEVICE_MIC,                      /**< [en]Indicates microphone.
                                                 [cn]麦克风 */
    TSDK_E_DEVICE_SPEAKER,                  /**< [en]Indicates loudspeaker.
                                                 [cn]扬声器 */
    TSDK_E_DEVICE_CAMERA,                   /**< [en]Indicates camera.
                                                 [cn]摄相头 */
    TSDK_E_DEVICE_BUTT
}TSDK_E_DEVICE_TYPE;

/**
* [en]This enumeration is used to describe the audio input and output device type.
* [cn]音频输入输出设备类型
*/
typedef enum tagTSDK_E_AUDDEV_ROUTE
{
    TSDK_E_AUD_DEV_ROUTE_DEFAULT = 0x0,  /**< [en]Indicates reserved value, which does not take effect when this value is set
                                         <br>[cn]保留值，设置不生效 */
    TSDK_E_AUD_DEV_ROUTE_LOUDSPEAKER = 0x1,  /**< [en]Indicates speakerphone, both input and output supported
                                             <br>[cn]扬声器 ，支持输入输出 */
    TSDK_E_AUD_DEV_ROUTE_BLUETOOTH = 0x2,  /**< [en]Indicates bluetooth headset, both input and output supported
                                           <br>[cn]蓝牙耳机 ，支持输入输出，支持蓝牙的设备使用，如手机，IP话机 */
    TSDK_E_AUD_DEV_ROUTE_EARPIECE = 0x3,  /**< [en]Indicates handset, both input and output supported
                                          <br>[cn]听筒 手柄设备，支持输入输出，IP话机使用 */
    TSDK_E_AUD_DEV_ROUTE_HEADSET = 0x4,  /**< [en]Indicates 3.5 mm headset, both input and output supported
                                         <br>[cn]3.5毫米耳机 ，支持输入输出，支持3.5毫米耳机的设备使用，如手机，IP话机 */
    TSDK_E_AUD_DEV_ROUTE_SUBDEFAULT = 0x5,  /**< [en]Indicates reserved value, which does not take effect when this value is set
                                            <br>[cn]保留值，设置不生效 */
    TSDK_E_AUD_DEV_ROUTE_HDMI = 0x6,  /**< [en]Indicates HDMI, input supported
                                      <br>[cn]HDMI,支持输出，IP话机及其他盒子类设备使用 */
    TSDK_E_AUD_DEV_ROUTE_USB = 0x7,  /**< [en]Indicates USB headset, both input and output supported
                                     <br>[cn]USB耳机 ，支持输入输出，IP话机使用 */
    TSDK_E_AUD_DEV_ROUTE_MAX = 0X8   /**< [en]Indicates invalid value
                                     <br>[cn]无效值 */
} TSDK_E_AUDDEV_ROUTE;


/**
 * [en]This enumeration is used to describe video orientation.
 * [cn]视频方向(横竖屏)
 */
typedef enum tagTSDK_E_VIDEO_ORIENTATION
{
    TSDK_E_VIDEO_ORIENTATION_DEVICE_DEFAULT,            /**< [en]Indicates device defalut orientation
                                                             [cn]设备默认方向 */
    TSDK_E_VIDEO_ORIENTATION_VERTICAL_SCREEN,           /**< [en]Indicates vertical screen
                                                             [cn]竖屏 */
    TSDK_E_VIDEO_ORIENTATION_HORIZONTAL_SCREEN,         /**< [en]Indicates horizontal screen
                                                             [cn]横屏 */
    TSDK_E_VIDEO_ORIENTATION_REVERSE_HORIZONTAL_SCREEN, /**< [en]Indicates reverse horizontal screen
                                                             [cn]反向横屏 */
    TSDK_E_VIDEO_ORIENTATION_BUTT
} TSDK_E_VIDEO_ORIENTATION;


/**
 * [en]This enumeration is used to describe video view type.
 * [cn]视频视图类型
 */
typedef enum tagTSDK_E_VIDEO_VIEW_TYPE
{
    TSDK_E_VIEW_LOCAL_PREVIEW = 1,          /**< [en]Indicates local video preview
                                                 [cn]本地视频预览 */
    TSDK_E_VIEW_VIDEO_VIEW = 2,             /**< [en]Indicates general video
                                                 [cn]普通视频 */
    TSDK_E_VIEW_AUX_DATA_VIEW = 3,          /**< [en]Indicates auxiliary data
                                                 [cn]辅流视频 */
    TSDK_E_VIDEO_VIEW_BUTT
} TSDK_E_VIDEO_VIEW_TYPE;



/**
 * [en]This enumeration is used to describe video view refresh events.
 * [cn]视频视图刷新事件
 */
typedef enum tagTSDK_E_VIDEO_VIEW_REFRESH_EVENT
{
    TSDK_E_VIDEO_LOCAL_VIEW_ADD = 1,        /**< [en]Indicates add local view
                                                 [cn]本地view添加 */
    TSDK_E_VIDEO_LOCAL_VIEW_REMOVE          /**< [en]Indicates remove local view
                                                 [cn]本地view删除 */
} TSDK_E_VIDEO_VIEW_REFRESH_EVENT;


/**
 * [en]This enumeration is used to describe the video window type.
 * [cn]视频窗口类型
 */
typedef enum tagTSDK_E_VIDEO_WND_TYPE
{
    TSDK_E_VIDEO_WND_REMOTE = 0,                /**< [en]Indicates remote video window
                                                     [cn]通话远端窗口 */
    TSDK_E_VIDEO_WND_LOCAL,                     /**< [en]Indicates local video window
                                                     [cn]通话本地窗口 */
    TSDK_E_VIDEO_WND_PREVIEW,                   /**< [en]Indicates preview window
                                                     [cn]预览窗口 */
    TSDK_E_VIDEO_WND_AUX_DATA,                  /**< [en]Indicates auxiliary data window
                                                     [cn]辅流窗口 */
    TSDK_E_VIDEO_WND_BUTT
} TSDK_E_VIDEO_WND_TYPE;


/**
 * [en]This enumeration is used to describe the video window display type
 * [cn]视频窗口显示类型
 */
typedef enum tagTSDK_E_VIDEO_WND_DISPLAY_MODE
{
    TSDK_E_VIDEO_WND_DISPLAY_ZOOM = 0,          /**< [en]Indicates stretch mode
                                                     [cn]拉伸模式 */
    TSDK_E_VIDEO_WND_DISPLAY_CUT,               /**< [en]Indicates (no stretch) black border mode
                                                     [cn](不拉伸)黑边模式   */
    TSDK_E_VIDEO_WND_DISPLAY_FULL,              /**< [en]Indicates (no stretch) crop mode
                                                     [cn](不拉伸)裁剪模式    */
    TSDK_E_VIDEO_WND_DISPLAY_BUTT
} TSDK_E_VIDEO_WND_DISPLAY_MODE;


/**
 * [en]This enumeration is used to describe the video window mirror type
 * [cn]视频窗口镜像类型
 */
typedef enum tagTSDK_E_VIDEO_WND_MIRROR_TYPE
{
    TSDK_E_VIDEO_WND_MIRROR_DEFAULE = 0,        /**< [en]Indicates no mirror (default type)
                                                     [cn]0:不做镜像(默认值) */
    TSDK_E_VIDEO_WND_MIRROR_VERTICAL,           /**< [en]Indicates vertical mirror type(x axis mirror)(not support at present)
                                                     [cn]1:垂直镜像(X轴镜像)(目前未支持)   */
    TSDK_E_VIDEO_WND_MIRROR_HORIZONTAL,         /**< [en]Indicates horizontal mirror type(y axis mirror)
                                                     [cn]2:水平镜像(Y轴镜像)   */
    TSDK_E_VIDEO_WND_MIRROR_BUTT
} TSDK_E_VIDEO_WND_MIRROR_TYPE;



/**
* [en]This enumeration is used to describe the Camera capture angle type
* [cn]摄像头采集角度类型
*/
typedef enum tagTSDK_E_VIDEO_CAPTURE_ROTATOIN_TYPE
{
    TSDK_E_VIDEO_CAPTURE_ROTATOIN_DEFAULE = 0,        /**< [en]Camera capture angle: 0 degrees (default type)
                                                           [cn]0:摄像头采集角度 0 度(默认值) */
    TSDK_E_VIDEO_CAPTURE_ROTATOIN_90,                 /**< [en]Camera capture angle: 90 degrees
                                                           [cn]1:摄像头采集角度 90 度  */
    TSDK_E_VIDEO_CAPTURE_ROTATOIN_180,                /**< [en]Camera capture angle: 180 degrees
                                                           [cn]2:摄像头采集角度 180 度 */
    TSDK_E_VIDEO_CAPTURE_ROTATOIN_270,              /**< [en]Camera capture angle: 270 degrees
                                                           [cn]2:摄像头采集角度 270 度 */
    TSDK_E_VIDEO_CAPTURE_ROTATOIN_BUTT
} TSDK_E_VIDEO_CAPTURE_ROTATOIN_TYPE;



/**
* [en]This enumeration is used to describe the Collection device (camera) index type
* [cn]采集设备(摄像头)索引类型
*/
typedef enum tagTSDK_E_VIDEO_CAPTURE_INDEX_TYPE
{
    TSDK_E_VIDEO_CAPTURE_INDEX_REAR = 0,          /**< [en]Rear camera (default type)
                                                      [cn]0:后置摄像头 */
    TSDK_E_VIDEO_CAPTURE_INDEX_FRONT,             /**< [en]Front camera
                                                      [cn]1:前置摄像头 */
    TSDK_E_VIDEO_CAPTURE_INDEX_BUTT
} TSDK_E_VIDEO_CAPTURE_INDEX_TYPE;



/**
* [en]This enumeration is used to describe the Window display angle type
* [cn]窗口显示角度类型
*/
typedef enum tagTSDK_E_VIDEO_DISPLAY_ROTATOIN_TYPE
{
    TSDK_E_VIDEO_DISPLAY_ROTATOIN_DEFAULE = 0,        /**< [en]Window display angle: 0 degrees (default type)
                                                      [cn]0:窗口显示角度 0 度(默认值) */
    TSDK_E_VIDEO_DISPLAY_ROTATOIN_90,                 /**< [en]Window display angle: 90 degrees
                                                      [cn]1:窗口显示角度 90 度  */
    TSDK_E_VIDEO_DISPLAY_ROTATOIN_180,                /**< [en]Window display angle: 180 egrees
                                                      [cn]2:窗口显示角度 180 度 */
    TSDK_E_VIDEO_DISPLAY_ROTATOIN_270,              /**< [en]Window display angle: 270 egrees
                                                      [cn]2:窗口显示角度 270 度 */
    TSDK_E_VIDEO_DISPLAY_ROTATOIN_BUTT
} TSDK_E_VIDEO_DISPLAY_ROTATOIN_TYPE;



/**
 * [en]This enumeration is used to describe the mobile audio route device type.
 * [cn]移动音频路由设备类型
 */
typedef enum  tagTSDK_E_MOBILE_AUIDO_ROUTE
{
    TSDK_E_MOBILE_AUDIO_ROUTE_DEFAULT = 0,      /**< [en]Indicates the default audio device, used to get, priority order: Bluetooth headset> Wired headset> Handset
                                                     [cn]默认音频设备，仅用于设置，优先级排序:蓝牙耳机>有线耳机>听筒 */
    TSDK_E_MOBILE_AUDIO_ROUTE_LOUDSPEAKER = 1,  /**< [en]Indicates speakerphone
                                                     [cn]扬声器，可用于获取和设置 */
    TSDK_E_MOBILE_AUDIO_ROUTE_BLUETOOTH = 2,    /**< [en]Indicates bluetooth
                                                     [cn]蓝牙，Android设备中可用于获取和设置，iOS设备中仅用于设置 */
    TSDK_E_MOBILE_AUDIO_ROUTE_EARPIECE = 3,     /**< [en]Indicates earpiece, used to get, set to retain, return error
                                                     [cn]听筒，仅用于获取，设置时填写此类型接口返回错误 */
    TSDK_E_MOBILE_AUDIO_ROUTE_HEADSET = 4,       /**< [en]Indicates headset, used to get, set to retain, return an error
                                                     [cn]耳机，仅用于获取，设置时填写此类型接口返回错误 */
    TSDK_E_MOBILE_AUDIO_ROUTE_BUTT
}TSDK_E_MOBILE_AUIDO_ROUTE;




/**
 * [en]This enumeration type  is used to describe video operation action.
 * [cn]视频控制操作动作
 */
typedef enum tagTSDK_E_VIDEO_CTRL_OPERATION_ACT
{
    TSDK_E_VIDEO_CTRL_OPEN      = 0x01,         /**< [en]Indicates turned on.
                                                     [cn]打开 */
    TSDK_E_VIDEO_CTRL_CLOSE     = 0x02,         /**< [en]Indicates turned off.
                                                     [cn]关闭 */
    TSDK_E_VIDEO_CTRL_START     = 0x04,         /**< [en]Indicates start.
                                                     [cn]启动 */
    TSDK_E_VIDEO_CTRL_STOP      = 0x08,         /**< [en]Indicates stopped.
                                                     [cn]停止 */
}TSDK_E_VIDEO_CTRL_OPERATION_ACT;


/**
 * [en]This enumeration is used to describe video control object type.
 * [cn]视频控制对象类型
 */
typedef enum tagTSDK_E_VIDEO_CTRL_OBJ
{
    TSDK_E_VIDEO_CTRL_REMOTE_WND = 0x01,        /**< [en]Indicates remote window
                                                     [cn]远端窗口 */
    TSDK_E_VIDEO_CTRL_LOCAL_WND  = 0x02,        /**< [en]Indicates local window
                                                     [cn]本地窗口 */
    TSDK_E_VIDEO_CTRL_CAMERA     = 0x04,        /**< [en]Indicates camera
                                                     [cn]摄相头 */
    TSDK_E_VIDEO_CTRL_ENCODER    = 0x08,        /**< [en]Indicates encoder
                                                     [cn]编码器 */
    TSDK_E_VIDEO_CTRL_DECODER    = 0x10         /**< [en]Indicates decoder
                                                     [cn]解码器 */
}TSDK_E_VIDEO_CTRL_OBJ;


/**
 * [en]This enumeration is used to describe the IPT service type
 * [cn]IPT业务类型
 */
typedef enum tagTSDK_E_IPT_SERVICE_TYPE
{
    TSDK_E_IPT_SERVICE_TYPE_BEGIN,

    TSDK_E_IPT_SERVICE_DND,                     /**< [en]Indicates DND(do not disturb)
                                                     [cn]请勿打扰 */
    TSDK_E_IPT_SERVICE_CALL_WAIT,               /**< [en]Indicates call waiting
                                                     [cn]呼叫等待 */
    TSDK_E_IPT_SERVICE_CFU,                     /**< [en]Indicates the server forwards unconditionally
                                                     [cn]无条件前转 */
    TSDK_E_IPT_SERVICE_CFB,                     /**< [en]Indicates the server forward on busy
                                                     [cn]遇忙前转 */
    TSDK_E_IPT_SERVICE_CFN,                     /**< [en]Indicates the server forward on reply
                                                     [cn]无应答前转 */
    TSDK_E_IPT_SERVICE_CFO,                     /**< [en]Indicates the server offline forward
                                                     [cn]离线前转 */
    TSDK_E_IPT_SERVICE_CFU_TO_VM,               /**< [en]Indicates the unconditional to voice mailbox
                                                     [cn]无条件转语音邮箱 */
    TSDK_E_IPT_SERVICE_CFB_TO_VM,               /**< [en]Indicates the busy to voice mailbox
                                                     [cn]遇忙转语音邮箱 */
    TSDK_E_IPT_SERVICE_CFN_TO_VM,               /**< [en]Indicates the no answer to voice mailbox
                                                     [cn]无应答转语音邮箱 */
    TSDK_E_IPT_SERVICE_CFO_TO_VM,               /**< [en]Indicates the offline to voice mailbox
                                                     [cn]离线转语音邮箱 */
    TSDK_E_IPT_SERVICE_CALL_ALERT,              /**< [en]Indicates the missed call alert service
                                                     [cn]来电提醒业务 */
    TSDK_E_IPT_SERVICE_TYPE_BUTT
}TSDK_E_IPT_SERVICE_TYPE;


/**
 * [en]This enumeration is used to describe reinvite event
 * [cn]reinvite 事件
 */
typedef enum tagTSDK_E_REINVITE_TYPE
{
    TSDK_E_REINVITE_NONE,                           /**< [en]Indicates none
                                                         [cn]无效事件 */
    TSDK_E_REINVITE_HOLD,                           /**< [en]Indicates hold event
                                                         [cn]保持事件 */
    TSDK_E_REINVITE_UNHOLD,                         /**< [en]Indicates unhold event
                                                         [cn]取消保持事件 */
    TSDK_E_REINVITE_BUTT                            /**< [en]Indicates BUTT
                                                         [cn]无效值  */
} TSDK_E_REINVITE_TYPE;

/**
* [en]This enumeration is used to describe the conference capability type.
* [cn]会议能力类型
*/
typedef enum tagTSDK_CALL_E_SVC_TYPE
{
    TSDK_CALL_E_SVC_TYPE_H264_SVC = 1,   /**< [en]Indicates H264 SVC
                                              [cn]H264 SVC */
    TSDK_CALL_E_SVC_TYPE_H265_SVC,       /**< [en]Indicates H265 SVC
                                              [cn]H265 SVC */
    TSDK_CALL_E_SVC_TYPE_BUTT
} TSDK_CALL_E_SVC_TYPE;

/**
 * [en]This enumeration is used to describe the media send mode.
 * [cn]媒体发送模式
 */
typedef enum tagTSDK_E_MEDIA_SEND_MODE
{
    TSDK_E_MEDIA_SEND_MODE_INACTIVE = 0x00,  /**< [en]Indicates neither send nor receive
                                                  [cn]不收不发 */
    TSDK_E_MEDIA_SEND_MODE_SENDONLY = 0x01,  /**< [en]Indicates send-only
                                                  [cn]只发 */
    TSDK_E_MEDIA_SEND_MODE_RECVONLY = 0x02,  /**< [en]Indicates receive-only
                                                  [cn]只收 */
    TSDK_E_MEDIA_SEND_MODE_SENDRECV = 0x04,  /**< [en]Indicates both send and receive
                                                  [cn]收发 */
    TSDK_E_MEDIA_SEND_MODE_INVALID  = 0x08   /**< [en]Indicates invalid
                                                  [cn]无效 */
}TSDK_E_MEDIA_SEND_MODE;


/**
 * [en]This enumeration is used to describe the media type.
 * [cn]媒体类型
 */
typedef enum tagTSDK_E_MEDIA_TYPE
{
    TSDK_E_MEDIA_AUDIO = 1,                /**< [en]Indicates audio
                                                [cn]音频*/
    TSDK_E_MEDIA_VIDEO,                    /**< [en]Indicates video
                                                [cn]视频 */
    TSDK_E_MEDIA_DATA,                     /**< [en]Indicates data
                                                [cn]辅流 */
    TSDK_E_MEDIA_BUTT                      /**< [en]Indicates BUTT
                                                [cn]无效值 */
}TSDK_E_MEDIA_TYPE;

/** 
 * [en]This enumeration is used to describe the audio capability type.
 * [cn]音频能力类型
 */
typedef enum tagTSDK_E_AUDIO_CAP
{
    TSDK_E_AUDIO_CAP_AACLD = 0,  /**< [en]Indicates audio ACC-LD  
                                      <br>[cn]AAC-LD */
    TSDK_E_AUDIO_CAP_G722_48K,   /**< [en]Indicates G722, Code rate:48K 
                                      <br>[cn]G722, 码率:48K */
    TSDK_E_AUDIO_CAP_G722_56K,   /**< [en]Indicates G722, Code rate:56K 
                                      <br>[cn]G722, 码率:56K */
    TSDK_E_AUDIO_CAP_G722_64K,   /**< [en]Indicates G722, Code rate:64K 
                                      <br>[cn]G722, 码率:64k */
    //G7221B24,G7221B32,G7221Ex均属于G.722.1_C，G.722.1_C是G.722.1的扩展。
    //G7221Ex  : 采样32K，码率48K
    //G7221B24 : 采样16K，码率24K
    //G7221B32 : 采样16K，码率32K
    TSDK_E_AUDIO_CAP_G7221,      /**< [en]Indicates G722.1 
                                      <br>[cn]G722.1  */
    TSDK_E_AUDIO_CAP_G7222,      /**< [en]Indicates G722.2 
                                      <br>[cn]G722.2 */
    TSDK_E_AUDIO_CAP_G711A,      /**< [en]Indicates G711A  
                                      <br>[cn]G711A */
    TSDK_E_AUDIO_CAP_G711U,      /**< [en]Indicates G711U
                                      <br>[cn]G711U  */
    TSDK_E_AUDIO_CAP_G729,       /**< [en]Indicates G729 
                                      <br>[cn]G729 */
    TSDK_E_AUDIO_CAP_G729AB,     /**< [en]Indicates G729AB
                                      <br>[cn]G729AB */
    TSDK_E_AUDIO_CAP_G726,       /**< [en]Indicates G726  
                                      <br>[cn]G726 */
    TSDK_E_AUDIO_CAP_ILBC,       /**< [en]Indicates ILBC  
                                      <br>[cn]ILBC */
    TSDK_E_AUDIO_CAP_OPUS,       /**< [en]Indicates OPUS  
                                      <br>[cn]OPUS */
    TSDK_E_AUDIO_CAP_DTMF,       /**< [en]Indicates DTMF 
                                      <br>[cn]DTMF */
    TSDK_E_AUDIO_CAP_G719,       /**< [en]Indicates G719
                                      <br>[cn]G719  */
    TSDK_E_AUDIO_CAP_G728,       /**< [en]Indicates G728
                                      <br>[cn]G728  */
    TSDK_E_AUDIO_CAP_G7231,      /**< [en]Indicates G7231_5K3,G7231_6K3
                                      <br>[cn]G7231_5K3,G7231_6K3 */
    TSDK_E_AUDIO_CAP_AACLC,      /**< [en]Indicates AAC-LC
                                      <br>[cn]AAC-LC  */
    TSDK_E_AUDIO_CAP_HWALD,      /**< [en]Indicates HW-ALD
                                      <br>[cn]HW-ALD  */
    TSDK_E_AUDIO_CAP_AMR,        /**< [en]Indicates AMR
                                      <br>[cn]AMR  */
    TSDK_E_AUDIO_CAP_BUTT
}TSDK_E_AUDIO_CAP;

/** 
 * [en]This enumeration is used to describe the ID of which support video capabilities, it's used to configure capacity priority and related usage
 * [cn]支持的视频能力的ID, 用于能力优先级配置及相关使用
 */
typedef enum tagTSDK_E_VIDEOCAP
{
    TSDK_E_CAP_MPEG_STD,        /**< [en]Indicates MPEG STD 
                                     <br>[cn]MPEG STD */
    TSDK_E_CAP_H264_BASE,       /**< [en]Indicates H264 BP
                                     <br>[cn]H264 BP  */
    TSDK_E_CAP_H264_MAIN,       /**< [en]Indicates H264 MP
                                     <br>[cn]H264 MP  */
    TSDK_E_CAP_H264_HIGH,       /**< [en]Indicates H264 HP
                                     <br>[cn]H264 HP  */
    TSDK_E_CAP_H264_SVC,        /**< [en]Indicates H264 SVC
                                     <br>[cn]H264 SVC  */
    TSDK_E_CAP_H263CUS_SIF,     /**< [en]Indicates H263 SIF
                                     <br>[cn]H263 SIF  */
    TSDK_E_CAP_H263CUS_4SIF,    /**< [en]Indicates H263 4SIF
                                     <br>[cn]H263 4SIF  */
    TSDK_E_CAP_H263CUS_VGA,     /**< [en]Indicates H263 VGA
                                     <br>[cn]H263 VGA  */
    TSDK_E_CAP_H263CUS_SVGA,    /**< [en]Indicates H263 SVGA
                                     <br>[cn]H263 SVGA  */
    TSDK_E_CAP_H263CUS_XGA,     /**< [en]Indicates H263 XGA
                                     <br>[cn]H263 XGA  */
    TSDK_E_CAP_H26316CIF,       /**< [en]Indicates H263 16CIF
                                     <br>[cn]H263 16CIF  */
    TSDK_E_CAP_H2634CIF,        /**< [en]Indicates H263 4CIF 
                                     <br>[cn]H263 4CIF  */
    TSDK_E_CAP_MPEG4CIF,        /**< [en]Indicates MPEG 4CIF
                                     <br>[cn]MPEG 4CIF  */
    TSDK_E_CAP_H263CIF,         /**< [en]Indicates H263 CIF 
                                     <br>[cn]H263 CIF  */
    TSDK_E_CAP_H261CIF,         /**< [en]Indicates H261 CIF
                                     <br>[cn]H261 CIF  */
    TSDK_E_CAP_MPEG4QCIF,       /**< [en]Indicates MPEG4 QCIF
                                     <br>[cn]MPEG4 QCIF  */
    TSDK_E_CAP_H263QCIF,        /**< [en]Indicates 263 QCIF
                                     <br>[cn]H263 QCIF  */
    TSDK_E_CAP_H261QCIF,        /**< [en]Indicates H261 QCIF
                                     <br>[cn]H261 QCIF  */
    TSDK_E_CAP_H263SQCIF,       /**< [en]Indicates H263 SQCIF
                                     <br>[cn]H263 SQCIF  */
    TSDK_E_CAP_MSRTV,           /**< [en]Indicates MS RTV  
                                     <br>[cn]MS RTV  */
    TSDK_E_CAP_MSH264UC,        /**< [en]Indicates MS H264 UC
                                     <br>[cn]MS H264 UC  */
    TSDK_E_CAP_H264EC,          /**< [en]Indicates H264 EC
                                     <br>[cn] H264 EC  */
    TSDK_E_CAP_H265_MAIN,       /**< [en]Indicates H265 
                                     <br>[cn] H265  */
    TSDK_E_VIDEO_DETAIL_CAP_BUTT
} TSDK_E_VIDEO_DETAIL_CAP;

/**
*[en]The structure is used to describe the actual video information.
*[cn]视频色域信息，保存能力协商结果
*/
typedef enum  tagTSDK_E_GAMUT_TYPE
{
	TSDK_E_GAMUT_BT601 = 0,                                  /**< [en]Indicates BT601 [cn]bt601色域 */
	TSDK_E_GAMUT_BT709,                                      /**< [en]Indicates BT709 [cn]bt709色域 */
	TSDK_E_GAMUT_BT2020,                                     /**< [en]Indicates BT2020 [cn]bt2020色域 */
	TSDK_E_GAMUT_BUTT
}TSDK_E_GAMUT_TYPE;

/*
* [en]This enumeration is used to describe  decode successful type of media type.
* [cn]解码成功的视频媒体类型
*/
typedef enum tagTSDK_E_DECODE_SUCCESS_MIDEATYPE
{
    TSDK_E_DECODE_SUCCESS_VIDEO = 2,        /**< [en]Indicates general video
                                                 [cn]普通视频 */
    TSDK_E_DECODE_SUCCESS_DATA = 3,         /**< [en]Indicates auxiliary data
                                                 [cn]辅流 */
    TSDK_E_DECODE_BUTT                      /**< [en]Indicates BUTT
                                                 [cn]无效值 */
} TSDK_E_DECODE_SUCCESS_MIDEATYPE;

/**
* [en]This structure is used to describe the video resolution Strategy.
* [cn]视频清晰度策略 高清1080P，标清720P，普清360P
*/
typedef enum tagTSDK_E_VIDEO_DEFINITION_POLICY
{
    TSDK_E_VIDEO_DEFINITION_HD = 1,                  /**< [en]Default value，Indicates HD, max resolution is 1080P
                                                     [cn] 默认值， 高清，最高分辨率1080P，自动降速*/
    TSDK_E_VIDEO_DEFINITION_SD = 2,                  /**< [en] Standard  definition, max resolution is 720P
                                                     [cn] 标清，最高分辨率720P，自动降速 */
    TSDK_E_VIDEO_DEFINITION_PD = 3,                  /**< [en] Normal definition, max resolution is 360P
                                                     [cn] 普清，最高分辨率360P，自动降速  */
    TSDK_E_VIDEO_QUALITY_BUTT                        /**< [en]Indicates BUTT
                                                     [cn]无效值 */
}TSDK_E_VIDEO_DEFINITION_POLICY;

/**
* [en]This enumeration is user-defined bandwidth level
* [cn]用户自定义带宽档位
*/
typedef enum tagTSDK_E_USER_DEF_BANDWIDTH_LEVEL
{
    TSDK_E_USER_DEF_BANDWIDTH_512K = 0,

    TSDK_E_USER_DEF_BANDWIDTH_768K,

    TSDK_E_USER_DEF_BANDWIDTH_1024K,

    TSDK_E_USER_DEF_BANDWIDTH_1152K,

    TSDK_E_USER_DEF_BANDWIDTH_1472K,

    TSDK_E_USER_DEF_BANDWIDTH_1536K = 5,

    TSDK_E_USER_DEF_BANDWIDTH_2M,

    TSDK_E_USER_DEF_BANDWIDTH_2048K,

    TSDK_E_USER_DEF_BANDWIDTH_3M,

    TSDK_E_USER_DEF_BANDWIDTH_4M,

    TSDK_E_USER_DEF_BANDWIDTH_5M = 10,

    TSDK_E_USER_DEF_BANDWIDTH_6M,

    TSDK_E_USER_DEF_BANDWIDTH_7M,

    TSDK_E_USER_DEF_BANDWIDTH_8M,

    TSDK_E_USER_DEF_BANDWIDTH_BUTT

} TSDK_E_USER_DEF_BANDWIDTH_LEVEL;

/**
* [en]This enumeration is used to describe device change type.
* [cn]设备改变类型
*/
typedef enum tagTSDK_E_DEVICE_CHANGED
{
    TSDK_E_DEVICE_CHANGED_AUDIO_INPUT,              /**< [en]Indicates audio input device change
                                                         [cn]音频输入设备发生改变 */
    TSDK_E_DEVICE_CHANGED_AUDIO_OUTPUT,             /**< [en]Indicates audio output device change
                                                         [cn]音频输出设备发生改变 */
    TSDK_E_DEVICE_CHANGED_BUTT                      /**< [en]Indicates BUTT
                                                         [cn]无效值 */
} TSDK_E_DEVICE_CHANGED;

/**
* [en]Headset plug-in type on the mobile phone.
* [cn]手机端耳机插拔类型。
*/
typedef enum tagTsdkMobileAudioDeviceStatus {
    TSDK_E_MOBILE_AUDIO_BLUETOOTH_OUTPUT = 0,          /**< [en]Indicates bluetooth output
                                                            [cn]断开蓝牙耳机连接 */
    TSDK_E_MOBILE_AUDIO_BLUETOOTH_INPUT,               /**< [en]Indicates bluetooth input
                                                            [cn]连接蓝牙耳机 */
    TSDK_E_MOBILE_AUDIO_HEADSET_OUT,                   /**< [en]Indicates android headset out
                                                            [cn]有线耳机拔出 */
    TSDK_E_MOBILE_AUDIO_HEADSET_IN,                    /**< [en]Indicates android headset in
                                                            [cn]有线耳机耳机插入 */
    TSDK_E_MOBILE_AUDIO_BUTT                           /**< [en]Indicates BUTT
                                                            [cn]无效值 */
} TsdkMobileAudioDeviceStatus;

/**
 * [en]This structure is used to describe call information.
 * [cn]呼叫信息
 */
typedef struct tagTSDK_S_CALL_INFO
{
    TSDK_UINT32 call_id;                                                        /**< [en]Indicates call id
                                                                                     [cn]呼叫id*/
    TSDK_BOOL is_caller;                                                        /**< [en]Indicates the caller.
                                                                                     [cn]是否为主叫*/
    TSDK_BOOL is_video_call;                                                    /**< [en]Indicates video call
                                                                                     [cn]是否为视频呼叫*/
    TSDK_CHAR peer_number[TSDK_D_MAX_NUMBER_LEN + 1];                           /**< [en]Indicates peer number
                                                                                     [cn]对端号码*/
    TSDK_CHAR peer_display_name[TSDK_D_MAX_DISPLAY_NAME_LEN + 1];               /**< [en]Indicates peer display name
                                                                                     [cn]对端名称*/
    TSDK_E_CALL_STATE call_state;                                               /**< [en]Indicates call state
                                                                                     [cn]呼叫状态*/
    TSDK_BOOL is_auto_answer;                                                   /**< [en]Indicates auto answer
                                                                                     [cn]是否为自动应答*/
    TSDK_BOOL is_focus;                                                         /**< [en]Indicates carry isfoucs or not, used in the mobile conference scenario
                                                                                     [cn]是否带isfoucs标识*/
    TSDK_CHAR conf_id[TSDK_D_MAX_CONF_ID_LEN + 1];                              /**< [en]Indicates conference id
                                                                                     [cn]会议id*/
    TSDK_INT32 reason_code;                                                     /**< [en]Indicates reason code
                                                                                     [cn]原因码*/
    TSDK_CHAR reason_description[TSDK_D_MAX_REASON_DESCRPTION_LEN + 1];         /**< [en]Indicates reason description
                                                                                     [cn]原因描述*/
    TSDK_CHAR conf_passcode[TSDK_D_MAX_CONF_ID_LEN + 1];                        /**< [en]Indicates conference passcode
                                                                                     [cn]会议passcode*/
    TSDK_UINT32 sip_account_id;                                                 /**< [en]Indicates the ID of the call line. 
                                                                                     [cn]通话所属线路ID */
    TSDK_BOOL is_svc_call;                                                      /**< [en]Indicates SVC conf
                                                                                     [cn]是否是SVC会议 */
    TSDK_UINT32 bandWidth;                                                      /**< [en]Indicates band width.
                                                                                     [cn]会场带宽 */
    TSDK_UINT32 svc_ssrc_table[2];                                              /**< [en]Indicates ssrc table.
                                                                                     [cn]ssrc范围值 */
    TSDK_AUX_SHARE_STATE auxStatus;                                             /**< [en]Indicates aux_status.
                                                                                     [cn]辅流共享状态 */
    TSDK_BOOL isSameCallId;                                                     /**< [en]Indicates call id is same.
                                                                                     [cn]呼叫ID是否一致 */
    TSDK_CALL_E_SVC_TYPE svcConfType;                                           /**< [en]Indicates Conference type (H264/H265)
                                                                                     [cn]会议能力(H264/H265) */
    TSDK_UINT32 sysCpuUtilization;                                              /**< [en]Indicates system CPU utilization.
                                                                                     [cn]系统cpu占用率 */
    TSDK_UINT32 realTimeBandWidth;                                              /**< [en]Indicates Real-Time BandWidth.
                                                                                     [cn]实时带宽 */
} TSDK_S_CALL_INFO;


/**
 * [en]This structure is used to describe video view refresh information.
 * [cn]视频视图刷新信息
 */
typedef struct tagTSDK_S_VIDEO_VIEW_REFRESH
{
    TSDK_E_VIDEO_VIEW_TYPE view_type;           /**< [en]Indicates video view type.
                                                     [cn]view刷新媒体类型 */
    TSDK_E_VIDEO_VIEW_REFRESH_EVENT event;      /**< [en]Indicates view refresh event.
                                                     [cn]view刷新事件 */
} TSDK_S_VIDEO_VIEW_REFRESH;


/**
 * [en]This structure is used to describe the coordinate info.
 * [cn]坐标信息
 */
typedef struct tagTSDK_S_COORDINATE_INFO
{
    TSDK_INT32 coordinate_x;                    /**< [en]Indicates X coordinate
                                                     [cn]X 轴 */
    TSDK_INT32 coordinate_y;                    /**< [en]Indicates Y coordinate
                                                     [cn]Y 轴 */
    TSDK_INT32 coordinate_w;                    /**< [en]Indicates width
                                                     [cn]宽 */
    TSDK_INT32 coordinate_h;                    /**< [en]Indicates height
                                                     [cn]高 */
    TSDK_INT32 coordinate_z;                    /**< [en]Indicates Z coordinate
                                                     [cn]Z 轴 */
}TSDK_S_COORDINATE_INFO;


/**
 * [en]This structure is used to describe the video window information.
 * [cn]视频窗口信息
 */
typedef struct tagTSDK_S_VIDEO_WND_INFO
{
    TSDK_E_VIDEO_WND_TYPE video_wnd_type;       /**< [en]Indicates video window type.
                                                     [cn]视频窗口类型 */
    TSDK_S_COORDINATE_INFO coordinate;          /**< [en]Indicates coordinate info.
                                                     [cn]坐标信息 */
    TSDK_UPTR render;                           /**< [en]Indicates window render.
                                                     [cn]窗口句柄*/
    TSDK_INT32 index;                           /**< [en]Indicates window index.
                                                     [cn]窗口序号*/
    TSDK_UINT32 session_id;                     /**< [en]Indicates local preview session ID.
                                                     [cn]本地预览session值*/
    TSDK_UINT32 ref_count;                      /**< [en]Indicates use reference count.
                                                     [cn]使用引用计数*/
    TSDK_E_VIDEO_WND_DISPLAY_MODE display_mode;                 /**< [en]Indicates display mode.
                                                                     [cn]显示模式 */
    TSDK_CHAR  start_image_file_path[TSDK_D_MAX_PATH_LEN + 1];  /**< [en]Indicates initial image of the video display, which must be .jpeg image and whose length and width must be multiples of eight.
                                                                     [cn]视频显示初始图像，必须为jpeg图像，且长宽都是8的倍数*/
} TSDK_S_VIDEO_WND_INFO;

/**
* [en]This structure is used to describe the svc window info.

* [cn]多流窗口信息
*/
typedef struct tagTSDK_S_SVC_VIDEO_WND_INFO
{
    TSDK_UPTR    render;                              /**< [en]Window handle. [cn]窗口句柄*/
    TSDK_UINT32  lable;                               /**< [en]lable. [cn]每个窗口需要关联的lable值*/
    TSDK_UINT32  width;                               /**< [en]Width of the svc window. It MUST be set when the ec-pktmode setting to EC-61. [cn]窗口宽，模式设置为EC6.1时必须设置*/
    TSDK_UINT32  height;                              /**< [en]Height of the svc window. It MUST be set when the ec-pktmode setting to EC-61.  [cn]窗口高，模式设置为EC6.1时必须设置*/
    TSDK_BOOL    is_sharpness;                        /**< [en]enable hme sharpness. It MUST be set when the ec-pktmode setting to EC-61.  [cn]是否使能锐化模式，模式设置为EC6.1时必须设置*/
    TSDK_UINT32  max_band_width;                      /**< [en]Max bandwidth of one svc channel according to the resolution table  [cn]多流接收方向每一路流的最大带宽 */
} TSDK_S_SVC_VIDEO_WND_INFO;

/**
* [en]This struct is watch attendee list.
* [cn]选看与会者总列表信息
*/
typedef struct tagTSDK_S_SVC_SET_WATCH_LIST_INFO
{
    TSDK_UINT32 attendNum;                                        /**< [en]Indicates watch attendee number.
                                                                       [cn]选看与会者总个数 */
    TSDK_S_SVC_VIDEO_WND_INFO attendWndInfo[TSDK_D_MAX_SVC_NUM];  /**< [en]Indicates svc attendee windows info list.
                                                                       [cn]选看与会者窗口信息列表 */
} TSDK_S_SVC_SET_WATCH_LIST_INFO;

/**
 * [en]This structure is used to describe the video control information.
 * [cn]视频控制信息
 */
typedef struct tagTSDK_S_VIDEO_CTRL_INFO
{
    TSDK_UINT32 operation;                      /**< [en]Indicates operation action, value of TSDK_E_VIDEO_CTRL_OPERATION_ACT, can use logical operators "|" combine, open|start，close|stop .
                                                     [cn]操作动作，取值:TSDK_E_VIDEO_CTRL_OPERATION_ACT，可以使用逻辑运算符"|"连接，open|start，close|stop */
    TSDK_UINT32 object;                         /**< [en]Indicates video control object, value of TSDK_E_VIDEO_CTRL_OBJ, can use logical operators "|" combine.
                                                     [cn]视频控制对象，取值: TSDK_E_VIDEO_CTRL_OBJ，可以使用逻辑运算符"|"连接 */
    TSDK_BOOL is_sync;                          /**< [en]Indicates whether to use synchronous execution.
                                                     [cn]是否使用同步执行,ios8.3使用异步，否则在切后台时调用该接口会被系统迅速挂起导致崩溃卡死 */
}TSDK_S_VIDEO_CTRL_INFO;


/**
 * [en]This structure is used to describe the device information.
 * [cn]设备信息
 */
typedef struct tagTSDK_S_DEVICE_INFO
{
    TSDK_UINT32 device_id;                                          /**< [en]Indicates device ID.
                                                                         [cn]设备ID */
    TSDK_UINT32 index;                                              /**< [en]Indicates device index.
                                                                         [cn]设备索引 */
    TSDK_CHAR device_name[TSDK_CALL_D_MAX_LENGTH_NUM + 1];         /**< [en]Indicates device name.
                                                                         [cn]设备名称 */
    TSDK_UINT32 camera_orient;                                      /**< [en]Indicates the camera orient, only the mobile platform camera device has a value.
                                                                         [cn]摄像头角度，仅移动平台摄像头设备有值 */
}TSDK_S_DEVICE_INFO;

/**
* 视频输入/输出设备信息
*/
typedef struct tagTsdkVideoDeviceInfo
{
    TSDK_UINT8 captureNum;                                /**< [en]Indicates capture num.
                                                               [cn]摄像头数目 */
    TSDK_S_DEVICE_INFO captures[TSDK_D_MAX_DEVICE_NUM];   /**< [en]Indicates capture device info.
                                                               [cn]视频设备信息 */
} TsdkVideoDeviceInfo;

/**
 * [en]This structure is used to describe the IPT service access code.
 * [cn]IPT业务特征码
 */
typedef struct tagTSDK_S_SERVICE_ACCESS_CODE
{
    TSDK_CHAR active_access_code[TSDK_D_MAX_ACCESS_CODE_LEN + 1];       /**< [en]Indicates active access code.
                                                                             [cn]激活业务接入码 */
    TSDK_CHAR deactive_access_code[TSDK_D_MAX_ACCESS_CODE_LEN + 1];     /**< [en]Indicates deactive access code.
                                                                             [cn]去激活业务接入码 */
}TSDK_S_SERVICE_ACCESS_CODE;


/**
 * [en]This structure is used to describe the feature codes service type
 * [cn]特征码业务类型
 */
typedef struct tagTSDK_S_IPT_SERVICE_CONFIG_PARAM
{
    TSDK_S_SERVICE_ACCESS_CODE dnd;                    /**< [en]Indicates the register DND
                                                            [cn]免打扰 */
    TSDK_S_SERVICE_ACCESS_CODE call_wait;              /**< [en]Indicates call wait
                                                            [cn]呼叫等待 */
    TSDK_S_SERVICE_ACCESS_CODE cfu;                    /**< [en]Indicates uncondition forward
                                                            [cn]无条件前转 */
    TSDK_S_SERVICE_ACCESS_CODE cfb;                    /**< [en]Indicates on busy forward
                                                            [cn]遇忙前转 */
    TSDK_S_SERVICE_ACCESS_CODE cfn;                    /**< [en]Indicates no reply forward
                                                            [cn]无应答前转 */
    TSDK_S_SERVICE_ACCESS_CODE cfo;                    /**< [en]Indicates offline forward
                                                            [cn]离线前转 */
    TSDK_S_SERVICE_ACCESS_CODE cfu_to_vm;              /**< [en]Indicates uncondition forward voice mail
                                                            [cn]无条件转语音邮箱,暂不支持，预留 */
    TSDK_S_SERVICE_ACCESS_CODE cfb_to_vm;              /**< [en]Indicates on busy forward voice mail
                                                            [cn]遇忙转语音邮箱,暂不支持，预留 */
    TSDK_S_SERVICE_ACCESS_CODE cfn_to_vm;              /**< [en]Indicates no reply forward voice mail
                                                            [cn]无应答转语音邮箱,暂不支持，预留 */
    TSDK_S_SERVICE_ACCESS_CODE cfo_to_vm;              /**< [en]Indicates offline forward voice mail
                                                            [cn]离线转语音邮箱,暂不支持，预留 */
    TSDK_S_SERVICE_ACCESS_CODE call_alert;             /**< [en]Indicates the missed calls alert service
                                                            [cn]未接来电提醒业务 */
}TSDK_S_IPT_SERVICE_CONFIG_PARAM;


/**
 * [en]This structure is used to describe the ipt service info
 * [cn]IPT业务信息
 */
typedef struct tagTSDK_S_IPT_SERVICE_INFO
{
    TSDK_BOOL has_right;                                /**< [en]Indicates whether has service right.
                                                             [cn]是否有业务权限 */
    TSDK_BOOL is_enable;                                /**< [en]Indicates whether is enable.
                                                             [cn]是否已激活(登记) */
    TSDK_CHAR number[TSDK_D_MAX_NUMBER_LEN + 1];        /**< [en]Indicates aim service number, valid for forward service.
                                                             [cn]业务目标号码，前转等业务有效 */
} TSDK_S_IPT_SERVICE_INFO;


/**
 * [en]This structure is used to describe set of ipt service right and state infor.
 * [cn]IPT业务权限及状态信息集合
 */
typedef struct tagTSDK_S_IPT_SERVICE_INFO_SET
{
    TSDK_S_IPT_SERVICE_INFO dnd;                    /**< [en]Indicates the register DND
                                                         [cn]免打扰 */
    TSDK_S_IPT_SERVICE_INFO call_wait;              /**< [en]Indicates call wait
                                                         [cn]呼叫等待 */
    TSDK_S_IPT_SERVICE_INFO cfu;                    /**< [en]Indicates uncondition forward
                                                         [cn]无条件前转 */
    TSDK_S_IPT_SERVICE_INFO cfb;                    /**< [en]Indicates on busy forward
                                                         [cn]遇忙前转 */
    TSDK_S_IPT_SERVICE_INFO cfn;                    /**< [en]Indicates no reply forward
                                                         [cn]无应答前转 */
    TSDK_S_IPT_SERVICE_INFO cfo;                    /**< [en]Indicates offline forward
                                                         [cn]离线前转 */
    TSDK_S_IPT_SERVICE_INFO cfu_to_vm;              /**< [en]Indicates uncondition forward voice mail
                                                         [cn]无条件转语音邮箱,暂不支持，预留 */
    TSDK_S_IPT_SERVICE_INFO cfb_to_vm;              /**< [en]Indicates on busy forward voice mail
                                                         [cn]遇忙转语音邮箱,暂不支持，预留 */
    TSDK_S_IPT_SERVICE_INFO cfn_to_vm;              /**< [en]Indicates no reply forward voice mail
                                                         [cn]无应答转语音邮箱,暂不支持，预留 */
    TSDK_S_IPT_SERVICE_INFO cfo_to_vm;              /**< [en]Indicates offline forward voice mail
                                                         [cn]离线转语音邮箱,暂不支持，预留 */
    TSDK_S_IPT_SERVICE_INFO call_alert;             /**< [en]Indicates the missed calls alert service
                                                         [cn]未接来电提醒业务 */
}TSDK_S_IPT_SERVICE_INFO_SET;


/**
 * [en]This structure is used to describe set ipt service result.
 * [cn]设置ipt业务结果
 */
typedef struct tagTSDK_S_SET_IPT_SERVICE_RESULT
{
    TSDK_BOOL is_enable;                                                   /**< [en]Indicates whether is enable.
                                                                                [cn]是否激活(登记)业务 */
    TSDK_INT32 reason_code;                                                /**< [en]Indicates reason code
                                                                                [cn]原因码*/
    TSDK_CHAR reason_description[TSDK_D_MAX_REASON_DESCRPTION_LEN + 1];    /**< [en]Indicates reason description
                                                                                [cn]原因描述*/
} TSDK_S_SET_IPT_SERVICE_RESULT;


/**
 * [en]This structure is used to describe video orient.
 * [cn]视频横竖屏状态
 */
typedef struct tagTSDK_S_VIDEO_ORIENT
{
    TSDK_UINT32 choice;           /**< [en]Indicates video horizontal screen situation 1: vertical screen; 2: horizontal screen; 3: reverse horizontal screen.
                                       [cn]视频横竖屏情况 1：竖屏；2：横屏；3：反向横屏  */
    TSDK_UINT32 portrait;         /**< [en]Indicates vertical screen video capture (counterclockwise rotation) Angle 0: 0 degrees; 1: 90 degrees; 2: 180 degrees; 3: 270 degrees.
                                       [cn]竖屏视频捕获（逆时针旋转）角度 0：0度；1：90度；2：180度；3：270度；*/
    TSDK_UINT32 landscape;        /**< [en]Indicates horizontal video capture (counterclockwise rotation) Angle 0: 0 degrees; 1: 90 degrees; 2: 180 degrees; 3: 270 degrees.
                                       [cn]横屏视频捕获（逆时针旋转）角度 0：0度；1：90度；2：180度；3：270度；*/
    TSDK_UINT32 seascape;         /**< [en]Indicates reverse horizontal video capture (counterclockwise rotation) Angle 0: 0 degrees; 1: 90 degrees; 2: 180 degrees; 3: 270 degrees.
                                       [cn]反向横屏视频捕获（逆时针旋转）角度 0：0度；1：90度；2：180度；3：270度；*/
}TSDK_S_VIDEO_ORIENT;


/**
 * [en]This structure is used to describe the video display window properties.
 * [cn]视频显示窗口属性
 */
typedef struct tagTSDK_S_VIDEO_RENDER_INFO
{
    TSDK_E_VIDEO_WND_TYPE render_type;           /**< [en]Indicates the window type enumeration value.
                                                      [cn]窗口类型枚举值 */
    TSDK_E_VIDEO_WND_DISPLAY_MODE display_type;  /**< [en]Indicates window display mode 0: Stretch mode 1: (No stretch) Black border mode 2: (No stretch) Crop mode 3: (guaranteed window size> = image size) Displayed at original resolution.
                                                      [cn]窗口显示模式 0:拉伸模式 1:(不拉伸)黑边模式 2:(不拉伸)裁剪模式 3:(需保证窗口尺寸 >= 图像尺寸)按原始分辨率显示 */
    TSDK_E_VIDEO_WND_MIRROR_TYPE mirror_type;    /**< [en]Indicates window Mirror Mode 0: not mirror (default) 1: Mirror up and down (currently not supported) 2: Mirror left and right.
                                                      [cn]窗口镜像模式 0:不做镜像(默认值) 1:垂直镜像(X轴镜像)(目前未支持) 2:水平镜像(Y轴镜像) */
}TSDK_S_VIDEO_RENDER_INFO;


/**
 * [en]This structure is used to describe the session modified complete result
 * [cn]会话修改完成结果信息
 */
typedef struct tagTSDK_S_SESSION_MODIFIED
{
    TSDK_UINT32 call_id;                                  /**< [en]Indicates call id
                                                               [cn]呼叫ID */
    TSDK_BOOL is_fouces;                                  /**< [en]Indicates whether carry isfoucs mark, used in mobile conf scene
                                                               [cn]是否带isfoucs标识，移动会议场景使用*/
    TSDK_E_VIDEO_ORIENTATION orient_type;                 /**< [en]Indicates video orient type
                                                               [cn]移动视频横竖屏情况*/
    TSDK_CHAR local_addr[TSDK_D_MAX_URL_LENGTH + 1];      /**< [en]Indicates local address
                                                               [cn]本地地址()*/
    TSDK_CHAR remote_addr[TSDK_D_MAX_URL_LENGTH + 1];     /**< [en]Indicates remote addr
                                                               [cn]移动上报远端地址*/
    TSDK_E_REINVITE_TYPE reinvite_type;                   /**< [en]Indicates hold type
                                                               [cn]主被叫控业务中Reinvite消息指示的事件类型*/
    TSDK_E_MEDIA_SEND_MODE audio_send_mode;               /**< [en]Indicates audio send mode
                                                               [cn]音频媒体方向*/
    TSDK_E_MEDIA_SEND_MODE video_send_mode;               /**< [en]Indicates video media type
                                                               [cn]视频媒体方向*/
    TSDK_E_MEDIA_SEND_MODE data_send_mode;                /**< [en]Indicates data send mode
                                                               [cn]辅流媒体方向*/
    TSDK_BOOL           is_low_bw_switch_to_audio;        /**< [en]Indicates is low band width switch to audio
                                                               [cn]是否是由低带宽造成的视频切换到音频*/
    TSDK_BOOL           is_svc_call;                      /**< [en]Indicates is multi stream conf flag
                                                               [cn]是否多流会议标志。取值：TUP_TRUE，是多流会议呼叫；否则不是*/
    TSDK_INT8           svc_lable_count;                  /**< [en]Indicates number of valid multi-streams (valid subscript of the svc_lable_ssrc[] array. Generally, the value is 2.)
                                                               [cn]多流有效个数(svc_lable_ssrc[]数组的有效下标，一般取2) */
    TSDK_UINT32 svc_lable_ssrc[TSDK_D_MAX_SVC_LABLE_NUM]; /**< [en]Indicates the SSRC value of the multi-stream. Generally, the first two values are used.
                                                               [cn]多流对应的ssrc值(一般取前两值) */
    TSDK_UINT32         bandWidth;                        /**< [en]Indicates band width
                                                               [cn]会场协商带宽 */
    TSDK_CALL_E_SVC_TYPE svcConfType;                     /**< [en]Indicates Conference type (H264/H265)
                                                               [cn]会议能力(H264/H265) */
} TSDK_S_SESSION_MODIFIED;


/**
 * [en]This structure is used to describe session codec info
 * [cn]会话正在使用的编解码器信息
 */
typedef struct tagTSDK_S_SESSION_CODEC
{
    TSDK_UINT32 call_id;                                      /**< [en]Indicates call id
                                                                   [cn]呼叫ID */
    TSDK_E_MEDIA_TYPE media_type;                             /**< [en]Indicates media type, 1:audio, 2:video, 3:data
                                                                   [cn]媒体类型1 : 音频。  2 : 视频。 3 : 辅流 */
    TSDK_UINT32 codec_type;                                   /**< [en]Indicate codec type, 1:encode, 2:decode
                                                                   [cn]编解码器类型 1 : 编码器。2 : 解码器。 */
    TSDK_CHAR   codec_name[TSDK_D_MAX_CODEC_NAME_LEN + 1];    /**< [en]Indicates codec name
                                                                   [cn]编解码名称 */
}TSDK_S_SESSION_CODEC;

/** 
 * [en]This enumeration is used to describe the parameter as function of tsdk_call_get_call_info.
 * [cn]作为tsdk_call_get_call_info函数的参数
 */
typedef enum tagTSDK_E_CALL_INFO_ID
{
    TSDK_E_INFO_BASIC_CALL_INFO,        /**< [en]Indicates the basic call information, corresponding to: CALL_S_CALL_INFO
                                             [cn]基本呼叫信息，对应: CALL_S_CALL_INFO */
    TSDK_E_INFO_SESSION_CAP_INFO,       /**< [en]Indicates the session capability information (the result of capability negotiation), including session total bandwidth and common codec capability, corresponding to: CALL_S_SESSION_CAP_INFO
                                             [cn]会话能力信息(能力协商的结果)，包括会话总带宽和公共编解码能力，对应: CALL_S_SESSION_CAP_INFO */
    TSDK_E_INFO_MEDIA_CHAN_INFO,        /**< [en]Indicates media channel information (results of capability negotiation), including audio, video, Auxiliary stream, and corresponding: CALL_S_MEDIA_CHAN_INFO
                                             [cn]媒体通道信息(能力协商的结果)，包括音频、视频、辅流，对应: CALL_S_MEDIA_CHAN_INFO */
    TSDK_E_INFO_ACTUAL_CHAN_INFO,       /**< [en]Indicates the actual media channel information correspondence: CALL_S_ACTUAL_CHAN_INFO
                                             [cn]实际媒体通道信息 对应：CALL_S_ACTUAL_CHAN_INFO */
    TSDK_E_INFO_MEDIA_QOS_INFO,         /**< [en]Indicates the media QOS information (channel real-time information, media statistics, and MOS value, etc.), including audio, video, Auxiliary streams, and corresponding: CALL_S_MEDIA_QOS_INFO
                                             [cn]媒体QOS信息(通道实时信息、媒体统计信息以及MOS值等)，包括音频、视频、辅流，对应: CALL_S_MEDIA_QOS_INFO */
    TSDK_E_INFO_CURRENT_STATE_INFO,     /**< [en]Indicates the current call state information, corresponding to: CALL_S_CURRENT_STATE
                                             [cn]当前呼叫状态信息，对应: CALL_S_CURRENT_STATE */
}TSDK_E_CALL_INFO_ID;

/**
 * QoS上报信息(上报本地UI)
 */
typedef struct tagTSDK_S_LOCAL_QOS_INFO
{
    TSDK_UINT32 call_id;        /**< 呼叫ID */

    /**< 下行 */
    TSDK_FLOAT  mos_value;       /**< mos平均值 */
    TSDK_UINT32 lost_value;     /**< JB丢包率平均值 */
    TSDK_UINT32 net_lost_value;  /**< 网络丢包率平均值 */
    TSDK_UINT32 jitter_value;   /**< 抖动平均值 */
    TSDK_UINT32 delay_value;    /**< 时延平均值 */
    TSDK_UINT32 rtp_loss_value;  /**< FEC后丢包 */
    TSDK_UINT32 recv_mean_speech_level; /**< 下行采集语音电平 */
    TSDK_UINT32 recv_mean_noise_level;  /**< 下行采集噪声电平 */

    /**< 上行 */
    TSDK_FLOAT  send_mos_value;         /**< mos值 */
    TSDK_UINT32 send_lost_value;       /**< 丢包率 */
    TSDK_UINT32 send_jitter_value;     /**< 抖动 */

    TSDK_CHAR audio_codec[TSDK_D_MAX_AUDIO_CODEC_LEN + 1]; /**< 音频编解码 "G722,PCMA,PCMU,G729,iLBC,telephone-event,red"*/

    TSDK_UINT32 recv_bytes;   /**< 接收字节数 */
    TSDK_UINT32 send_bytes;   /**< 发送字节数 */
    TSDK_UINT32 send_mean_speech_level; /**< 上行采集语音电平 */
    TSDK_UINT32 send_mean_noise_level;  /**< 上行采集噪声电平 */
}TSDK_S_LOCAL_QOS_INFO;

/** 
 * [en]This structure is used to describe the real-time session bandwidth.
 * [cn]实时会话带宽
 */
typedef struct _tagTSDK_S_REALTIME_TOTAL_RATE
{
    TSDK_UINT32 rt_tx_rate;                 /**< [en]Indicates the total bandwidth of real-time transmissions. [cn]实时发送的总带宽           */
    TSDK_UINT32 rt_rx_rate;                 /**< [en]Indicates the total bandwidth received in real-time. [cn]实时接收的总带宽           */
    TSDK_UINT32 rt_rx_effective_rate; /**< [en]Indicates the total effective bandwidth received in real-time. [cn]实时接收的有效带宽           */  
}TSDK_S_REALTIME_TOTAL_RATE;

/** 
 * [en]The structure is used to describe the MOS value of voice statistics.
 * [cn]语音MOS值统计信息
 */
typedef struct _tagTSDK_S_EMODEL_RESULT_STRU
{
    TSDK_UINT8 mos_valid_flag;               /**< [en]Indicates the MOS active flag. When the channel does not receive any message or does not reach the calculation cycle (RTCP send cycle, 5s), the following four directions MOS sub-parameters are invalid. [cn]MOS分有效标志,当通道未收到任何报文或未达到计算周期(RTCP发送周期，5s)时，如下4个方向的MOS分参数都无效 */
    TSDK_FLOAT average_mosQ;                 /**< [en]Indicates the MOS average value.Use floating-point numbers. Value range from 0 to 5. 0xFFFFFFFF indicates that the parameter is invalid. [cn]MOS分平均值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_FLOAT max_mosQ;                     /**< [en]Indicates the MOS maximum value.Use floating-point numbers. Value range from 0 to 5. 0xFFFFFFFF indicates that the parameter is invalid.  [cn]MOS分最大值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_FLOAT min_mosQ;                     /**< [en]Indicates the MOS minimum value.Use floating-point numbers. Value range from 0 to 5. 0xFFFFFFFF indicates that the parameter is invalid. [cn]MOS分最小值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_FLOAT cur_mosQ;                     /**< [en]Indicates the MOS current value.Use floating-point numbers. Value range from 0 to 5. 0xFFFFFFFF indicates that the parameter is invalid. [cn]MOS分当前值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
} TSDK_S_EMODEL_RESULT_STRU;

/** 
 * [en]This structure is used to describe real-time audio statistics.
 * [cn]实时的音频统计信息
 */
typedef struct _tagTSDK_S_REALTIME_AUDIO_INFO
{
    TSDK_UINT32 bit_rate;                   /**< [en]Indicates the bit rate. [cn]码率 */
    TSDK_UINT32 lost_per;                   /**< [en]Indicates the packet loss rate in units of 1/1000. [cn]丢包率,单位:1/1000  */
    TSDK_UINT32 net_lost_per;               /**< [en]Indicates the packet loss rate in units of 1/1000. [cn]网络丢包率,单位:1/1000  */
    TSDK_UINT32 lost_packets;               /**< [en]Indicates the total number of packets lost. [cn]总丢包数 */
    TSDK_UINT32 jitter;                     /**< [en]Indicates average jitter (ms). [cn]平均抖动(ms) */
    TSDK_UINT32 delay;                      /**< [en]Indicates the average delay (ms). [cn]平均时延(ms) */
    TSDK_E_AUDIO_CAP protocol;                          /**< [en]Indicates the audio protocol. [cn]音频协议 */
} TSDK_S_REALTIME_AUDIO_INFO;

/** 
 * [en]The structure is used to describe real-time video statistics.
 * [cn]实时的视频统计信息
 */
typedef struct _tagTSDK_S_REALTIME_VIDEO_INFO
{
    TSDK_UINT32 bit_rate;                   /**< [en]Indicates the bit rate. [cn]码率 */
    TSDK_UINT32 frame_rate;                 /**< [en]Indicates the frame rate. [cn]帧率 */
    TSDK_UINT32 lost_per;                   /**< [en]Indicates the packet loss rate in units of 1/1000. [cn]丢包率,单位:1/1000  */
    TSDK_UINT32 lost_packets;               /**< [en]Indicates the total number of packets lost. [cn]总丢包数 */
    TSDK_UINT32 jitter;                     /**< [en]Indicates average jitter (ms). [cn]平均抖动(ms) */
    TSDK_UINT32 delay;                      /**< [en]Indicates the average delay (ms). [cn]平均时延(ms) */
	TSDK_E_GAMUT_TYPE gamut_type;           /**< [en]Indicates the colorgamut.type, currently supported BT601, BT709, BT2020. [cn]色域类型, 当前支持 BT601, BT709, BT2020 */
    TSDK_UINT32 width;                      /**< [en]Indicates the video format - wide. [cn]视频格式-宽 */
    TSDK_UINT32 height;                     /**< [en]Indicates the video format - High. [cn]视频格式-高 */
    TSDK_E_VIDEO_DETAIL_CAP  protocol;      /**< [en]Indicates the video protocol CALL_E_VIDEO_DETAIL_CAP. [cn]视频协议TSDK_E_VIDEO_DETAIL_CAP */
    TSDK_UINT8  h264_profile;               /**< [en]Indicates the H.264 video encoding format, currently supported H264: BP, MP, HP, SVC?. [cn]H.264视频编码格式, 当前支持的H264:BP,MP,HP,SVC? */
} TSDK_S_REALTIME_VIDEO_INFO;

/** 
 * [en]The structure is used to describe real-time video statistics.
 * [cn]实时的视频(多流)统计信息
 */
typedef struct _tagTSDK_S_REALTIME_SVC_VIDEO_INFO
{
    TSDK_UINT32 ssrc;                       /**< [en]Indicates the ssrc. [cn]ssrc */
    TSDK_UINT32 bit_rate;                   /**< [en]Indicates the bit rate. [cn]码率 */
    TSDK_UINT32 frame_rate;                 /**< [en]Indicates the frame rate. [cn]帧率 */
    TSDK_UINT32 width;                      /**< [en]Indicates the width. [cn]分辨率-宽 */
    TSDK_UINT32 height;                     /**< [en]Indicates the height. [cn]分辨率-高 */
    TSDK_UINT32 lost_per;                   /**< [en]Indicates the packet loss rate in units of 1/1000. [cn]丢包率,单位:1/1000  */
    TSDK_UINT32 lost_packets;               /**< [en]Indicates the total number of packets lost. [cn]总丢包数 */
    TSDK_UINT32 jitter;                     /**< [en]Indicates average jitter (ms). [cn]平均抖动(ms) */
    TSDK_UINT32 delay;                      /**< [en]Indicates the average delay (ms). [cn]平均时延(ms) */
} TSDK_S_REALTIME_SVC_VIDEO_INFO;


/** 
 * [en]This structure is used to describe media QOS information (channel real-time information, media statistics and MOS value, etc.), including audio, video and auxiliary stream. Read through the CALL_E_INFO_MEDIA_QOS_INFO configuration item..
 * [cn]媒体QOS信息(通道实时信息、媒体统计信息以及MOS值等)，包括音频、视频、辅流。通过CALL_E_INFO_MEDIA_QOS_INFO配置项读取。
 */   
typedef struct _tagTSDK_S_MEDIA_QOS_INFO
{
    TSDK_S_REALTIME_AUDIO_INFO rt_tx_audio;         /**< [en]Indicates real-time audio sending statistics. [cn]实时音频发送统计信息 */
    TSDK_S_REALTIME_AUDIO_INFO rt_rx_audio;         /**< [en]Indicates real-time audio reception statistics. [cn]实时音频接收统计信息 */
    TSDK_S_REALTIME_VIDEO_INFO rt_tx_main_video;    /**< [en]Indicates that the real-time mainstream sends statistics. [cn]实时主流发送统计信息 */
    TSDK_S_REALTIME_VIDEO_INFO rt_rx_main_video;    /**< [en]Indicates real-time mainstream receive statistics. [cn]实时主流接收统计信息 */
    TSDK_S_REALTIME_VIDEO_INFO rt_tx_aux_video;     /**< [en]Indicates the real-time Auxiliary stream to send statistics. [cn]实时辅流发送统计信息 */
    TSDK_S_REALTIME_VIDEO_INFO rt_rx_aux_video;     /**< [en]Indicates that the real-time Auxiliary stream receives statistics. [cn]实时辅流接收统计信息 */
} TSDK_S_MEDIA_QOS_INFO;

/**
* [en]This structure is used to describe the audio stream information.
* [cn]音频通道信息
*/
typedef struct _tagTSDK_S_CALL_AUDIO_STREAM_INFO
{
    TSDK_CHAR encode_protocol[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];    /**< [en]Indicates encode protocol. [cn]编码协议名*/
    TSDK_CHAR decode_protocol[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];    /**< [en]Indicates decode protocol. [cn]解码协议名*/
    TSDK_BOOL is_srtp;                     /**< [en]Indicates whether enable SRTP or not, value of: 0 RTP, 1 SRTP. [cn]是否启用SRTP， 取值: 0 RTP, 1 SRTP*/
    TSDK_UINT32 recv_bit_rate;             /**< [en]Indicates to receive bit rate(bps). [cn]接收比特率(kbps) */
    TSDK_FLOAT recv_delay;                 /**< [en]Indicates receiver delay on average(ms). [cn]接收方平均时延(ms) */ 
    TSDK_FLOAT recv_jitter;                /**< [en]Indicates receiver jitter on average(ms). [cn]接收方平均抖动(ms) */  
    TSDK_FLOAT recv_loss_fraction;         /**< [en]Indicates receiver packer loss rate(%). [cn]接收方丢包率(%) */
    TSDK_FLOAT recv_net_loss_fraction;     /**< [en]Indicates receiver net packet loss rate(%). [cn]接收方网络丢包率(%) */
    TSDK_UINT32 recv_total_lost_packet;    /**< [en]Indicates receiver total lost packet. [cn]接收方累计包损 */
    TSDK_UINT32 recv_bytes;                /**< [en]Indicates the bytes has received. [cn]接收总字节数*/
    TSDK_FLOAT recv_average_mos;           /**< [en]Indicates to receive direction MOS average value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid. 
                                                [cn]接收方向MOS分平均值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */                            
    TSDK_FLOAT recv_cur_mos;               /**< [en]Indicates to receive direction MOS current value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid. 
                                                [cn]接收方向MOS分当前值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_FLOAT recv_max_mos;               /**< [en]Indicates to receive direction MOS maximum value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid. 
                                                [cn]接收方向MOS分最大值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_FLOAT recv_min_mos;               /**< [en]Indicates to receive direction MOS minimum value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid. 
                                                [cn]接收方向MOS分最小值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_UINT32 send_bit_rate;             /**< [en]Indicates to send bit rate(bps). [cn]发送比特率(kbps) */
    TSDK_FLOAT send_delay;                 /**< [en]Indicates sender delay on average(ms). [cn]发送方平均时延(ms) */
    TSDK_FLOAT send_jitter;                /**< [en]Indicates sender jitter on average(ms). [cn]发送方平均抖动(ms) */
    TSDK_FLOAT send_loss_fraction;         /**< [en]Indicates sender packet loss rate(%) . [cn]发送方丢包率(%) */
    TSDK_FLOAT send_net_loss_fraction;     /**< [en]Indicates sender net packet loss rate(%). [cn]发送方网络丢包率(%) */
    TSDK_UINT32 send_total_lost_packet;    /**< [en]Indicates sender total lost packet. [cn]发送方累计包损 */
    TSDK_UINT32 send_bytes;                /**< [en]Indicates the bytes has been sent.  [cn]发送总子节数*/
    TSDK_FLOAT send_average_mos;           /**< [en]Indicates to send direction MOS average value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid.
                                                [cn]发送方向MOS分平均值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_FLOAT send_cur_mos;               /**< [en]Indicates to send direction MOS current value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid. 
                                                [cn]发送方向MOS分当前值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */                        
    TSDK_FLOAT send_max_mos;               /**< [en]Indicates to send direction MOS maximum value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid.
                                                [cn]发送方向MOS分最大值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
    TSDK_FLOAT send_min_mos;               /**< [en]Indicates to send direction MOS minimum value, with floating-point number: Range (0, 5], 0xFFFFFFFF means the parameter is invalid. 
                                                [cn]发送方向MOS分最小值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效 */
} TSDK_S_CALL_AUDIO_STREAM_INFO;

/**
* [en]This structure is used to describe the video stream information.
* [cn]视频通道信息
*/
typedef struct _tagCALL_S_VIDEO_STREAM_INFO
{
    TSDK_CHAR encode_name[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];        /**< [en]Indicates encode name. [cn]编码名称*/
    TSDK_CHAR encoder_profile[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];    /**< [en]Indicates video encode format. [cn]视频编码格式*/
    TSDK_CHAR encoder_size[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];       /**< [en]Indicates image resolution ratio(encode). [cn]图像分辨率(编码)*/
    TSDK_CHAR decode_name[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];        /**< [en]Indicates decode name. [cn]解码名称*/
    TSDK_CHAR decoder_profile[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];    /**< [en]Indicates video decode format. [cn]视频解码格式*/
    TSDK_CHAR decoder_size[TSDK_D_MAX_CODEC_DESCRPTION_LEN + 1];       /**< [en]Indicates image resolution ratio(decode). [cn]图像分辨率(解码)*/
    TSDK_BOOL is_srtp;                                                 /**< [en]Indicates whether enable SRTP or not, value of: 0 RTP, 1 SRTP. [cn]是否启用SRTP， 取值: 0 RTP, 1 SRTP*/
    TSDK_UINT32 width;                                                 /**< [en]Indicates video resolution ratio-Width(ppi). [cn]视频分辨率-宽(ppi)*/
    TSDK_UINT32 height;                                                /**< [en]Indicates video resolution ratio-Height(ppi). [cn]视频分辨率-高(ppi)*/
    TSDK_FLOAT recv_delay;                                             /**< [en]Indicates receiver delay on average. [cn]接收方平均时延(ms) */
    TSDK_UINT32 recv_frame_rate;                                       /**< [en]Indicates video frame rate(decode). [cn]视频帧率(解码)*/      
    TSDK_FLOAT recv_jitter;                                            /**< [en]Indicates receiver jitter on average. [cn]接收方平均抖动(ms) */
    TSDK_FLOAT recv_loss_fraction;                                     /**< [en]Indicates reveiver packer loss rate(%). [cn]接收方丢包率(%) */
    TSDK_UINT32 recv_bit_rate;                                         /**< [en]Indicates decode bit rate(bps). [cn]解码码率(bps) */
    TSDK_UINT64 recv_bytes;                                            /**< [en]Indicates the bytes has received. [cn]接收总字节数*/
    TSDK_FLOAT send_delay;                                             /**< [en]Indicates sender delay on average(ms). [cn]发送方平均时延(ms) */
    TSDK_UINT32 send_frame_rate;                                       /**< [en]Indicates video frame rate(encode). [cn]视频帧率(编码)*/
    TSDK_FLOAT send_jitter;                                            /**< [en]Indicates sender jitter on average(ms). [cn]发送方平均抖动(ms) */
    TSDK_FLOAT send_loss_fraction;                                     /**< [en]Indicates sender packet loss rate(%). [cn]发送方丢包率(%) */
    TSDK_UINT32 send_bit_rate;                                         /**< [en]Indicates encode bit rate(bps). [cn]编码码率(bps) */
    TSDK_UINT64 send_bytes;                                            /**< [en]Indicates the bytes has been sent. [cn]发送总子节数*/
    TSDK_UINT32 decodeSsrc;                                            /**< [en]Indicates svc video decode ssrc. [cn]svc多流解码ssrc*/
} TSDK_S_CALL_VIDEO_STREAM_INFO;

/**
* [en]This structure is used to describe the audio and video stream information.
* [cn]音视频通道信息
*/
typedef struct _tagTSDK_S_CALL_STREAM_INFO
{
    TSDK_S_CALL_AUDIO_STREAM_INFO audio_stream_info;         /**< [en]Indicates audio stream information. [cn]音频流信息*/
    TSDK_S_CALL_VIDEO_STREAM_INFO video_stream_info;         /**< [en]Indicates video stream information. [cn]视频流信息*/
    TSDK_S_CALL_VIDEO_STREAM_INFO data_stream_info;          /**< [en]Indicates data Stream information.  [cn]辅流信息*/
    TSDK_S_CALL_VIDEO_STREAM_INFO svc_video_stream_info[TSDK_D_MAX_SVC_NUM];     /**< [en]Indicates SVC video Stream information.  [cn]SVC视频流信息*/
} TSDK_S_CALL_STREAM_INFO;

/**
* [en]This structure is used to describe the Decode success message information.
* [cn]解码成功信息
*/
typedef struct tagTSDK_S_DECODE_SUCCESS
{
    TSDK_UINT32 call_id;                            /**< [en]Indicates call ID. [cn]通话ID */
    TSDK_E_DECODE_SUCCESS_MIDEATYPE meida_type;     /**< [en]Indicates media type. [cn]解码成功的视频媒体类型 */
} TSDK_S_DECODE_SUCCESS;

/**
* [en]This structure is used to describe the bfcp start error information.
* [cn]辅流发送失败信息
*/
typedef struct tagTSDK_S_BFCP_START_ERROR
{
    TSDK_UINT32 callId;                            /**< [en]Indicates call ID. [cn]通话ID */
    TSDK_UINT32 bfcpErrorType;     /**< [en]Indicates bfcp start error type. [cn]辅流发送失败类型 */
} TSDK_S_BFCP_START_ERROR;

/**
* [en]This structure is used to describe the conference param information.
* [cn]会议信息
*/
typedef struct tagTsdkCallConfInfo {
    TSDK_CHAR confId[TSDK_D_MAX_CONF_ID_LEN + 1];                            /**< [en]Indicates conference ID.   [cn]3.0会议id*/
    TSDK_CHAR confToken[TSDK_D_MAX_CONF_TOKEN_LEN + 1];                      /**< [en]Indicates conference token. [cn]会议token */
    TSDK_CHAR serverIp[TSDK_D_MAX_SERVER_ADDR_LEN + 1];                      /**< [en]Indicates conference IP     [cn]服务器 IP*/
    TSDK_UINT32 serverPort;                                                  /**< [en]Indicates conference port   [cn]服务器 端口*/
} TsdkCallConfInfo;

/**
* 网络级别信息
*/
typedef struct tagTsdkCallNetQualityLevel {
    TSDK_UINT32 upNetLevel;     /**< 上行网络级别 */
    TSDK_UINT32 downNetLevel;   /**< 下行网络级别 */
} TsdkCallNetQualityLevel;

/**
* 网络质量改变通知消息结构
*/
typedef struct tagTsdkCallNetQualityChange {
    TSDK_UINT32 callId;        /**< 呼叫ID */
    TSDK_UINT32 netError;      /**< 网络错误 0 : 没有错误 1 : 网络发端错误 2 : 网络收端错误 3 : 网络收发均错误。 */
    TSDK_UINT32 accountId;     /**< 账户ID */
    TsdkCallNetQualityLevel netLevel; /* 网络级别信息 */
} TsdkCallNetQualityChange;

/**
* 网络质量统计信息
*/
typedef struct tagTsdkCallStatisticNetInfo {
    TSDK_UINT32 callId;        /**< 呼叫ID */
    TSDK_FLOAT lost;           /**< 下行丢包率，单位:% */
    TSDK_FLOAT delay;          /**< 下行时延，单位:毫秒 */
    TSDK_FLOAT jitter;         /**< 下行抖动，单位:毫秒 */
    TSDK_UINT32 sendLost;      /**< 上行丢包率，单位:% */
    TSDK_UINT32 sendDelay;     /**< 上行时延，单位:毫秒 */
    TSDK_UINT32 sendJitter;    /**< 上行抖动，单位:毫秒 */
} TsdkCallStatisticNetInfo;

/**
* 媒体错误信息
*/
typedef struct tagTsdkCallMediaErrorInfo {
    TSDK_UINT32 callId;        /**< 呼叫Id */
    TSDK_UINT32 mediaType;     /**< 媒体类型:   0 : 未知类型 1 : 音频     2 : 视频    3 : 辅流  */
    TSDK_UINT32 errorType;     /**< 错误类型:   0 : 未知类型 1 : 启动发送错误 2 : 启动接收错误 3 : 摄像头被抢占错误*/
} TsdkCallMediaErrorInfo;

/**
* [en]This structure is used to describe the sip sessiontime param.
* [cn]设置SIP Session保活时长信息
*/
typedef struct tagTsdkCallSipSessionTimeParam {
    TSDK_BOOL enableSessionTime;                        /**< [en]Indicates enable session time, default true
                                                             [cn]开启Sessiontime开关， 默认true**/
    TSDK_UINT32 sessionTime;                            /**< [en]Indicates session time length, default 180s
                                                             [cn]UPDATE信令保活时长， 默认180s**/
    TSDK_UINT32 keepAlive;                              /**< [en]Indicates keep alive length, default 45s
                                                             [cn]keepalive协议保活时长， 默认45s**/
} TsdkCallSipSessionTimeParam;

/**
* [en]This structure is used to describe the audio advance param.
* [cn]设置音频高级配置参数
*/
typedef struct tagTsdkAudioAdvanceParam {
    TSDK_BOOL howlAutoMuteSwitch;                        /**< [en]Indicates howlAutoMuteSwitch, default true
                                                              [cn]开启啸叫检测后自动静音开关， 默认true**/
    TSDK_BOOL denoiseSwitch;                             /**< [en]Indicates denoiseSwitch, default true
                                                              [cn]开启降噪开关， 默认true**/
} TsdkAudioAdvanceParam;

/**
* [en]This enumeration is used to describe audio device status.
* [cn]音频设备异常。
*/
typedef enum tagTsdkSystemAudioErrType {
    TSDK_E_SYSTEM_AUDIO_ERROR_TYPE_DEFAULT_DEVICE_INVALIDATED = 0x80070490,   /**< [en]Indicates system default 
                                                                               audio device wrong [cn]默认音频设备异常 */
    TSDK_E_SYSTEM_AUDIO_ERROR_TYPE_DEVICE_INVALIDATED = 0x88890004,           /**< [en]Indicates audio device wrong
                                                                                   [cn]音频设备异常 */
    TSDK_E_SYSTEM_AUDIO_ERROR_TYPE_DEVICE_ACCESS_DENIED = 0x80070005,         /**< [en]The application does not have access to MIC
                                                                                   [cn]应用没有访问MIC的权限 */
    TSDK_E_SYSTEM_AUDIO_ERROR_TYPE_BUTT                                       /**< [en]Indicates BUTT
                                                                                   [cn]无效值 */
} TsdkSystemAudioErrType;

/**
* [en]This enumeration is used to describe tmmbr notification type of data sender under main video and data bandwidth interaction.
* [cn]主辅流联动辅流发送方上报UI消息类型
*/
typedef enum tagTsdkCallNotifyTmmbrMsgType {
    TSDK_CALL_E_TMMBR_MSG_NONE = 0,        /**< [en]Indicates no msg.          [cn]无效消息 */
    TSDK_CALL_E_TMMBR_MSG_CAMERA_OFF,      /**< [en]Indicates turn off camera. [cn]关闭摄像头 */
    TSDK_CALL_E_TMMBR_MSG_CAMERA_ON,       /**< [en]Indicates turn on camera.  [cn]打开摄像头 */
    TSDK_CALL_E_TMMBR_MSG_DATA_CLOSE,      /**< [en]Indicates close data.      [cn]关闭辅流 */
    TSDK_CALL_E_TMMBR_MSG_DATA_OPEN,       /**< [en]Indicates open data.       [cn]打开辅流 */
} TsdkCallNotifyTmmbrMsgType;

/**
* [en]This structure is used to describe the call refer information.
* [cn]内部call信息
*/
typedef struct tagTsdkCallInnerInfo {
    TSDK_BOOL isAnonymousCallByUdp;                                            /**< [en]Indicates Whether a call is is anonymous join by udp
                                                                                    [cn]记录本地呼叫是不是dmz组网UDP多个IP需多次进行呼叫 */
    TSDK_BOOL isCallRefer;                                                     /**< [en]Indicates Whether a call is forwarded 
                                                                                    [cn]本次呼叫是不是呼叫转移 */
    TSDK_CHAR peerNumberBeforeRefer[TSDK_D_MAX_NUMBER_LEN + 1];                /**< [en]Indicates peer number before refer 
                                                                                    [cn]呼转之前的对端号码 */
    TSDK_UINT32 downNetLevel;                                                  /**< [en]Indicates the down net level.
                                                                                    [cn]下行网络级别 */
    TSDK_UINT32 upNetLevel;                                                    /**< [en]Indicates the up net level.
                                                                                    [cn]上行网络级别 */
} TsdkCallInnerInfo;

/**
* [en]This enumeration is used to sets the video capture mode.
* [cn]摄像头状态
*/
typedef enum tagTSDK_E_CAMERA_STATE {
    TSDK_E_CAMERA_CLOSE = 0,      /**< [en]0 camera closed.
                                  [cn]0 摄像头关闭 */
    TSDK_E_CAMERA_OPEN = 1,       /**< [en]1 camera opened
                                  [cn]1 摄像头开启 */
    TSDK_E_NO_CAMERA = 2,         /**< [en]2 no camera
                                  [cn]2 无摄像头 */
    TSDK_E_CAMERA_STATE_BUTT
} TSDK_E_CAMERA_STATE;

/**
* [en]This enumeration is used to sets the mic mode.
* [cn]麦克风状态
*/
typedef enum tagTSDK_E_MIC_STATE {
    TSDK_E_MIC_MUTE = 0,       /**< [en]0 mic closed.
                               [cn]0 麦克风关闭 */
    TSDK_E_MIC_UNMUTE = 1,     /**< [en]1 mic opened
                               [cn]1 麦克风开启 */
    TSDK_E_MIC_STATE_BUTT
} TSDK_E_MIC_STATE;

/**
* [en]This enumeration is used to sets the speaker state.
* [cn]扬声器状态
*/
typedef enum tagTSDK_E_SPEAKER_STATE {
    TSDK_E_SPEAKER_MUTE = 0,           /**< [en]0 speaker closed.
                                            [cn]0 扬声器关闭 */
    TSDK_E_SPEAKER_UNMUTE = 1,         /**< [en]1 speaker opened
                                            [cn]1 扬声器开启 */
    TSDK_E_SPEAKER_STATE_BUTT
} TSDK_E_SPEAKER_STATE;

/**
* [en]This enumeration is used to sets the device state.
* [cn]设备状态
*/
typedef struct tagTSDK_S_DEVICE_STATE {
    TSDK_E_CAMERA_STATE cameraState;         /**< [en] camera state.
                                                  [cn] 摄像头状态 */
    TSDK_UINT32 cameraIndex;                 /**< [en] camera index, IOS reported that index 0 is the post-position and 1 is the pre-position.
                                                  [cn] 摄像头索引，IOS端上报index 0是后置 1是前置 */
    TSDK_E_MIC_STATE micState;               /**< [en] mic state.
                                                  [cn] 麦克风状态 */
    TSDK_E_SPEAKER_STATE speakerState;       /**< [en] speaker state.
                                                  [cn] 扬声器状态 */
} TSDK_S_DEVICE_STATE;

// 屏幕抓取回调函数原型声明
typedef TSDK_LONG(*CALL_WRAPPER_CAPTURE_CALLBACK_FUN)(TSDK_VOID* buffer, TSDK_LONG* pWidth, TSDK_LONG* pHeight);
#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_CALL_DEF_H__ */

