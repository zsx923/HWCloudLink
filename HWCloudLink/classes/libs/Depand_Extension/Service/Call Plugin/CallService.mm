//
//  CallService.mm
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallService.h"
#import "CallInfo+StructParase.h"
#import "CallData.h"
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <dlfcn.h>
#include <sys/sysctl.h>
#import "ManagerService.h"
#include <string.h>
#import <UIKit/UIKit.h>
#import "Initializer.h"
#import "CallSessionModifyInfo.h"
#import "IPTConfig.h"
#import "LoginInfo.h"
#import "CommonUtils.h"
#import "CallLogMessage.h"
#import "ConfBaseInfo.h"
#import "CallStreamInfo.h"
#import "VideoStream.h"
#import "VoiceStream.h"
#import "ConfAttendeeInConf.h"

#import "EAGLView.h"

#import "tsdk_def.h"
#import "tsdk_error_def.h"
#import "tsdk_manager_def.h"
#import "tsdk_manager_interface.h"
#import "tsdk_call_interface.h"
#import "Logger.h"
#import "securec.h"
#import "utility.h"
#import "NSString+CZFTools.h"
#import "NSObject+CZFTools.h"

#define CHECKCSTR(str) (((str) == NULL) ? "" : (str))

#define CALLINFO_CALLNUMBER_KEY @"CALLINFO_CALLNUMBER_KEY"
#define CALLINFO_SIPNUMBER_KEY  @"CALLINFO_SIPNUMBER_KEY"

#define USER_AGENT_UC @"eSpace Mobile"
@interface CallService()<TupCallNotifacation>
{
    int _playHandle;
}

/**
 *Indicates local view
 *本地画面
 */
@property (nonatomic, strong)id localView;

/**
 *Indicates remote view
 *远端画面
 */
@property (nonatomic, strong)id remoteView;

/**
 *Indicates camera index, 1:front camera; 0:back camera
 *摄像头序号， 1为前置摄像头，0为后置摄像头
 */
@property (nonatomic,assign)CameraIndex cameraCaptureIndex;

/**
 *Indicates camera rotation, 0：90 1：180 2：270 3：360
 *摄像头方向，0：90 1：180 2：270 3：360
 */
@property (nonatomic,assign)NSInteger cameraRotation;

/**
 *Indicates video preview
 *视频预览
 */
@property (nonatomic, strong)id videoPreview;

/**
 *Indicates ctd call id
 *点击呼叫的呼叫id
 */
@property (nonatomic, assign)int ctdCallId;

/**
 *Indicates dictionary used to record callInfo,key:callID,value:callInfo
 *用于存储呼叫信息的词典
 */
@property (nonatomic,strong)NSMutableDictionary<NSString* , CallInfo*> *tsdkCallInfoDic;

/**
 *Indicates authorize token
 *鉴权token
 */
@property (nonatomic, copy)NSString *token;

@end

@implementation CallService

//creat getter and setter method of delegate
@synthesize delegate;

//creat getter and setter method of sipAccount
@synthesize sipAccount;

//creat getter and setter method of definition
@synthesize definition;

//creat getter and setter method of isSMC3
@synthesize isSMC3;

//creat getter and setter method of isReferCall
@synthesize isReferCall;

//creat getter and setter method of terminal
@synthesize terminal;

//creat getter and setter method of isShowTupBfcp
@synthesize isShowTupBfcp;

//creat getter and setter method of iptDelegate
@synthesize iptDelegate;

//Indicates current base callInfo
@synthesize currentCallInfo;

//Indicates current  callStreamInfo
@synthesize currentCallStreamInfo;

@synthesize ldapContactInfo;

@synthesize isSession;

@synthesize authType;

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+(instancetype)shareInstance
{
    static CallService *_tupCallService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tupCallService = [[CallService alloc] init];
    });
    return _tupCallService;
}

/**
 *This method is used to init this class
 *初始化该类
 */
-(instancetype)init
{
    if (self = [super init])
    {
        [Initializer registerCallCallBack:self];
        _cameraRotation = 0;
        _cameraCaptureIndex = CameraIndexFront;
        _tsdkCallInfoDic = [NSMutableDictionary dictionary];
        _playHandle = -1;
        self.isShowTupBfcp = NO;
        self.isReferCall = false;
    }
    return self;
}


/**
 * This method is used to get call info with confId
 * 用confid获取呼叫信息
 *@param confId              Indicates conference Id
 *                           会议id
 *@return call Info          Return call info
 *                           返回值为呼叫信息
 *@return YES or NO
 */
- (CallInfo *)callInfoWithConfId:(NSString *)confId
{
    NSArray *array = [_tsdkCallInfoDic allValues];
    for (CallInfo *info in array) {
        if ([info.serverConfId isEqualToString:confId]) {
            return info;
        }
    }
    return nil;
}

/**
 * This method is used to get call info with confId
 * 用call_id获取呼叫信息
 *@param callId              Indicates call Id
 *                           呼叫id
 *@return call Info          Return call info
 *                           返回值为呼叫信息
 *@return YES or NO
 */
- (CallInfo *)callInfoWithcallId:(NSString *)callId
{
    return _tsdkCallInfoDic[callId];
}


/**
 * This method is used to hang up all call.
 * 挂断所有呼叫
 */
- (void)hangupAllCall
{
    NSArray *array = [_tsdkCallInfoDic allValues];
    for (CallInfo *info in array) {
        [self closeCall:info.stateInfo.callId];
    }
}

/**
 * This method is used to config bussiness token
 * 配置业务token
 *@param sipAccount         Indicates sip account
 *                          sip账号
 *@param terminal         Indicates terminal
 *                          terminal号码（长号）
 *@param token              Indicates token
 *                          鉴权token
 */
- (void)configBussinessAccount:(NSString *)sipAccount
                      terminal:(NSString *)terminal
                         token:(NSString *)token
{
    if (token.length > 0 || token != nil) {
        self.token = token;
    }
    if (sipAccount.length > 0 || sipAccount != nil) {
        self.sipAccount = sipAccount;
    }
    if (terminal.length > 0 || terminal != nil) {
        self.terminal = terminal;
    }
}

/**
 * This method is used to deel call event callback from service
 * 分发呼叫业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)callModule:(TUP_MODULE)module notication:(Notification *)notification
{
    if (module == CALL_SIP_MODULE) {
        [self onRecvCallNotification:notification];
    }else if (module == CALL_CTD_MODULE ){ //4001 - 5000
        [self onReceiveUpLoadLogNotification:notification];
    }
}

/**
 *This method is used to deel call notification
 *处理call回调业务
 */
