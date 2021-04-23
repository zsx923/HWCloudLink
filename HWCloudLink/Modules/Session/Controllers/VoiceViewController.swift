//
// VoiceViewController.swift
// HWCloudLink
//
// Created by 陈帆 on 2020/3/20.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import ReplayKit

class VoiceViewController: MeetingViewController {
    
    enum SpeakerTypE:Int {
        case ROUTE_DEFAULT_TYPE = 0
        case ROUTE_LOUDSPEAKER_TYPE
        case ROUTE_BLUETOOTH_TYPE
        case ROUTE_EARPIECE_TYPE
        case ROUTE_HEADSET_TYPE
    }
    @IBOutlet weak var avatarImageView: UIImageView!
        
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var callStatusLabel: UILabel!
    
    @IBOutlet weak var onCallUserIDLab: ActionUILabel!
    @IBOutlet weak var onCallMainTitleLab: ActionUILabel!
    @IBOutlet weak var onCallLeaveBtn: UIButton!
    @IBOutlet weak var preHeaderView: UIView!
    @IBOutlet weak var preCloseBtn: UIButton!
    @IBOutlet weak var preListenBtn: UIButton!
    @IBOutlet weak var preMutBtn: UIButton!
    @IBOutlet weak var suspendWindowBtn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var listenBtn: UIButton!
    // 音频、视频转换按钮
    @IBOutlet weak var convertBtn: UIButton!
    //新增网络质量属性
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var netCheckBtn: UIButton!
    
    private let netLevelManager = NetLevel()
    
    var previousRouteType:Bool = false
    //会议详情vc
    public weak var meetInfoVC : MeetingInfoViewController?
    
    var isOpenVoiceBtn:Bool = false
    var isTransfer: Bool = false //是否是转化过来的音频 默认是否
    var updatCallSecondBlock: UpdateCallSecondsBlock? // 如果需要回传数据则使用，否则不用
    var silenceType: Bool = false //静音状态，默认是非静音，在音视频转的过程中需要传递此状态，更新静音icon显示
    var speakerType: SpeakerTypE = .ROUTE_DEFAULT_TYPE
//        ROUTE_TYPE.ROUTE_DEFAULT_TYPE  //Defalt >> 听筒状态 对照PRD每个状态机切换时由APP强制指定
    
    // 扬声器状态, 默认是扬声器状态,在音视频转的过程中需要传递此状态，更新扬声器icon显示
    var soundType: Bool = false
    //是否点击了listenBtn按钮, 默认是false,在音视频转的过程中需要传递此状态，确认是否维持初始状态, voice 默认 听筒
    var isListenBtnType:Bool = false
    private var canExchange: Bool = true//  是否可以点击转化为
    //信号vc
    private weak var alertSingalVC: AlertTableSingalViewController?
    //请求转视频vc
    private weak var askVoiceVC: AskVoiceToVideoRequestViewController?
    private var timer: Timer?
        
    // 当前通话秒数 fileprivate - 设置到转化 需要把当前时长带过来
    var currentCalledSeconds: Int =  0 // 听筒
    
    private var isMineCloseCall: Bool = false
    
    // 语音会议是否接听
    private var isAnswerCall: Bool = false
    
    private var manager = CallMeetingManager()
    
    // 当前信号质量
    private var netLevel:String = "5"
    
    // MARK: - Life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CLLog("VoiceViewController - viewDidLoad")
        
//        // Do any additional setup after loading the view.
        // 初始化
        self.setViewUI()
        
        if UI_IS_BANG_SCREEN {
            // 刘海屏
//            self.topShrakConstraint.constant = 50
        } else {
            // 普通屏
//            self.topShrakConstraint.constant = 30
        }
        if isTransfer {
            //视频转过来的音频
            callStatusLabel.removeFromSuperview()
            //靠近耳朵息屏
            closeToTheEarScreen(isProximityMonitoringEnabled: true)
            //更新静音键的状态
            updateSecondAndVoiceType(0, silence: self.silenceType)
            
            if isListenBtnType {
                //点击了listenBtn
                //更新扬声器的状态
                self.setListenBtnStyle(isSlected: self.soundType, sender: self.listenBtn)
            }else{
                //强制为听筒
                self.setListenBtnStyle(isSlected: false, sender: self.listenBtn)
                initDefaultRouter()
            }
            self.isAnswerCall = true
        } else {
            //按照之前的逻辑
            installComingAndConfig()
            initDefaultRouter()
        }
                
