//
//  VoiceMeetingViewController.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/12/1.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import ReplayKit

class VoiceMeetingViewController: MeetingViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var callStatusLabel: UILabel!
      
    @IBOutlet weak var meetingLable: UILabel!
    @IBOutlet weak var netCheckBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var safeImage: UIImageView!
    @IBOutlet weak var titleArrView: UIImageView!
    @IBOutlet weak var topUserName: UILabel!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var miniBtn: UIButton!
    
    private var netLevel:String = "5"
    
    //是否预约会议申请主席
    private var isPrePlayCharm  = false
    
    //用来判断是否真正进会
    private var isRealJoinMeeting = false
    //防止多次刷新
    private var isReFreshmeetingInfo = false
    
    private let netLevelManager = NetLevel()
    
    var updatCallSecondBlock: UpdateCallSecondsBlock? // 如果需要回传数据则使用，否则不用
    
    //右侧navItem点击之后 vc
    private weak var popTitleVC: PopTitleNormalViewController?
    //拨号盘vc
    private weak var numberKeyboardVc: NumberKeyboardController?
    //延长时间vc
    private weak var hourMinutePickerVC: ViewMinutesViewController?
    //信号vc
    private weak var alertSingalVC: AlertTableSingalViewController?

    private weak var alertVC: AlertSingleTextFieldViewController?
    // 静音
    fileprivate var muteBtn = UIButton()
    // 耳机
    fileprivate var listenBtn = UIButton()
    // 与会者
    fileprivate var addUserBtn = UIButton()
    
    @IBOutlet weak var numberPadBtn: UIButton!


    fileprivate var moreBtn = UIButton()

    fileprivate var timer: Timer?
            
    // 当前通话秒数 fileprivate - 设置到转化 需要把当前时长带过来
    var currentCalledSeconds: Int = 1
    var previousRouteType:Bool = false
    fileprivate var attendeeArray: [ConfAttendeeInConf] = []
    fileprivate var mineConfInfo: ConfAttendeeInConf?
    
    // 自己是否在与会者列表中
    private var isMineCloseCall: Bool = false
    
    //延长会议成功之后的文本提示
    private var delayTimeStr: String = ""
    
    // 语音会议是否接听
    private var isAnswerCall: Bool = false
    // 自动申请主持人
    private var isAutoRequestChairman = false
    // 是否申请主持人填写密码弹框
    private  var isPWBullet: Bool = false
    // 是否在当前Controller 解决申请主持人释放弹框问题
    private var isCurrentShow: Bool = true

    private var manager = CallMeetingManager()
    
    /// 是否在入会在后更新一次麦克风
    private var isUpdateMicrophoneState = false
    
    // MARK: - Life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        CLLog("voiceM - viewDidLoad")
        super.viewDidLoad()
        
        //首先隐藏掉会议的标题
        meetingInfo(show: false)
        
        contentView.backgroundColor = UIColor.gradient(size: CGSize(width: kScreenWidth, height: kScreenHeight), direction: .default, start: UIColor(white: 0, alpha: 0.3), end: UIColor(white: 0, alpha: 1))
        // Do any additional setup after loading the view.
        // 初始化
        self.setViewUI()
        
//        if UI_IS_BANG_SCREEN {
//            // 刘海屏
//            self.topShrakConstraint.constant = 50
//        } else {
//            // 普通屏
//            self.topShrakConstraint.constant = 30
//        }
//
        // set navigation
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
  
        installComingAndConfig()
        
        registerNotify()

        initStackView()
        
        self.initDefaultRouter()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CLLog("voiceM - viewDidAppear")
//        self.initDefaultRouter()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        CLLog("VoiceM eetingViewController - viewWillDisappear")
        super.viewWillAppear(animated)

        isCurrentShow = true
        self.setMute(isMute: self.mineConfInfo != nil ? self.mineConfInfo?.is_mute ?? false : true)
//        setInitData()
        
        //靠近耳朵息屏
        closeToTheEarScreen(isProximityMonitoringEnabled: true)
        // 屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
