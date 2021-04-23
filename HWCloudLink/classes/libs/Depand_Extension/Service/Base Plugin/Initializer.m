//
//  Initializer.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "Initializer.h"
#import "tsdk_def.h"
#import "tsdk_manager_def.h"
#import "tsdk_manager_interface.h"
#import "CommonUtils.h"
#import "ImageRGBHelper.h"

#import "securec.h"
#import "ManagerService.h"
#import "tsdk_call_interface.h"
#import "LoginCenter.h"
#import "SynchGroupDataSer.h"
#import "Logger.h"
 
static id<TupLoginNotification> g_loginDelegate = nil;        // login delegate
static id<TupCallNotifacation> g_callDelegate = nil;          // call delegate
static id<TupConfNotifacation> g_confDelegate = nil;          // conference delegate
static id<ContactNotification> g_contactDelegate = nil;    // contact delegate
static SynchGroupDataSer * synchGtoupDataTool = nil;
/**
 * tup_login_register_process_notifiy的接口参数回调LOGIN_FN_CALLBACK_PTR
 */
TSDK_VOID onTSDKNotifications(TSDK_UINT32 msgid, TSDK_UINT32 param1, TSDK_UINT32 param2, TSDK_VOID *data)
{
    DDLogInfo(@"onTUPLoginNotifications : %d",msgid);
    Notification *notification = [[Notification alloc] initWithMsgId:msgid param1:param1 param2:param2 data:data];
    if(msgid >1000 && msgid < 2000){
        [g_loginDelegate loginModule:LOGIN_UPORTAL_MODULE notification:notification];
    }
    if(msgid > 2000 && msgid <3000){
         [g_callDelegate callModule:CALL_SIP_MODULE notication:notification];
    }
    if(msgid > 3000 && msgid < 4000){
        [g_confDelegate confModule:CONF_MODULE notication:notification];
    }
    if(msgid > 4000 && msgid < 5000){
        [g_callDelegate callModule:CALL_CTD_MODULE notication:notification];
    }
    if(msgid > 5000 && msgid < 6000){
        [g_contactDelegate contactModule:CONTACT_MODULE notification:notification];
    }
    if(msgid > 7000 && msgid < 8000){
        [g_contactDelegate contactModule:CONTACT_MODULE notification:notification];
    }
}



TSDK_LONG ios_wrapper_capture_screen(TSDK_VOID* buffer, TSDK_LONG* pWidth, TSDK_LONG* pHeight)
{
    
    if(synchGtoupDataTool == nil) {
        synchGtoupDataTool = [SynchGroupDataSer shareInstance];
    }
    
    return  [synchGtoupDataTool airClientScreenDataCallback:buffer Width:pWidth Height:pHeight];
    return 0;
}



@implementation Initializer

/**
 * This method is used to register login call back.
 * 设置登陆模块的代理
 *@param loginDelegate TupLoginNotification
 */
+ (void)registerLoginCallBack:(id<TupLoginNotification>)loginDelegate
{
    g_loginDelegate = loginDelegate;
}

/**
 * This method is used to register call call back.
 * 设置呼叫模块的代理
 *@param callDelegate TupCallNotifacation
 */
+ (void)registerCallCallBack:(id<TupCallNotifacation>)callDelegate
{
    g_callDelegate = callDelegate;
}

/**
 * This method is used to register conference call back.
 * 设置会议模块的代理
 *@param confDelegate TupConfNotifacation
 */
+ (void)registerConfCallBack:(id<TupConfNotifacation>)confDelegate
{
    g_confDelegate = confDelegate;
}

/**
 * This method is used to register contact call back.
 * 设置联系人模块的代理
 *@param contactDelegate ContactNotification
 */
+ (void)registerContactCallBack:(id<ContactNotification>)contactDelegate
{
    g_contactDelegate = contactDelegate;
}

/**
 *This method is used to init all tsdk service
 *初始化各个tsdk模块业务
 *@param logPath log path
 */
+ (BOOL)startupWithLogPath:(NSString *)logPath
{
    
    TSDK_S_LOG_PARAM logParam;
    memset_s(&logParam, sizeof(TSDK_S_LOG_PARAM), 0, sizeof(TSDK_S_LOG_PARAM));
    NSString *path = [logPath stringByAppendingString:@"/tsdk"];
    logParam.level = TSDK_E_LOG_DEBUG;
    logParam.file_count = 4;
    logParam.max_size_kb = 4*1024;
    strcpy_s(logParam.path, sizeof(logParam.path), [path UTF8String]);
    TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOG_PARAM, &logParam);
    DDLogInfo(@"config log param result: %d",configResult);
    
    TSDK_BOOL conf_send_data_switch = TSDK_FALSE;
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_DATA_CONF_SEND_DATA_SWITCH, &conf_send_data_switch);
    DDLogInfo(@"TSDK_E_CONFIG_DATA_CONF_SEND_DATA_SWITCH: %d", configResult);
    
    TSDK_S_APP_INFO_PARAM app_info;
    memset_s(&app_info, sizeof(TSDK_S_APP_INFO_PARAM), 0, sizeof(TSDK_S_APP_INFO_PARAM));
    app_info.client_type = TSDK_E_CLIENT_MOBILE;
    
    strcpy_s(app_info.product_name, sizeof(app_info.product_name), "Huawei TE Mobile");

    app_info.use_ui_plugin = TSDK_FALSE;
    app_info.support_audio_and_video_call = TSDK_TRUE;
    app_info.support_audio_and_video_conf = TSDK_TRUE;
    app_info.support_data_conf = TSDK_FALSE;
    app_info.support_ldap_frontstage = TSDK_TRUE;
    app_info.is_close_security_channel = TSDK_FALSE;
    TSDK_RESULT result = tsdk_init(&app_info ,&onTSDKNotifications);
    DDLogInfo(@"tsdk_init result: %d", result);
    
    result = tsdk_set_capture_callback(ios_wrapper_capture_screen);
    DDLogInfo(@"tsdk_set_capture_callback result: %d", result);
//    NSString *ipAddressStr = [RequestIPAddress getIPAddress:YES];

//
    
   
    
    return result;
}

@end