        registerNotify()
//        self.callInfo = manager.currentCallInfo()
        //顶部详情点击事件
        self.onCallMainTitleLab.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [weak self] (_) in
            guard let self = self else { return }
           
            // 信号质量VC
            let infoVC = MeetingInfoViewController()
            let infoModel = MeetingInfoModel()
            infoModel.type = .video
            let name = String(format: tr("与%@通话中"), "\(self.meetInfo?.scheduleUserName ?? "")")
            infoModel.name = name
            infoModel.number = self.meetInfo?.accessNumber ?? ""
            infoModel.netLevel = self.netLevel
            // 会议时间
            infoVC.infoModel = infoModel
            infoVC.modalPresentationStyle = .overFullScreen
            infoVC.modalTransitionStyle = .crossDissolve
            infoVC.displayShowRotation = .portrait
            self.present(infoVC, animated: true) {
            }
            self.meetInfoVC = infoVC
        }))
    }
    
    //判断中英文
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CLLog("VoiceViewController - viewDidAppear")
//        buf_fix_yuep202011214 主叫默认设置为听筒模式
        //UI 已正确配置，但是设备控制的开关需要强制指定
        self.manager.closeSpeaker()
        // hot_fix20201214 与安卓对齐，默认所有语音通话都走听筒
        self.speakerType =  .ROUTE_DEFAULT_TYPE
        self.listenBtn.isSelected = false // 默认的音频输出状态为听筒
        self.muteBtn.isSelected = false
        self.preMutBtn.isSelected = false
        self.preListenBtn.isSelected = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CLLog("VoiceViewController - viewWillAppear")
        
        contentView.backgroundColor = UIColor.gradient(size: CGSize(width: kScreenWidth, height: kScreenHeight), direction: .default, start: UIColor(white: 0, alpha: 0.3), end: UIColor(white: 0, alpha: 1))
        setInitData()
        
        //靠近耳朵息屏
        closeToTheEarScreen(isProximityMonitoringEnabled: true)
        
        // 屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
