//  Created by fenric on 16/3/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESYUVConverter.h"
#import "NTESVideoUtil.h"
#import "libyuv.h"

#import "utility.h"
//#import "SocketTool.h"

@implementation NTESYUVConverter

+ (NTESI420Frame *)I420ScaleWithSourceI420Frame:(NTESI420Frame *)I420Frame
                                       dstWidth:(float)width
                                      dstHeight:(float)height {
    NTESI420Frame *scaledI420Frame = [[NTESI420Frame alloc] initWithWidth:width height:height];

    libyuv::I420Scale([I420Frame dataOfPlane:NTESI420FramePlaneY],
                      (int)[I420Frame strideOfPlane:NTESI420FramePlaneY],
                      [I420Frame dataOfPlane:NTESI420FramePlaneU],
                      (int)[I420Frame strideOfPlane:NTESI420FramePlaneU],
                      [I420Frame dataOfPlane:NTESI420FramePlaneV],
                      (int)[I420Frame strideOfPlane:NTESI420FramePlaneV],
                      I420Frame.width, I420Frame.height,
                      [scaledI420Frame dataOfPlane:NTESI420FramePlaneY],
                      (int)[scaledI420Frame strideOfPlane:NTESI420FramePlaneY],
                      [scaledI420Frame dataOfPlane:NTESI420FramePlaneU],
                      (int)[scaledI420Frame strideOfPlane:NTESI420FramePlaneU],
                      [scaledI420Frame dataOfPlane:NTESI420FramePlaneV],
                      (int)[scaledI420Frame strideOfPlane:NTESI420FramePlaneV],
                      width, height, libyuv::kFilterNone);

    return scaledI420Frame;
}

//+ (NVSI420Frame *)pixelBufferToI420:(CVImageBufferRef)pixelBuffer withCrop:(float)cropRatio targetSize:(CGSize)size andOrientation:(NVSVideoPackOrientation)orientation {
//
////    CMVideoDimensions outputDimens = [NVSVideoUtil outputVideoDimens:inputDimens crop:cropRatio];
//    return [self pixelBufferToI420:pixelBuffer withCrop:cropRatio andScale:0 andOrientation:orientation];
//}

+ (NTESI420Frame *)pixelBufferToI420:(CVImageBufferRef)pixelBuffer
                            withCrop:(float)cropRatio
                          targetSize:(CGSize)size
                      andOrientation:(NTESVideoPackOrientation)orientation
{
    if (pixelBuffer == NULL) {
        return nil;
    }

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);

    size_t bufferWidth = 0;
    size_t bufferHeight = 0;
    size_t rowSize = 0;
    uint8_t *pixel = NULL;

    if (CVPixelBufferIsPlanar(pixelBuffer)) {
        int basePlane = 0;
        pixel = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, basePlane);
        bufferHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, basePlane);
        bufferWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, basePlane);
        rowSize = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, basePlane);
    } else {
        pixel = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
        bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
        bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
        rowSize = CVPixelBufferGetBytesPerRow(pixelBuffer);
    }

    NTESI420Frame *convertedI420Frame = [[NTESI420Frame alloc] initWithWidth:(int)bufferWidth height:(int)bufferHeight];

    int error = -1;

    if (kCVPixelFormatType_32BGRA == sourcePixelFormat) {
        error = libyuv::ARGBToI420(
            pixel, (int)rowSize,
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
            (int)bufferWidth, (int)bufferHeight);
    } else if (kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange == sourcePixelFormat || kCVPixelFormatType_420YpCbCr8BiPlanarFullRange == sourcePixelFormat) {
        error = libyuv::NV12ToI420(
            pixel,
            (int)rowSize,
            (const uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1),
            (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1),
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneY],
            (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneU],
            (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneV],
            (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
            (int)bufferWidth,
            (int)bufferHeight);
    }

    if (error) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        NSLog(@"error convert pixel buffer to i420 with error %d", error);
        return nil;
    } else {
        rowSize = [convertedI420Frame strideOfPlane:NTESI420FramePlaneY];
        pixel = convertedI420Frame.data;
    }

    CMVideoDimensions inputDimens = { (int32_t)bufferWidth, (int32_t)bufferHeight };
    CMVideoDimensions outputDimens = [NTESVideoUtil outputVideoDimensEnhanced:inputDimens crop:cropRatio];
