//
// CZFSingalCrash.h
// CloudLink Share
// Notes：
//
// Created by 陈帆 on 2020/12/22.
// Copyright © 2020 zhu dongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZFSingalCrash : NSObject

// 监听崩溃信息
+ (void)observerCaughtException;

@end

NS_ASSUME_NONNULL_END
