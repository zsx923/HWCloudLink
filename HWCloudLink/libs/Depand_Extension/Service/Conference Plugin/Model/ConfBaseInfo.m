//
//  ConfBaseInfo.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2018/9/10.
//  Copyright © 2018年 cWX160907. All rights reserved.
//

#import "ConfBaseInfo.h"
#import "CommonUtils.h"
#include "ConfAttendee.h"
#import "Logger.h"
#import "NSString+CZFTools.h"

@implementation ConfBaseInfo

ConfBaseInfo *currentConfBaseInfo;
+(ConfBaseInfo *)transfromFromConfBaseInfo:(TSDK_S_CONF_BASE_INFO *)baseInfo {
    if (baseInfo == NULL) {
        return nil;
    }
    ConfBaseInfo *confInfo = [[ConfBaseInfo alloc]init];
    
    confInfo.confId = [NSString stringWithUTF8String:baseInfo->confId];
    NSString *subject = [NSString stringWithUTF8String:baseInfo->subject];
    if (subject && subject.length) {
        confInfo.confSubject = subject;
    }
    confInfo.accessNumber = [NSString stringWithUTF8String:baseInfo->accessNumber];
    confInfo.chairmanPwd = [NSString stringWithUTF8String:baseInfo->chairmanPwd];
    confInfo.generalPwd = [NSString stringWithUTF8String:baseInfo->guestPwd];
    confInfo.startTime = [NSString stringWithUTF8String:baseInfo->startTime];
    confInfo.endTime = [NSString stringWithUTF8String:baseInfo->endTime];
    confInfo.confType = baseInfo->conferenceType;
    NSString *timeZoneId = [NSString stringWithUTF8String:baseInfo->timeZoneId];
    if (timeZoneId && timeZoneId.length) {
        confInfo.timeZoneId = timeZoneId;
    }
    confInfo.duration = baseInfo->duration;
    NSString *confIdV3 = [NSString stringWithUTF8String:baseInfo->confIdV3];
    if (confIdV3 && confIdV3.length) {
        confInfo.confIdV3 = confIdV3;
    }
    confInfo.scheduleUserAccount = [NSString stringWithUTF8String:baseInfo->scheduleUserAccount];
    confInfo.scheduleUserName = [NSString stringWithUTF8String:baseInfo->scheduleUserName];
    confInfo.isActive = baseInfo->active;
//    confInfo.confType = baseInfo->conferenceType;
    confInfo.signedConf = baseInfo->signedConf;
    confInfo.signInAheadTime = baseInfo->signInAheadTime;
    confInfo.confTimeType = baseInfo->conferenceTimeType;
    
    confInfo.autoExtend = baseInfo->autoExtend;
    confInfo.autoEnd = baseInfo->autoEnd;
    confInfo.autoMute = baseInfo->autoMute;
    confInfo.voiceActive = baseInfo->voiceActive;
    confInfo.enableRecord = baseInfo->enableRecord;
    confInfo.enableLiveBroadcast = baseInfo->enableLiveBroadcast;
    confInfo.autoRecord = baseInfo->autoRecord;
    confInfo.audioRecord = baseInfo->audioRecord;
    confInfo.amcRecord = baseInfo->amcRecord;
    confInfo.chairJoinUri = [NSString stringWithUTF8String:baseInfo->chairmanLink];
    confInfo.guestJoinUri = [NSString stringWithUTF8String:baseInfo->guestLink];
    confInfo.isVmrConf = baseInfo->isVmrConf;
    
    if (baseInfo->attendeesNum > 0) {
        NSMutableArray *attendeesArray = [NSMutableArray array];
        for (int i = 0; i < baseInfo->attendeesNum; i++) {
            ConfAttendee *attendee = [[ConfAttendee alloc] init];
            TsdkConfGeralInfo confGeralInfo = baseInfo->attendees[i];
            attendee.conferenceAttendeesType = confGeralInfo.conferenceAttendeesType;
            attendee.name = [NSString stringWithUTF8String:confGeralInfo.userName];
            attendee.number = [NSString stringWithUTF8String:confGeralInfo.userNumber];
            [attendeesArray addObject:attendee];
        }
        confInfo.attendeesArray = [NSArray arrayWithArray:attendeesArray];
    }
//    if (baseInfo->attendeeNumber > 0) {
//        NSMutableArray *attendeeArray = [NSMutableArray array];
//        for (int i = 0; i < baseInfo->attendeesNum; i++) {
//            ConfAttendee *attendee = [[ConfAttendee alloc] init];
//            TSDK_S_ATTENDEE_SMCV3 attendeeV3 = baseInfo->attendeeList[i];
//            attendee.number = [NSString stringWithUTF8String:attendeeV3.attendeeUri];
//            attendee.name = [NSString stringWithUTF8String:attendeeV3.attendeeName];
//            [attendeeArray addObject:attendee];
//        }
//        confInfo.attendeeArray = [NSArray arrayWithArray:attendeeArray];
//    }
    if (baseInfo->participantsNumber > 0) {
        NSMutableArray *participantArray = [NSMutableArray array];
        for (int i = 0; i < baseInfo->participantsNumber; i++) {
            ConfAttendee *attendee = [[ConfAttendee alloc] init];
            TSDK_S_PARTICIPANT_SMCV3 participant = baseInfo->participantList[i];
            attendee.number = [NSString stringWithUTF8String:participant.participantsUri];
            attendee.name = [NSString stringWithUTF8String:participant.participantsName];
            [participantArray addObject:attendee];
        }
        confInfo.participantArray = [NSArray arrayWithArray:participantArray];
    }
    
    DDLogInfo(@"get meetingList attendeesNum:%@ attendeeNumber%@ participantsNumber:%@", [NSString encryptNumberWithString:@(baseInfo->attendeesNum).stringValue], [NSString encryptNumberWithString:@(baseInfo->attendeeNumber).stringValue], [NSString encryptNumberWithString:@(baseInfo->participantsNumber).stringValue]);
    return confInfo;
}

@end
