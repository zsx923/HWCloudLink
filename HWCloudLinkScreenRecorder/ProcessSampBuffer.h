//
//  ProcessSampBuffer.h
//  HWCloudLink
//
//  Created by yuepeng on 2020/12/29.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN


static CMSampleBufferRef lastLastSampleBuffer = NULL;
static CMSampleBufferRef currentSampBuffer = NULL;
static struct mmps_t *vedio_mmps = NULL;

@interface ProcessSampBuffer : NSObject
@property (nonatomic, assign) long                          lastFrameTimestamp;
//@property(nonatomic,assign)struct mmps_t * vedio_mmps;
@property(nonatomic,assign)CMSampleBufferRef lastLastSampleBuffer;


-(instancetype)init;
-(void)sampleHeandlerProcessSampBuffer:(CMSampleBufferRef) sampleBuffer;
-(void)synchronizeGroupData;
@end

NS_ASSUME_NONNULL_END
