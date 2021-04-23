//
//  SynchGroupDataSer.h
//  HWCloudLink
//
//  Created by yuepeng on 2020/12/29.
//  Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerService.h"

NS_ASSUME_NONNULL_BEGIN

@interface SynchGroupDataSer : NSObject
+ (instancetype)shareInstance ;
- (size_t)airClientScreenDataCallback:(TSDK_VOID *)pData Width:(long *)pWidth Height:(long *)pHeight;
@end

NS_ASSUME_NONNULL_END
