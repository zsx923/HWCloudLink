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

@implementation HWCloudLinkEngine (CallService)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)callServiceNotification
{
    // 系统下发来电事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callComingNotification:) name:CALL_S_COMING_CALL_NOTIFY object:nil];
    
    // 建立通话连接请求成功回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callingConnectedNotification:) name:CONF_S_CALL_EVT_CONF_CONNECTED object:nil];
    
    // 通话连接结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callingEndedNotification:) name:CALL_S_CALL_EVT_CALL_ENDED object:nil];

    // 销毁会议页面控制器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callingDestoryedNotification:) name:CALL_S_CALL_EVT_CALL_DESTROY object:nil];
}

- (void)callComingNotification:(NSNotification *)notification
{
    CallInfo *callInfo = notification.object;
    [TranslateBridge CLLogWithMessage:@"calling number: \(NSString.encryptNumber(with: callInfo.telNumTel) ?? "")"];
    [LocalNotification pushLocalNotify];
    ManagerService.callService.currentCallInfo = callInfo;
    
    if (SessionManager.shared.isCurrentMeeting)
    {
        [TranslateBridge CLLogWithMessage:@"\(NSString.encryptNumber(with: callInfo.stateInfo.callName) ?? "") call coming..."];
        return;
    }
    
    // 非发起会议, 被邀入会
    if (!SessionManager.shared.isJoinImmediately)
    {
        SessionManager.shared.isBeInvitation = YES;
    }
    
    NSString *accessNumber = ManagerService.confService.currentConfBaseInfo.accessNumber ?: @"";
    NSString *telNumTel = ManagerService.callService.currentCallInfo.telNumTel ?: @"";
    [TranslateBridge CLLogWithMessage:@"发会 accessNumber = \(NSString.encryptNumber(with: accessNumber) ?? "")"];
    [TranslateBridge CLLogWithMessage:@"来电 telNumTel = \(NSString.encryptNumber(with: telNumTel) ?? "")"];
    
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

- (void)callingConnectedNotification:(NSNotification *)notification
{
    [TranslateBridge CLLogWithMessage:@"##1.通话已建立通知"];
    NSDictionary *userInfo = notification.userInfo;
    CallInfo *callInfo = userInfo[TSDK_CALL_INFO_KEY];
    if (!callInfo || ![callInfo isKindOfClass:[CallInfo class]])
    {
        [TranslateBridge CLLogWithMessage:@"notificationCallConnected 加入会议失败"];
        [MBProgressHUD showBottom:@"加入会议失败" icon:nil view:nil];
        return;;
    }
    [TranslateBridge CLLogWithMessage:@"notificationCallConnected 加入会议成功"];
    [TranslateBridge CLLogWithMessage:@"会议类型：callType:\(callInfo.stateInfo.callType) 【0:audio,1:video】"];

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
            [TranslateBridge CLLogWithMessage:@"smc3.0 vmr CallID:\(numArray.firstObject)"];
        }
    }

    [ManagerService.callService switchCameraOpen:SessionManager.shared.isCameraOpen callId:callInfo.stateInfo.callId];
    [ManagerService.callService muteMic:!SessionManager.shared.isMicrophoneOpen callId:callInfo.stateInfo.callId];
    
    if (!SessionManager.shared.isCurrentMeeting)
    {
        // 非会议中启动异常入会定时器, 如果在20S内没有会控回调过来, 结束会议
        if ([self respondsToSelector:@selector(startlocalTimeout)])
        {
            [self performSelector:@selector(startlocalTimeout)];
        }
    }
}

- (void)callingEndedNotification:(NSNotification *)notification
{
    if ([self respondsToSelector:@selector(endlocalTimeout)])
    {
        [self performSelector:@selector(endlocalTimeout)];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW + 1.0, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
     });

    NSDictionary *resultInfo = notification.userInfo;
    CallInfo *callInfo = resultInfo[TSDK_CALL_INFO_KEY];
    if (!callInfo || ![callInfo isKindOfClass:[CallInfo class]])
    {
        [TranslateBridge CLLogWithMessage:@"呼叫信息不正确"];
        return;
    }
    
    if (!callInfo.isFocus)
    {
        if (self.isJoining && !callInfo.serverConfId)
        {
            [TranslateBridge CLLogWithMessage:@"当前是加入会议，需要提示"];
            self.isJoining = NO;
            [MBProgressHUD showBottom:@"会议未开始或不存在" icon:nil view:nil];
        }
        else
        {
            [TranslateBridge CLLogWithMessage:@"当前呼叫为点呼, 不提示"];
            return;
        }
            
    }
    
    if ([TranslateBridge reasonCodeIsEqualErrorTypeWithReasonCode:callInfo.stateInfo.reasonCode
             type:TSDK_E_CALL_ERR_REASON_CODE_NOTFOUND | TSDK_E_CALL_ERR_UNKNOWN])
    {
        [MBProgressHUD showBottom:@"会议未开始或不存在" icon:nil view:nil];
    }

    
    if (SessionManager.shared.meetingMainVC.isShowInWindow)
    {
        [TranslateBridge CLLogWithMessage:@"dismiss"];
        [SessionManager.shared.meetingMainVC dismissViewControllerAnimated:NO completion:^{}];
    }
}

- (void)callingDestoryedNotification:(NSNotification *)notification
{
    if ([self respondsToSelector:@selector(endlocalTimeout)])
    {
        [self performSelector:@selector(endlocalTimeout)];
    }
    
    [TranslateBridge CLLogWithMessage:@"会议销毁通知"];
    [MBProgressHUD hideHUD];
    self.isJoining = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"aux_rec"];
    SessionManager.shared.isCurrentMeeting = NO;
}

#pragma clang diagnostic pop

@end
