//
//  ConferenceService.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConferenceService.h"

#include "tsdk_conference_def.h"
#include "tsdk_conference_interface.h"
#import "tsdk_error_def.h"


#include <arpa/inet.h>
#import <string.h>
#import "ConfAttendee+StructParase.h"
#import "ManagerService.h"
#import "ConfData.h"
#import "ConfAttendeeInConf.h"
#import "ConfDeviceInfo.h"
#import "Initializer.h"
#import "LoginInfo.h"
#import "LoginServerInfo.h"
#import "Defines.h"
#import "ChatMsg.h"
#import "ConfBaseInfo.h"
#import "CommonUtils.h"
#import "Logger.h"
#import "NSString+CZFTools.h"
#import "NSObject+CZFTools.h"

#import "securec.h"
#include "tsdk_maintain_interface.h"
//数据共享线程
dispatch_queue_t espace_dataconf_datashare_queue = 0;

#define MAX_CONF_NAME_ATTENDEE_LENGTH 64

#define JOIN_NUMBER_LEN 256
@interface ConferenceService()<TupConfNotifacation>

@property (nonatomic, assign) int confHandle;                     // current confHandle
@property (nonatomic, assign) NSString *dataConfIdWaitConfInfo;   // get current confId
@property (nonatomic, copy)NSString *sipAccount;                  // current sipAccount
@property (nonatomic, copy)NSString *account;                     // current account
@property (nonatomic, strong) NSString *confCtrlUrl;              // recorde dateconf_uri
@property (nonatomic, strong) NSMutableDictionary *confTokenDic;  // update conference token in SMC
@property (nonatomic, assign) BOOL hasReportMediaxSpeak;          // has reportMediaxSpeak or not in Mediax
@property (nonatomic, retain) NSTimer *heartBeatTimer;            // NSTime record heart beat
@property (nonatomic, assign) int currentCallId;                  // current call id

@property (nonatomic, assign) BOOL isStartScreenSharing;
@property (nonatomic, assign) int currentDataShareTypeId;

@property (nonatomic, strong)void (^cancelConfBackAction)(BOOL, NSError*);   // 取消预约会议block回掉
@property (nonatomic, strong)void (^svcWatchListInd)(BOOL, NSString*, NSArray<ConfAttendeeInConf*>*, NSDictionary*); // SVC观看列表回调
@end


@implementation ConferenceService

//creat getter and setter method of delegate
@synthesize delegate;

//creat getter and setter method of isJoinDataConf
@synthesize isJoinDataConf;

//creat getter and setter method of haveJoinAttendeeArray
@synthesize haveJoinAttendeeArray;

//creat getter and setter method of uPortalConfType
@synthesize uPortalConfType;

//creat getter and setter method of selfJoinNumber
@synthesize selfJoinNumber;

@synthesize isVideoConfInvited;

@synthesize chatDelegate;

@synthesize currentConfBaseInfo;

@synthesize vmrBaseInfo;

@synthesize lastConfSharedData;

@synthesize isHaveChair;

@synthesize isHaveAux;

@synthesize isRecvingAux;

@synthesize isSendAux;

@synthesize auxData;

@synthesize messageArray;


/**
 *This method is used to get sip account from call service
 *从呼叫业务获取sip账号
 */
-(NSString *)sipAccount
{
    NSString *sipAccount = [ManagerService callService].sipAccount;
    NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    
    return shortSipNum;
}

/**
 *This method is used to get login account from login service
 *从登陆业务获取鉴权登陆账号
 */
- (NSString *)account
{
    LoginInfo *mine = [[ManagerService loginService] obtainCurrentLoginInfo];
    _account = mine.account;
    
    return _account;
}

/**
 *This method is used to init this class， give initial value
 *初始化方法，给变量赋初始值
 */
-(instancetype)init
{
    if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            espace_dataconf_datashare_queue = dispatch_queue_create("com.huawei.espace.dataconf.datashare", 0);
        });
        [Initializer registerConfCallBack:self]; //注册回调，将回调消息分发代理设置为自己
        self.isJoinDataConf = NO;
        self.isHaveChair = NO;
        self.isHaveAux = NO;
        self.isRecvingAux = NO;
        self.isSendAux = NO;
        _confHandle = 0;
        self.haveJoinAttendeeArray = [[NSMutableArray alloc] init]; //会议与会者列表
        self.messageArray = [NSMutableArray array];
        self.uPortalConfType = CONF_TOPOLOGY_UC;
        _confTokenDic = [[NSMutableDictionary alloc]init];
        _confCtrlUrl = nil;
        self.selfJoinNumber = nil;
        _hasReportMediaxSpeak = NO;
        _currentCallId = 0;
        self.isVideoConfInvited = NO;
        self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
        self.vmrBaseInfo = [[ConfBaseInfo alloc] init];
        _isStartScreenSharing = NO;
        _currentDataShareTypeId = -1;
    }
    return self;
}

#pragma mark - EC 6.0

/**
 * This method is used to deel conference event callback from service
 * 分发会控业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)confModule:(TUP_MODULE)module notication:(Notification *)notification
{
    if (module == CONF_MODULE) {
        [self onRecvTupConferenceNotification:notification];
    }else {
        
    }
}

/**
 * This method is used to deel conference event notification
 * 处理会控业务回调
 */