-(void)onRecvCallNotification:(Notification *)notify
{
//    [[CallWindowController shareInstance] setDelegate];
    switch (notify.msgId)
    {
        case TSDK_E_CALL_EVT_CALL_START_RESULT: // 发起呼叫结果
        {
            DDLogInfo(@"recv call notify :CALL_E_EVT_CALL_STARTCALL_RESULT :%d",notify.param2);
            [[ManagerService callService] switchCameraOpen:false callId:notify.param1];
            
//            ManagerService.call()?.switchCameraOpen(false, callId: callInfo.stateInfo.callId)
//            ManagerService.call()?.muteMic(true, callId: UInt32(callInfo.stateInfo.callId))

            break;
        }
        case TSDK_E_CALL_EVT_CALL_INCOMING: // 来电事件
        {
            DDLogInfo(@"recv call notify :TSDK_E_CALL_EVT_CALL_INCOMING callid:%d",notify.param1);
            
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            
            DDLogInfo(@"recv call notify->meeting type:%d",callInfo->is_video_call);
            [self resetUCVideoOrientAndIndexWithCallId:0];
            
            NSString *callId = [NSString stringWithFormat:@"%d", callInfo->call_id];
            [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_INCOMMING result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_COMING_CALL_NOTIFY object:tsdkCallInfo];
            });
            
            CallLogMessage *callLogMessage = [[CallLogMessage alloc]init];
         
            callLogMessage.calleePhoneNumber = tsdkCallInfo.stateInfo.callNum;
            callLogMessage.durationTime = 0;
            callLogMessage.startTime = [self nowTimeString];
            callLogMessage.callLogType = MissedCall;
            callLogMessage.callId = tsdkCallInfo.stateInfo.callId;
            callLogMessage.isConnected = NO;
            if (!tsdkCallInfo.isFocus) {  //write call log message to local file
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if ([self loadLocalCallHistoryData].count > 0) {
                    [array addObjectsFromArray:[self loadLocalCallHistoryData]];
                }
                [array addObject:callLogMessage];
                [self writeToLocalFileWith:array];
            }
            break;
        }
        case TSDK_E_CALL_EVT_CALL_RINGBACK: // 回铃音事件
        {
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_RINGBACK_KEY : [NSNumber numberWithBool:true]
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_RINGBACK result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_CALL_RINGBACK object:resultInfo];
            });
            
            break;
        }
        case TSDK_E_CALL_EVT_CALL_OUTGOING: // 呼出事件
        {
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            NSString *callId = [NSString stringWithFormat:@"%d", tsdkCallInfo.stateInfo.callId];
            DDLogInfo(@"TSDK_E_CALL_EVT_CALL_OUTGOING >> callId:%@", callId);

            
            [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_OUTGOING result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_CALL_OUTGOING object:nil userInfo:resultInfo];
            });
            
            break;
        }
        case TSDK_E_CALL_EVT_CALL_CONNECTED: // 通话已建立
        {
            DDLogInfo(@"Call_Log: recv call notify :CALL_E_EVT_CALL_CONNECTED");
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            NSString *callId = [NSString stringWithFormat:@"%d", tsdkCallInfo.stateInfo.callId];
            
            CallInfo *dirCallInfo = _tsdkCallInfoDic[callId];
            if (dirCallInfo && dirCallInfo.isAudienceConf) {
                tsdkCallInfo.isAudienceConf = dirCallInfo.isAudienceConf;
                tsdkCallInfo.isOneWay = dirCallInfo.isOneWay;
            }
            [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            //获取callinfo的值
            ManagerService.callService.currentCallInfo = tsdkCallInfo;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_CONNECT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName: tsdkCallInfo.isFocus == 1 ? CONF_S_CALL_EVT_CONF_CONNECTED : CALL_S_CALL_EVT_CALL_CONNECTED object:nil userInfo:resultInfo];
            });
            
            
            if ([self loadLocalCallHistoryData].count > 0) {
                NSArray *array = [self loadLocalCallHistoryData];
                for (CallLogMessage *message in array) {
                    if (message.callId == tsdkCallInfo.stateInfo.callId) {
                        if (message.callLogType == MissedCall) {
                            message.callLogType = ReceivedCall;
                        }
                        message.isConnected = YES;
                        [self writeToLocalFileWith:array];
                        break;
                    }
                }
            }
  
            break;
        }
        case TSDK_E_CALL_EVT_CALL_ENDED: // 呼叫结束
        {
            DDLogInfo(@"Call_Log: recv call notify :CALL_E_EVT_CALL_ENDED");
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            DDLogInfo(@"reasonCode = %d", tsdkCallInfo.stateInfo.reasonCode);
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_CLOSE result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_CALL_ENDED object:nil userInfo:resultInfo];
            });
            
            
            NSString *callId = [NSString stringWithFormat:@"%d", tsdkCallInfo.stateInfo.callId];
            [_tsdkCallInfoDic removeObjectForKey:callId];
            
            self.isShowTupBfcp = NO;
            if ([ManagerService confService].currentConfBaseInfo) {
                ConfBaseInfo *currentConfBaseInfo = [ManagerService confService].currentConfBaseInfo;
                if (notify.param1 == currentConfBaseInfo.callId) {
                    [[ManagerService confService] confCtrlLeaveConference];
                    [[ManagerService confService] restoreConfParamsInitialValue];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_QUITE_TO_CONFLISTVIEW object:@"0"];
                    });
                }
            }
            if ([self loadLocalCallHistoryData].count > 0) {
                NSArray *array = [self loadLocalCallHistoryData];
                for (CallLogMessage *message in array) {
                    if (message.callId == tsdkCallInfo.stateInfo.callId) {
                        if (message.callLogType != MissedCall && message.isConnected) {
                            NSDate *date = [NSDate date];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            NSTimeZone *timeZone = [NSTimeZone localTimeZone];
                            [formatter setTimeZone:timeZone];
                            NSTimeInterval timeInterval = [date timeIntervalSinceDate:[formatter dateFromString:message.startTime]];
                            message.durationTime = timeInterval;
                            [self writeToLocalFileWith:array];
                        }
                        break;
                    }
                }
                
            }
            break;
        }
        case TSDK_E_CALL_EVT_CALL_DESTROY: // 呼叫结束后销毁呼叫控制信息
        {
            NSString* callId = [NSString stringWithFormat:@"%d", notify.param1];
            DDLogInfo(@"Call_Log: recv call notify :TSDK_E_CALL_EVT_CALL_DESTROY  call_Id:%@",[NSString encryptNumberWithString:callId]);
            NSDictionary *dstroyDic = [NSDictionary dictionaryWithObjectsAndKeys:callId,CALL_ID, nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_DESTROY result:dstroyDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_CALL_DESTROY object:dstroyDic];
            });
        }
            break;
        case TSDK_E_CALL_EVT_ENDCALL_FAILED: // 结束通话失败
            
            break;
        case TSDK_E_CALL_EVT_REFRESH_VIEW_IND: // 视频view刷新通知
        {
            NSString* callId = [NSString stringWithFormat:@"%d", notify.param1];
            TSDK_S_VIDEO_VIEW_REFRESH *viewRefresh = (TSDK_S_VIDEO_VIEW_REFRESH *)notify.data;
            
            NSDictionary *viewRefreshInd = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 callId,CALL_ID,
                                                 [NSNumber numberWithInt:viewRefresh->event],TSDK_VIEW_REFRESH_KEY,
                                                 nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_VIEW_REFRESH result:viewRefreshInd];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_REFRESH_VIEW_IND
                                                                    object:[NSNumber numberWithUnsignedInteger:notify.param1]
                                                                  userInfo:nil];
            });
            break;
        }
        case TSDK_E_CALL_EVT_OPEN_VIDEO_REQ: // 远端请求打开视频
        {
            NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
            NSDictionary *callUpgradePassiveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    callId,CALL_ID,
                                                    nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_UPGRADE_VIDEO_PASSIVE result:callUpgradePassiveInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_OPEN_VIDEO_REQ object:callUpgradePassiveInfo];
            });
            DDLogInfo(@"Call_Log: call revice CALL_E_EVT_CALL_ADD_VIDEO");
            break;
        }
        case TSDK_E_CALL_EVT_CLOSE_VIDEO_IND: // 关闭视频通知
        {
            NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
            NSDictionary *callDowngradePassiveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      callId,CALL_ID,
                                                      nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_DOWNGRADE_VIDEO_PASSIVE result:callDowngradePassiveInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_CLOSE_VIDEO_IND object:callDowngradePassiveInfo];
            });
            DDLogInfo(@"Call_Log: call CALL_E_EVT_CALL_DEL_VIDEO");
            break;
        }
        case TSDK_E_CALL_EVT_OPEN_VIDEO_IND: // 打开视频通知
        {
            NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
            NSDictionary *callUpgradePassiveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      callId,CALL_ID,
                                                      nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_AGREEE_OPEN_VIDEO result:callUpgradePassiveInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_OPEN_VIDEO_IND object:callUpgradePassiveInfo];
            });
            
            DDLogInfo(@"Call_Log: call CALL_E_EVT_CALL_ADD_VIDEO");
            break;
        }
        case TSDK_E_CALL_EVT_REFUSE_OPEN_VIDEO_IND: // 远端拒绝请求打开视频通知(远端用户拒绝或超时未响应)
        {
            NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
            NSDictionary *callUpgradePassiveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     callId,CALL_ID,
                                                     nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_REFUSE_OPEN_VIDEO result:callUpgradePassiveInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_REFUSE_OPEN_VIDEO_IND object:callUpgradePassiveInfo];
            });
            DDLogInfo(@"Call_Log: call CALL_E_EVT_CALL_DEL_VIDEO");
            break;
        }
        case TSDK_E_CALL_EVT_CALL_ROUTE_CHANGE: // 移动路由变化通知(主要用于iOS)
        {
            DDLogInfo(@"CALL_E_EVT_MOBILE_ROUTE_CHANGE");
            NSString *value = [NSString stringWithFormat:@"%lu",(unsigned long)notify.param2];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_CALL_ROUTE_CHANGE object:nil userInfo:@{AUDIO_ROUTE_KEY : value}];
            });
            break;
        }
        case TSDK_E_CALL_EVT_IPT_SERVICE_INFO:
        {
            TSDK_S_IPT_SERVICE_INFO_SET *serviceInfoSet = (TSDK_S_IPT_SERVICE_INFO_SET *)notify.data;
            IPTConfig *iptConfig = [IPTConfig sharedInstance];
            
            iptConfig.hasDNDRight = serviceInfoSet->dnd.has_right;
            iptConfig.isDNDRegister = serviceInfoSet->dnd.is_enable;
            
            iptConfig.hasCWRight = serviceInfoSet->call_wait.has_right;
            iptConfig.isCWRegister = serviceInfoSet->call_wait.is_enable;
            
            iptConfig.hasCFURight = serviceInfoSet->cfu.has_right;
            iptConfig.isCFURegister = serviceInfoSet->cfu.is_enable;
            iptConfig.cfuNumber = [NSString stringWithUTF8String:serviceInfoSet->cfu.number];
   
            iptConfig.hasCFBRight = serviceInfoSet->cfb.has_right;
            iptConfig.isCFBRegister = serviceInfoSet->cfb.is_enable;
            iptConfig.cfbNumber = [NSString stringWithUTF8String:serviceInfoSet->cfb.number];

            iptConfig.hasCFNARight = serviceInfoSet->cfn.has_right;
            iptConfig.isCFNARegister = serviceInfoSet->cfn.is_enable;
            iptConfig.cfnaNumber = [NSString stringWithUTF8String:serviceInfoSet->cfn.number];
            
            iptConfig.hasCFNRRight = serviceInfoSet->cfo.has_right;
            iptConfig.isCFNRRegister = serviceInfoSet->cfo.is_enable;
            iptConfig.cfnrNumber = [NSString stringWithUTF8String:serviceInfoSet->cfo.number];
            
            NSString *accountId = [CommonUtils getUserDefaultValueWithKey:USER_ACCOUNT];
            NSData *archiveCarPriceData = [NSKeyedArchiver archivedDataWithRootObject:iptConfig requiringSecureCoding:NO error:nil]; //将iptConfig实例序列化，以便保存
            DDLogInfo(@"........%@", [NSString encryptNumberWithString:accountId]);
            if (accountId.length == 0 || accountId == nil) {
                return;
            }
            NSDictionary *dicInfo = @{
                                      @"ACCOUNT" : accountId,
                                      @"IPT" : archiveCarPriceData
                                      };
            NSMutableArray *mutArray;
            NSArray *orginalArray;
            if ([[CommonUtils getUserDefaultValueWithKey:@"iptConfig"] isKindOfClass:[NSArray class]])
            {
                orginalArray= [CommonUtils getUserDefaultValueWithKey:@"iptConfig"];
                mutArray = [NSMutableArray arrayWithArray:orginalArray];
            }
            else
            {
                mutArray = [[NSMutableArray alloc] init];
            }
            if (orginalArray.count > 0)
            {
                for (NSDictionary *tempDic in orginalArray)
                {
                    NSString *account = tempDic[@"ACCOUNT"];
                    DDLogInfo(@",,,,,,,,,%@",[NSString encryptNumberWithString:account]);
                    if ([account isEqualToString:accountId]) //如果该帐号已存在保存的配置，先删除
                    {
                        [mutArray removeObject:tempDic];
                    }
                }
                [mutArray addObject:dicInfo];
            }
            else
            {
                [mutArray addObject:dicInfo];
            }
            [CommonUtils userDefaultSaveValue:[NSArray arrayWithArray:mutArray] forKey:@"iptConfig"];
            break;
            }
            
        case TSDK_E_CALL_EVT_AUX_DATA_RECVING://辅流接收成功
        {
            DDLogInfo(@"CALL_S_CONF_CALL_EVT_DATA_START收到辅流");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_AUX_DATA_RECVING object:nil userInfo:nil];
                [NSUserDefaults.standardUserDefaults setBool:true forKey:@"aux_rec"];
            });
            break;
        }
        case TSDK_E_CALL_EVT_AUX_SENDING://辅流发送成功
        {
            [ManagerService confService].isHaveAux = YES;
            [ManagerService confService].isSendAux = YES;
            [NSUserDefaults.standardUserDefaults setBool:false forKey:@"aux_rec"];
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"CALL_S_CONF_CALL_EVT_DATA_START本端开始共享");
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CONF_CALL_EVT_DATA_START object:nil];
            });
            break;
        }
        case TSDK_E_CALL_EVT_AUX_SHARE_FAILED://辅流共享失败
        {
            TSDK_S_BFCP_START_ERROR *reasonInfo = (TSDK_S_BFCP_START_ERROR *)notify.data;
            DDLogInfo(@"辅流共享失败原因reasonInfo ->bfcpErrorType:%d",reasonInfo ->bfcpErrorType);
            NSString *raasonCode = [NSString stringWithFormat:@"%d", reasonInfo->bfcpErrorType];;
            NSDictionary *reasonDic = @{
            TSDK_AUX_REASONCODE_KEY:raasonCode
            };
            [ManagerService confService].isHaveAux = NO;
            [ManagerService confService].isSendAux = NO;
            [NSUserDefaults.standardUserDefaults setBool:false forKey:@"aux_rec"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_AUX_SHARE_FAILED object:nil userInfo:reasonDic];
            });
            break;
        }
        case TSDK_E_CALL_EVT_AUX_DATA_STOPPED://辅流停止接收
        {
            [ManagerService confService].isRecvingAux = NO;
            [ManagerService confService].isHaveAux = NO;
//            [NSUserDefaults.standardUserDefaults setBool:false forKey:@"aux_rec"];
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_AUX_DATA_STOPPED object:nil];
            });
            DDLogInfo(@"Call_Log: call revice TSDK_E_CALL_EVT_AUX_DATA_STOPPED");
            break;
        }
        
        case TSDK_E_CALL_EVT_DECODE_SUCCESS://解码成功信息通知
        {
            TSDK_S_DECODE_SUCCESS *tsdk_decode_success = (TSDK_S_DECODE_SUCCESS *)notify.data;
            if (tsdk_decode_success->meida_type == TSDK_E_DECODE_SUCCESS_DATA) {
                [ManagerService confService].isHaveAux = YES;
                [ManagerService confService].isRecvingAux = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_DECODE_SUCCESS object:nil];
                });
            }
            DDLogInfo(@"Call_Log: call revice TSDK_E_CALL_EVT_DECODE_SUCCESS");
            break;
        }
        case TSDK_E_CALL_EVT_NO_STREAM_DURATION: //无码流
        {
            NSDictionary *massgeDic = @{CALL_S_CALL_EVT_NO_STREAM_DURATION : [NSString stringWithFormat:@"%d",notify.param2],CALL_ID:[NSNumber numberWithInteger:notify.param1]};
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self respondsCallDelegateWithType:CALL_NO_STREAM_DURATION result:massgeDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_NO_STREAM_DURATION object:nil userInfo:massgeDic];
            });
            break;
        }
        case TSDK_E_CALL_EVT_SESSION_MODIFIED:// 会话修改完成通知
        {
            DDLogInfo(@"Call_Log: recv call notify :TSDK_E_CALL_EVT_SESSION_MODIFIED");
            TSDK_S_SESSION_MODIFIED* session_info = (TSDK_S_SESSION_MODIFIED *)notify.data;
            NSString *callId = [NSString stringWithFormat:@"%d", session_info->call_id];
            CallInfo *tsdkCallInfo = _tsdkCallInfoDic[callId];
            tsdkCallInfo.isSvcCall = session_info->is_svc_call;
            tsdkCallInfo.bandWidth = session_info->bandWidth;
            if (tsdkCallInfo.isSvcCall) {
               tsdkCallInfo.ulSvcSsrcStart = session_info->svc_lable_ssrc[0];
               tsdkCallInfo.ulSvcSsrcEnd = session_info->svc_lable_ssrc[1];
            }
            [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
            
            [ManagerService callService].isSession = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_CALL_MODIFY object:nil userInfo:@{TSDK_CALL_INFO_KEY : tsdkCallInfo}];
            });
            break;
        }
        case TSDK_E_CALL_EVT_AUDIT_DIR:// 观众会场会议方向类型
        {
            NSString *callId = [NSString stringWithFormat:@"%d", notify.param1];
            CallInfo *tsdkCallInfo = _tsdkCallInfoDic[callId];
            if (tsdkCallInfo)
            {
                tsdkCallInfo.isAudienceConf = YES;
                tsdkCallInfo.isOneWay = !notify.param2;
                [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_AUDIT_DIR
                                                                        object:nil
                                                                      userInfo:self->_tsdkCallInfoDic];
                });
                
            }

            break;
        }
        case TSDK_E_CALL_EVT_REFER_NOTIFY: // 转移通知
        {
            NSString *callId = [NSString stringWithFormat:@"%d", notify.param1];
            CallInfo *tsdkCallInfo = _tsdkCallInfoDic[callId];
            [ManagerService confService].currentConfBaseInfo.callId = tsdkCallInfo.stateInfo.callId;
            if (tsdkCallInfo) {
                DDLogInfo(@"Call_Log: call revice TSDK_E_CALL_EVT_REFER_NOTIFY");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_REFER_NOTIFY
                                                                        object:nil
                                                                      userInfo:nil];
                });
            }
            break;
        }
        case TSDK_E_CALL_EVT_AUTH_TYPE_NOTIFY: // 用户认证类型
        {
            /* change at xuegd 2021-01-11
             param2: [cn]认证方式，0-未认证，1-本地认证(本地用户)，2-外部认证(AD用户)，3-无效值
             data:   None
             */
            NSString *authType = [NSString stringWithFormat:@"%d", notify.param2];
            if (authType) {
                DDLogInfo(@"Call_Log: call revice TSDK_E_CALL_EVT_AUTH_TYPE_NOTIFY");
                [CommonUtils userDefaultSaveValue:authType forKey: CALL_EVT_AUTH_TYPE_KEY];
            }
            break;
        }
        case TSDK_E_CALL_EVT_VIDEO_NET_QUALITY: // 视频网络质量统计信息
        {
            NSString *callId = [NSString stringWithFormat:@"%d", notify.param1];
            TsdkCallNetQualityLevel *level = (TsdkCallNetQualityLevel *)notify.data;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *result = @{@"callId":callId,@"netLevel":[NSString stringWithFormat:@"%d",level->downNetLevel],@"upNetLevel":[NSString stringWithFormat:@"%d",level->upNetLevel]};
                DDLogInfo(@"Call_Log: call revice TSDK_E_CALL_EVT_VIDEO_NET_QUALITY %@",result);
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_VIDEO_NET_QUALITY
                                                                    object:nil
                                                                  userInfo:result];
            });
            break;
        }
            
        case TSDK_E_CALL_EVT_AUDIO_NET_QUALITY: // 音频网络质量统计信息
        {
            NSString *callId = [NSString stringWithFormat:@"%d", notify.param1];
            TsdkCallNetQualityLevel *level = (TsdkCallNetQualityLevel *)notify.data;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *result = @{@"callId":callId,@"netLevel":[NSString stringWithFormat:@"%d",level->downNetLevel],@"upNetLevel":[NSString stringWithFormat:@"%d",level->upNetLevel]};
                DDLogInfo(@"Call_Log: call revice TSDK_E_CALL_EVT_AUDIO_NET_QUALITY %@",result);
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_AUDIO_NET_QUALITY
                                                                    object:nil
                                                                  userInfo:result];
            });
            break;
        }
        case TSDK_E_CALL_EVT_HOWL_STATUS: // 啸叫信息通知
        {
            NSString *howlAutoMuteSwitch = [NSString stringWithFormat:@"%d", notify.param1];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *result = @{@"howlAutoMuteSwitch":howlAutoMuteSwitch};
                DDLogInfo(@"Call_Log: call revice TSDK_E_CALL_EVT_HOWL_STATUS %@",result);
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_HOWL_STATUS
                                                                    object:nil
                                                                  userInfo:result];
            });
            break;
        }
        case TSDK_E_CALL_EVT_REAL_TIME_BAND_WIDTH_CHANGE: // 实时带宽信息变化通知
        {
            NSString *callID = [NSString stringWithFormat:@"%d",notify.param1];
            NSString *bindWidth = [NSString stringWithFormat:@"%d", notify.param2];
            NSDictionary *result = @{@"callID":callID,CALL_S_CALL_EVT_BAND_WIDTH_CHANGE:bindWidth};
            DDLogInfo(@"Call_Log: recv call notify :TSDK_E_CALL_EVT_REAL_TIME_BAND_WIDTH_CHANGE %@",result);
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSNotificationCenter.defaultCenter postNotificationName:CALL_S_CALL_EVT_BAND_WIDTH_CHANGE object:nil userInfo:result];
            });
            break;
        }
        case TSDK_E_CALL_EVT_CALL_RTP_CREATED: // RTP通道已建立，可以进行二次拨号
        {
            NSString *callID = [NSString stringWithFormat:@"%d",notify.param1];
            DDLogInfo(@"Call_Log: recv call notify :TSDK_E_CALL_EVT_CALL_RTP_CREATED >> callId:%@", callID);
            break;
        }
        case TSDK_E_CALL_EVT_SESSION_CODEC: // 会话正在使用的codec通知
        {
            DDLogInfo(@"Call_Log: recv call notify :TSDK_E_CALL_EVT_SESSION_CODEC");
            break;
        }
        default: {
            DDLogInfo(@"msgId = %d", notify.msgId);
            break;
        }
    }
    
    if (notify.msgId>=TSDK_E_CALL_EVT_HOLD_SUCCESS && notify.msgId<=TSDK_E_CALL_EVT_UNHOLD_FAILED)
    {
        [self handleCallHoldNotify:notify];
    }
    if (notify.msgId>=TSDK_E_CALL_EVT_DIVERT_FAILED && notify.msgId<=TSDK_E_CALL_EVT_SET_IPT_SERVICE_RESULT)
    {
        [self handleTransferNotify:notify];
    }
}

