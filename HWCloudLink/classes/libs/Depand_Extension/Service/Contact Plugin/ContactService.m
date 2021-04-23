//
//  ContactService.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "Initializer.h"
#import "ContactService.h"
#import "LoginServerInfo.h"
#import "SearchParam.h"
//#import "SearchResultInfo.h"
#import "DeptInfo.h"
#import "ContactInfo.h"
#import "LdapContactInfo.h"
#import "tsdk_ldap_frontstage_def.h"
#import "tsdk_ldap_frontstage_interface.h"

#import <UIKit/UIKit.h>
#import "ManagerService.h"
#import "LoginInfo.h"
#import "tsdk_error_def.h"
#include <string.h>
#import "Logger.h"
#import "NSString+CZFTools.h"

#define SIZE52 CGSizeMake(52, 52)
#define SIZE120 CGSizeMake(120, 120)
#define SIZE320 CGSizeMake(320, 320)

#define ICON_PATH [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/TUPC60log/contact/icon"]

NSString *const TUP_CONTACT_EVENT_RESULT_KEY        = @"TUP_CONTACT_EVENT_RESULT_KEY";
NSString *const TUP_CONTACT_KEY                     = @"TUP_CONTACT_KEY";
NSString *const TUP_DEPARTMENT_KEY                  = @"TUP_DEPARTMENT_KEY";
NSString *const TUP_DEPARTMENT_RESULT_KEY           = @"TUP_DEPARTMENT_RESULT_KEY";
NSString *const TUP_CONTACT_HEADERIMG_KEY           = @"TUP_CONTACT_HEADERIMG_KEY";
NSString *const TUP_SYS_ICON_ID_KEY                 = @"TUP_SYS_ICON_ID_KEY";
NSString *const TUP_ICON_FILE_KEY                   = @"TUP_ICON_FILE_KEY";
NSString *const COOKIE_LEN                          = @"COOKIE_LEN";
NSString *const PAGE_COOKIE                         = @"PAGE_COOKIE";

@interface ContactService ()<ContactNotification>

@property (nonatomic, copy) NSData *pageCookie;
@property (nonatomic,assign) TSDK_UINT32 cookieLength;

@end

@implementation ContactService
@synthesize delegate = _delegate;
@synthesize curentBaseDn = _curentBaseDn;


