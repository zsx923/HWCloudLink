//
//  BackGroudActive.h
//  HWCloudLink
//
//  Created by yuepeng on 2020/12/22.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackGroudActive : NSObject
+ (BackGroudActive *)shareManager;

/**
 开启后台运行
 */
- (void)startBGRun;

/**
 关闭后台运行
 */
- (void)stopBGRun;

@end

NS_ASSUME_NONNULL_END