//        self.initDefaultRouter()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        CLLog("VoicM - viewWillDisappear")
        super.viewWillDisappear(animated)
        isCurrentShow = false
        
        //靠近耳朵息屏
        closeToTheEarScreen(isProximityMonitoringEnabled: false)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }

    deinit {
        CLLog("voiceM VoiceMeetingViewController - deinit")

        NotificationCenter.default.removeObserver(self)
        
        // 结束铃声
        SessionHelper.stopMediaPlay()
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    //在没有确认入会前隐藏会议标题等信息
    private func meetingInfo(show: Bool) {
        if show {
            topUserName.isHidden = false
            userNameLabel.isHidden = false
//            stackView.isHidden = false
            safeImage.isHidden = false
            titleArrView.isHidden = false
            miniBtn.isHidden = false
            callStatusLabel.isHidden = false
            netCheckBtn.isHidden = false
        }else{
            topUserName.isHidden = true
            userNameLabel.isHidden = true
//            stackView.isHidden = true
            safeImage.isHidden = true
            titleArrView.isHidden = true
            miniBtn.isHidden = true
            callStatusLabel.isHidden = true
            netCheckBtn.isHidden = true
        }
    }
    
    private func initDefaultRouter() -> Void {
        var defaultRouteType:ROUTE_TYPE = manager.obtainMobileAudioRoute()
        print("tsdk告诉获取到的设备route是：",defaultRouteType.rawValue)
        CLLog("VoiceM get >> routeType >> TSDK 2014 ret\(defaultRouteType.rawValue)(initDefaltRoute)")
        
        switch defaultRouteType {
        case ROUTE_TYPE.HEADSET_TYPE ,ROUTE_TYPE.BLUETOOTH_TYPE :
            self.enterHeadSetModel()
            break
        default:

            self.enterSpeakerModel()
        
            break
        }
        
        //TODO:当前无论是TSDK还是系统自行监听获取到的是否耳机插入状态都是错误的，因此发送0设置命令主动触发
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
           if(false == self.previousRouteType){
            self.enterSpeakerModel()
           }
        }
    }
    
    // MARK: - IBActions
    // 缩小画面
    @IBAction func sharkClick(_ sender: Any) {
        SessionManager.shared.currentCalledSeconds = self.currentCalledSeconds
        self.suspend(coverImageName: "", type: .voice, svcManager: nil)
    }
    
    @objc func muteBtnClick(_ sender: UIButton) {
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone {[weak self] (isAuth) in
            guard isAuth else {
                CLLog("voiceM no microphone auth")
                self?.requestMuteAlert()
                return
            }
            
            guard let selfConf = self?.mineConfInfo else { return }
            
            if  ManagerService.confService()?.confCtrlMuteAttendee(selfConf.number, isMute: !(selfConf.is_mute)) ?? false {
                self?.setMute(isMute: !(selfConf.is_mute))
            }
        }
    }
    
    @objc func listenBtnClick(_ sender: UIButton) {
        CLLog("voiceM listenBtnClick1")
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
//            self.listenBtn.setImageName(normalImg: "bottomicon_speaker1_default", pressImg: "bottomicon_speaker1_press", title: tr("扬声器"))
//            CLLog("voiceM listenBtnClick 2 扬声器")
            manager.openSpeaker()
        } else {
            
//            self.listenBtn.setImageName(normalImg: "icon_receiver_default", pressImg: "icon_receiver_press", title: tr("听筒"))
//            CLLog("voiceM listenBtnClick1 3 听筒")
            manager.closeSpeaker()
        }
    }
    
    @objc func addUserBtnClick(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "JoinUsersViewController", bundle: nil)
        let joinUsersViewVC = storyboard.instantiateViewController(withIdentifier: "JoinUsersView") as! JoinUsersViewController
        joinUsersViewVC.isVideoConf = false
        joinUsersViewVC.mineConfInfo = self.mineConfInfo
        joinUsersViewVC.meettingInfo = self.meetInfo
        self.navigationController?.pushViewController(joinUsersViewVC, animated: true)
    }
    
    // 拨号盘
    @IBAction func numberPadBtnClick(_ sender: Any) {
        let numberKeyboardVc = NumberKeyboardController()
        numberKeyboardVc.delegate = self
        self.numberKeyboardVc = numberKeyboardVc
        numberKeyboardVc.modalPresentationStyle = .overFullScreen
        numberKeyboardVc.modalTransitionStyle = .crossDissolve
        present(numberKeyboardVc, animated: true, completion: nil)
       
    }
    
    @objc func moreBtnClick(_ sender: UIButton) {
        setMenuViewBtnsInfo()
    }
    
    // 挂断打电话响应
    @IBAction func closeCallBtnClick(_ sender: Any) {
        let popTitleVC = PopTitleNormalViewController()
        popTitleVC.modalTransitionStyle = .crossDissolve
        popTitleVC.modalPresentationStyle = .overFullScreen
        
        if self.mineConfInfo != nil && self.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
            popTitleVC.showName = tr("结束或离开会议")
            popTitleVC.isShowDestroyColor = true
            popTitleVC.dataSource = [tr("离开会议"), tr("结束会议"), tr("取消")]
            popTitleVC.subTitleArray = [tr("会议将继续进行，会中将没有主持人"), tr("会议将结束，其他人无法继续会议")]
        } else {
            popTitleVC.showName = tr("您确定要离开会议吗？")
            popTitleVC.isShowDestroyColor = true
            popTitleVC.dataSource = [tr("离开会议"), tr("取消")]
//            popTitleVC.subTitleArray = [tr("会议将继续进行，会中将没有主持人")]
        }
        
        popTitleVC.customDelegate = self
        self.popTitleVC = popTitleVC
        self.present(popTitleVC, animated: true, completion: nil)
    }
    
    //点击信号
    @IBAction func netCheckBtnClick(_ sender: UIButton) {
        
//        refreshSignalButtonImg()
//
//        let alertSingalVC = AlertTableSingalViewController()
//        alertSingalVC.modalPresentationStyle = .overFullScreen
//        alertSingalVC.modalTransitionStyle = .crossDissolve
//        alertSingalVC.isVideoNetCheck = false
//
//        if UInt32((self.meetInfo?.callId)!) != 0 {
//             alertSingalVC.callId = UInt32((self.meetInfo?.callId)!)
//        } else {
//            alertSingalVC.callId = manager.currentCallInfo()?.stateInfo.callId ?? 0
//        }
//        self.alertSingalVC = alertSingalVC
//        present(alertSingalVC, animated: true, completion: nil)
    }
    
    // MARK: - Private
    fileprivate func refreshSignalButtonImg() {
        CLLog("voiceM refreshSignalButtonImg")
        if let meetInfo = self.meetInfo {
            let isSuccess = manager.getCallStreamInfo(callId: UInt32(meetInfo.callId))
            if isSuccess {
//                let signalImg = SessionHelper.getSignalImage(recvLossPercent: manager.getRecvLossFraction())
//                netCheckBtn.setImage(signalImg, for: .normal)
            } else {
                CLLog("voiceM 获取会议中的信号信息失败")
            }
        }
    }
    
    private func autoRequestChairman() {
        CLLog("autoRequestChairman")
        if !manager.isSMC3(), SessionManager.shared.isSelfPlayCurrentMeeting, !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false), let meetInfo = self.meetInfo, !meetInfo.isVmrConf && !SessionManager.shared.isBeInvitation {
            CLLog("smc 2.0 Automatically Chairperson")
            self.isAutoRequestChairman = true // 自动申请主持人
            let _ = ManagerService.confService()?.confCtrlRequestChairman(SessionManager.shared.chairPassword, number: mineConfInfo?.participant_id)
            return
        }
        // smc3.0自己发起的会议申请主席  条件：(自己的会议，与会者中有自己，3.0环境，有会议信息，第一次入会，会议中没有主席)
        if self.manager.isSMC3(), !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false), !SessionManager.shared.isBeInvitation, SessionManager.shared.isSelfPlayCurrentMeeting {
            guard let confBaseInfo = self.meetInfo,
                  let chairmanPwd = confBaseInfo.chairmanPwd,
                  let scheduleUserAccount = confBaseInfo.scheduleUserAccount,
                  let mineConfInfo = self.mineConfInfo,
                  let contactInfo = manager.ldapContactInfo() else {
                return
            }

            if scheduleUserAccount == contactInfo.userName {
                // 发会自动申请主持人
                let _ = self.manager.requestChairman(password: chairmanPwd, number: mineConfInfo.participant_id)
                self.isAutoRequestChairman = true
                CLLog("smc 3.0 Automatically Chairperson")
            }
            return
        }
        
        if let confBaseInfo = self.meetInfo,
           let chairmanPwd = confBaseInfo.chairmanPwd,
           let scheduleUserAccount = confBaseInfo.scheduleUserAccount,
           let mineConfInfo = self.mineConfInfo,
           let contactInfo = manager.ldapContactInfo(), self.manager.isSMC3() {
            CLLog("smc 3.0 Comming Chairperson")
            if scheduleUserAccount == contactInfo.userName, self.manager.isSMC3(), !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) {
                // 发会自动申请主持人
                let _ = self.manager.requestChairman(password: chairmanPwd, number: mineConfInfo.participant_id)
                self.isAutoRequestChairman = true
            }
            return
        }
        
        if UserDefaults.standard.value(forKey: "YUYUELEHUIYI") as? String == "1" && !manager.isSMC3() && !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) {
            isPrePlayCharm = true
            ManagerService.confService()?.confCtrlRequestChairman("", number: mineConfInfo?.participant_id)
            UserDefaults.standard.setValue("", forKey: "YUYUELEHUIYI")
            self.isAutoRequestChairman = true
            CLLog("2.0预约申请主持人")
            return
        }
    }

    override func noStreamAlertAction() {
        CLLog("noStreamAlertAction")
        closeCall(isAnswer: false)
    }
    

    func enterHeadSetModel() {
        self.listenBtn.setImageName(normalImg: "icon_receiver_default", pressImg: "icon_receiver_press", title: tr("耳机"))
        self.listenBtn.isSelected = false
//        self.listenBtn.isEnabled = false
       self.previousRouteType = true
   }
   
   func enterLouderSpeakerModel(){
//        self.listenBtn.isEnabled = true
        manager.openSpeaker()
       self.listenBtn.isSelected = true
        self.listenBtn.setImageName(normalImg: "bottomicon_speaker1_default", pressImg: "bottomicon_speaker1_press", title: tr("扬声器"))
   }
    func enterSpeakerModel() {
       
       self.listenBtn.isSelected = false
       manager.closeSpeaker()
        self.listenBtn.setImageName(normalImg: "icon_receiver_default", pressImg: "icon_receiver_press", title: tr("听筒"))
   }
    
    private func installComingAndConfig() {
        if !isComing() {
            if meetInfo?.isImmediately ?? false {
                self.setCalledViewUI()
            } else {
                // 加入语音会议
                manager.joinConference(meetInfo: meetInfo, isVideo: false)
            }
        } else {
            if meetInfo?.isImmediately ?? false {
                self.callInfo = manager.currentCallInfo()
                self.setCalledViewUI()
            }
        }
    }
    
    private func endMeetingDismissVC(isEndConf: Bool = false) {
        CLLog("endMeetingDismissVC")
        if let meetingInfo = self.meetInfo {
            ContactManager.shared.saveMeetingRecently(meetingInfo: meetingInfo, startTime: "", duration: self.currentCalledSeconds)
        }
        alertVC?.dismiss(animated: false, completion: nil)
        numberKeyboardVc?.dismiss(animated: false, completion: nil)
        popTitleVC?.dismiss(animated: false, completion: nil)
        hourMinutePickerVC?.dismiss(animated: false, completion: nil)
        alertSingalVC?.destroyVC()
        
        SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: isEndConf)
        NotificationCenter.default.removeObserver(self)
        
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        let viewControllerArray = self.navigationController?.viewControllers ?? []
        for vc in viewControllerArray {
            if let joinVC = vc as? JoinUsersViewController {
                joinVC.dismissVC()
            } else if let searchVC = vc as? SearchAttendeeViewController {
                searchVC.dismissVC()
            }
        }
        CLLog("页面 dissmiss")
        self.dismiss(animated: true, completion: nil)
        self.parent?.dismiss(animated: true) {
            CLLog("dismiss")
        }
    }
    
    fileprivate func initStackView() {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        self.muteBtn.frame = frame
        self.muteBtn.addTarget(self, action: #selector(muteBtnClick(_:)), for: .touchUpInside)
        self.listenBtn.frame = frame
        self.listenBtn.addTarget(self, action: #selector(listenBtnClick(_:)), for: .touchUpInside)
        self.addUserBtn.frame = frame
        self.addUserBtn.addTarget(self, action: #selector(addUserBtnClick(_:)), for: .touchUpInside)
        self.addUserBtn.setImageName(normalImg: "bottomicon_sites_default",
                                     pressImg: "bottomicon_sites_press",
                                     disableImg: "bottomicon_sites_press",
                                     title: tr("与会者"))
//        self.numberPadBtn.frame = frame
//        self.numberPadBtn.addTarget(self, action: #selector(numberPadBtnClick(_:)), for: .touchUpInside)
//        self.numberPadBtn.setImageName(normalImg: "bottomicon_keyboard_default",
//                                       pressImg: "bottomicon_keyboard_press",
//                                       title: tr("拨号盘"))
        self.moreBtn.frame = frame
        self.moreBtn.addTarget(self, action: #selector(moreBtnClick(_:)), for: .touchUpInside)
        self.moreBtn.setImageName(normalImg: "bottomicon_more_default",
                                  pressImg: "bottomicon_more_press",
                                  disableImg: "bottomicon_more_press",
                                  title: tr("更多"))
        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(self.muteBtn)
        stackView.addArrangedSubview(self.listenBtn)
        stackView.addArrangedSubview(self.addUserBtn)
//        stackView.addArrangedSubview(self.numberPadBtn)
        stackView.addArrangedSubview(self.moreBtn)
    }
    
    func setViewUI() {
//        self.backgroundImageView.mas_makeConstraints { (make) in
//            make?.top.mas_equalTo()(0)
//            make?.width.mas_equalTo()(SCREEN_WIDTH)
//            make?.height.mas_equalTo()(SCREEN_HEIGHT)
//        }
        self.numberPadBtn.setImageName(normalImg: "bottomicon_keyboard_default",
                                       pressImg: "bottomicon_keyboard_press",
                                       title:"")

        self.view.sendSubviewToBack(self.backgroundImageView)
        self.callStatusLabel.textColor = .white
        self.callStatusLabel.text = "ID: " + NSString.dealMeetingId(withSpaceString: meetInfo?.accessNumber ?? "")
        
        self.leaveBtn.setTitle(tr("离开"), for: .normal)
        self.leaveBtn.layer.borderColor = COLOR_RED.cgColor
        self.leaveBtn.layer.borderWidth = 1.0
        self.leaveBtn.layer.cornerRadius = 2.0
        self.leaveBtn.setTitleColor(UIColor(hexString: "#F34B4B"), for: .normal)
        self.topUserName.isUserInteractionEnabled = true
        self.topUserName.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [weak self](_) in
            self?.presentMeetingInfoAlert()
        }))
//        self.setInitData()
    }


    fileprivate func presentMeetingInfoAlert() {

        let infoVC = MeetingInfoViewController()
        let infoModel = MeetingInfoModel()
        infoModel.type = .voiceMeeting
        infoModel.isProtect = true
//        infoModel.isProtect = (self.meetInfo?.generalPwd ?? "").count != 0 ? true : false // 是否是加密会议
        infoModel.meetingId = NSString.getSipaccount(self.meetInfo?.accessNumber ?? "")
        infoModel.guestPassword = (self.meetInfo?.generalPwd ?? "") // 会议密码
        infoModel.isChairman = self.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN ? true : false // 自己是否是主
//        infoModel.isChairman = ManagerService.confService()?.isHaveChair ?? false
        infoModel.chairmanPassword = (self.meetInfo?.chairmanPwd ?? "")
        infoModel.name = self.meetInfo?.confSubject ?? "" // 会议主题
       // 会议时间
        // 跨天数
        let gapDay = NSDate.gapDayCount(withStartTime: meetInfo?.startTime, endTime: meetInfo?.endTime)
//            let Time = NSString.getReadTime(withStartTime: (self.meetInfo?.startTime)!, andEndTime: (self.meetInfo?.endTime) ?? "")
        let Time = NSString.getReadTime(withStartTime: self.meetInfo?.startTime ?? "", andEndTime: (""))
        let TimeArr:[String] = (Time?.components(separatedBy: "/"))!
        let dayArr:[String] = (TimeArr[2].components(separatedBy: " "))
        let dayStr = dayArr[1].components(separatedBy: "-")[0]
        
       // 会议时间
        if self.meetInfo?.endTime != nil && self.meetInfo?.endTime != ""  {
            
            if gapDay > 0 {
                var allStr:String = ""
                if isCNlanguage() {
                    allStr = TimeArr[1]+"月"+dayArr[0]+tr("日")+" "+dayStr
                } else {
                    allStr = TimeArr[1]+"/"+dayArr[0]+" "+dayStr
                }
                let AttStr = NSMutableAttributedString.init(string: allStr)
                AttStr.setAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#FFFFFF")!,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], range: NSMakeRange(0, allStr.count))
                infoModel.dateStr = AttStr
            }else{
                if isCNlanguage() {
                    infoModel.dateStr = NSAttributedString.init(string: TimeArr[1]+tr("月")+dayArr[0]+tr("日")+" "+dayStr)
                } else {
                    infoModel.dateStr = NSAttributedString.init(string: TimeArr[1]+"/"+dayArr[0]+" "+dayStr)
                }
            }
        }else{
            let allStr:String = TimeArr[1]+tr("月")+dayArr[0]+tr("日")+" "+dayStr
            infoModel.dateStr = NSAttributedString.init(string: tr(allStr + "-") + tr("持续会议"))                                             
        }
        infoModel.netLevel = netLevel
        infoVC.infoModel = infoModel
        infoVC.modalPresentationStyle = .overFullScreen
        infoVC.modalTransitionStyle = .crossDissolve
        infoVC.displayShowRotation = .portrait
        self.present(infoVC, animated: true) {

        }
    }
    func setCalledViewUI() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        // 设置定时器
        self.meetingLable.text = self.getCallTimeDuration()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.currentCalledSeconds += 1
            self.meetingLable.text = self.getCallTimeDuration()
            // 缩小画面语音时长通知
            NotificationCenter.default.post(name: NSNotification.Name("CalledSecondsChange"), object: NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds))
        })
                
        // 结束铃声
        SessionHelper.stopMediaPlay()
    }
    
    private func getCallTimeDuration() -> String {
        let durationString = NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds) as String
        return tr("会议中") + String(format:"  %@", durationString)
    }
    
    func setInitData() {
        // 筛选主持人和自己
        self.refreshAttendeeInfo()
        CLLog("self.meetInfo?.confSubject----\(String(describing: self.meetInfo?.confSubject))")
        self.topUserName.text = self.meetInfo?.confSubject ?? ""
        self.userNameLabel.text = self.meetInfo?.confSubject ?? ""
        self.topUserName.text = "\(self.topUserName.text ?? "")"
        self.userNameLabel.text = "\(self.userNameLabel.text ?? "")(\(self.attendeeArray.count != 0 ? self.attendeeArray.count : 0))"
        let userCardStyle = getCardImageAndColor(from: self.meetInfo?.confSubject ?? "")
        self.backgroundImageView.image = userCardStyle.cardImage
        callStatusLabel.text = "ID: " + NSString.dealMeetingId(withSpaceString: meetInfo?.accessNumber ?? "")
        self.setMute(isMute: self.mineConfInfo != nil ? self.mineConfInfo!.is_mute : true)

        if self.mineConfInfo != nil {
            self.setMute(isMute: self.mineConfInfo!.is_mute)
        }
    }
    
    // 设置麦克风状态
    func setMute(isMute: Bool) {
        let normalImg = isMute ? "icon_mute2_default" : "icon_mute1_default"
        let pressImg = isMute ? "icon_mute2_press" : "icon_mute1_press"
        let disableImg = isMute ? "icon_mute2_disabled" : "icon_mute1_disabled"
        self.muteBtn.setImageName(normalImg: normalImg, pressImg: pressImg,
                                  disableImg: disableImg, title: tr("静音"))
    }
    
    // 挂断
    func closeCall(isAnswer: Bool) {
        
        // 点对点通话
        if self.callInfo == nil {
            showBottomHUD(tr("结束通话"))
            manager.hangupAllCall()
        } else {
            manager.closeCall(callId: self.callInfo?.stateInfo.callId ?? 0)
        }
                
        // 结束铃声
        SessionHelper.stopMediaPlay()

        closeToTheEarScreen(isProximityMonitoringEnabled: false)
        self.endMeetingDismissVC()
    }
    
    private func updateSecondAndVoiceType(_ updateSeconds: Int, silence: Bool) {
        
        
        // TODO: 接收和处理来自设置页面设置的默认入会 设备状态配置（摄像头、麦克风）
        
        //更新扬声器状态
//        let voiceType = manager.obtainMobileAudioRoute()
//        self.listenBtn.isSelected = voiceType == ROUTE_TYPE.LOUDSPEAKER_TYPE ? false : true
//        listenBtnClick(self.listenBtn)
        //更新静音状态
        manager.muteMic(isSelected: silence, callId: UInt32(self.callInfo?.stateInfo.callId ?? 0))
        self.setMute(isMute: silence)
    }
    
    //第一次更新静音按钮状态
    private func setMicrophoneOpenClose() {
        
        guard let selfConf = self.mineConfInfo else {
            return
        }
        
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuto) in
            guard let self = self else { return }
            if isAuto {  // 已授权麦克风
                if self.mineConfInfo == nil { // 如果与会人中我是空 则设置麦克风位静音
                    if self.manager.confCtrlMuteAttendee(participantId: self.mineConfInfo?.participant_id, isMute: true) {
                        self.mineConfInfo?.is_mute = true
                        self.setMute(isMute: true)
                    }
        
                }else {  // 与会人我不为空
                    if self.mineConfInfo?.is_mute == false, UserDefaults.standard.bool(forKey: CurrentUserMicrophoneStatus) == true  { //客户开，服务开才为开
//                        ManagerService.confService()?.confCtrlMuteAttendee(NSString.getSipaccount(self.svcManager.mineConfInfo?.number), isMute: self.muteButton.isSelected)
                        self.setMute(isMute: false)
                    }else  { //客户关，服务开，为关
                        if  ManagerService.confService()?.confCtrlMuteAttendee(selfConf.number, isMute: true) ?? false {
                            self.mineConfInfo?.is_mute = true
                            self.setMute(isMute: true)
                        }
                    }
                }
//                SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
            }else {      // 未授权麦克风
                if ManagerService.confService()?.confCtrlMuteAttendee(selfConf.number, isMute: true) ?? false {
                    self.mineConfInfo?.is_mute = true
                    self.setMute(isMute: true)
                }
            }
        }
    }
    
    // MARK: - 通知
    fileprivate func registerNotify() {
        //是否真正进会
        NotificationCenter.default.addObserver(self, selector: #selector(notficationRealJoinMeeting(notification:)), name: NSNotification.Name.init(CALL_S_CONF_BASEINFO_UPDATE_KEY), object: nil)
        //举手主席提示
        NotificationCenter.default.addObserver(self, selector: #selector(notficationHandUpResult(notification:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_HAND_UP_IND), object: nil)
        //查看音视频会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationLookAudioAndVideoQualityViewCtrl), name: NSNotification.Name(LookAudioAndVideoQualityNotifiName), object: nil)
        // 与会者列表更新回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAttendeeUpdate(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE), object: nil)
        // 延长会议回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationExtensionConfLen(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_E_CONF_POSTPONE_CONF), object: nil)
        // 邀请选中与会者通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdateSelectedAttendee(notification:)), name: NSNotification.Name.init(rawValue: UpdataInvitationAttendee), object: nil)
        // 结束通话
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationListenListenChange(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_CALL_ROUTE_CHANGE), object: nil)
        // 申请主持人通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRequestChairman), name: NSNotification.Name(CALL_S_CONF_REQUEST_CHAIRMAN), object: nil)
        // 释放主持人通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReleaseChairman), name: NSNotification.Name(CALL_S_CONF_RELEASE_CHAIRMAN), object: nil)
        
        // 与会者举手
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSetHandup), name: NSNotification.Name(CALL_S_CONF_SET_HANDUP), object: nil)
        
        // 音频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationAudioQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_AUDIO_NET_QUALITY), object: nil)
        
        // 上报设备状态
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallDeviceState(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_DEVICE_STATE), object: nil)
    }
    
    // 设备信息上报
    @objc func notificationCallDeviceState(notfication:Notification) {
        guard let userInfo = notfication.userInfo, let deviceInfo = userInfo[CALL_S_CONF_EVT_DEVICE_STATE] else {
            CLLog("- 设备信息获取为空 -")
            return
        }
        guard let selfConf = self.mineConfInfo else { return }
        // 跟新CallID
        let deviceModel:ConfDeviceInfo? = (deviceInfo as? ConfDeviceInfo) ?? ConfDeviceInfo()
        ManagerService.call()?.currentCallInfo.stateInfo.callId = deviceModel?.callId ?? 0
        ManagerService.confService()?.currentConfBaseInfo.callId = Int32(deviceModel?.callId ?? 0)
        self.callInfo = manager.currentCallInfo()
        self.meetInfo = manager.currentConfBaseInfo()
        
        CLLog("设备信息上报 \(deviceModel?.mj_JSONString() ?? "")")
        // 设置扬声器
        switch deviceModel?.speaker_type.rawValue {
        case 0: // 扬声器关闭
            self.listenBtn.isSelected = true
            self.listenBtnClick(self.listenBtn)
        case 1: // 扬声器开启
            self.listenBtn.isSelected = false
            self.listenBtnClick(self.listenBtn)
        case 2:
            CLLog("CONF_SPEAKER_BUTT")
        default:
            print("speaker_type default")
        }
        // 设置麦克风
        switch deviceModel?.mic_type.rawValue {
        case 0 : //  麦克风关闭
            if  ManagerService.confService()?.confCtrlMuteAttendee(selfConf.number, isMute: true) ?? false {
                self.setMute(isMute: true)
            }
        case 1:  //  麦克风打开
            if  ManagerService.confService()?.confCtrlMuteAttendee(selfConf.number, isMute: false) ?? false {
                self.setMute(isMute: false)
            }
        case 2:
            CLLog("CONF_MIC_BUTT")
        default:
            print("mic_type default")
        }
    }
    
    @objc func notficationRealJoinMeeting(notification:Notification) {
        
        // 真正进会了
        CLLog("----------------- notficationRealJoinMeeting")
        if !isReFreshmeetingInfo {
            isReFreshmeetingInfo = true
            isRealJoinMeeting = true
            if let confInfo = manager.currentConfBaseInfo() {
                self.meetInfo = confInfo
            }
            
            CLLog("self.meetInfo?.confSubject:\(String(describing: self.meetInfo?.confSubject))")

            self.topUserName.text = self.meetInfo?.confSubject ?? ""
            self.userNameLabel.text = self.meetInfo?.confSubject ?? ""
            self.topUserName.text = "\(self.topUserName.text ?? "")"
            self.userNameLabel.text = "\(self.userNameLabel.text ?? "")(\(self.attendeeArray.count != 0 ? self.attendeeArray.count : 0))"
            // 筛选主持人和自己
            self.refreshAttendeeInfo()
            
        }
    }
    
    @objc func notficationHandUpResult(notification:Notification) {
        guard let noti = notification.userInfo as? [String:String] else {
            return
        }
        let handUpInfo = noti[ECCONF_HAND_UP_RESULT_KEY]
        if self.mineConfInfo?.name != handUpInfo {
            MBProgressHUD.showBottom("\(handUpInfo ?? "")" + tr("正在举手"), icon: nil, view: view)
        }
    }
    
    @objc func notificationLookAudioAndVideoQualityViewCtrl (notification:Notification) {

        refreshSignalButtonImg()

        let alertSingalVC = AlertTableSingalViewController()
        alertSingalVC.modalPresentationStyle = .overFullScreen
        alertSingalVC.modalTransitionStyle = .crossDissolve
        alertSingalVC.isVideoNetCheck = false
//        alertSingalVC.svcManager = SVCMeetingManager()
        if UInt32(self.meetInfo?.callId ?? 0) != 0 {
             alertSingalVC.callId = UInt32(self.meetInfo?.callId ?? 0)
        } else {
            alertSingalVC.callId = manager.currentCallInfo()?.stateInfo.callId ?? 0
        }
        self.alertSingalVC = alertSingalVC
        present(alertSingalVC, animated: true, completion: nil)
        
    }
    @objc func notificationListenListenChange(notification:Notification){
        print("tsdk告诉APProute-2014 状态更新了", notification)
        
        guard let noti = notification.userInfo as? [String:String] else {
            return
        }
        
        let routeType = noti[AUDIO_ROUTE_KEY]
        CLLog("voiceM >> notify >>route:\(routeType)(MSG:2014)")
        print("voiceM >>routetype>>>>",routeType)
        switch routeType {
        case "0":
            break
        case "1":
            //扬声器
            self.enterLouderSpeakerModel()
            break
        case "2","4":
            //插入耳机
            self.enterHeadSetModel()
            break
        case "3":
            //拔出耳机
            self.previousRouteType = false
            self.listenBtn.isSelected = false
            self.listenBtn.setImageName(normalImg: "icon_receiver_default", pressImg: "icon_receiver_press", title: tr("听筒"))
            break
        default:
            break
        }
        
    }
    
    // 连接会议回调通知
    @objc func notificationConfConnect(notification: Notification) {
        let meetInfo = manager.currentConfBaseInfo()
        let callInfo = manager.currentCallInfo()
        if callInfo != nil {
            if callInfo?.stateInfo.callType == CALL_VIDEO {
                meetInfo?.mediaType = CONF_MEDIATYPE_VIDEO
            }
        }
        
        if meetInfo != nil {
            // 入会成功
            self.setCalledViewUI()
            self.meetInfo = meetInfo
            self.meetInfo?.isConf = true
        } else {
            showBottomHUD(tr("会议连接失败"))
            self.endMeetingDismissVC()
        }
    }
    
    // 与会者列表更新回调通知
    @objc func notificationAttendeeUpdate(notification: Notification) {
        setInitData()
    }
    
    @objc func notificationExtensionConfLen(notification: Notification) {
        CLLog("notificationExtensionConfLen")
        guard let userInfoCode = notification.userInfo?[ECCONF_RESULT_KEY] as? Int  else {
            showBottomHUD(tr("延长会议失败"), view: self.view)
            return
        }
        if self.delayTimeStr.count > 0 && userInfoCode == 1 {
            showBottomHUD(self.delayTimeStr, view: self.view)
        } else {
            showBottomHUD(tr("延长会议失败"), view: self.view)
        }
    }
    // 邀请选中与会者通知
    @objc func notificationUpdateSelectedAttendee(notification: Notification) {
        // 添加与会者
        if SessionManager.shared.currentAttendeeArray.count > 0 {
            // 升级会议
            manager.confCtrlAddAttendee(toConfercene: SessionManager.shared.currentAttendeeArray)
            SessionManager.shared.currentAttendeeArray.removeAll()
        }
    }
    // 申请释放主持人回调
    @objc func notificationRequestChairman(notification: Notification) {
        CLLog("notificationRequestChairman")
        guard let resultCode = notification.userInfo?[ECCONF_RESULT_KEY] as? NSNumber  else {
            if isCurrentShow {
                showBottomHUD(tr("申请主持人失败"))
            }
            return
        }
        
        if resultCode != 1 && isPrePlayCharm && isCurrentShow {
            isPrePlayCharm = false
            isPWBullet = false
            return
        }
        
        CLLog("notificationRequestChairman  --  resultCode  =====   \(resultCode)")
        
        if resultCode == 67109022 && isCurrentShow {
            isPWBullet = false
            showBottomHUD(tr("会议已存在主持人，暂无法申请主持人"), view: self.view)
            return
        }
        
        if resultCode == 67109023 && isCurrentShow {
            isPWBullet = false
            MBProgressHUD.showBottom(tr("密码错误"), icon: nil, view: self.view)
            return
        }
        
        if resultCode == 1 {
            CLLog("CONF_E_REQUEST_CHAIRMAN_RESULT - 申请主持人")
            if isCurrentShow {
                MBProgressHUD.hide(for: self.view, animated: true)
                showBottomHUD(tr("已申请主持人"), view: self.view)
            }
//            self.mineConfInfo?.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
//            self.isPWBullet = false
        } else if isCurrentShow {
            if !self.isPWBullet {
                let alertVC = AlertSingleTextFieldViewController()
                alertVC.modalTransitionStyle = .crossDissolve
                alertVC.modalPresentationStyle = .overFullScreen
                alertVC.customDelegate = self
                self.alertVC = alertVC
                self.present(alertVC, animated: true) {
                    alertVC.showInputTextField.keyboardType = .numberPad
                    self.isPWBullet = true
                }
            } else {
                showBottomHUD(tr("申请主持人失败"))
                self.isPWBullet = false
            }
        }
    }
    // 申请释放主持人回调
    @objc func notificationReleaseChairman(notification: Notification) {
        CLLog("notificationReleaseChairman")
        if isCurrentShow {
            MBProgressHUD.hide(for: self.view, animated: true)
            guard let resultCode = notification.userInfo?[ECCONF_RESULT_KEY] as? NSNumber  else {
                showBottomHUD(tr("释放主持人失败"))
                return
            }
            if resultCode == 1 {
                CLLog("CONF_E_RELEASE_CHAIRMAN_RESULT - 释放主持人")
                showBottomHUD(tr("主持人已释放"))
            } else {
                showBottomHUD(tr("释放主持人失败"))
            }
        }
    }
    
    @objc func notificationQuitToListViewCtrl(notification: Notification) {
        CLLog("notificationQuitToListViewCtrl")
        self.endMeetingDismissVC()
        
        let object = notification.object as? String
        if object != nil {
            CLLog("voiceM 会议已结束")
            Toast.showBottomMessage(tr("会议已结束"))
        }
    }
    
    private func refreshAttendeeInfo() {
        let attendeeArray = manager.haveJoinAttendeeArray()
        let selfNumber = ManagerService.call()?.sipAccount
        // 特殊处理排除
        var tempAttendeeArray: [ConfAttendeeInConf] = []
        for attendInConf in attendeeArray {
            
            if attendInConf.participant_id == selfNumber || attendInConf.number == selfNumber || NSString.getSipaccount(attendInConf.participant_id) == selfNumber || NSString.getSipaccount(attendInConf.number) == selfNumber || attendInConf.isSelf {
                CLLog("selfNumber = \(selfNumber ?? "") --- attendInConf = \(attendInConf.participant_id ?? "") --- ischairMan === \(attendInConf.role == .CONF_ROLE_CHAIRMAN)")
                self.mineConfInfo = attendInConf
            }
            if ![ATTENDEE_STATUS_LEAVED, ATTENDEE_STATUS_NO_ANSWER,
                 ATTENDEE_STATUS_REJECT, ATTENDEE_STATUS_CALL_FAILED].contains(attendInConf.state) {
                CLLog("获取到的与会者ID：" + NSString.encryptNumber(with: attendInConf.number))
                tempAttendeeArray.append(attendInConf)
            }
        }
        self.attendeeArray = tempAttendeeArray
        
        // 入会后第一次更新摄像头麦克风状态
        if isUpdateMicrophoneState == false && self.mineConfInfo != nil && isRealJoinMeeting {
            CLLog("----------------- isRealJoinMeeting   \(isRealJoinMeeting)")
            CLLog("self.mineConfInfo?.role\(self.mineConfInfo?.role == .CONF_ROLE_CHAIRMAN)")
            if self.mineConfInfo?.role == .CONF_ROLE_CHAIRMAN {
                CLLog("I am CHAIRMAN")
                // 如果进会自己本来就是主席  打开静音
                //根据当前的静音状态重新设置
                isUpdateMicrophoneState = true
                isAutoRequestChairman = true
                
            } else {
                isUpdateMicrophoneState = true
                self.setMicrophoneOpenClose()
                if !self.isAutoRequestChairman {
                    self.autoRequestChairman()
                }
            }
            meetingInfo(show: true)
        }
    }
}

