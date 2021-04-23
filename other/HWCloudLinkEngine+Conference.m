//
//  HWCloudLinkEngine+Conference.m
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/20.
//  Copyright © 2021 jd.com. All rights reserved.
//

#import "HWCloudLinkEngine+Conference.h"
#import "MBProgressHUD+New.h"
#import "HWCloudLink-Swift.h"
#import "Defines.h"

@implementation HWCloudLinkEngine (Conference)

- (void)conferenceServiceNotification
{
    // 会议创建结果回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conferenceStatusNotification:) name:CALL_S_CONF_EVT_BOOK_CONF_RESULT object:nil];
    
    // 主动加入会议请求失败回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeJoinConferenceFailedNotification:) name:@"JOINCONFFAIL" object:nil];
    
    // 加入会议结果状态回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectConferenceStatusNotification:) name:CALL_S_CONF_EVT_JOIN_CONF_RESULT object:nil];
 
}

- (void)conferenceStatusNotification:(NSNotification *)notification
{
    NSString *text = (SessionManager.shared.isBespeak ? @"预约会议" : @"创建会议");
    SessionManager.shared.isSelfPlayConf = !SessionManager.shared.isSelfPlayConf;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        if (notification.userInfo)
        {
            NSString *result = notification.userInfo[ECCONF_RESULT_KEY];
            if ([result isEqualToString:@"1"])
            {
                [MBProgressHUD showBottom:[NSString stringWithFormat:@"%@成功", text] icon:nil view:nil];
                if (ManagerService.callService.isSMC3 && SessionManager.shared.isBespeak)
                {
                    [[NSUserDefaults standardUserDefaults] setValue:result forKey:@"YUYUELEHUIYI"];
                }
            }
            else
            {
                [self dealMeetingStatusErrorWithCode:result text:text];
            }
        }
        
        SessionManager.shared.isBespeak = NO;
        UIViewController *vc = self.mainController.presentedViewController;
        if ([vc isKindOfClass:NSClassFromString(@"HWCreateMeetingController")] ||
            [vc isKindOfClass:NSClassFromString(@"HWJoinMeetingController")])
        {
            [vc dismissViewControllerAnimated:YES completion:^{}];
        }
    });
}


