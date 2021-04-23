//
//  LdapContactInfo.h
//  HWCloudLink
//
//  Created by Tory on 2020/3/26.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsdk_ldap_frontstage_def.h"
#import "Defines.h"
#include "tsdk_conference_def.h"

/**
 *This enum is about confctrl attendee type enum
 *与会者类型枚举值
 */
typedef NS_ENUM(NSUInteger, CONFCTRL_ATTENDEE_TYPE) {
    ATTENDEE_TYPE_NORMAL,
    ATTENDEE_TYPE_TELEPRESENCE,
    ATTENDEE_TYPE_SINGLE_CISCO_TP,
    ATTENDEE_TYPE_THREE_CISCO_TP,
    ATTENDEE_TYPE_H323
};

@interface LdapContactInfo : NSObject

/*
 SMC2.0
 */
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *number;
//@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *sms;
@property (nonatomic, strong) NSString *organizationName;
//@property (nonatomic, strong) NSString *uri;
@property (nonatomic, assign) BOOL is_mute;
//@property (nonatomic, assign) NSInteger rate;

@property (nonatomic, assign) CONFCTRL_CONF_ROLE role;
@property (nonatomic, assign) CONFCTRL_ATTENDEE_TYPE type;
@property (nonatomic, assign) TSDK_E_CONFERENCE_ATTENDEE_TYPE conferenceAttendeesType;

//Have join the conference property
@property (nonatomic, copy) NSString *participant_id;

/*
 SMC3.0
 */
// 联系人id
@property (nonatomic ,copy) NSString *id;
// SIP URI
@property (nonatomic ,copy) NSString *uri;
// 终端号
@property (nonatomic ,copy) NSString *ucAcc;
// 工号
@property (nonatomic ,copy) NSString *staffNo;
// 姓名
@property (nonatomic ,copy) NSString *name;
// 登录账号
@property (nonatomic ,copy) NSString *userName;
// 昵称(为兼容之前代码，暂时等于userName)
@property (nonatomic ,copy) NSString *nickName;
// 名字拼音全拼
@property (nonatomic ,copy) NSString *qpinyin;
// 名字首字母拼音
@property (nonatomic ,copy) NSString *spinyin;
// 家庭电话
@property (nonatomic ,copy) NSString *homePhone;
// 办公电话
@property (nonatomic ,copy) NSString *officePhone;
// 手机号码
@property (nonatomic ,copy) NSString *mobile;
// 其他号码
@property (nonatomic ,copy) NSString *otherPhone;
// 住址
@property (nonatomic ,copy) NSString *address;
// 电子邮箱
@property (nonatomic ,copy) NSString *email;
// 职责
@property (nonatomic ,copy) NSString *duty;
// 传真
@property (nonatomic ,copy) NSString *fax;
// 联系人类型
@property (nonatomic ,copy) NSString *gender;
//  企业名称
@property (nonatomic ,copy) NSString *corpName;
// 部门名称
@property (nonatomic ,copy) NSString *deptName;
// 个人网站
@property (nonatomic ,copy) NSString *webSite;
// 描述
@property (nonatomic ,copy) NSString *desc;
// zip
@property (nonatomic ,copy) NSString *zip;
// 签名
@property (nonatomic ,copy) NSString *signature;
// 头像图片id
@property (nonatomic ,copy) NSString *imageID;

@property (nonatomic ,copy) NSString *position;

@property (nonatomic ,copy) NSString *location;
// 联系人所在时区
@property (nonatomic ,copy) NSString *tzone;
// avaliable device (mic/speaker/camera)
@property (nonatomic ,copy) NSString *avtool;
// 联系人设备类型
@property (nonatomic ,copy) NSString *device;
// 联系人类型
@property (nonatomic ,copy) NSString *terminalType;
// 联系人在群组中的状态
@property (nonatomic) unsigned long *flow;
// 会议id
@property (nonatomic ,copy) NSString *confid;
// 接入码
@property (nonatomic ,copy) NSString *accessNum;
// 主席密码
@property (nonatomic ,copy) NSString *chairPwd;
// 搜索关键字
@property (nonatomic ,copy) NSString *searchWord;
// vmr号码
@property (nonatomic ,copy) NSString *vmrIdentityNumber;
// 带宽
@property (nonatomic ,copy) NSString *tpSpeed;
// 与会者类型
@property (nonatomic ,copy) NSString *attendeeType;
// 是否选中
@property (nonatomic ,assign) BOOL isSelected;
// 是否不可点击
@property (nonatomic ,assign) BOOL isSelf;

+ (LdapContactInfo *)ldapContactInfoTransformFrom:(TSDK_S_LDAP_CONTACT)contactInfo;

+ (NSString *)getDeptName:(NSString *)corpName;

@end