/*
 处理上传日志回调通知
 */
- (void)onReceiveUpLoadLogNotification:(Notification *)notify{
    switch (notify.msgId) {
        case TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT:
        {
            TSDK_UINT32 result = notify.param1;
            NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",result],@"result", nil] ;
            [[NSNotificationCenter defaultCenter] postNotificationName:UPLOAD_LOG_RESULT object:nil userInfo:dict];
        }
            break;
            
        default:
            break;
    }
}

/**
 *This method is used to deel call transfer notification
 *处理转移业务回调
 */
-(void)handleTransferNotify:(Notification *)notify
{
    DDLogInfo(@"handleTransferNotify id:%d",notify.msgId);
    switch (notify.msgId)
    {
        case TSDK_E_CALL_EVT_DIVERT_FAILED:
        {
            DDLogInfo(@"CALL_E_EVT_CALL_DIVERT_FAILED");
            [self respondsCallDelegateWithType:CALL_DIVERT_FAILED result:nil];
            break;
        }
        case TSDK_E_CALL_EVT_BLD_TRANSFER_SUCCESS:
        {
            DDLogInfo(@"CALL_E_EVT_CALL_BLD_TRANSFER_SUCCESS");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_TRANSFER_RESULT_KEY:[NSNumber numberWithBool:YES]
                                         };
            [self respondsCallDelegateWithType:CALL_TRANSFER_RESULT result:resultInfo];
            break;
        }
        case TSDK_E_CALL_EVT_BLD_TRANSFER_FAILED:
        {
            DDLogInfo(@"CALL_E_EVT_CALL_BLD_TRANSFER_FAILED");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_TRANSFER_RESULT_KEY:[NSNumber numberWithBool:NO]
                                         };
            [self respondsCallDelegateWithType:CALL_TRANSFER_RESULT result:resultInfo];
            break;
        }
            
        case TSDK_E_CALL_EVT_SET_IPT_SERVICE_RESULT:
        {
            TSDK_E_IPT_SERVICE_TYPE serviceCallType = (TSDK_E_IPT_SERVICE_TYPE)notify.param1;
            TSDK_S_SET_IPT_SERVICE_RESULT *setServiceResult = (TSDK_S_SET_IPT_SERVICE_RESULT *)notify.data;
            
            IPTConfigType type = [self getIPTConfigType:(CALL_SERVICE_TYPE)serviceCallType withIsEnable:setServiceResult->is_enable];
            if([self.iptDelegate respondsToSelector:@selector(iptConfigCallBack:result:)]){
                [self.iptDelegate iptConfigCallBack:type result:(setServiceResult->reason_code == 0)?YES:NO];
            }
            break;
        }
            
        default:
            break;
    }
}

/**
 *This method is used to get ipt config type
 *将sdk提供的ipt业务枚举转换为自定义枚举值
 */