- (void)connectConferenceStatusNotification:(NSNotification *)notification
{
//    CLLog("##3.连接会议回调通知")
    [MBProgressHUD hideHUD];
//    // 停止异常入会定时器
//    stopAbnormalTimer()
//    // 销毁定时器
    [NickJionMeetingManager.manager stopAbnormalTimer];
    
    // 判断会议信息
    NSDictionary *userInfo = notification.userInfo;
    ConfBaseInfo *confInfo = userInfo[@"CONF_E_CONNECT"];
    NSNumber *confNum = userInfo[@"JONIN_MEETING_RESULT_KEY"];
    if ((!confInfo || ![confInfo isKindOfClass:[ConfBaseInfo class]]) ||
        (!confNum || ![confNum isKindOfClass:[NSNumber class]]))
    {
        [MBProgressHUD showBottom:@"加入会议失败" icon:nil view:nil];
        [SessionManager.shared endAndLeaveConferenceDealWithIsEndConf:NO];
        return;
    }

//    CLLog(" 开始加入会议")
    
    //如果是加入会议，此时需要把isjoining 置位false ，因为会议结束的时候也会收到会议结束的通知，
    if (self.isJoining)
    {
        self.isJoining = NO;
    }
    
    // 进入会场
    
    CallInfo *callInfo = ManagerService.callService.currentCallInfo;
    ConfBaseInfo *cloudInfo = SessionManager.shared.cloudMeetInfo;
    
    confInfo.scheduleUserName = @"";
    SessionManager.shared.currentCallId = confInfo.callId;
    confInfo.mediaType = CONF_MEDIATYPE_VIDEO;
//    CLLog("==========会议类型mediaType:\(meetInfo.mediaType) 【0:voice，1:video】")
    
    confInfo.confSubject = SessionManager.shared.isMeetingVMR ? cloudInfo.confSubject : @"";
    confInfo.accessNumber = SessionManager.shared.isMeetingVMR ?
    cloudInfo.accessNumber : (callInfo != nil ? callInfo.telNumTel : @"000 000");
    NSArray *numberArray = [confInfo.accessNumber componentsSeparatedByString:@"*"];
    if (numberArray.count > 0)
    {
        confInfo.accessNumber = numberArray.firstObject;
        if (numberArray.count > 1)
        {
            confInfo.generalPwd = numberArray[1];
        }
    }
    
    confInfo.isConf = YES;
    confInfo.isImmediately = YES;
//    CLLog("连接会议回调 - ECONF_E_CONNECT_KEY \(meetInfo.mediaType)")
    
    if (callInfo)
    {
//        SessionType sessionType = 1;//callInfo.isSvcCall ? svcMeeting : avcMeeting;
//        CLLog("##4.跳转页面 isSVC[\(currentCallInfo.isSvcCall)]")
//        if meetInfo.mediaType == CONF_MEDIATYPE_VIDEO {
//            sessionType = currentCallInfo.isSvcCall ? .svcMeeting : .avcMeeting
//        }
//        CLLog("========入会sessionType:\(sessionType) ===:mediaType:\(meetInfo.mediaType)")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW + 0.5, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [SessionManager.shared jump];
//            [SessionManager.shared jumpConfMeetVC123WithSessionType:<#(ConfBaseInfo * _Nonnull)#>]
         });
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { // 延迟0.5秒跳转
//            SessionManager.shared.jumpConfMeetVC(sessionType: sessionType, meetInfo: meetInfo, animated: true)
//        }
    }
    else
    {
//        CLLog("callInfo is nil")
    }
}

- (void)activeJoinConferenceFailedNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showBottom:@"加入会议失败" icon:nil view:nil];
        
    });
}

- (void)dealMeetingStatusErrorWithCode:(NSString *)errorCode text:(NSString *)text
{
    //3.0 状态下发起vmr 会议可能失败，在此处置为NO
    if (SessionManager.shared.isJoinImmediately)
    {
        SessionManager.shared.isJoinImmediately = NO;
    }
    
    NSString *desc = [NSString stringWithFormat:@"%@失败", text];
    NSArray *arr_1 = @[@"67109058", @"67109062", @"67109065", @"67109068", @"67109070", @"67109071", @"67109072", @"67109073", @"67109074", @"67109075", @"67109076"];
    
    NSArray *arr_2 = @[@"67109060", @"67109061", @"67109063", @"67109064", @"67109066", @"67109067", @"67109069", @"67109077", @"67109078", @"67109079", @"67109080", @"67109081"];
    
    if ([arr_1 containsObject:errorCode])
    {
        desc = [NSString stringWithFormat:@"%@失败，请稍后再试", text];
    }
    else if ([arr_2 containsObject:errorCode])
    {
        desc = [NSString stringWithFormat:@"%@失败，请联系管理员", text];
    }
    else if ([errorCode isEqualToString:@"67109096"])
    {
        desc = [NSString stringWithFormat:@"您的个人会议ID已被预约或正在召开会议，%@失败", text];
    }
    else if ([errorCode isEqualToString:@"67108876"])
    {
        desc = @"鉴权失败，请重新登录";
    }
    else if ([errorCode isEqualToString:@"50331749"])
    {
        desc = @"入会失败，请稍后重试";
    }
    else if ([errorCode isEqualToString:@"67108873"])
    {
        desc = @"网络异常，创建会议失败";
    }
    
    [MBProgressHUD showBottom:desc icon:nil view:nil];
    SessionManager.shared.isMeetingVMR = NO;
    SessionManager.shared.isBeInvitation = NO;
    SessionManager.shared.isSelfPlayCurrentMeeting = NO;
    SessionManager.shared.isJoinImmediately = NO;
}

@end
