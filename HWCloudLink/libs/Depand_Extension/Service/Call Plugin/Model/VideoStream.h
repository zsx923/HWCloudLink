//
//  VideoStream.h
//  HWCloudLink
//
//  Created by Tory on 2020/4/22.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoStream : NSObject

/// 编码名称
@property(nonatomic, copy) NSString *encodeName;

/// 视频编码格式
@property(nonatomic, copy) NSString *encoderProfile;

/// 图像分辨率(编码)
@property(nonatomic, copy) NSString *encoderSize;

/// 解码名称
@property(nonatomic, copy) NSString *decodeName;

/// 视频解码格式
@property(nonatomic, copy) NSString *decoderProfile;

/// 图像分辨率(解码)
@property(nonatomic, copy) NSString *decoderSize;

/// 是否启用SRTP
@property(nonatomic, assign) BOOL isSrtp;

/// 视频分辨率-宽(ppi)
@property(nonatomic, assign) unsigned int width;

/// 视频分辨率-高(ppi)
@property(nonatomic, assign) unsigned int height;

/// 接收方平均时延(ms)
@property(nonatomic, assign) float recvDelay;

/// 视频帧率(解码)
@property(nonatomic, assign) unsigned int recvFrameRate;

/// 接收方平均抖动(ms)
@property(nonatomic, assign) float recvJitter;

/// 接收方丢包率(%)
@property(nonatomic, assign) float recvLossFraction;

/// 解码码率(bps)
@property(nonatomic, assign) unsigned int recvBitRate;

/// 接收总字节数
@property(nonatomic, assign) unsigned long long recvBytes;

/// 发送方平均时延(ms)
@property(nonatomic, assign) float sendDelay;

/// 视频帧率(编码)
@property(nonatomic, assign) unsigned int sendFrameRate;

/// 发送方平均抖动(ms)
@property(nonatomic, assign) float sendJitter;

/// 发送方丢包率(%)
@property(nonatomic, assign) float sendLossFraction;

/// 编码码率(bps)
@property(nonatomic, assign) unsigned int sendBitRate;

/// 发送总子节数
@property(nonatomic, assign) unsigned long long sendBytes;

/// svc多流解码
@property(nonatomic, assign) unsigned int decodeSsrc;

/// svc远端视频会长名
@property(nonatomic, copy) NSString *decodeAttConfName;

@end

// 辅流信息
@interface BfcpVideoStream : NSObject

/// 编码名称
@property(nonatomic, copy) NSString *encodeName;

/// 视频编码格式
@property(nonatomic, copy) NSString *encoderProfile;

/// 图像分辨率(编码)
@property(nonatomic, copy) NSString *encoderSize;

/// 解码名称
@property(nonatomic, copy) NSString *decodeName;

/// 视频解码格式
@property(nonatomic, copy) NSString *decoderProfile;

/// 图像分辨率(解码)
@property(nonatomic, copy) NSString *decoderSize;

/// 是否启用SRTP
@property(nonatomic, assign) BOOL isSrtp;

/// 视频分辨率-宽(ppi)
@property(nonatomic, assign) unsigned int width;

/// 视频分辨率-高(ppi)
@property(nonatomic, assign) unsigned int height;

/// 接收方平均时延(ms)
@property(nonatomic, assign) float recvDelay;

/// 视频帧率(解码)
@property(nonatomic, assign) unsigned int recvFrameRate;

/// 接收方平均抖动(ms)
@property(nonatomic, assign) float recvJitter;

/// 接收方丢包率(%)
@property(nonatomic, assign) float recvLossFraction;

/// 解码码率(bps)
@property(nonatomic, assign) unsigned int recvBitRate;

/// 接收总字节数
@property(nonatomic, assign) unsigned long long recvBytes;

/// 发送方平均时延(ms)
@property(nonatomic, assign) float sendDelay;

/// 视频帧率(编码)
@property(nonatomic, assign) unsigned int sendFrameRate;

/// 发送方平均抖动(ms)
@property(nonatomic, assign) float sendJitter;

/// 发送方丢包率(%)
@property(nonatomic, assign) float sendLossFraction;

/// 编码码率(bps)
@property(nonatomic, assign) unsigned int sendBitRate;

/// 发送总子节数
@property(nonatomic, assign) unsigned long long sendBytes;


@end

NS_ASSUME_NONNULL_END
