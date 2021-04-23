//
//  UIColor+Extension.h
//  HWCloudLink
//
//  Created by lyw on 2021/2/5.
//  Copyright © 2021 陈帆. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 适配暗黑模式颜色
@interface UIColor(Extension)

+ (UIColor *)colorWithLightColor:(UIColor *)lightColor DarkColor:(UIColor *)darkColor;

@end

NS_ASSUME_NONNULL_END
