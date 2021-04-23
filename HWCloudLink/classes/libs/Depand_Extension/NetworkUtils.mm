//
//  NetworkUtils.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "NetworkUtils.h"
#import "CommonUtils.h"
#import "Logger.h"

NSString *const NETWORK_STATUS_CHAGNE_NOTIFY = @"NETWORK_STATUS_CHAGNE_NOTIFY";
NSString *const NETWORK_STATUS_CHAGNE_UI_NOTIFY = @"NETWORK_STATUS_CHAGNE_UI_NOTIFY";

// 存储当前ip
NSString *const SAVE_CURRENT_LOCAL_IP_KEY = @"SAVE_CURRENT_LOCAL_IP_KEY";

@interface NetworkUtils()

@property (nonatomic) Reachability *internetReachability;

@end

@implementation NetworkUtils

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+(instancetype)shareInstance
{
    static NetworkUtils *_networkUtils = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkUtils = [[NetworkUtils alloc] init];
    });
    return _networkUtils;
}

/**
 *This method is used to init this class
 *初始化方法
 */
-(instancetype)init
{
    if (self = [super init])
    {
        [self startUpNetWorkStatusMonitoring];
    }
    return self;
}

/**
 *This method is used to start up network status monitoring
 *开启网络状态监测
 */
-(void)startUpNetWorkStatusMonitoring
{
    //1.监听WiFi之间的切换
     CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),NULL,onNotifyCallback,CFSTR("com.apple.system.config.network_change"),NULL,CFNotificationSuspensionBehaviorDeliverImmediately);

    //2.监听WiFi与4G等其他网络之间的切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
}

static void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)

{
    NSString* notifyName = (__bridge NSString *)name;//(NSString*)name;
    // WiFi之间的切换
    if ([notifyName isEqualToString:@"com.apple.system.config.network_change"]) {
        //判断服务器地址是否 IPV6
        NSArray *serverConfigInfo = [CommonUtils getUserDefaultValueWithKey:SERVER_CONFIG_INFO];
        NSString *address = serverConfigInfo[0];
        BOOL serverAddrIsIPV6 = [CommonUtils isValidateIPv6: address];
        BOOL isVPNConnect = [CommonUtils checkIsVPNConnect];
        NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN: isVPNConnect serverAddrIsIPV6: serverAddrIsIPV6];
        NSString *beforeIp = [CommonUtils getUserDefaultValueWithKey:SAVE_CURRENT_LOCAL_IP_KEY];
        if (!(beforeIp != nil && [beforeIp isEqual:ip])) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_STATUS_CHAGNE_NOTIFY object:[NSNumber numberWithInteger:ReachableViaWiFi]];
            [CommonUtils userDefaultSaveValue:ip forKey:SAVE_CURRENT_LOCAL_IP_KEY];
            DDLogInfo(@"WIFI network changed:%@",notifyName);
        }
        
    } else {
        DDLogInfo(@"intercepted %@", notifyName);
    }
}


/**
 *This method is used to post notification about current network
 *通知当前的网络状态
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_STATUS_CHAGNE_NOTIFY object:[NSNumber numberWithInteger:netStatus]];
}

/**
 *This method is used to get current network status
 *获取当前的网络状态
 */
-(NetworkStatus)getCurrentNetworkStatus
{
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    return netStatus;
}

// 网络是否不可用 YES不可用, NO可用
+ (BOOL)unavailable {
    return [[NetworkUtils shareInstance] getCurrentNetworkStatus] == NotReachable;
}


/**
 *This method is used to remove observer of notification kReachabilityChangedNotification
 *移除对事件kReachabilityChangedNotification的监听
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterRemoveObserver(notification, (__bridge const void *)(self), CFSTR("com.apple.system.config.network_change"), NULL);
}

@end
