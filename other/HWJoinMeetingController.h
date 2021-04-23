//
//  HWJoinMeetingController.h
//  HWCloudLink
//
//  Created by huangyingjie9 on 2021/4/19.
//  Copyright © 2021 陈帆. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWJoinMeetingController : UIViewController

@property(nonatomic, strong)UITextField *meetingIdTextField;
@property(nonatomic, strong)UITextField *passwordTextField;

@property(nonatomic, strong)UIButton *microBtn;
@property(nonatomic, strong)UIButton *cameraBtn;

@end

NS_ASSUME_NONNULL_END
