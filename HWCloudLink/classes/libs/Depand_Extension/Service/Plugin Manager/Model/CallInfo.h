//
//  CallInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

/**
 *This enum is about call state
 *呼叫状态枚举
 */
typedef NS_ENUM(NSUInteger, CallState) {
    CallStateIdle,
    CallStateIncoming,
    CallStateOutgoing,
    CallStateTaking,
    CallStateHold,
    CallStateEnd,
    CallStateButt
};

/**
 *This enum is about call type
 *呼叫类型
 */
typedef enum
{
    CALL_AUDIO = 0 ,
    CALL_VIDEO,
    CALL_UNKNOWN
}TUP_CALL_TYPE;

/**
 *This enum is about svc type
 *svc视频类型
 */
typedef enum
{
    CALL_SVC_H264 = 0,
    CALL_SVC_H265,
    CALL_SVC_UNKNOWN
}TUP_CALL_SVC_TYPE;

@class CallInfo;
@interface CallStateInfo : NSObject

@property (nonatomic, assign) unsigned int callId; //呼叫id
@property (nonatomic, assign) TUP_CALL_TYPE callType; //呼叫类型
@property (nonatomic, assign) CallState callState; //呼叫状态
@property (nonatomic, copy) NSString *callNum; //呼叫号码
@property (nonatomic, copy) NSString *callName; //主叫名字
@property (nonatomic, assign) unsigned int reasonCode; //失败码
@property (nonatomic, copy) NSString *reasonDescription; //失败原因

@end

@interface CallInfo : NSObject

@property (nonatomic, strong) CallStateInfo *stateInfo; //呼叫相关信息
@property (nonatomic, assign) BOOL isFocus; //是否为会议
@property (nonatomic, assign) BOOL isSvcCall; //是否为SVC会议
@property (nonatomic, assign) TUP_CALL_SVC_TYPE svcType; //  h264,h265视频能力
@property (nonatomic, assign) NSInteger ulSvcSsrcStart; // ssrc起始值
@property (nonatomic, assign) NSInteger ulSvcSsrcEnd; // ssrc结束值
@property (nonatomic, assign) unsigned int bandWidth; // 视频带宽
@property (nonatomic, assign) BOOL isAudienceConf; //是否单向直播观众会场
@property (nonatomic, assign) BOOL isOneWay; //观众会场是否单向能力
@property (nonatomic, copy) NSString *telNumTel; //主叫号码
@property (nonatomic, copy) NSString *serverConfId; //会议id
@property (nonatomic, assign) unsigned int orientType; //屏幕方向

@end