//        CMVideoDimensions outputDimens = {(int32_t)738,(int32_t)1312};
    CMVideoDimensions sizeDimens = { (int32_t)size.width, (int32_t)size.height };
    CMVideoDimensions targetDimens = [NTESVideoUtil outputVideoDimensEnhanced:sizeDimens crop:cropRatio];
    int cropX = (inputDimens.width - outputDimens.width) / 2;
    int cropY = (inputDimens.height - outputDimens.height) / 2;

    if (cropX % 2) {
        cropX += 1;
    }

    if (cropY % 2) {
        cropY += 1;
    }
    float scale = targetDimens.width * 1.0 / outputDimens.width;

    NTESI420Frame *croppedI420Frame = [[NTESI420Frame alloc] initWithWidth:outputDimens.width height:outputDimens.height];

    error = libyuv::ConvertToI420(pixel, bufferHeight * rowSize * 1.5,
                                  [croppedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[croppedI420Frame strideOfPlane:NTESI420FramePlaneY],
                                  [croppedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[croppedI420Frame strideOfPlane:NTESI420FramePlaneU],
                                  [croppedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[croppedI420Frame strideOfPlane:NTESI420FramePlaneV],
                                  cropX, cropY,
                                  (int)bufferWidth, (int)bufferHeight,
                                  croppedI420Frame.width, croppedI420Frame.height,
                                  libyuv::kRotate0, libyuv::FOURCC_I420);

    if (error) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        NSLog(@"error convert pixel buffer to i420 with error %d", error);
        return nil;
    }

    NTESI420Frame *i420Frame;

    if (scale == 1.0) {
        i420Frame = croppedI420Frame;
    } else {
        int width = outputDimens.width * scale;
        width &= 0xFFFFFFFE;
        int height = outputDimens.height * scale;
        height &= 0xFFFFFFFE;

        i420Frame = [[NTESI420Frame alloc] initWithWidth:width height:height];

        libyuv::I420Scale([croppedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[croppedI420Frame strideOfPlane:NTESI420FramePlaneY],
          [croppedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[croppedI420Frame strideOfPlane:NTESI420FramePlaneU],
          [croppedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[croppedI420Frame strideOfPlane:NTESI420FramePlaneV],
          croppedI420Frame.width, croppedI420Frame.height,
          [i420Frame dataOfPlane:NTESI420FramePlaneY], (int)[i420Frame strideOfPlane:NTESI420FramePlaneY],
          [i420Frame dataOfPlane:NTESI420FramePlaneU], (int)[i420Frame strideOfPlane:NTESI420FramePlaneU],
          [i420Frame dataOfPlane:NTESI420FramePlaneV], (int)[i420Frame strideOfPlane:NTESI420FramePlaneV],
          i420Frame.width, i420Frame.height,
          libyuv::kFilterBilinear);     // TODO kFilterNone
    }

    int dstWidth, dstHeight;
    libyuv::RotationModeEnum rotateMode = [NTESYUVConverter rotateMode:orientation];

    if (rotateMode != libyuv::kRotateNone) {
        if (rotateMode == libyuv::kRotate270 || rotateMode == libyuv::kRotate90) {
            dstWidth = i420Frame.height;
            dstHeight = i420Frame.width;
        } else {
            dstWidth = i420Frame.width;
            dstHeight = i420Frame.height;
        }
        NTESI420Frame *rotatedI420Frame = [[NTESI420Frame alloc]initWithWidth:dstWidth height:dstHeight];

        libyuv::I420Rotate([i420Frame dataOfPlane:NTESI420FramePlaneY], (int)[i420Frame strideOfPlane:NTESI420FramePlaneY],
                           [i420Frame dataOfPlane:NTESI420FramePlaneU], (int)[i420Frame strideOfPlane:NTESI420FramePlaneU],
                           [i420Frame dataOfPlane:NTESI420FramePlaneV], (int)[i420Frame strideOfPlane:NTESI420FramePlaneV],
                           [rotatedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneY],
                           [rotatedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneU],
                           [rotatedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneV],
                           i420Frame.width, i420Frame.height,
                           rotateMode);
        i420Frame = rotatedI420Frame;
    }

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return i420Frame;
}

+ (NTESI420Frame *)i420RotationWithFrameRotate:(uint16_t)angle i420Frame:(NTESI420Frame *)i420Frame {
    int dstWidth, dstHeight;

    NTESVideoPackOrientation orientation = NTESVideoPackOrientationPortrait;
    if (angle == 0) {
        orientation = NTESVideoPackOrientationPortrait;
    } else if (angle == 90) {
        orientation = NTESVideoPackOrientationLandscapeLeft;
    } else if (angle == 180) {
        orientation = NTESVideoPackOrientationPortraitUpsideDown;
    } else {
        orientation = NTESVideoPackOrientationLandscapeRight;
    }
    libyuv::RotationModeEnum rotateMode = [NTESYUVConverter rotateMode:orientation];
    
    if (rotateMode != libyuv::kRotateNone) {
        if (rotateMode == libyuv::kRotate270 || rotateMode == libyuv::kRotate90) {
            dstWidth = i420Frame.height;
            dstHeight = i420Frame.width;
        } else {
            dstWidth = i420Frame.width;
            dstHeight = i420Frame.height;
        }
        NTESI420Frame *rotatedI420Frame = [[NTESI420Frame alloc]initWithWidth:dstWidth height:dstHeight];
        
        libyuv::I420Rotate([i420Frame dataOfPlane:NTESI420FramePlaneY], (int)[i420Frame strideOfPlane:NTESI420FramePlaneY],
                           [i420Frame dataOfPlane:NTESI420FramePlaneU], (int)[i420Frame strideOfPlane:NTESI420FramePlaneU],
                           [i420Frame dataOfPlane:NTESI420FramePlaneV], (int)[i420Frame strideOfPlane:NTESI420FramePlaneV],
                           [rotatedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneY],
                           [rotatedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneU],
                           [rotatedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[rotatedI420Frame strideOfPlane:NTESI420FramePlaneV],
                           i420Frame.width, i420Frame.height,
                           rotateMode);
        //i420Frame = rotatedI420Frame;
        
         return rotatedI420Frame;
    }
    
    return i420Frame;
}

+ (NTESI420Frame *)pixelBufferToI420:(CVImageBufferRef)pixelBuffer {
    return [self pixelBufferToI420:pixelBuffer scale:1];
}

+ (NTESI420Frame *)pixelBufferToI420:(CVImageBufferRef)pixelBuffer scale:(CGFloat)scale {
    if (pixelBuffer == NULL) {
        return nil;
    }

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);

    size_t bufferWidth = 0;
    size_t bufferHeight = 0;
    size_t rowSize = 0;
    uint8_t *pixel = NULL;

    if (CVPixelBufferIsPlanar(pixelBuffer)) {
        int basePlane = 0;
        pixel = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, basePlane);
        bufferHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, basePlane);
        bufferWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, basePlane);
        rowSize = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, basePlane);
    } else {
        pixel = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
        bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
        bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
        rowSize = CVPixelBufferGetBytesPerRow(pixelBuffer);
    }
    //NSLog(@"%ld, %ld", bufferWidth, bufferHeight);
    NTESI420Frame *convertedI420Frame = [[NTESI420Frame alloc] initWithWidth:(int)bufferWidth height:(int)bufferHeight];

    int error = -1;
    if (kCVPixelFormatType_32BGRA == sourcePixelFormat) {
        error = libyuv::ARGBToI420(
            pixel, (int)rowSize,
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
            (int)bufferWidth, (int)bufferHeight);
    } else if (kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange == sourcePixelFormat || kCVPixelFormatType_420YpCbCr8BiPlanarFullRange == sourcePixelFormat) {
        error = libyuv::NV12ToI420(
            pixel,
            (int)rowSize,
            (const uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1),
            (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1),
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneY],
            (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneU],
            (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
            [convertedI420Frame dataOfPlane:NTESI420FramePlaneV],
            (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
            (int)bufferWidth,
            (int)bufferHeight);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    if (error) {
        NSLog(@"error convert pixel buffer to i420 with error %d", error);
        return nil;
    }

    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kGroup];
    BOOL isConf = [userDefault boolForKey:@"isConf"];
    BOOL isIpad = [userDefault boolForKey:@"isIpad"];
    
    if (isConf && isIpad) {
        CGFloat tempWidth = bufferWidth;
        CGFloat tempHeight = bufferHeight;
        if (tempWidth * tempHeight > 1080 * 1920) {
                if (tempWidth > tempHeight) {
                    scale = 1080.0 / tempHeight;
                } else {
                    scale = 1080.0 / tempWidth;
                }
        }
    }else {
        scale = 1.0;
    }
    
    if (scale == 1.0) {
        return convertedI420Frame;
    }

    int width = bufferWidth * scale;
    width &= 0xFFFFFFFE;
    int height = bufferHeight * scale;
    height &= 0xFFFFFFFE;

    NTESI420Frame *i420Frame = [[NTESI420Frame alloc] initWithWidth:width height:height];

    libyuv::I420Scale([convertedI420Frame dataOfPlane:NTESI420FramePlaneY], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneY],
                      [convertedI420Frame dataOfPlane:NTESI420FramePlaneU], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneU],
                      [convertedI420Frame dataOfPlane:NTESI420FramePlaneV], (int)[convertedI420Frame strideOfPlane:NTESI420FramePlaneV],
                      convertedI420Frame.width, convertedI420Frame.height,
                      [i420Frame dataOfPlane:NTESI420FramePlaneY], (int)[i420Frame strideOfPlane:NTESI420FramePlaneY],
                      [i420Frame dataOfPlane:NTESI420FramePlaneU], (int)[i420Frame strideOfPlane:NTESI420FramePlaneU],
                      [i420Frame dataOfPlane:NTESI420FramePlaneV], (int)[i420Frame strideOfPlane:NTESI420FramePlaneV],
                      i420Frame.width, i420Frame.height,
                      libyuv::kFilterBilinear);

    convertedI420Frame = nil;
    return i420Frame;
}

