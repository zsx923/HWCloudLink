//
//  SuspendWindow.swift
//  SuspendViewDemo
//
//  Created by 冯琦帆 on 2018/7/13.
//  Copyright © 2018年 冯琦帆. All rights reserved.
//  

import UIKit

let radious: CGFloat = 100

protocol SuspendWindowDelegate {
    func captureIndex() -> CameraIndex
    func svcLabelId() -> Int
    func isSVCConf() -> Bool
    func isAuxNow() -> Bool
}

class SuspendWindow: UIWindow,CallServiceDelegate {

    var isAVC = false
    var currentCallId:UInt32 = 0
    fileprivate let space: CGFloat = 10
    var rootVC:UIViewController?
    public var remoteView:UIView?
    fileprivate var roteTimelabel:UILabel?
    // 摄像头类型
    fileprivate var cameraCaptureIndex = CameraIndex.front
    
    fileprivate var mineConfInfo: ConfAttendeeInConf?
    
    public var svcManager = SVCMeetingManager()
    
    init(rootViewController: UIViewController , frame: CGRect, svcManager: SVCMeetingManager?) {
        self.svcManager = svcManager ?? SVCMeetingManager()
        self.rootVC = rootViewController
        super.init(frame: frame)
    }
    
    // MARK 语音代理
    func callEventCallback(_ callEvent: TUP_CALL_EVENT_TYPE, result resultDictionary: [AnyHashable : Any]!) {
        if callEvent == CALL_CLOSE { // 会议结束
            ManagerService.call()?.delegate = nil
            NotificationCenter.default.removeObserver(self)
            self.isHidden = true
            SuspendTool.remove()
            ManagerService.call()?.hangupAllCall()
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
            // TODO: 需要写通话记录
            
        }
    }
    
