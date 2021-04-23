//
//  SessionManager.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/12/3.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

// 当前是否正在会议状态变更通知
let NOTIFICATION_CURRENT_MEETING_STATUS_CHANGED = NSNotification.Name.init("NOTIFICATION_CURRENT_MEETING_STATUS_CHANGED")

enum SessionType {
    case p2pVoice
    case p2pVideo
    case avcMeeting
    case svcMeeting
    case voiceMeeting
}

/// 辅流数据类型
enum BFCPDataStatus {
    case noBFCP             // 没有辅流数据
    case remoteRecvBFCP     // 接收远端辅流数据
    case localSendBFCP      // 本地发送辅流数据
}

/// 当前会议中展示的视频画面类型
enum MeetingVideoType: Int {
    case showBFCP = 0       // 正在展示辅流
    case showMainVideo      // 正在展示主画面
    case showTwoVideo       // 正在展示二画面
    case showThreeVideo     // 正在展示三画面
    case showFourVideo      // 正在展示四画面
}

@objcMembers
class SessionManager: NSObject, PopTitleNormalViewDelegate {
    
    static let shared = SessionManager()
    
    var isCurrentMeeting = false // 当前是否在开会
    {
        didSet {
            NotificationCenter.default.post(name: NOTIFICATION_CURRENT_MEETING_STATUS_CHANGED, object: isCurrentMeeting)
        }
    }
    var isMeetingVMR = false    // 当前会议是否是虚拟会议
    var cloudMeetInfo = ConfBaseInfo()
    
    var currentAttendeeArray: [LdapContactInfo] = []
    
    var isCameraOpen = false        // 摄像头是否打开(入会默认先关闭)
    var isMicrophoneOpen = false    // 麦克风是否打开(入会默认先关闭)
    var isSelfPlayCurrentMeeting = false //会议发起者
    var chairPassword : String? //主持人密码
    var currentCallId: UInt32 = 0
    var currentCalledSeconds: Int = 0
    var isPolicy:Bool = false
    //是否被动（邀请）入会
    var isBeInvitation = false
    // 是否是自己刚发起的会议
    var isSelfPlayConf = false
    
    var meetingMainVC: MeetingContainerViewController?
    
    //正在选看的
    var watchingAttend: ConfAttendeeInConf?
    
    //是否正在广播
    var isBroadcast: Bool = false
    
    // 是否预约会议
    var isBespeak: Bool = false
    
    // 是否视频呼叫
    private var isVideoCall: Bool = false
    
    // 是否是会议
    var isConf: Bool = false
    
    // 辅流数据类型
    var bfcpStatus = BFCPDataStatus.noBFCP
    // 当前会议中展示的视频画面类型
    var currentShowVideoType = MeetingVideoType.showMainVideo
    
    //xjc 3.0 加入会议取消接听界面,来电接听弹出接听界面冲突,发起3.0会议置为true
    var isJoinImmediately: Bool = false
    
    // 本地视频画面 - 临时
    private var locationVideoView: EAGLView?
    // 大画面 - 临时
    private var videoStreamView: PicInPicView?
    // 通话转换页面,场景  1.语音转视频 2.视频转语音 3.SMC3.0带密码的会议
    private var transformImageView: UIImageView?
    
    func cacheEAGLView(location: EAGLView?, videoStream: PicInPicView?) {
        self.locationVideoView = location
        self.videoStreamView = videoStream
    }
    
    // 跳转会议界面
    func jumpConfMeetVC(sessionType: SessionType, meetInfo: ConfBaseInfo, animated: Bool) {

        DispatchQueue.main.async {
            CLLog("进入会议页面 1 - \(self.isCurrentMeeting ? "true" : "false")")
            if self.isCurrentMeeting {
                CLLog("##已经进入会议页面, 更新")
                self.meetingMainVC?.meetInfo = meetInfo
                self.meetingMainVC?.convertTo(type: sessionType)
                return
            }

            CLLog("进入会议页面 2 - \(self.isCurrentMeeting ? "true" : "false")")
            
            self.isConf = meetInfo.isConf
            
            if self.meetingMainVC?.isShowInWindow ?? false {
                CLLog("##上次页面退出异常")
                SessionManager.shared.meetingMainVC?.dismiss(animated: false, completion: nil)
            }
            
            let vc = MeetingContainerViewController()
            vc.sessionType = sessionType
            vc.meetInfo = meetInfo
            self.meetingMainVC = vc
            let navigationVC = BaseNavigationController.init(rootViewController: vc)
            navigationVC.modalPresentationStyle = .overFullScreen
            navigationVC.modalTransitionStyle = .coverVertical
            
            if sessionType == .avcMeeting || sessionType == .voiceMeeting {
//                if sessionType == .avcMeeting {
//                    APP_DELEGATE.rotateDirection = .landscape
//                    UIDevice.switchNewOrientation(.landscapeRight)
//                }
                ViewControllerUtil.getCurrentViewController().present(navigationVC, animated: false, completion: nil)
            }else {
                ViewControllerUtil.getCurrentViewController().present(navigationVC, animated: animated, completion: nil)
            }
            
            self.isCurrentMeeting = true
        }
    }
    
