//
//  HWMeetingHandler.m
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/20.
//  Copyright © 2021 jd.com. All rights reserved.
//

#import "HWMeetingHandler.h"
#import "HWCloudLinkEngine.h"
#import "HWCreateMeetingController.h"

#import "ServiceManager.h"

@implementation HWMeetingHandler


+ (void)initOnlineMeeting:(UINavigationController *)rootVC
{
    HWCloudLinkEngine *engine = [HWCloudLinkEngine sharedInstance];
    engine.mainController = rootVC;
    [engine initTSDK];
}

// 华为CloudLinkSDK登录
+ (void)login
{

}

// 华为CloudLinkSDK登出
+ (void)logout
{
    
}

// 创建会议
+ (void)createMeetingWithUsers:(NSArray *)userList owner:(NSDictionary *)owner title:(NSString *)title
keywords:(NSString *)keywords meetingType:(NSInteger)meetingType
{
    HWCloudLinkEngine *engine = [HWCloudLinkEngine sharedInstance];
    HWCreateMeetingController *vc = [HWCreateMeetingController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [engine.mainController presentViewController:vc animated:YES completion:^{}];
}

// 加入会议
+ (void)joinMeetingWithMessageInfo:(NSDictionary *)messageInfo
{
    

}

+ (void)joinAppointMeeting:(NSString *_Nonnull)meetingId password:(NSString *_Nullable)pwd meetingType:(NSInteger)meetingType
{

}

// 点对点呼叫
+ (void)callUser:(NSDictionary *)user from:(NSDictionary *)from
{
   
}

@end