/**
 * This method is used to init this class
 * 初始化该类
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 设置联系人回调的delegate
        [Initializer registerContactCallBack:self];
    }
    return self;
}

/**
 * This method is used to deel contact event callback from service
 * 分发联系人业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)contactModule:(TUP_MODULE)module notification:(Notification *)notification {
    
    if (CONTACT_MODULE == module) {
        switch (notification.msgId) {
/*
                // 联系人搜索结果
            case TSDK_E_EADDR_EVT_SEARCH_CONTACTS_RESULT: 
			{
                DDLogInfo(@"TSDK_E_EADDR_EVT_SEARCH_CONTACTS_RESULT");
                BOOL result = notification.param1 == TSDK_SUCCESS;
                if (!result) {
                    DDLogError(@"TSDK_E_EADDR_EVT_SEARCH_CONTACTS_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notification.data]);
                    return;
                }
                TSDK_S_SEARCH_CONTACTS_RESULT *searchContactorResult = (TSDK_S_SEARCH_CONTACTS_RESULT *)notification.data;
                
                if (searchContactorResult == NULL) {
                    DDLogWarn(@"handleSearchContact result is empty.");
                    return;
                }
                int pageIndex = searchContactorResult->page;
                int totalNum = searchContactorResult->total_num;
                TSDK_S_CONTACTS_INFO *pstContactorInfo = searchContactorResult->contact_info;
                
                //查询配置自己软终端号
                if (notification.param2 == 100) {
                    if (pstContactorInfo != NULL) {
//                        ContactInfo *contactInfo = [ContactInfo contactInfoTransformFrom:pstContactorInfo[0]];
//                        NSString *accountNumber = contactInfo.terminal;
//                        if (accountNumber.length == 0 || accountNumber == nil) {
//                            accountNumber = contactInfo.terminal2;
//                        }
//                        [[ManagerService callService] configBussinessAccount:accountNumber terminal:contactInfo.terminal2 token:nil];
                        
//                        [eSpaceDBService sharedInstance].localDataManager = [[ESpaceLocalDataManager alloc] initWithUserAccount:contactInfo.staffAccount];
                    }
                    return;
                }

                
                NSMutableArray *contactArray = [[NSMutableArray alloc] init];
                // 搜索到的联系人结果放入联系人数组，传递给界面使用
                for (int i = 0; i< totalNum; i++) {
                    
                    int lastTotal = totalNum - PAGE_ITEM_SIZE*(pageIndex-1);
                    int endIndex = (lastTotal < PAGE_ITEM_SIZE) ? lastTotal : PAGE_ITEM_SIZE ;
                    if (i == endIndex) {
                        NSDictionary *resultInfo = @{TUP_CONTACT_EVENT_RESULT_KEY : [NSNumber numberWithBool:result],
                                                     TUP_CONTACT_KEY:contactArray};
                        [self respondsContactDelegateWithType:CONTACT_E_SEARCH_CONTACT_RESULT result:resultInfo];
                        return;
                    }
//                    ContactInfo *contactInfo = [ContactInfo contactInfoTransformFrom:pstContactorInfo[i]];
//                    DDLogInfo(@"contactInfo.personName: %@",contactInfo.personName);
//                    [contactArray addObject:contactInfo];
                }
                NSDictionary *resultInfo = @{TUP_CONTACT_EVENT_RESULT_KEY : [NSNumber numberWithBool:result],
                                             TUP_CONTACT_KEY:contactArray};
                [self respondsContactDelegateWithType:CONTACT_E_SEARCH_CONTACT_RESULT result:resultInfo];
            }
                break;
                // 联系人头像搜索结果
            case TSDK_E_EADDR_EVT_GET_ICON_RESULT: {
                DDLogInfo(@"TSDK_E_EADDR_EVT_GET_ICON_RESULT");
//                BOOL result = notification.param1 == TSDK_SUCCESS;
//                if (!result) {
//                    DDLogError(@"TSDK_E_EADDR_EVT_GET_ICON_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notification.data]);
//                    return;
//                }
//
//                TSDK_S_GET_ICON_RESULT *getIconResult = (TSDK_S_GET_ICON_RESULT *)notification.data;
//                int sysIconID = getIconResult->icon_id;
//                NSString *acIconFile = [NSString stringWithUTF8String:getIconResult->icon_path];
//
//                NSDictionary *resultInfo = @{TUP_CONTACT_EVENT_RESULT_KEY : [NSNumber numberWithBool:result],
//                                             TUP_SYS_ICON_ID_KEY : [NSString stringWithFormat:@"%d", sysIconID],
//                                             TUP_ICON_FILE_KEY : [NSString stringWithFormat:@"%@%@", ICON_PATH, acIconFile]};
//                [self respondsContactDelegateWithType:CONTACT_E_SEARCH_GET_ICON_RESULT result:resultInfo];
            }
                break;
                // 联系人部门搜索结果
            case TSDK_E_EADDR_EVT_SEARCH_DEPT_RESULT: {
//                DDLogInfo(@"TSDK_E_EADDR_EVT_SEARCH_DEPT_RESULT");
//                BOOL result = notification.param1 == TSDK_SUCCESS;
//                if (!result) {
//                    DDLogError(@"TSDK_E_EADDR_EVT_SEARCH_DEPT_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notification.data]);
//                    return;
//                }
//
//                TSDK_S_SEARCH_DEPARTMENT_RESULT *searchDeptResult = (TSDK_S_SEARCH_DEPARTMENT_RESULT *)notification.data;
//                SearchResultInfo *info = [SearchResultInfo resultInfoTransformFrom:searchDeptResult];
//                TSDK_S_DEPARTMENT_INFO* pstDeptInfo = searchDeptResult->department_info;
//                int itemNum = searchDeptResult->item_num;
//
//                NSMutableArray *deptArray = [[NSMutableArray alloc] init];
//                // 部门搜索结果放入部门数组，传递给界面使用
//                for (int i = 0; i<itemNum; i++) {
//                    TSDK_S_DEPARTMENT_INFO tsdkDeptInfo = pstDeptInfo[i];
//                    DeptInfo *detpInfo = [DeptInfo deptInfoTransformFrom:tsdkDeptInfo];
//                    DDLogInfo(@"Search department result: deptID:(%@) dept name(%@) parentID(%@)", detpInfo.deptId, detpInfo.deptName, detpInfo.parentId);
//                    [deptArray addObject:detpInfo];
//                }
//
//                NSDictionary *resultInfo = @{TUP_CONTACT_EVENT_RESULT_KEY : [NSNumber numberWithBool:result],
//                                             TUP_DEPARTMENT_KEY : deptArray,
//                                             TUP_DEPARTMENT_RESULT_KEY : info };
//                [self respondsContactDelegateWithType:CONTACT_E_SEARCH_DEPARTMENT_RESULT result:resultInfo];
            }
                break;
*/
            // 企业地址本搜索结果
            case TSDK_E_LDAP_FRONTSTAGE_EVT_SEARCH_RESULT: {
                DDLogInfo(@"TSDK_E_LDAP_FRONTSTAGE_EVT_SEARCH_RESULT");
                BOOL result = notification.param1 == TSDK_SUCCESS;
                TSDK_S_LDAP_SEARCH_RESULT_INFO *searchContactorResult = (TSDK_S_LDAP_SEARCH_RESULT_INFO *)notification.data;
                if (searchContactorResult == NULL) {
                    DDLogWarn(@"TSDK_S_LDAP_SEARCH_RESULT_INFO result is empty.");
                    return;
                }
                if (searchContactorResult->search_result_data == NULL) {
                    DDLogWarn(@"searchContactorResult->search_result_data == NULL.");
                    NSDictionary *resultInfo = @{
                        TUP_CONTACT_EVENT_RESULT_KEY: [NSNumber numberWithBool:result],
                        TUP_CONTACT_KEY: [[NSMutableArray alloc] init],
                        COOKIE_LEN: [NSNumber numberWithInt:searchContactorResult->cookie_len],
                        PAGE_COOKIE: [NSData dataWithBytes:searchContactorResult->page_cookie length:searchContactorResult->cookie_len]
                    };
                    [self respondsContactDelegateWithType:CONTACT_E_SEARCH_LDAP_CONTACT_RESULT result:resultInfo];
                    return;
                }
                TSDK_S_LDAP_SEARCH_RESULT_DATA *resultData = searchContactorResult->search_result_data;
                //int pageIndex = searchContactorResult->page;
                int totalNum = resultData->current_count;
                TSDK_S_LDAP_CONTACT *pstContactorInfo = resultData->contact_list;
//                        //查询配置自己软终端号
//                        if (notification.param2 == 100) {
//                            if (pstContactorInfo != NULL) {
//        //                        ContactInfo *contactInfo = [ContactInfo contactInfoTransformFrom:pstContactorInfo[0]];
//        //                        NSString *accountNumber = contactInfo.terminal;
//        //                        if (accountNumber.length == 0 || accountNumber == nil) {
//        //                            accountNumber = contactInfo.terminal2;
//        //                        }
//        //                        [[ManagerService callService] configBussinessAccount:accountNumber terminal:contactInfo.terminal2 token:nil];
//        //                        [eSpaceDBService sharedInstance].localDataManager = [[ESpaceLocalDataManager alloc] initWithUserAccount:contactInfo.staffAccount];
//                            }
//                            return;
//                        }

                NSMutableArray *contactArray = [[NSMutableArray alloc] init];
                // 搜索到的联系人结果放入联系人数组，传递给界面使用
                for (int i = 0; i< totalNum; i++) {
//                            int lastTotal = totalNum - PAGE_ITEM_SIZE*(pageIndex-1);
//                            int endIndex = (lastTotal < PAGE_ITEM_SIZE) ? lastTotal : PAGE_ITEM_SIZE ;
//                            if (i == endIndex) {
//                                NSDictionary *resultInfo = @{TUP_CONTACT_EVENT_RESULT_KEY : [NSNumber numberWithBool:result],
//                                                             TUP_CONTACT_KEY:contactArray};
//                                [self respondsContactDelegateWithType:CONTACT_E_SEARCH_LDAP_CONTACT_RESULT result:resultInfo];
//                                return;
//                            }
                    LdapContactInfo *contactInfo = [LdapContactInfo ldapContactInfoTransformFrom:pstContactorInfo[i]];
                    DDLogInfo(@"contactInfo.personName: %@",[NSString encryptNumberWithString:contactInfo.name]);
                    [contactArray addObject:contactInfo];
                }
                NSDictionary *resultInfo = @{
                    TUP_CONTACT_EVENT_RESULT_KEY : [NSNumber numberWithBool:result],
                    TUP_CONTACT_KEY: contactArray,
                    COOKIE_LEN: [NSNumber numberWithInt:searchContactorResult->cookie_len],
                    PAGE_COOKIE: [NSData dataWithBytes:searchContactorResult->page_cookie length:searchContactorResult->cookie_len]
                };
                [self respondsContactDelegateWithType:CONTACT_E_SEARCH_LDAP_CONTACT_RESULT result:resultInfo];
//                        free(pstContactorInfo);
//                        free(resultData);
//                        free(searchContactorResult);
            }