- (void)onRecvTupConferenceNotification:(Notification *)notify 
{
//    DDLogInfo(@"onReceiveConferenceNotification msgId : %d",notify.msgId);
    switch (notify.msgId)
    {
        case TSDK_E_CONF_EVT_BOOK_CONF_RESULT: // 预约会议结果
        {
            BOOL result = notify.param1 == TSDK_SUCCESS;
            DDLogInfo(@"TSDK_E_CONF_EVT_BOOK_CONF_RESULT = %d", result);
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_BOOK_CONF_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                NSLog(@"TSDK_E_CONF_EVT_BOOK_CONF_RESULT,error:%@ , param1:%u",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data],notify.param1);
                [self handleGetConfListResult:nil];
                NSDictionary *resultInfo = @{
                                             ECCONF_RESULT_KEY : [NSString stringWithFormat:@"%d",notify.param1],
                                             };
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_BOOK_CONF_RESULT object:nil userInfo:resultInfo];
                return;
            }
            
            TSDK_S_CONF_BASE_INFO *confListInfo = (TSDK_S_CONF_BASE_INFO *)notify.data;
            if (confListInfo != NULL)
            {
                TSDK_S_CONF_BASE_INFO confInfo = (TSDK_S_CONF_BASE_INFO)confListInfo[0];
                NSLog(@"subject = %s", confInfo.subject);
                if (self.currentConfBaseInfo == nil) {
                    self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
                }
                self.currentConfBaseInfo = [ConfBaseInfo transfromFromConfBaseInfo:&confInfo];
                _dataConfIdWaitConfInfo = self.currentConfBaseInfo.confId;
                
            }
            //[NSNumber numberWithBool:result]
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSString stringWithFormat:@"%d",result],
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_CREATE_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_BOOK_CONF_RESULT object:nil userInfo:resultInfo];
            });
            
        }
            break;
        
        case TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT: // 查询会议列表结果
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT");
            BOOL result = notify.param1 == TSDK_SUCCESS;
            if (!result) {
                    [self handleGetConfListResult:nil];
                return;
            }
            [self handleGetConfListResult:notify];
        }
            break;
            
        case TSDK_E_CONF_EVT_QUERY_CONF_DETAIL_RESULT: // 查询会议详情结果
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_QUERY_CONF_DETAIL_RESULT");
            BOOL result = notify.param1 == TSDK_SUCCESS;
            if (!result && notify.data != nil) {
                DDLogError(@"TSDK_E_CONF_EVT_QUERY_CONF_DETAIL_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_QUERY_CONF_DETAIL_RESULT object:nil userInfo:nil];
                });
                return;
            }
            [self handleGetConfInfoResult:notify];
        }
            break;
        
        case  TSDK_E_CALL_EVT_DEVICE_STATE: // 上报设备状态
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_DEVICE_STATE_SC_CHANGE");
            int callID = notify.param1;
            if (callID != 0) {
                TSDK_S_DEVICE_STATE *devicceInfo = (TSDK_S_DEVICE_STATE *)notify.data;
                ConfDeviceInfo *device = [[ConfDeviceInfo alloc] init];
                device.cameraIndex = devicceInfo->cameraIndex;
                device.camera_type = (CONF_D_CAMERA_STATE)devicceInfo->cameraState;
                device.mic_type = (CONF_D_MIC_STATE)devicceInfo->micState;
                device.speaker_type = (CONF_D_SPEAKER_STATE)devicceInfo->speakerState;
                device.callId = notify.param1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSNotificationCenter.defaultCenter postNotificationName:CALL_S_CONF_EVT_DEVICE_STATE object:nil userInfo:@{CALL_S_CONF_EVT_DEVICE_STATE:device}];
                });
            }
        }
            break;
        case TSDK_E_CONF_EVT_JOIN_CONF_RESULT:  // 加入会议
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_JOIN_CONF_RESULT");
            BOOL result = notify.param2 == TSDK_SUCCESS;
            if (self.currentConfBaseInfo != nil) {
                self.currentConfBaseInfo.confSubject = @"";
                self.currentConfBaseInfo.accessNumber = @"";
            }
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_JOIN_CONF_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                NSDictionary *resultDic = @{@"CONF_E_CONNECT": [NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]};
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self respondsECConferenceDelegateWithType:CONF_E_CONNECT result:resultDic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_JOIN_CONF_RESULT object:nil userInfo:resultDic];
                });
                
                return;
            }
            
            _confHandle = notify.param1;
            TSDK_S_JOIN_CONF_IND_INFO *confInfo = (TSDK_S_JOIN_CONF_IND_INFO *)notify.data;
            _currentCallId = confInfo->call_id;

            if (self.currentConfBaseInfo == nil) {
                self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
            }
            self.currentConfBaseInfo.callId = _currentCallId;
            self.currentConfBaseInfo.confSubject = @"";
            self.currentConfBaseInfo.accessNumber = @"";
            self.lastConfSharedData = nil;
            self.isJoinDataConf = NO;
            self.isVideoConfInvited = NO;
            switch (confInfo->conf_media_type) {
                case TSDK_E_CONF_MEDIA_VOICE:
                    self.currentConfBaseInfo.mediaType = CONF_MEDIATYPE_VOICE;
                    break;
                 case TSDK_E_CONF_MEDIA_VIDEO:
                    self.currentConfBaseInfo.mediaType = CONF_MEDIATYPE_VIDEO;
                    self.isVideoConfInvited = YES;
                    break;
                case TSDK_E_CONF_MEDIA_VOICE_DATA:
                    self.currentConfBaseInfo.mediaType = CONF_MEDIATYPE_DATA;
                    self.isJoinDataConf = YES;
                    break;
                case TSDK_E_CONF_MEDIA_VIDEO_DATA:
                    self.currentConfBaseInfo.mediaType = CONF_MEDIATYPE_VIDEO_DATA;
                    self.isJoinDataConf = YES;
                    self.isVideoConfInvited = YES;
                    break;
                default:
                    break;
            }
            self.messageArray = nil;
            NSDictionary *resultInfo = @{@"CONF_E_CONNECT" : self.currentConfBaseInfo,
                                         @"JONIN_MEETING_RESULT_KEY" :[NSNumber numberWithBool:result]
            };
            self.currentConfBaseInfo.reasonCode = notify.param2;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_CONNECT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_JOIN_CONF_RESULT object:self.currentConfBaseInfo userInfo:resultInfo];
            });
        }
            break;
        
        case TSDK_E_CONF_EVT_GET_DATACONF_PARAM_RESULT: // 获取数据会议参数结果
        {
        }
            break;
        
        case TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT: // 会控操作结果
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT");
            [self onRecvConfCtrlOperationNotification:notify];
        }
            break;
        
        case TSDK_E_CONF_EVT_INFO_AND_STATUS_UPDATE: // 会议信息及状态状态更新
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_INFO_AND_STATUS_UPDATE");
            [self handleAttendeeUpdateNotify:notify];
        }
            break;
            
        case TSDK_E_CONF_EVT_REQUEST_CONF_RIGHT_FAILED:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_REQUEST_CONF_RIGHT_FAILED");
            BOOL result = notify.param2 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_REQUEST_CONF_RIGHT_FAILED,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                return;
            }
            
        }
            break;
        
        case TSDK_E_CONF_EVT_CONF_INCOMING_IND:
        {
            if (!self.selfJoinNumber) {
                self.selfJoinNumber = self.sipAccount;
            }
            
            DDLogInfo(@"TSDK_E_CONF_EVT_CONF_INCOMING_IND");
            int callID = notify.param2;
            _confHandle = notify.param1;
            TSDK_S_CONF_INCOMING_INFO *inComingInfo = (TSDK_S_CONF_INCOMING_INFO *)notify.data;
            
            CallInfo *tsdkCallInfo = [[CallInfo alloc]init];
            tsdkCallInfo.stateInfo.callId = callID;
            BOOL is_video_conf = NO;
            if (inComingInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO || inComingInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO_DATA) {
                is_video_conf = YES;
            }
            tsdkCallInfo.stateInfo.callType = is_video_conf?CALL_VIDEO:CALL_AUDIO;
            tsdkCallInfo.stateInfo.callNum = [NSString stringWithUTF8String:inComingInfo->number];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_COMING_CONF_NOTIFY
                                                                object:nil
                                                              userInfo:@{TUP_CONF_INCOMING_KEY : tsdkCallInfo}];
        }
            break;
            
        case TSDK_E_CONF_EVT_CONF_END_IND:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_CONF_END_IND");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_QUITE_TO_CONFLISTVIEW object:@"1"];
                [self respondsECConferenceDelegateWithType:CONF_E_END_RESULT result:nil];
            });
            [self confCtrlLeaveConference];
            [self restoreConfParamsInitialValue];
        }
            break;
            
        case TSDK_E_CONF_EVT_JOIN_DATA_CONF_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_JOIN_DATA_CONF_RESULT");
            NSDictionary *resultInfo = nil;
            BOOL isSuccess = notify.param2 == TSDK_SUCCESS;
            resultInfo = @{
                           UCCONF_RESULT_KEY :[NSNumber numberWithBool:isSuccess]
                           };
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CONF_JOIN_DATA_RESOULT object:[NSNumber numberWithBool:isSuccess]];
            });
            [self respondsECConferenceDelegateWithType:DATA_CONF_JOIN_RESOULT result:resultInfo];
        }
            break;
            
        case TSDK_E_CONF_EVT_AS_STATE_CHANGE:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_AS_STATE_CHANGE");
            TSDK_S_CONF_AS_STATE_INFO *shareState = (TSDK_S_CONF_AS_STATE_INFO *)notify.data;
            
            BOOL isStopSharing = NO;
            
            // DIFF:
            //收到开始程序共享的通知，结束之前的共享
            if (1 == notify.param2) {
                isStopSharing = YES;
            }
            
            TSDK_E_CONF_SHARE_STATE state =  shareState->state;
            
            switch (state) {
                case TSDK_E_CONF_AS_STATE_NULL:
                {
                    if (0 == notify.param2) {
                        _isStartScreenSharing = NO;
                        _currentDataShareTypeId = -1;
                        isStopSharing = YES;
                    }
                }
                    break;
                case TSDK_E_CONF_AS_STATE_START:
                case TSDK_E_CONF_AS_STATE_VIEW:
                {
                    if (0 == notify.param2) {
                        _isStartScreenSharing = YES;
                        _currentDataShareTypeId = 0x0002;
                    }
                }
                    break;
                default:
                    break;
            }

            if (isStopSharing) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(espace_dataconf_datashare_queue, ^{
                    [weakSelf stopSharedData];
                    weakSelf.isStartScreenSharing = NO;
                });
            }
        }
            break;
        case TSDK_E_CONF_EVT_AS_SCREEN_DATA_UPDATE:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_AS_SCREEN_DATA_UPDATE");
        }
            break;
        case TSDK_E_CONF_EVT_DS_DOC_NEW:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_DS_DOC_NEW");
        }
            break;
        
        case TSDK_E_CONF_EVT_DS_DOC_CURRENT_PAGE_IND:
        {
            
        }
            break;
            
        case TSDK_E_CONF_EVT_DS_DOC_CURRENT_PAGE:
        {
            
        }
            break;
        case TSDK_E_CONF_EVT_DS_DOC_DRAW_DATA_NOTIFY:
        {
        }
            break;
        
        case TSDK_E_CONF_EVT_DS_DOC_DEL:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(espace_dataconf_datashare_queue, ^{
            
            [weakSelf stopSharedData];
            
            });
        }
            break;
            
        case TSDK_E_CONF_EVT_WB_DOC_NEW:
        {
            _currentDataShareTypeId = 0x0200;
            DDLogInfo(@"TSDK_E_CONF_EVT_WB_DOC_NEW");
        }
            break;
        
        case TSDK_E_CONF_EVT_WB_DOC_CURRENT_PAGE_IND:
        {
        }
            break;
        
        case TSDK_E_CONF_EVT_WB_DOC_DRAW_DATA_NOTIFY:
        {
        }
            break;
        
        case TSDK_E_CONF_EVT_WB_DOC_DEL:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(espace_dataconf_datashare_queue, ^{
                [weakSelf stopSharedData];
                
            });
        }
            break;
            
        case TSDK_E_CONF_EVT_RECV_CHAT_MSG:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_RECV_CHAT_MSG");
            TSDK_S_CONF_CHAT_MSG_INFO *chat_msg_info = (TSDK_S_CONF_CHAT_MSG_INFO*)notify.data;
            [self handleChatMSGdata:chat_msg_info];
            break;
        }
            
        case TSDK_E_CONF_EVT_SPEAKER_IND: // 发言方通知
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_SPEAKER_IND");
            TSDK_S_CONF_SPEAKER_INFO *speaker_info = (TSDK_S_CONF_SPEAKER_INFO *)notify.data;
            TSDK_S_CONF_SPEAKER *speakers = speaker_info->speakers;
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < speaker_info->speaker_num; i++) {
                TSDK_S_CONF_SPEAKER speaker = speakers[i];
//                DDLogInfo(@"speaker.number :%s,speaker.is_speaking :%d",speaker.base_info.number,speaker.is_speaking);
                ConfCtrlSpeaker *confSpeaker = [[ConfCtrlSpeaker alloc] init];

                //add displayname --changed at 2020.7.15 by lisa
                NSString *number = [NSString stringWithUTF8String:speaker.base_info.number];
                NSString *displayName = [NSString stringWithUTF8String:speaker.base_info.display_name];

                if (number.length > 0) {
                    confSpeaker.number = number;
                }
                if (displayName.length > 0) {
                    confSpeaker.dispalyname = displayName;
                }

                confSpeaker.is_speaking = speaker.is_speaking;
                confSpeaker.speaking_volume = speaker.speaking_volume;
                [tempArray addObject:confSpeaker];
            }

            if (tempArray.count > 0) {
                NSDictionary *resultInfo = @{
                                             CALL_S_CONF_EVT_SPEAKER_IND : [NSArray arrayWithArray:tempArray]
                                             };
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_SPEAKER_IND object:nil userInfo:resultInfo];
                    [self respondsECConferenceDelegateWithType:CONF_E_SPEAKER_LIST result:resultInfo];
                });
            }
        }
            break;
        
        case TSDK_E_CONF_EVT_SHARE_STATUS_UPDATE_IND:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_SHARE_STATUS_UPDATE_IND");
            TSDK_S_SHARE_STATUS_INFO *statusInfo = (TSDK_S_SHARE_STATUS_INFO *)notify.data;
            [self onShareStatusUpateInd:statusInfo];
        }
            break;
        case TSDK_E_CONF_EVT_RECV_CUSTOM_DATA_IND:
        {
            TSDK_S_CONF_CUSTOM_DATA_INFO *custonInfo = (TSDK_S_CONF_CUSTOM_DATA_INFO *)notify.data;
            [self handleChatCustonMSGdata:custonInfo];
            DDLogInfo(@"TSDK_E_CONF_EVT_RECV_CUSTOM_DATA_IND");
        }
            break;
        case TSDK_E_CONF_EVT_CONF_BASE_INFO_IND: // 当前会议基础信息通知
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_CONF_BASE_INFO_IND");
            TSDK_S_CONF_BASE_INFO *confListInfo = (TSDK_S_CONF_BASE_INFO *)notify.data;
            if (confListInfo != NULL)
            {
                TSDK_S_CONF_BASE_INFO confInfo = (TSDK_S_CONF_BASE_INFO)confListInfo[0];
                
                if (self.currentConfBaseInfo == nil) {
                    self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
                }

                self.currentConfBaseInfo.confId = [NSString stringWithUTF8String:confInfo.confId];
                self.currentConfBaseInfo.confSubject = [NSString stringWithUTF8String:confInfo.subject];
                self.currentConfBaseInfo.accessNumber = [NSString stringWithUTF8String:confInfo.accessNumber];
                self.currentConfBaseInfo.chairmanPwd = [NSString stringWithUTF8String:confInfo.chairmanPwd];
                self.currentConfBaseInfo.generalPwd = [NSString stringWithUTF8String:confInfo.guestPwd];
//                NSString *utcDataStartString = [NSString stringWithUTF8String:confInfo.startTime];
//                self.currentConfBaseInfo.startTime = [CommonUtils getLocalDateFormateUTCDate:utcDataStartString];
//                NSString *utcDataEndString = [NSString stringWithUTF8String:confInfo.endTime];
//                self.currentConfBaseInfo.endTime = [CommonUtils getLocalDateFormateUTCDate:utcDataEndString];
                self.currentConfBaseInfo.startTime = [NSString stringWithUTF8String:confInfo.startTime];
                self.currentConfBaseInfo.endTime = [NSString stringWithUTF8String:confInfo.endTime];
                self.currentConfBaseInfo.scheduleUserAccount = [NSString stringWithUTF8String:confInfo.scheduleUserAccount];
                self.currentConfBaseInfo.scheduleUserName = [NSString stringWithUTF8String:confInfo.scheduleUserName];
                self.currentConfBaseInfo.chairJoinUri = [NSString stringWithUTF8String:confInfo.chairmanLink];
                self.currentConfBaseInfo.guestJoinUri = [NSString stringWithUTF8String:confInfo.guestLink];
                
                DDLogInfo(@"--onbaseinfo--");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_BASEINFO_UPDATE_KEY object:nil];
                 });
            }
        }
            break;
            
         case TSDK_E_CONF_EVT_DATA_COMPT_TOKEN_MSG://3044 令牌权限变更通知
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_DATA_COMPT_TOKEN_MSG");
            TSDK_S_CONF_TOKEN_MSG *token_info = (TSDK_S_CONF_TOKEN_MSG *)notify.data;
            if (token_info != NULL) {
                if (token_info->msg_type == TSDK_E_CONF_TOKEN_RELEASE_IND_MSG) {
                    self.isHaveAux = NO;
                    self.isRecvingAux = NO;
                    [self respondsECConferenceDelegateWithType:DATA_CONF_AUX_STREAM_STOP result:nil];
                    [self appShareDetach];
                }else if (token_info->msg_type == TSDK_E_CONF_TOKEN_OWNER_IND_MSG){
                    //                    [self respondsECConferenceDelegateWithType: result:nil];
                }
                
            }
            
        }
            break;
                case TSDK_E_CONF_EVT_PHONE_VIDEO_CAPABLE_IND://3047 电话能力更新
                {
                    DDLogInfo(@"TSDK_E_CONF_EVT_PHONE_VIDEO_CAPABLE_IND");
                    TSDK_BOOL *isHaveAux = (TSDK_BOOL *)notify.data;
                    if (isHaveAux != NULL) {
                        if (*isHaveAux != TSDK_FALSE) {
                            [self respondsECConferenceDelegateWithType:DATA_CONF_AUX_STREAM_BIND result:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CONF_AUX_STREAM_BIND_NOTIFY object:nil];
                            });
                        }
                    }
                }
                    break;
                case TSDK_E_CONF_EVT_AS_AUX_DEC_FRIST_FRAME:// 3049 辅流解码第一帧成功的通知
                {
                    DDLogInfo(@"TSDK_E_CONF_EVT_AS_AUX_DEC_FRIST_FRAME");
                    self.isHaveAux = YES;
		    self.isRecvingAux = YES;
                    [self respondsECConferenceDelegateWithType:DATA_CONF_AUX_STREAM_RECIVED result:nil];
                    [NSNotificationCenter.defaultCenter postNotificationName:@"DATA_EVT_AUS_RESIVE_FIRST" object:nil];
                }
                    break;
            
        case TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT:// 虚拟会议列表 3045 VMR
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT");
            TSDK_S_VMR_INFO *vrmList = (TSDK_S_VMR_INFO *)notify.data;
            if (vrmList != NULL)
            {
                 TSDK_S_VMR_INFO vmrInfo = (TSDK_S_VMR_INFO)vrmList[0];
                self.vmrBaseInfo.accessNumber = [NSString stringWithFormat:@"%@%@",[NSString stringWithUTF8String:vmrInfo.access_number],[NSString stringWithUTF8String:vmrInfo.conf_id]];
                DDLogInfo(@"self.vmrBaseInfo.accessNumber:%@",self.vmrBaseInfo.accessNumber);
                self.vmrBaseInfo.confId = [NSString stringWithUTF8String:vmrInfo.conf_id];
                self.vmrBaseInfo.chairmanPwd = [NSString stringWithUTF8String:vmrInfo.chairman_pwd];
                self.vmrBaseInfo.userAccount = [NSString stringWithUTF8String:vmrInfo.user_account];
                self.vmrBaseInfo.generalPwd = [NSString stringWithUTF8String:vmrInfo.guest_pwd];
                self.vmrBaseInfo.confSubject = [NSString stringWithUTF8String:vmrInfo.name];
                
            }else {
                DDLogInfo(@"VMR信息为空");
            }
        
            NSDictionary *resultInfo = @{VIRTUAL_MEETING_ROOM_LISTS_KEY: self.vmrBaseInfo};
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_GET_VMR_LIST_RESULT object:nil userInfo:resultInfo];
            });
        }
            break;
            
        case TSDK_E_CONF_EVT_SVC_WATCH_IND:  // 获取SVC观看列表
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_SVC_WATCH_IND");
            TSDK_S_SVC_REPORT_LIST_INFO* svc_report_info = (TSDK_S_SVC_REPORT_LIST_INFO *)notify.data;
            NSMutableArray *svclableArray = [NSMutableArray array];
            NSMutableDictionary *svclabelDic = [NSMutableDictionary dictionary];
            NSMutableArray *svcNumberArray = [NSMutableArray array];
            if (NULL != svc_report_info)
            {
                for (int i = 0; i < svc_report_info->total_count; i++)
                {
                    TSDK_S_SVC_REPORT svc_report = svc_report_info->svc_report[i];
                    ConfAttendeeInConf *confModel = [[ConfAttendeeInConf alloc] init];
                    confModel.number = [NSString stringWithUTF8String:svc_report.number];
                    confModel.lable_id = svc_report.lable_id;
                    [svclableArray addObject:confModel];
                    
                    NSMutableDictionary *confDic = [NSMutableDictionary dictionary];
                    [confDic setValue:[NSString encryptNumberWithString:[NSString stringWithUTF8String:svc_report.number]] forKey:@"number"];
                    [confDic setValue:[NSString stringWithFormat:@"%d",confModel.lable_id] forKey:@"label_id"];
                    [svcNumberArray addObject:confDic];
                    
                    [svclabelDic setObject:confModel forKey:confModel.number];
                }
            }
            DDLogInfo(@"TSDK_E_CONF_EVT_SVC_WATCH_IND result %@",svcNumberArray);
            // 回调
            if (self.svcWatchListInd) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.svcWatchListInd(svclableArray.count == 0 ? false : true, [NSString stringWithFormat:@"%d",notify.param1], svclableArray, svclabelDic);
                });
            }
            
            if (svclableArray.count == 0) {
                return;
            }
            NSDictionary *resultInfo = @{CALL_S_CONF_EVT_SVC_WATCH_IND: svclableArray};
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_SVC_WATCH_IND object:nil userInfo:resultInfo];
                [self respondsECConferenceDelegateWithType:CONF_E_UP_SVC_WATCH result:resultInfo];
            });
        }
            break;
            
        case TSDK_E_CONF_EVT_TIMEZONE_RESULT: // 查询时区列表(3.0及以后版本)
        {
            BOOL result = notify.param1 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"查询时区列表失败");
                DDLogError(@"TSDK_E_CONF_EVT_TIMEZONE_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TIMEZONE_LIST_KEY" object:nil userInfo:nil];
                });
                return;
            }
            NSMutableArray *tempArray = [NSMutableArray array];
            TSDK_S_CONF_TIME_ZONE_LIST *time_zone_list = (TSDK_S_CONF_TIME_ZONE_LIST *)notify.data;
            for (int i = 0; i < time_zone_list->time_zone_number; i++) {
                TSDK_S_CONF_TIME_ZONE_INFO  time_zone_info = time_zone_list->time_zone_info[i];
                TimezoneModel *zoneModel = [[TimezoneModel alloc] init];
                zoneModel.timeZoneId = [NSString stringWithUTF8String:time_zone_info.time_zone_id];
                zoneModel.timeZoneName = [NSString stringWithUTF8String:time_zone_info.time_zone_name];
                zoneModel.timeZoneDesc = [NSString stringWithUTF8String:time_zone_info.time_zone_desc];
                zoneModel.offset = time_zone_info.offset;
                [tempArray addObject:zoneModel];
                
                NSLog(@"time_zone_id = %s", time_zone_info.time_zone_id);
                NSLog(@"time_zone_name = %s", time_zone_info.time_zone_name);
                NSLog(@"time_zone_desc = %s", time_zone_info.time_zone_desc);
                NSLog(@"time_zone_offset = %d", time_zone_info.offset);
            }
            
            NSDictionary *resultInfo = @{
                                         @"TIMEZONE_LIST_KEY" : [NSArray arrayWithArray:tempArray]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TIMEZONE_LIST_KEY" object:nil userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_EVT_SVC_WATCH_POLICY_IND: // 转为大会模式
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_SVC_WATCH_POLICY_IND %d",notify.param1);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_SVC_WATCH_POLICY_IND object:nil userInfo:nil];
            });
            break;
        }
        case TSDK_E_CONF_EVT_CHECKIN_RESULT://会议签到
            {
                DDLogInfo(@"TSDK_E_CONF_EVT_CHECKIN_RESULT");
                BOOL result = notify.param1 == TSDK_SUCCESS;
                if (result) {
                    // 防止签到通知太快
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_CHECKIN_RESULT object:nil userInfo:nil];
                     });
                }
            }
            break;
        case TSDK_E_CONF_EVT_HAND_UP_IND://举手主席端提示
            {
                DDLogInfo(@"TSDK_E_CONF_EVT_HAND_UP_IND");
                TSDK_S_ATTENDEE *confStatusStruct = (TSDK_S_ATTENDEE *)notify.data;
                TSDK_S_ATTENDEE_BASE_INFO baseInfo = confStatusStruct->base_info;
                TSDK_S_ATTENDEE_STATUS_INFO status_info = confStatusStruct->status_info;
                if (status_info.is_handup) {
                    ConfAttendeeInConf *addAttendee = [[ConfAttendeeInConf alloc] init];
                    addAttendee.name = [NSString stringWithUTF8String:baseInfo.display_name];
                    addAttendee.number = [NSString stringWithUTF8String:baseInfo.number];
                    NSDictionary *resultInfo = @{ECCONF_HAND_UP_RESULT_KEY:addAttendee.name,@"ECCONF_HAND_UP_RESULT_NUMBER":addAttendee.number};
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_HAND_UP_IND object:nil userInfo:resultInfo];
                        });
                }
            }
            break;
        case  TSDK_E_CONF_EVT_BROADCAST_IND: // 广播事件通知
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_BROADCAST_IND");
            TSDK_BOOL isBroadcast = (TSDK_BOOL)notify.param1;
            TSDK_S_ATTENDEE *participant = (TSDK_S_ATTENDEE *)notify.data;
            ConfAttendeeInConf *addAttendee = [[ConfAttendeeInConf alloc] init];
            if (isBroadcast) {
                if (participant != nil) {
                    addAttendee.name = [NSString stringWithUTF8String:participant->base_info.display_name];
                    addAttendee.number = [NSString stringWithUTF8String:participant->base_info.number];
                    addAttendee.participant_id = [NSString stringWithUTF8String:participant->status_info.participant_id];
                    addAttendee.is_mute = (participant->status_info.is_mute == TSDK_TRUE);
                    if (participant->status_info.is_handup == TSDK_TRUE || participant->status_info.is_req_talk == TSDK_TRUE) {
                        addAttendee.hand_state = YES;
                    }else{
                        addAttendee.hand_state = NO;
                    }
                    addAttendee.is_open_camera = (participant->status_info.has_camera == TSDK_TRUE);
                    addAttendee.is_audio = (participant->status_info.is_audio == TSDK_TRUE);
                    addAttendee.role = (CONFCTRL_CONF_ROLE)participant->base_info.role;
                    addAttendee.state = (ATTENDEE_STATUS_TYPE)participant->status_info.state;
                    addAttendee.isJoinDataconf = participant->status_info.is_join_dataconf;
                    addAttendee.isPresent = participant->status_info.is_present;
                    addAttendee.isSelf = participant->status_info.is_self;
                    addAttendee.isBroadcast = participant->status_info.is_broadcast;
                    addAttendee.is_req_talk = participant->status_info.is_req_talk;
                    addAttendee.isBeWatch = NO;
                    if (!self.selfJoinNumber) {
                        self.selfJoinNumber = self.sipAccount;
                    }
                }else{
                    addAttendee.isBeWatch = YES;
                }
                
            }
            NSString *isBoard = (isBroadcast == true) ? @"1" : @"0";
            NSDictionary *resultInfo = @{@"isBroadcast":isBoard,@"attendee": addAttendee};
            DDLogInfo(@"TSDK_E_CONF_EVT_BROADCAST_IND result %@",resultInfo);
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:CALL_S_CONF_EVT_BROADCAST_IND object:nil userInfo:resultInfo];
            });
        }
            break;;

            //        case CONFCTRL_E_EVT_FLOOR_ATTENDEE_IND:
//        {
//            //Speaker report in this place
//            DDLogInfo(@"CONFCTRL_E_EVT_FLOOR_ATTENDEE_IND handle is : %d",notify.param1);
//            CONFCTRL_S_FLOOR_ATTENDEE_INFO *floorAttendee = (CONFCTRL_S_FLOOR_ATTENDEE_INFO *)notify.data;
//            CONFCTRL_S_SPEAKER *speakers = floorAttendee->speakers;
//            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//            for (int i =0; i< floorAttendee->num_of_speaker; i++)
//            {
//                DDLogInfo(@"speakers[i].number :%s,speakers[i].is_speaking :%d",speakers[i].number,speakers[i].is_speaking);
//                ConfCtrlSpeaker *speaker = [[ConfCtrlSpeaker alloc] init];
//                speaker.number = [NSString stringWithUTF8String:speakers[i].number];
//                speaker.is_speaking = speakers[i].is_speaking;
//                speaker.speaking_volume = speakers[i].speaking_volume;
//                [tempArray addObject:speaker];
//            }
//
//            NSDictionary *resultInfo = @{
//                                         ECCONF_SPEAKERLIST_KEY : [NSArray arrayWithArray:tempArray]
//                                         };
//            [self respondsECConferenceDelegateWithType:CONF_E_SPEAKER_LIST result:resultInfo];
//        }
//            break;
                break;
            case TSDK_E_CONF_EVT_CANCEL_CONF_RESULT:
            {
                DDLogInfo(@"TSDK_E_CONF_EVT_CANCEL_CONF_RESULT");
                TSDK_UINT32 result = notify.param1;
                if (self.cancelConfBackAction) {
                    self.cancelConfBackAction(result == TSDK_SUCCESS, [NSError errorWithDomain:@"" code:result userInfo:nil]);
                }
            }
            break;
        case TSDK_E_CONF_EVT_VMR_CHANGEED_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_VMR_CHANGEED_RESULT");
            TSDK_UINT32 result = notify.param1;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",result],@"result", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateVMRResult" object:nil userInfo:dict];
        }
            break;
        default:
            break;
    }
}

- (void)onShareStatusUpateInd:(TSDK_S_SHARE_STATUS_INFO *)statusInfo
{
    TSDK_E_SHARE_STATUS status = statusInfo->share_status;
    TSDK_E_COMPONENT_ID componetId = (TSDK_E_COMPONENT_ID)statusInfo->component_id;
    
    switch (status) {
        case TSDK_E_SHARE_STATUS_STOP: {
            _currentDataShareTypeId = 0;
            //            prevDataShareTypeId_ = 0;
            [self stopSharedData];
            return;
        }
        case TSDK_E_SHARE_STATUS_SHARING: {
            if (TSDK_E_COMPONENT_BASE == componetId || TSDK_E_COMPONENT_VIDEO == componetId || TSDK_E_COMPONENT_RECORD == componetId || TSDK_E_COMPONENT_POLLING == componetId || TSDK_E_COMPONENT_FT == componetId){
                _currentDataShareTypeId = 0;
                [self stopSharedData];
                return;
            }
            // 当前的模块变为新来的模块
            _currentDataShareTypeId = componetId;
            break;
        }
        default:
            break;
    }
}

bool getIntValueFromXmlByNodeName(const char* xml, const char *pBeginNode, const char *pEndNode, unsigned int &value) {
    char tempValue[32];
    memset_s(tempValue, 32, 0, 32);
    
    size_t  iKeyLength = strlen(pBeginNode);
    const char *pBegin = strstr(xml, pBeginNode);
    
    if (NULL == pBegin) {
        return false;
    }
    
    const char *pEnd = strstr(xml, pEndNode);
    if (NULL == pEnd) {
        return false;
    }
    
    memcpy(tempValue, pBegin+iKeyLength,  pEnd-pBegin-iKeyLength);
    
    NSString *tempValueString = [NSString stringWithFormat:@"%s",tempValue];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    //value = atoi(tempValue);
    NSNumber *tempValueNumber = [f numberFromString:tempValueString];
    value = [tempValueNumber unsignedIntValue];
    //value = strtoul(tempValue, NULL, 10);
    
    return true;
}

/**
 * This method is used to deal chat message.
 * 聊天消息处理
 *@param pData void*
 */
-(void)handleChatMSGdata:(TSDK_S_CONF_CHAT_MSG_INFO*)pData
{
    
    TSDK_S_CONF_CHAT_MSG_INFO *chatMsg = (TSDK_S_CONF_CHAT_MSG_INFO *)pData;
    TSDK_CHAR charMsgC[chatMsg->chat_msg_len+1];
	memset_s(charMsgC, chatMsg->chat_msg_len+1, 0, chatMsg->chat_msg_len+1);
    memcpy(charMsgC, chatMsg->chat_msg, chatMsg->chat_msg_len);
    DDLogInfo(@"charMsgC: %s",charMsgC);
    NSString *msgStr = [NSString stringWithUTF8String:charMsgC];

    DDLogInfo(@"msgStr :%@,chatMsg->lpMsg :%s, chatMsg->sender_display_name :%s，chatMsg->nMsgLen:%d",msgStr,chatMsg->chat_msg,chatMsg->sender_display_name,chatMsg->chat_msg_len);
    ChatMsg *tupMsg = [[ChatMsg alloc] init];
    tupMsg.nMsgLen = chatMsg->chat_msg_len;
    tupMsg.time = chatMsg->time;
    tupMsg.lpMsg = msgStr;
    tupMsg.fromUserName = [NSString stringWithUTF8String:chatMsg->sender_display_name];;
    if (tupMsg.fromUserName.length == 0 || tupMsg.fromUserName == nil) {
        tupMsg.fromUserName = [NSString stringWithUTF8String:chatMsg->sender_number];;
    }
    if (self.messageArray == nil) {
        self.messageArray = [NSMutableArray array];
    }
    [self.messageArray addObject:tupMsg];
    if ([self.chatDelegate respondsToSelector:@selector(didReceiveChatMessage:)]) {
        [self.chatDelegate didReceiveChatMessage:tupMsg];
    }
}


/**
 * This method is used to deal chat message.
 * 通用聊天消息处理
 *@param pData void*
 */
-(void)handleChatCustonMSGdata:(TSDK_S_CONF_CUSTOM_DATA_INFO*)pData
{
    
    TSDK_S_CONF_CUSTOM_DATA_INFO *chatMsg = (TSDK_S_CONF_CUSTOM_DATA_INFO *)pData;
    TSDK_INT8 charMsgC[chatMsg->data_len+1];
    memset_s(charMsgC, chatMsg->data_len+1, 0, chatMsg->data_len+1);
	memcpy(charMsgC, chatMsg->data_content, chatMsg->data_len);
    DDLogInfo(@"charMsgC: %s",charMsgC);
    NSString *msgStr = [NSString stringWithUTF8String:charMsgC];
    
    DDLogInfo(@"msgStr :%@,chatMsg->lpMsg :%s, chatMsg->sender_display_name :%s，chatMsg->nMsgLen:%d",msgStr,chatMsg->data_content,chatMsg->sender_display_name,chatMsg->data_len);
    ChatMsg *tupMsg = [[ChatMsg alloc] init];
    tupMsg.nMsgLen = chatMsg->data_len;
    tupMsg.time = [[NSDate date]timeIntervalSince1970];
    tupMsg.lpMsg = msgStr;
    tupMsg.fromUserName = [NSString stringWithUTF8String:chatMsg->sender_display_name];;
    if (tupMsg.fromUserName.length == 0 || tupMsg.fromUserName == nil) {
        tupMsg.fromUserName = [NSString stringWithUTF8String:chatMsg->sender_number];;
    }
    if (self.messageArray == nil) {
        self.messageArray = [NSMutableArray array];
    }
    [self.messageArray addObject:tupMsg];
    if ([self.chatDelegate respondsToSelector:@selector(didReceiveChatMessage:)]) {
        [self.chatDelegate didReceiveChatMessage:tupMsg];
    }
}