+ (CVPixelBufferRef)i420FrameToPixelBuffer:(NTESI420Frame *)i420Frame
{
    @autoreleasepool {
        if (i420Frame == nil) {
            return NULL;
        }

        CVPixelBufferRef pixelBuffer = NULL;

        NSDictionary *pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSDictionary dictionary], (id)kCVPixelBufferIOSurfacePropertiesKey,
                                               nil];

        CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                              i420Frame.width,
                                              i420Frame.height,
                                              kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                              (__bridge CFDictionaryRef)pixelBufferAttributes,
                                              &pixelBuffer);

        if (result != kCVReturnSuccess) {
    //        NVSLogErr(@"Failed to create pixel buffer: %d", result);
            return NULL;
        }

        result = CVPixelBufferLockBaseAddress(pixelBuffer, 0);

        if (result != kCVReturnSuccess) {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            CFRelease(pixelBuffer);
    //        NVSLogErr(@"Failed to lock base address: %d", result);
            return NULL;
        }

        uint8 *dstY = (uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        int dstStrideY = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        uint8 *dstUV = (uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        int dstStrideUV = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);

        int ret = libyuv::I420ToNV12([i420Frame dataOfPlane:NTESI420FramePlaneY], (int)[i420Frame strideOfPlane:NTESI420FramePlaneY],
                                     [i420Frame dataOfPlane:NTESI420FramePlaneU], (int)[i420Frame strideOfPlane:NTESI420FramePlaneU],
                                     [i420Frame dataOfPlane:NTESI420FramePlaneV], (int)[i420Frame strideOfPlane:NTESI420FramePlaneV],
                                     dstY, dstStrideY, dstUV, dstStrideUV,
                                     i420Frame.width, i420Frame.height);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        if (ret) {
    //        NVSLogErr(@"Error converting I420 VideoFrame to NV12: %d", result);
            CFRelease(pixelBuffer);
            return NULL;
        }

        return pixelBuffer;
    }
  
}