//        if !self.isOpenVoiceBtn {
//            self.initDefaultRouter()
//        }
    }

    
   private func initDefaultRouter() -> Void {
        let defaultRouteType:ROUTE_TYPE = manager.obtainMobileAudioRoute()
        print("call>>tsdk告诉获取到的设备route是：",defaultRouteType.rawValue)
        switch defaultRouteType {
        case ROUTE_TYPE.HEADSET_TYPE ,ROUTE_TYPE.BLUETOOTH_TYPE :
            self.enterHeadSetModel2()
            self.listenBtn.setImageName("icon_receiver_default", title: tr("耳机"))
            self.preListenBtn.setImageName("icon_receiver_default", title: tr("耳机"))
//            self.listenBtn.isEnabled = false
            self.listenBtn.isSelected = true
//            manager.closeSpeaker()
            break
        default:

//            self.enterSpeakerModel2()
        
            break
        }
        
        //TODO:当前无论是TSDK还是系统自行监听获取到的是否耳机插入状态都是错误的，因此发送0设置命令主动触发
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
           if(false == self.previousRouteType){
            self.enterSpeakerModel2()
           }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        CLLog("VoiceViewController - viewWillDisappear")
        super.viewWillDisappear(animated)
        
        //靠近耳朵息屏
        closeToTheEarScreen(isProximityMonitoringEnabled: false)
        
        UIApplication.shared.isIdleTimerDisabled = false
//        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        CLLog("VoiceViewController - deinit")
        //p2pType 0 为语音点呼   其他为视频点呼
        NotificationCenter.default.post(name: NSNotification.Name.init(P2PCallDeinitStatus), object: nil, userInfo: ["P2PType": "0"])

        NotificationCenter.default.removeObserver(self)
        // 结束铃声
        SessionHelper.stopMediaPlay()
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    // MARK: - IBActions
    // 缩小画面
    @IBAction func sharkClick(_ sender: Any) {
        CLLog("sharkClick")
        SessionManager.shared.currentCalledSeconds = self.currentCalledSeconds
        self.suspend(coverImageName: "", type: .voice, svcManager: nil)
    }
    @IBAction func preMuteBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.muteBtn.isSelected = sender.isSelected
        self.muteBtnClick(self.muteBtn)
        
        self.setMute(isMute: sender.isSelected,sender: self.preMutBtn)
    }
    
    // 静音
    @IBAction func muteBtnClick(_ sender: UIButton) {
        CLLog("muteBtnClick")
        //权限开启
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { (isAuth) in
            guard isAuth else {
                CLLog("no microphone auth")
                self.requestMuteAlert()
                return
            }
            
            sender.isSelected = !sender.isSelected
            let callId = self.callInfo == nil ? UInt32(self.meetInfo?.callId ?? 0) : UInt32(self.callInfo?.stateInfo.callId ?? 0)
            self.manager.muteMic(isSelected: sender.isSelected, callId: callId)
            self.setMute(isMute: sender.isSelected,sender: self.muteBtn)
        }
    }
    
    @IBAction func preListenBtnClick(_ sender: UIButton) {
        self.listenBtnClick(self.listenBtn)
        sender.isSelected = !sender.isSelected
        self.listenBtn.isSelected = self.preListenBtn.isSelected
        //设置扬声器的状态
        self.setListenBtnStyle(isSlected: sender.isSelected, sender: self.preListenBtn)
    }
    // 听筒
    @IBAction func listenBtnClick(_ sender: UIButton) {
        CLLog("listenBtnClick ")
        print("sender.isSelected",sender.isSelected)
        sender.isSelected = !sender.isSelected
        self.previousRouteType = false
        self.isOpenVoiceBtn = true
        var isSound = sender.isSelected
        if let img = sender.accessibilityIdentifier {
           isSound = !(img == "sound")
        }
        self.listenBtn.isSelected = sender.isSelected
        self.preListenBtn.isSelected = self.listenBtn.isSelected
        self.setListenBtnStyle(isSlected: isSound, sender: self.listenBtn)
    }
    
    // 转视频通话
    @IBAction func convertBtnClick(_ sender: UIButton) {
        CLLog("convertBtnClick")
        guard self.canExchange else {
            CLLog("can't convert")
            return
        }
        
        if callInfo == nil {
            self.callInfo = manager.currentCallInfo()
        }
        if self.callInfo != nil {
            self.canExchange = false
            showBottomHUD(tr("等待对方开启摄像头"))
            manager.upgradeAudioToVideoCall(callId: self.callInfo?.stateInfo.callId ?? 0)
            sender.isEnabled = false
        } else {
            CLLog("can't do nothing")
        }
    }
    
    // 挂断打电话响应
    @IBAction func callBtnClick(_ sender: Any) {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        showBottomHUD(tr("通话已结束"))
        MBProgressHUD.showBottom(tr("通话已结束"), icon: nil, view: nil)
        CLLog("callBtnClick")
        isMineCloseCall = true
        // false：主动呼叫又挂断，true：主动呼叫成功/接听成功后挂断
        closeCall(isAnswer: self.isAnswerCall)
    }
    
    // 挂断
    func closeCall(isAnswer: Bool) {
        CLLog("点呼结束实际调用， manager.closeCall")
        if self.callInfo == nil {
            showBottomHUD(tr("通话已结束"))
           
            manager.hangupAllCall()
        } else {
            manager.closeCall(callId: self.callInfo?.stateInfo.callId ?? 0)
        }
        
        saveContact(isAnswer: isAnswer)
        
        // 结束铃声
        SessionHelper.stopMediaPlay()

        closeToTheEarScreen(isProximityMonitoringEnabled: false)
        
        self.endMeetingDismissVC()
    }
    
    func saveContact(isAnswer: Bool) {
        CLLog("saveContact")
        // 本地最近联系人存储 0（呼叫别人，别人没接听自己挂断走两次）（呼叫别人  别人挂断）(呼叫别人 接听后自己挂断)
        //（呼叫别人 接听后别人挂断）（被呼叫 接听后自己挂断）
        let talkTime = currentCalledSeconds
        let number = meetInfo?.accessNumber ?? ""
        if meetInfo?.scheduleUserName != nil {
            let name = meetInfo?.scheduleUserName ?? number
            ContactManager.shared.saveContactCallLog(callType: 1, name: name, number: number, depart: "",
                                                     isAnswer: isAnswer, talkTime: talkTime, isComing: isComing())
        } else {
            let name = callInfo?.stateInfo.callName ?? number
            ContactManager.shared.saveContactCallLog(callType: 1, name: name, number: number, depart: "",
                                                     isAnswer: isAnswer, talkTime: talkTime, isComing: isComing())
        }
    }
    
    //点击信号
    @IBAction func netCheckBtnClick(_ sender: UIButton) {
        CLLog("netCheckBtnClick")
        
    }

    // MARK: - Private
    fileprivate func refreshSignalButtonImg() {
        CLLog("refreshSignalButtonImg")
        if let meetInfo = self.meetInfo {
            let isSuccess = manager.getCallStreamInfo(callId: UInt32(meetInfo.callId))
            if isSuccess {
//                let signalImg = SessionHelper.getSignalImage(recvLossPercent: manager.getRecvLossFraction())
//                netCheckBtn.setImage(signalImg, for: .normal)
            } else {
                CLLog("获取点对点语音的信号信息失败")
            }
        }
    }
    
    override func noStreamAlertAction() {
        CLLog("noStreamAlertAction")
        closeCall(isAnswer: self.isAnswerCall)
    }
   
    private func installComingAndConfig() {
        if !isComing() {
            // 发起语音呼叫
            manager.startCall(number: self.meetInfo?.accessNumber ?? "", name: self.meetInfo?.name ?? "",  type: CALL_AUDIO)
        }
        //隐藏
        callStatusLabel.removeFromSuperview()
        netCheckBtn.isHidden = true
        //靠近耳朵息屏
        closeToTheEarScreen(isProximityMonitoringEnabled: true)
    }
    
    private func endMeetingDismissVC(isTransfer: Bool = false) {
        CLLog("endMeetingDismissVC")
        if !isTransfer {
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
        }
        NotificationCenter.default.removeObserver(self)
        alertSingalVC?.destroyVC()
        askVoiceVC?.dismiss(animated: false, completion: nil)
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        if isTransfer {
            self.joinVideoCall()
        } else {
            self.parent?.dismiss(animated: true) {
                CLLog("dismiss")
            }
        }
    }
    
    private func joinVideoCall() {
        NotificationCenter.default.post(name: NSNotification.Name.init(P2PCallDeinitStatus), object: nil, userInfo: ["P2PType": "1"])
        
        let convertModel = P2PConvertModel()
        convertModel.meetInfo = meetInfo
        convertModel.callInfo = callInfo
        convertModel.silenceType = self.silenceType
        convertModel.soundType = self.soundType
        convertModel.isListenBtnClick = (self.isOpenVoiceBtn || self.isListenBtnType) ? true : false
        convertModel.currentCalledSeconds = currentCalledSeconds
        if let parentVC = self.parent as? MeetingContainerViewController {
            parentVC.convertTo(type: .p2pVideo, convertModel: convertModel)
        }
    }
    
    private func setViewUI() {
        // 隐藏最小化按钮
        self.suspendWindowBtn.isHidden = true
        self.onCallLeaveBtn.layer.borderColor = COLOR_RED.cgColor
        self.onCallLeaveBtn.layer.borderWidth = 1.0
        self.onCallLeaveBtn.setTitle(tr("挂断"), for: .normal)
        self.callStatusLabel.text = tr("正在呼叫")
        //设置背景
        let userCardStyle = getCardImageAndColor(from: self.meetInfo?.scheduleUserName ?? "")
        self.avatarImageView.image = userCardStyle.cardImage
        self.avatarImageView.alpha = 0.3
//        self.view.backgroundColor = userCardStyle.textColor
        
        if !isComing() && isTransfer == false {
            self.setPreCallUI()
            return
            
        } else {
            // 接听
//            self.isAnswerCall = true
//            self.userNameLabel.text = self.meetInfo?.accessNumber == nil ? self.meetInfo?.confId : self.meetInfo?.accessNumber
            self.onCallUserIDLab.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.accessNumber ?? "")
            let name = String(format: tr("与%@通话中"), "\((self.meetInfo?.accessNumber == nil ? self.meetInfo?.confId : self.meetInfo?.accessNumber) ?? "")")

            self.setCalledViewUI()
        }
  
        self.setInitData()
    }
    
    
    private func setPreCallUI(){
        self.userNameLabel.text = self.meetInfo?.scheduleUserName == nil ? self.meetInfo?.scheduleUserAccount : self.meetInfo?.scheduleUserName
        self.meetingLabel.text = tr("正在呼叫")
        // 主叫 >> 播放铃声ring_back
        SessionHelper.mediaStartPlayWithMediaName(name: "ring_back.wav", isSupportVibrate: false)
        self.listenBtn.isHidden = true
        self.muteBtn.isHidden = true
        self.convertBtn.isHidden = true
        
        self.preMutBtn.setImageName("icon_mute1_default", title: tr("静音"))
        self.preListenBtn.setImageName("icon_receiver_default", title: tr("听筒"))
        self.preHeaderView.isHidden = true
        self.preMutBtn.isHidden = true
        self.preListenBtn.isHidden = true
        self.setMute(isMute: self.silenceType,sender: self.muteBtn)
        
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            self.currentCalledSeconds = 0
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self](_) in
            guard let self = self else { return }
            self.currentCalledSeconds += 1
        })
    }
    private func setCalledViewUI() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            self.currentCalledSeconds = 0
        }
        
        // 显示最小化按钮
        self.suspendWindowBtn.isHidden = false
        self.listenBtn.isHidden = false
        self.muteBtn.isHidden = false
        self.convertBtn.isHidden = false
        self.preCloseBtn.isHidden = true
        self.preMutBtn.isHidden = true
        self.preListenBtn.isHidden = true
        self.preHeaderView.isHidden = false
        self.onCallLeaveBtn.layer.borderColor = COLOR_RED.cgColor
        self.onCallLeaveBtn.layer.borderWidth = 1.0
        // 设置定时器
        netCheckBtn.isHidden = false
        self.meetingLabel.text = self.getCallTimeDuration()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.currentCalledSeconds += 1
            self.meetingLabel.text = self.getCallTimeDuration()
            // 缩小画面语音时长通知
            NotificationCenter.default.post(name: NSNotification.Name("CalledSecondsChange"), object: NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds))
