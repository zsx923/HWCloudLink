//
//  SuspendTool.swift
//  SuspendViewDemo
//
//  Created by 冯琦帆 on 2018/7/17.
//  Copyright © 2018年 冯琦帆. All rights reserved.
//

import Foundation
import UIKit

enum SuspendType {
    case video
    case voice
    case auxvid
}

class SuspendTool: NSObject {

    static let videoSuspendSize = CGSize(width: 146, height: 84)
    static let voiceSuspendSize = CGSize(width: 72, height: 90)
    static let auxSuspendSize = CGSize(width: 65, height: 70)
    static let sharedInstance = SuspendTool()
    public var suspendWindows: [SuspendWindow] = []
    private var cacheEAGLView: UIView?
    let screenSize = UIScreen.main.bounds.size
    var origin: CGPoint = CGPoint.init(x: UIScreen.main.bounds.width - videoSuspendSize.width - 10, y: 120)
    var voiceOrigin: CGPoint = CGPoint.init(x: UIScreen.main.bounds.width - voiceSuspendSize.width - 10, y: 120)
    
    static func showVoiceSuspendWindow(rootViewController: UIViewController) {
        let tool = SuspendTool.sharedInstance
        let window = SuspendWindow.init(rootViewController: rootViewController, frame: CGRect.init(origin: tool.voiceOrigin, size: voiceSuspendSize), svcManager: SVCMeetingManager())
        window.showVoice(currentTime: SessionManager.shared.currentCalledSeconds)
        tool.suspendWindows.append(window)
    }
    
    static func showVideoSuspendWindow(rootViewController: UIViewController, isAvc: Bool, svcManager:SVCMeetingManager?) {

        let tool = SuspendTool.sharedInstance
        tool.suspendWindows.removeAll()
        var adjustPosition = tool.origin
        if (adjustPosition.x + videoSuspendSize.width + 10) > tool.screenSize.width {
            // 调整异常位置
            adjustPosition.x = tool.screenSize.width - videoSuspendSize.width - 10
        }
        
        let window = SuspendWindow.init(rootViewController: rootViewController, frame: CGRect(origin: adjustPosition, size: videoSuspendSize), svcManager: svcManager)
        window.showVideo(viewController: rootViewController)
        window.isAVC = isAvc
        tool.suspendWindows.append(window)
    }
    
    static func showAuxShareSuspendWindo(rootViewController: UIViewController, isAvc: Bool) {
        let tool = SuspendTool.sharedInstance
        tool.suspendWindows.removeAll()
        
        let window = SuspendWindow.init(rootViewController: rootViewController, frame: CGRect(origin: tool.origin, size: auxSuspendSize), svcManager: SVCMeetingManager())
        window.showAuxShare(viewController: rootViewController)
        window.isAVC = isAvc
        tool.suspendWindows.append(window)
    }

    static func remove() {
        UIView.animate(withDuration: 0.25, animations: {
            SuspendTool.sharedInstance.suspendWindows.first?.alpha = 0
        }) { (_) in
            
            SuspendTool.removeWindow()
        }
    }
    
    static func isMeeting() -> Bool {
        
        return SuspendTool.sharedInstance.suspendWindows.count > 0
    }

    static func setLatestOrigin(origin: CGPoint) {
        SuspendTool.sharedInstance.origin = origin
    }
    
    static func removeWindow() {
        
        if let suspendWindow = SuspendTool.sharedInstance.suspendWindows.first, let remoteView = suspendWindow.remoteView {
            SuspendTool.sharedInstance.cacheEAGLView = remoteView
        }
        
        SuspendTool.sharedInstance.suspendWindows.removeAll()
    }
}