      required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }
    
    func showAuxShare(viewController:UIViewController)  {
        self.videoRegisterNotify()
        self.backgroundColor = UIColor.gray
        self.windowLevel = UIWindow.Level.alert - 1
        self.screen = UIScreen.main
        self.isHidden = false
        self.layer.cornerRadius = 2.0
        // 添加阴影
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5;//阴影半径，默认3
        
        
        let remoteView = UIView(frame: bounds)
        remoteView.layer.cornerRadius = 2.0
        remoteView.layer.masksToBounds = true
        remoteView.backgroundColor = UIColor.gray
        self.addSubview(remoteView)
        self.remoteView = remoteView

        let callImageView = UIImageView.init()
//        65 x 70
        callImageView.frame = CGRect(x: 22.5, y: 15, width: 25, height: 25)
        callImageView.image = UIImage(named: "session_video_share")
        self.remoteView?.addSubview(callImageView)
        
        let roteTimeLabel = UILabel.init()
        roteTimeLabel.frame = CGRect(x: 0, y: callImageView.bottom+6, width: 65, height: 20)
        roteTimeLabel.textAlignment = .center
        roteTimeLabel.textColor = UIColor(hexString: "6ECE7E")
        roteTimeLabel.font = UIFont.systemFont(ofSize: 15)
        roteTimeLabel.adjustsFontSizeToFitWidth = true
        roteTimeLabel.text = tr("停止共享")
        self.remoteView?.addSubview(roteTimeLabel)
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(didOvicePan(_:)))
        self.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didOauxShareTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    // Mark - 语音界面
    func showVoice(currentTime:Int) {
        
        self.voiceRegisterNotify()
        // 接收语音时长通知
        self.backgroundColor = UIColor.white
        self.windowLevel = UIWindow.Level.alert - 1
        self.screen = UIScreen.main
        self.isHidden = false
        self.layer.cornerRadius = 2.0
        // 添加阴影
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5;//阴影半径，默认3
        
        
        let remoteView = UIView.init(frame: bounds)
        remoteView.layer.cornerRadius = 2.0
        remoteView.layer.masksToBounds = true
        remoteView.backgroundColor = UIColor.white
        self.addSubview(remoteView)
        self.remoteView = remoteView

        // 电话图片
        let callImageView = UIImageView.init()
        callImageView.frame = CGRect(x: 24, y: 21, width: 24, height: 24)
        callImageView.image = UIImage(named: "calling_mini")
        self.remoteView?.addSubview(callImageView)
        
        //  时间
        let roteTimeLabel = UILabel.init()
        roteTimeLabel.frame = CGRect(x: 6, y: callImageView.bottom+6, width: 60, height: 20)
        roteTimeLabel.textAlignment = .center
        roteTimeLabel.textColor = UIColor(hexString: "6ECE7E")
        roteTimeLabel.font = UIFont.systemFont(ofSize: 16)
        roteTimeLabel.adjustsFontSizeToFitWidth = true
        roteTimeLabel.text = NSDate.stringReadStampHourMinuteSecond(withFormatted: currentTime)
        self.remoteView?.addSubview(roteTimeLabel)
        self.roteTimelabel = roteTimeLabel
        
        // 代理
        ManagerService.call()?.delegate = self
    
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(didOvicePan(_:)))
        self.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didOviceTap(_:)))
        self.addGestureRecognizer(tapGesture)
  }
  

    @objc fileprivate func didOviceTap(_ tapGesture: UITapGestureRecognizer) {
        ManagerService.call()?.delegate = nil
        NotificationCenter.default.removeObserver(self)
        self.rootVC?.spread(from: self)
        
      }

    @objc fileprivate func didOauxShareTap(_ tapGesture: UITapGestureRecognizer) {
      
        self.passiveStopShareScreen()
        NotificationCenter.default.removeObserver(self)
        self.rootVC?.spread(from: self)
        
      }
    
      @objc fileprivate func didOvicePan(_ panGesture: UIPanGestureRecognizer) {
        let point = panGesture.translation(in: panGesture.view)
        var originX = self.frame.origin.x + point.x
        if originX < space {
          originX = space
        } else if originX > UIScreen.main.bounds.width - 72 - space {
          originX = UIScreen.main.bounds.width - 72 - space
        }
        var originY = self.frame.origin.y + point.y
        if originY < space {
          originY = space
        } else if originY > UIScreen.main.bounds.height - 90 - space {
          originY = UIScreen.main.bounds.height - 90 - space
        }
        self.frame = CGRect.init(x: originX, y: originY, width: self.bounds.width, height: self.bounds.height)
        if panGesture.state == UIGestureRecognizer.State.cancelled || panGesture.state == UIGestureRecognizer.State.ended || panGesture.state == UIGestureRecognizer.State.failed {
          self.adjustOviceVideoFrameAfterPan()
        }
        panGesture.setTranslation(CGPoint.zero, in: self)
      }

      fileprivate func adjustOviceVideoFrameAfterPan() {
        var originX: CGFloat = space
        if self.center.x < UIScreen.main.bounds.width / 2 {
          originX = space
        } else if self.center.x >= UIScreen.main.bounds.width / 2 {
          originX = UIScreen.main.bounds.width - 72 - space
        }
        UIView.animate(withDuration: 0.25, animations: {
          self.frame = CGRect.init(x: originX, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }) { (complete) in
          SuspendTool.setLatestOrigin(origin: self.frame.origin)
        }
      }
    
    // Mark - 视频
    func showVideo(viewController:UIViewController) {
     
        self.videoRegisterNotify()
        self.backgroundColor = UIColor.black
        self.windowLevel = UIWindow.Level.alert - 1
        self.screen = UIScreen.main
        self.isHidden = false
        self.layer.cornerRadius = 2.0
        self.layer.borderColor = COLOR_LIGHT_GAY.cgColor
        self.layer.borderWidth = 0.5
        // 添加阴影
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5;//阴影半径，默认3

        // 代理
        ManagerService.call()?.delegate = self
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(didVideoPan(_:)))
        self.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didVideoTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        if let delegate = viewController as? SuspendWindowDelegate {
            let remoteView = delegate.isAuxNow() ? EAGLViewAvcManager.shared.viewForBFCP : EAGLViewAvcManager.shared.viewForRemote
            remoteView.frame = self.bounds
            remoteView.layer.cornerRadius = 2.0
            remoteView.layer.masksToBounds = true
            self.addSubview(remoteView)
            self.remoteView = remoteView
            cameraCaptureIndex = delegate.captureIndex()
            guard let callId = ManagerService.call()?.currentCallInfo.stateInfo.callId else { return }
            currentCallId = callId
            if delegate.isAuxNow() {
                self.setShowVideo(isAuxNow:delegate.isAuxNow(), isSVCConf: delegate.isSVCConf(), attendArray: svcManager.attendeeArray)
                return
            }
            if svcManager.isReloadSmallWindow {
                self.setShowVideo(isAuxNow:delegate.isAuxNow(), isSVCConf: delegate.isSVCConf(), attendArray: svcManager.attendeeArray)
            }
        }
    
  }

  @objc fileprivate func didVideoTap(_ tapGesture: UITapGestureRecognizer) {
    self.smalWindowDisMiss()
//    SuspendTool.sharedInstance.origin = self.frame.origin
//    self.rootViewController?.spread(from: self.frame.origin)
//    SuspendTool.remove(suspendWindow: self)
    CLLog("小窗口被点击>>> 下一动作最大化")
  }

  @objc fileprivate func didVideoPan(_ panGesture: UIPanGestureRecognizer) {
    guard let view = panGesture.view else { return }
    
    let point = panGesture.translation(in: panGesture.view)
    var originX = self.frame.origin.x + point.x
    if originX < space {
      originX = space
    } else if originX > UIScreen.main.bounds.width - view.width - space {
      originX = UIScreen.main.bounds.width - view.width - space
    }
    var originY = self.frame.origin.y + point.y
    if originY < space {
      originY = space
    } else if originY > UIScreen.main.bounds.height - view.height - space {
      originY = UIScreen.main.bounds.height - view.height - space
    }
    self.frame = CGRect.init(x: originX, y: originY, width: self.bounds.width, height: self.bounds.height)
    if panGesture.state == UIGestureRecognizer.State.cancelled || panGesture.state == UIGestureRecognizer.State.ended || panGesture.state == UIGestureRecognizer.State.failed {
      self.adjustVideoFrameAfterPan(view)
    }
    panGesture.setTranslation(CGPoint.zero, in: self)
    CLLog("小窗口被拖动位置")            
  }

    fileprivate func adjustVideoFrameAfterPan(_ view: UIView) {
    var originX: CGFloat = space
    if self.center.x < UIScreen.main.bounds.width / 2 {
      originX = space
    } else if self.center.x >= UIScreen.main.bounds.width / 2 {
        originX = UIScreen.main.bounds.width - view.width - space
    }
    UIView.animate(withDuration: 0.25, animations: {
      self.frame = CGRect.init(x: originX, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
    }) { (complete) in
      SuspendTool.setLatestOrigin(origin: self.frame.origin)
    }
  }
    // 会议中 - 更新与会者信息（包括自己）
    fileprivate func refreshAttendeeInfo() -> [ConfAttendeeInConf] {
        // 刷新与会者列表
        guard let attendeeArray = ManagerService.confService()?.haveJoinAttendeeArray as? [ConfAttendeeInConf] else {
            CLLog("suspend window: attendeeArray is nil")
            return []
        }
        
        // 在线的与会者
        var attendArray:[ConfAttendeeInConf] = []
        
        // 获取登录者的accountNumber
        var selfNumber = NSString.getSipaccount(ManagerService.call()?.sipAccount)
        if let selfJoinNumber = ManagerService.confService()?.selfJoinNumber {
            selfNumber = selfJoinNumber
        }
       
        for attendInConf in attendeeArray {
            if [ATTENDEE_STATUS_LEAVED, ATTENDEE_STATUS_NO_EXIST, ATTENDEE_STATUS_BUSY, ATTENDEE_STATUS_NO_ANSWER, ATTENDEE_STATUS_REJECT, ATTENDEE_STATUS_CALL_FAILED].contains(attendInConf.state) {
                continue
            }
            
            // 判断麦克风是否有改变
            if NSString.getSipaccount(attendInConf.participant_id) == selfNumber || attendInConf.isSelf {
                if (self.mineConfInfo != nil) {
                    if self.mineConfInfo?.is_mute != attendInConf.is_mute {
                        self.mineConfInfo = attendInConf
                        // 设置麦克风
                        self.setMicrophoneOpenClose()
                    }
                } else {
                    self.mineConfInfo = attendInConf
                    // 设置麦克风
                    self.setMicrophoneOpenClose()
                }
                continue
            }
            
            // 全部在线的与会者
            attendArray.append(attendInConf)
        }
        
        return attendArray
    }
    
    // 设置小画面麦克风打开和关闭
    func setMicrophoneOpenClose() {
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuto) in
            guard let self = self else { return }
            guard let mineConf = self.mineConfInfo else { return }
            
            if isAuto {  // 已授权麦克风
                ManagerService.call()?.muteMic(mineConf.is_mute, callId: self.currentCallId)
            }else {      // 未授权麦克风
                CLLog("not auth micphone.")
            }
        }
    }
    
    // 设置视频显示的画面
    func setShowVideo(isAuxNow:Bool,isSVCConf: Bool, attendArray:[ConfAttendeeInConf]) {
        if isAuxNow {
            ManagerService.call()?.updateVideoWindow(withLocal: nil, andRemote: nil, andBFCP: remoteView, callId: currentCallId)
            return
        }
        if isSVCConf { // 当前是SVC
            /********** 获取大画面的与会者信息 **********/
            //  与会者数组为0则说明与会者只有自己，return不执行下面方法操作
            svcManager.isReloadSmallWindow = false
            var bigAttendee:ConfAttendeeInConf?
            let broadcastArr:[ConfAttendeeInConf] = attendArray.filter({$0.isBroadcast})
            if broadcastArr.count != 0 {
                bigAttendee = broadcastArr.first
            }
            CLLog("suspendWindow attendArray \(String(attendArray.count))")
            if attendArray.count == 0 {
                bigAttendee = svcManager.mineConfInfo
            } else {
                // 与会者数组不为空则说明不是只有我
                // 一个与会者,先判断是否有广播 有广播则大画面是广播的与会者
                if bigAttendee == nil {
                    if svcManager.watchConfInfo != nil {// 无广播则有没有选看与会者。有选看则大画面是选看的与会者
                        bigAttendee = svcManager.watchConfInfo
                    }else{
                        bigAttendee = svcManager.attendeesPageArray[0].first
                        // 无广播无选看无大画面与会者则展示与会者数字第一个与会者
                        svcManager.bigPictureConfInfo = bigAttendee // 全局保存该与会者
                    }
                }
            }
            // 过滤nil
            guard let bigAttendeetemp = bigAttendee, let remoteViewTemp:EAGLView = remoteView as? EAGLView else { return }
            // 先要选看后才可以关联
            CLLog("svc meet need refresh  ---------------------- 17")
            self.svcManager.currentShowAttendeeArray = [bigAttendeetemp]
            self.svcManager.attendeesPageArray[0] = self.svcManager.currentShowAttendeeArray
            self.svcManager.attendeesIDPageArray[0] = self.svcManager.getCurrentAttendeesID(attendees: self.svcManager.currentShowAttendeeArray)
            svcManager.svcWatchAttendeesAndAddRemoveSvcVideoWindow(currentAttendeeArray: [bigAttendeetemp], Remotes: [remoteViewTemp], callId: self.currentCallId, isBigPicture: true, indexRow: 0, ssrcType: .ssrcFlashback) { (watchResult, attendees) in
            } mcuWatchCompletion: { (mcuResult, attendees) in
            } bindCompletion: { (bindResult, attendees) in
                if bindResult, attendees?.count != 0 {
                    if attendees?.count == self.svcManager.currentShowAttendeeArray.count {
                        self.svcManager.currentShowAttendeeArray = attendees ?? [bigAttendeetemp]
                        self.svcManager.attendeesPageArray[0] = self.svcManager.currentShowAttendeeArray
                        self.svcManager.attendeesIDPageArray[0] = self.svcManager.getCurrentAttendeesID(attendees: self.svcManager.currentShowAttendeeArray)
                    }
                    self.svcManager.bigPictureConfInfo = self.svcManager.currentShowAttendeeArray.first
                }
            }
        } else {
            ManagerService.call()?.updateVideoWindow(withLocal: nil, andRemote: remoteView, andBFCP: nil, callId: currentCallId)
        }
    }
}


