//
//  UserCallLogModel.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/16.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

// 通话记录类型
public enum CallLogType: Int {
    case person = 1    // 个人通话记录
    case other = 2 // 会议记录
}

class UserCallLogModel: BaseModel {
    
    let sqlTabelName = "cl_user_call_log"
    
    var userCallLogId:Int?
    
    var userId:Int?
    
    var userName:String?
    
    var number:String?
    
    var imageUrl:String?
    
    var title:String?
    
    var meetingType:Int? // 1:个人通话记录 2:会议记录
    
    var callType:Int? // 1:语音电话 2:视频电话
    
    var createTime:String?
    
    var page = 0
    
    var limit = 20
    
    var isSelected = false // 当前是否被选定
    
    var isSelf = false // 是否置灰
    
    var isAnswer = false //是否接听
    
    var isComing = false // 是否呼入
    
    var talkTime: Int = 0  //通话时长
    
//    required init(json: JSON) {
//       super.init(json: json)
//           userCallLogId = json["user_call_log_id"].stringValue
//           userId = json["user_id"].intValue
//           userName = json["user_name"].stringValue
//           number = json["number"].stringValue
//           imageUrl = json["image_url"].stringValue
//           title = json["title"].stringValue
//           type = json["type"].intValue
//    }
}