//                [self ldapGetSearchListResult:notification];
                break;
            default:
                break;
        }
    }
     
}

/**
 * This method is used to deel contact event callback from service to UI
 * 分发联系人业务相关回调到界面
 *@param type TUP_CONTACT_EVENT_TYPE
 *@param resultDictionary NSDictionary
 */
-(void)respondsContactDelegateWithType:(TUP_CONTACT_EVENT_TYPE)type result:(NSDictionary *)resultDictionary {
    if ([self.delegate respondsToSelector:@selector(contactEventCallback:result:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate contactEventCallback:type result:resultDictionary];
        });
    }
}

/**
 * This method is used to set system head image (0~9) (if completionBlock result is YES, set self head ID with sysIconID)
 * 设置系统头像
 */
-(void)ldapGetSearchListResult:(Notification *)notify
{
    TSDK_S_LDAP_SEARCH_RESULT_INFO *searchContactInfo = (TSDK_S_LDAP_SEARCH_RESULT_INFO*)notify.data;
    BOOL result = searchContactInfo->is_success;
    if (!result) {
        DDLogError(@"TSDK_E_LDAP_FRONTSTAGE_EVT_SEARCH_RESULT,error:%d",searchContactInfo->result_code);
        return;
    }
    if (searchContactInfo->cookie_len) {
        _pageCookie = [NSData dataWithBytes:searchContactInfo->page_cookie length:searchContactInfo->cookie_len];
        _cookieLength = searchContactInfo->cookie_len;
    }
    DDLogInfo(@"confListInfoResult->current_count----- :%d",searchContactInfo->search_result_data->current_count);
    TSDK_S_LDAP_CONTACT *contactList = searchContactInfo->search_result_data->contact_list;
    NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    NSMutableArray *deptArray = [NSMutableArray array];
    for (int i = 0; i< searchContactInfo->search_result_data->current_count; i++)
    {
        ContactInfo *contactInfo = [[ContactInfo alloc] init];
        
        contactInfo.personName = [NSString stringWithUTF8String:contactList[i].name_];
        contactInfo.staffAccount = [NSString stringWithUTF8String:contactList[i].ucAcc_];
        contactInfo.deptName = [NSString stringWithUTF8String:contactList[i].deptName_];
        contactInfo.mobile = [NSString stringWithUTF8String:contactList[i].mobile_];
        contactInfo.email = [NSString stringWithUTF8String:contactList[i].email_];
        contactInfo.officePhone = [NSString stringWithUTF8String:contactList[i].officePhone_];
        contactInfo.gender = [NSString stringWithUTF8String:contactList[i].gender_];
        
        contactInfo.fax = [NSString stringWithUTF8String:contactList[i].fax_];
        contactInfo.corpName = [NSString stringWithUTF8String:contactList[i].corpName_];
        contactInfo.webSite = [NSString stringWithUTF8String:contactList[i].webSite_];//id
        DDLogInfo(@"contactInfo.personName: %@,%@",[NSString encryptNumberWithString:contactInfo.personName],[NSString encryptNumberWithString:contactInfo.deptName]);
        if (contactInfo.personName.length==0 && contactInfo.deptName.length > 0) {
            DeptInfo *deptInfo = [[DeptInfo alloc]init];
            deptInfo.deptName = [NSString stringWithString:contactInfo.deptName];
            deptInfo.parentId = [NSString stringWithString:contactInfo.corpName];
            deptInfo.isSelected = NO;
            deptInfo.expand = NO;
            [deptArray addObject:deptInfo];
        }else{
            [contactArray addObject:contactInfo];
        }
        
    }
    NSDictionary *resultInfo = @{TUP_CONTACT_EVENT_RESULT_KEY : [NSNumber numberWithBool:((searchContactInfo->cookie_len > 0) ? YES:NO)],
                                 TUP_DEPARTMENT_KEY : deptArray,
                                 TUP_CONTACT_KEY:contactArray};
    [self respondsContactDelegateWithType:CONTACT_E_SEARCH_CONTACT_RESULT result:resultInfo];
}