// registerNotify
extension SuspendWindow {
    
    func voiceRegisterNotify() {
        
        // 收到转音频通知
        NotificationCenter.default.addObserver(self, selector: #selector(callConvertNotify), name: NSNotification.Name(P2PCallConvertNotify), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(p2pCallDeinitStatusUpdate(notfication:)), name: NSNotification.Name.init(P2PCallDeinitStatus), object: nil)
        
        // 接受通知
        NotificationCenter.default.addObserver(self, selector: #selector(CurrentTimeChange(_:)), name: NSNotification.Name(CalledSecondsChange), object: nil)
        // 与会者列表更新回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAttendeeUpdate(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE), object: nil)
        // 监听是否结束离开会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl2(notification:)), name: NSNotification.Name.init(rawValue:"ENDANDDISMISSAVC"), object: nil)
        
    }
    func videoRegisterNotify() {
        // 收到转音频通知
        NotificationCenter.default.addObserver(self, selector: #selector(callConvertNotify), name: NSNotification.Name(P2PCallConvertNotify), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(p2pCallDeinitStatusUpdate(notfication:)), name: NSNotification.Name.init(P2PCallDeinitStatus), object: nil)
        // 监听是否结束离开会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: nil)
        // 与会者列表更新回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAttendeeUpdate(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE), object: nil)
        // 监听屏幕旋转
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(notfic:)), name: NSNotification.Name(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAuxRecevingShareDa(notification:)), name: NSNotification.Name.init(rawValue:AUX_RECCVING_SHARE_DATA), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAuxRecevingStop(notification:)), name: NSNotification.Name.init(rawValue:AUX_RECCVING_STOP_SHARE), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl(notification:)), name: NSNotification.Name.init(rawValue:"ENDANDDISMISSAVC"), object: nil)
  
    }
    
    @objc private func callConvertNotify(notification: NSNotification) {
        ManagerService.call()?.delegate = nil
        NotificationCenter.default.removeObserver(self)
        self.rootVC?.spread(from: self)
      }
    
    @objc private func notificationAuxRecevingShareDa(notification: NSNotification) {
        CLLog("辅流被抢断，小窗口关闭")
        if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.online {
            self.smalWindowDisMiss()
        }
      }
    
    @objc private func notificationAuxRecevingStop(notification: NSNotification) {
        CLLog("辅流正在共享时停止 MSGID = 2032")
        if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.online {
            self.smalWindowDisMiss()
        }
      }
    
    // 结束或离开会议
    @objc private func notificationQuitToListViewCtrl(notification:NSNotification) {
        SuspendTool.remove()
        SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: true)
        //BUG_FIX yuepeng 小窗口结束时取消GLview绑定
