//
//  ImageRGBHelper.m
//  EC_SDK_DEMO
//
//  Created by zwx804641 on 2020/6/16.
//  Copyright © 2020 cWX160907. All rights reserved.
//

#import "ImageRGBHelper.h"

#define clamp(a) (a>255?255:(a<0?0:a))
@implementation ImageRGBHelper

+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {

    CGImageRef imageRef = image.CGImage;

    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];

    if(!context) {
        return NULL;
    }

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    CGRect rect = CGRectMake(0, 0, width, height);

    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);

    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);

    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;

    unsigned char *newBitmap = NULL;

    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);

        if(newBitmap) {    // Copy the data
            for(int i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }

        free(bitmapData);

    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }

    CGContextRelease(context);

    return newBitmap;
}

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;

    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;

    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;

    colorSpace = CGColorSpaceCreateDeviceRGB();

    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }

    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);

    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }

    //Create bitmap context

    context = CGBitmapContextCreate(bitmapData,
            width,
            height,
            bitsPerComponent,
            bytesPerRow,
            colorSpace,
            kCGImageAlphaNone);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }

    CGColorSpaceRelease(colorSpace);

    return context;
}

+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer
        withWidth:(int) width
       withHeight:(int) height {


    size_t bufferLength = width * height * 3;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 3 * width;

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if(colorSpaceRef == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }

    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef iref = CGImageCreate(width,
                height,
                bitsPerComponent,
                bitsPerPixel,
                bytesPerRow,
                colorSpaceRef,
                bitmapInfo,
                provider,    // data provider
                NULL,        // decode
                YES,            // should interpolate
                renderingIntent);

    uint32_t* pixels = (uint32_t*)malloc(bufferLength);

    if(pixels == NULL) {
        NSLog(@"Error: Memory not allocated for bitmap");
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);
        return nil;
    }

    CGContextRef context = CGBitmapContextCreate(pixels,
                 width,
                 height,
                 bitsPerComponent,
                 bytesPerRow,
                 colorSpaceRef,
                 kCGImageAlphaPremultipliedLast);

    if(context == NULL) {
        NSLog(@"Error context not created");
        free(pixels);
    }

    UIImage *image = nil;
    if(context) {

        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);

        CGImageRef imageRef = CGBitmapContextCreateImage(context);

        // Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
        if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
            float scale = [[UIScreen mainScreen] scale];
            image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        } else {
            image = [UIImage imageWithCGImage:imageRef];
        }

        CGImageRelease(imageRef);
        CGContextRelease(context);
    }

    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);

    return image;
}

/**
 获取rgba通道数据
 
 @param image Image
 @return 字符数据
 */
+ (unsigned char *)rgbCharArray:(UIImage *)image{
//    UIImage *tempImage = [self scaleToSize:image size:image.size];
    
    CGImageRef imgRef = [image CGImage];
    CGSize size = image.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int pixelCount = size.width * size.height;
    uint8_t* rgba = (uint8_t*)malloc(pixelCount * 4);
    CGContextRef context = CGBitmapContextCreate(rgba, size.width, size.height, 8, 4 * size.width, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imgRef);
    CGContextRelease(context);
    uint8_t *rgb = (uint8_t*)malloc(pixelCount * 3);
    int m = 0;
    int n = 0;
    /** 移除掉Alpha */
    for(int i=0; i<pixelCount; i++){
        int Value1 = n++;
        int Value2 = n++;
        int Value3 = n++;
        
        rgb[m++] = rgba[Value3];
        rgb[m++] = rgba[Value2];
        rgb[m++] = rgba[Value1];
        
        n++;
    }
    free(rgba);
    return rgb;
}


+ (UIImage *)processImage:(NSDictionary *)dictionary
{
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CVPixelBufferLockBaseAddress(imageBuffer,0);

    size_t width = [[dictionary objectForKey:@"width"] unsignedIntValue];
    size_t height = [[dictionary objectForKey:@"height"] unsignedIntValue];
    size_t orientation = [[dictionary objectForKey:@"orientation"] unsignedIntValue];
    NSData *yData = [dictionary objectForKey:@"yData"];
    NSData *uvData = [dictionary objectForKey:@"uvData"];
    uint8_t *yBuffer = (unsigned char *)[yData bytes];
    size_t yPitch = [[dictionary objectForKey:@"yPitch"] unsignedIntValue];
    uint8_t *cbCrBuffer = (unsigned char *)[uvData bytes];
    size_t cbCrPitch = [[dictionary objectForKey:@"cbCrPitch"] unsignedIntValue];

    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);
    if (orientation == UIImageOrientationLeft) {
        orientation = UIImageOrientationRight;
    }else if (orientation == UIImageOrientationRight){
        orientation = UIImageOrientationLeft;
    }

    for(int y = 0; y < height; y++) {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];

        for(int x = 0; x < width; x++) {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;

            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];

            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);

            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:orientation];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);


    return [self imageCompressFitSizeScale:image];
}

+ (UIImage *) imageCompressFitSizeScale:(UIImage *)sourceImage{
    CGSize size;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width > height) {
        size = CGSizeMake(1920, 1080);
    }else
    {
       size = CGSizeMake(1080, 1920);
    }
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

    if(CGSizeEqualToSize(imageSize, size) == NO){

        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if(widthFactor > heightFactor){
            scaleFactor = heightFactor;
        }
        else{
            scaleFactor = widthFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        
    }

    UIGraphicsBeginImageContext(size);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }

    UIGraphicsEndImageContext();
    return newImage;
}

@end
