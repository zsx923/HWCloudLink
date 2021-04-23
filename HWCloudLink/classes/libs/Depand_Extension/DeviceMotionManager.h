//
//  ESpaceDeviceMotionManager.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#define ESPACE_DEVICE_ORIENTATION_CHANGED   @"ESPACE_DEVICE_ORIENTATION_CHANGED"

@interface DeviceMotionManager : NSObject

@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@property (nonatomic, strong) CMMotionManager *motionManager;

+ (instancetype)sharedInstance;

- (void)startDeviceMotionManager;

- (void)stopDeviceMotionManager;

- (BOOL)adjustCamerRotation:(NSUInteger *)cameraRotation
            displayRotation:(NSUInteger *)displayRotation
               byCamerIndex:(NSUInteger)index
       interfaceOrientation:(UIInterfaceOrientation)interface;

/**
 *This method is used to adjust both front and back camer rotation according to device interface orientation
 *根据设备屏幕方向调整摄像头方向（横竖屏，上下方向）；
 */
- (void)adjustCamerRotation2:(NSUInteger *)cameraRotation
            displayRotation:(NSUInteger *)displayRotation
               byCamerIndex:(NSUInteger)index
        interfaceOrientation:(UIInterfaceOrientation)interface;

/**
 *This method is used to adjust both front and back camer rotation according to device interface orientation
 *根据设备屏幕方向调整摄像头方向（横竖屏，上下方向）；
 */
- (void)adjustAVCCamerRotation2:(NSUInteger *)cameraRotation
            displayRotation:(NSUInteger *)displayRotation
               byCamerIndex:(NSUInteger)index
        interfaceOrientation:(UIInterfaceOrientation)interface;

@end
