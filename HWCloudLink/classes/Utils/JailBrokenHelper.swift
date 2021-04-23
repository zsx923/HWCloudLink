//
//  JailBrokenHelper.swift
//  HWCloudLink
//
//  Created by lyw on 2021/2/23.
//  Copyright © 2021 陈帆. All rights reserved.
//

import Foundation
import UIKit

class JailBrokenHelper: NSObject {
    
    static let shared = JailBrokenHelper()
    
    var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    // 当前设备是否越狱环境
    var isJailBroken: Bool {
        get {
            if JailBrokenHelper.shared.isSimulator { return false }
            if JailBrokenHelper.hasCydiaInstalled() { return true }
            if JailBrokenHelper.isContainsSuspiciousApps() { return true }
            if JailBrokenHelper.isSuspiciousSystemPathsExists() { return true }
            return JailBrokenHelper.canEditSystemFiles()
        }
    }
}

extension JailBrokenHelper: TextTitleSingleBtnViewDelegate {
    // 越狱检测
    func jailBrokenCheck(_ rootVc: UIViewController) -> Bool {
        let isJailBroken = JailBrokenHelper.shared.isJailBroken
        CLLog("是否越狱设备上安装APP：\(isJailBroken ? "YES":"NO")")
        
        if isJailBroken {
            let vc = TextTitleSingleBtnViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.customDelegate = self
            rootVc.present(vc, animated: true, completion: nil)
        }
        return isJailBroken
    }
    
    func textTitleSingleBtnViewDidLoad(viewVC: TextTitleSingleBtnViewController) {
        viewVC.showTitleLabel.text = tr("检测到您的设备已越狱，存在安全风险，HW CloudLink无法使用。如果继续使用，请恢复系统。")
        viewVC.showSureBtn.setTitle(tr("已了解并退出应用"), for: .normal)
    }
    
    func textTitleSingleBtnViewSureBtnClick(viewVC: TextTitleSingleBtnViewController, sender: UIButton) {
        exit(0)
    }
}

fileprivate extension JailBrokenHelper {
    //check if cydia is installed (using URI Scheme)
    static func hasCydiaInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }
    
    //Check if suspicious apps (Cydia, FakeCarrier, Icy etc.) is installed
    static func isContainsSuspiciousApps() -> Bool {
        for path in suspiciousAppsPathToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    //Check if system contains suspicious files
    static func isSuspiciousSystemPathsExists() -> Bool {
        for path in suspiciousSystemPathsToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    //Check if app can edit system files
    static func canEditSystemFiles() -> Bool {
        let jailBreakText = "Developer Insider"
        do {
            try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    //suspicious apps path to check
    static var suspiciousAppsPathToCheck: [String] {
        return ["/Applications/Cydia.app",
                "/Applications/blackra1n.app",
                "/Applications/FakeCarrier.app",
                "/Applications/Icy.app",
                "/Applications/IntelliScreen.app",
                "/Applications/MxTube.app",
                "/Applications/RockApp.app",
                "/Applications/SBSettings.app",
                "/Applications/WinterBoard.app",
                "/Applications/checkra1n.app"
        ]
    }
    
    //suspicious system paths to check
    static var suspiciousSystemPathsToCheck: [String] {
        return ["/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                "/private/var/lib/apt",
                "/private/var/lib/apt/",
                "/private/var/lib/cydia",
                "/private/var/mobile/Library/SBSettings/Themes",
                "/private/var/stash",
                "/private/var/tmp/cydia.log",
                "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                "/usr/bin/sshd",
                "/usr/libexec/sftp-server",
                "/usr/sbin/sshd",
                "/etc/apt",
                "/bin/bash",
                "/Library/MobileSubstrate/MobileSubstrate.dylib"
        ]
    }
}