//        ManagerService.call()?.updateVideoWindow(withLocal: nil, andRemote:nil, andBFCP: nil, callId: UInt32(currentCallId))
        CLLog("小窗口时离开会议\\点呼结束")
    }
    
    // 结束或离开会议
    @objc private func notificationQuitToListViewCtrl2(notification:NSNotification) {
        SuspendTool.remove()
        SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: true)
        //BUG_FIX yuepeng 小窗口结束时取消GLview绑定
//        ManagerService.call()?.updateVideoWindow(withLocal: nil, andRemote:nil, andBFCP: nil, callId: UInt32(currentCallId))
        CLLog("小窗口时离开会议\\点呼结束")
    }
    
    
    // 与会者发上生改变
    @objc private func notificationAttendeeUpdate(notification:NSNotification) {
        
        self.updateSmalWindow()
    }
    @objc private func CurrentTimeChange(_ notfic:Notification) {
        roteTimelabel?.text = (notfic.object as! String)
    }
    
//    监听屏幕旋转
    @objc private func deviceOrientationDidChange(notfic:NSNotification) {

        if UIApplication.shared.applicationState != UIApplication.State.active {
            return
        }
        
//        if isAVC {
//            return
//        }
        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        var cameraRotation: UInt = 0
        var displayRotation: UInt = 0
        
        var orientation:UIInterfaceOrientation = .portrait
        if DeviceMotionManager.sharedInstance()?.lastOrientation == UIDeviceOrientation.landscapeLeft {
            orientation = .landscapeLeft
        }else if DeviceMotionManager.sharedInstance()?.lastOrientation == UIDeviceOrientation.landscapeRight {
            orientation = .landscapeRight
        }else if DeviceMotionManager.sharedInstance()?.lastOrientation == UIDeviceOrientation.portraitUpsideDown {
            orientation = .portraitUpsideDown
        }
        DeviceMotionManager.sharedInstance()?.adjustAVCCamerRotation2(&cameraRotation, displayRotation: &displayRotation, byCamerIndex: UInt(cameraCaptureIndex.rawValue), interfaceOrientation: orientation)
        
        guard let callID = ManagerService.call()?.currentCallInfo.stateInfo.callId else { return  }
        currentCallId = callID
        ManagerService.call()?.rotationCameraCapture(cameraRotation, callId: callID, isCameraClose: !SessionManager.shared.isCameraOpen)
        ManagerService.call()?.rotationVideoDisplay(isAVC ? 0 : displayRotation, callId: callID, isCameraClose: !SessionManager.shared.isCameraOpen)
    }
    
    @objc func p2pCallDeinitStatusUpdate(notfication:Notification) {
        
        SuspendTool.remove()
    }
    
    @objc func didVideoTap(notfication:Notification) {
        
        
        self.didVideoTap(UITapGestureRecognizer())
    }
    
}
extension SuspendWindow {
    //被动结束扩展进程
    func passiveStopShareScreen() {
        let cfnotification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(cfnotification, CFNotificationName.init("STOPSHARED" as CFString), nil, nil, true)
        SessionManager.shared.bfcpStatus = .noBFCP
        ManagerService.call()?.stopSendAuxData(withCallId:UInt32(self.currentCallId))
    }
    func smalWindowDisMiss() {
        ManagerService.call()?.delegate = nil
        NotificationCenter.default.removeObserver(self)
        self.rootVC?.spread(from: self)
    }
    
    func updateSmalWindow() {
        if let delegate = rootVC as? SuspendWindowDelegate,
           let _ = self.remoteView as? EAGLView {
            guard let callId = ManagerService.call()?.currentCallInfo.stateInfo.callId else { return  }
            currentCallId = callId
            self.setShowVideo(isAuxNow:delegate.isAuxNow(),isSVCConf: delegate.isSVCConf(), attendArray: self.refreshAttendeeInfo())
        }
    }
}