- (void)setSystemHead:(int)sysIconID withCmpletion:(void(^)(BOOL result))completionBlock {
//    TSDK_RESULT set_sys_result = tsdk_set_system_icon((TSDK_UINT32)sysIconID);
//    BOOL result = set_sys_result == TSDK_SUCCESS;
//    if (completionBlock) {
//        completionBlock(result);
//    }
//    if (result) {
//        [self setHeadID:[NSString stringWithFormat:@"%d", sysIconID]];
    }
/**
 * headId's set method
 * 头像Id 的set方法
 *@param headId NSString
 */
- (void)setHeadID:(NSString *)headId {
//    EmployeeEntity *selfEntity = LOCAL_DATA_MANAGER.currentUser;
//    selfEntity.headId = headId;
}

/**
 * This method is used to set custom head image (if completionBlock result is YES, set self hedID with headID)
 * 设置自定义头像
 *@param image                     Indicates custom image
 *                                 自定义头像
 *@param completionBlock           Indicates callback(result: set head image result. YES or NO)
 *                                 回调，返回设置头像成功与否
 */
- (void)setHeadImage:(UIImage *)image completion:(void(^)(BOOL result, NSString *headID))completionBlock {
    //自定义头像接口需要上传三种尺寸的图片：52x52   120x120   320x320 
//    NSData *minImg = [self imgWithSize:SIZE52 image:image];
//    NSData *midImg = [self imgWithSize:SIZE120 image:image];
//    NSData *maxImg = [self imgWithSize:SIZE320 image:image];
//    NSString *path = NSTemporaryDirectory();
//    NSString *iconPathMinImg = [path stringByAppendingPathComponent:@"minImg"];
//    NSString *iconPathMidImg = [path stringByAppendingPathComponent:@"midImg"];
//    NSString *iconPathMaxImg = [path stringByAppendingPathComponent:@"maxImg"];
//    [minImg writeToFile:iconPathMinImg atomically:YES];
//    [midImg writeToFile:iconPathMidImg atomically:YES];
//    [maxImg writeToFile:iconPathMaxImg atomically:YES];
//
//    TSDK_S_ICON_INFO* icon_info = (TSDK_S_ICON_INFO*)malloc(sizeof(TSDK_S_ICON_INFO));
//    memset(icon_info, 0, sizeof(TSDK_S_ICON_INFO));
//    strcpy(icon_info->small_icon_path, [iconPathMinImg UTF8String]);
//    strcpy(icon_info->medium_icon_path, [iconPathMidImg UTF8String]);
//    strcpy(icon_info->large_icon_path, [iconPathMaxImg UTF8String]);
//
//    TSDK_CHAR *modifyTime = (TSDK_CHAR *)malloc(16);
//    memset_s(modifyTime, 16, 0, 16);
//    TSDK_UINT32 length = 16;
//
//    TSDK_RESULT ret_set_def = tsdk_set_user_def_icon(icon_info, modifyTime, &length);
//    free(icon_info);
//    // 出参modifyTime时间戳，作为联系人headId
//    NSString *mTime = [NSString stringWithUTF8String:modifyTime];
//    DDLogInfo(@"set image ret: %d modify time: %@", length, mTime);
//    BOOL result = ret_set_def == TSDK_SUCCESS;
//    if (completionBlock) {
//        completionBlock(result, mTime);
//    }
//    if (result) {
//        [self setHeadID:mTime];
//    }
    
}