    // 结束会议和离开会议处理
    func endAndLeaveConferenceDeal(isEndConf: Bool) {
        CLLog("endAndLeaveConferenceDeal")
        // 删除keywindow层上的menuView
        if let subviewArray = UIApplication.shared.keyWindow?.subviews {
            for view in subviewArray {
                if view.classForCoder == YCMenuView.classForCoder(), let menuView = view as? YCMenuView {
                    menuView.dismiss()
                }
            }
        }
        SessionManager.shared.meetingMainVC = nil
        SessionManager.shared.isCurrentMeeting = false
        SessionManager.shared.isMeetingVMR = false
        SessionManager.shared.watchingAttend = nil
        SessionManager.shared.isBeInvitation = false
        SessionManager.shared.chairPassword = ""
        SessionManager.shared.isPolicy = false
        SessionManager.shared.isSelfPlayCurrentMeeting = false
        SessionManager.shared.currentCalledSeconds = 0
        SessionManager.shared.isJoinImmediately = false
        SessionManager.shared.isSelfPlayConf = false
        UserDefaults.standard.setValue(false, forKey: "aux_rec")

        if isEndConf {
            CLLog("结束会议")
            ManagerService.confService()?.confCtrlEndConference()
        } else {
            CLLog("离开会议")
            ManagerService.confService()?.confCtrlLeaveConference()
        }
//        ManagerService.call()?.hangupAllCall() // 解决超时挂断不了问题
        ManagerService.confService()?.restoreConfParamsInitialValue()
        // 是结束会议或离开会议刷新会议列表
        ManagerService.confService()?.obtainConferenceList(withPageIndex: 1, pageSize: PAGE_COUNT_PER)
    }
    
    // 呼叫界面
    func showCallSelectView(name: String?, number: String?, depart: String, vc: UIViewController) {
        let popTitleVC = PopTitleNormalViewController.init(nibName: "PopTitleNormalViewController", bundle: nil)
        popTitleVC.modalTransitionStyle = .crossDissolve
        popTitleVC.modalPresentationStyle = .overFullScreen
        
        popTitleVC.showName = name
        popTitleVC.showNumber = number
        popTitleVC.showDepart = depart
        popTitleVC.isShowDestroyColor = false
        popTitleVC.dataSource = [tr("语音呼叫"), tr("视频呼叫"), tr("取消")]
        
        popTitleVC.customDelegate = self
        popTitleVC.isAllowRote = false
        
        vc.present(popTitleVC, animated: true, completion: nil)
    }
    
    // 直接进行语音或视频点对点呼叫
    func startCall(isVideo: Bool, name: String, number: String, depart: String) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            CLLog("voice or video call is network unavailable.")
            return
        }
        
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        
        // 判断号码是否有问题
        if number == "" {
            MBProgressHUD.showBottom(tr("号码为空，暂不能呼叫"), icon: nil, view: nil)
            return
        }
        
        // 判断是否呼叫自己
        if ManagerService.call()?.terminal == number {
            MBProgressHUD.showBottom(tr("您呼叫的号码正在通话中"), icon: nil, view: nil)
            return
        }
        
        // 进入点对点
        let meetInfo = ConfBaseInfo.init()
        meetInfo.confId = ""
        meetInfo.callId = 0
        meetInfo.accessNumber = number
        meetInfo.scheduleUserName = name
        meetInfo.generalPwd = ""
        meetInfo.isConf = false
        self.isConf = false
        let sessionType: SessionType = isVideo ? .p2pVideo : .p2pVoice
        SessionManager.shared.jumpConfMeetVC(sessionType: sessionType, meetInfo: meetInfo, animated: true)
    }
    
    // MARK: - PopTitleNormalViewDelegate
    // MARK:popTitleNormalViewDidLoad
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController) {
        
    }
    
    // MARK:popTitleNormalViewCellClick
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath) {
        viewVC.dismiss(animated: true) {
            if index.row == 0 {
                self.isVideoCall = false
                if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
                    self.getAuthAlertWithAccessibilityValue(value: "20")
                    return
                }
                // 语音呼叫
                self.startCall(isVideo: false, name: viewVC.showName!, number: viewVC.showNumber!, depart: viewVC.showDepart!)
            } else if index.row == 1 {
                self.isVideoCall = true
                if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
                    self.getAuthAlertWithAccessibilityValue(value: "10")
                    return
                }
                if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
                    self.getAuthAlertWithAccessibilityValue(value: "20")
                    return
                }
                // 视频呼叫
                self.startCall(isVideo: true, name: viewVC.showName!, number: viewVC.showNumber!, depart: viewVC.showDepart!)
            }
        }
    }
    
    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        ViewControllerUtil.getCurrentViewController().present(alertTitleVC, animated: true, completion: nil)
    }
    
    static func showMeetingWarning() {
        MBProgressHUD.showBottom(tr("目前正在会议中"), icon: "", view: nil)
    }
}

extension SessionManager: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("视频呼叫需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("\(self.isVideoCall ? "视频" : "语音")呼叫需要开启麦克风权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
    }
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
    }
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        viewVC.dismiss(animated: true, completion: nil)
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
