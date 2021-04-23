//
//  ESpaceDeviceMotionManager.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "DeviceMotionManager.h"
#import "Defines.h"

//sensitive 灵敏度
static const float sensitive = 0.7;
static DeviceMotionManager *g_deviceManager = nil;

@implementation DeviceMotionManager

/**
 *This method is used to init this class
 *初始化方法
 */
- (instancetype)init
{
    if (self = [super init]) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.0/2.0; //采集频率
        _lastOrientation = UIDeviceOrientationPortrait;
    }
    return self;
}

/**
 *This method is used to get single instance of this class
 *获取本类唯一实例
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_deviceManager = [[DeviceMotionManager alloc] init];
    });
    return g_deviceManager;
}

/**
 *This method is used to stop device motion updates
 *暂停加速器及螺旋仪数据采集
 */
- (void)stopDeviceMotionManager
{
    if (nil != _motionManager && _motionManager.isDeviceMotionAvailable)
    {
        [_motionManager stopDeviceMotionUpdates];
    }
}

/**
 *This method is used to start device motion manager
 *开启速器及螺旋仪数据采集
 */
- (void)startDeviceMotionManager
{
    [self stopDeviceMotionManager];
    //开始采集设备方向
    if (_motionManager.isDeviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *data,NSError *error){
            [self performSelectorOnMainThread:@selector(currentDeviceOrientation:) withObject:data waitUntilDone:YES];
        }];
    }
    
}

/**
 *This method is used to detect device orientation when orientation is locked
 *方向被锁定键时，使用此方法检测设备方向
 */
- (void)currentDeviceOrientation:(CMDeviceMotion *)deviceMotion
{
    UIDeviceOrientation orientation = _lastOrientation;
    
    if (_motionManager.isDeviceMotionAvailable) {
        double x = deviceMotion.gravity.x;
        double y = deviceMotion.gravity.y;
        
        double fabX = fabs(x);
        double fabY = fabs(y);
        
        if (y < 0 ) {
            if (fabY > sensitive) {
                if (orientation != UIDeviceOrientationPortrait) {
                    orientation = UIDeviceOrientationPortrait;
                }
            }
        }else {
            if (y > sensitive) {
                if (orientation != UIDeviceOrientationPortraitUpsideDown) {
                    orientation = UIDeviceOrientationPortraitUpsideDown;
                }
            }
        }
        if (x < 0 ) {
            if (fabX > sensitive) {
                if (orientation != UIDeviceOrientationLandscapeLeft) {
                    orientation = UIDeviceOrientationLandscapeLeft;
                }
            }
        }else {
            if (x > sensitive) {
                if (orientation != UIDeviceOrientationLandscapeRight) {
                    orientation = UIDeviceOrientationLandscapeRight;
                }
            }
        }
        
    }
    if (orientation != _lastOrientation) {
        _lastOrientation = orientation;
        [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_DEVICE_ORIENTATION_CHANGED object:nil];
    }
}

/**
 *This method is used to adjust both front and back camer rotation according to device interface orientation
 *根据设备屏幕方向调整摄像头方向（横竖屏，上下方向）；
 */
- (BOOL)adjustCamerRotation:(NSUInteger *)cameraRotation
            displayRotation:(NSUInteger *)displayRotation
               byCamerIndex:(NSUInteger)index
       interfaceOrientation:(UIInterfaceOrientation)interface
{
    if (_lastOrientation != UIDeviceOrientationFaceUp && _lastOrientation != UIDeviceOrientationFaceDown)
    {
        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        if (_lastOrientation == UIDeviceOrientationPortrait)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 3;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 3;
                    *displayRotation = 0;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 3;
                    *displayRotation = 3;
                }
                else
                {
                    *cameraRotation = 3;
                    *displayRotation = 3;
                }
            }
        }
        else if (_lastOrientation == UIDeviceOrientationLandscapeLeft)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 2;
                    *displayRotation = 0;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 2;
                    *displayRotation = 0;
                }
            }
        }
        else if (_lastOrientation == UIDeviceOrientationLandscapeRight)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 2;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 0;
                    *displayRotation = 0;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 2;
                    *displayRotation = 2;
                }
                else
                {
                    *cameraRotation = 0;
                    *displayRotation = 2;
                }
            }
            
        }
        else if (_lastOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 2;
                }
                else
                {
                    *cameraRotation = 1;
                    *displayRotation = 2;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 1;
                    *displayRotation = 1;
                }
                else
                {
                    *cameraRotation = 1;
                    *displayRotation = 1;
                }
            }
        }
        return YES;
    }
    
    return NO;
}


/**
 *This method is used to adjust both front and back camer rotation according to device interface orientation
 *根据设备屏幕方向调整摄像头方向（横竖屏，上下方向）；
 */
- (void)adjustCamerRotation2:(NSUInteger *)cameraRotation
            displayRotation:(NSUInteger *)displayRotation
               byCamerIndex:(NSUInteger)index
       interfaceOrientation:(UIInterfaceOrientation)interface
{
    // 0:0度 ; 1:90度 ；2:180度 ；3:270度
    if (interface == UIInterfaceOrientationPortrait)
    {
        if (index == CameraIndexFront)
        {
            *cameraRotation = 3;
            *displayRotation = 0;
        }
        else
        {
            *cameraRotation = 3;
            *displayRotation = 0;
        }
    }

    if (interface == UIDeviceOrientationLandscapeLeft)
    {
        if (index == CameraIndexFront)
        {
            *cameraRotation = 2;
            *displayRotation = 0;
        }
        else
        {
            *cameraRotation = 0;
            *displayRotation = 0;
        }
    }

    if (interface == UIDeviceOrientationLandscapeRight)
    {
        if (index == CameraIndexFront)
        {
            *cameraRotation = 0;
            *displayRotation = 0;
        }
        else
        {
            *cameraRotation = 2;
            *displayRotation = 0;
        }
    }
    
    if (interface == UIDeviceOrientationPortraitUpsideDown)
    {
        if (index == CameraIndexFront) // 前置摄像头
        {
            *cameraRotation = 3;
            *displayRotation = 0;
        }
        else
        {
            *cameraRotation = 3;
            *displayRotation = 0;
        }
    }
}

- (void)adjustAVCCamerRotation2:(NSUInteger *)cameraRotation
    displayRotation:(NSUInteger *)displayRotation
       byCamerIndex:(NSUInteger)index
           interfaceOrientation:(UIInterfaceOrientation)interface{
    // 0:0度 ; 1:90度 ；2:180度 ；3:270度
    if (interface == UIDeviceOrientationPortrait)
    {
        if (index == CameraIndexFront)
        {
            *cameraRotation = 3;
            *displayRotation = 3;
        }
        else
        {
            *cameraRotation = 3;
            *displayRotation = 3;
        }
    }

    if (interface == UIDeviceOrientationLandscapeLeft)
    {
        if (index == CameraIndexFront)
        {
            *cameraRotation = 2;
            *displayRotation = 2;
        }
        else
        {
            *cameraRotation = 0;
            *displayRotation = 2;
        }
    }

    if (interface == UIDeviceOrientationLandscapeRight)
    {
        if (index == CameraIndexFront)
        {
            *cameraRotation = 0;
            *displayRotation = 0;
        }
        else
        {
            *cameraRotation = 2;
            *displayRotation = 0;
        }
    }
    
    if (interface == UIDeviceOrientationPortraitUpsideDown)
    {
        if (index == CameraIndexFront)
        {
            *cameraRotation = 1;
            *displayRotation = 1;
        }
        else
        {
            *cameraRotation = 1;
            *displayRotation = 1;
        }
    }
}

@end
