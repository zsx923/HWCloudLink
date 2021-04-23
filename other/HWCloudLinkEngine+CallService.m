//
//  HWCloudLinkEngine+CallService.m
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/20.
//  Copyright © 2021 jd.com. All rights reserved.
//

#import "HWCloudLinkEngine+CallService.h"
#import "MBProgressHUD+New.h"
#import "HWCloudLink-Swift.h"
//#import "Defines.h"

@implementation HWCloudLinkEngine (CallService)

- (void)callServiceNotification
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkComingCallNotification:) name:CALL_S_COMING_CALL_NOTIFY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callingChannelConnectedNotification:) name:CONF_S_CALL_EVT_CONF_CONNECTED object:nil];
}

- (void)sdkComingCallNotification:(NSNotification *)notification
{
    CallInfo *callInfo = notification.object;
//    GlobalDefines.shared.CLLog("calling number: \(NSString.encryptNumber(with: callInfo.telNumTel) ?? "")");
    [LocalNotification pushLocalNotify];
    
    ManagerService.callService.currentCallInfo = callInfo;
    [ManagerService.callService switchCameraOpen:NO callId:callInfo.stateInfo.callId];
    [ManagerService.callService muteMic:NO callId:callInfo.stateInfo.callId];

    if (SessionManager.shared.isCurrentMeeting) {
//        GlobalDefines.CLLog("\(NSString.encryptNumber(with: callInfo.stateInfo.callName) ?? "") call coming...")
        return;
    }
    
    // 非发起会议, 被邀入会
    if (!SessionManager.shared.isJoinImmediately)
    {
        SessionManager.shared.isBeInvitation = YES;
    }
    
    NSString *accessNumber = ManagerService.confService.currentConfBaseInfo.accessNumber ?: @"";
    NSString *telNumTel = ManagerService.callService.currentCallInfo.telNumTel ?: @"";
//    CLLog("发会 accessNumber = \(NSString.encryptNumber(with: accessNumber) ?? "")")
//    CLLog("来电 telNumTel = \(NSString.encryptNumber(with: telNumTel) ?? "")")
    
    if (SessionManager.shared.isJoinImmediately && [accessNumber isEqualToString:telNumTel])
    {
        SessionManager.shared.isJoinImmediately = NO;
        [MBProgressHUD showMessage:@"正在加入会议..."];
        [ManagerService.callService answerComingCallType:CALL_VIDEO callId:callInfo.stateInfo.callId];
    }
    else
    {
        AnswerPhoneViewController *receiveCallVC = [AnswerPhoneViewController new];
        receiveCallVC.modalPresentationStyle = UIModalPresentationFullScreen;
        receiveCallVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        receiveCallVC.callInfo = callInfo;
        [self.mainController presentViewController:receiveCallVC animated:YES completion:^{}];
    }
}

- (void)callingChannelConnectedNotification:(NSNotification *)notification
{
//    CLLog("##1.通话已建立通知")
    NSDictionary *userInfo = notification.userInfo;
    CallInfo *callInfo = userInfo[TSDK_CALL_INFO_KEY];
    if (!callInfo || ![callInfo isKindOfClass:[CallInfo class]])
    {
//        CLLog("notificationCallConnected 加入会议失败")
        [MBProgressHUD showBottom:@"加入会议失败" icon:nil view:nil];
        return;;
    }
    
//    CLLog("notificationCallConnected 加入会议成功")
//    CLLog("会议类型：callType:\(callInfo.stateInfo.callType) 【0:audio,1:video】")

    ManagerService.callService.currentCallInfo = callInfo;
    
    // 保存VMR会议信息
    if (SessionManager.shared.isMeetingVMR)
    {
        NSString *callNum = callInfo.telNumTel;
        NSArray *numArray = [callNum componentsSeparatedByString:@"*"];
        if (ManagerService.callService.isSMC3)
        {
            if (numArray.count > 0)
            {
                [[NSUserDefaults standardUserDefaults] setValue:numArray.firstObject forKey:VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY];
            }
//            CLLog("smc3.0 vmr CallID:\(numArray.firstObject)")
        }
    }

    BOOL cameraEnable = [[NSUserDefaults standardUserDefaults] boolForKey:GlobalDefines.shared.CurrentUserCameraStatus];
    [ManagerService.callService switchCameraOpen:cameraEnable callId:callInfo.stateInfo.callId];
    SessionManager.shared.isCameraOpen = cameraEnable;
    [ManagerService.callService muteMic:YES callId:callInfo.stateInfo.callId];
    
    if (!SessionManager.shared.isCurrentMeeting)
    {
        // 非会议中启动异常入会定时器, 如果在20S内没有会控回调过来, 结束会议
//        startAbnormalTimer()
    }

}


@end
