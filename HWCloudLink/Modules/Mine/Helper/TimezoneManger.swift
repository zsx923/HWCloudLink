//
//  TimezoneManger.swift
//  HWCloudLink
//
//  Created by 严腾飞 on 2021/2/9.
//  Copyright © 2021 陈帆. All rights reserved.
//

import Foundation

class TimezoneManger {
    
    static let shared = TimezoneManger()
    
    var timezoneList: [TimezoneModel] = []
    
    private init() {}
}

extension TimezoneManger {
    
    func getTimezoneList(_ isLangageChange: Bool = false) {
        if timezoneList.isEmpty || isLangageChange {
            if !NetworkUtils.unavailable() {
                if ManagerService.call()?.isSMC3 ?? false {
                    // 获取时区列表
                    ManagerService.confService()?.confctrlGetTimeZoneList()
                    NotificationCenter.default.addObserver(self, selector: #selector(notificationTimezoneList(notification:)), name: NSNotification.Name(rawValue: "TIMEZONE_LIST_KEY"), object: nil)
                }
            }
        }
    }

    @objc func notificationTimezoneList(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: [TimezoneModel]], let zoneLists = userInfo["TIMEZONE_LIST_KEY"] else { return }
        timezoneList = zoneLists
        NotificationCenter.default.removeObserver(self)
    }
}