// MARK: 会议密码弹框 - AlertSingleTextFieldViewDelegate,UITextFieldDelegate
extension VoiceMeetingViewController: AlertSingleTextFieldViewDelegate, UITextFieldDelegate {
    func alertSingleTextFieldViewViewDidLoad(viewVC: AlertSingleTextFieldViewController) {
        viewVC.showTitleLabel.text = tr("会议密码")
        viewVC.showInputTextField.isSecureTextEntry = true
        viewVC.showInputTextField.placeholder = tr("请输入1-6位数字密码")
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        viewVC.showInputTextField.delegate = self
    }
    
    // left btn Click
    func alertSingleTextFieldViewLeftBtnClick(viewVC: AlertSingleTextFieldViewController, sender: UIButton) {
        self.isPWBullet = false
    }
    
    // right btn click
    func alertSingleTextFieldViewRightBtnClick(viewVC: AlertSingleTextFieldViewController, sender: UIButton) {
        viewVC.dismiss(animated: true, completion: nil)
        ManagerService.confService()?.confCtrlRequestChairman(viewVC.showInputTextField.text?.count == 0 ? "" : viewVC.showInputTextField.text, number: self.mineConfInfo?.participant_id)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        
        return nowString.count <= 6
    }
}

// MARK: - Menu弹框
extension VoiceMeetingViewController {
    
