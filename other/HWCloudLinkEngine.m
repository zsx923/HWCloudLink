//
//  HWCloudLinkEngine.m
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/20.
//  Copyright © 2021 jd.com. All rights reserved.
//

#import "HWCloudLinkEngine.h"
#import "ServiceManager.h"
#import "LoginInfo.h"
#import "LoginCenter.h"
#import "ConfBaseInfo.h"
#import "HWCloudLink-Swift.h"

static HWCloudLinkEngine *instance = nil;

@interface HWCloudLinkEngine ()

@end

@implementation HWCloudLinkEngine

+ (instancetype)sharedInstance
{
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[HWCloudLinkEngine alloc] init];
        [instance registerCallbackNotification];
    });
    return instance;
}

- (void)initTSDK
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL init_success = [ServiceManager startup];
        if (init_success == 0)
        {
            NSLog(@"tsdk初始化成功 ~~~~~~~~~~~~~~~~");
//            [instance authLoginTSDK];
        }
        else
        {
            NSLog(@"tsdk初始化失败 ~~~~~~~~~~~~~~~~");
        }
    });
}

- (void)authLoginTSDK
{
    if (![[LoginCenter sharedInstance] isCalibrateCerSuccess])
    {
        NSLog(@"tsdk证书已过期 ~~~~~~~~~~~~~~~~");
        return;
    }
    
    LoginInfo *user = [LoginInfo new];
    user.regServerAddress = @"59.36.11.63";
    user.regServerPort = @"5061";
    user.sipUrl = @"";
    
    user.account = @"zhangyaoqi5";
    user.password = @"Huawei@123";
    
    [[ManagerService loginService] authorizeLoginWithLoginInfo:user loginCompletionBlock:^(BOOL isSuccess, NSError *error) {
        
        if (isSuccess) NSLog(@"tsdk鉴权登录成功 ~~~~~~~~~~~~~~~~");
        else NSLog(@"tsdk鉴权登录失败 ~~~~~~~~~~~~~~~~");
        
    } changePasswordCompletionBlock:^(BOOL isSuccess, NSError *error) {
        
        NSLog(@"tsdk鉴权登录失败 ~~~~~~~~~~~~~~~~");
        
    }];
}

- (void)createMeetingWithSubject:(NSString *)subject password:(NSString *)pwd microEnable:(BOOL)microEnable cameraEnable:(BOOL)cameraEnable
{
    SessionManager.shared.isMeetingVMR = NO;
    SessionManager.shared.isJoinImmediately = YES;
    SessionManager.shared.isCameraOpen = cameraEnable;
    SessionManager.shared.isMicrophoneOpen = microEnable;
    SessionManager.shared.isSelfPlayCurrentMeeting = YES;
    
    NSMutableArray *attendeeArray = [NSMutableArray new];
    LdapContactInfo *contact = [ManagerService callService].ldapContactInfo;
    if (contact)
    {
        [attendeeArray addObject:contact];
    }
    
    if (subject.length < 1) subject = (contact.name ? : @"在线会议");
    if (pwd.length < 1) pwd = @"";
    
    [MBProgressHUD showMessage:@"创建会议中..."];
    EC_CONF_MEDIATYPE type = CONF_MEDIATYPE_VIDEO;
    [[ManagerService confService] vmrBaseInfo].generalPwd = pwd;
    [[ManagerService confService] creatCommonConferenceWithAttendee:attendeeArray mediaType:type subject:subject password:pwd];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)registerCallbackNotification
{
    if ([instance respondsToSelector:@selector(loginServiceNotification)])
    {
        [instance performSelector:@selector(loginServiceNotification)];
    }
    if ([instance respondsToSelector:@selector(conferenceServiceNotification)])
    {
        [instance performSelector:@selector(conferenceServiceNotification)];
    }
    if ([instance respondsToSelector:@selector(callServiceNotification)])
    {
        [instance performSelector:@selector(callServiceNotification)];
    }
}

#pragma clang diagnostic pop


- (void)pushLocalNotif
{

}

@end
