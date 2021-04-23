//
//  UpgradeManager.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2020/12/25.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let AppStoreHasUpgradeVersion = NSNotification.Name("AppStoreHasUpgradeVersion")
}

class UpgradeManager: NSObject {

    static let UpgradeReminderDateKey = "UpgradeReminderDateKey"
    static let appId = "1127269366"
    static let shared = UpgradeManager()
    // AppStore版本
    var appStoreVersion = ""
    private var releaseNotes = ""
    
    // 跳转到AppStore
    func jumpToAppStore() {
        let urlStr = URL_APPSTORE_APP + APP_ID
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                CLLog("跳转AppStore\(success ? "成功" : "失败")")
            }
        }
    }
    
    // 本地版本
    func localVersion() -> String {
        return NSString.getAppInfo(withKey: "CFBundleShortVersionString")
    }
    
    // 检测是否有新版本
    func hasNewVersion() -> Bool {
        let result = localVersion().compare(appStoreVersion, options: .numeric, range: nil, locale: nil)
        return result == .orderedAscending
    }
    
    // AppStore版本
    func checkAppUpgradeInfo() {
        let urlStr = "http://itunes.apple.com/cn/lookup?id=\(APP_ID)"
        guard let url = URL(string: urlStr) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let result = data else {
                return
            }
            self.parseJson(result)
        }
        task.resume()
        return
    }
    
    private func parseJson(_ jsonData: Data) {
        guard let jsonDic = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
              let results = jsonDic["results"] as? [Any],
              let versionDic = results.first as? [String: Any],
              let version = versionDic["version"] as? String else {
            return
        }
        appStoreVersion = version
        CLLog("appStoreVersion = \(version)")
        
        guard let releaseNotes = versionDic["releaseNotes"] as? String else { return }
        self.releaseNotes = releaseNotes
//        CLLog("releaseNotes = \(releaseNotes)")
        if hasNewVersion() {
            postNotifiy()
            // 今天没有弹出过升级提示, 自动弹出
            if !todayHasReminder() {
                presentUpgradeInfoAlert()
            }
        }
    }
    
    private func postNotifiy() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .AppStoreHasUpgradeVersion, object: nil)
        }
    }
    
    // 弹出授权框
    private func presentUpgradeInfoAlert() {
        self.lateReminder()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            let alertTitleVC = UpgradeViewController()
            alertTitleVC.modalTransitionStyle = .crossDissolve
            alertTitleVC.modalPresentationStyle = .overFullScreen
            alertTitleVC.customDelegate = self
            
            let currentVC = ViewControllerUtil.getCurrentViewController()
            currentVC.present(alertTitleVC, animated: true, completion: nil)
        }
    }
    
    private func lateReminder() {
        let currentDate = NSDate.string(from: Date(), andFormatterString: "yyyyMMdd")
        NSObject.userDefaultSaveValue(currentDate, forKey: UpgradeManager.UpgradeReminderDateKey)
    }
    
    private func todayHasReminder() -> Bool {
        guard let lastDay = NSObject.getUserDefaultValue(withKey: UpgradeManager.UpgradeReminderDateKey) as? String,
              let today = NSDate.string(from: Date(), andFormatterString: "yyyyMMdd") else {
            CLLog("今天没有提醒过升级")
            return false
        }
        CLLog("上次提醒日期是\(lastDay), 今天是\(today)")
        return lastDay >= today
    }
}

extension UpgradeManager: UpgradeViewDelegate {
    
    func textTitleViewViewDidLoad(viewVC: UpgradeViewController) {
        viewVC.showTitleLabel.text = tr("版本更新")
        var releaseNotes = tr("更新内容:\n") + self.releaseNotes
        if self.releaseNotes.hasPrefix("更新内容") {
            releaseNotes = self.releaseNotes
        }
        viewVC.setReleaseNotes(releaseNotes)
        viewVC.showLeftBtn.setTitle(tr("稍后提醒"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("立即更新"), for: .normal)
    }
    
    func textTitleViewRightBtnClick(viewVC: UpgradeViewController, sender: UIButton) {
        viewVC.dismiss(animated: false) {
            self.jumpToAppStore()
        }
    }
}