    fileprivate func getChairmanMoreAction() -> [YCMenuAction] {
        var actionArray: [YCMenuAction] = []
        // 添加释放主持人按钮
        actionArray.append(YCMenuAction(title: tr("释放主持人"), image: nil, handler: { (_) in
            self.releaseChairmanWithAlert(num: self.mineConfInfo?.participant_id)
        }))
        
        if self.meetInfo?.endTime != nil && self.meetInfo?.endTime != "" {
            actionArray.append(YCMenuAction.init(title: tr("延长会议"), image: nil) { (_) in
                CLLog("延长会议")
                // 设置会议时长
                let hourMinutePickerVC = ViewMinutesViewController()
                hourMinutePickerVC.modalPresentationStyle = .overFullScreen
                hourMinutePickerVC.modalTransitionStyle = .crossDissolve
                hourMinutePickerVC.customDelegate = self
                hourMinutePickerVC.title = tr("请选择延长时间")
                self.hourMinutePickerVC = hourMinutePickerVC
                
                self.present(hourMinutePickerVC, animated: true, completion: nil)
            })
        }
        
        actionArray.append(YCMenuAction(title: tr("邀请"), image: nil, handler: { [weak self] (_) in
            guard let self = self else { return }
            let storyboard = UIStoryboard(name: "SearchAttendeeViewController", bundle: nil)
            let searchAttendee = storyboard.instantiateViewController(withIdentifier: "SearchAttendeeView") as! SearchAttendeeViewController
            searchAttendee.meetingCofArr = self.attendeeArray
            self.navigationController?.pushViewController(searchAttendee, animated: true)

        }))
        return actionArray
    }
    
