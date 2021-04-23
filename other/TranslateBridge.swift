//
//  TranslateBridge.swift
//  HWCloudLink
//
//  Created by huangyingjie9 on 2021/4/23.
//  Copyright © 2021 陈帆. All rights reserved.
//

// oc和swift 业务代码中间层转换


import UIKit
import CocoaLumberjack

@objcMembers
class TranslateBridge: NSObject {

    static func jumpConfMeetVC(callInfo: CallInfo, meetInfo: ConfBaseInfo, animated: Bool) {
        
        let sessionType = callInfo.isSvcCall ? SessionType.svcMeeting : SessionType.avcMeeting
        SessionManager.shared.jumpConfMeetVC(sessionType: sessionType, meetInfo: meetInfo, animated: animated)
        
    }
    
    static func CLLog(message: String) {
        
        HWCloudLink.CLLog(message, level: DDDefaultLogLevel, context: 0, tag: nil, asynchronous: asyncLoggingEnabled, ddlog: .sharedInstance)
    }
    
    static func reasonCodeIsEqualErrorType(reasonCode: UInt32, type: UInt32) -> Bool {
        return Tools.toHex(Int64(type)) == Tools.toHex(Int64(reasonCode))
    }    
}
