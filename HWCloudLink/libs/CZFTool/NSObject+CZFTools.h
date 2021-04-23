//
//  NSObject+CZFTools.h
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const SOUND_BELL_KEY;   // 铃声
extern NSString *const VIBRATE_KEY;      // 振动

@interface NSObject (CZFTools)


/**
 去除自定中空的字符值
 
 @param obj OBJ
 @return ReturnOBJ
 */
+ (id) processDictionaryIsNSNull:(id)obj;

/// 存储数据到本地
/// @param anyValue OBJ
/// @param key key
+(void)userDefaultSaveValue:(id)anyValue forKey:(NSString *)key;

/// 读取本地数据
/// @param key key
+(id)getUserDefaultValueWithKey:(NSString *)key;

/// 改变textField 的placeholder 颜色
/// @param textField textField
/// @param color color
+ (void)changeTextFieldPlaceholderColor:(UITextField *)textField andPlaceholderColor:(UIColor *)color;

/// 获取网络状态类型
+ (NSString *)networkingStatesFromStatebar;

/// 开始播放音频
/// @param soundFile 音频文件  时长小于30s
+ (BOOL)startSoundPlayerWithFileName:(NSString *)soundFile isSupportVibrate:(BOOL)isVibrate;

/// 停止音频播放
+ (BOOL)stopSoundPlayer;

///保存当前登录用户的风险提示状态，是根据用户名来保存的
+ (void)saveUserDangerStatementWithValue:(BOOL)isYES forKey:(NSString *)key;
///获取当前登录用户名的风险提示状态
+ (BOOL)getUserDangerStatementStatusWithCurrentCount:(NSString *)count;


@end
