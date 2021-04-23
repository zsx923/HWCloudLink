//
//  utility.h
//  CloudLink Share
//
//  Created by zhu dongwei on 2020/4/2.
//  Copyright © 2020 zhu dongwei. All rights reserved.
//

#ifndef utility_h
#define utility_h

#include <stdio.h>

#define ExcuteStep(result,stepMsg) \
{if(result != TUP_SUCCESS) \
{ \
NSLog(@"%@ result: %@",stepMsg,@"failure"); \
return;\
}\
else{\
NSLog(@"%@ result: %@",stepMsg,@"success");\
}\
}

//TODO:后期配置发布证书时需要注意APP标识与groupID事关辅流能力，严格按照规则填写
#define REPLAY_EXTENSION_ID  @"com.isoftstone.cloudlink.screenRecorder"
//group
#define kGroup @"group.com.isoftstone.cloudlink"  // group.TTSAudio, group.com.thundersoft.Netexten

#define CTRL_PORT  4999
#define DATA_PORT  1444
#define FRAMERATE30 30
#define FRAMERATE15 15
#define CTRL_TE20_PORT  443


// color
#define ViewBackgroundColor [UIColor colorWithHexString:@"#F8F8F8"]



#endif /* utility_h */
