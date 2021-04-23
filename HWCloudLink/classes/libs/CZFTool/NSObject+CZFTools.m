//
//  NSObject+CZFTools.m
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import "NSObject+CZFTools.h"
#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "ManagerService.h"

#import "NSString+AES256.h"

@implementation NSObject (CZFTools)

static SystemSoundID soundID = 1008;
static NSTimer *timer;
static AVAudioPlayer *mPlayer;

NSString *const SOUND_BELL_KEY = @"SOUND_BELL_KEY";   // 铃声
NSString *const VIBRATE_KEY = @"VIBRATE_KEY";         // 振动

/**
 去除自定中空的字符值
 
 @param obj OBJ
 @return ReturnOBJ
 */
+ (id) processDictionaryIsNSNull:(id)obj {
    const NSString *blank = @"";
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dt = [(NSMutableDictionary*)obj mutableCopy];
        for(NSString *key in [dt allKeys]) {
            id object = [dt objectForKey:key];
            if([object isKindOfClass:[NSNull class]]) {
                [dt setObject:blank
                       forKey:key];
            }
            else if ([object isKindOfClass:[NSString class]]){
                NSString *strobj = (NSString*)object;
                if ([strobj isEqualToString:@"<null>"]) {
                    [dt setObject:blank
                           forKey:key];
                }
            }
            else if ([object isKindOfClass:[NSArray class]]){
                NSArray *da = (NSArray*)object;
                da = [self processDictionaryIsNSNull:da];
                [dt setObject:da
                       forKey:key];
            }
            else if ([object isKindOfClass:[NSDictionary class]]){
                NSDictionary *ddc = [self processDictionaryIsNSNull:object];
                [dt setObject:ddc forKey:key];
            }
        }
        return [dt copy];
    }
    else if ([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *da = [(NSMutableArray*)obj mutableCopy];
        for (int i=0; i<[da count]; i++) {
            NSDictionary *dc = [obj objectAtIndex:i];
            dc = [self processDictionaryIsNSNull:dc];
            [da replaceObjectAtIndex:i withObject:dc];
        }
        return [da copy];
    }
    else{
        return obj;
    }
}

+(void)userDefaultSaveValue:(id)anyValue forKey:(NSString *)key
{
    if (anyValue == nil) {
        return;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([anyValue isKindOfClass:[NSArray class]] || [anyValue isKindOfClass:[NSMutableArray class]]) {
        NSArray *anyValueArray = (NSArray *)anyValue;
        NSMutableArray *mutiArray = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < anyValueArray.count; i++) {
            NSString *aesValue = [NSString stringWithFormat:@"%@", anyValueArray[i]];
            if (aesValue != nil) {
                [mutiArray addObject:[aesValue aes256_encrypt:@"hwcloudlink"]];
            }
        }
        [userDefault setObject:mutiArray forKey:key];
    } else {
        NSString *aesValue = [NSString stringWithFormat:@"%@", anyValue];
        [userDefault setObject:[aesValue aes256_encrypt:@"hwcloudlink"] forKey:key];
    }
    [userDefault synchronize];
}

+(id)getUserDefaultValueWithKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id anyValue = [userDefault objectForKey:key];
    if (anyValue == nil) {
        return nil;
    }
    
    if ([anyValue isKindOfClass:[NSArray class]] || [anyValue isKindOfClass:[NSMutableArray class]]) {
        NSArray *anyValueArray = (NSArray *)anyValue;
        NSMutableArray *mutiArray = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < anyValueArray.count; i++) {
            NSString *aesValue = [NSString stringWithFormat:@"%@", anyValueArray[i]];
            aesValue = [aesValue aes256_decrypt:@"hwcloudlink"];
            if (aesValue != nil) {
                 [mutiArray addObject:aesValue];
            }
        }
        return mutiArray;
    } else {
        NSString *aesValue = [NSString stringWithFormat:@"%@", anyValue];
        aesValue = [aesValue aes256_decrypt:@"hwcloudlink"];
        return aesValue;
    }
}