- (void)onRecvConfCtrlOperationNotification:(Notification *)notify
{
    TSDK_S_CONF_OPERATION_RESULT *operationResult = (TSDK_S_CONF_OPERATION_RESULT *)notify.data;
    BOOL result = operationResult->reason_code == TSDK_SUCCESS;
    if (!result) {
        DDLogError(@"onRecvConfCtrlOperationNotification error : %d,  description : %@",operationResult->reason_code, [NSString stringWithUTF8String:operationResult->description]);
    }
    DDLogInfo(@"onRecvConfCtrlOperationNotification operation type : %d",operationResult->operation_type);
    switch (operationResult->operation_type) {
        case TSDK_E_CONF_UPGRADE_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_UPGRADE_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_UPGRADE_RESULT result:resultInfo];
            
        }
            break;
            
        case TSDK_E_CONF_MUTE_CONF: // 闭音会场
        {
            DDLogInfo(@"TSDK_E_CONF_MUTE_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_MUTE_KEY: [NSNumber numberWithBool:YES],
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_MUTE_RESULT result:resultInfo];
            
            //全体闭音的通知
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:CALL_S_CONF_MUTE_CONF_SUCSESS object:nil userInfo:@{ECCONF_RESULT_KEY : [NSNumber numberWithBool:result]}];
            });
            
            
        }
            break;
        case TSDK_E_CONF_UNMUTE_CONF: // 取消闭音
        {
            DDLogInfo(@"TSDK_E_CONF_UNMUTE_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_MUTE_KEY: [NSNumber numberWithBool:NO],
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_MUTE_RESULT result:resultInfo];
            
            //全体取消闭音的通知
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:CALL_S_CONF_UNMUTE_CONF_SUCSESS object:nil userInfo:@{ECCONF_RESULT_KEY : [NSNumber numberWithBool:result]}];
            });
            
        }
            break;
        case TSDK_E_CONF_LOCK_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_LOCK_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_LOCK_STATUS_CHANGE result:resultInfo];
            
        }
            break;
        case TSDK_E_CONF_UNLOCK_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_UNLOCK_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_LOCK_STATUS_CHANGE result:resultInfo];
        }
            break;
        case TSDK_E_CONF_ADD_ATTENDEE: // 添加与会者
        {
            DDLogInfo(@"TSDK_E_CONF_ADD_ATTENDEE");
            NSDictionary *resultInfo = @{
                CALL_S_CONF_ADD_ATTENDEE : [NSNumber numberWithBool:result]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_ADD_ATTENDEE_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_ADD_ATTENDEE object:nil userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_REMOVE_ATTENDEE: // 删除与会者
        {
            DDLogInfo(@"TSDK_E_CONF_REMOVE_ATTENDEE");
        }
            break;
            
        case TSDK_E_CONF_REDIAL_ATTENDEE: // 重拨与会者
        {
            DDLogInfo(@"TSDK_E_CONF_CALL_ATTENDEE");
        }
            break;
            
        case TSDK_E_CONF_HANG_UP_ATTENDEE: // 挂断与会者
        {
            DDLogInfo(@"TSDK_E_CONF_HANG_UP_ATTENDEE -- 挂断");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_HANGUP_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_MUTE_ATTENDEE: // 闭音与会者
        {
            DDLogInfo(@"TSDK_E_CONF_MUTE_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_MUTE_ATTENDEE_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_MUTE_ATTENDEE object:nil userInfo:resultInfo];
            });
            
        }
            break;
        case TSDK_E_CONF_UNMUTE_ATTENDEE: // 取消闭音与会者
        {
            DDLogInfo(@"TSDK_E_CONF_UNMUTE_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_MUTE_ATTENDEE_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_UNMUTE_ATTENDEE object:nil userInfo:resultInfo];
            });
            
            
        }
            break;
        case TSDK_E_CONF_SET_HANDUP: // 设置举手
        {
            DDLogInfo(@"TSDK_E_CONF_SET_HANDUP");
            NSDictionary *resultInfo = @{
                CALL_S_CONF_SET_HANDUP : [NSNumber numberWithInt:result]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_HANDUP_ATTENDEE_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_SET_HANDUP object:nil userInfo:resultInfo];
            });
            
        }
            break;
        case TSDK_E_CONF_CANCLE_HANDUP: //取消设置举手
        {
            DDLogInfo(@"TSDK_E_CONF_CANCLE_HANDUP");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_RAISEHAND_ATTENDEE_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_CANCLE_HANDUP object:nil userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_SET_VIDEO_MODE: // 设置会议视频模式
        {
            DDLogInfo(@"TSDK_E_CONF_SET_VIDEO_MODE");
            NSDictionary *resultInfo = @{
                CALL_S_CONF_SET_VIDEO_MODE : [NSNumber numberWithInt:result]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_CONF_SET_VIDEO_MODE result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_SET_VIDEO_MODE
                                                                    object:nil
                                                                  userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_WATCH_ATTENDEE: // 选看
        {
            DDLogInfo(@"TSDK_E_CONF_WATCH_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result == 1 ? 1 : operationResult->reason_code]
                                         };
            //选看成功的通知
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_CONF_WATCH_ATTENDEE result:resultInfo];
                [NSNotificationCenter.defaultCenter postNotificationName:CALL_S_CONF_WATCH_ATTENDEE object:nil userInfo:resultInfo];
            });
            
        }
            break;
        case TSDK_E_CONF_POSTPONE_CONF: // 延长会议
        {
            DDLogInfo(@"TSDK_E_CONF_POSTPONE_CONF  -- 延长会议");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_CONF_POSTPONE_CONF result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_E_CONF_POSTPONE_CONF object:nil userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_BROADCAST_ATTENDEE: // 广播指定与会者
        {
            DDLogInfo(@"TSDK_E_CONF_BROADCAST_ATTENDEE");
            NSDictionary *resultInfo = @{
            ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_CONF_BROADCAST_ATTENDEE result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_BROADCAST_ATTENDEE object:nil userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_CANCEL_BROADCAST_ATTENDEE: // 取消广播指定与会者
        {
            DDLogInfo(@"TSDK_E_CONF_CANCEL_BROADCAST_ATTENDEE");
            NSDictionary *resultInfo = @{
            ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_CONF_CANCEL_BROADCAST_ATTENDEE result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_CANCEL_BROADCAST_ATTENDEE object:nil userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_REQUEST_CHAIRMAN:  // 申请主席
        {
            DDLogInfo(@"TSDK_E_CONF_REQUEST_CHAIRMAN -- reasonCode = %d", operationResult->reason_code);
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result == 1 ? result : operationResult->reason_code]
                                         };
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_REQUEST_CHAIRMAN_RESULT result:resultInfo];
                 [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_REQUEST_CHAIRMAN object:nil userInfo:resultInfo];
            });
        }
            break;
        case TSDK_E_CONF_RELEASE_CHAIRMAN:  // 释放主席
        {
            DDLogInfo(@"TSDK_E_CONF_RELEASE_CHAIRMAN -- reasonCode = %d", operationResult->reason_code);
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result == 1 ? result : operationResult->reason_code]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsECConferenceDelegateWithType:CONF_E_RELEASE_CHAIRMAN_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_RELEASE_CHAIRMAN object:nil userInfo:resultInfo];
            });
            
        }
            break;
          
        case TSDK_E_CONF_ROLL_CALL: { //点名
            DDLogInfo(@"TSDK_E_CONF_ROLL_CALL");
            NSDictionary *resultInfo = @{ ECCONF_RESULT_KEY : [NSNumber numberWithInt:result] };
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:CALL_S_CONF_ROLL_CALL object:nil userInfo:resultInfo];
            });
        }
            break;
        case  TSDK_E_CONF_WATCH_SVC_ATTENDEE: {
            DDLogInfo(@"TSDK_E_CONF_WATCH_SVC_ATTENDEE");
            NSDictionary *resultInfo = @{ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]};
            
        }
            break;
        default:
            break;
    }
    
}

/**
 *This method is used to post service handle result to UI by delegate
 *将业务处理结果消息通过代理分发给页面进行ui处理
 */
-(void)respondsECConferenceDelegateWithType:(EC_CONF_E_TYPE)type result:(NSDictionary *)resultDictionary
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ecConferenceEventCallback:result:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate ecConferenceEventCallback:type result:resultDictionary];
        });
    }
}

/**
 *This method is used to handle conf info update notification
 *处理会议信息改变上报的回调
 */
-(void)handleAttendeeUpdateNotify:(Notification *)notify
{
    TSDK_S_CONF_STATUS_INFO *confStatusStruct = (TSDK_S_CONF_STATUS_INFO *)notify.data;
    
    if (self.currentConfBaseInfo != nil) {
        self.currentConfBaseInfo.size = confStatusStruct->size;
        self.currentConfBaseInfo.mediaType = (EC_CONF_MEDIATYPE)confStatusStruct->conf_media_type;
        self.currentConfBaseInfo.confId = [NSString stringWithUTF8String:confStatusStruct->conf_id];
        self.currentConfBaseInfo.callId = _currentCallId;
        self.currentConfBaseInfo.hasChairman = confStatusStruct->hasChairman;
        self.currentConfBaseInfo.recordStatus = confStatusStruct->is_record;
        self.currentConfBaseInfo.lockState = confStatusStruct->is_lock;
        self.currentConfBaseInfo.isAllMute = confStatusStruct->is_all_mute;
    }
    
    TSDK_S_ATTENDEE *participants = confStatusStruct->attendee_list;
    [self.haveJoinAttendeeArray removeAllObjects];
    self.isHaveChair = NO;
    for (int i = 0; i<confStatusStruct->attendee_num; i++)
    {
        TSDK_S_ATTENDEE participant = participants[i];
        
        ConfAttendeeInConf *addAttendee = [[ConfAttendeeInConf alloc] init];
        addAttendee.name = [NSString stringWithUTF8String:participant.base_info.display_name];
        addAttendee.number = [NSString stringWithUTF8String:participant.base_info.number];
        addAttendee.participant_id = [NSString stringWithUTF8String:participant.status_info.participant_id];
        addAttendee.is_mute = (participant.status_info.is_mute == TSDK_TRUE);
        addAttendee.hand_state = (participant.status_info.is_handup == TSDK_TRUE);
        if (participant.status_info.is_handup == TSDK_TRUE || participant.status_info.is_req_talk == TSDK_TRUE) {
            addAttendee.hand_state = YES;
        }else{
            addAttendee.hand_state = NO;
        }
        addAttendee.is_open_camera = (participant.status_info.has_camera == TSDK_TRUE);
        addAttendee.is_audio = (participant.status_info.is_audio == TSDK_TRUE);
        addAttendee.role = (CONFCTRL_CONF_ROLE)participant.base_info.role;
        addAttendee.state = (ATTENDEE_STATUS_TYPE)participant.status_info.state;
        addAttendee.type = (EC_CONF_MEDIATYPE)confStatusStruct->conf_media_type;
        addAttendee.isJoinDataconf = participant.status_info.is_join_dataconf;
        addAttendee.isPresent = participant.status_info.is_present;
        addAttendee.isSelf = participant.status_info.is_self;
        addAttendee.isBroadcast = participant.status_info.is_broadcast;
        addAttendee.is_req_talk = participant.status_info.is_req_talk;
        [self.haveJoinAttendeeArray addObject:addAttendee];
        
        if (addAttendee.role == CONF_ROLE_CHAIRMAN) {
            self.isHaveChair = YES;
        }
        if (!self.selfJoinNumber) {
            self.selfJoinNumber = self.sipAccount;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE object:nil];
        [self respondsECConferenceDelegateWithType:CONF_E_ATTENDEE_UPDATE_INFO result:nil];
    });
}

/**
 *This method is used to handle get conf info result notification
 *处理获取会议信息结果回调
 */
-(void)handleGetConfInfoResult:(Notification *)notify
{
    TSDK_S_CONF_DETAIL_INFO *confInfo = (TSDK_S_CONF_DETAIL_INFO*)notify.data;
    TSDK_S_CONF_BASE_INFO confListInfo = confInfo->conf_info;
    DDLogInfo(@"conf_id : %@, subject : %@, conf_media_type: %d,scheduser_name:%@,scheduser_account:%s, start_time:%s, end_time:%s",
              [NSString encryptNumberWithString:[NSString stringWithFormat:@"%s", confListInfo.confId]],[NSString encryptNumberWithString:[NSString stringWithFormat:@"%s", confListInfo.subject]],confListInfo.conferenceType,[NSString encryptNumberWithString:[NSString stringWithFormat:@"%s", confListInfo.scheduleUserName]],[NSString encryptNumberWithString:[NSString stringWithFormat:@"%s", confListInfo.scheduleUserAccount]],confListInfo.startTime,confListInfo.endTime);
    ConfBaseInfo *Info = [ConfBaseInfo transfromFromConfBaseInfo:&confListInfo];
    NSDictionary *resultInfo = @{
        CALL_S_CONF_EVT_QUERY_CONF_DETAIL_RESULT : Info
                                 };
    //post current conf info detail to UI 
    dispatch_async(dispatch_get_main_queue(), ^{
        [self respondsECConferenceDelegateWithType:CONF_E_CURRENTCONF_DETAIL result:resultInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_QUERY_CONF_DETAIL_RESULT object:nil userInfo:resultInfo];
    });
}

