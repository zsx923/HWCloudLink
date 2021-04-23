//
// CallStreamInfo.m
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/17.
// Copyright © 2020 陈帆. All rights reserved.
//

#import "CallStreamInfo.h"

@implementation CallStreamInfo


/**
 *This method is used to init CallStreamInfo
 *初始化CallStreamInfo
 */
- (id)init
{
    if (self = [super init])
    {
        _voiceStream = [[VoiceStream alloc]init];
        _videoStream = [[VideoStream alloc]init];
        _bfcpVideoStream = [[BfcpVideoStream alloc]init];
    }
    return self;
}

/**
 *This method is used to parse C struct TSDK_S_CALL_STREAM_INFO to instance of class CallStreamInfo
 *将头文件的结构体TSDK_S_CALL_STREAM_INFO转换为类CallStreamInfo的实例
 */
+ (CallStreamInfo *)transfromFromCallStreamInfoStract:(TSDK_S_CALL_STREAM_INFO *)callStreamInfo
{
    if (NULL == callStreamInfo)
    {
        return nil;
    }
    CallStreamInfo *streamInfo = [[CallStreamInfo alloc] init];
    
    VoiceStream *audioInfo = [self transfromFromCallAudioStreamInfoStract:&(callStreamInfo->audio_stream_info)];
    
    VideoStream *videoInfo = [self transfromFromCallVideoStreamInfoStract:&(callStreamInfo->video_stream_info)];
    
    BfcpVideoStream *dataInfo = [self transfromFromCallBfcpVideoStreamInfoStract:&(callStreamInfo->data_stream_info)];
    
    NSMutableArray *svcArray = [NSMutableArray array];
    for (int i = 0; i < TSDK_D_MAX_SVC_NUM; i++) {
        VideoStream *svcInfo = [self transfromFromCallVideoStreamInfoStract:&(callStreamInfo->svc_video_stream_info[i])];
        [svcArray addObject:svcInfo];
    }
    
    streamInfo.voiceStream = audioInfo;
    streamInfo.videoStream = videoInfo;
    streamInfo.bfcpVideoStream = dataInfo;
    streamInfo.svcArray = [NSArray arrayWithArray:svcArray];
    
    return streamInfo;
}


/**
 *This method is used to parse C struct TSDK_S_CALL_AUDIO_STREAM_INFO to instance of class CallAudioStreamInfo
 *将头文件的结构体TSDK_S_CALL_AUDIO_STREAM_INFO转换为类CallAudioStreamInfo的实例
 */
+ (VoiceStream *)transfromFromCallAudioStreamInfoStract:(TSDK_S_CALL_AUDIO_STREAM_INFO *)audio_stream_info{
    
    if (NULL == audio_stream_info)
    {
        return nil;
    }
    VoiceStream *audioInfo = [[VoiceStream alloc]init];
    if (0 < strlen(audio_stream_info->encode_protocol))
    {
        audioInfo.encodeProtocol = [NSString stringWithUTF8String:audio_stream_info->encode_protocol];
    }
    if (0 < strlen(audio_stream_info->decode_protocol))
    {
        audioInfo.decodeProtocol = [NSString stringWithUTF8String:audio_stream_info->decode_protocol];
    }
    
    audioInfo.isSrtp = audio_stream_info->is_srtp;
    audioInfo.recvBitRate = audio_stream_info->recv_bit_rate;
    audioInfo.recvDelay = audio_stream_info->recv_delay;
    audioInfo.recvJitter = audio_stream_info->recv_jitter;
    audioInfo.recvLossFraction = audio_stream_info->recv_loss_fraction;
    audioInfo.recvNetLossFraction = audio_stream_info->recv_net_loss_fraction;
    audioInfo.recvTotalLostPacket = audio_stream_info->recv_total_lost_packet;
    audioInfo.recvBytes = audio_stream_info->recv_bytes;
    audioInfo.recvAverageMos = audio_stream_info->recv_average_mos;
    audioInfo.recvCurMos = audio_stream_info->recv_cur_mos;
    audioInfo.recvMaxMos = audio_stream_info->recv_max_mos;
    audioInfo.recvMinMos = audio_stream_info->recv_min_mos;
    audioInfo.sendBitRate = audio_stream_info->send_bit_rate;
    audioInfo.sendDelay = audio_stream_info->send_delay;
    audioInfo.sendJitter = audio_stream_info->send_jitter;
    audioInfo.sendLossFraction = audio_stream_info->send_loss_fraction;
    audioInfo.sendNetLossFraction = audio_stream_info->send_net_loss_fraction;
    audioInfo.sendTotalLostPacket = audio_stream_info->send_total_lost_packet;
    audioInfo.sendBytes = audio_stream_info->send_bytes;
    audioInfo.sendAverageMos = audio_stream_info->send_average_mos;
    audioInfo.sendCurMos = audio_stream_info->send_cur_mos;
    audioInfo.sendMaxMos = audio_stream_info->send_max_mos;
    audioInfo.sendMinMos = audio_stream_info->send_min_mos;
    
    return audioInfo;
}
/**
 *This method is used to parse C struct TSDK_S_CALL_VIDEO_STREAM_INFO to instance of class CallVideoStreamInfo
 *将头文件的结构体TSDK_S_CALL_VIDEO_STREAM_INFO转换为类CallVideoStreamInfo的实例
 */