    fileprivate func getAttendeeMoreAction() -> [YCMenuAction] {
        
        var actionArray: [YCMenuAction] = []
        guard let mineConfInfo = self.mineConfInfo else { return actionArray }
        //判断会议中是否有主持人
//        var isHaveChairMan = false
//        for att in self.attendeeArray {
//            if att.role == .CONF_ROLE_CHAIRMAN {
//                isHaveChairMan = true
//            }
//        }
        
        actionArray.append(YCMenuAction(title: tr("申请主持人"),titleColor: (manager.currentConfBaseInfo()?.hasChairman ?? false) ? .lightGray : .white, image: nil, handler: { [weak self] (_) in
            guard let self = self else { return }
            if self.manager.currentConfBaseInfo()?.hasChairman ?? false {
//                self.showBottomHUD(tr("会议已存在主持人，暂无法申请主持人"), view: self.view)
                return
            }
            
            self.isPWBullet = false
            
            if self.manager.isSMC3(), SessionManager.shared.isSelfPlayCurrentMeeting, SessionManager.shared.isMeetingVMR {
                CLLog("smc 3.0 vmr Chairperson----")
               let _ = self.manager.requestChairman(password: self.meetInfo?.chairmanPwd ?? "", number: mineConfInfo.participant_id)
                return
            }
            
            if self.manager.isSMC3(), ManagerService.confService()?.currentConfBaseInfo.accessNumber == ManagerService.confService().vmrBaseInfo?.accessNumber {
                CLLog("smc 3.0 -- vmr Chairperson----")
               let _ = self.manager.requestChairman(password: self.meetInfo?.chairmanPwd ?? "", number: mineConfInfo.participant_id)
                return
            }
            
            if self.manager.isSMC3(), ManagerService.confService()?.currentConfBaseInfo.accessNumber == ManagerService.confService().vmrBaseInfo?.accessNumber {
                CLLog("smc 3.0 -- vmr Chairperson----")
               let _ = self.manager.requestChairman(password: self.meetInfo?.chairmanPwd ?? "", number: mineConfInfo.participant_id)
                return
            }
            
            self.manager.requestChairman(password: "", number: mineConfInfo.participant_id)
        }))
        
        actionArray.append(YCMenuAction(title: mineConfInfo.hand_state ? tr("手放下") : tr("举手"), titleColor: (!(manager.currentConfBaseInfo()?.hasChairman ?? false) && !mineConfInfo.hand_state) ? .lightGray : .white, image: nil) { [weak self] (_) in
            guard let self = self else { return }
            if !(self.manager.currentConfBaseInfo()?.hasChairman ?? false) && !mineConfInfo.hand_state {
//                    self.showBottomHUD(tr("会议无主持人，不能举手"), view: self.view)
            } else {
              let isSuccess = self.manager.raiseHand(handState: !mineConfInfo.hand_state, number: mineConfInfo.number)
                
                if !mineConfInfo.hand_state {
                    self.showBottomHUD(isSuccess ? tr("举手成功") : tr("举手失败"), view: self.view)
                }else {
                    self.showBottomHUD(isSuccess ? tr("取消举手成功") : tr("取消举手失败"), view: self.view)
                }
    
                if isSuccess {
                    mineConfInfo.hand_state = !mineConfInfo.hand_state
                }
            }
        })
        
        return actionArray
    }
    