/**
 *This method is used to handle get conf list result notification, if success refresh UI page
 *处理获取会议列表回调，如果成功，刷新UI页面
 */
-(void)handleGetConfListResult:(Notification *)notify
{
    if (notify == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_QUERY_CONF_LIST_RESULT object:nil];
        });
        return;
    }
    TSDK_S_CONF_LIST_INFO *confListInfoResult = (TSDK_S_CONF_LIST_INFO*)notify.data;
    DDLogInfo(@"confListInfoResult->current_count----- :%d ",confListInfoResult->current_count);
    TSDK_S_CONF_BASE_INFO *confList = confListInfoResult->conf_info_list;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< confListInfoResult->current_count; i++)
    {
        ConfBaseInfo *confBaseInfo = [ConfBaseInfo transfromFromConfBaseInfo:&confList[i]];
        [tempArray addObject:confBaseInfo];
    }
    NSDictionary *resultInfo = @{
        CALL_S_CONF_EVT_QUERY_CONF_LIST_RESULT : tempArray
                                 };
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_EVT_QUERY_CONF_LIST_RESULT object:tempArray];
        [self respondsECConferenceDelegateWithType:CONF_E_GET_CONFLIST result:resultInfo];
    });
    
}

#pragma mark  public

/**
 *This method is used to give value to struct CONFCTRL_S_ATTENDEE by memberArray
 *用memberArray给结构体CONFCTRL_S_ATTENDEE赋值，为创会时的入参
 */
-(TSDK_S_BOOK_CONF_ATTENDEE_INFO *)returnAttendeeWithArray:(NSArray *)memberArray
{
    TSDK_S_BOOK_CONF_ATTENDEE_INFO *attendee = (TSDK_S_BOOK_CONF_ATTENDEE_INFO *)malloc(memberArray.count*sizeof(TSDK_S_BOOK_CONF_ATTENDEE_INFO));
    memset_s(attendee, memberArray.count *sizeof(TSDK_S_BOOK_CONF_ATTENDEE_INFO), 0, memberArray.count *sizeof(TSDK_S_BOOK_CONF_ATTENDEE_INFO));
    for (int i = 0; i<memberArray.count; i++) {
 
        LdapContactInfo *info = memberArray[i];
        // 3.0传组织名称字段,有的字段传上
        if ([ManagerService callService].isSMC3) {
            if (info.deptName.length > 0 && info.deptName != nil) {
                strcpy_s(attendee[i].organizationName, sizeof(attendee[i].organizationName), [info.deptName UTF8String]);
            }
            if (info.nickName.length > 0 && info.nickName != nil) {
                strcpy_s(attendee[i].number, sizeof(attendee[i].number), [info.nickName UTF8String]);
            }
            if (info.name.length > 0 && info.name != nil) {
                strcpy_s(attendee[i].display_name, sizeof(attendee[i].display_name), [info.name UTF8String]);
            }
            if (info.ucAcc.length > 0 && info.ucAcc != nil) {
                strcpy_s(attendee[i].uri, sizeof(attendee[i].uri), [info.ucAcc UTF8String]);
            }
            if (info.email.length > 0 && info.email != nil) {
                strcpy_s(attendee[i].email, sizeof(attendee[i].email), [info.email UTF8String]);
            }
            attendee->terminal_type = TSDK_E_CONF_TERMINAL_SIP;
        } else {
            if (info.name.length > 0 && info.name != nil) {
                strcpy_s(attendee[i].display_name, sizeof(attendee[i].display_name), [info.name UTF8String]);
            }
            if (info.number.length > 0 && info.number != nil) {
                strcpy_s(attendee[i].number, sizeof(attendee[i].number), [info.number UTF8String]);
            }
            if (info.ucAcc.length > 0 && info.ucAcc != nil) {
                strcpy_s(attendee[i].uri, sizeof(attendee[i].uri), [info.ucAcc UTF8String]);
            }
            if (info.email.length > 0 && info.email != nil) {
                strcpy_s(attendee[i].email, sizeof(attendee[i].email), [info.email UTF8String]);
            }
        }
        if (info.role == CONF_ROLE_CHAIRMAN) {
            self.selfJoinNumber = info.number;
        }
        DDLogInfo(@"attendee is : %@",[NSString encryptNumberWithString:[NSString stringWithFormat:@"%s", attendee[i].number]]);
    }
    return attendee;
}

- (TSDK_S_PARTICIPANTREQ *)participantrWithArray:(NSArray *)memberArray {
    
    TSDK_S_PARTICIPANTREQ *attendee = (TSDK_S_PARTICIPANTREQ *)malloc(memberArray.count*sizeof(TSDK_S_PARTICIPANTREQ));
    memset_s(attendee, memberArray.count *sizeof(TSDK_S_PARTICIPANTREQ), 0, memberArray.count *sizeof(TSDK_S_BOOK_CONF_ATTENDEE_INFO));
    
    // MARK: - 修改这里的代码请慎重,一个参数错误导致预约失败 by yantf 2021-01-06
    for (int i = 0; i<memberArray.count; i++) {
        LdapContactInfo *info = memberArray[i];
        if (info.ucAcc.length > 0 && info.ucAcc != nil) {
            strcpy_s(attendee[i].uri, sizeof(attendee[i].uri), [info.ucAcc UTF8String]);
        }
        if (info.name.length > 0 && info.name != nil) {
            strcpy_s(attendee[i].name, sizeof(attendee[i].name), [info.name UTF8String]);
        }
        if (info.deptName.length > 0 && info.deptName != nil) {
            strcpy_s(attendee[i].organizationName, sizeof(attendee[i].organizationName), [info.deptName UTF8String]);
        }
        if (info.email.length > 0 && info.email != nil) {
            strcpy_s(attendee[i].email, sizeof(attendee[i].email), [info.email UTF8String]);
        }
        if (info.terminalType.length > 0 && info.terminalType != nil) {
            strcpy_s(attendee[i].terminalType, sizeof(attendee[i].terminalType), [info.terminalType UTF8String]);
        }
        if (info.tpSpeed.length > 0 && info.tpSpeed != nil) {
            strcpy_s(attendee[i].terminalRate, sizeof(attendee[i].terminalRate), [info.tpSpeed UTF8String]);
        } else {
            strcpy_s(attendee[i].terminalRate, sizeof(attendee[i].terminalRate), "");
        }

        // comment by wangyh 2021-01-06
        // attendee->rate = (TSDK_UINT32)[info.tpSpeed intValue];
        DDLogInfo(@"attendee is : %@",[NSString encryptNumberWithString:[NSString stringWithFormat:@"%s", attendee[i].name]]);
    }
    return attendee;
}

/**
 *This method is used to transform local date to UTC date
 *将本地时间转换为UTC时间
 */
-(NSString *)getUTCFormateLocalDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //input
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //output
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}
 
 
/**
 * This method is used to create conference
 * 创建会议，预约会议
 *@param attendeeArray one or more attendees
 *@param mediaType EC_CONF_MEDIATYPE value
 *@return YES or NO
 */
-(BOOL)createConferenceWithAttendee:(NSArray *)attendeeArray
                          mediaType:(EC_CONF_MEDIATYPE)mediaType
                            subject:(NSString *)subject
                          startTime:(NSDate *)startTime
                            confLen:(int)confLen
                           chairmanPassword:(NSString *)chairmanPassword
                   guestPassword:(NSString *)guestPassword
                      timezoneModel:(TimezoneModel *)timezoneModel
                    personalConfId:(NSString *)personalConfId
			   			   {
                               
       return [self tupConfctrlBookConf:attendeeArray mediaType:mediaType startTime:startTime confLen:confLen chairmanPassword:chairmanPassword guestPassword:guestPassword subject:subject timezoneModel:timezoneModel personalConfId:personalConfId];
}

/**
 * This method is used to create conference
 * 创会（有密码）
 *@param attendeeArray one or more attendees
 *@param mediaType EC_CONF_MEDIATYPE value
 *@return YES or NO
 */
-(BOOL)tupConfctrlBookConf:(NSArray *)attendeeArray mediaType:(EC_CONF_MEDIATYPE)mediaType startTime:(NSDate *)startTime confLen:(int)confLen chairmanPassword:(NSString *)chairmanPassword guestPassword:(NSString *)guestPassword subject:(NSString *)subject timezoneModel:(TimezoneModel *)timezoneModel personalConfId:(NSString *)personalConfId {
    
    TSDK_S_BOOK_CONF_INFO *bookConfInfoUportal = (TSDK_S_BOOK_CONF_INFO *)malloc(sizeof(TSDK_S_BOOK_CONF_INFO));
    memset_s(bookConfInfoUportal, sizeof(TSDK_S_BOOK_CONF_INFO), 0, sizeof(TSDK_S_BOOK_CONF_INFO));
    if (subject.length > 0 && subject != nil) {
        strcpy_s(bookConfInfoUportal->subject, sizeof(bookConfInfoUportal->subject), [subject UTF8String]);
    }
    if (startTime != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *startTimeStr = [dateFormatter stringFromDate:startTime];
        DDLogInfo(@"预约会议开始时间 : %@",startTimeStr);
//        NSString *startTimeStr = [self beginTimeStringFormat:startTime isNeedSec:NO];
        strcpy_s(bookConfInfoUportal->start_time, sizeof(bookConfInfoUportal->start_time), [startTimeStr UTF8String]);
        bookConfInfoUportal->duration = confLen;
        bookConfInfoUportal->conf_type = TSDK_E_CONF_RESERVED;
    } else {
        // 立即/延时会议
        bookConfInfoUportal->conf_type = TSDK_E_CONF_INSTANT;
        bookConfInfoUportal->duration = 120 ;
    }
    bookConfInfoUportal->conf_media_type = (TSDK_E_CONF_MEDIA_TYPE)mediaType;
    bookConfInfoUportal->welcome_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->enter_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->leave_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->reminder = TSDK_E_CONF_REMINDER_NONE;
    
    // MARK: - 3.0环境
    if ([ManagerService callService].isSMC3) {
        /*点击添加与会人,与会人信息区分会议室和普通用户,如果是会议室,participantList,participantNum必传*/
        if (timezoneModel.timeZoneId) {
            bookConfInfoUportal->timeZoneId = (TSDK_INT32)timezoneModel.timeZoneId.integerValue;
            bookConfInfoUportal->timeOffSet = (TSDK_INT32)timezoneModel.offset;
        } else {
            bookConfInfoUportal->timeOffSet = 28800000;
            bookConfInfoUportal->timeZoneId = 58;
        }
        /*
//        NSMutableArray *participantArray = [NSMutableArray array];
//        NSMutableArray *attendeeListArray = [NSMutableArray array];
//        [attendeeArray enumerateObjectsUsingBlock:^(LdapContactInfo *info, NSUInteger idx, BOOL * _Nonnull stop) {
//            [participantArray addObject:info];
//            if ([info.attendeeType isEqualToString:@"1"]) {// 会议室
//                [participantArray addObject:info];
//            } else if ([info.attendeeType isEqualToString:@"5"]) {// 普通人
//                [attendeeListArray addObject:info];
//            }
//        }];
//        if (attendeeListArray.count > 0) {
//            bookConfInfoUportal->attendee_num = (TSDK_UINT32)attendeeListArray.count;
//            bookConfInfoUportal->attendee_list = [self returnAttendeeWithArray:attendeeListArray];
//        }else {
//            bookConfInfoUportal->attendee_num = 0;
//            bookConfInfoUportal->attendee_list = NULL;
//        }
        */
        if (attendeeArray.count > 0) {
            bookConfInfoUportal->participantNum = (TSDK_UINT32)attendeeArray.count;
            bookConfInfoUportal->participantList = [self participantrWithArray:attendeeArray];
        } else {
            bookConfInfoUportal->participantNum = 0;
            bookConfInfoUportal->participantList = NULL;
        }
        if (![personalConfId isEqualToString:@""] && personalConfId.length > 0) {
            strcpy_s(bookConfInfoUportal->vmrNumber, sizeof(bookConfInfoUportal->vmrNumber), [personalConfId UTF8String]);
        }
        bookConfInfoUportal->subjectLen = MAX_CONF_NAME_ATTENDEE_LENGTH;
        if (guestPassword.length > 0 && ![guestPassword isEqualToString: @""]) {
            strcpy_s(bookConfInfoUportal->conf_password, sizeof(bookConfInfoUportal->conf_password), [guestPassword UTF8String]);
            bookConfInfoUportal->confPasswordLen = (TSDK_INT32)guestPassword.length;
        } else {
            strcpy_s(bookConfInfoUportal->conf_password, sizeof(bookConfInfoUportal->conf_password), NULL);
        }
        if (chairmanPassword.length > 0 && [chairmanPassword isEqualToString: @""]) {
            strcpy_s(bookConfInfoUportal->chairmanPwd, sizeof(bookConfInfoUportal->chairmanPwd), [chairmanPassword UTF8String]);
            bookConfInfoUportal->chairmanPwdLen = (TSDK_INT32)chairmanPassword.length;
        } else {
            NSString *chairmanPwd = [self generateTradeNO];
            strcpy_s(bookConfInfoUportal->chairmanPwd, sizeof(bookConfInfoUportal->chairmanPwd), chairmanPwd.UTF8String);
            bookConfInfoUportal->chairmanPwdLen = (TSDK_INT32)chairmanPwd.length;
        }
        if (mediaType == CONF_MEDIATYPE_VOICE) {
            bookConfInfoUportal->confMediaTypeV3 = TSDK_E_CONFERENCETYPE_AUDIO;
        } else if (mediaType == CONF_MEDIATYPE_VIDEO) {
            bookConfInfoUportal->confMediaTypeV3 = TSDK_E_CONFERENCETYPE_VIDEO;
        }
        bookConfInfoUportal->conf_encrypt_mode =  TSDK_E_CONF_MEDIA_ENCRYPT_AUTO;
        bookConfInfoUportal->is_hd_conf = TSDK_E_OPEN ;
        bookConfInfoUportal->record_mode = TSDK_E_CONF_RECORD_DISABLE ;
    } else {
        // 2.0预约会议没有密码
//        if (guestPassword.length > 0 && guestPassword != nil) {
//            strcpy_s(bookConfInfoUportal->conf_password, sizeof(bookConfInfoUportal->conf_password), [guestPassword UTF8String]);
//        }
        if (attendeeArray.count == 0) {
            bookConfInfoUportal->attendee_num = 0;
            bookConfInfoUportal->attendee_list = NULL;
        } else {
            bookConfInfoUportal->attendee_num = (TSDK_UINT32)attendeeArray.count;
            bookConfInfoUportal->attendee_list = [self returnAttendeeWithArray:attendeeArray];
        }
    }
    bookConfInfoUportal->is_has_aux_video = TSDK_E_OPEN ; //这个参数跟安卓不一样
    // 默认语音提示播报为英文，如需中文播报，此字段赋值TSDK_E_CONF_LANGUAGE_ZH_CN即可。
//    bookConfInfoUportal->language = TSDK_E_CONF_LANGUAGE_ZH_CN;
     
    TSDK_RESULT ret = tsdk_book_conference(bookConfInfoUportal);
    DDLogInfo(@"tsdk_book_conference result : %d",ret);
    // 释放数据
    if (bookConfInfoUportal->attendee_list != NULL) {
        free(bookConfInfoUportal->attendee_list);
    }
    if (bookConfInfoUportal->participantList != NULL) {
        free(bookConfInfoUportal->participantList);
    }
    free(bookConfInfoUportal);
    return ret == TSDK_SUCCESS ? YES : NO;
} 
/*
 3.0 创建VMR会议
 */
