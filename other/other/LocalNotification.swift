//
//  LocalNotification.swift
//  HWCloudLink
//
//  Created by huangyingjie9 on 2021/4/22.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

@objcMembers
class LocalNotification: NSObject {

     static func pushLocalNotify() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "call", content: content, trigger: trigger)
        center.add(request) { (error) in
            CLLog("来电本地推送")
        }
    }
    
}