- (IPTConfigType)getIPTConfigType:(CALL_SERVICE_TYPE) serviceCallType withIsEnable:(BOOL) isEnable
{
    
    IPTConfigType type = IPT_REG_UN;
    
    switch (serviceCallType) {
        case CALL_SERVICE_TYPE_DND:
        {
            if(isEnable){
                type = IPT_REG_DND;
            }else{
                type = IPT_UNREG_DND;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CALL_WAIT:
        {
            if(isEnable){
                type = IPT_CALL_WAIT_ACTIVE;
            }else{
                type = IPT_CALL_WAIT_DEACTIVE;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFU:
        {
            if(isEnable){
                type = IPT_FORWARD_UNCONDITION_Active;
            }else{
                type = IPT_FORWARD_UNCONDITION_Deactive;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFB:
        {
            if(isEnable){
                type = IPT_FORWARD_ONBUSY_Active;
            }else{
                type = IPT_FORWARD_ONBUSY_Deactive;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFN:
        {
            if(isEnable){
                type = IPT_FORWARD_NOREPLY_Active;
            }else{
                type = IPT_FORWARD_NOREPLY_Deactive;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFO:
        {
            if(isEnable){
                type = IPT_FORWARD_OFFLINE_Active;
            }else{
                type = IPT_FORWARD_OFFLINE_Deactive;
            }
            break;
        }
        default:
            break;
    }
    
    return type;
}

/**
 *This method is used to deel call hold notification
 *处理呼叫保持回调业务
 */
-(void)handleCallHoldNotify:(Notification *)notify
{
    DDLogInfo(@"handleCallHoldNotify id:%d",notify.msgId);
    NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
    switch (notify.msgId)
    {
        case TSDK_E_CALL_EVT_HOLD_SUCCESS:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_HOLD_SUCCESS");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_HOLD_RESULT_KEY:[NSNumber numberWithBool:YES],
                                         CALL_ID : callId
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_HOLD_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_HOLD_SUCCESS object:nil userInfo:resultInfo];
            });
            
            
            break;
        }
        case TSDK_E_CALL_EVT_HOLD_FAILED:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_HOLD_FAILED");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_HOLD_RESULT_KEY:[NSNumber numberWithBool:NO],
                                         CALL_ID : callId
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_HOLD_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_HOLD_FAILED object:nil userInfo:resultInfo];
            });
            
            break;
        }
        case TSDK_E_CALL_EVT_UNHOLD_SUCCESS:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_UNHOLD_SUCCESS");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_UNHOLD_RESULT_KEY:[NSNumber numberWithBool:YES],
                                         CALL_ID : callId
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsCallDelegateWithType:CALL_UNHOLD_RESULT result:resultInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_S_CALL_EVT_UNHOLD_SUCCESS object:nil userInfo:resultInfo];
            });
            
            break;
        }
        case TSDK_E_CALL_EVT_UNHOLD_FAILED:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_UNHOLD_FAILED");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_UNHOLD_RESULT_KEY:[NSNumber numberWithBool:NO],
                                         CALL_ID : callId
                                         };
            [self respondsCallDelegateWithType:CALL_UNHOLD_RESULT result:resultInfo];
            break;
        }
        default:
            break;
    }
}

/**
 *This method is used to get incoming call number
 *获取来电号码
 */
- (NSDictionary*)parseCallNumberForInfo:(CallInfo*)callInfo
{
    NSMutableDictionary* parseDic = [NSMutableDictionary dictionary];
    NSString *comingSipNum = callInfo.stateInfo.callNum;
    NSRange numSearchRange = [comingSipNum rangeOfString:@"@"];
    if (numSearchRange.length > 0)
    {
        comingSipNum = [comingSipNum substringToIndex:numSearchRange.location];
    }
    
    NSString *comingNum = callInfo.telNumTel;
    if (0 == [comingNum length])
    {
        comingNum = comingSipNum;
    }
    NSRange searchRange = [comingNum rangeOfString:@"@"];
    if (searchRange.length > 0)
    {
        comingNum = [comingNum substringToIndex:searchRange.location];
    }
    
    NSRange rangeSearched = [comingNum rangeOfString:@";cpc=ordinary" options:NSCaseInsensitiveSearch];
    if (rangeSearched.length > 0)
    {
        comingNum = [comingNum substringToIndex:rangeSearched.location];
    }
    
    [parseDic setObject:comingNum forKey:CALLINFO_CALLNUMBER_KEY];
    [parseDic setObject:comingSipNum forKey:CALLINFO_SIPNUMBER_KEY];
    
    return parseDic;
}

#pragma mark - Config


/**
 *This method is used to reset video orient and index
 *重设摄像头的方向和序号
 */
- (void)resetUCVideoOrientAndIndexWithCallId:(unsigned int)callid
{
    TSDK_S_VIDEO_ORIENT orient;
    orient.choice = 1;
    orient.portrait = 0;
    orient.landscape = 0;
    orient.seascape = 1;
    tsdk_set_video_orient(callid, CameraIndexFront, &orient);
}

/**
 * This method is used to update video window local view
 * 更新视频本地窗口画面
 *@param localVideoView     Indicates local video view
 *                          本地视频视图
 *@param remoteVideoView    Indicates remote video view
 *                          远端视频试图
 *@param bfcpVideoView      Indicates bfcp video view
 *                          bfcp视频试图
 *@param callId             Indicates call id
 *                          呼叫id
 *@return YES or NO
 */
- (BOOL)updateVideoWindowWithLocal:(id)localVideoView
                         andRemote:(id)remoteVideoView
                           andBFCP:(id)bfcpVideoView
                            callId:(unsigned int)callId
{
    DDLogInfo(@"updateVideoWindowWithLocal - localVideoView:%@  remoteVideoView:%@  bfcpVideoView:%@",localVideoView,remoteVideoView,bfcpVideoView);
    NSInteger num = 3;
    CallInfo *callInfo = _tsdkCallInfoDic[[NSString stringWithFormat:@"%d",callId]];
    if (callInfo && callInfo.isSvcCall) {
        num = 2;
    }
    TSDK_S_VIDEO_WND_INFO videoInfo[num];
    memset_s(videoInfo, sizeof(TSDK_S_VIDEO_WND_INFO) * num, 0, sizeof(TSDK_S_VIDEO_WND_INFO) * num);
    videoInfo[0].video_wnd_type = TSDK_E_VIDEO_WND_LOCAL;
    videoInfo[0].render = (TSDK_UPTR)localVideoView;
    videoInfo[0].display_mode = TSDK_E_VIDEO_WND_DISPLAY_FULL;
    videoInfo[1].video_wnd_type = TSDK_E_VIDEO_WND_AUX_DATA;
    videoInfo[1].render = (TSDK_UPTR)bfcpVideoView;
    TSDK_RESULT ret;
    videoInfo[1].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;
//    videoInfo[1].display_mode = TSDK_E_VIDEO_WND_DISPLAY_FULL;
    if ((callInfo == nil) || (!callInfo.isSvcCall)) {
        videoInfo[2].video_wnd_type = TSDK_E_VIDEO_WND_REMOTE;
        videoInfo[2].render = (TSDK_UPTR)remoteVideoView;
        videoInfo[2].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;
//        videoInfo[2].display_mode = TSDK_E_VIDEO_WND_DISPLAY_FULL;
    }

    ret = tsdk_set_video_window((TSDK_UINT32)callId, (TSDK_UINT32)num, videoInfo);
    DDLogInfo(@"Call_Log: tsdk_set_video_window = %d",ret);
    
    [self updateVideoRenderInfoWithVideoIndex:_cameraCaptureIndex withRenderType:TSDK_E_VIDEO_WND_LOCAL andCallId:callId];
    [self updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TSDK_E_VIDEO_WND_REMOTE andCallId:callId];
    return (TSDK_SUCCESS == ret);
}


/**
* This method is used to add svc video window
* 绑定SVC视频窗口画面
*@param remoteVideoView    Indicates remote video view
*                          远端视频试图
*@param callId             Indicates call id
*                          呼叫id
*@return YES or NO
 */
- (BOOL)addSvcVideoWindowWithRemote:(id)remoteVideoView
                                 lable:(NSInteger)lable
                                callId:(unsigned int)callId
{
    TSDK_RESULT ret;
    TSDK_S_SVC_VIDEO_WND_INFO window;
    memset_s(&window, sizeof(TSDK_S_SVC_VIDEO_WND_INFO), 0, sizeof(TSDK_S_SVC_VIDEO_WND_INFO));
    window.render = (TSDK_UPTR)remoteVideoView;
    window.lable = (TSDK_UINT32)lable;
    window.width = RESOLUTION_720P_WIDTH.floatValue;
    window.height = RESOLUTION_720P_HEIGHT.floatValue;
    ret = tsdk_add_svc_video_window((TSDK_UINT32)callId, &window);
    DDLogInfo(@"tsdk_add_svc_video_window result = %d",ret);
    return (TSDK_SUCCESS == ret);
}

/**
* This method is used to remove svc video window
* 删除SVC视频窗口画面
*@param remoteVideoView    Indicates remote video view
*                          远端视频试图
*@param callId             Indicates call id
*                          呼叫id
*@return YES or NO
 */
- (BOOL)removeSvcVideoWindowWithRemote:(id)remoteVideoView
                                 lable:(NSInteger)lable
                                callId:(unsigned int)callId
{
    TSDK_RESULT ret;
    TSDK_S_SVC_VIDEO_WND_INFO window;
    memset_s(&window, sizeof(TSDK_S_SVC_VIDEO_WND_INFO), 0, sizeof(TSDK_S_SVC_VIDEO_WND_INFO));
    window.render = (TSDK_UPTR)remoteVideoView;
    window.lable = (TSDK_UINT32)lable;
    window.width = RESOLUTION_720P_WIDTH.floatValue;
    window.height = RESOLUTION_720P_HEIGHT.floatValue;
    ret = tsdk_remove_svc_video_window((TSDK_UINT32)callId, &window);
    DDLogInfo(@"tsdk_remove_svc_video_window result = %d",ret);
    return (TSDK_SUCCESS == ret);
}

/**
* This method is used to update svc video window
* 更新SVC视频窗口画面
*@param remoteVideoView    Indicates remote video view
*                          远端视频试图
*@param callId             Indicates call id
*                          呼叫id
*@return YES or NO
 */
- (BOOL)updateSvcVideoWindowWithRemote:(id)remoteVideoView
                                 lable:(NSInteger)lable
                                callId:(unsigned int)callId
{
    TSDK_RESULT ret;
    TSDK_S_SVC_VIDEO_WND_INFO window;
    memset_s(&window, sizeof(TSDK_S_SVC_VIDEO_WND_INFO), 0, sizeof(TSDK_S_SVC_VIDEO_WND_INFO));
    window.render = (TSDK_UPTR)remoteVideoView;
    window.lable = UInt32(lable);
    window.width = RESOLUTION_720P_WIDTH.floatValue;
    window.height = RESOLUTION_720P_HEIGHT.floatValue;
    ret = tsdk_update_svc_video_window((TSDK_UINT32)callId, &window);
    DDLogInfo(@"tsdk_update_svc_video_window result = %d",ret);
    return (TSDK_SUCCESS == ret);
}

/**
* 批量删除绑定SVC视频窗口画面
* @param  remoteVideoViews      远端视频画面数组
* @param  attendees             与会者数组
* @param  callId                呼叫id
* @return  YES or NO
 */
