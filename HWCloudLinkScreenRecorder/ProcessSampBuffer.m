//
//  ProcessSampBuffer.m
//  HWCloudLink
//
//  Created by yuepeng on 2020/12/29.
//  Copyright © 2020 陈帆. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ProcessSampBuffer.h"
#include "mmps.h"
#import "NTESI420Frame.h"
#import "NTESYUVConverter.h"
#import <ReplayKit/ReplayKit.h>

#define hWCloudLinkScreenRecorderGroup  @"group.com.isoftstone.cloudlink"
#define GROUP_PATH [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:hWCloudLinkScreenRecorderGroup]
#define VEDIO_MMPS_PATH [[[GROUP_PATH URLByAppendingPathComponent:@"vedio_tmp.txt"] path] UTF8String]
#define VEDIO_MMPS_SIZE (1024 * 1024 * 16)
#define VEDIO_MMPS_EXT_SIZE (1024 * 1024 * 6)

static int actionIndex = 0;
@interface ProcessSampBuffer ()

@end


@implementation ProcessSampBuffer

-(instancetype)init{
    if (self = [super init]) {
        vedio_mmps = mmps_init(VEDIO_MMPS_PATH, VEDIO_MMPS_SIZE, VEDIO_MMPS_EXT_SIZE);
        if (vedio_mmps == NULL)
        {
            //TODO: 当共享内存区创建失败时需要收集日志(重要!!!! 立即处理)
//            [self printLog:@"扩展 vedio_mmps 构建失败"];
        }
        mmps_clear(vedio_mmps);
    }
    
    return self;
}
-(void)sampleHeandlerProcessSampBuffer:(CMSampleBufferRef) sampleBuffer{
    
//    if (CMSampleBufferIsValid(sampleBuffer) && CMSampleBufferDataIsReady(sampleBuffer)) {
//        @synchronized (self) {
            lastLastSampleBuffer = sampleBuffer;
            currentSampBuffer = sampleBuffer;
            //刷新最后一帧时间戳
            self.lastFrameTimestamp = getCurrentTimestamp();
//            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            [self synchronizeGroupData];
//        }
//    }
}



-(void)synchronizeGroupData{
    actionIndex = 0;
    CMSampleBufferRef SampleBuffer = NULL;
    long now = getCurrentTimestamp();
//    TODO：根据时间跨度定制丢包策略
    if (now - self.lastFrameTimestamp < 100) {
        SampleBuffer = lastLastSampleBuffer;
    } else {
        SampleBuffer = currentSampBuffer;
    }
    if (SampleBuffer == NULL) {
        NSLog(@"转换过程中1  >>>SampleBuffer为空");
        return;
    }
    @synchronized (self) {
        @autoreleasepool {
            size_t angle = [self getRotateByBuffer:SampleBuffer];
            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(SampleBuffer);
            if (pixelBuffer == NULL) {
                NSLog(@" 转换过程中2 pixelBuffer 为空");
                return;
            }
            NTESI420Frame *videoFrame = nil;
            videoFrame = [NTESYUVConverter pixelBufferToI420:pixelBuffer scale:1.0];
            if (videoFrame == nil){
                NSLog(@"转换过程中2-2 videoFrame数据异常");
                return;
            }
            if (videoFrame.i420DataLength % 4 != 0) {
                
                //TODO:yuep videoFrame 非4K对齐，需要将当前错误信息进行收集
                //NSString *log_str = @"videoFrame.i420DataLength % 4 不等于 0";
                NSLog(@"转换过程中2-3 i420DataLength异常");
        //        [self printLog:log_str];
            }
            size_t structSize = sizeof(videoFrame.width) + sizeof(videoFrame.height) + sizeof(videoFrame.i420DataLength) + sizeof(videoFrame.timetag);
            size_t size = sizeof(angle) + structSize + videoFrame.i420DataLength;
            struct mmps_data_t *mmps_data = mmps_data_snapshot_push(vedio_mmps, size);
            if (mmps_data == NULL){
                NSLog(@"转换过程中3 mmps数据为空,size>> %zu structSize>>%zu",size,structSize);
        //        struct mmps_data_t *pp = mmps_data_snapshot_pull(vedio_mmps);
                return;
            }
            *(size_t *)mmps_data->data = angle;
            [videoFrame getContext:(mmps_data->data + sizeof(angle))];
            mmps_data_snapshot_sync(vedio_mmps, mmps_data);
            
            NSLog(@"转换过程中4 mmps>>>sync>>>成功！！！ size>> %zu structSize>>%zu",size,structSize);
        }
    }
}



/**获取影像的方向 计算需旋转角度   1  ——  */
-(uint16_t)getRotateByBuffer:(CMSampleBufferRef)sampleBuffer {
    uint16_t rotate = 0;
    if (@available(iOS 11.1, *)) {
  
        CFStringRef RPVideoSampleOrientationKeyRef = (__bridge CFStringRef)RPVideoSampleOrientationKey;
        NSNumber *orientation = (NSNumber *)CMGetAttachment(sampleBuffer, RPVideoSampleOrientationKeyRef,NULL);
        switch ([orientation integerValue]) {
                //竖屏时候
                //SDK内部会做图像大小自适配(不会变形) 所以上层只要控制横屏时候的影像旋转的问题
            case kCGImagePropertyOrientationUp:{
                rotate = 0;
            }
                break;
            case kCGImagePropertyOrientationDown:{
                rotate = 180;
                break;
            }
            case kCGImagePropertyOrientationLeft: {
                //静音键那边向上 所需转90度
                rotate = 90;
            }
                break;
            case kCGImagePropertyOrientationRight:{
                //关机键那边向上 所需转270
                rotate = 270;
            }
                break;
            default:
                break;
        }
    }
    return rotate;
}


-(void)dealloc{
    mmps_free(vedio_mmps);
}
@end
