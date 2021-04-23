//
//  Toast.m
//  HWCloudLink
//
//  Created by chenfan on 2021/3/20.
//  Copyright © 2021 陈帆. All rights reserved.
//

#import "Toast.h"
#import "UIView+Toast.h"

#define kSCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define kSCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@implementation Toast

+ (void)showBottomMessage:(NSString *)mess {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageFont = [UIFont boldSystemFontOfSize:14.0];
    style.maxHeightPercentage = 1.0;
    style.maxWidthPercentage = 1.0;
    style.horizontalPadding = 20.0;
    style.verticalPadding = 20.0;
    [[[UIApplication sharedApplication] windows].firstObject makeToast:mess duration:1.5 position:nil style:style];
}

@end
