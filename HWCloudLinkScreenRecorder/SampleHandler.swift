//
//  SampleHandler.swift
//  HWCloudLinkScreenRecorder
//
//  Created by yuepeng on 2021/2/1.
//  Copyright © 2021 陈帆. All rights reserved.
//

import ReplayKit
private let hWCloudLinkScreenRecorderGroup = "group.com.isoftstone.cloudlink"
private let GROUP_PATH :String = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: hWCloudLinkScreenRecorderGroup)!.absoluteString
private let VEDIO_MMPS_PATH:String = GROUP_PATH  + "vedio_tmp.txt"
private var videoQueue = DispatchQueue(label: "com.isoftstone.cloudlink.screenRecorder")
private let VEDIO_MMPS_SIZE =  (1024 * 1024 * 16)
private let VEDIO_MMPS_EXT_SIZE =  (1024 * 1024 * 6)
private var  bufferIndex:Int = 0
let sampleBufferTool:ProcessSampBuffer = ProcessSampBuffer()

class SampleHandler: RPBroadcastSampleHandler {
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // 添加录屏监听
        self.registerObserver()
        // 开启共享录屏
//        sampleBufferTool.vedio_mmps = video_mmps
        self.postNotifyWithName(notiryIdf: "ExtentionRecordStart")

    }
    
    override func broadcastPaused() {
        self.postNotifyWithName(notiryIdf: "ExtentionRecordPause")
        bufferIndex = 0
    }
    
    override func broadcastResumed() {
        self.postNotifyWithName(notiryIdf: "ExtentionRecordResumed")
    }
    
    override func broadcastFinished() {
//        YBTimer.cancelTask(timerName)
        self.postNotifyWithName(notiryIdf: "ExtentionRecordFinished")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        
        bufferIndex += 1;
        if bufferIndex >= 500 {
            self.postNotifyWithName(notiryIdf: "ExtentionRecordSampleBufferUpdate")
            bufferIndex = 0
        }
        
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            sampleBufferTool.sampleHeandlerProcessSampBuffer(sampleBuffer)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    
    func registerObserver() {
        // Void pointer to `self`:
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            { (_, observer, name, _, _) -> Void in
                // 被抢了共享
                if name == CFNotificationName.init("STOPSHARED" as CFString) {
                    // Extract pointer to `self` from void pointer:
                    let mySelf = Unmanaged<SampleHandler>.fromOpaque(observer!).takeUnretainedValue()
                    mySelf.finishBroad()
                }
            },
            "STOPSHARED" as CFString,
            nil,
            .deliverImmediately)
    }
    
    // 结束共享
    func finishBroad() {
        let langage = Locale.preferredLanguages.first ?? "en"
        let isCN = langage .hasPrefix("zh")
        let warnInfo = NSDictionary.init(dictionary: [NSLocalizedFailureReasonErrorKey: isCN ? "您停止了屏幕共享或其它设备已共享" : "You have stopped screen sharing or other devices have been shared"])
        let warnError = NSError.init(domain: NSCocoaErrorDomain, code: 4, userInfo: warnInfo as? [String : Any])
        
        self.finishBroadcastWithError(warnError)
        self.postNotifyWithName(notiryIdf: "ExtentionRecordStop")
    }
}
extension SampleHandler{
    func postNotifyWithName(notiryIdf:String) -> Void {
        let notification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notification, CFNotificationName.init(notiryIdf as CFString), nil, nil, true)
    }
}
