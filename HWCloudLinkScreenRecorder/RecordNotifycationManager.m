//
//  RecordNotifycationManager.m
//  HWCloudLinkScreenRecorder
//
//  Created by yuepeng on 2020/12/21.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import "RecordNotifycationManager.h"

@interface RecordNotifycationManager (){
    NSMutableDictionary * handlers;
}

@end
@implementation RecordNotifycationManager


+ (instancetype)sharedInstance {
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback {
    handlers[name] = callback;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), defaultNotificationCallback, (__bridge CFStringRef)name, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)postNotificationWithName:(NSString *)name {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, (__bridge CFStringRef)name, NULL, NULL, YES);
}

- (void)notificationCallbackReceivedWithName:(NSString *)name {
    void (^callback)(void) = handlers[name];
    callback();
}

void defaultNotificationCallback (CFNotificationCenterRef center,
                 void *observer,
                 CFStringRef name,
                 const void *object,
                 CFDictionaryRef userInfo)
{
    NSLog(@"name: %@", name);
    NSLog(@"userinfo: %@", userInfo);

    NSString *identifier = (__bridge NSString *)name;
    [[RecordNotifycationManager sharedInstance] notificationCallbackReceivedWithName:identifier];
}


- (void)dealloc {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}

@end
