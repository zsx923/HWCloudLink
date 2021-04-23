//
//  UIDevice+Extension.m
//  HWCloudLink
//
//  Created by mac on 2020/5/22.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import "UIDevice+Extension.h"

@implementation UIDevice (Extension)
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}
@end
