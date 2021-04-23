//
//  GlobalDefines.swift
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/21.
//  Copyright © 2021 jd.com. All rights reserved.
//


import UIKit
import CocoaLumberjack

@objcMembers
class GlobalDefines: NSObject {
    
    static let shared = GlobalDefines()
    
    /*
     预览图片页面，删除图片，发送通知到反馈页面
     */
    let mine_set_deleteImageView = "deleteImageView"


    // 邀请与会者通知
    let UpdataInvitationAttendee = "UpdataInvitationAttendee"
    // 取消会议通知
    let CancelTheMeetingSuccess = "CancelTheMeetingSuccess"
    // SVC在与会者页面选看成功回调视频页面通知
    let BeWatchSuccessAttendees = "BeWatchSuccessAttendees"
    // SVC与会者页面改变我的摄像头状态
    let MineCameraStateChange = "MineCameraStateChange";
    // SVC与会者页面改变我的麦克风状态
    let MineMicrophoneStateChange = "MineMicrophoneStateChange"

    // SVC小画面点击放大操作
    let SVCSmallWindowZoomChange = "SVCSmallWindowZoomChange"
    // SVC上下会控显示隐藏通知，控制与会者名字偏移
    let SVCParticipantNameOffset = "SVCParticipantNameOffset"


    // 音视频点呼/master页面是否销毁的通知，响应方为小窗口
    let P2PCallDeinitStatus = "P2PCallDeinitStatus"

    // 音视频点呼转换通知
    let P2PCallConvertNotify = "P2PCallConvertNotify"

    //其他端开始共享
    let AUX_RECCVING_SHARE_DATA = "AUX_RECCVING_SHARE_DATA"
    //其他端停止共享
    let AUX_RECCVING_STOP_SHARE = "AUX_RECCVING_STOP_SHARE"
    //本端停止发送共享
    let AUX_SENDING_STOP_SHARE = "AUX_SENDING_STOP_SHARE"

    // 点呼累计通话时间描述更新通知
    let CalledSecondsChange = "CalledSecondsChange"

    // 临时使用
    let userNameAccunt:String = NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) != nil ? NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as! String : ""
    
    // 本地保存摄像头状态。和用户ID关联
    let CurrentUserCameraStatus = "CurrentUserCameraStatus"+(((ManagerService.call()?.isSMC3 ?? false) == false) ? GlobalDefines.shared.userNameAccunt : GlobalDefines.shared.userNameAccunt)
    
    // 本地保存麦克风状态。和用户ID关联
    let CurrentUserMicrophoneStatus = "CurrentUserMicrophoneStatus"+(((ManagerService.call()?.isSMC3 ?? false) == false) ? GlobalDefines.shared.userNameAccunt : GlobalDefines.shared.userNameAccunt)
    
    func CLLog(message: String,
                          level: DDLogLevel = DDDefaultLogLevel,
                          context: Int = 0,
                          file: StaticString = #file,
                          function: StaticString = #function,
                          line: UInt = #line,
                          tag: Any? = nil,
                          asynchronous async: Bool = asyncLoggingEnabled,
                          ddlog: DDLog = .sharedInstance) {
        
        _DDLogMessage(("\(message)"), level: level, flag: .info, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }
}
