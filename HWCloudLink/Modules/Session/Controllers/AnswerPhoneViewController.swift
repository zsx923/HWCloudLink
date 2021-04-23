//
//  AnswerPhoneController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/10.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

@objcMembers
class AnswerPhoneViewController: UIViewController {
    
    var callInfo: CallInfo?
    private var abnormalTimer: Timer?
    fileprivate var isVideoCall = false
        
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var callStatusLabel: UILabel!
    
    @IBOutlet weak var cancelCallBtn: UIButton!
    
    @IBOutlet weak var sureCallBtn: UIButton!
    
    @IBOutlet weak var voiceReceiveCallBtn: UIButton!
    
    fileprivate let sizeIcon = 24
    // 当前通话秒数
    fileprivate var currentCalledSeconds: Int = 0
    
    private var isClickVideoBtn: Bool = false
    fileprivate var timer: Timer?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ManagerService.contactService()?.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        // Do any additional setup after loading the view.
        self.isVideoCall = self.callInfo?.stateInfo.callType == CALL_VIDEO
        // 初始化
        self.setViewUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallDestory(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_CALL_DESTROY), object: nil)

        //会议结束
        NotificationCenter.default.addObserver(self, selector: #selector(cancelCallBtnClick), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_ENDED), object: nil)
        
        //通话建立的通知，用来获取 callinfo 信息。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallConnected), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_CONNECTED), object: nil)

        
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            self.currentCalledSeconds += 1
        })
    }


    @objc func notificationCallConnected(notification: Notification) {
        // 进入会场
        let meetInfo = ConfBaseInfo.init()
        meetInfo.confId = self.callInfo?.serverConfId
        meetInfo.callId = Int32((self.callInfo?.stateInfo.callId)!)
        meetInfo.accessNumber = self.callInfo?.stateInfo.callNum
        meetInfo.generalPwd = ""
        meetInfo.scheduleUserName = self.callInfo?.stateInfo.callName
        meetInfo.mediaType = self.callInfo?.stateInfo.callType == CALL_AUDIO ? CONF_MEDIATYPE_VOICE : CONF_MEDIATYPE_VIDEO
        meetInfo.isConf = (self.callInfo?.isFocus) == true
//        meetInfo.is_conf = (self.callInfo?.isFocus)! == 1
        meetInfo.isComing = true
        meetInfo.isImmediately = true
        // 点对点
        CLLog("页面 dissmiss")
        self.dismiss(animated: false) {
            if self.isVideoCall {
                SessionManager.shared.jumpConfMeetVC(sessionType: .p2pVideo, meetInfo: meetInfo, animated: false)
            } else {
                SessionManager.shared.jumpConfMeetVC(sessionType: .p2pVoice, meetInfo: meetInfo, animated: false)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            NotificationCenter.default.post(name: NSNotification.Name.init(CALL_S_CALL_EVT_CALL_CONNECTED), object: nil, userInfo: notification.userInfo)
        }
        
    }
    @objc func notificationCallOutgoing(notification: Notification) {
        CLLog("voice >> CALL_OUTGOING")
        guard let resultInfo = notification.userInfo else {
            CLLog("notificationCallOutgoing 呼出失败")
            return
        }
        self.callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
    }
    

    
    // MARK: call 销毁通知
    @objc func notificationCallDestory(notification: Notification) {
        //被叫超时，SDK主动挂断
        self.cancelCallBtnClick("10")
    }
    
    // MARK: notification 被叫销毁消息通知
    @objc func notifcationSdkComingEndCall(notification: Notification) {
        self.cancelCallBtnClick("20")
    }
    
    func setViewUI() {
        // set top image bottom text
        self.voiceReceiveCallBtn.setImageName("phone", title: tr("语音接听"))
        
        if self.isVideoCall {
            // 视频
            self.sureCallBtn.setImage(UIImage.init(named: "session_receive_videocall"), for: .normal)
        } else {
            // 语音
            self.voiceReceiveCallBtn.isHidden = true
        }
        
        // 被叫时需要默认开启扬声器
        CallMeetingManager().openSpeaker()
        if (self.callInfo?.isFocus) == true {
            let callName = self.callInfo?.stateInfo.callName ?? ""
            self.userNameLabel.text = NSString.dealMeetingId(withSpaceString: callName)
        } else { // 点对点语音
            let callName = self.callInfo?.stateInfo.callName
            let callNum = self.callInfo?.stateInfo.callNum
            
            //TODO: 当前测试要求从始至终返回SIP信息，但实际企业通讯录的查询结果，下个版本会用到
            
            if callNum == callName || callName == nil || callName == "" { // 返回一样 企业通讯录查询
                self.userNameLabel.text = callNum
                ManagerService.contactService()?.delegate = self
                let search = SearchParam.init()
                search.keywords = callNum
                search.curentBaseDn = ""
                search.sortAttribute = ""
                ManagerService.contactService()?.searchLdapContact(with: search)
            } else {
                self.userNameLabel.text = (callName != nil) ? callName : callNum
            }
        }

        //设置背景
        let userCardStyle = getCardImageAndColor(from: self.callInfo?.stateInfo.callName ?? "")
        self.avatarImageView.image = userCardStyle.cardImage
        self.avatarImageView.alpha = 0.3
//        self.view.backgroundColor = userCardStyle.textColor
        
//        let showStatus = (self.callInfo?.isFocus == true) ? "会议" : "通话"
//        self.callStatusLabel.text = self.isVideoCall ? "想与您视频\(showStatus)" : "想与您语音\(showStatus)"
        var text = ""
        if self.isVideoCall == true {
            if self.callInfo?.isFocus == true {
                text = tr("想与您视频会议")
            } else {
                text = tr("想与您视频通话")
            }
        } else {
            if self.callInfo?.isFocus == true {
                text = tr("想与您语音会议")
            } else {
                text = tr("想与您语音通话")
            }
        }
        self.callStatusLabel.text = text
        if APP_DELEGATE.isBackground {
            setupLocalNotiWithText(text: "\(self.userNameLabel.text ?? "")\(self.callStatusLabel.text ?? "")")
        }
    }
    
    private func setupLocalNotiWithText(text: String) {
        let localNotification = UILocalNotification()
        localNotification.alertBody = text
        localNotification.fireDate = Date(timeIntervalSinceNow: 0)
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    // 取消会议来电
    @IBAction func cancelCallBtnClick(_ sender: Any) {
        if self.timer != nil {
            self.timer?.invalidate()
        }
        removeNotificationObserver()

        if self.presentedViewController is TextTitleViewController {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        
        self.dismiss(animated: true) {
            if self.callInfo != nil && (self.callInfo?.isFocus) == true {
                MBProgressHUD.showBottom(tr("会议已结束"), icon: nil, view: nil)
                
                ContactManager.shared.saveContactCallLog(callType: self.isVideoCall ? 2:1, name: (self.callInfo?.stateInfo.callName ?? self.callInfo?.stateInfo.callNum) ?? "", number: self.callInfo?.stateInfo.callNum ?? "", depart: "", isAnswer: false, talkTime: self.currentCalledSeconds, isComing: true)
            } else {
                // 储存未接听的最近通话列表（）（被呼叫，别人挂断）（被呼叫， 自己挂断）（被呼叫  接听后别人挂断）
                ContactManager.shared.saveContactCallLog(callType: self.isVideoCall ? 2:1, name: (self.callInfo?.stateInfo.callName ?? self.callInfo?.stateInfo.callNum) ?? "", number: self.callInfo?.stateInfo.callNum ?? "", depart: "", isAnswer: false, talkTime: self.currentCalledSeconds, isComing: true)
                
                if sender is UIButton { // 主动点击
                    MBProgressHUD.showBottom(tr("通话已结束"), icon: nil, view: nil)
                } else { // 被动接受挂断
                    let retMessage = tr("通话已结束")
                    MBProgressHUD.showBottom(retMessage, icon: nil, view: nil)
                }
            }
        }
        SessionManager.shared.isSelfPlayConf = false
//        ManagerService.confService()?.rejectConfCall()
        ManagerService.call()?.closeCall((self.callInfo?.stateInfo.callId)!)
    }
    
    // 接听会议来电
    @IBAction func sureCallBtnClick(_ sender: UIButton) {

        isClickVideoBtn = self.isVideoCall == true
        stopAbnormalTimer()
        
        if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
            self.getAuthAlertWithAccessibilityValue(value: "10")
            return
        }
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        
        if self.timer != nil {
            self.timer?.invalidate()
        }
//        removeNotificationObserver()
       // 接听
        ManagerService.call()?.answerComingCall(self.isVideoCall ? CALL_VIDEO : CALL_AUDIO, callId: (self.callInfo?.stateInfo.callId)!)
//        ManagerService.confService()?.acceptConfCallIsJoinVideoConf(self.isVideoCall)
        ManagerService.call()?.currentCallInfo = self.callInfo
       
        
//        print("****************************** ",self.callInfo?.stateInfo.callType.rawValue,self.isVideoCall)
        
        CLLog("进入会场会议类型 - \(String(describing: self.callInfo?.stateInfo.callType.rawValue))")

//        let meetInfo = ConfBaseInfo.init()
//        meetInfo.confId = self.callInfo?.serverConfId
//        meetInfo.callId = Int32((self.callInfo?.stateInfo.callId)!)
//        meetInfo.accessNumber = self.callInfo?.stateInfo.callNum
//        meetInfo.generalPwd = ""
//        meetInfo.scheduleUserName = self.callInfo?.stateInfo.callName
//        meetInfo.mediaType = self.callInfo?.stateInfo.callType == CALL_AUDIO ? CONF_MEDIATYPE_VOICE : CONF_MEDIATYPE_VIDEO
//        meetInfo.isConf = (self.callInfo?.isFocus) == true
////        meetInfo.is_conf = (self.callInfo?.isFocus)! == 1
//        meetInfo.isComing = true
//        meetInfo.isImmediately = true
        
        
        if (self.callInfo?.isFocus) == true {
            MBProgressHUD.showMessage(tr("正在加入会议") + "...")
            let number = ManagerService.call()?.terminal

            if !SessionManager.shared.isCurrentMeeting {
                startAbnormalTimer()
            }
            CLLog("加入会议需要 - number:\(number ?? "") - serverConfId:\(self.callInfo?.serverConfId ?? "") - callNum\(self.callInfo?.stateInfo.callNum ?? "")")
            // 会议
            self.dismiss(animated: true) {

            }
        }
    }
    
    // 转为语音接听
    @IBAction func voiceReceiveCallBtnClick(_ sender: Any) {
        
        isClickVideoBtn = false
        
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        removeNotificationObserver()
        // 接听
        ManagerService.call()?.answerComingCall(CALL_AUDIO, callId: (self.callInfo?.stateInfo.callId)!)
        ManagerService.call()?.currentCallInfo = self.callInfo
        
        // 视频会议来电,语音接听直接返回,通过通知进会
        if self.callInfo?.isFocus ?? false {
            CLLog("视频会议来电,接听语音会议")
            self.dismiss(animated: true) {
                MBProgressHUD.showMessage(tr("正在加入会议") + "...")

            }
            return
        }
        
        // 进入会场
        let meetInfo = ConfBaseInfo.init()
        meetInfo.confId = self.callInfo?.serverConfId
        meetInfo.callId = Int32((self.callInfo?.stateInfo.callId)!)
        meetInfo.accessNumber = self.callInfo?.stateInfo.callNum
        meetInfo.generalPwd = ""
        meetInfo.mediaType = CONF_MEDIATYPE_VOICE
        meetInfo.isConf = (self.callInfo?.isFocus) == true
        meetInfo.isComing = true
        meetInfo.isImmediately = true
        meetInfo.nameForVoice = callInfo?.stateInfo.callName
        
        self.dismiss(animated: false) {
            SessionManager.shared.jumpConfMeetVC(sessionType: .p2pVoice, meetInfo: meetInfo, animated: false)
        }
    }

    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CallMeetingManager().openSpeaker()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        UIDevice.switchNewOrientation(.portrait)
        APP_DELEGATE.rotateDirection = .portrait
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .lightContent
        
        //增加渐变色
        contentView.backgroundColor = UIColor.gradient(size: CGSize(width: kScreenWidth, height: kScreenHeight), direction: .default, start: UIColor(white: 0, alpha: 0.3), end: UIColor(white: 0, alpha: 1))
        
        // 播放铃声
        SessionHelper.mediaStartPlayWithMediaName(name: "ringing.wav", isSupportVibrate: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.switchNewOrientation(.portrait)
//        APP_DELEGATE.isAllowRotate = false
        APP_DELEGATE.rotateDirection = .portrait
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.statusBarStyle = .default
        
        // 结束铃声
        SessionHelper.stopMediaPlay()
    }


    deinit {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        removeNotificationObserver()
    }
    
    func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /*** static function */
    
    /// 结束通知提示
    /// - Parameter isConf: 是否是会议
    static func showEndConfTip(isConf: Bool) {
        if isConf {
            MBProgressHUD.showBottom(tr("会议已结束"), icon: nil, view: nil)
        } else {
            MBProgressHUD.showBottom(tr("结束通话"), icon: nil, view: nil)
        }
        
    }
}

//根据终端号查询名字
extension AnswerPhoneViewController: TUPContactServiceDelegate {
    func contactEventCallback(_ contactEvent: TUP_CONTACT_EVENT_TYPE, result resultDictionary: [AnyHashable: Any]!) {
        if contactEvent == CONTACT_E_SEARCH_LDAP_CONTACT_RESULT {
            let res = resultDictionary[TUP_CONTACT_EVENT_RESULT_KEY] as! Bool
            if !res {
                CLLog("Search ldap contact failed!")
            }
            let contactList = resultDictionary[TUP_CONTACT_KEY] as! [LdapContactInfo]
            print("contactList count =", contactList.count)
            if contactList.count == 0 {
                CLLog("contactList Empty")
                return
            }
            
            //遍历所搜索到的所有数据
            for searcher in contactList {
                
                if searcher.ucAcc == self.callInfo?.stateInfo.callNum {
                    
//                    self.userNameLabel.text = searcher.name
//                    self.backgroundImageView.image = getUserIconWithAZ(name: searcher.name)
//                    self.backgroundImageView.image = getCardImageAndColor(from: searcher.name).cardImage
                    return
                }
            }
        }
    }
}
extension AnswerPhoneViewController {
    func stopAbnormalTimer() {
        CLLog("stopAbnormalTimer")
        self.abnormalTimer?.invalidate()
        self.abnormalTimer = nil
    }
    func startAbnormalTimer() {
        self.stopAbnormalTimer()
        CLLog("startAbnormalTimer")
        self.abnormalTimer = Timer.scheduledTimer(withTimeInterval: 25, repeats: false) { (timer) in
            CLLog("加入会议25s超时")
            DispatchQueue.main.async {
                MBProgressHUD.hide()
            }
        }
    }
}

extension AnswerPhoneViewController: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {

        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("视频接听需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("\(self.isClickVideoBtn ? "视频" : "语音")接听需要开启麦克风权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
    }
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
    }
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        viewVC.dismiss(animated: true) {
            self.cancelCallBtnClick("10")
        }
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
