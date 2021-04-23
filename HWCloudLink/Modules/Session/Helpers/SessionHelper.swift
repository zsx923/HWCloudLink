//
//  SessionHelper.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/11/30.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation
import UIKit
import ReplayKit

enum AudioModeType {
    case earphone
    case speaker
}

class SessionHelper {

    // UIDeviceOrientation -> UIInterfaceOrientation
    static func getOrientation() -> UIInterfaceOrientation {
        switch DeviceMotionManager.sharedInstance()?.lastOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
    
    // 1-4   获取网络信号图片
    static func getSignalImage(recvLossPercent: Float) -> UIImage? {
        let singalLevel = UInt(100 - recvLossPercent)
        var level = 4
        switch singalLevel {
        case 0..<25:
            level = 1
        case 25..<50:
            level = 2
        case 50..<75:
            level = 3
        case 75..<100:
            level = 4
        default:
            level = 4
        }
        return UIImage(named: "session_video_signal\(level)")
    }
    
    // 0-5 信号质量显示
    static func getSignalQualityImage(netLevel: String) -> UIImage? {
        switch netLevel {
        case "4","5":
            return UIImage(named: "icon_signal_1")
        case "2","3":
            return UIImage(named: "icon_signal_2")
        case "0","1":
            return UIImage(named: "icon_signal_3")
        default:
            return UIImage(named: "icon_signal_1")
        }
    }
    
    // 会议id每N位加一个空格, 默认4个
    static func setMeetingIDType(meetingId: String, divideCount: Int = 4) -> String {
        var tmpMeetingId:String = meetingId
        
        if tmpMeetingId.hasPrefix("9000") {
            tmpMeetingId = tmpMeetingId.subString(from: 4)
        }
        var count:Int = 0
        var doneTitle:String = ""
        for i in 0 ..< tmpMeetingId.count {
            count = count + 1
            let startIndex = tmpMeetingId.index(tmpMeetingId.startIndex, offsetBy: i)
            let endIndex =  tmpMeetingId.index(tmpMeetingId.startIndex, offsetBy: i+1)
            let newStr = String(tmpMeetingId[startIndex..<endIndex])
            doneTitle = doneTitle+newStr
            if count == divideCount {
                doneTitle = doneTitle + " "
                count = 0
            }
        }
        return doneTitle
    }
    
    // 拨号盘间隔设置
    static func setCallKeyType(meetingId: String, divideCount: Int = 4) -> String {
        let tmpMeetingId:String = meetingId
        var count:Int = 0
        var doneTitle:String = ""
        for i in 0 ..< tmpMeetingId.count {
            count = count + 1
            let startIndex = tmpMeetingId.index(tmpMeetingId.startIndex, offsetBy: i)
            let endIndex =  tmpMeetingId.index(tmpMeetingId.startIndex, offsetBy: i+1)
            let newStr = String(tmpMeetingId[startIndex..<endIndex])
            doneTitle = doneTitle+newStr
            if count == divideCount {
                doneTitle = doneTitle + " "
                count = 0
            }
        }
        return doneTitle
    }
    
    
    static func isHeadSetPlugging() -> AudioModeType {
        
        let route = AVAudioSession.sharedInstance().currentRoute
        for desc in route.outputs {
         if desc.portType == .headphones
                || desc.portType == .bluetoothA2DP
                || desc.portType == .bluetoothHFP
                || desc.portType == .bluetoothLE {
             return .earphone
            }
        }
         return .speaker
    }
    
    // 播放铃声
    static func  mediaStartPlayWithMediaName(name:String, isSupportVibrate: Bool) {
        // 播放铃声ring_back
        let isPlay = NSObject.startSoundPlayer(withFileName: name, isSupportVibrate: isSupportVibrate)
        CLLog("播放铃声 \(isPlay ? "true" : "false")");
    }
    
    // 停止播放铃声
    static func stopMediaPlay() {
        let isStop = NSObject.stopSoundPlayer()
        CLLog("停止播放铃声 \(isStop ? "true" : "false")")
    }
    
    
    
}

