//
//  ImageRGBHelper.h
//  EC_SDK_DEMO
//
//  Created by zwx804641 on 2020/6/16.
//  Copyright © 2020 cWX160907. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageRGBHelper : NSObject

 + (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *)image;

 /** A helper routine used to convert a RGBA8 to UIImage
  @return a new context that is owned by the caller
  */
 + (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef)image;


 /** Converts a RGBA8 bitmap to a UIImage.
  @param buffer - the RGBA8 unsigned char * bitmap
  @param width - the number of pixels wide
  @param height - the number of pixels tall
  @return a UIImage that is autoreleased or nil if memory allocation issues
  */
 + (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *)buffer
     withWidth:(int)width
     withHeight:(int)height;

 /**
  获取rgba通道数据
  
  @param image Image
  @return 字符数据
  */
 + (unsigned char *)rgbCharArray:(UIImage *)image;

/**
 获取数据合成的图片
 
 @param dictionary  截屏返回的数据
 @return image
 */
 + (UIImage *)processImage:(NSDictionary *)dictionary;

@end
