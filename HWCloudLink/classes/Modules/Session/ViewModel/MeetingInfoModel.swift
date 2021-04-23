//
//  MeetingInfoModel.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2020/12/30.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

enum MeetingInfoType {
    case video
    case voiceMeeting
    case svcMeeting
    case avcMeeting
}

class MeetingInfoModel {
    // 会议类型
    var type = MeetingInfoType.video
    // 会议名称
    var name = ""
    // 会议日期
    var dateStr:NSAttributedString = NSAttributedString.init(string: "")
    // 会议时间段
    var durationStr = ""
    // 会议ID  self.meetInfo?
    var meetingId = ""
    // 来宾密码 meetInfo?.generalPwd
    var guestPassword = ""
    // 是否主持人
    var isChairman = false
    // 是否是自己的会议,自己的会议显示主席密码，不是自己的会议不显示主席密码
    var isMineMeeting = false
    // 主持人密码
    var chairmanPassword = ""
    // 是否加密会议
    var isProtect = false
    // 终端号码
    var number = ""
    //音视频质量
    var netLevel = "5"
}
