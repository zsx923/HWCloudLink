//
//  ConfAttendee.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#include "tsdk_conference_def.h"
#import "Defines.h"
#import "LdapContactInfo.h"


@interface ConfAttendee : NSObject
@property (nonatomic, copy)NSString *account;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *sms;
@property (nonatomic, strong) NSString *organizationName;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, assign) BOOL is_mute;
//@property (nonatomic, assign) NSInteger rate;

@property (nonatomic, assign) CONFCTRL_CONF_ROLE role;
@property (nonatomic, assign) CONFCTRL_ATTENDEE_TYPE type;
@property (nonatomic, assign) TSDK_E_CONFERENCE_ATTENDEE_TYPE conferenceAttendeesType;

//Have join the conference property
@property (nonatomic, copy) NSString *participant_id;


@end
