//
//  VoiceStream.h
//  HWCloudLink
//
//  Created by Tory on 2020/4/22.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceStream : NSObject

/// 编码协议名
@property(nonatomic, copy) NSString *encodeProtocol;

/// 解码协议名
@property(nonatomic, copy) NSString *decodeProtocol;

/// 是否启用SRTP
@property(nonatomic, assign) BOOL isSrtp;

/// 接收比特率(kbps)
@property(nonatomic, assign) unsigned int recvBitRate;

/// 接收方平均时延(ms)
@property(nonatomic, assign) float recvDelay;

/// 接收方平均抖动(ms)
@property(nonatomic, assign) float recvJitter;

/// 接收方丢包率(%)
@property(nonatomic, assign) float recvLossFraction;

/// 接收方网络丢包率(%)
@property(nonatomic, assign) float recvNetLossFraction;

/// 接收方累计包损
@property(nonatomic, assign) unsigned int recvTotalLostPacket;

/// 接收总字节数
@property(nonatomic, assign) unsigned int recvBytes;

/// 接收方向MOS分平均值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float recvAverageMos;

/// 接收方向MOS分当前值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float recvCurMos;

/// 接收方向MOS分最大值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float recvMaxMos;

/// 接收方向MOS分最小值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float recvMinMos;

/// 发送比特率(kbps)
@property(nonatomic, assign) unsigned int sendBitRate;

/// 发送方平均时延(ms)
@property(nonatomic, assign) float sendDelay;

/// 发送方平均抖动(ms)
@property(nonatomic, assign) float sendJitter;

/// 发送方丢包率(%)
@property(nonatomic, assign) float sendLossFraction;

/// 发送方网络丢包率(%)
@property(nonatomic, assign) float sendNetLossFraction;

/// 发送方累计包损
@property(nonatomic, assign) unsigned int sendTotalLostPacket;

/// 发送总子节数
@property(nonatomic, assign) unsigned int sendBytes;

/// 发送方向MOS分平均值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float sendAverageMos;

/// 发送方向MOS分当前值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float sendCurMos;

/// 发送方向MOS分最大值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float sendMaxMos;

/// 发送方向MOS分最小值,用浮点数表示:取值范围(0, 5], 0xFFFFFFFF表示该参数无效
@property(nonatomic, assign) float sendMinMos;

@end

NS_ASSUME_NONNULL_END
