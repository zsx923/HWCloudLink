//
//  ContactInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface ContactInfo : NSObject

@property (nonatomic ,copy)NSString *staffAccount;      // the uc account
@property (nonatomic ,copy)NSString *personName;        // the person's name
@property (nonatomic ,copy)NSString *deptName;          // the person's department name
@property (nonatomic ,copy)NSString *mobile;            // the person's cellphone
@property (nonatomic ,copy)NSString *email;             // the person's email
@property (nonatomic ,copy)NSString *officePhone;       // the person's seat phone
@property (nonatomic ,copy)NSString *gender;            // the person's gender
@property (nonatomic ,copy)NSString *fax;               // the person's fax
@property (nonatomic ,copy)NSString *corpName;          // the person's corpName
@property (nonatomic ,copy)NSString *webSite;           // the person's webSite


/**
 This method is used to transform TSDK_S_CONTACTS_INFO data to ContactInfo data

 @param info TSDK_S_CONTACTS_INFO
 @return ContactInfo
 */
//+ (ContactInfo *)contactInfoTransformFrom:(TSDK_S_CONTACTS_INFO)info;

@end