+ (VideoStream *)transfromFromCallVideoStreamInfoStract:(TSDK_S_CALL_VIDEO_STREAM_INFO *)video_stream_info{
    if (NULL == video_stream_info)
    {
        return nil;
    }
    VideoStream *videoInfo = [[VideoStream alloc]init];
    if (0 < strlen(video_stream_info->encode_name))
    {
        videoInfo.encodeName = [NSString stringWithUTF8String:video_stream_info->encode_name];
    }
    if (0 < strlen(video_stream_info->encoder_profile))
    {
        videoInfo.encoderProfile = [NSString stringWithUTF8String:video_stream_info->encoder_profile];
    }
    if (0 < strlen(video_stream_info->encoder_size))
    {
        videoInfo.encoderSize = [NSString stringWithUTF8String:video_stream_info->encoder_size];
    }
    if (0 < strlen(video_stream_info->decode_name))
    {
        videoInfo.decodeName = [NSString stringWithUTF8String:video_stream_info->decode_name];
    }
    if (0 < strlen(video_stream_info->decoder_profile))
    {
        videoInfo.decoderProfile = [NSString stringWithUTF8String:video_stream_info->decoder_profile];
    }
    if (0 < strlen(video_stream_info->decoder_size))
    {
        videoInfo.decoderSize = [NSString stringWithUTF8String:video_stream_info->decoder_size];
    }
    videoInfo.isSrtp = video_stream_info->is_srtp;
    videoInfo.width = video_stream_info->width;
    videoInfo.height = video_stream_info->height;
    videoInfo.recvDelay = video_stream_info->recv_delay;
    videoInfo.recvFrameRate = video_stream_info->recv_frame_rate;
    videoInfo.recvJitter = video_stream_info->recv_jitter;
    videoInfo.recvLossFraction = video_stream_info->recv_loss_fraction;
    videoInfo.recvBitRate = video_stream_info->recv_bit_rate;
    videoInfo.recvBytes = video_stream_info->recv_bytes;
    videoInfo.sendDelay = video_stream_info->send_delay;
    videoInfo.sendFrameRate = video_stream_info->send_frame_rate;
    videoInfo.sendJitter = video_stream_info->send_jitter;
    videoInfo.sendLossFraction = video_stream_info->send_loss_fraction;
    videoInfo.sendBitRate = video_stream_info->send_bit_rate;
    videoInfo.sendBytes = video_stream_info->send_bytes;
    videoInfo.decodeSsrc = video_stream_info->decodeSsrc;
    return videoInfo;
}

+ (BfcpVideoStream *)transfromFromCallBfcpVideoStreamInfoStract:(TSDK_S_CALL_VIDEO_STREAM_INFO *)video_stream_info {
    if (NULL == video_stream_info)
    {
        return nil;
    }
    BfcpVideoStream *videoInfo = [[BfcpVideoStream alloc]init];
    if (0 < strlen(video_stream_info->encode_name))
    {
        videoInfo.encodeName = [NSString stringWithUTF8String:video_stream_info->encode_name];
    }
    if (0 < strlen(video_stream_info->encoder_profile))
    {
        videoInfo.encoderProfile = [NSString stringWithUTF8String:video_stream_info->encoder_profile];
    }
    if (0 < strlen(video_stream_info->encoder_size))
    {
        videoInfo.encoderSize = [NSString stringWithUTF8String:video_stream_info->encoder_size];
    }
    if (0 < strlen(video_stream_info->decode_name))
    {
        videoInfo.decodeName = [NSString stringWithUTF8String:video_stream_info->decode_name];
    }
    if (0 < strlen(video_stream_info->decoder_profile))
    {
        videoInfo.decoderProfile = [NSString stringWithUTF8String:video_stream_info->decoder_profile];
    }
    if (0 < strlen(video_stream_info->decoder_size))
    {
        videoInfo.decoderSize = [NSString stringWithUTF8String:video_stream_info->decoder_size];
    }
    videoInfo.isSrtp = video_stream_info->is_srtp;
    videoInfo.width = video_stream_info->width;
    videoInfo.height = video_stream_info->height;
    videoInfo.recvDelay = video_stream_info->recv_delay;
    videoInfo.recvFrameRate = video_stream_info->recv_frame_rate;
    videoInfo.recvJitter = video_stream_info->recv_jitter;
    videoInfo.recvLossFraction = video_stream_info->recv_loss_fraction;
    videoInfo.recvBitRate = video_stream_info->recv_bit_rate;
    videoInfo.recvBytes = video_stream_info->recv_bytes;
    videoInfo.sendDelay = video_stream_info->send_delay;
    videoInfo.sendFrameRate = video_stream_info->send_frame_rate;
    videoInfo.sendJitter = video_stream_info->send_jitter;
    videoInfo.sendLossFraction = video_stream_info->send_loss_fraction;
    videoInfo.sendBitRate = video_stream_info->send_bit_rate;
    videoInfo.sendBytes = video_stream_info->send_bytes;

    return videoInfo;
}

@end
