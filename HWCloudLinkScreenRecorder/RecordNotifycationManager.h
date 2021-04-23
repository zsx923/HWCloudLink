//
//  RecordNotifycationManager.h
//  HWCloudLinkScreenRecorder
//
//  Created by yuepeng on 2020/12/21.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordNotifycationManager : NSObject

+ (instancetype)sharedInstance;

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;


@end

NS_ASSUME_NONNULL_END