+ (libyuv::RotationModeEnum)rotateMode:(NTESVideoPackOrientation)orientation
{
    switch (orientation) {
        case NTESVideoPackOrientationPortraitUpsideDown:
            return libyuv::kRotate180;
        case NTESVideoPackOrientationLandscapeLeft:
            return libyuv::kRotate90;
        case NTESVideoPackOrientationLandscapeRight:
            return libyuv::kRotate270;
        case NTESVideoPackOrientationPortrait:
        default:
            return libyuv::kRotate0;
    }
}


/// rgba 转 YUV420P数据
/// @param srcRGBAData rgba数据
/// @param destYUV420PData 目标数据地址
/// @param size 图片大小尺寸
+ (void)rgbaDataConvertYUV420P:(uint8_t *)srcRGBAData Dest:(uint8_t *)destYUV420PData ImageSize:(CGSize)size {
    int width = size.width;
    int height = size.height;
    int y_stride = width;
    int u_stride = (width + 1) / 2;
    int v_stride = u_stride;
    
    size_t ySize = (size_t) (y_stride * height);
    size_t uSize = (size_t) (u_stride * (height + 1) / 2);
    
    libyuv::RGBAToI420(srcRGBAData, width * 4, destYUV420PData, y_stride, destYUV420PData + ySize, u_stride, destYUV420PData + ySize + uSize, v_stride, width, height);
}

+ (CMSampleBufferRef)pixelBufferToSampleBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (pixelBuffer == NULL) {
        return NULL;
    }
    CMSampleBufferRef sampleBuffer;
    CMTime frameTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSince1970], 1000000000);
    CMSampleTimingInfo timing = { kCMTimeInvalid, frameTime, kCMTimeInvalid };
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);

    OSStatus status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (status != noErr) {
        NSLog(@"Failed to create sample buffer with error %@.", @(status));
    }

    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);

    CVPixelBufferRelease(pixelBuffer);
    if (videoInfo) CFRelease(videoInfo);

    return sampleBuffer;
}

@end
