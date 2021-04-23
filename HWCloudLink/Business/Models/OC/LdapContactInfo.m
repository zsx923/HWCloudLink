//
//  LdapContactInfo.m
//  HWCloudLink
//
//  Created by Tory on 2020/3/26.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import "LdapContactInfo.h"

@implementation LdapContactInfo

+ (LdapContactInfo *)ldapContactInfoTransformFrom:(TSDK_S_LDAP_CONTACT)contactInfo{
    LdapContactInfo *info = [[LdapContactInfo alloc] init];
//    info.id    = [NSString stringWithUTF8String:contactInfo.id_];
//    info.uri    = [NSString stringWithUTF8String:contactInfo.uri_];
//    info.staffNo    = [NSString stringWithUTF8String:contactInfo.staffNo_];
//    info.nickName    = [NSString stringWithUTF8String:contactInfo.nickName_];
//    info.qpinyin    = [NSString stringWithUTF8String:contactInfo.qpinyin_];
//    info.spinyin    = [NSString stringWithUTF8String:contactInfo.spinyin_];
//    info.homePhone    = [NSString stringWithUTF8String:contactInfo.homePhone_];
//    info.otherPhone    = [NSString stringWithUTF8String:contactInfo.otherPhone_];
//    info.address    = [NSString stringWithUTF8String:contactInfo.address_];
//    info.duty    = [NSString stringWithUTF8String:contactInfo.duty_];
//    info.desc    = [NSString stringWithUTF8String:contactInfo.desc_];
//    info.zip    = [NSString stringWithUTF8String:contactInfo.zip_];
//    info.signature    = [NSString stringWithUTF8String:contactInfo.signature_];
//    info.imageID    = [NSString stringWithUTF8String:contactInfo.imageID_];
//    info.position    = [NSString stringWithUTF8String:contactInfo.position_];
//    info.location    = [NSString stringWithUTF8String:contactInfo.location_];
//    info.tzone    = [NSString stringWithUTF8String:contactInfo.tzone_];
//    info.avtool    = [NSString stringWithUTF8String:contactInfo.avtool_];
//    info.device    = [NSString stringWithUTF8String:contactInfo.device_];
//    info.terminalType    = [NSString stringWithUTF8String:contactInfo.terminalType_];
//    info.flow    =  (unsigned long)contactInfo.flow_;
//    info.confid    = [NSString stringWithUTF8String:contactInfo.confid_];
//    info.accessNum    = [NSString stringWithUTF8String:contactInfo.accessNum_];
//    info.chairPwd    = [NSString stringWithUTF8String:contactInfo.chair_pwd_];
    
    // xuegd change at 20201211
    /* contactInfo
     ucAcc_    TSDK_CHAR [1200]
     name_    TSDK_CHAR [1200]
     userName    TSDK_CHAR [1200]  // no
     officePhone_    TSDK_CHAR [1200]
     mobile_    TSDK_CHAR [1200]
     email_    TSDK_CHAR [1200]
     fax_    TSDK_CHAR [1200]
     gender_    TSDK_CHAR [1200]
     corpName_    TSDK_CHAR [1200]
     deptName_    TSDK_CHAR [1200]
     webSite_    TSDK_CHAR [1200]
     attendeeType    TSDK_CHAR [1200]
     tpSpeed    TSDK_CHAR [1200]
     vmrIdentityNumber    TSDK_CHAR [1200]
     terminalType
     */

    info.ucAcc = [NSString stringWithUTF8String:contactInfo.ucAcc_];
    info.name = [NSString stringWithUTF8String:contactInfo.name_];
    info.userName = [NSString stringWithUTF8String:contactInfo.userName];
    info.nickName = [NSString stringWithUTF8String:contactInfo.userName];
    info.officePhone = [NSString stringWithUTF8String:contactInfo.officePhone_];
    info.mobile = [NSString stringWithUTF8String:contactInfo.mobile_];
    info.email = [NSString stringWithUTF8String:contactInfo.email_];
    info.fax = [NSString stringWithUTF8String:contactInfo.fax_];
    info.gender = [NSString stringWithUTF8String:contactInfo.gender_];
    info.corpName = [NSString stringWithUTF8String:contactInfo.corpName_];
    info.deptName = [NSString stringWithUTF8String:contactInfo.deptName_];
    info.webSite = [NSString stringWithUTF8String:contactInfo.webSite_];
    info.attendeeType = [NSString stringWithUTF8String:contactInfo.attendeeType];
    info.tpSpeed = [NSString stringWithUTF8String:contactInfo.tpSpeed];
    info.vmrIdentityNumber = [NSString stringWithUTF8String:contactInfo.vmrIdentityNumber];
    info.terminalType = [NSString stringWithUTF8String:contactInfo.terminalType];

    info.isSelected = false;
    return info;
}

+ (NSString *)getDeptName:(NSString *)corpName{
    NSString *deptName = [[NSString alloc] init];
    if (corpName != nil || ![corpName  isEqual: @""]) {
        NSArray *corpNameArr = [corpName componentsSeparatedByString:@","];
        NSMutableArray *corpNameList = [[NSMutableArray alloc] init];
        for(id cName in corpNameArr){
            if ([cName containsString:@"ou="]) {
                [corpNameList addObject:cName];
            }
        }
        for (long i = [corpNameList count] - 1; i > -1; i--){
           deptName = [deptName stringByAppendingString:[corpNameList[i] substringFromIndex:3]];
           deptName = [deptName stringByAppendingString:@" "];
        }
    }
    return deptName;
}
@end

