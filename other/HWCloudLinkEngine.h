//
//  HWCloudLinkEngine.h
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/20.
//  Copyright © 2021 jd.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWCloudLinkEngine : NSObject

@property(nonatomic, strong)UIViewController *mainController;
@property(nonatomic, assign)BOOL isJoining;

+ (instancetype)sharedInstance;

- (void)initTSDK;

- (void)authLoginTSDK;

- (void)createMeetingWithSubject:(NSString *)subject password:(NSString *)pwd microEnable:(BOOL)microEnable cameraEnable:(BOOL)cameraEnable;


@end

NS_ASSUME_NONNULL_END
