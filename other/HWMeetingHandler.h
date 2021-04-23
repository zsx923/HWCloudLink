//
//  HWMeetingHandler.h
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/20.
//  Copyright © 2021 jd.com. All rights reserved.
//

#import "JDMeetingBaseHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface HWMeetingHandler : JDMeetingBaseHandler

+ (void)initOnlineMeeting:(UINavigationController *)rootVC;

+ (void)login;

+ (void)logout;

// 创建会议
+ (void)createMeetingWithUsers:(NSArray *)userList owner:(NSDictionary *)owner title:(NSString *)title
                      keywords:(NSString *)keywords meetingType:(NSInteger)meetingType;

// 点对点呼叫
+ (void)callUser:(NSDictionary *)user from:(NSDictionary *)from;

// 加入会议接口
+ (void)joinMeetingWithMessageInfo:(NSDictionary *)messageInfo;

// 加入预约会议
+ (void)joinAppointMeeting:(NSString *_Nonnull)meetingId password:(NSString *_Nullable)pwd meetingType:(NSInteger)meetingType;


@end

NS_ASSUME_NONNULL_END