    // 与会者举手
    @objc func notficationSetHandup(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber],
              let _ = userInfo[CALL_S_CONF_SET_HANDUP] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("会议无主持人，不能举手"), icon: nil, view: self.view)
            return
        }
        MBProgressHUD.showBottom(tr("举手成功"), icon: nil, view: view)
    }
    
    // 音频质量变化
    @objc func notficationAudioQuality(notfication:Notification) {
        guard let level = netLevelManager.getCurrenLevel(isVoice: true, notfication: notfication) else {
            return
        }
    
        // 设置信号强度
        self.netCheckBtn.setImage(level.image, for: .normal)
        netLevel = level.level
        NotificationCenter.default.post(name: NSNotification.Name("NET_LEVEL_UPDATE_NOTIFI"), object: nil, userInfo: ["netLevel": netLevel])
    }

    
    func setMenuViewBtnsInfo() {
        var actionArray: [YCMenuAction] = []
        
        // 会议
        if self.mineConfInfo != nil && self.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
            actionArray = getChairmanMoreAction()
        } else {
            actionArray = getAttendeeMoreAction()
        }
        if actionArray.isEmpty {
            return
        }
        let menu = YCMenuView.menu(with: actionArray, width: 155.0, relyonView: self.moreBtn)
        // config
        menu?.backgroundColor = COLOR_DARK_GAY
        menu?.textAlignment = .center
        menu?.separatorColor = COLOR_GAY
        menu?.maxDisplayCount = 20
        menu?.offset = 0
        menu?.textColor = UIColor.white
        menu?.textFont = UIFont.systemFont(ofSize: 15.0)
        menu?.menuCellHeight = 50.0
        menu?.dismissOnselected = true
        menu?.dismissOnTouchOutside = true
        menu?.show()
    }
}