/**
 * This method is used to draw image to a needed size
 * 压缩图片图片至给定大小
 *@param size  CGSize
 *@param image UIImage
 */
- (NSData *)imgWithSize:(CGSize)size image:(UIImage *)image {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(newImage);
}

- (void)searchContactsToConfigSelfTerminalNum {
//    LoginInfo *mine = [[ManagerService loginService] obtainCurrentLoginInfo];
//    SearchParam *searchParam = [[SearchParam alloc] init];
//    searchParam.acSearchItem = mine.account;
//    searchParam.ulPageIndex = 1;
//    searchParam.ulExactSearch = 0;
//    searchParam.ulSeqNo = 100;
//    [self searchContactWithParam:searchParam];

//	LoginInfo *mine = [[ManagerService loginService] obtainCurrentLoginInfo];
    SearchParam *searchParam = [[SearchParam alloc] init];
//    searchParam.acSearchItem = mine.account;
//    searchParam.ulPageIndex = 1;
//    searchParam.ulExactSearch = 0;
//    searchParam.ulSeqNo = 100;
    [self searchContactWithParam:searchParam];
}

/**
 * This method is used to search corporate directory contacts
 * 搜索联系人信息
 *@param searchParam               Indicates search param, see SearchParam value (Search conditions)
 *                                 用于搜索联系人的参数
 */