/// 改变textField 的placeholder 颜色
/// @param textField textField
/// @param color color
+ (void)changeTextFieldPlaceholderColor:(UITextField *)textField andPlaceholderColor:(UIColor *)color {
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(textField, ivar);
    placeholderLabel.textColor = color;
}



/// 获取网络状态
+ (int)networkingStates {
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];

    int type = 0;
    for (id child in children) {
        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
        }
    }
    return type;
}

/// 获取网络状态类型
+ (NSString *)networkingStatesFromStatebar {
    int type = [self networkingStates];
    NSString *stateString = @"wifi";

    switch (type) {
        case 0:
            stateString = @"notReachable";
            break;

        case 1:
            stateString = @"2G";
            break;

        case 2:
            stateString = @"3G";
            break;

        case 3:
            stateString = @"4G";
            break;

        case 4:
            stateString = @"LTE";
            break;

        case 5:
            stateString = @"wifi";
            break;

        default:
            break;
    }

    return stateString;
}


/// 开始播放音频
/// @param soundFile 音频文件  时长小于30s
+ (BOOL)startSoundPlayerWithFileName:(NSString *)soundFile isSupportVibrate:(BOOL)isVibrate {
    // 获取本地铃声、震动的状态
    NSString *soundBellStatus = [self getUserDefaultValueWithKey:SOUND_BELL_KEY];
    NSString *vibrateStatus = [self getUserDefaultValueWithKey:VIBRATE_KEY];
    if (soundBellStatus != nil && [soundBellStatus isEqual:@"1"]) {
        // 使用AVPlayer又不能用静音物理按键控制。(使用AudioServicesPlayAlertSound播放铃声，控制不了震动)
        [self startMPlayerWithFileName:soundFile];
    }
    if (isVibrate && vibrateStatus != nil && [vibrateStatus isEqual:@"1"]) {
        //振动vibrate
        //定义URl，要播放的音乐文件是win.wav
        NSURL *audioPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:soundFile ofType:nil]];
        //创建系统音频
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(audioPath), &soundID);
        timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:true block:^(NSTimer * _Nonnull timer) {
            //振动vibrate
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }];
        [timer fire];
    }
    
    return true;
    
//    // SDK
//    NSString *wavPath = [[NSBundle mainBundle] pathForResource:soundFile
//    ofType:nil];
//    return [[ManagerService callService] mediaStartPlayWithFile:wavPath];
}

/// 停止音频播放
+ (BOOL)stopSoundPlayer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    if (mPlayer) {
        [mPlayer stop];
        mPlayer = nil;
    }
    
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);

    return true;
    
//    // SDK
//    return [[ManagerService callService] mediaStopPlay];
}

+ (void)startMPlayerWithFileName:(NSString *)fileName {
    if (!mPlayer) {
    /*这里是随便添加得一首音乐。真正的工程应该是添加一个尽可能小的音乐。。。0～1秒的没有声音的。循环播放就行。这个只是保证后台一直运行该软件。使得该软件一直处于活跃状态.你想操作的东西该在哪里操作就在哪里操作。
             */
         AVAudioSession *session = [AVAudioSession sharedInstance];
        /*打开应用会关闭别的播放器音乐*/
    //    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    /*打开应用不影响别的播放器音乐*/
        [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [session setActive:YES error:nil];
        //1.音频文件的url路径，实际开发中，用无声音乐
        NSURL *url = [[NSBundle mainBundle]URLForResource:fileName withExtension:Nil];
        //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
        mPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
        //3.缓冲
        [mPlayer prepareToPlay];
        mPlayer.numberOfLoops = NSUIntegerMax;
    }
    BOOL isucc = [mPlayer play];
    NSLog(@"isuccisuccisuccisucc:%d",isucc);
}


+ (void)saveUserDangerStatementWithValue:(BOOL)isYES forKey:(NSString *)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
//    LoginInfo *loginInfo = ManagerService.loginService.obtainCurrentLoginInfo;
    [userDefault setBool:isYES forKey:key];
}
+ (BOOL)getUserDangerStatementStatusWithCurrentCount:(NSString *)count{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return  [userDefault boolForKey:count];
}


@end