- (BOOL)addRemoveSvcVideoWindowWithRemotes:(NSArray *)remoteVideoViews
                                 attendees:(NSArray *)attendees
                                    callId:(unsigned int)callId
                              isBigPicture:(BOOL)isBigPicture
                                 bandWidth:(UInt32)bandWidth
                                 isH265SVC:(BOOL)isH265Svc
{
    TSDK_RESULT ret;
    TSDK_S_SVC_SET_WATCH_LIST_INFO *window_array = (TSDK_S_SVC_SET_WATCH_LIST_INFO *)malloc(sizeof(TSDK_S_SVC_SET_WATCH_LIST_INFO));
    memset_s(window_array, sizeof(TSDK_S_SVC_SET_WATCH_LIST_INFO), 0, sizeof(TSDK_S_SVC_SET_WATCH_LIST_INFO));
    NSInteger count = 0;
    if (remoteVideoViews.count >= attendees.count) {
        count = attendees.count;
    }else{
        count = remoteVideoViews.count;
    }
    window_array->attendNum = (TSDK_UINT32)count;
    for (int i = 0; i< count; i++) {
        ConfAttendeeInConf *attend = attendees[i];
        EAGLView *view = remoteVideoViews[i];
        window_array->attendWndInfo[i].render = (TSDK_UPTR)view;
        window_array->attendWndInfo[i].lable = (UInt32)attend.lable_id;
        if (isBigPicture || attendees.count == 1) { // 当前是画中画或者当前只有一个远端画面
            if (bandWidth > 1536) { // 会场带宽大于1.5M 使用720P画质
                window_array->attendWndInfo[i].width = RESOLUTION_720P_WIDTH.floatValue;
                window_array->attendWndInfo[i].height = RESOLUTION_720P_HEIGHT.floatValue;
            }else { // 会场带宽小于等于1.5M 使用360P画质
                window_array->attendWndInfo[i].width = RESOLUTION_360P_WIDTH.floatValue;
                window_array->attendWndInfo[i].height = RESOLUTION_360P_HEIGHT.floatValue;
            }
        }else{ // 当前是画廊模式
            if (bandWidth > 1536) { // 会场带宽大于1.5M 使用360P画质
                window_array->attendWndInfo[i].width = RESOLUTION_360P_WIDTH.floatValue;
                window_array->attendWndInfo[i].height = RESOLUTION_360P_HEIGHT.floatValue;
            }else { // 会场带宽小于等于1.5M
                if (!isH265Svc && bandWidth <= 512) { // H264SVC会议，带宽小于512KB，使用90P
                    window_array->attendWndInfo[i].width = RESOLUTION_90P_WIDTH.floatValue;
                    window_array->attendWndInfo[i].height = RESOLUTION_90P_HEIGHT.floatValue;
                }else { // H265SVC使用180P 或 H264SVC并且带宽大于512KB使用180P
                    window_array->attendWndInfo[i].width = RESOLUTION_180P_WIDTH.floatValue;
                    window_array->attendWndInfo[i].height = RESOLUTION_180P_HEIGHT.floatValue;
                }
            }
        }
    }
    ret = tsdk_set_all_svc_video_windows((TSDK_UINT32)callId, window_array);
    DDLogInfo(@"tsdk_set_all_svc_video_windows result is %d", ret);
    
    free(window_array);
    return  (TSDK_SUCCESS == ret);
}

/**
 * This method is used to open video preview, default open front camera
 * 打开视频预览,默认打开前置摄像头
 *@param cameraIndex         Indicates camera index
 *                           视频摄像头序号
 *@param viewHandler         Indicates view handle
 *                           视图句柄
 *@return YES or NO
 */