- (void)searchContactWithParam:(SearchParam *)searchParam {
//    TSDK_S_SEARCH_CONTACTS_PARAM *tsdkSearchParam = (TSDK_S_SEARCH_CONTACTS_PARAM *)malloc(sizeof(TSDK_S_SEARCH_CONTACTS_PARAM));
//    memset(tsdkSearchParam, 0, sizeof(TSDK_S_SEARCH_CONTACTS_PARAM));
//    if (searchParam.acSearchItem.length > 0 && searchParam.acSearchItem != nil) {
//        strcpy(tsdkSearchParam->search_keyword, [searchParam.acSearchItem UTF8String]);
//    }
//    tsdkSearchParam->page_index = searchParam.ulPageIndex;
//    tsdkSearchParam->is_exact_search = searchParam.ulExactSearch;
//    
//    if (searchParam.acDepId.length > 0 && searchParam.acDepId != nil && ![searchParam.acDepId isEqualToString:@"-1"])
//    {
//        strcpy(tsdkSearchParam->department_id, [searchParam.acDepId UTF8String]);
//    }
//    tsdkSearchParam->seq_no = searchParam.ulSeqNo;
    
//    TSDK_RESULT result = tsdk_search_contacts(tsdkSearchParam);
//    DDLogInfo(@"tsdk_search_contacts result: %d",result);
//    free(tsdkSearchParam);
}