-  (BOOL)createVMRConferenceWithAttendee:(NSArray *)attendeeArray mediaType:(EC_CONF_MEDIATYPE)mediaType subject:(NSString *)subject confId:(NSString *)confId chairPwd:(NSString *)chairPwd generalPwd:(NSString *)generalPwd {
    TSDK_S_BOOK_CONF_INFO *bookConfInfoUportal = (TSDK_S_BOOK_CONF_INFO *)malloc(sizeof(TSDK_S_BOOK_CONF_INFO));
    memset_s(bookConfInfoUportal, sizeof(TSDK_S_BOOK_CONF_INFO), 0, sizeof(TSDK_S_BOOK_CONF_INFO));
    if (subject.length > 0 && subject != nil) {
        strcpy_s(bookConfInfoUportal->subject, sizeof(bookConfInfoUportal->subject), [subject UTF8String]);
    }
    // 立即/延时会议
    bookConfInfoUportal->conf_type = TSDK_E_CONF_INSTANT;
    bookConfInfoUportal->duration = 120 ;
     
    if (attendeeArray.count == 0) {
        bookConfInfoUportal->attendee_num = 0;
        bookConfInfoUportal->attendee_list = NULL;
    } else {
        bookConfInfoUportal->attendee_num = (TSDK_UINT32)attendeeArray.count;
        bookConfInfoUportal->attendee_list = [self returnAttendeeWithArray:attendeeArray];
    }
    bookConfInfoUportal->conf_media_type = (TSDK_E_CONF_MEDIA_TYPE)mediaType;
    bookConfInfoUportal->welcome_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->enter_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->leave_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->reminder = TSDK_E_CONF_REMINDER_NONE;
    
    bookConfInfoUportal->timeOffSet = 28800000;
    bookConfInfoUportal->timeZoneId = 58;
    if (attendeeArray.count > 0) {
        bookConfInfoUportal->participantNum = (TSDK_UINT32)attendeeArray.count;
        bookConfInfoUportal->participantList = [self participantrWithArray:attendeeArray];
    }else {
        bookConfInfoUportal->participantNum = 0;
        bookConfInfoUportal->participantList = NULL;
    }
    bookConfInfoUportal->subjectLen = MAX_CONF_NAME_ATTENDEE_LENGTH;
    if (mediaType == CONF_MEDIATYPE_VOICE) {
        bookConfInfoUportal->confMediaTypeV3 = TSDK_E_CONFERENCETYPE_AUDIO;
    } else if (mediaType == CONF_MEDIATYPE_VIDEO) {
        bookConfInfoUportal->confMediaTypeV3 = TSDK_E_CONFERENCETYPE_VIDEO;
    }
    bookConfInfoUportal->conf_encrypt_mode =  TSDK_E_CONF_MEDIA_ENCRYPT_AUTO;
    bookConfInfoUportal->is_has_aux_video = TSDK_E_OPEN ; //这个参数跟安卓不一样
    bookConfInfoUportal->is_hd_conf = TSDK_E_OPEN ;
    bookConfInfoUportal->record_mode = TSDK_E_CONF_RECORD_DISABLE ;
    // 默认语音提示播报为英文，如需中文播报，此字段赋值TSDK_E_CONF_LANGUAGE_ZH_CN即可。
    bookConfInfoUportal->language = TSDK_E_CONF_LANGUAGE_ZH_CN;
    strcpy_s(bookConfInfoUportal->chairmanPwd, sizeof(bookConfInfoUportal->chairmanPwd), [chairPwd UTF8String]);
    bookConfInfoUportal->chairmanPwdLen = (TSDK_INT32)chairPwd.length;
    strcpy_s(bookConfInfoUportal->vmrNumber, sizeof(bookConfInfoUportal->vmrNumber), [confId UTF8String]);
    if (generalPwd.length > 0 && generalPwd != nil) {
        strcpy_s(bookConfInfoUportal->conf_password, sizeof(bookConfInfoUportal->conf_password), [generalPwd UTF8String]);
        bookConfInfoUportal->confPasswordLen = (TSDK_INT32)generalPwd.length;
    }
    TSDK_RESULT ret = tsdk_book_conference(bookConfInfoUportal);
    DDLogInfo(@"tsdk_book_conference result : %d",ret);
    // 释放数据
    if (bookConfInfoUportal->attendee_list != NULL) {
        free(bookConfInfoUportal->attendee_list);
    }
    if (bookConfInfoUportal->participantList != NULL) {
        free(bookConfInfoUportal->participantList);
    }
    free(bookConfInfoUportal);
    return ret == TSDK_SUCCESS ? YES : NO;
}
/*
   2.0 和 3.0 创建普通会议
*/
- (BOOL)creatCommonConferenceWithAttendee:(NSArray *)attendArray mediaType:(EC_CONF_MEDIATYPE)mediaType subject:(NSString *)subject password:(NSString *)password{
    TSDK_S_BOOK_CONF_INFO *bookConfInfoUportal = (TSDK_S_BOOK_CONF_INFO *)malloc(sizeof(TSDK_S_BOOK_CONF_INFO));
    memset_s(bookConfInfoUportal, sizeof(TSDK_S_BOOK_CONF_INFO), 0, sizeof(TSDK_S_BOOK_CONF_INFO));
    if (subject.length > 0 && subject != nil) {
        strcpy_s(bookConfInfoUportal->subject, sizeof(bookConfInfoUportal->subject), [subject UTF8String]);
        bookConfInfoUportal->subjectLen = MAX_CONF_NAME_ATTENDEE_LENGTH;
    }
    // 立即/延时会议
    bookConfInfoUportal->conf_type = TSDK_E_CONF_INSTANT;
    bookConfInfoUportal->duration = 120 ;
    bookConfInfoUportal->conf_media_type = (TSDK_E_CONF_MEDIA_TYPE)mediaType;
    bookConfInfoUportal->welcome_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->enter_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->leave_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->reminder = TSDK_E_CONF_REMINDER_NONE;
    
    // MARK: - 3.0环境
    if ([ManagerService callService].isSMC3) {
        bookConfInfoUportal->timeOffSet = 28800000;
        bookConfInfoUportal->timeZoneId = 58;
        if (attendArray.count > 0) {
            bookConfInfoUportal->participantNum = (TSDK_UINT32)attendArray.count;
            bookConfInfoUportal->participantList = [self participantrWithArray:attendArray];
        } else {
            bookConfInfoUportal->participantNum = 0;
            bookConfInfoUportal->participantList = NULL;
        }

        if (password.length > 0 && password != nil) {
            strcpy_s(bookConfInfoUportal->conf_password, sizeof(bookConfInfoUportal->conf_password), [password UTF8String]);
            bookConfInfoUportal->confPasswordLen = (UInt32)password.length;
        }
        NSString *chairmanPwd = [self generateTradeNO];
        strcpy_s(bookConfInfoUportal->chairmanPwd, sizeof(bookConfInfoUportal->chairmanPwd), [chairmanPwd UTF8String]);
        bookConfInfoUportal->chairmanPwdLen = (TSDK_INT32)chairmanPwd.length;
        if (mediaType == CONF_MEDIATYPE_VOICE) {
            bookConfInfoUportal->confMediaTypeV3 = TSDK_E_CONFERENCETYPE_AUDIO;
        } else if (mediaType == CONF_MEDIATYPE_VIDEO) {
            bookConfInfoUportal->confMediaTypeV3 = TSDK_E_CONFERENCETYPE_VIDEO;
        }
        bookConfInfoUportal->conf_encrypt_mode =  TSDK_E_CONF_MEDIA_ENCRYPT_AUTO;
        bookConfInfoUportal->is_hd_conf = TSDK_E_OPEN ;
        bookConfInfoUportal->record_mode = TSDK_E_CONF_RECORD_DISABLE ;
    } else {
        if (password.length > 0 && password != nil) {
            strcpy_s(bookConfInfoUportal->conf_password, sizeof(bookConfInfoUportal->conf_password), [password UTF8String]);
        }
        if (attendArray.count == 0) {
            bookConfInfoUportal->attendee_num = 0;
            bookConfInfoUportal->attendee_list = NULL;
        } else {
            bookConfInfoUportal->attendee_num = (TSDK_UINT32)attendArray.count;
            bookConfInfoUportal->attendee_list = [self returnAttendeeWithArray:attendArray];
        }
    }
    bookConfInfoUportal->is_has_aux_video = TSDK_E_OPEN ; //这个参数跟安卓不一样
    TSDK_RESULT ret = tsdk_book_conference(bookConfInfoUportal);
    DDLogInfo(@"tsdk_book_conference result is %d",ret);
    
    // 释放数据
    if (bookConfInfoUportal->attendee_list != NULL) {
        free(bookConfInfoUportal->attendee_list);
    }
    if (bookConfInfoUportal->participantList != NULL) {
        free(bookConfInfoUportal->participantList);
    }
    free(bookConfInfoUportal);
    return ret == TSDK_SUCCESS ? YES : NO;
}
#pragma mark 生成随机数
- (NSString *)generateTradeNO {
    static int kNumber = 6;
    NSString *sourceStr = @"0123456789";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

///**
// * This method is used to create conference
// * 创会(无密码)
// *@param attendeeArray one or more attendees
// *@param mediaType EC_CONF_MEDIATYPE value
// *@return YES or NO
// */
//-(BOOL)tupConfctrlBookConf:(NSArray *)attendeeArray mediaType:(EC_CONF_MEDIATYPE)mediaType startTime:(NSDate *)startTime confLen:(int)confLen subject:(NSString *)subject
//{
//    TSDK_S_BOOK_CONF_INFO *bookConfInfoUportal = (TSDK_S_BOOK_CONF_INFO *)malloc(sizeof(TSDK_S_BOOK_CONF_INFO));
//    memset_s(bookConfInfoUportal, sizeof(TSDK_S_BOOK_CONF_INFO), 0, sizeof(TSDK_S_BOOK_CONF_INFO));
//    if (subject.length > 0 && subject != nil) {
//        strcpy(bookConfInfoUportal->subject, [subject UTF8String]);
//    }
//    bookConfInfoUportal->conf_type = TSDK_E_CONF_INSTANT;
//    if (startTime != nil)
//    {
////        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
////        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//        NSString *startTimeStr = [self beginTimeStringFormat:startTime isNeedSec:NO];
////        NSString *utcStr = [self getUTCFormateLocalDate:startTimeStr];
////        DDLogInfo(@"start time : %@, utc time: %@",startTimeStr,utcStr);
//        strcpy(bookConfInfoUportal->start_time, [startTimeStr UTF8String]);
//
//        bookConfInfoUportal->duration = confLen;
//
//        bookConfInfoUportal->conf_type = TSDK_E_CONF_RESERVED;
//    }
//    if (attendeeArray.count == 0)
//    {
//        bookConfInfoUportal->size = 5;
//        bookConfInfoUportal->attendee_num = 0;
//        bookConfInfoUportal->attendee_list = NULL;
//    }
//    else
//    {
//        bookConfInfoUportal->size = (TSDK_UINT32)attendeeArray.count;
//        bookConfInfoUportal->attendee_num = (TSDK_UINT32)attendeeArray.count;
//        bookConfInfoUportal->attendee_list = [self returnAttendeeWithArray:attendeeArray];
//    }
//
//    bookConfInfoUportal->conf_media_type = (TSDK_E_CONF_MEDIA_TYPE)mediaType;
//    bookConfInfoUportal->is_hd_conf = TSDK_TRUE;
//    bookConfInfoUportal->is_multi_stream_conf = TSDK_TRUE;
//    bookConfInfoUportal->is_auto_record = TSDK_FALSE;
//    bookConfInfoUportal->is_auto_prolong = TSDK_TRUE;
//    bookConfInfoUportal->is_auto_mute = TSDK_FALSE;
//    bookConfInfoUportal->welcome_prompt = TSDK_E_CONF_WARNING_DEFAULT;
//    bookConfInfoUportal->enter_prompt = TSDK_E_CONF_WARNING_DEFAULT;
//    bookConfInfoUportal->leave_prompt = TSDK_E_CONF_WARNING_DEFAULT;
//    bookConfInfoUportal->reminder = TSDK_E_CONF_REMINDER_NONE;
//
//    // 默认语音提示播报为英文，如需中文播报，此字段赋值TSDK_E_CONF_LANGUAGE_ZH_CN即可。
//    bookConfInfoUportal->language = TSDK_E_CONF_LANGUAGE_ZH_CN;
//
//    TSDK_RESULT ret = tsdk_book_conference(bookConfInfoUportal);
//    DDLogInfo(@"tsdk_book_conference result : %d",ret);
//    free(bookConfInfoUportal);
//    return ret == TSDK_SUCCESS ? YES : NO;
//}

- (NSString *)beginTimeStringFormat:(NSDate *)beginTime isNeedSec:(BOOL)isNeedSec
{
    if (nil == beginTime) {
        DDLogInfo(@"beginTimeStringFormat: nil beginTime");
        return nil;
    }
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags =     NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitWeekday |
    NSCalendarUnitHour |
    NSCalendarUnitMinute;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:beginTime];
    //comps = [calendar components:unitFlags fromDate:beginTime];
    
    //    int week = [comps weekday];
    NSInteger year =[comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger min = [comps minute];
    if (isNeedSec) {
        return [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:00", (long)year+1, (long)month,(long)day, (long)hour,(long)min];
    }
    NSString *beginTimeDateString = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld", (long)year, (long)month,(long)day, (long)hour,(long)min];
    return beginTimeDateString;
}

/**
 * This method is used to get conference list
 * 获取会议列表
 *@param pageIndex pageIndex default 1
 *@param pageSize pageSize default 10
 *@return YES or NO
 */
-(BOOL)obtainConferenceListWithPageIndex:(int)pageIndex pageSize:(int)pageSize
{
    TSDK_S_QUERY_CONF_LIST_REQ conflistInfo;
	memset_s(&conflistInfo, sizeof(TSDK_S_QUERY_CONF_LIST_REQ), 0, sizeof(TSDK_S_QUERY_CONF_LIST_REQ));
    conflistInfo.pageIndex = pageIndex;
    conflistInfo.pageSize = pageSize;
    if (![ManagerService callService].isSMC3) {
        strcpy_s(conflistInfo.queryEndTime,sizeof(conflistInfo.queryEndTime), "2037-12-31 23:59:59");
    }
    int result = tsdk_query_conference_list(&conflistInfo);
    DDLogInfo(@"tsdk_query_conference_list result is %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}


///< 获取当前时间的: 前一周(day:-7)丶前一个月(month:-30)丶前一年(year:-1)的时间戳
- (NSString *)ddpGetExpectTimestamp:(NSInteger)year {
    
    ///< 当前时间
    NSDate *currentdata = [NSDate date];
    
    ///< NSCalendar -- 日历类，它提供了大部分的日期计算接口，并且允许您在NSDate和NSDateComponents之间转换
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *datecomps = [[NSDateComponents alloc] init];
    [datecomps setYear:year?:0];
    
    ///< dateByAddingComponents: 在参数date基础上，增加一个NSDateComponents类型的时间增量
    NSDate *calculatedate = [calendar dateByAddingComponents:datecomps toDate:currentdata options:0];
    
    ///< 打印推算时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *calculateStr = [formatter stringFromDate:calculatedate];
    
    return calculateStr;
}

/**
* @ingroup ConfCtrl
* @brief [en]This interface is used to Requested VMR list.
*            [cn]请求vmr列表
*
* @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
*                                              [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] corresponding callback event is TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT.
*                   [cn] 对应的回调事件为TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT
* @see TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT
**/
-(BOOL)getVmrList{
    int result = tsdk_get_vmr_list();
    DDLogInfo(@"tsdk_get_vmr_list result is %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}
/*
 更新vmr 数据
 *@param chairStr 主席密码
 *@param generalStr 来宾密码
 *@param confId  会议id
 *@return YES or NO
 */
- (BOOL)updateVmrList:(NSString *)chairStr generalStr:(NSString *)generalStr confId:(NSString *)confId{ 
    TSDK_S_VMR_INFO vmrinfo;
    memset_s(&vmrinfo, sizeof(TSDK_S_VMR_INFO), 0, sizeof(TSDK_S_VMR_INFO));
    strcpy_s(vmrinfo.conf_id, sizeof(vmrinfo.conf_id), [confId UTF8String]);
    strcpy_s(vmrinfo.chairman_pwd, sizeof(vmrinfo.chairman_pwd), [chairStr UTF8String]);
    strcpy_s(vmrinfo.guest_pwd, sizeof(vmrinfo.guest_pwd), [generalStr UTF8String]);
    int result = tsdk_update_vmr_info(&vmrinfo);
    return result == TSDK_SUCCESS ? YES : NO ;
}
/**
 * This method is used to join conference
 * 加入会议
 *@return YES or NO
 */
-(BOOL)joinConferenceWithConfId:(NSString *)confId AccessNumber:(NSString *)accessNumber confPassWord:(NSString *)confPassWord joinNumber:(NSString *)joinNumber isVideoJoin:(BOOL)isVideoJoin
{
    TSDK_S_CONF_JOIN_PARAM confJoinParam;
    // DIFF:
    memset_s(&confJoinParam, sizeof(TSDK_S_CONF_JOIN_PARAM), 0, sizeof(TSDK_S_CONF_JOIN_PARAM));
    if (confPassWord.length > 0 && confPassWord != nil) {
        strcpy_s(confJoinParam.conf_password, sizeof(confJoinParam.conf_password), [confPassWord UTF8String]);
    }
    if (accessNumber.length > 0 && accessNumber != nil) {
        strcpy_s(confJoinParam.access_number, sizeof(confJoinParam.access_number), [accessNumber UTF8String]);
    }
    TSDK_CHAR join_number[JOIN_NUMBER_LEN];
    
    NSArray *array = [joinNumber componentsSeparatedByString:@"\\"];
    NSString *realNumber = array[0];
    if (array.count > 1) {
        realNumber = array[1];
    }
    if (!realNumber || realNumber.length == 0) {
        if (!self.selfJoinNumber) {
            self.selfJoinNumber = self.sipAccount;
        }
        realNumber = self.selfJoinNumber;
    }
    strcpy_s(join_number,sizeof(join_number), [realNumber UTF8String]);
    
    TSDK_UINT32 call_id;
    DDLogInfo(@"access_number:%@", [NSString encryptNumberWithString:[NSString stringWithFormat:@"%s", confJoinParam.access_number]]);
    BOOL result = tsdk_join_conference(&confJoinParam, join_number, (TSDK_BOOL)isVideoJoin, &call_id);
    if (result != TSDK_SUCCESS) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JOINCONFFAIL" object:nil];
    }
    DDLogInfo(@"tsdk_join_conference = %d, call_id is :%@",result,[NSString encryptNumberWithString:@(call_id).stringValue]);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to leave conference
 * 离开会议
 *@return YES or NO
 */
-(BOOL)confCtrlLeaveConference
{
    int result = tsdk_leave_conference(_confHandle);
    DDLogInfo(@"tsdk_leave_conference = %d, _confHandle is :%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to end conference (chairman)
 * 结束会议
 *@return YES or NO
 */
-(BOOL)confCtrlEndConference
{
    int result = tsdk_end_conference(_confHandle);
    DDLogInfo(@"tsdk_end_conference = %d, _confHandle is :%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}


/**
 * This method is used to mute conference (chairman)
 * 主席闭音会场
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteConference:(BOOL)isMute
{
    TSDK_BOOL tupBool = isMute ? TSDK_TRUE : TSDK_FALSE;
    int result = tsdk_mute_conference(_confHandle, tupBool);
    DDLogInfo(@"tsdk_mute_conference = %d, _confHandle is :%d, isMute:%d",result,_confHandle,isMute);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to add attendee to conference
 * 添加与会者到会议中
 @param attendeeArray attendees
 @return YES or NO
 */
-(BOOL)confCtrlAddAttendeeToConfercene:(NSArray *)attendeeArray
{
    if (0 == attendeeArray.count)
    {
        return NO;
    }
    TSDK_S_ADD_ATTENDEES_INFO *attendeeInfo = (TSDK_S_ADD_ATTENDEES_INFO *)malloc( sizeof(TSDK_S_ADD_ATTENDEES_INFO));
    memset_s(attendeeInfo, sizeof(TSDK_S_ADD_ATTENDEES_INFO), 0, sizeof(TSDK_S_ADD_ATTENDEES_INFO));
    attendeeInfo->attendee_num = (TSDK_UINT32)attendeeArray.count;
    TSDK_S_CONF_ATTENDEE_INFO *attendee = (TSDK_S_CONF_ATTENDEE_INFO *)malloc(attendeeArray.count*sizeof(TSDK_S_CONF_ATTENDEE_INFO));
    memset_s(attendee, attendeeArray.count *sizeof(TSDK_S_CONF_ATTENDEE_INFO), 0, attendeeArray.count *sizeof(TSDK_S_CONF_ATTENDEE_INFO));

    
    for (int i=0; i<attendeeArray.count; i++)
    {
        ConfAttendee *cAttendee = attendeeArray[i];
        strcpy(attendee[i].displayName, [cAttendee.name UTF8String]);
        strcpy_s(attendee[i].number, sizeof(attendee[i].number), [cAttendee.number UTF8String]);
//        if (cAttendee.email.length != 0)
//        {
//            strcpy_s(attendee[i].email,sizeof(attendee[i].email), [cAttendee.email UTF8String]);
//        }
//        if (cAttendee.sms.length != 0)
//        {
//            strcpy_s(attendee[i].sms, sizeof(attendee[i].sms), [cAttendee.sms UTF8String]);
//        }
//        if (cAttendee.account.length != 0) {
//            strcpy_s(attendee[i].account_id, sizeof(attendee[i].account_id), [cAttendee.account UTF8String]);
//        }
//        attendee[i].role = (TSDK_E_CONF_ROLE)cAttendee.role;
//        strcat(attendee[i].account_id, [@"ios173" UTF8String]);
//        DDLogInfo(@"cAttendee number is %@,cAttendee role is %lu,attendee[i].role is : %d",cAttendee.number,(unsigned long)cAttendee.role,attendee[i].role);
    }
    attendeeInfo->attendee_list = attendee;
    int result = tsdk_add_attendee(_confHandle, attendeeInfo);
    DDLogInfo(@"tsdk_add_attendee = %d, _confHandle:%d",result,_confHandle);
    free(attendee);
    free(attendeeInfo);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to remove attendee
 *  重播与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRecallAttendee:(NSString *)attendeeNumber
{
    int result = tsdk_redial_attendee(_confHandle, (TSDK_CHAR*)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_redial_attendee result is %d, _confHandle:%d, attendeeNumber:%@",result,_confHandle,[NSString encryptNumberWithString:attendeeNumber]);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to remove attendee
 * 移除与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRemoveAttendee:(NSString *)attendeeNumber
{
    int result = tsdk_remove_attendee(_confHandle, (TSDK_CHAR*)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_remove_attendee result is %d, _confHandle:%d, attendeeNumber:%@",result,_confHandle,[NSString encryptNumberWithString:attendeeNumber]);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to hang up attendee
 * 挂断与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlHangUpAttendee:(NSString *)attendeeNumber
{
    int result = tsdk_hang_up_attendee(_confHandle, (TSDK_CHAR*)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_hang_up_attendee result is %d, _confHandle:%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to mute attendee (chairman)
 * 主席闭音与会者
 *@param attendeeNumber attendee number
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteAttendee:(NSString *)attendeeNumber isMute:(BOOL)isMute
{
    TSDK_BOOL tupBool = isMute ? 1 : 0;
    int result = tsdk_mute_attendee(_confHandle, (TSDK_CHAR *)[attendeeNumber UTF8String], tupBool);
    DDLogInfo(@"tsdk_mute_attendee result is %d, _confHandle is :%d, isMute:%d, attendee is :%@",result,_confHandle,isMute,[NSString encryptNumberWithString:attendeeNumber]);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to raise hand (Attendee)
 * 与会者举手
 *@param raise YES raise hand, NO cancel raise
 *@param attendeeNumber join conference number
 *@return YES or NO
 */
- (BOOL)confCtrlRaiseHand:(BOOL)raise attendeeNumber:(NSString *)attendeeNumber
{
    TSDK_BOOL tupBool = raise ? TSDK_TRUE : TSDK_FALSE;
    int result = tsdk_set_handup(_confHandle, tupBool, (TSDK_CHAR *)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_set_handup result is %d, attendee is :%@",result,[NSString encryptNumberWithString:attendeeNumber]);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to request chairman right (Attendee)
 * 申请主席权限
 *@param chairPwd chairman password
 *@param newChairNumber attendee's number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlRequestChairman:(NSString *)chairPwd number:(NSString *)newChairNumber
{
    if (newChairNumber.length == 0) {
        return NO;
    }
    TSDK_RESULT ret_request_chairman = tsdk_request_chairman(_confHandle, (TSDK_CHAR *)[chairPwd UTF8String]);
    DDLogInfo(@"tsdk_request_chairman ret: %d", ret_request_chairman);
    return (TSDK_SUCCESS == ret_request_chairman);
}

/**
 * This method is used to release chairman right (chairman)
 * 释放主席权限
 *@param chairNumber chairman number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlReleaseChairman:(NSString *)chairNumber
{
    if (chairNumber.length == 0) {
        return NO;
    }
    TSDK_RESULT ret_release_chairman = tsdk_release_chairman(_confHandle);
    DDLogInfo(@"ret_release_chairman ret: %d", ret_release_chairman);
    return ret_release_chairman == TSDK_SUCCESS;
}

/**
 * This interface is used to postpone conference.
 * 延长会议
 *@param time Indicates postpone time, the unit is minute.
 *@return YES or NO
 **/
-(BOOL)PostponeConferenceTime:(NSString *)time{
    TSDK_RESULT result = tsdk_postpone_conference(_confHandle, [time integerValue]);
    DDLogInfo(@"tsdk_postpone_conference ret: %d", result);
    return result == TSDK_SUCCESS;
}

/**
 * This method is used to watch attendee
 * 选看与会者
 */
-(void)watchAttendeeNumber:(NSString *)attendeeNumber
{
    TSDK_S_WATCH_ATTENDEES_INFO *attendeeInfo = (TSDK_S_WATCH_ATTENDEES_INFO *)malloc(sizeof(TSDK_S_WATCH_ATTENDEES_INFO));
    memset_s(attendeeInfo, sizeof(TSDK_S_WATCH_ATTENDEES_INFO), 0, sizeof(TSDK_S_WATCH_ATTENDEES_INFO));
    if (attendeeNumber.length == 0 && attendeeNumber == nil) {
        attendeeInfo->watch_attendee_num = 0;
        TSDK_RESULT ret_watch_attendee = tsdk_watch_attendee(_confHandle, attendeeInfo);
        DDLogInfo(@"ret_watch_attendee: %d", ret_watch_attendee);
        free(attendeeInfo);
        return;
    }

    attendeeInfo->watch_attendee_num = [attendeeNumber isEqual:@""] ? 0 : 1;
    TSDK_S_WATCH_ATTENDEES *attendeeList = (TSDK_S_WATCH_ATTENDEES *)malloc(sizeof(TSDK_S_WATCH_ATTENDEES));
    memset_s(attendeeList, sizeof(TSDK_S_WATCH_ATTENDEES), 0, sizeof(TSDK_S_WATCH_ATTENDEES));
    strcpy_s(attendeeList[0].number,sizeof(attendeeList[0].number), [attendeeNumber UTF8String]);

    attendeeInfo->watch_attendee_list = attendeeList;

    TSDK_RESULT ret_watch_attendee = tsdk_watch_attendee(_confHandle, attendeeInfo);
    free(attendeeInfo);
    free(attendeeList);
    DDLogInfo(@"ret_watch_attendee: %d", ret_watch_attendee);
}

/**
 * This method is used to svc watch attendee
 * SVC选看与会者
 */
-(void)svcWatchAttendeeArray:(NSArray *)attendeeArray isBigPicture:(BOOL)isBigPicture bandWidth:(UInt32)bandWidth isH265SVC:(BOOL)isH265Svc watchComplete:(void(^)(BOOL, NSString*, NSArray<ConfAttendeeInConf*>*))watchBlock complete:(void(^)(BOOL, NSString*, NSArray<ConfAttendeeInConf*>*, NSDictionary*))block {
    self.svcWatchListInd = block;
    TSDK_S_WATCH_SVC_ATTENDEES_INFO *watch_attendee_info = (TSDK_S_WATCH_SVC_ATTENDEES_INFO *)malloc(sizeof(TSDK_S_WATCH_SVC_ATTENDEES_INFO));
    memset_s(watch_attendee_info, sizeof(TSDK_S_WATCH_SVC_ATTENDEES_INFO), 0, sizeof(TSDK_S_WATCH_SVC_ATTENDEES_INFO));
    watch_attendee_info->count = (TSDK_UINT32)attendeeArray.count;
    for (int i = 0; i< attendeeArray.count; i++) {
        ConfAttendeeInConf *attend = attendeeArray[i];
        NSString *number = [NSString stringWithFormat:@"%@", [attend.number componentsSeparatedByString:@"@"][0]];
        if (number.length > 0 && number != nil) {
            strcpy_s(watch_attendee_info->attendees_info[i].number,sizeof(watch_attendee_info->attendees_info[i].number), [number UTF8String]);
        }
        watch_attendee_info->attendees_info[i].lable_id = attend.lable_id;
        if (isBigPicture || attendeeArray.count == 1) { // 当前是画中画,或者只有一个远端画面
            if (bandWidth > 1536) { // 会场带宽大于1.5M 使用720P画质
                watch_attendee_info->attendees_info[i].width = RESOLUTION_720P_WIDTH.floatValue;
                watch_attendee_info->attendees_info[i].height = RESOLUTION_720P_HEIGHT.floatValue;
            }else { // 会场带宽小于等于1.5M 使用360P画质
                watch_attendee_info->attendees_info[i].width = RESOLUTION_360P_WIDTH.floatValue;
                watch_attendee_info->attendees_info[i].height = RESOLUTION_360P_HEIGHT.floatValue;
            }
        }else{ // 当前是画廊模式
            if (bandWidth > 1536) { // 会场带宽大于1.5M 使用360P画质
                watch_attendee_info->attendees_info[i].width = RESOLUTION_360P_WIDTH.floatValue;
                watch_attendee_info->attendees_info[i].height = RESOLUTION_360P_HEIGHT.floatValue;
            }else { // 会场带宽小于等于1.5M
                if (!isH265Svc && bandWidth <= 512) { // H264SVC会议，带宽小于512KB，使用90P
                    watch_attendee_info->attendees_info[i].width = RESOLUTION_90P_WIDTH.floatValue;
                    watch_attendee_info->attendees_info[i].height = RESOLUTION_90P_HEIGHT.floatValue;
                }else { // H265SVC使用180P 或 H264SVC并且带宽大于512KB使用180P
                    watch_attendee_info->attendees_info[i].width = RESOLUTION_180P_WIDTH.floatValue;
                    watch_attendee_info->attendees_info[i].height = RESOLUTION_180P_HEIGHT.floatValue;
                }
            }
        }
    }
    TSDK_UINT32 ret_watch_attendee = tsdk_watch_svc_attendee(_confHandle, watch_attendee_info);
    BOOL result = ret_watch_attendee == TSDK_SUCCESS;
    DDLogInfo(@"tsdk_watch_svc_attendee ret: %d   %@", ret_watch_attendee,result==1 ? @"svc watch true" : @"svc watch fail");
    watchBlock(result,[NSString stringWithFormat:@"%d",ret_watch_attendee],attendeeArray);
    free(watch_attendee_info);
}



/**
*  会场切换单双向
*@param isOneWay 是否单向
*@return YES or NO
*/
-(BOOL)confCtrlSwitchAuditSitesDir:(BOOL)isOneWay
{
    int result = tsdk_confctrl_switch_audit_sites_dir(_confHandle, (TSDK_INT8)isOneWay);
    DDLogInfo(@"tsdk_confctrl_switch_audit_sites_dir result is %d, _confHandle:%d, isOneWay:%d",result,_confHandle,isOneWay);
    return result == TSDK_SUCCESS ? YES : NO;
}

- (BOOL)confctrlGetTimeZoneList {
    int result = tsdk_confctrl_get_time_zone_list([NSString isCNlanguageOC] ? TSDK_E_CONF_LANGUAGE_TYPE_ZH_CN : TSDK_E_CONF_LANGUAGE_TYPE_EN_US );
    return result == TSDK_SUCCESS ? YES : NO;
}




/**
 * This method is used to boardcast attendee
 * 广播与会者
 */
- (void)broadcastAttendee:(NSString *)attendeeNumber isBoardcast:(BOOL)isBoardcast {
    TSDK_RESULT ret_boardcast_attendee = tsdk_broadcast_attendee(_confHandle, (TSDK_CHAR *)[attendeeNumber UTF8String], (isBoardcast ? TSDK_TRUE : TSDK_FALSE));
    DDLogInfo(@"tsdk_broadcast_attendee number: %@, is boardcast: %d ret: %d", [NSString encryptNumberWithString:attendeeNumber], isBoardcast, ret_boardcast_attendee);
}

/**
 * This method is used to create _heartBeatTimer.
 * 创建定时器
 */
-(void)startHeartBeatTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                           target:self
                                                         selector:@selector(heartBeat)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

-(void)receiveSharedData:(NSData*)data{
    if ([data length] > 0 ) {
        [self willChangeValueForKey:@"lastConfSharedData"];
        self.lastConfSharedData = data;
        [self didChangeValueForKey:@"lastConfSharedData"];
    }
    
}
-(void)stopSharedData{
    [self willChangeValueForKey:@"lastConfSharedData"];
    self.lastConfSharedData = nil;
    [self didChangeValueForKey:@"lastConfSharedData"];
}

/**
 * This method is used to stop _heartBeatTimer.
 * 销毁_heartBeatTimer定时器
 */
-(void)stopHeartBeat
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DDLogInfo(@"<INFO>: stopHeartBeat: enter!!! ");
        if ([self.heartBeatTimer isValid])
        {
            DDLogInfo(@"<INFO>: stopHeartBeat");
            [self.heartBeatTimer invalidate];
            self.heartBeatTimer = nil;
        }
    });
    
}






/**
 * This method is used to dealloc conference params
 * 销毁会议参数信息
 */
-(void)restoreConfParamsInitialValue
{
    DDLogInfo(@"restoreConfParamsInitialValue");
    [_confTokenDic removeAllObjects];
    [self.haveJoinAttendeeArray removeAllObjects];
    [self.messageArray removeAllObjects];
    self.isJoinDataConf = NO;
    self.isHaveChair = NO;
    self.isRecvingAux = NO;
    self.isHaveAux = NO;
    _dataConfIdWaitConfInfo = nil;
    _confCtrlUrl = nil;
    self.selfJoinNumber = nil;
    _hasReportMediaxSpeak = NO;
    [self stopHeartBeat];
	[self stopSharedData];
    _currentCallId = 0;
    self.isVideoConfInvited = NO;
    self.currentConfBaseInfo = nil;
}

/**
 * This method is used to judge whether is uportal mediax conf
 * 判断是否为mediax下的会议
 */
- (BOOL)isUportalMediaXConf
{
    //Mediax conference
    return  (CONF_TOPOLOGY_MEDIAX == self.uPortalConfType);
}

/**
 * This method is used to judge whether is uportal smc conf
 * 判断是否为smc下的会议
 */
- (BOOL)isUportalSMCConf
{
    //SMC conference
    return (CONF_TOPOLOGY_SMC == self.uPortalConfType);
}

/**
 * This method is used to judge whether is uportal UC conf
 * 判断是否为uc下的会议
 */
- (BOOL)isUportalUSMConf
{
    //UC conference
    return (CONF_TOPOLOGY_UC == self.uPortalConfType);
}

/**
 * This interface is used to join a conference anonymously.
 * 通过匿名方式加入会议
 *@param disPlayName Indicates display name.
 *@param confID Indicates conference id.
 *@param passWord Indicates conference password.
 *@param serverAdd Indicates the server address.
 *@param random xxxxxxxxxxx
 *@param serverPort Indicates the server port.
 *@param authType Indicates the conference auth type.
 *@return YES or NO
 */
- (BOOL)joinConferenceWithDisPlayName:(NSString *)disPlayName ConfId:(NSString *)confID PassWord:(NSString *)passWord ServerAdd:(NSString *)serverAdd Random:(NSString *)random ServerPort:(int)serverPort AuthType:(int)authType
{ 
    TSDK_S_CONF_ANONYMOUS_JOIN_PARAM anonymousParam;
	memset_s(&anonymousParam, sizeof(TSDK_S_CONF_ANONYMOUS_JOIN_PARAM), 0, sizeof(TSDK_S_CONF_ANONYMOUS_JOIN_PARAM));
     
    anonymousParam.auth_type = TSDK_E_CONF_ANONYMOUS_AUTH_RANDOM;
    //通过链接获取
    strcpy_s(anonymousParam.random, sizeof(anonymousParam.random), [random UTF8String]);
    //用户手动输入
    if (disPlayName != nil) {
        strcpy_s(anonymousParam.display_name, sizeof(anonymousParam.display_name), [disPlayName UTF8String]);
    }
    //链接获取
    strcpy_s(anonymousParam.server_addr,sizeof(anonymousParam.server_addr), [serverAdd UTF8String]);
    //类型固定
    anonymousParam.smcVersion =  TSDK_S_SMC_VERSION_V3 ;
   
    TSDK_RESULT joinConfResult = tsdk_join_conference_by_anonymous(&anonymousParam);
    DDLogInfo(@"tsdk_join_conference_by_anonymous = %d",joinConfResult);
    return joinConfResult == TSDK_SUCCESS ;
}


/**
 * This interface is invoked by the chairman in a conference to set or cancel a common participant speak，dose not support roll call chairman self.
 *  [cn]点名发言或取消点名接口
 不支持点名主席，因为点名主席后，取消点名是广播主席，闭音被点名的与会者，这样主席
 会被闭音，而主席取消点名会闭音主席自己，不符合使用场景，所以在点名接口中限制点名主席
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRollCallAttendee:(NSString *)attendeeNumber
{
//    int result = tsdk_roll_call_attendee(_confHandle, (TSDK_CHAR*)[attendeeNumber UTF8String]);
//    DDLogInfo(@"tsdk_roll_call_attendee = %d, _confHandle:%d, attendeeNumber:%@",result,_confHandle,attendeeNumber);
//    return result == TSDK_SUCCESS ? YES : NO;
    return NO;
}

/**
*  取消预约会议
*@param confId 会议号3.0
*@param completionBlock  result call back
*/
-(void)cancelConferenceConfId:(NSString *)confId
                   completion:(void (^)(BOOL isSuccess, NSError *error))completionBlock
{
    TSDK_RESULT result = tsdk_cancel_conference((TSDK_CHAR *)[confId UTF8String]);
    DDLogInfo(@"tsdk_cancel_conference result is %d",result);
    if (result != TSDK_SUCCESS) {
        completionBlock(NO, [NSError errorWithDomain:@"" code:result userInfo:nil]);
    } else {
        self.cancelConfBackAction = completionBlock;
    }
    
}
/**
*  日志上传---本地日志和sdk日志一起
*@param logPath .zip 日志的绝对路径
*@return  YES  成功
*/
- (BOOL)upLoadLogWithPath:(NSString*)logPath{
//    TSDK_API TSDK_RESULT tsdk_log_upload(IN TSDK_CHAR* logPath);
//    TSDK_CHAR path[JOIN_NUMBER_LEN];
//    strcpy_s(path,sizeof(path), [logPath UTF8String]);

    TSDK_RESULT result =  tsdk_log_upload((TSDK_CHAR*)[logPath UTF8String]);
    DDLogInfo(@"tsdk_log_upload result is %d",result);
    return result == TSDK_SUCCESS ? YES : NO;;
}
@end