//MARK: - NumberBoardAble 会议拨号盘相关
extension VoiceMeetingViewController: NumberBoardAble {
    
    func numberBoardText(_ resuleString: String, _ controller: UIViewController) {
        CLLog(resuleString)
        if resuleString == "" {
            return
        }
        CLLog("voiceM >> sendDTMF  +  \(resuleString)")
        manager.sendDTMF(dialNum: resuleString, callId: manager.currentCallInfo()?.stateInfo.callId ?? 0)
        if resuleString == "#" {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - PopTitleNormalViewDelegate
extension VoiceMeetingViewController: PopTitleNormalViewDelegate {
    
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController) {
        
    }
    
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath) {
       
        // 退出语音会议
        viewVC.dismiss(animated: true, completion: nil)
        if index.row == 0 {
            // 离开会议
            Toast.showBottomMessage(tr("离开会议"))
            self.endMeetingDismissVC()
        } else if index.row == 1 {
            // 结束会议
            Toast.showBottomMessage(tr("会议已结束"))
            self.endMeetingDismissVC(isEndConf: true)
        }
    }
}

// MARK: - ViewOnlyMinuteDelegate
extension VoiceMeetingViewController: ViewOnlyMinuteDelegate {
    
    func viewOnlyMinuteSureBtnClick(viewVC: ViewMinutesViewController, seconds: Int) {
        // 设置延长会议
        let isSuccess = manager.postponeConferenceTime(seconds: seconds)
        self.delayTimeStr = ViewMinutesViewController.secondTodelayStr(seconds)
        
        if !isSuccess {
            showBottomHUD(tr("延长会议失败"))
            self.delayTimeStr = ""
            return
        }
    }
}