/**
 * This method is used to search corporate directory contacts
 * 搜索联系人信息
 *@param searchParam               Indicates search param, see SearchParam value (Search conditions)
 *                                 用于搜索联系人的参数
 */
- (void)searchLdapWithParam:(SearchParam *)searchParam{
    TSDK_S_SEARCH_CONDITION *tsdkSearchParam = (TSDK_S_SEARCH_CONDITION *)malloc(sizeof(TSDK_S_SEARCH_CONDITION));
    memset_s(tsdkSearchParam, sizeof(TSDK_S_SEARCH_CONDITION), 0, sizeof(TSDK_S_SEARCH_CONDITION));
       //xjc 注释掉
//    if (searchParam.acSearchItem.length > 0 && searchParam.acSearchItem != nil) {
//        tsdkSearchParam->keywords = (TSDK_CHAR*)[searchParam.acSearchItem UTF8String];
//    }else{
        tsdkSearchParam->keywords = (TSDK_CHAR*)[@"*" UTF8String];
//    }
    tsdkSearchParam->curent_base_dn = (TSDK_CHAR*)[_curentBaseDn UTF8String];
//    tsdkSearchParam->sort_attribute = searchParam.ulPageIndex ? (TSDK_CHAR*)[@"quanpin" UTF8String] : (TSDK_CHAR*)[@"ou" UTF8String];
    tsdkSearchParam->search_single_level = [_curentBaseDn isEqualToString: @"dc=Huawei,dc=com"]?0:2;
//    tsdkSearchParam->page_size = searchParam.ulPageIndex;
//    if (searchParam.ulPageIndex && searchParam.ulExactSearch) {
//        tsdkSearchParam->cookie_length = _cookieLength;
//        tsdkSearchParam->page_cookie = (TSDK_CHAR *)[_pageCookie bytes];
//    }else{
        tsdkSearchParam->cookie_length = 0;
        tsdkSearchParam->page_cookie = TSDK_NULL_PTR;
//    }
    TSDK_UINT32 ulseqNo;
    TSDK_RESULT result = tsdk_ldap_search(tsdkSearchParam,&ulseqNo);
    free(tsdkSearchParam);
    DDLogInfo(@"tsdk_ldap_search result: %d",result);
}