//            self.manager.getSpeaker()
            
        })
                
        // 结束铃声
        SessionHelper.stopMediaPlay()
    }
    
    private func getCallTimeDuration() -> String {
        let durationString = NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds) as String
        return String(format: tr("通话中") + " %@", durationString)
    }
    
    private func setInitData() {
        if isComing() {
            // 接听
            if self.callInfo != nil {
                self.userNameLabel.text = self.callInfo?.stateInfo.callName == nil ? self.callInfo?.stateInfo.callNum : self.callInfo?.stateInfo.callName
                self.onCallUserIDLab.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.accessNumber ?? "")
                let name = String(format: tr("与%@通话中"), "\((self.callInfo?.stateInfo.callName == nil ? self.callInfo?.stateInfo.callNum : self.callInfo?.stateInfo.callName) ?? "")")
                self.onCallMainTitleLab.text = name
            }
        } else {
            self.userNameLabel.text = self.meetInfo?.scheduleUserName == nil ? self.meetInfo?.scheduleUserAccount : self.meetInfo?.scheduleUserName
            self.onCallUserIDLab.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.accessNumber ?? "")
            let name = String(format: tr("与%@通话中"), "\((self.meetInfo?.scheduleUserName == nil ? self.meetInfo?.scheduleUserAccount : self.meetInfo?.scheduleUserName) ?? "")")
            self.onCallMainTitleLab.text = name
        }
        self.setMute(isMute: self.silenceType,sender: self.muteBtn)
        self.convertBtn.setImageName("videoTransformBg", title: tr("转视频通话"))
    }
    
    func setListenBtnStyle(isSlected:Bool,sender:UIButton) {
        if isSlected {
            self.listenBtn.setImageName("sound", title: tr("扬声器"))
            self.preListenBtn.setImageName("sound", title: tr("扬声器"))
            self.speakerType = .ROUTE_LOUDSPEAKER_TYPE
            manager.openSpeaker()
        } else {
            self.preListenBtn.setImageName("icon_receiver_default", title: tr("听筒"))
            self.listenBtn.setImageName("icon_receiver_default", title: tr("听筒"))
            self.speakerType =  .ROUTE_DEFAULT_TYPE
            manager.closeSpeaker()
        }
        
        self.soundType = isSlected
    }
    // 设置麦克风状态
    func setMute(isMute: Bool,sender:UIButton) {
        if isMute {
            sender.setImageName("microphone_close", title: tr("静音"))
            self.manager.muteMic(isSelected: true, callId: self.callInfo?.stateInfo.callId ?? 0)
        } else {
            sender.setImageName("icon_mute1_default", title: tr("静音"))
            self.manager.muteMic(isSelected: false, callId: self.callInfo?.stateInfo.callId ?? 0)
        }
        self.silenceType = isMute
    }
    private func transformVideoVC() {
        CLLog("voice >> 转换 >> video ")
        self.endMeetingDismissVC(isTransfer: true)
    }
    
    private func updateSecondAndVoiceType(_ updateSeconds: Int, silence: Bool) {
        //更新扬声器状态
        _ = manager.obtainMobileAudioRoute()
        //更新静音状态
        manager.muteMic(isSelected: silence, callId: self.callInfo?.stateInfo.callId ?? 0)
        self.setMute(isMute: silence,sender: self.muteBtn)
    }
    
    // MARK: - 通知
    fileprivate func registerNotify() {
        // 结束通话
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl),
            name: NSNotification.Name(CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: nil)
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(notificationListenListenChange), name: NSNotification.Name( CALL_S_CALL_EVT_CALL_ROUTE_CHANGE), object: nil)
        
        // 远端请求打开视频
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRequestVideo), name: NSNotification.Name(CALL_S_CALL_EVT_OPEN_VIDEO_REQ), object: nil)
        
        // 打开视频通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationOpenVideo), name: NSNotification.Name(CALL_S_CALL_EVT_OPEN_VIDEO_IND), object: nil)
        
        //远端拒绝打开视频(音频转视频被拒)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRequestViewoFail), name: NSNotification.Name( CALL_S_CALL_EVT_REFUSE_OPEN_VIDEO_IND), object: nil)
        
        //通话建立的通知，用来获取 callinfo 信息。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallConnected), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_CONNECTED), object: nil)
        // 呼叫结束
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallEnd), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_ENDED), object: nil)
        // 呼出事件
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallOutgoing), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_OUTGOING), object: nil)
        
        // 会议详情信号质量点击通知
        NotificationCenter.default.addObserver(self, selector: #selector(notficationLookAudioClick(notfication:)), name: NSNotification.Name.init(LookAudioAndVideoQualityNotifiName), object: nil)
        
        // 音频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationAudioQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_AUDIO_NET_QUALITY), object: nil)
     
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
    
    // 会议详情视频质量点击通知
    @objc func notficationLookAudioClick(notfication:Notification) {
            presentSignalAlert()
            refreshSignalButtonImg()
    }

    
    @objc func notificationCallConnected(notification: Notification) {
//        return
        // 判断call 信息
        CLLog("voice >> CALL_CONNECT - 连接")
        guard let resultInfo = notification.userInfo else {
            CLLog("notificationCallConnected 连接失败")
            return
        }
        
        self.isAnswerCall = true
        self.callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
        self.setCalledViewUI()
        self.setInitData()
        NSObject.stopSoundPlayer()
    }
    @objc func notificationCallOutgoing(notification: Notification) {
        CLLog("voice >> CALL_OUTGOING")
        guard let resultInfo = notification.userInfo else {
            CLLog("notificationCallOutgoing 呼出失败")
            return
        }
        self.callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
    }
    
    @objc func notificationCallEnd(notification: Notification) {
        CLLog("voice >> CALL_CLOSE - call关闭")
        guard let resultInfo = notification.userInfo else {
            CLLog("notificationCallEnd 关闭失败")
            return
        }
        
        self.callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
        if reasonCodeIsEqualErrorType(reasonCode: self.callInfo?.stateInfo.reasonCode ?? 0, type: TSDK_E_CALL_ERR_REASON_CODE_NOTFOUND.rawValue) {
            showBottomHUD(tr("用户未在线或不存在"))
            closeCall(isAnswer: false)
        } else if reasonCodeIsEqualErrorType(reasonCode: self.callInfo?.stateInfo.reasonCode ?? 0, type: TSDK_E_CALL_ERR_REASON_CODE_NON_STD_REASON.rawValue) {
            showBottomHUD(tr("对方忙，请稍后再试"))
            closeCall(isAnswer: false)
        } else {
//            let title = (isMineCloseCall == true || currentCalledSeconds != 1) ? tr("结束通话") : tr("对方已挂断")
//            showBottomHUD(title)
            if ( self.callInfo?.stateInfo.reasonCode == 0 || self.isMineCloseCall == true || callInfo?.stateInfo.reasonCode == 50331745) {
//                self.showBottomHUD(tr("通话已结束"))
                Toast.showBottomMessage(tr("通话已结束"))
            } else {
                if callInfo?.stateInfo.reasonCode == 50331648 || callInfo?.stateInfo.reasonCode == 50331750 {
                    self.showBottomHUD(tr("会议未开始或不存在了"))
                } else {
                    self.showBottomHUD(tr("对方已挂断"))
                }
            }
            
//            showBottomHUD(tr("对方已挂断"))
            closeCall(isAnswer: self.isAnswerCall)
            isMineCloseCall = false
        }
    }
    
    @objc func notificationRequestVideo(notification: Notification) {
        CLLog("CALL_UPGRADE_VIDEO_PASSIVE - 远端请求打开视频")
        CLLog("需要弹出提示 是否打开视频-----")
        alertSingalVC?.destroyVC()
        
        
        guard SuspendTool.isMeeting() else {
            self.requestVoiceToVideoAlert(animated: true)
            return
        }
        // 小窗口时先结束小窗口
        NotificationCenter.default.post(name: NSNotification.Name(P2PCallConvertNotify), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.requestVoiceToVideoAlert(animated: false)
        }
    }
    
    @objc func notificationOpenVideo(notification:Notification) {
        CLLog("打开视频")
        self.transformVideoVC()
    }
    
    @objc func notificationRequestViewoFail(notification:Notification) {
        CLLog("音频转视频请求被拒")
        self.canExchange = true
        // 长时间不接 应该dismiss掉
        if askVoiceVC != nil {
            askVoiceVC?.dismiss(animated: true, completion: nil)
        } else {
            showBottomHUD(tr("对方拒绝转为视频通话"))
            self.convertBtn.isEnabled = true
        }
    }
    
    @objc func notificationListenListenChange(notification:Notification){
        CLLog("tsdk告诉APProute-2014 状态更新了\( notification)")
        
        guard let noti = notification.userInfo as? [String:String] else {
            return
        }
        
        let routeType = noti[AUDIO_ROUTE_KEY]!
        CLLog("call >> routetype>>>>\(routeType)")
        switch routeType {
        case "0":
            break
        case "1":
            
            if self.previousRouteType,!isOpenVoiceBtn {
                self.enterSpeakerModel2()
            }else{
              
//                self.listenBtn.isEnabled = true
                self.listenBtn.isSelected = true
                self.preListenBtn.isSelected = true
                self.listenBtn.setImageName("sound", title: tr("扬声器"))
                self.preListenBtn.setImageName("sound", title: tr("扬声器"))
                //            self.enterLouderSpeakerModel()
            }
            break
        case "2","4":
            self.soundType = false
            self.enterHeadSetModel2()
            break
        case "3":
            self.listenBtn.isSelected = false
//            self.listenBtn.isEnabled = true
            self.preListenBtn.isSelected = self.listenBtn.isSelected
            self.listenBtn.setImageName( "icon_receiver_default", title:tr("听筒")  )
            self.preListenBtn.setImageName( "icon_receiver_default", title:tr("听筒"))
            break
        default:
            break
        }
        
    }
    
    @objc func notificationQuitToListViewCtrl(notification: Notification) {
        CLLog("notificationQuitToListViewCtrl")
        self.endMeetingDismissVC()
        let object = notification.object as? String
        if object != nil {
            CLLog("结束通话")
            showBottomHUD(tr("结束通话"))
            DispatchQueue.main.async {
                self.saveContact(isAnswer: true)
            }
        }
    }
    
    
    // MARK: - Alert
    
    private func requestVoiceToVideoAlert(animated: Bool) {
        CLLog("requestVoiceToVideoAlert")
        if self.callInfo == nil {
            self.callInfo = manager.currentCallInfo()
        }
        if self.callInfo != nil {
            if askVoiceVC == nil {
                CLLog("弹出转视频请求")
                let askVoiceVC = AskVoiceToVideoRequestViewController.init()
                askVoiceVC.modalPresentationStyle = .overFullScreen
                askVoiceVC.modalTransitionStyle = .coverVertical
                askVoiceVC.callInfo = callInfo
                askVoiceVC.meetInfo = meetInfo
                askVoiceVC.responseBlock = { [weak self] (sureResponse) in
                    CLLog("同意or拒绝sureResponse =  \(sureResponse)")
                    self?.manager.replyAddVideoCallIsAccept(isAccept: sureResponse, callId: self?.callInfo?.stateInfo.callId ?? 0)
                    if sureResponse {
                        self?.transformVideoVC()
                    }
                }
                self.askVoiceVC = askVoiceVC
                self.present(askVoiceVC, animated: animated, completion: nil)
            } else {
                CLLog("有未处理的---弹出转视频请求")
            }
        } else {
            CLLog("啥也不弹 nothing")
        }
        
    }
    
}

