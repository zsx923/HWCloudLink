//
//  CallMeetingManager.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/12/4.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation



class CallMeetingManager {
    
    func currentCallInfo() -> CallInfo? {
        return callInfo()?.currentCallInfo
    }
    
    func callInfo() -> CallInterface? {
        return ManagerService.call()
    }
    
    func muteMic(isSelected: Bool, callId: UInt32) {
        CLLog("设置静音 \(isSelected ? "关闭" : "打开")麦克风,帐号 = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        callInfo()?.muteMic(isSelected, callId: callId)
    }
    
    func closeSpeaker() {
        CLLog("closeSpeaker")
        DispatchQueue.global().async {
            self.callInfo()?.configAudioRoute(ROUTE_TYPE.DEFAULT_TYPE)
        }
    }
    
    func openSpeaker() {
        CLLog("openSpeaker")
        DispatchQueue.global().async {
            self.callInfo()?.configAudioRoute(ROUTE_TYPE.LOUDSPEAKER_TYPE)
            
        }
    }
    
    func upgradeAudioToVideoCall(callId: UInt32) {
        CLLog("upgradeAudioToVideoCall callId = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        callInfo()?.upgradeAudioToVideoCall(withCallId: callId)
    }
    
    func hangupAllCall() {
        CLLog("hangupAllCall")
        callInfo()?.hangupAllCall()
    }
    
    func closeCall(callId: UInt32) {
        CLLog("closeCall callId = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        callInfo()?.closeCall(callId)
    }
    
    func replyAddVideoCallIsAccept(isAccept: Bool, callId: UInt32) {
        CLLog("视频请求是否接受 \(isAccept), callId = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        callInfo()?.replyAddVideoCallIsAccept(isAccept, callId: callId)
    }
    
    func obtainMobileAudioRoute() -> ROUTE_TYPE {
        return callInfo()?.obtainMobileAudioRoute() ?? ROUTE_TYPE.DEFAULT_TYPE
    }
    
    func getCallStreamInfo(callId: UInt32) -> Bool {
        return callInfo()?.getCallStreamInfo(callId) ?? false
    }
    
    func getRecvLossFraction() -> Float {
        return callInfo()?.currentCallStreamInfo.videoStream.recvLossFraction ?? 0.0
    }
    
    func startCall(number: String, name: String, type: TUP_CALL_TYPE) {
        CLLog("startCall number = \(NSString.encryptNumber(with: number) ?? ""), name = \(NSString.encryptNumber(with: name) ?? ""), type = \(type)")
        callInfo()?.startCall(withNumber: number, name: name, type: type)
    }
    
    func sipAccount() -> String? {
        return callInfo()?.sipAccount
    }
    
    func sipAccountNumber() -> String {
        let sipAccount = self.sipAccount()
        let array = sipAccount?.components(separatedBy: "@")
        return array?.first ?? ""
    }
    
    func terminal() -> String? {
        CLLog("terminal")
        return callInfo()?.terminal
    }
    
    func sendDTMF(dialNum: String, callId: UInt32) -> Bool {
        CLLog("sendDTMF dialNum = \(String(describing: sendDTMF)), callId = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        return callInfo()?.sendDTMF(withDialNum: dialNum, callId: callId) ?? false
    }
    
    func switchCameraOpen(_ isOpen: Bool, callId: UInt32) -> Bool {
        CLLog("switchCameraOpen isOpen = \(isOpen), callId = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        return callInfo()?.switchCameraOpen(isOpen, callId: callId) ?? false
    }
    
    func switchCameraIndex(_ cameraIndex: CameraIndex, callId: UInt32) {
        CLLog("switchCameraIndex cameraIndex = \(cameraIndex), callId = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        callInfo()?.switchCameraIndex(UInt(cameraIndex.rawValue), callId: callId)
    }
    
    func downgradeVideoToAudioCall(callId: UInt32) {
        CLLog("将视频呼叫转为音频呼叫, callId = \(NSString.encryptNumber(with: String(callId)) ?? "")")
        callInfo()?.downgradeVideoToAudioCall(withCallId: callId)
    }

    func rotationVideo(callId: UInt32, cameraIndex: CameraIndex, showRotation: UIInterfaceOrientation) {
        if UIApplication.shared.applicationState != UIApplication.State.active {
            return
        }
        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        var cameraRotation: UInt = 0
        var displayRotation: UInt = 0
        DeviceMotionManager.sharedInstance()?
            .adjustCamerRotation2(&cameraRotation,
                                  displayRotation: &displayRotation,
                                  byCamerIndex: UInt(cameraIndex.rawValue),
                                  interfaceOrientation: showRotation)
        CLLog("P2P-Video cameraRotation = \(cameraRotation), displayRotation = \(displayRotation)")
        callInfo()?.rotationCameraCapture(cameraRotation, callId: callId, isCameraClose: !SessionManager.shared.isCameraOpen)
        callInfo()?.rotationVideoDisplay(displayRotation, callId: callId, isCameraClose: !SessionManager.shared.isCameraOpen)
    }
    
    func rotationAVCVideo(callId: UInt32, cameraIndex: CameraIndex, showRotation: UIInterfaceOrientation) {
        if UIApplication.shared.applicationState != UIApplication.State.active {
            return
        }

        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        var cameraRotation: UInt = 0
        var displayRotation: UInt = 0
        // 传感器方向
        let sensorRotation = SessionHelper.getOrientation()
        
        DeviceMotionManager.sharedInstance()?
            .adjustAVCCamerRotation2(&cameraRotation,
                                     displayRotation: &displayRotation,
                                     byCamerIndex: UInt(cameraIndex.rawValue),
                                     interfaceOrientation: sensorRotation)
        
        
        CLLog("AVC cameraRotation = \(cameraRotation), displayRotation = \(displayRotation)")
        displayRotation = 0
        
        callInfo()?.rotationCameraCapture(cameraRotation , callId: callId, isCameraClose: !SessionManager.shared.isCameraOpen)
        callInfo()?.rotationVideoDisplay(displayRotation, callId: callId, isCameraClose: !SessionManager.shared.isCameraOpen)
    }
    
    func updateVideoWindow(localView: UIView?, callId: UInt32) {
        callInfo()?.updateVideoWindow(withLocal: localView, andRemote: nil, andBFCP: nil, callId: callId)
    }
    
    func clearVideoWindow(callId: UInt32) {
        callInfo()?.updateVideoWindow(withLocal: nil, andRemote: nil, andBFCP: nil, callId: callId)
    }
    
    func ldapContactInfo() -> LdapContactInfo? {
        return callInfo()?.ldapContactInfo
    }
    func isSMC3() -> Bool {
        return callInfo()?.isSMC3 ?? false
    }
    
    // MARK: - Conf
    func confService() -> ConferenceInterface? {
        return ManagerService.confService()
    }
    
    func currentConfBaseInfo() -> ConfBaseInfo?  {
        return confService()?.currentConfBaseInfo
    }
    
    func confCtrlAddAttendee(toConfercene: [LdapContactInfo]) {
        CLLog("添加选中的与会人, toConfercene count = \(toConfercene.count)")
        confService()?.confCtrlAddAttendee(toConfercene: toConfercene)
    }
    
    func confCtrlMuteAttendee(participantId: String?, isMute: Bool) -> Bool {
        CLLog("控制与会人静音, participantId = \(NSString.encryptNumber(with: participantId) ?? ""), isMute = \(isMute)")
        return confService()?.confCtrlMuteAttendee(participantId, isMute: isMute) ?? false
    }
    
    func joinConference(meetInfo: ConfBaseInfo?, isVideo: Bool) {
        CLLog("joinConference  meetInfo = \(NSString.encryptNumber(with: meetInfo?.confId) ?? ""), isVideo = \(isVideo)")
        confService()?.joinConference(withConfId: meetInfo?.confId,
                                      accessNumber: meetInfo?.accessNumber,
                                      confPassWord: meetInfo?.generalPwd,
                                      joinNumber: callInfo()?.terminal,
                                      isVideoJoin: isVideo  
                                      )
    }
    func selfJoinNumber() -> String? {
        return confService()?.selfJoinNumber
    }
    
    func haveJoinAttendeeArray() -> [ConfAttendeeInConf] {
        return (confService()?.haveJoinAttendeeArray ?? []) as! [ConfAttendeeInConf]
    }
    
    func postponeConferenceTime(seconds: Int) -> Bool {
        return confService()?.postponeConferenceTime(String(seconds / 60)) ?? false
    }
    
    func confCtrlSwitchAuditSitesDir(_ isOneWay: Bool) -> Bool {
        return confService()?.confCtrlSwitchAuditSitesDir(isOneWay) ?? false
    }
    
    // 选看（选看多画面）
    func watchAttendeeNumber(_ number: String) {
        CLLog("选看,帐号 = \(NSString.encryptNumber(with: number) ?? "")")
        confService()?.watchAttendeeNumber(number)
    }
    
    func appShareAttach(_ attachView: UIView) {
        confService()?.appShareAttach(attachView)
    }
    
    func raiseHand(handState: Bool, number: String?) -> Bool {
        CLLog("举手,handState = \(handState) 账号 = \(NSString.encryptNumber(with: number) ?? "")")
        return confService()?.confCtrlRaiseHand(handState, attendeeNumber: number) ?? false
    }
    
    func requestChairman(password: String, number: String?) -> Bool {
        CLLog("申请主持人,账号 = \(NSString.encryptNumber(with: number) ?? "")")
        return confService()?.confCtrlRequestChairman(password, number: number) ?? false
    }
    
    func releaseChairman(_ number: String?) {
        CLLog("释放主持人,账号 = \(NSString.encryptNumber(with: number) ?? "")")
        confService()?.confCtrlReleaseChairman(number)
    }
    
}


