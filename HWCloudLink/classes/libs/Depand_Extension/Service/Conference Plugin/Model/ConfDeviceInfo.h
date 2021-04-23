//
//  ConfDeviceInfo.h
//  HWCloudLink
//
//  Created by mac on 2021/3/12.
//  Copyright © 2021 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *This enum is about conf device state enum
 *SC返回的摄像头状态
 */
typedef enum
{
    CONF_CAMERA_CLOSE = 0, // 关闭
    CONF_CAMERA_OPEN = 1, // 打开
    CONF_CAMERA_NO = 2, // 没有摄像头
    CONF_CAMERA_BUTT
} CONF_D_CAMERA_STATE;


/**
 *This enum is about conf device state enum
 *SC返回的麦克风状态
 */
typedef enum
{
    CONF_MIC_MUTE = 0, // 麦克风关闭
    CONF_MIC_UNMUTE = 1, // 麦克风开启
    CONF_MIC_BUTT
} CONF_D_MIC_STATE;

/**
 *This enum is about conf device state enum
 *SC返回的扬声器状态
 */
typedef enum
{
    CONF_SPEAKER_MUTE = 0, // 扬声器关闭
    CONF_SPEAKER_UNMUTE = 1, // 扬声器开启
    CONF_SPEAKER_BUTT,
} CONF_D_SPEAKER_STATE;


@interface ConfDeviceInfo : NSObject

@property (nonatomic, assign) CONF_D_CAMERA_STATE camera_type; // 摄像头状态
@property (nonatomic, assign) CONF_D_MIC_STATE mic_type; // 麦克风状态
@property (nonatomic, assign) CONF_D_SPEAKER_STATE speaker_type; // 扬声器状态
@property (nonatomic, assign) int cameraIndex; // 摄像头索引，IOS端上报index 0是后置 1是前置
@property (nonatomic, assign) unsigned int callId; //呼叫id

@end

NS_ASSUME_NONNULL_END