- (BOOL)searchLdapContactWithParam:(SearchParam *)searchParam {
    TSDK_S_SEARCH_CONDITION *tsdkSearchParam = (TSDK_S_SEARCH_CONDITION *)malloc(sizeof(TSDK_S_SEARCH_CONDITION));
    memset_s(tsdkSearchParam, sizeof(TSDK_S_SEARCH_CONDITION), 0, sizeof(TSDK_S_SEARCH_CONDITION));

    if (searchParam.keywords != nil && searchParam.keywords.length > 0) {
        size_t length = strlen([searchParam.keywords UTF8String]);
        tsdkSearchParam->keywords = (TSDK_CHAR *)malloc(length+1);
        memset(tsdkSearchParam->keywords, 0, length+1);
        //strcpy(tsdkSearchParam->keywords, [searchParam.keywords UTF8String]);
        memcpy(tsdkSearchParam->keywords, [searchParam.keywords UTF8String], length);
    }
    
    if (searchParam.curentBaseDn != nil && searchParam.curentBaseDn.length > 0) {
        size_t length = strlen([searchParam.curentBaseDn UTF8String]);
        tsdkSearchParam->curent_base_dn = (TSDK_CHAR *)malloc(length+1);
        memset(tsdkSearchParam->curent_base_dn, 0, length+1);
        //strcpy(tsdkSearchParam->curent_base_dn, [searchParam.curentBaseDn UTF8String]);
        memcpy(tsdkSearchParam->curent_base_dn, [searchParam.curentBaseDn UTF8String], length);
    }

//    if ([searchParam.sortAttribute isEqual:@""]) {
        searchParam.sortAttribute = @"";
//    }
    if (searchParam.sortAttribute != nil && searchParam.sortAttribute.length > 0) {
        size_t length = strlen([searchParam.sortAttribute UTF8String]);
        tsdkSearchParam->sort_attribute = (TSDK_CHAR *)malloc(length+1);
        memset(tsdkSearchParam->sort_attribute, 0, length+1);
        //strcpy(tsdkSearchParam->sort_attribute, [searchParam.sortAttribute UTF8String]);
        memcpy(tsdkSearchParam->sort_attribute, [searchParam.sortAttribute UTF8String], length);
    }
    
    tsdkSearchParam->search_single_level = searchParam.searchSingleLevel;
    tsdkSearchParam->page_size = searchParam.pageSize;
    tsdkSearchParam->cookie_length = searchParam.cookieLength;
    
    if (searchParam.pageCookie != nil && searchParam.pageCookie.length > 0) {
        tsdkSearchParam->page_cookie = (TSDK_CHAR *)malloc([searchParam.pageCookie length]);
        memcpy(tsdkSearchParam->page_cookie, (TSDK_CHAR *)[searchParam.pageCookie bytes], [searchParam.pageCookie length]);
    }
    
    TSDK_UINT32 seq_no;
    TSDK_RESULT result = tsdk_ldap_search(tsdkSearchParam,&seq_no);
    
    DDLogInfo(@"tsdk_ldap_search result: %d",result);
    
    // free
    if (tsdkSearchParam->keywords != NULL) {
        free(tsdkSearchParam->keywords);
        tsdkSearchParam->keywords = NULL;
    }
    if (tsdkSearchParam->curent_base_dn != NULL) {
        free(tsdkSearchParam->curent_base_dn);
        tsdkSearchParam->curent_base_dn = NULL;
    }
    if (tsdkSearchParam->sort_attribute != NULL) {
        free(tsdkSearchParam->sort_attribute);
        tsdkSearchParam->sort_attribute = NULL;
    }
    if (tsdkSearchParam->page_cookie != NULL) {
        free(tsdkSearchParam->page_cookie);
        tsdkSearchParam->page_cookie = NULL;
    }
    if (tsdkSearchParam != NULL) {
        free(tsdkSearchParam);
        tsdkSearchParam = NULL;
    }
    
        
//    free(tsdkSearchParam);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to search corporate directory departments list
 * 搜索部门列表
 *@param deptID                    Indicates parent department ID
 *                                 部门id
 */
- (void)searchDeptListWithID:(NSString *)deptID {
//    TSDK_S_SEARCH_DEPARTMENT_PARAM *deptParam = (TSDK_S_SEARCH_DEPARTMENT_PARAM *)malloc(sizeof(TSDK_S_SEARCH_DEPARTMENT_PARAM));
//    memset(deptParam, 0, sizeof(TSDK_S_SEARCH_DEPARTMENT_PARAM));
//    if (deptID.length > 0 && deptID != nil) {
//        strcpy(deptParam->department_id, [deptID UTF8String]);
//    }
//    deptParam->seq_no = rand();
//
//    TSDK_RESULT result = tsdk_search_department(deptParam);
//    DDLogInfo(@"tsdk_search_department result: %d",result);
//    free(deptParam);
}

/**
 * This method is used to load contact head image from corporate directory
 * 加载个人头像
 *@param account                   Indicates user account
 *                                 用户帐号
 */
- (void)loadPersonHeadIconWithAccount:(NSString *)account {
//    TSDK_S_GET_ICON_PARAM *iconParam = (TSDK_S_GET_ICON_PARAM *)malloc(sizeof(TSDK_S_GET_ICON_PARAM));
//    memset(iconParam, 0, sizeof(TSDK_S_GET_ICON_PARAM));
//    if (account.length > 0 && account != nil) {
//        strcpy(iconParam->account, [account UTF8String]);
//    }
//    iconParam->seq_no = rand();
//    TSDK_RESULT result = tsdk_get_user_icon(iconParam);
//    DDLogInfo(@"tsdk_get_user_icon result: %d", result);
//    free(iconParam);
}


@end
