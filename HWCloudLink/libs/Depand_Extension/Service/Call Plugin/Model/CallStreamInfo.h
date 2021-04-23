//
// CallStreamInfo.h
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/17.
// Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceStream.h"
#import "VideoStream.h"
#import "tsdk_call_def.h"

NS_ASSUME_NONNULL_BEGIN
@class BfcpVideoStream,SVCVideoStream;
@interface CallStreamInfo : NSObject

@property(nonatomic, strong) VoiceStream *voiceStream;
@property(nonatomic, strong) VideoStream *videoStream;
@property(nonatomic, strong) BfcpVideoStream *bfcpVideoStream;
@property(nonatomic, strong) NSArray<VideoStream *> *svcArray;                    /**< [en]Indicates data Stream information.  [cn]SVC信息*/

+ (CallStreamInfo *)transfromFromCallStreamInfoStract:(TSDK_S_CALL_STREAM_INFO *)callStreamInfo;

@end

NS_ASSUME_NONNULL_END
