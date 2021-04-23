//
//  ConfBaseInfo.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2018/9/10.
//  Copyright © 2018年 cWX160907. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"
#include "tsdk_conference_def.h"

typedef enum
{
    CONF_E_STATE_SCHEDULE = 0,    //预定状态
    CONF_E_STATE_CREATING,        //正在创建状态
    CONF_E_STATE_GOING,           //会议已经开始
    CONF_E_STATE_DESTROYED        //会议已经关闭
} CONF_E_STATE;

@interface ConfBaseInfo : NSObject
@property (nonatomic, copy) NSString *confId; //会议id
@property (nonatomic, copy) NSString *confSubject; //会议主题
@property (nonatomic, copy) NSString *accessNumber; //会议介入码
@property (nonatomic, copy) NSString *chairmanPwd; //会议主席密码
@property (nonatomic, copy) NSString *generalPwd; //普通与会者密码
@property (nonatomic, copy) NSString *startTime; //会议开始时间
@property (nonatomic, copy) NSString *endTime; //会议结束时间
@property (nonatomic, assign) BOOL hasChairman; // 会议中是否存在主席
@property (nonatomic, copy) NSString *timeZoneId; //时区 smc3.0
@property (nonatomic, assign) NSInteger duration; // 时长 smc3.0
@property (nonatomic, copy) NSString *confIdV3; //会议号 smc3.0
@property (nonatomic, copy) NSString *scheduleUserAccount; //会议预约者账号 smc3.0
@property (nonatomic, copy) NSString *scheduleUserName; //会议预约者姓名 smc3.0
@property (nonatomic, assign) BOOL isActive; // 会议是否处于活动状态 smc3.0
@property (nonatomic, assign) TSDK_E_CONF_TYPE_EX confType; //会议类型 smc3.0
@property (nonatomic, assign) BOOL signedConf; // 会议是否需要签到 smc3.0
@property (nonatomic, assign) NSInteger signInAheadTime; // 会议提前签到时间 smc3.0
@property (nonatomic, assign) TSDK_E_CONF_TYPE confTimeType; //会议时间类型 smc3.0
@property (nonatomic, assign) BOOL autoExtend; // 是否自动延长会议 smc3.0
@property (nonatomic, assign) BOOL autoEnd; //是否自动结束会议 smc3.0
@property (nonatomic, assign) BOOL autoMute; //是否自动闭音 smc3.0
@property (nonatomic, assign) BOOL voiceActive; //是否声控切换 smc3.0
@property (nonatomic, assign) BOOL enableRecord; //是否启用录播 smc3.0
@property (nonatomic, assign) BOOL enableLiveBroadcast; //是否启用直播 smc3.0
@property (nonatomic, assign) BOOL autoRecord; //是否启用自动录播或直播 smc3.0
@property (nonatomic, assign) BOOL audioRecord; //是否纯语音录制 smc3.0
@property (nonatomic, assign) BOOL amcRecord; //是否录制桌面 smc3.0
@property (nonatomic, copy) NSString *chairJoinUri; //主席入会链接 smc3.0
@property (nonatomic, copy) NSString *guestJoinUri; //来宾入会链接 smc3.0
@property (nonatomic, strong) NSArray *attendeesArray; // 与会人
@property (nonatomic, strong) NSArray *attendeeArray; // 与会者
@property (nonatomic, strong) NSArray *participantArray; // 会场
@property (nonatomic, assign) BOOL isVmrConf; // 是否是VMR会议

@property (nonatomic, assign) int callId; // call id
@property (nonatomic, assign) int size; //会议大小

@property (nonatomic, assign) BOOL recordStatus; //会议录制状态
@property (nonatomic, assign) BOOL lockState; //会议锁定状态
@property (nonatomic, assign) BOOL isAllMute; //是否全员禁言
@property (nonatomic, assign) EC_CONF_MEDIATYPE mediaType; //会议类型


// add jiangbz
@property (nonatomic, assign) CONF_E_STATE confState; //会议状态
@property (nonatomic, assign) BOOL isHdConf; //是否高清视频会议
@property (nonatomic, copy) NSString *token; //会议token
@property (nonatomic, assign) int numOfParticipant; //与会者个数
@property (nonatomic, assign) BOOL isConf; //是否是会议（不是会议就是点对点）
@property (nonatomic, assign) BOOL isComing; //是否是接听方（不是会议就是点对点）
@property (nonatomic, assign) BOOL isImmediately; // 是否立即入会
//虚拟会议
@property (nonatomic, copy) NSString *userAccount; //查询者帐号
@property (nonatomic, copy) NSString *name; //查询者帐号
@property (nonatomic, assign) unsigned int reasonCode;  // 错误码
@property (nonatomic, copy) NSString *nameForVoice;
// svc
@property (nonatomic, assign) BOOL isSvcConf;  // 是否是svc会议

+ (ConfBaseInfo *)transfromFromConfBaseInfo:(TSDK_S_CONF_BASE_INFO *)callStreamInfo;

@end