- (BOOL)videoPreview:(unsigned int)cameraIndex toView:(id) viewHandler
{
    _videoPreview = viewHandler;
    TSDK_RESULT ret = tsdk_open_video_preview((TSDK_UPTR)viewHandler, (TSDK_UINT32)cameraIndex);
    DDLogInfo(@"Camera_Log:tsdk_open_video_preview result is %d", ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}


/**
 * This method is used to close video preview
 *关闭视频预览
 */
-(void)stopVideoPreview
{
    tsdk_close_video_preview();
}

/**
 *This method is used to start EC access number to join conference
 *EC接入码入会
 *@param confid                  Indicates confid
 *                               会议Id
 *@param acceseNum               Indicates accese number
 *                               会议接入码
 *@param psw                     Indicates password
 *                               会议密码
 *@return unsigned int           Return call id, equal zero mean start call fail.
 *                               返回呼叫id,失败返回0
 */
//- (unsigned int) startECAccessCallWithConfid:(NSString *)confid AccessNum:(NSString *)acceseNum andPsw:(NSString *)psw
//{
//    TSDK_UINT32 callid = 0;
//    CALL_S_CONF_PARAM *confParam = (CALL_S_CONF_PARAM *)malloc(sizeof(CALL_S_CONF_PARAM));
//    memset_s(confParam, sizeof(CALL_S_CONF_PARAM), 0, sizeof(CALL_S_CONF_PARAM));
//    if (confid.length > 0 && confid != nil) {
//        strcpy(confParam->confid, [confid UTF8String]);
//    }
//    if (psw.length > 0 && psw != nil) {
//        strcpy(confParam->conf_paswd, [psw UTF8String]);
//    }
//    if (acceseNum.length > 0 && acceseNum != nil) {
//        strcpy(confParam->access_code, [acceseNum UTF8String]);
//    }
//    //callType  默认使用CALL_E_CALL_TYPE_IPVIDEO
//    TUP_RESULT ret_ex = tup_call_serverconf_access_reservedconf_ex(&callid, CALL_E_CALL_TYPE_IPVIDEO, confParam);
//    return callid;
//
//}

/**
 *This method is used to start point to point audio call or video call
 *发起音视频呼叫
 *@param number                  Indicates number
 *                               呼叫的号码
 *@param callType audio/video    Indicates call type
 *                               呼叫类型
 *@return unsigned int           Return call id, equal zero mean start call fail.
 *                               返回呼叫id,失败返回0
 */
-(unsigned int)startCallWithNumber:(NSString *)number name:(NSString *)name type:(TUP_CALL_TYPE)callType
{
    if (nil == number || number.length == 0) {
        return 0;
    }
    [self resetUCVideoOrientAndIndexWithCallId:0];
    TSDK_BOOL isVideo = (callType==CALL_VIDEO)?TSDK_TRUE:TSDK_FALSE;
    TSDK_UINT32 callid = 0;
    TSDK_RESULT ret = tsdk_start_call(&callid,(TSDK_CHAR*)[number UTF8String], (TSDK_CHAR*)[name UTF8String], isVideo);
    
    
    DDLogInfo(@"Call_Log: tsdk_start_call = %d", ret);
    
    if (ret == 0) {
        CallLogMessage *callLogMessage = [[CallLogMessage alloc]init];
        callLogMessage.calleePhoneNumber = number;
        callLogMessage.durationTime = 0;
        callLogMessage.startTime = [self nowTimeString];
        callLogMessage.callLogType = OutgointCall;
        callLogMessage.callId = callid;
        callLogMessage.isConnected = NO;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        if ([self loadLocalCallHistoryData].count > 0) {
            [array addObjectsFromArray:[self loadLocalCallHistoryData]];
        }
        [array addObject:callLogMessage];
        [self writeToLocalFileWith:array];
    }
    
    return callid;
}

/**
 *This method is used to answer the incoming call, select audio or video call
 *接听呼叫
 *@param callType                Indicates call type
 *                               呼叫类型
 *@param callId                  Indicate call id
 *                               呼叫id
 *@return YES or NO
 */
- (BOOL) answerComingCallType:(TUP_CALL_TYPE)callType callId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_accept_call((TSDK_UINT32)callId, callType == CALL_AUDIO ? TSDK_FALSE : TSDK_TRUE);
    DDLogInfo(@"Call_Log:answer call type is %d,result is %d, callid: %@",callType,ret,[NSString encryptNumberWithString:@(callId).stringValue]);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to end call
 *结束通话
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES or NO
 */
-(BOOL)closeCall:(unsigned int)callId
{
    TSDK_UINT32 callid = (TSDK_UINT32)callId;
    TSDK_RESULT ret = tsdk_end_call(callid);
    DDLogInfo(@"Call_Log: tsdk_end_call is %d, callid:%@",ret,[NSString encryptNumberWithString:@(callId).stringValue]);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to reply request of adding video call
 *回复是否接受音频转视频
 *@param accept                  Indicates whether accept
 *                               是否接受
 *@param callId                  Indicates call id
 *                               呼叫Id
 @return YES is success,NO is fail
 */
-(BOOL)replyAddVideoCallIsAccept:(BOOL)accept callId:(unsigned int)callId
{
    TSDK_BOOL isAccept = accept;
    TSDK_RESULT ret = tsdk_reply_add_video((TSDK_UINT32)callId , isAccept);
    DDLogInfo(@"Call_log: tsdk_reply_add_video is %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to upgrade audio to video call
 *将音频呼叫升级为视频呼叫
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)upgradeAudioToVideoCallWithCallId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_add_video((TSDK_UINT32)callId);
    DDLogInfo(@"Call_Log: tsdk_add_video is %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to transfer video call to audio call
 *将视频呼叫转为音频呼叫
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)downgradeVideoToAudioCallWithCallId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_del_video((TSDK_UINT32)callId);
    DDLogInfo(@"Call_Log: tsdk_del_video is %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to rotation camera capture
 * 转换摄像头采集
 *@param ratation                Indicates camera rotation {0,1,2,3}
 *                               旋转摄像头采集
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)rotationCameraCapture:(NSUInteger)ratation callId:(unsigned int)callId  isCameraClose:(BOOL)isCameraClose
{
    _cameraRotation = ratation;
    if (isCameraClose) {
        return NO;
    }
    TSDK_RESULT ret = tsdk_set_capture_rotation((TSDK_UINT32)callId , (TSDK_E_VIDEO_CAPTURE_INDEX_TYPE)_cameraCaptureIndex, (TSDK_E_VIDEO_CAPTURE_ROTATOIN_TYPE)ratation);
    DDLogInfo(@"Call_Log: tsdk_set_capture_rotation is %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to rotation Video display
 * 旋转摄像头显示
 *@param orientation             Indicates camera orientation
 *                               旋转摄像头采集
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success, NO is fail
 */
-(BOOL)rotationVideoDisplay:(NSUInteger)orientation callId:(unsigned int)callId isCameraClose:(BOOL)isCameraClose
{
    if (isCameraClose) {
        return NO;
    }
    TSDK_RESULT ret_rotation = tsdk_set_display_rotation((TSDK_UINT32)callId, TSDK_E_VIDEO_WND_LOCAL, (TSDK_E_VIDEO_DISPLAY_ROTATOIN_TYPE)orientation);
    DDLogInfo(@"tsdk_set_display_rotation : %d", ret_rotation);
    return (TSDK_SUCCESS == ret_rotation);
}

/**
 *This interface is used to set set camera picture
 *设置视频采集文件
 */
-(BOOL)setVideoCaptureFileWithcallId:(unsigned int)callId
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"tup_call_closeCramea_img2"
                                                          ofType:@"bmp"];
    TSDK_RESULT ret = tsdk_set_camera_picture((TSDK_UINT32)callId, (TSDK_CHAR *)[imagePath UTF8String]);
    DDLogInfo(@"Call_Log: tsdk_set_camera_picture = %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to switch camera index
 * 切换摄像头
 *@param cameraCaptureIndex      Indicates camera capture index, Fort -1 Back -0
 *                               摄像头序号
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)switchCameraIndex:(NSUInteger)cameraCaptureIndex callId:(unsigned int)callId
{
    TSDK_S_VIDEO_ORIENT orient;
    memset_s(&orient, sizeof(TSDK_S_VIDEO_ORIENT), 0, sizeof(TSDK_S_VIDEO_ORIENT));
    orient.choice = 1;
    orient.portrait = 0;
    orient.landscape = 0;
    orient.seascape = 1;
    TSDK_RESULT result = tsdk_set_video_orient(callId, (TSDK_UINT32)cameraCaptureIndex, &orient);
    if (result == TSDK_SUCCESS)
    {
        _cameraCaptureIndex = cameraCaptureIndex == 1 ? CameraIndexFront : CameraIndexBack;
    }
    [self updateVideoRenderInfoWithVideoIndex:(CameraIndex)cameraCaptureIndex withRenderType:TSDK_E_VIDEO_WND_LOCAL andCallId:callId];
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to update video  render info with video index
 *根据摄像头序号更新视频渲染
 */
- (void)updateVideoRenderInfoWithVideoIndex:(CameraIndex)index withRenderType:(TSDK_E_VIDEO_WND_TYPE)renderType andCallId:(unsigned int)callid
{
    TSDK_UINT32 mirrorType = 0;
    TSDK_UINT32 displaytype = 0;
    
    //本端视频，displaytype为1，镜像模式根据前后摄像头进行设置
    if (TSDK_E_VIDEO_WND_LOCAL == renderType)
    {
        //前置镜像模式为2（左右镜像），后置镜像模式为0（不做镜像）
        switch (index) {
            case CameraIndexBack:
            {
                mirrorType = 0;
                break;
            }
            case CameraIndexFront:
            {
                mirrorType = 2;
                break;
            }
            default:
                break;
        }
        
        displaytype = TSDK_E_VIDEO_WND_DISPLAY_FULL;
    }
    //远端视频，镜像模式为0(不做镜像)，显示模式为0（拉伸模式）
    else if (TSDK_E_VIDEO_WND_REMOTE == renderType)
    {
        mirrorType = 0;
        displaytype = TSDK_E_VIDEO_WND_DISPLAY_CUT;
    }
    else
    {
        displaytype = TSDK_E_VIDEO_WND_DISPLAY_CUT;
        DDLogInfo(@"rendertype is not remote or local");
    }
    TSDK_S_VIDEO_RENDER_INFO renderInfo;
    renderInfo.render_type = (TSDK_E_VIDEO_WND_TYPE)renderType;
    renderInfo.display_type = (TSDK_E_VIDEO_WND_DISPLAY_MODE)displaytype;
    renderInfo.mirror_type = (TSDK_E_VIDEO_WND_MIRROR_TYPE)mirrorType;
    TSDK_RESULT ret_video_render_info = tsdk_set_video_render(callid, &renderInfo);
    DDLogInfo(@"tsdk_set_video_render : %d", ret_video_render_info);
}

/**
 * This method is used to get device list
 * 获取设备列表
 *@param deviceType                 Indicates device type,see CALL_E_DEVICE_TYPE
 *                                  设备类型，参考CALL_E_DEVICE_TYPE
 *@return YES is success,NO is fail
 */
//-(BOOL)obtainDeviceListWityType:(DEVICE_TYPE)deviceType
//{
//    DDLogInfo(@"current device type: %ld",deviceType);
//    TSDK_UINT32 deviceNum = 0;
//    TSDK_S_DEVICE_INFO *deviceInfo = nullptr;
//    memset(deviceInfo, 0, sizeof(TSDK_S_DEVICE_INFO));
//    TSDK_RESULT ret = tsdk_get_devices((TSDK_E_DEVICE_TYPE)deviceType, &deviceNum, deviceInfo);
//    DDLogInfo(@"Call_Log: tsdk_get_devices = %#x,count:%d",ret,deviceNum);
//    if (deviceNum>0)
//    {
//        DDLogInfo(@"again");
//        deviceInfo = new TSDK_S_DEVICE_INFO[deviceNum];
//        TSDK_RESULT rets = tsdk_get_devices((TSDK_E_DEVICE_TYPE)deviceType, &deviceNum, deviceInfo);
//        DDLogInfo(@"Call_Log: tsdk_get_devices = %#x,count:%d",rets,deviceNum);
//        for (int i = 0; i<deviceNum; i++)
//        {
//            DDLogInfo(@"Call_Log: ulIndex:%d,strName:%s,string:%@",deviceInfo[i].index,deviceInfo[i].device_name,[NSString stringWithUTF8String:deviceInfo[i].device_name]);
//        }
//    }
//    delete [] deviceInfo;
//    return ret == TSDK_SUCCESS ? YES : NO;
//}

/**
 * This method is used to switch camera open or close
 * 切换摄像头开关
 *@param openCamera               Indicates open camera, YES:open NO:close
 *                                是否打开摄像头
 *@param callId                   Indicates call id
 *                                呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)switchCameraOpen:(BOOL)openCamera callId:(unsigned int)callId
{
    if (openCamera)
    {
        TSDK_RESULT ret = tsdk_set_capture_rotation((TSDK_UINT32)callId , (TSDK_E_VIDEO_CAPTURE_INDEX_TYPE)_cameraCaptureIndex, (TSDK_E_VIDEO_CAPTURE_ROTATOIN_TYPE)_cameraRotation);
        DDLogInfo(@"Call_Log: tsdk_set_capture_rotation is %d",ret);
        return ret == TSDK_SUCCESS ? YES : NO;
    }
    else
    {
        return [self setVideoCaptureFileWithcallId:callId];
    }
}

/**
 *This method is used to control camera close or open
 *控制摄像头的开关
 */
-(BOOL)callVideoControlCameraClose:(BOOL)isCameraClose Module:(EN_VIDEO_OPERATION_MODULE)module callId:(unsigned int)callId
{
    if (isCameraClose)
    {
        [self setVideoCaptureFileWithcallId:callId];
        [self videoControlWithCmd:STOP andModule:module andIsSync:YES callId:callId];
    }
    else
    {
        //reopen local camera
        _cameraCaptureIndex = CameraIndexFront;
        [self rotationCameraCapture:_cameraRotation callId:callId isCameraClose:isCameraClose];
        [self videoControlWithCmd:OPEN_AND_START andModule:module andIsSync:YES callId:callId];

    }
    return YES;
}

/**
 *This method is used to control video
 *控制远端和近端的摄像头打开或者关闭
 */
-(void)videoControlWithCmd:(EN_VIDEO_OPERATION)control andModule:(EN_VIDEO_OPERATION_MODULE)module andIsSync:(BOOL)isSync callId:(unsigned int)callId
{
    DDLogInfo(@"videoControlWithCmd :%d module: %d isSync:%d",control,module,isSync);
    TSDK_S_VIDEO_CTRL_INFO videoControlInfos;
    memset_s(&videoControlInfos, sizeof(TSDK_S_VIDEO_CTRL_INFO), 0, sizeof(TSDK_S_VIDEO_CTRL_INFO));
    TSDK_UINT32 call_id = (TSDK_UINT32)callId;
    videoControlInfos.object = module;
    videoControlInfos.operation = control;
    videoControlInfos.is_sync = isSync;
    TSDK_RESULT ret = tsdk_video_control(call_id, &videoControlInfos);
    DDLogInfo(@"Call_Log: tsdk_video_control result is %d",ret);
}

/**
 * This method is used to deal with video streaming, app enter background or foreground
 * 在app前后景切换时,控制视频流
 *@param active                    Indicates active YES: goreground NO: background
 *                                 触发行为
 *@param callId                    Indicates call id
 *                                 呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)controlVideoWhenApplicationResignActive:(BOOL)active callId:(unsigned int)callId
{
    if (active)
    {
        return [self callVideoControlCameraClose:NO Module:LOCAL_AND_REMOTE callId:callId];
    }
    else
    {
        return [self callVideoControlCameraClose:YES Module:LOCAL_AND_REMOTE callId:callId];
    }
}

/**
 * This method is get stream singal information, user join conference or call connected
 * 呼叫成功或建立会议成功后，获取辅流信息
 *@param callId                    Indicates call id
 *                                 呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)getCallStreamInfo:(unsigned int)callId
{
    TSDK_S_CALL_STREAM_INFO *call_stream_info = (TSDK_S_CALL_STREAM_INFO *)malloc(sizeof(TSDK_S_CALL_STREAM_INFO));
    memset_s(call_stream_info, sizeof(TSDK_S_CALL_STREAM_INFO), 0, sizeof(TSDK_S_CALL_STREAM_INFO));
    TSDK_RESULT result = tsdk_get_call_stream_info(callId, call_stream_info);
    DDLogInfo(@"Call_Log: tsdk_get_call_stream_info is %d",result);
    
    // 获取辅流信息
    self.currentCallStreamInfo = [[CallStreamInfo alloc] init];
    
    self.currentCallStreamInfo.voiceStream  =  [[VoiceStream alloc] init];
    
    self.currentCallStreamInfo.videoStream  =  [[VideoStream alloc] init];
    
    self.currentCallStreamInfo.bfcpVideoStream  =  [[BfcpVideoStream alloc] init];
    // 音频辅流
    self.currentCallStreamInfo.voiceStream.encodeProtocol = [NSString stringWithUTF8String:call_stream_info->audio_stream_info.encode_protocol];
    self.currentCallStreamInfo.voiceStream.decodeProtocol = [NSString stringWithUTF8String:call_stream_info->audio_stream_info.decode_protocol];
    self.currentCallStreamInfo.voiceStream.isSrtp = call_stream_info->audio_stream_info.is_srtp;
    self.currentCallStreamInfo.voiceStream.recvBitRate = call_stream_info->audio_stream_info.recv_bit_rate;
    self.currentCallStreamInfo.voiceStream.recvDelay = call_stream_info->audio_stream_info.recv_delay;
    self.currentCallStreamInfo.voiceStream.recvJitter = call_stream_info->audio_stream_info.recv_jitter;
    self.currentCallStreamInfo.voiceStream.recvLossFraction = call_stream_info->audio_stream_info.recv_loss_fraction;
    self.currentCallStreamInfo.voiceStream.recvNetLossFraction = call_stream_info->audio_stream_info.recv_net_loss_fraction;
    self.currentCallStreamInfo.voiceStream.recvTotalLostPacket = call_stream_info->audio_stream_info.recv_total_lost_packet;
    self.currentCallStreamInfo.voiceStream.recvBytes = call_stream_info->audio_stream_info.recv_bytes;
    self.currentCallStreamInfo.voiceStream.recvAverageMos = call_stream_info->audio_stream_info.recv_average_mos;
    self.currentCallStreamInfo.voiceStream.recvCurMos = call_stream_info->audio_stream_info.recv_cur_mos;
    self.currentCallStreamInfo.voiceStream.recvMaxMos = call_stream_info->audio_stream_info.recv_max_mos;
    self.currentCallStreamInfo.voiceStream.recvMinMos = call_stream_info->audio_stream_info.recv_min_mos;
    self.currentCallStreamInfo.voiceStream.sendBitRate = call_stream_info->audio_stream_info.send_bit_rate;
    self.currentCallStreamInfo.voiceStream.sendDelay = call_stream_info->audio_stream_info.send_delay;
    self.currentCallStreamInfo.voiceStream.sendJitter = call_stream_info->audio_stream_info.send_jitter;
    self.currentCallStreamInfo.voiceStream.sendLossFraction = call_stream_info->audio_stream_info.send_loss_fraction;
    self.currentCallStreamInfo.voiceStream.sendNetLossFraction = call_stream_info->audio_stream_info.send_net_loss_fraction;
    self.currentCallStreamInfo.voiceStream.sendTotalLostPacket = call_stream_info->audio_stream_info.send_total_lost_packet;
    self.currentCallStreamInfo.voiceStream.sendBytes = call_stream_info->audio_stream_info.send_bytes;
    self.currentCallStreamInfo.voiceStream.sendAverageMos = call_stream_info->audio_stream_info.send_average_mos;
    self.currentCallStreamInfo.voiceStream.sendCurMos = call_stream_info->audio_stream_info.send_cur_mos;
    self.currentCallStreamInfo.voiceStream.sendMaxMos = call_stream_info->audio_stream_info.send_max_mos;
    self.currentCallStreamInfo.voiceStream.sendMinMos = call_stream_info->audio_stream_info.send_min_mos;
    // 视频辅流
    self.currentCallStreamInfo.videoStream.encodeName = [NSString stringWithUTF8String:call_stream_info->video_stream_info.encode_name];
    self.currentCallStreamInfo.videoStream.encoderProfile = [NSString stringWithUTF8String:call_stream_info->video_stream_info.encoder_profile];
    self.currentCallStreamInfo.videoStream.encoderSize = [NSString stringWithUTF8String:call_stream_info->video_stream_info.encoder_size];
    self.currentCallStreamInfo.videoStream.decodeName = [NSString stringWithUTF8String:call_stream_info->video_stream_info.decode_name];
    self.currentCallStreamInfo.videoStream.decoderProfile = [NSString stringWithUTF8String:call_stream_info->video_stream_info.decoder_profile];
    self.currentCallStreamInfo.videoStream.decoderSize = [NSString stringWithUTF8String:call_stream_info->video_stream_info.decoder_size];
    self.currentCallStreamInfo.videoStream.isSrtp = call_stream_info->video_stream_info.is_srtp;
    self.currentCallStreamInfo.videoStream.width = call_stream_info->video_stream_info.width;
    self.currentCallStreamInfo.videoStream.height = call_stream_info->video_stream_info.height;
    self.currentCallStreamInfo.videoStream.recvDelay = call_stream_info->video_stream_info.recv_delay;
    self.currentCallStreamInfo.videoStream.recvFrameRate = call_stream_info->video_stream_info.recv_frame_rate;
    self.currentCallStreamInfo.videoStream.recvJitter = call_stream_info->video_stream_info.recv_jitter;
    self.currentCallStreamInfo.videoStream.recvLossFraction = call_stream_info->video_stream_info.recv_loss_fraction;
    self.currentCallStreamInfo.videoStream.recvBitRate = call_stream_info->video_stream_info.recv_bit_rate;
    self.currentCallStreamInfo.videoStream.recvBytes = call_stream_info->video_stream_info.recv_bytes;
    self.currentCallStreamInfo.videoStream.sendDelay = call_stream_info->video_stream_info.send_delay;
    self.currentCallStreamInfo.videoStream.sendFrameRate = call_stream_info->video_stream_info.send_frame_rate;
    self.currentCallStreamInfo.videoStream.sendJitter = call_stream_info->video_stream_info.send_jitter;
    self.currentCallStreamInfo.videoStream.sendLossFraction = call_stream_info->video_stream_info.send_loss_fraction;
    self.currentCallStreamInfo.videoStream.sendBitRate = call_stream_info->video_stream_info.send_bit_rate;
    self.currentCallStreamInfo.videoStream.sendBytes = call_stream_info->video_stream_info.send_bytes;
    // SVC视频流
    NSMutableArray *svcArray = [NSMutableArray array];
    for (int i = 0; i < TSDK_D_MAX_SVC_NUM; i++) {
        VideoStream *svcInfo = [[VideoStream alloc] init];
        svcInfo.encodeName = [NSString stringWithUTF8String:call_stream_info->video_stream_info.encode_name];
        svcInfo.encoderProfile = [NSString stringWithUTF8String:call_stream_info->video_stream_info.encoder_profile];
        svcInfo.encoderSize = [NSString stringWithUTF8String:call_stream_info->video_stream_info.encoder_size];
        svcInfo.decodeName = [NSString stringWithUTF8String:call_stream_info->video_stream_info.decode_name];
        svcInfo.decoderProfile = [NSString stringWithUTF8String:call_stream_info->video_stream_info.decoder_profile];
        svcInfo.decoderSize = [NSString stringWithUTF8String:call_stream_info->video_stream_info.decoder_size];
        svcInfo.isSrtp = call_stream_info->video_stream_info.is_srtp;
        svcInfo.width = call_stream_info->video_stream_info.width;
        svcInfo.height = call_stream_info->video_stream_info.height;
        svcInfo.recvDelay = call_stream_info->video_stream_info.recv_delay;
        svcInfo.recvFrameRate = call_stream_info->video_stream_info.recv_frame_rate;
        svcInfo.recvJitter = call_stream_info->video_stream_info.recv_jitter;
        svcInfo.recvLossFraction = call_stream_info->video_stream_info.recv_loss_fraction;
        svcInfo.recvBitRate = call_stream_info->video_stream_info.recv_bit_rate;
        svcInfo.recvBytes = call_stream_info->video_stream_info.recv_bytes;
        svcInfo.sendDelay = call_stream_info->video_stream_info.send_delay;
        svcInfo.sendFrameRate = call_stream_info->video_stream_info.send_frame_rate;
        svcInfo.sendJitter = call_stream_info->video_stream_info.send_jitter;
        svcInfo.sendLossFraction = call_stream_info->video_stream_info.send_loss_fraction;
        svcInfo.sendBitRate = call_stream_info->video_stream_info.send_bit_rate;
        svcInfo.sendBytes = call_stream_info->video_stream_info.send_bytes;
        [svcArray addObject:svcInfo];
    }
    self.currentCallStreamInfo.svcArray = [NSArray arrayWithArray:svcArray];
    // 数据辅流
    self.currentCallStreamInfo.bfcpVideoStream.encodeName = [NSString stringWithUTF8String:call_stream_info->data_stream_info.encode_name];
    self.currentCallStreamInfo.bfcpVideoStream.encoderProfile = [NSString stringWithUTF8String:call_stream_info->data_stream_info.encoder_profile];
    self.currentCallStreamInfo.bfcpVideoStream.encoderSize = [NSString stringWithUTF8String:call_stream_info->data_stream_info.encoder_size];
    self.currentCallStreamInfo.bfcpVideoStream.decodeName = [NSString stringWithUTF8String:call_stream_info->data_stream_info.decode_name];
    self.currentCallStreamInfo.bfcpVideoStream.decoderProfile = [NSString stringWithUTF8String:call_stream_info->data_stream_info.decoder_profile];
    self.currentCallStreamInfo.bfcpVideoStream.decoderSize = [NSString stringWithUTF8String:call_stream_info->data_stream_info.decoder_size];
    self.currentCallStreamInfo.bfcpVideoStream.isSrtp = call_stream_info->data_stream_info.is_srtp;
    self.currentCallStreamInfo.bfcpVideoStream.width = call_stream_info->data_stream_info.width;
    self.currentCallStreamInfo.bfcpVideoStream.height = call_stream_info->data_stream_info.height;
    self.currentCallStreamInfo.bfcpVideoStream.recvDelay = call_stream_info->data_stream_info.recv_delay;
    self.currentCallStreamInfo.bfcpVideoStream.recvFrameRate = call_stream_info->data_stream_info.recv_frame_rate;
    self.currentCallStreamInfo.bfcpVideoStream.recvJitter = call_stream_info->data_stream_info.recv_jitter;
    self.currentCallStreamInfo.bfcpVideoStream.recvLossFraction = call_stream_info->data_stream_info.recv_loss_fraction;
    self.currentCallStreamInfo.bfcpVideoStream.recvBitRate = call_stream_info->data_stream_info.recv_bit_rate;
    self.currentCallStreamInfo.bfcpVideoStream.recvBytes = call_stream_info->data_stream_info.recv_bytes;
    self.currentCallStreamInfo.bfcpVideoStream.sendDelay = call_stream_info->data_stream_info.send_delay;
    self.currentCallStreamInfo.bfcpVideoStream.sendFrameRate = call_stream_info->data_stream_info.send_frame_rate;
    self.currentCallStreamInfo.bfcpVideoStream.sendJitter = call_stream_info->data_stream_info.send_jitter;
    self.currentCallStreamInfo.bfcpVideoStream.sendLossFraction = call_stream_info->data_stream_info.send_loss_fraction;
    self.currentCallStreamInfo.bfcpVideoStream.sendBitRate = call_stream_info->data_stream_info.send_bit_rate;
    self.currentCallStreamInfo.bfcpVideoStream.sendBytes = call_stream_info->data_stream_info.send_bytes;
    free(call_stream_info);
    return result == TSDK_SUCCESS ? YES : NO;
}
/**
 * This method is used to deal with aux data streaming, app enter background or foreground
 * 在app前后景切换时,控制辅流
 *@param active                    Indicates active YES: goreground NO: background
 *                                 触发行为
 *@param callId                    Indicates call id
 *                                 呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)controlAuxDataWhenApplicationResignActive:(BOOL)active callId:(unsigned int)callId{
    TSDK_S_VIDEO_CTRL_INFO videoControlInfos;
    memset_s(&videoControlInfos, sizeof(TSDK_S_VIDEO_CTRL_INFO), 0, sizeof(TSDK_S_VIDEO_CTRL_INFO));
    
    videoControlInfos.object = 3;
    videoControlInfos.operation = active ? 5 : 10;
    videoControlInfos.is_sync = TSDK_TRUE;
    
    TSDK_RESULT result = tsdk_aux_data_control(callId,&videoControlInfos);
    DDLogInfo(@"Call_Log: tsdk_aux_data_control result= %xd , active = %d",result,active);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to play WAV music file
 * 播放wav音乐文件
 *@param filePath                  Indicates file path
 *                                 文件路径
 *@return YES is success,NO is fail
 */
-(BOOL)mediaStartPlayWithFile:(NSString *)filePath
{
    if (_playHandle >= 0)
    {
        return NO;
    }
    TSDK_RESULT result = tsdk_start_play_media(0, (TSDK_CHAR *)[filePath UTF8String], &_playHandle);
    DDLogInfo(@"Call_Log: tsdk_start_play_media result= %xd , playhandle = %d",result,_playHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to stop play music
 * 停止播放铃音
 *@return YES is success,NO is fail
 */
-(BOOL)mediaStopPlay
{
    TSDK_RESULT result = tsdk_stop_play_media(_playHandle);
    _playHandle = -1;
    DDLogInfo(@"Call_Log: tsdk_stop_play_media result= %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to switch mute micphone
 * 打开或者关闭麦克风
 *@param mute                      Indicates switch microphone, YES is mute,NO is unmute
 *                                 打开或者关闭麦克风
 *@param callId                    Indicates call id
 *                                 呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)muteMic:(BOOL)mute callId:(unsigned int)callId
{
    TSDK_RESULT result = tsdk_mute_mic(callId , mute);
    DDLogInfo(@"Call_Log: tsdk_mute_mic result= %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}


/**
 * This method is used to set audio route
 * 设置音频路线
 *@param route                      Indicates audio route, see ROUTE_TYPE enum value
 *                                  音频路线
 *@return YES is success,NO is fail. Call back see CALL_S_CALL_EVT_CALL_ROUTE_CHANGE
 */
-(BOOL)configAudioRoute:(ROUTE_TYPE)route
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
            TSDK_E_MOBILE_AUIDO_ROUTE audioRoute = (TSDK_E_MOBILE_AUIDO_ROUTE)route;
            TSDK_RESULT result = tsdk_set_mobile_audio_route(audioRoute);
            DDLogInfo(@"tsdk_set_mobile_audio_route result is %d, audioRoute is :%d",result,audioRoute);
    });
    return YES;
}

/**
 * This method is used to get audio route
 * 获取音频路线
 *@return ROUTE_TYPE
 */
-(ROUTE_TYPE)obtainMobileAudioRoute
{
    TSDK_E_MOBILE_AUIDO_ROUTE route;
    TSDK_RESULT result = tsdk_get_mobile_audio_route(&route);
    DDLogInfo(@"tsdk_get_mobile_audio_route result is %d, audioRoute is :%d",result,route);
    return (ROUTE_TYPE)route;
}

/**
 * This method is used to send DTMF
 * 发送dtmf
 *@param number                      Indicates dtmf number, 0-9 * #
 *                                   dtmf号码
 *@param callId                      Indicates call id
 *                                   呼叫id
 *@return YES is success,NO is fail
 */
- (BOOL)sendDTMFWithDialNum:(NSString *)number callId:(unsigned int)callId
{
    TSDK_E_DTMF_TONE dtmfTone = (TSDK_E_DTMF_TONE)[number intValue];
    if ([number isEqualToString:@"*"])
    {
        dtmfTone = TSDK_E_DTMF_STAR;
    }
    else if ([number isEqualToString:@"#"])
    {
        dtmfTone = TSDK_E_DTMF_POUND;
    }
    TSDK_UINT32 callid = callId;
    TSDK_RESULT ret = tsdk_send_dtmf((TSDK_UINT32)callid,(TSDK_E_DTMF_TONE)dtmfTone);
    DDLogInfo(@"Call_Log: tsdk_send_dtmf = %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * @ingroup Call
 * @brief [en]This interface is used to get the audio and video media info
 *        [cn]获取呼叫流通道信息
 *
 * @param  callId                     [en] Indicates call ID.
 *                                                     [cn] 呼叫ID
 *@return CallStreamInfo              [en] return media information.
 *                                                     [cn] 媒体信息
 */
- (CallStreamInfo *)getStreamInfoWithCallId:(unsigned int)callId
{
    TSDK_S_CALL_STREAM_INFO *call_stream_info = (TSDK_S_CALL_STREAM_INFO *)malloc(sizeof(TSDK_S_CALL_STREAM_INFO));;
    memset_s(call_stream_info, sizeof(TSDK_S_CALL_STREAM_INFO), 0, sizeof(TSDK_S_CALL_STREAM_INFO));
    TSDK_RESULT ret = tsdk_get_call_stream_info(callId,call_stream_info);
    DDLogInfo(@"Call_Log: tsdk_get_call_stream_info = %d",ret);
    BOOL result = (TSDK_SUCCESS == ret) ? YES : NO;
    if (!result) {
        free(call_stream_info);
        return nil;
    }
    CallStreamInfo *callStreamInfo = [CallStreamInfo transfromFromCallStreamInfoStract:call_stream_info];
    free(call_stream_info);
    return callStreamInfo;
}

/**
*        [cn] 启动辅流
*
* @param callId                [en] Indicates call id.
*                                                                 [cn] 呼叫ID
* @return TSDK_RESULT                            [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention NA
* @see tsdk_aux_stop_data
*/
- (BOOL) startSendAuxDataWithCallId:(unsigned int)callId{
    TSDK_RESULT ret = tsdk_aux_start_data(callId);
    DDLogInfo(@"Call_Log: tsdk_aux_start_data = %d",ret);
    return ret;
}

/**
 * @brief [en] This interface is used to stop data.
 *        [cn] 停止辅流
 *
 * @param  callId                [en] Indicates call id.
 *                                                [cn] 呼叫ID
 * @return TSDK_RESULT                            [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                                [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_aux_start_data
 **/
- (BOOL) stopSendAuxDataWithCallId:(unsigned int)callId{
        
    TSDK_RESULT ret = tsdk_aux_stop_data(callId);
    DDLogInfo(@"Call_Log: tsdk_aux_stop_data = %d",ret);
    return ret == TSDK_SUCCESS;
}

/**
* @ingroup Call
* @brief [en] This interface is used to set video resolution according to video definition policy.
*        [cn] 设置视频图像清晰度策略
*
*                                                                       [cn] 视频图像清晰度策略
* @retval TSDK_RESULT                                                   [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                                       [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
* @attention NA
* @see NA
**/
-(BOOL) setVideoDefinitionPolicy:(NSInteger)videoDefinition
{
    
    TSDK_RESULT ret = tsdk_set_video_definition_policy((TSDK_E_VIDEO_DEFINITION_POLICY)videoDefinition);
    // 4M == 9  2M == 6  图像优先就设置带宽为4M, 如果是流畅优先就设置带宽为2M
    TSDK_E_USER_DEF_BANDWIDTH_LEVEL level = TSDK_E_USER_DEF_BANDWIDTH_2M;
    if (videoDefinition == TSDK_E_VIDEO_DEFINITION_HD) {
        level = TSDK_E_USER_DEF_BANDWIDTH_4M;
    }
    tsdk_set_user_def_bandwidth(level);
    DDLogInfo(@"Call_Log: videoDefinition = %ld, level = %d",(long)videoDefinition, level);
    DDLogInfo(@"Call_Log: tsdk_set_video_definition_policy = %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

#pragma mark - CTD

/**
 * This method is used to start CTD call
 * 发起ctd呼叫
 *@param callbackNumber           Indicates ctd callback number
 *                                ctd主叫号码
 *@param callee                   Indicates target number
 *                                ctd被叫号码
 *@return YES is success,NO is fail
 */
-(BOOL)startCTDCallWithCallbackNumber:(NSString *)callbackNumber
                         calleeNumber:(NSString *)callee
{
//    TSDK_S_CTD_CALL_PARAM *ctdParam = (TSDK_S_CTD_CALL_PARAM *)malloc(sizeof(TSDK_S_CTD_CALL_PARAM));
//    memset(ctdParam, 0, sizeof(TSDK_S_CTD_CALL_PARAM));
//    strcpy(ctdParam->callee_number, [callee UTF8String]);
//    strcpy(ctdParam->caller_number, [callbackNumber UTF8String]);
//    if (self.terminal.length  > 0 || self.terminal != nil) {
//        // 公有云环境需要用长号订阅
//        strcpy(ctdParam->subscribe_number, [self.terminal UTF8String]);
//    }else{
//        strcpy(ctdParam->subscribe_number, [callbackNumber UTF8String]);
//    }
//    TSDK_INT32 ctdCallId;
//    TSDK_RESULT result = tsdk_ctd_start_call(ctdParam, (TSDK_UINT32*)&ctdCallId);
//    _ctdCallId = ctdCallId;
//    DDLogInfo(@"tsdk_ctd_start_call result: %d",result);
//    free(ctdParam);
//    if (result == TSDK_SUCCESS) {
//        CallLogMessage *callLogMessage = [[CallLogMessage alloc]init];
//        callLogMessage.calleePhoneNumber = callbackNumber;
//        callLogMessage.durationTime = 0;
//        callLogMessage.startTime = [self nowTimeString];
//        callLogMessage.callLogType = OutgointCall;
//        callLogMessage.callId = ctdCallId;
//        callLogMessage.isConnected = NO;
//        NSMutableArray *array = [[NSMutableArray alloc]init];
//        if ([self loadLocalCallHistoryData].count > 0) {
//            array = [self loadLocalCallHistoryData];
//        }
//        [array addObject:callLogMessage];
//        [self writeToLocalFileWith:array];
//    }
//    return TSDK_SUCCESS == result ? YES : NO;
    
    return true;
}

/**
 * This method is used to close ctd call
 * 结束ctd呼叫
 @return YES is success,NO is fail
 */
-(BOOL)endCTDCall
{
//    TSDK_RESULT ret = tsdk_ctd_end_call(_ctdCallId);
//    DDLogInfo(@"Call_Log: tsdk_ctd_end_call = %d, callId:%d", ret, _ctdCallId);
//    _ctdCallId = 0;
//    return ret == TSDK_SUCCESS ? YES : NO;
    
    return YES;
}

/**
 * This method is used to config ip call
 * 设置ip呼叫
 */
-(BOOL)ipCallConfig
{
    //config local ip
    TSDK_S_LOCAL_ADDRESS local_ip;
    memset_s(&local_ip, sizeof(TSDK_S_LOCAL_ADDRESS), 0, sizeof(TSDK_S_LOCAL_ADDRESS));
    NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]];
    strcpy_s(local_ip.ip_address,sizeof(local_ip.ip_address), [ip UTF8String]);
    TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
    DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, ip);
    
    TSDK_BOOL ip_call_switch = true;
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_IPCALL_SWITCH, &ip_call_switch);
    DDLogInfo(@"config ip call result: %d", configResult);
    
    return configResult;
}

/**
 * This method is used to config ip call
 * 修改图像叠加的会场名
 * TSDK_E_CONFIG_CONF_TERMINAL_LOCAL_NAME
 */
- (BOOL)setTerminalLocalName:(NSString *)name {
    TSDK_S_TERMINAL_LOCAL_NAME local_name;
    memset_s(&local_name, sizeof(TSDK_S_TERMINAL_LOCAL_NAME), 0, sizeof(TSDK_S_TERMINAL_LOCAL_NAME));
    strcpy_s(local_name.localName, sizeof(local_name.localName), [name UTF8String]);
    TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_CONF_TERMINAL_LOCAL_NAME, &local_name);
    DDLogInfo(@"config local name result: %d, name = %@", configResult, [NSString encryptNumberWithString:name]);
    return  configResult;
}

/**
 *This method is used to post call event call back to UI according to type
 *将呼叫回调事件分发给页面
 */
-(void)respondsCallDelegateWithType:(TUP_CALL_EVENT_TYPE)type result:(NSDictionary *)resultDictionary
{
    if ([self.delegate respondsToSelector:@selector(callEventCallback:result:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate callEventCallback:type result:resultDictionary];
        });
    }
}

/**
 *This method is used to post ctd event call back to UI according to type
 *将ctd回调事件分发给页面
 */
-(void)respondsCTDDelegateWithType:(TUP_CTD_EVENT_TYPE)type result:(NSDictionary *)resultDictionary
{
    if ([self.delegate respondsToSelector:@selector(ctdCallEventCallback:result:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate ctdCallEventCallback:type result:resultDictionary];
        });
    }
}


-(void)dealloc
{
}

#pragma mark - DBPath Deal

/**
 *This method is used to get call history database path, if not exist create it
 *获取呼叫历史记录本地存储路径
 */
- (NSString *)callHistoryDBPath
{
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistName = [NSString stringWithFormat:@"%@_allHistory.plist",[ManagerService callService].sipAccount];
    NSString *filePath = [logPath stringByAppendingPathComponent:plistName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if ([[NSFileManager defaultManager] createFileAtPath:filePath
                                                    contents:nil
                                                  attributes:nil]) {
            return filePath;
        }else {
            DDLogWarn(@"create callHistory.plist failed!");
            return nil;
        }
    }
    return filePath;
}

/**
 *This method is used to write message to local file
 *将信息写到本地文件中
 */
- (BOOL)writeToLocalFileWith:(NSArray *)array {
    NSString *path = [self callHistoryDBPath];
    if (path) {
        return [NSKeyedArchiver archiveRootObject:array toFile:path];
    }
    return NO;
}

/**
 *This method is used to local call history data
 *加载呼叫历史记录
 */
- (NSArray *)loadLocalCallHistoryData {
    NSString *path = [self callHistoryDBPath];
    if (path) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return array;
    }
    return nil;
}

/**
 *This method is used to get current time as appointed format
 *获取给定格式的当前时间
 */
- (NSString *)nowTimeString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowTimeString = [formatter stringFromDate:date];
    return nowTimeString;
}

@end
