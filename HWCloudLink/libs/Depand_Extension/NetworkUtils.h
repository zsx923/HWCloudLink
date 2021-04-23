//
//  NetworkUtils.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

extern NSString *const NETWORK_STATUS_CHAGNE_NOTIFY;    
extern NSString *const NETWORK_STATUS_CHAGNE_UI_NOTIFY;
extern NSString *const SAVE_CURRENT_LOCAL_IP_KEY;

@interface NetworkUtils : NSObject
/**
 NetworkUtils instance
 
 @return NetworkUtils value
 */
+(instancetype)shareInstance;
/**
 get current network state
 
 @return NetworkStatus value
 */
-(NetworkStatus)getCurrentNetworkStatus;

// 网络是否不可用 YES不可用, NO可用
+ (BOOL)unavailable;

@end
