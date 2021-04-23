//
//  SynchGroupDataSer.m
//  HWCloudLink
//
//  Created by yuepeng on 2020/12/29.
//  Copyright © 2020 陈帆. All rights reserved.
//

#include "mmps.h"
#import "SynchGroupDataSer.h"
#import "NTESI420Frame.h"
#import "NTESYUVConverter.h"
#import "RecordNotifycationManager.h"

//extern struct mmps_t *vedio_mmps;
struct mmps_t *vedio_mmps = NULL;
static CVPixelBufferRef globle_pixelBuffer = NULL;
static bool isShareScreen =  false;
static SynchGroupDataSer * _synchGroupDataSer = nil;
#define hWCloudLinkScreenRecorderGroup  @"group.com.isoftstone.cloudlink"
#define GROUP_PATH [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:hWCloudLinkScreenRecorderGroup]
#define VEDIO_MMPS_PATH [[[GROUP_PATH URLByAppendingPathComponent:@"vedio_tmp.txt"] path] UTF8String]
#define VEDIO_MMPS_SIZE (1024 * 1024 * 16)
#define VEDIO_MMPS_EXT_SIZE (1024 * 1024 * 6)


@implementation SynchGroupDataSer


+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _synchGroupDataSer = [[SynchGroupDataSer alloc] init];
      
    });
    
    return _synchGroupDataSer;
}


-(instancetype)init{
    if (self = [super init]) {
        NSFileManager *filemanager =  [NSFileManager defaultManager];
        if ([filemanager isExecutableFileAtPath:[[GROUP_PATH URLByAppendingPathComponent:@"vedio_tmp.txt"] path]])
        {
            [filemanager removeItemAtPath:[[GROUP_PATH URLByAppendingPathComponent:@"vedio_tmp.txt"] path] error:nil];
        }
       
        vedio_mmps = mmps_init(VEDIO_MMPS_PATH, VEDIO_MMPS_SIZE, VEDIO_MMPS_EXT_SIZE);
        if (vedio_mmps == NULL)
        {
           
        }
        mmps_clear(vedio_mmps);
        
//        RecordNotifycationManager * not = [RecordNotifycationManager sharedInstance];
//        [not registerForNotificationName:@"ExtentionRecordStart" callback:^{
//            isShareScreen = false;
//        }];
        
    }
    return self;
}
/***** Call Back ************/
///!!! [优化流程：字节长度转换unsigned int -> size_t] w30006558 20201218
- (size_t)airClientScreenDataCallback:(TSDK_VOID *)pData Width:(long *)pWidth Height:(long *)pHeight{
//    ISLog(@"airClientScreenDataCallback, %ld", self.arrData.count);
    if (pWidth == NULL || pHeight == NULL || pData == NULL) {
//        ISLog(@"airClientScreenDataCallback中pWidth:%d, pHeight:%d", pWidth==NULL?0:1, pHeight==NULL?0:1);
        return 0;
    }
    if (1) {
    //TODO : 如果发生辅流共享期间被抢断，需要将当前置位条件清零，停止推流
        @autoreleasepool {

            struct mmps_data_t *pp = mmps_data_snapshot_pull(vedio_mmps);
            if (pp != NULL) {
                size_t size = pp->size - sizeof(struct mmps_data_t) - sizeof(size_t);

                size_t angle = *(size_t *)pp->data;

                size_t headerLength = sizeof(angle);
                NTESI420Frame *ntesi420frame = [NTESI420Frame initWithBuffer:(pp->data + headerLength) Length:(size - headerLength)];
                
                //mmps_data_free(vedio_mmps, pp);
                if (ntesi420frame != nil) {
                    NTESI420Frame *frameNew = [NTESYUVConverter i420RotationWithFrameRotate:angle i420Frame:ntesi420frame];

                    
                    if (frameNew != nil) {
                        globle_pixelBuffer = [frameNew convertToPixelBuffer];
                     
                        if (globle_pixelBuffer != NULL) {
                            CVPixelBufferLockBaseAddress(globle_pixelBuffer, 0);
                            size_t length = CVPixelBufferGetDataSize(globle_pixelBuffer);
                            *pWidth = CVPixelBufferGetWidth(globle_pixelBuffer);
                            *pHeight = CVPixelBufferGetHeight(globle_pixelBuffer);
                            CVPixelBufferUnlockBaseAddress(globle_pixelBuffer, 0);
                            (*((long long *)pData)) = globle_pixelBuffer;
                            return length;
                        } else {
//                            nslog(@"pixelBuffer数据出错");
                            return 0;
                        }
                    } else {
//                        nslog(@"socket数据转I420数据出错");
                        return 0;
                    }
                }
            }
        }
    }
    return 0;
}

#if 0
- (void)handleVedioWithLoopQueue
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (1) {
            if ([TupService shareInstance].isShareScreen && [TupService shareInstance].isConnected) {
                @autoreleasepool {
                    [self printAppMMPSStatus];
                    struct mmps_data_t *pp = mmps_data_point(vedio_mmps);
                    
                    if (pp != NULL) {
                        size_t size = pp->size - sizeof(struct mmps_data_t);

                        size_t angle = *(size_t *)pp->data;

                        size_t headerLength = sizeof(angle);
                        NTESI420Frame *ntesi420frame = [NTESI420Frame initWithBuffer:(pp->data + headerLength) Length:(size - headerLength)];
                        
                        mmps_data_free(vedio_mmps, pp);
                        if (ntesi420frame != nil) {

                            size_t width = ntesi420frame.width;
                            size_t height = ntesi420frame.height;

                            [TupService shareInstance].screenImageWidth = width;
                            [TupService shareInstance].screenImageHeight = height;
                            [TupService shareInstance].screenImageAngle = angle;
                            
                            NTESI420Frame *frameNew = [NTESYUVConverter i420RotationWithFrameRotate:angle i420Frame:ntesi420frame];

                            if (frameNew != nil) {
                                CVPixelBufferRef pixelBuffer = [frameNew convertToPixelBuffer];
                                if (pixelBuffer != NULL) {
                                    [[TupService shareInstance] shareScreenWithPixelBuffer:pixelBuffer imgWidth:width imgHeight:height Angle:angle];
                                } else {
                                    ISLog(@"pixelBuffer数据出错");
                                }
                            } else {
                                ISLog(@"socket数据转I420数据出错");
                            }
                        }
                    } else {
                        usleep(30 * 1000);
                    }
                }
            } else {
                usleep(20 * 1000);
            }
            
        }
    });
}

#endif

-(void)dealloc{
    mmps_free(vedio_mmps);
}
@end