// 设备管理模块
extension VoiceViewController {
    func enterHeadSetModel2() {
        
        if self.soundType {
            return
        }
        
        self.listenBtn.setImageName("icon_receiver_default", title: tr("耳机"))
        self.preListenBtn.setImageName("icon_receiver_default", title: tr("耳机"))
        //修改连接蓝牙耳机时也可以切换扬声器
//        self.listenBtn.isEnabled = true
        self.previousRouteType = true
   }
   
   func enterLouderSpeakerModel(){
//       self.listenBtn.isEnabled = true
       manager.openSpeaker()
//        self.listenBtn.setImageName( "headset", title:  "听筒")
       self.listenBtn.isSelected = true
       self.preListenBtn.isSelected = true
       self.listenBtn.setImageName("sound", title: tr("扬声器"))
       self.preListenBtn.setImageName("sound", title: tr("扬声器"))
   }
    func enterSpeakerModel2() {
       
       self.listenBtn.isSelected = false
       self.preListenBtn.isSelected = false
       self.listenBtn.isEnabled = true
       //拔掉耳机之后默认进入 听筒模式
       
       manager.closeSpeaker()
       self.listenBtn.setImageName( "icon_receiver_default", title:tr("听筒"))
       self.preListenBtn.setImageName( "icon_receiver_default", title:tr("听筒"))
   }

    func presentSignalAlert() {
        
        CLLog("video >> 信号强度点击1.")
        guard let callInfo = self.callInfo else {
            CLLog("video >> 信号强度2获取失败：callInfo=nil")
            return
        }
        let alertSingalVC = AlertTableSingalViewController()
        alertSingalVC.modalPresentationStyle = .overFullScreen
        alertSingalVC.modalTransitionStyle = .crossDissolve
        alertSingalVC.isVideoNetCheck = false
        alertSingalVC.isSvc = false
        alertSingalVC.isAvc = false
        alertSingalVC.isHaveAuxiliaryData = false
        if self.callInfo == nil {
             alertSingalVC.callId = UInt32(self.meetInfo?.callId ?? 0)
        } else {
            alertSingalVC.callId = self.callInfo?.stateInfo.callId ?? 0
        }
        self.alertSingalVC = alertSingalVC
        self.present(alertSingalVC, animated: true, completion: nil)
    }
    
    
}
