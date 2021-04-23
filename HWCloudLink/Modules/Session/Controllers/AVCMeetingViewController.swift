//
//  AVCMeetingViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/10.
//  Copyright © 2020 陈帆. All rights reserved.

import UIKit
import ReplayKit
import MediaPlayer

class AVCMeetingViewController: MeetingViewController {
    
    @IBOutlet weak var navTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var localVideoBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titileArrView: UIImageView!
    @IBOutlet weak var numberPadBtn: UIButton!
    @IBOutlet weak var navBackView: UIView!
    @IBOutlet weak var showBackgroundImageView: UIImageView!
    @IBOutlet weak var showRightBottomSmallIV: DrapView!
    @IBOutlet weak var showSecurityImageView: UIImageView!
    @IBOutlet weak var showsignalImageView: UIImageView!
    @IBOutlet weak var showRecordTimeLabel: UILabel!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var showUserNameLabel: UILabel!
    @IBOutlet weak var attCountLable: UILabel!
    @IBOutlet weak var showUserIDLabel: UILabel!
    @IBOutlet weak var showTopVoiceBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var addUserBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var miniBtn: UIButton!
    
    //是否有广播
    private var isHaveBroadcastForEvt = false
    
    //用来判断是否真正进会
    private var isRealJoinMeeting = false
    //防止多次刷新
    private var isReFreshmeetingInfo = false
    //防止横竖屏多次刷新导致黑屏
    private var isRereshForOrientation = false
    // 当前信号质量
    private var netLevel:String = "5"
    private let netLevelManager = NetLevel()

    private var isHaveFirstShowSmallIV = false
    // 是否正在共享
    private var isShare: Bool = false
    private var myShare:Bool = false
    private var isShareBtnDisable:Bool = false
    private var auxRecvinng: Bool = false
    // 是否申请主持人填写密码弹框
    private  var isPWBullet: Bool = false
    // 是否在当前Controller 解决申请主持人释放弹框问题
    private var isCurrentShow: Bool = true
    // 底部控制栏是否展示
    fileprivate var isShowFuncBtns = true
    //右侧navItem点击之后 vc
    private weak var popTitleVC: PopTitleNormalViewController?
    //拨号盘vc
    private weak var numberKeyboardVc: NumberKeyboardController?
    //延长时间vc
    private weak var hourMinutePickerVC: ViewMinutesViewController?
    //信号vc
    private weak var alertSingalVC: AlertTableSingalViewController?
    private weak var  alertVC:  AlertSingleTextFieldViewController?
    fileprivate var displayShowRotation: UIInterfaceOrientation = .landscapeRight
    fileprivate var attendeeArray: [ConfAttendeeInConf] = []
    fileprivate var isEnterBackground = false
    fileprivate var currentConfMode = EC_CONF_MODE_FIXED
    
    // 与会者中的自己
    fileprivate var mineConfInfo: ConfAttendeeInConf?

    // 定时器
    fileprivate var timer: Timer?
    // 隐藏会控栏按钮
    fileprivate var hideFuncBtnsCount = 0
    
    // 更多menu
    fileprivate var menuView: YCMenuView?
    
    //延长会议成功之后的文本提示
    private var delayTimeStr: String = ""
    // manager
    private var manager = CallMeetingManager()
    // 摄像头类型
    public var cameraCaptureIndex = CameraIndex.front
    // fileprivate 当前通话秒数
    var currentCalledSeconds: Int = 1
    //  block 如果需要回传数据则使用，否则不用
    var updatCallSecondBlock: UpdateCallSecondsBlock?
    
    // 一进入会议按钮不可操作
    var disableAllButtons = true
    // 自动申请主持人
    var isAutoRequestChairman = false
    //防止申请主持人操作更新会议时长
    var isApplayChairman = false
    // 上一次route设备是否是耳机（BLE&有线都是耳机）
    var previousRouteType:Bool = false
    
    // 是否在入会在后更新一次摄像头和麦克风
    private var isUpdataCameraMicrophoneState = false
    
    // 创建本地视频画面
    public var locationVideoView: EAGLView?
    // 大画面
    public var videoStreamView: PicInPicView?
    
    // 是否打开了扬声器操作
    private var isOpenVoiceBtn = false
    
    //是否预约会议申请主席
    private var isPrePlayCharm  = false
    
    
    var shareBackView: ShareScreenBackView = {
        let shareView = ShareScreenBackView.shareScreenBackView()
        shareView.isUserInteractionEnabled = true
//        shareView.frame = CGRect(x: 0, y: 0, width: kScreenHeight, height:  kScreenWidth)
        return shareView
    }()
    
    //录屏相关
    lazy var broadcastPickerView: RPSystemBroadcastPickerView =  {
        let broadcastPickerView = RPSystemBroadcastPickerView()
        broadcastPickerView.size = CGSize(width: 0.0001, height: 0.0001)
        broadcastPickerView.showsMicrophoneButton = false
        
        return broadcastPickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CLLog("- 加入视频会议 - AVC - \(manager.isSMC3())")
        // 未入会前禁止点击会控
        enableAllButtons()
        SessionManager.shared.currentCalledSeconds = 0
        //首先隐藏掉头部会议信息
        meetingInfo(show: false)
        // 设置入会后摄像头打开或关闭
        setCameraOpenCloseJoninMeetingNow()
        // set navigation
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
        self.setControlNaviAndBottomMenuShow(isShow: true, isAnimated: false)
                
        // 添加共享
        broadcastPickerView.preferredExtension = REPLAY_EXTENSION_ID
        view.addSubview(broadcastPickerView)
        // 加载通知
        self.installNotification()
        // 设置UI
        setViewUI()
    
        SessionManager.shared.isConf = true
        SessionManager.shared.bfcpStatus = .noBFCP
        auxRecvinng = UserDefaults.standard.bool(forKey: "aux_rec")

        self.callInfo = manager.currentCallInfo()
        self.installComingAndConfig()
        
        DeviceMotionManager.sharedInstance()?.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CLLog("viewWillAppear")
        self.leaveBtn.isHidden = false
        //防止转屏不过来画面拉伸
        APP_DELEGATE.rotateDirection = .landscape
        UIDevice.switchNewOrientation(.landscapeRight)
        displayShowRotation = .landscapeRight
        self.setControlNaviAndBottomMenuShow(isShow: true, isAnimated: false)
        isCurrentShow = true
        if !self.isOpenVoiceBtn {
            self.initDefaultRouter()
        }


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CLLog("viewWillDisappear")
        isCurrentShow = false
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CLLog("avc >> viewDidAppear")
        isShareBtnDisable = true
        // 4.GCD 主线程/子线程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            self.isShareBtnDisable = false
        }
        // 屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
//        if currentCalledSeconds > 2 {
//            self.videoStreamView?.isAuxiliary = self.auxRecvinng
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CLLog("viewDidDisappear")
        self.alertSingalVC?.destroyVC()
    }
    
    public func removeAll() {
        self.isOpenVoiceBtn = false
        CLLog("AVCMeetingViewController - deinit")
        NotificationCenter.default.removeObserver(self)
        // 关闭设备监听
        DeviceMotionManager.sharedInstance()?.stop()
        // 结束铃声
        passiveStopShareScreen()
        SessionHelper.stopMediaPlay()
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        self.videoStreamView?.sizeForChange = self.showBackgroundImageView.bounds.size
//    }
    
    deinit {
        self.isOpenVoiceBtn = false
        CLLog("AVCMeetingViewController - deinit")
        NotificationCenter.default.removeObserver(self)
        // 关闭设备监听
        DeviceMotionManager.sharedInstance()?.stop()
        // 结束铃声
        passiveStopShareScreen()
        SessionHelper.stopMediaPlay()
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    // MARK: - Private
    
    func setViewUI() {
        
        // 入会先关闭摄像头
//        SessionManager.shared.isCameraOpen = false
        
        self.miniBtn.setImage(UIImage(named: "icon_mini_default"), for: UIControl.State.normal)
        self.miniBtn.setImage(UIImage(named: "icon_mini_press"), for: UIControl.State.highlighted)
        
        self.showRecordTimeLabel.layer.shadowColor = UIColor.black.cgColor
        self.showRecordTimeLabel.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.showRecordTimeLabel.layer.shadowRadius = 2.0
        self.showRecordTimeLabel.layer.shadowOpacity = 0.7
        self.showRecordTimeLabel.isHidden = true
        
        
        self.leaveBtn.layer.borderColor = COLOR_RED.cgColor
        self.leaveBtn.layer.borderWidth = 1.0
        
        // me video
        self.showRightBottomSmallIV.clipsToBounds = true
        self.showRightBottomSmallIV.layer.cornerRadius = 2.0
        self.showRightBottomSmallIV.layer.borderColor = UIColorFromRGB(rgbValue: 0x979797).cgColor
        self.showRightBottomSmallIV.layer.borderWidth = 0.5
        
        // 设置信号强度
//        let signalImg = SessionHelper.getSignalImage(recvLossPercent: 0.0)
//        self.showsignalImageView.image = signalImg
        
        self.showsignalImageView.isUserInteractionEnabled = false
//        self.showsignalImageView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [weak self](_) in
//            self?.refreshSignalButtonImg()
////            self?.presentSignalAlert()
//        }))
        
        self.showUserNameLabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [weak self](_) in
            self?.presentMeetingInfoAlert()
        }))
        
        self.attCountLable.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [weak self](_) in
            self?.presentMeetingInfoAlert()
        }))
        
        titileArrView.isUserInteractionEnabled = true
        self.titileArrView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [weak self](_) in
            self?.presentMeetingInfoAlert()
        }))
        
        self.leaveBtn.setTitle(tr("离开"), for: .normal)
        
        //对应默认的扬声器状态
        self.showTopVoiceBtn.isSelected = true
        // bottom btns
//        self.refreshVideoImage()
//        self.refreshShareImage()
//        self.refreshAddUserImage()
//        self.refreshMoreImage()
//        self.refreshMuteImage()
//        self.refreshAttendeeInfo()
    }
    
    private func installComingAndConfig() {
        self.setCalledViewUI()
//        self.updateVideoConfig()
        // 设置摄像头
//        self.updateCameraOpenClose()
        // 屏幕旋转
        self.deviceCurrentMotionOrientationChanged()
    }
    
    fileprivate func presentMeetingInfoAlert() {
        CLLog("点击了标题")
        
        let infoVC = MeetingInfoViewController()
        let infoModel = MeetingInfoModel()
        infoModel.type = .avcMeeting
        //TODO:
        infoModel.isProtect = true//目前和安卓保持一致会议为全部加密
//        infoModel.isProtect = (self.meetInfo?.generalPwd ?? "").count != 0 ? true : false // 是否是加密会议
        infoModel.meetingId = ((SessionManager.shared.isMeetingVMR && SessionManager.shared.cloudMeetInfo.accessNumber != nil) ? (SessionManager.shared.cloudMeetInfo.accessNumber ?? "") : (NSString.getSipaccount(self.meetInfo?.accessNumber ?? "")))
        infoModel.guestPassword = (self.meetInfo?.generalPwd ?? "") // 会议密码
        //因为vmr也要显示主席密码  所以加后面的判断， 并不是自己真正是主席
        infoModel.isChairman = (self.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN || ManagerService.confService()?.currentConfBaseInfo.accessNumber == ManagerService.confService().vmrBaseInfo?.accessNumber) ? true : false // 自己是否是主席
        if SessionManager.shared.isMeetingVMR && SessionManager.shared.cloudMeetInfo.accessNumber != nil {
            infoModel.chairmanPassword = SessionManager.shared.cloudMeetInfo.chairmanPwd
        }else {
            infoModel.chairmanPassword = (self.meetInfo?.chairmanPwd ?? "")
        }
        infoModel.name = self.meetInfo?.confSubject ?? "" // 会议主题
        
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
        self.present(infoVC, animated: true) {

        }
    }
    
    fileprivate func presentSignalAlert() {
        
        guard let callInfo = self.callInfo else {
            return
        }
        // 信号点击
        let alertSingalVC = AlertTableSingalViewController()
        alertSingalVC.isSvc = false
        alertSingalVC.isAvc = true
        alertSingalVC.isHaveAuxiliaryData = self.isShare
        alertSingalVC.modalPresentationStyle = .overFullScreen
        alertSingalVC.modalTransitionStyle = .crossDissolve
        alertSingalVC.interfaceOrientationChange = self.displayShowRotation
        alertSingalVC.callId = callInfo.stateInfo.callId
        self.alertSingalVC = alertSingalVC
        self.present(alertSingalVC, animated: true, completion: nil)
    }
    
    private func initDefaultRouter() -> Void {
        let defaultRouteType:ROUTE_TYPE = manager.obtainMobileAudioRoute()
        CLLog("avc video >> get >>tsdk >> routeType:\(defaultRouteType)")
        switch defaultRouteType {
        case ROUTE_TYPE.HEADSET_TYPE ,ROUTE_TYPE.BLUETOOTH_TYPE :
            self.enterHeadSetModel()
//            self.showTopVoiceBtn.isSelected = true
            break
        default:
            self.enterLouderSpeakerModel()
            manager.openSpeaker()
            break
        }
    }
    
    
    fileprivate func refreshCallDuration() {
        self.currentCalledSeconds += 1
        SessionManager.shared.currentCalledSeconds = self.currentCalledSeconds
        self.hideFuncBtnsCount += 1
        self.showRecordTimeLabel.text = NSString.init(format: "%@", NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds)) as String
        if self.hideFuncBtnsCount > 5, self.isShowFuncBtns {
            self.setControlNaviAndBottomMenuShow(isShow: false, isAnimated: true)
        }
    }
    
    fileprivate func setCalledViewUI() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        // 设置定时器
        self.showRecordTimeLabel.isHidden = false
        self.showRecordTimeLabel.text = NSString.init(format: "%@", NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds)) as String
        self.view.bringSubviewToFront(self.showRecordTimeLabel)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.refreshCallDuration()
        })
        
        self.showsignalImageView.isUserInteractionEnabled = true
        
        self.showBackgroundImageView.image = nil
        self.showBackgroundImageView.backgroundColor = UIColor.black
        
        // 设置前置摄像头
//        manager.switchCameraIndex(CameraIndex.front, callId: UInt32(self.meetInfo?.callId ?? 0))
        
        self.createVideoStreamView()
        if let videoStreamView = self.videoStreamView {
            self.showBackgroundImageView.addSubview(videoStreamView)
            videoStreamView.mas_makeConstraints { (make) in
                make?.edges.equalTo()(0)
            }
        }
        // 添加背景点击
        self.videoStreamView?.isUserInteractionEnabled = true
        //
        let viewTapGesture = UITapGestureRecognizer.init(actionBlock: { [weak self](_) in
            guard let self = self else { return }
            self.setControlNaviAndBottomMenuShow(isShow: !self.isShowFuncBtns, isAnimated: true)
        })
        
        self.videoStreamView?.addGestureRecognizer(viewTapGesture)
        self.videoStreamView?.isConf = true
        

        self.locationVideoView = self.createLocationVideoView()
        if let locationVideoView = self.locationVideoView {
            self.showRightBottomSmallIV.addSubview(locationVideoView)
//            locationVideoView.mas_makeConstraints { (make) in
//                make?.edges.equalTo()(0.5)
//            }
        }
        self.refreshAttendeeInfo()
    }
    
    // 创建本地视频画面
    private func createLocationVideoView() -> EAGLView? {
        self.videoStreamView?.localVideoView = EAGLViewAvcManager.shared.viewForLocal
        self.videoStreamView?.localVideoView?.backgroundColor = UIColor.clear
        self.showRightBottomSmallIV.isHidden = true
        self.videoStreamView?.localVideoView?.frame = self.showRightBottomSmallIV.bounds
        self.videoStreamView?.localVideoView?.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        return self.videoStreamView?.localVideoView

    }
    
    // 创建大画面
    private func createVideoStreamView() {
        let temp = PicInPicView.picInPicView()
        var tempSize = UIScreen.main.bounds.size
        if tempSize.height > tempSize.width {
            tempSize = CGSize(width: tempSize.height, height: tempSize.width)
        }
        temp.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: tempSize)
        temp.sizeForChange = tempSize
        temp.delegate = self
        self.videoStreamView = temp
    }
    
    fileprivate func refreshAttendeeInfo() {

        // 刷新与会者列表
        let attendeeArray = manager.haveJoinAttendeeArray()
        let selfNumber = ManagerService.call()?.sipAccount
//        if let selfJoinNumber = manager.selfJoinNumber() {
//            selfNumber = selfJoinNumber
//        }
        // 特殊处理排除
        var tempAttendeeArray: [ConfAttendeeInConf] = []
        var broadcastTempAttendee: ConfAttendeeInConf?
        for attendInConf in attendeeArray {
            
            if attendInConf.participant_id == selfNumber || attendInConf.number == selfNumber || NSString.getSipaccount(attendInConf.participant_id) == selfNumber || NSString.getSipaccount(attendInConf.number) == selfNumber || attendInConf.isSelf {
                self.mineConfInfo = attendInConf
                CLLog("selfNumber = \(selfNumber ?? "") --- attendInConf = \(attendInConf.participant_id ?? "") --- ischairMan === \(attendInConf.role == .CONF_ROLE_CHAIRMAN)")

//                self.refreshMuteImage()
                // 解禁操作 （2.0 会议中有自己  并且还在未解禁中就解禁会控）
                if self.disableAllButtons && !manager.isSMC3() {
//                    self.refreshMuteImage()
                    self.disableAllButtons = false
                    self.enableAllButtons()
                }
            }
            if ![ATTENDEE_STATUS_LEAVED, ATTENDEE_STATUS_NO_ANSWER,
                 ATTENDEE_STATUS_REJECT, ATTENDEE_STATUS_CALL_FAILED].contains(attendInConf.state) {
                CLLog("获取到的与会者ID：" + NSString.encryptNumber(with: attendInConf.number))
                tempAttendeeArray.append(attendInConf)
                // 是否在广播
                if attendInConf.isBroadcast {
                    broadcastTempAttendee = attendInConf
                }
            } else {
                // 是否被选看
                var beWatch = SessionManager.shared.watchingAttend?.number == attendInConf.number
                // 特殊处理排除（未在会议中)
                if beWatch {
                    SessionManager.shared.watchingAttend = nil
                    beWatch = false
                }
            }
        }
        
        // chenfan: 如果广播与选看同时存在,依然保持选看记录
        if (broadcastTempAttendee != nil) {
            SessionManager.shared.isBroadcast = true
        } else {
            // chenfan:取消广播判断 -- 原因SMC如果做了取消广播后，SDK不发取消广播的通知
            if SessionManager.shared.isBroadcast, let beWatchAttendee = SessionManager.shared.watchingAttend {
                ManagerService.confService()?.watchAttendeeNumber(NSString.getSipaccount(beWatchAttendee.number))
            }
            SessionManager.shared.isBroadcast = false
        }
        self.attendeeArray = tempAttendeeArray

        //刷新会议市场
//        if !isApplayChairman {
//            self.currentCalledSeconds = 0
//        }
        var meetingId = self.meetInfo?.accessNumber ?? ""
        if SessionManager.shared.isMeetingVMR && SessionManager.shared.cloudMeetInfo.accessNumber != nil {
            meetingId = SessionManager.shared.cloudMeetInfo.accessNumber
        }
        //和安卓对不展示会议密码
        self.showUserIDLabel.text = "ID" + tr(": ") + NSString.dealMeetingId(withSpaceString: meetingId)
        
        // 更新麦克风，摄像头状态
        if self.mineConfInfo != nil, isUpdataCameraMicrophoneState == true {
            HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuto) in
                guard let self = self else {return}
                if isAuto {  // 已授权麦克风
                    self.refreshMuteImage()
//                    self.refreshVideoImage()
//                    SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
                }
            }
        }
        
        // 入会后第一次更新摄像头麦克风状态
        if isUpdataCameraMicrophoneState == false && self.mineConfInfo != nil && isRealJoinMeeting {
//            self.setCameraOpenClose()
            CLLog("----------------- isRealJoinMeeting   \(isRealJoinMeeting)")
            isUpdataCameraMicrophoneState = true
            if self.mineConfInfo?.role == .CONF_ROLE_CHAIRMAN {
                // 如果进会自己本来就是主席  打开静音
                //根据当前的静音状态重新设置
                
                isAutoRequestChairman = true

            } else {
                
                if !self.isAutoRequestChairman {
                    self.autoRequestChairman()
                }
            }
            
            // 解禁操作 （3.0 只有onbaseinfo回调回来后才解禁会控）
        CLLog(">> disableAllButtons   \(self.disableAllButtons)")
            if self.disableAllButtons {
                self.disableAllButtons = false
                self.enableAllButtons()
            }
            meetingInfo(show: true)
        }
    }

    // 设入会后麦克风打开和关闭
    func setMicrophoneOpenClose() {
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuto) in
            guard let self = self else { return }
            if isAuto {  // 已授权麦克风
                
                if SessionManager.shared.isBeInvitation {
                    if self.manager.confCtrlMuteAttendee(participantId: self.mineConfInfo?.participant_id, isMute: true) {
//                        self.mineConfInfo?.is_mute = true
//                        self.refreshMuteImage()
                    }
                }else if self.mineConfInfo == nil { // 如果与会人中我是空 则设置麦克风位静音
                    if self.manager.confCtrlMuteAttendee(participantId: self.mineConfInfo?.participant_id, isMute: true) {
//                        self.mineConfInfo?.is_mute = true
//                        self.refreshMuteImage()
                    }
        
                }else {  // 与会人我不为空
                    if self.mineConfInfo?.is_mute == false, UserDefaults.standard.bool(forKey: CurrentUserMicrophoneStatus) == true  { //客户开，服务开才为开
//                        ManagerService.confService()?.confCtrlMuteAttendee(NSString.getSipaccount(self.svcManager.mineConfInfo?.number), isMute: self.muteButton.isSelected)
//                        self.refreshMuteImage()
                        if self.manager.confCtrlMuteAttendee(participantId: self.mineConfInfo?.participant_id, isMute: false) {
//                            self.mineConfInfo?.is_mute = true
//                            self.refreshMuteImage()
                        }
                    }else {
                       let _ = self.manager.confCtrlMuteAttendee(participantId: self.mineConfInfo?.participant_id, isMute: true)
                    }
                }
//                SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
            }else {      // 未授权麦克风
                let number = ManagerService.call()?.ldapContactInfo != nil ? ManagerService.call()?.ldapContactInfo.ucAcc : ""
                ManagerService.confService()?.confCtrlMuteAttendee(NSString.getSipaccount(number), isMute: true)

//                self.refreshMuteImage(isMute: self.muteButton.isSelected)
//                SessionManager.shared.isMicrophoneOpen = self.muteButton.isSelected
            }
        }
    }
    
    // 设置入会后摄像头打开或关闭
    private func setCameraOpenCloseJoninMeetingNow() {
        CLLog("setCameraOpenCloseJoninMeetingNow>>1")
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone {[weak self] (isAuto) in
            CLLog("setCameraOpenCloseJoninMeetingNow>>2 ISAUTO:\(isAuto) CALLID:\(UInt32(self?.manager.currentConfBaseInfo()?.callId ?? 0))")
            if isAuto {
                
                // 已授权摄像头
                if SessionManager.shared.isBeInvitation && !SessionManager.shared.isSelfPlayConf {
                    if self?.manager.switchCameraOpen(false, callId: UInt32(self?.manager.currentConfBaseInfo()?.callId ?? 0)) ?? false {
                        SessionManager.shared.isCameraOpen = false
                        CLLog("setCameraOpenCloseJoninMeetingNow>>3 ISAUTO")
                    }
                }else if UserDefaults.standard.bool(forKey: CurrentUserCameraStatus) == false {
                    if self?.manager.switchCameraOpen(false, callId: UInt32(self?.manager.currentConfBaseInfo()?.callId ?? 0)) ?? false {
                        SessionManager.shared.isCameraOpen = false
                        CLLog("setCameraOpenCloseJoninMeetingNow>>4 ISAUTO")
                    }
                }else{
                    
                    if self?.manager.switchCameraOpen(true, callId: UInt32(self?.manager.currentConfBaseInfo()?.callId ?? 0)) ?? false {
                        SessionManager.shared.isCameraOpen = true
                        self?.switchCamera(cameraIndex: self?.cameraCaptureIndex.rawValue) // 打开摄像头设置摄像头方向
                        CLLog("setCameraOpenCloseJoninMeetingNow>>5 ISAUTO")
                    }
                }
                self?.refreshVideoImage()
                CLLog("setCameraOpenCloseJoninMeetingNow>>6 ISAUTO")
            }else {      // 未授权摄像头
                CLLog("setCameraOpenCloseJoninMeetingNow>>7 ISAUTO")
                if self?.manager.switchCameraOpen(false, callId: UInt32(self?.manager.currentConfBaseInfo()?.callId ?? 0)) ?? false {
                    SessionManager.shared.isCameraOpen = false
                }
                self?.refreshVideoImage()
                self?.requestCameraAlert()
            }
        }
    }
    
    
    private func refreshVideoImage() {
        let isCameraOpen = SessionManager.shared.isCameraOpen 
        let normalImg = isCameraOpen ? "bottomicon_camera1_default" : "bottomicon_camera2_default"
        let pressImg = isCameraOpen ? "bottomicon_camera1_press" : "bottomicon_camera2_press"
        let disableImg = isCameraOpen ? "bottomicon_camera1_press" : "bottomicon_camera2_press"
        
        self.videoBtn.setImageName(normalImg: normalImg, pressImg: pressImg,
                                   disableImg: disableImg, title: tr("视频"))
        CLLog("摄像头UI  is open \(isCameraOpen)")
        self.videoBtn.isEnabled = !self.disableAllButtons
    }
    
    private func refreshVideoImageWith(cameraStatus:Bool) {
        self.videoBtn.isEnabled = !self.disableAllButtons
        CLLog("videoBtn enable is \(self.videoBtn.isEnabled)")
        let isCameraOpen = cameraStatus
        let normalImg = isCameraOpen ? "bottomicon_camera1_default" : "bottomicon_camera2_default"
        let pressImg = isCameraOpen ? "bottomicon_camera1_press" : "bottomicon_camera2_press"
        let disableImg = isCameraOpen ? "bottomicon_camera1_press" : "bottomicon_camera2_press"
        
        self.videoBtn.setImageName(normalImg: normalImg, pressImg: pressImg,
                                   disableImg: disableImg, title: tr("视频"))
        CLLog("摄像头UI  is open \(isCameraOpen)")
    }
    
    // 设置麦克风状态
    private func refreshMuteImage() {
        self.muteBtn.isEnabled = !self.disableAllButtons
        CLLog("muteBtn enable is \(self.muteBtn.isEnabled)   ----   \(self.mineConfInfo?.is_mute ?? true)")
        
        let isMute = self.mineConfInfo?.is_mute ?? true
        let normalImg = isMute ? "icon_mute2_default" : "icon_mute1_default"
        let pressImg = isMute ? "icon_mute2_press" : "icon_mute1_press"
        let disableImg = isMute ? "icon_mute2_disabled" : "icon_mute1_disabled"
        
        self.muteBtn.setImageName(normalImg: normalImg, pressImg: pressImg,
                                  disableImg: disableImg, title: tr("静音"))
        
        CLLog("avc video 设置为\(isMute ? "【静音】" : "【非静音】")")
    }
    
    private func refreshShareImage() {
        self.shareBtn.isEnabled = !self.disableAllButtons
        CLLog("shareBtn enable is \(self.shareBtn.isEnabled)")
        let normalImg = "bottomicon_share1_default"
        let pressImg = "bottomicon_share1_press"
        let disableImg = "bottomicon_share1_press"
        
        self.shareBtn.setImageName(normalImg: normalImg, pressImg: pressImg,
                                   disableImg: disableImg, title:  tr("屏幕共享"))
    }
    
    // 设置与会者状态
    private func refreshAddUserImage() {
        self.addUserBtn.isEnabled = !self.disableAllButtons
        CLLog("addUserBtn enable is \(self.addUserBtn.isEnabled)")
        let normalImg = "bottomicon_sites_default"
        let pressImg = "bottomicon_sites_press"
        let disableImg = "bottomicon_sites_press"
        
        self.addUserBtn.setImageName(normalImg: normalImg, pressImg: pressImg,
                                  disableImg: disableImg, title: tr("与会者"))
    }
    
    private func refreshMoreImage() {
        self.moreBtn.isEnabled = !self.disableAllButtons
        CLLog("moreBtn enable is \(self.moreBtn.isEnabled)")
        let normalImg = "bottomicon_more_default"
        let pressImg = "bottomicon_more_press"
        let disableImg = "bottomicon_more_press"
        self.moreBtn.setImageName(normalImg: normalImg, pressImg: pressImg,
                                  disableImg: disableImg, title: tr("更多"))
    }
    
    private func enableAllButtons() {
        CLLog("----解禁操作----")
        refreshMuteImage()
        refreshVideoImage()
        refreshShareImage()
        refreshAddUserImage()
        refreshMoreImage()
    }
    
    //是否显示听不会议信息
    private func meetingInfo(show: Bool) {
        if show {
            showSecurityImageView.isHidden = false
            showsignalImageView.isHidden = false
            showUserNameLabel.isHidden = false
            attCountLable.isHidden = false
            showUserIDLabel.isHidden = false
            titileArrView.isHidden = false
            miniBtn.isHidden = false
//            bottomView.isHidden = false
            
        }else{
            showSecurityImageView.isHidden = true
            showsignalImageView.isHidden = true
            showUserNameLabel.isHidden = true
            attCountLable.isHidden = true
            showUserIDLabel.isHidden = true
            titileArrView.isHidden = true
            miniBtn.isHidden = true
//            bottomView.isHidden = true
        }
    }
    
    private func autoRequestChairman() {
        CLLog("autoRequestChairman")
        CLLog("smc  Chairperson \(SessionManager.shared.isBeInvitation)---\(SessionManager.shared.isSelfPlayCurrentMeeting)")
        
        
        
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
                self.setMicrophoneOpenClose()
                return
            }
            CLLog("smc 3.0 Automatically Chairperson")
            if scheduleUserAccount == contactInfo.userName {
                // 发会自动申请主持人
                let _ = self.manager.requestChairman(password: chairmanPwd, number: mineConfInfo.participant_id)
                self.isAutoRequestChairman = true
                return
            }
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
                return
            }
            
        }
        if UserDefaults.standard.value(forKey: "YUYUELEHUIYI") != nil {
            guard let preMeetingInfo = UserDefaults.standard.value(forKey: "YUYUELEHUIYI") as? String  else {
                self.setMicrophoneOpenClose()
                return
            }
            if preMeetingInfo == "1" && !manager.isSMC3() && !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) {
                isPrePlayCharm = true
                ManagerService.confService()?.confCtrlRequestChairman("", number: mineConfInfo?.participant_id)
                UserDefaults.standard.setValue("", forKey: "YUYUELEHUIYI")
                self.isAutoRequestChairman = true
                CLLog("2.0预约申请主持人")
                return
            }
        }
        
        self.setMicrophoneOpenClose()
    }


    // MARK: - IBActions
    // 离开会议
    @IBAction func leaveBtnClick(_ sender: UIButton) {
        CLLog("leaveBtnClick")
        let popTitleVC = PopTitleNormalViewController.init(nibName: "PopTitleNormalViewController", bundle: nil)
        popTitleVC.modalTransitionStyle = .crossDissolve
        popTitleVC.modalPresentationStyle = .overFullScreen
        popTitleVC.isAllowRote = true
        
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
        if SessionManager.shared.isMeetingVMR && self.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
            popTitleVC.showName = tr("结束或离开会议")
            popTitleVC.isShowDestroyColor = true
            popTitleVC.dataSource = [tr("离开会议"), tr("结束会议"), tr("取消")]
            popTitleVC.subTitleArray = [tr("会议将继续进行，会中将没有主持人"), tr("会议将结束，其他人无法继续会议")]
        }
        
        popTitleVC.customDelegate = self
        popTitleVC.isShow = true
        self.popTitleVC = popTitleVC
        self.present(popTitleVC, animated: true, completion: nil)
    }
    
    // 打开扬声器
    @IBAction func showTopVoiceBtnClick(_ sender: UIButton) {
        self.isOpenVoiceBtn = true
//        self.showTopVoiceBtn.isEnabled = false
        CLLog("avc video listenBtnClick 1 (showTopVoiceBtnClick)")
        sender.isSelected = !sender.isSelected
        self.previousRouteType = false
        if sender.isSelected {
            manager.openSpeaker()
            CLLog("avc video listenBtnClick 2 (speaker)")
        } else {
            manager.closeSpeaker()
            CLLog("avc video listenBtnClick 3 (louder speaker)")
        }
    }
    
    // 设置静音
    @IBAction func muteBtnClick(_ sender: UIButton) {
        CLLog("avc video >> muteBtnClick")
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuth) in
            guard let self = self else { return }
            // 麦克风未授权 弹框去授权
            guard isAuth else {
                CLLog("avc video 申请静音权限")
                self.requestMuteAlert()
                return
            }
            guard let mineConfInfo = self.mineConfInfo else {
                CLLog("avc video mineConfinfo 数据为空")
                return
            }
            CLLog("avc videov 设置前为\(mineConfInfo.is_mute ? "【静音】" : "【非静音】")状态")
            let success = self.manager.confCtrlMuteAttendee(participantId: mineConfInfo.participant_id, isMute: !mineConfInfo.is_mute)
            CLLog("avc video 设置静音状态 -- \(success ? "success" : "fail")")
//            if success {
//                self.mineConfInfo?.is_mute = !mineConfInfo.is_mute
//                self.refreshMuteImage()
//            }
        }
    }
    
    // 打开关闭视频
    @IBAction func videoBtnClick(_ sender: UIButton) {
        CLLog("videoBtnClick")
        if myShare {return}
        // 摄像头未授权
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone { [weak self] (isAuth) in
            guard let self = self else { return }
            if isAuth {
                // d打开视频
                if let currentConf = self.manager.currentConfBaseInfo() {
                    if self.manager.switchCameraOpen(!SessionManager.shared.isCameraOpen, callId: UInt32(currentConf.callId)) {
                        SessionManager.shared.isCameraOpen = !SessionManager.shared.isCameraOpen
                        self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue) // 打开摄像头设置摄像头方向
                        self.refreshVideoImage()
                    }
                }
                self.deviceCurrentMotionOrientationChanged()
            } else { // 未授权
                self.requestCameraAlert()
            }
        }
    }
    
    // 共享
    @IBAction func shareBtnClick(_ sender: UIButton) {
        CLLog("shareBtnClick")
        if isShareBtnDisable {return}
        if myShare {
            passiveStopShareScreen()
            return
        }
        isShareBtnDisable = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            self.isShareBtnDisable = false
        }
        if auxRecvinng {
            self.alertAuthRequest("auxReq")
            return
        }
        showReplayKitUI()
    }
    
    // 与会者
    @IBAction func addUserBtnClick(_ sender: UIButton) {
        CLLog("addUserBtnClick")
        if myShare {return}
        self.leaveBtn.isHidden = true
        // 与会者
        let storyboard = UIStoryboard.init(name: "JoinUsersViewController", bundle: nil)

        let joinUsersViewVC = storyboard.instantiateViewController(withIdentifier: "JoinUsersView") as! JoinUsersViewController
        joinUsersViewVC.modalPresentationStyle = .custom
        joinUsersViewVC.isVideoConf = true
        joinUsersViewVC.mineConfInfo = self.mineConfInfo
        joinUsersViewVC.customDelegate = self
        joinUsersViewVC.meettingInfo = self.meetInfo
        self.isShowFuncBtns = true
        joinUsersViewVC.isHaveBroadcastForEvt = isHaveBroadcastForEvt
        joinUsersViewVC.navigationController?.navigationBar.shadowImage = UIImage.init()
        APP_DELEGATE.rotateDirection = .portrait
        UIDevice.switchNewOrientation(.portrait)
        
        self.navigationController?.pushViewController(joinUsersViewVC, animated: false)
    }
    
    // 更多/单项直播发言
    @IBAction func moreBtnClick(_ sender: UIButton) {
        CLLog("moreBtnClick")
        if myShare {return}
        setMenuViewBtnsInfo()
//        if (self.showRightBottomSmallIV.frame.size.height + self.showRightBottomSmallIV
//            .frame.origin.y + 10) > self.menuView!.frame.origin.y {
//
//            UIView.animate(withDuration: 0.25) {
////                self.localVideoBottomConstraint.constant = self.menuView!.frame.size.height + 20
//            }
//        }

    }
    
    @IBAction func suspendWindowClick(_ sender: UIButton) {
//        fix_20210402 修复华晨反馈共享时入小窗口必现黑屏 yuepeng
        if myShare {
            return
        }
        self.suspendwindowDisplay(isAux: false)
    }
    
    // 小窗口移除屏幕方向监听
    func removeOrientationObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
    }
    
    // 恢复窗口后重新监听屏幕方向监听
    func addOrientationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceCurrentMotionOrientationChanged), name: NSNotification.Name(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
    }
    
    // 释放视频窗口
    private func destoryEAGLView() {
        
        ManagerService.call()?.controlVideo(whenApplicationResignActive: false, callId: PicInPicView.id)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.manager.clearVideoWindow(callId: PicInPicView.id)
            
            self.locationVideoView?.removeFromSuperview()
            self.locationVideoView = nil
            
            self.videoStreamView?.removeFromSuperview()
            self.videoStreamView = nil
        }

    }
    
    private func endMeetingDismissVC(isEndConf: Bool = false) {
        CLLog("endMeetingDismissVC")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"ENDANDDISMISSAVC"), object: nil)
        UserDefaults.standard.setValue(false, forKey: "aux_rec")
        
        
        if let meetingInfo = self.meetInfo {
            ContactManager.shared.saveMeetingRecently(meetingInfo: meetingInfo, startTime: "", duration: self.currentCalledSeconds)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            
            //结束会议
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: isEndConf)
            
            self.destortyCurrentVC()
            self.passiveStopShareScreen()
        }
    }
    
    private func destortyCurrentVC()  {
        // 释放视频窗口
        self.destoryEAGLView()
        
        alertVC?.dismiss(animated: false, completion: nil)
        numberKeyboardVc?.dismiss(animated: false, completion: nil)
        alertSingalVC?.destroyVC()
        popTitleVC?.dismiss(animated: false, completion: nil)
        hourMinutePickerVC?.dismiss(animated: false, completion: nil)

        let viewControllerArray = self.navigationController?.viewControllers ?? []
        for vc in viewControllerArray {
            if let joinVC = vc as? JoinUsersViewController {
                joinVC.dismissVC()
            } else if let searchVC = vc as? SearchAttendeeViewController {
                searchVC.dismissVC()
            }
        }
        self.dismiss(animated: true, completion: nil)
        self.parent?.dismiss(animated: true) {
            CLLog("dismiss")
            NotificationCenter.default.removeObserver(self)
        }
    }
    //  更新视频配置
    func updateVideoConfig() {
        
        guard let meetInfo = self.meetInfo else {
            return
        }
        
        self.videoStreamView?.currentCallId = UInt32(meetInfo.callId)
        
        manager.watchAttendeeNumber(meetInfo.accessNumber)
    }
    
    override func noStreamAlertAction() {
        CLLog("noStreamAlertAction")
        endMeetingDismissVC()
    }
    
    override func showReplayKitUI() {        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            for screenBtn in self.broadcastPickerView.subviews {
                if screenBtn is UIButton {
                    (screenBtn as! UIButton).sendActions(for: .allTouchEvents)
                }
            }
        }
    }
    
}

// MARK: - 屏幕旋转UI更新
extension AVCMeetingViewController {
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.displayShowRotation = toInterfaceOrientation
        CLLog("willRotate toInterfaceOrientation = \(toInterfaceOrientation.rawValue)")
        
        alertSingalVC?.interfaceOrientationChange = toInterfaceOrientation

        numberKeyboardVc?.interfaceOrientationChangeValue = toInterfaceOrientation
        
        // 选转屏幕隐藏menu
        self.menuView?.dismiss()

        // 小画面
        if toInterfaceOrientation == .landscapeLeft || toInterfaceOrientation == .landscapeRight {
            showRightBottomSmallIV.interfaceOrientationChange = toInterfaceOrientation
            if !isRereshForOrientation {
                isRereshForOrientation = true
                videoStreamView?.sizeForChange = (toInterfaceOrientation == .portrait || toInterfaceOrientation == .portraitUpsideDown) ? CGSize(width: kScreenWidth, height: kScreenHeight) : CGSize(width: isiPhoneXMore() ? kScreenHeight - 98: kScreenHeight, height: kScreenWidth)
            }
            
//            var rightRect:CGRect = self.showRightBottomSmallIV.frame
//            rightRect.origin.y = SCREEN_WIDTH-self.bottomView.frame.size.height-rightRect.size.height-10
//            self.showRightBottomSmallIV.frame = CGRect(x: rightRect.origin.x, y: rightRect.origin.y, width: 146, height: 84)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.deviceCurrentMotionOrientationChanged()
        }
    }
}

// MARK: 与会者列表 - JoinUsersViewDelegate
extension AVCMeetingViewController: JoinUsersViewDelegate {
    // 打开关闭摄像头
    func joinUsersViewSwitchCamera(viewVC: JoinUsersViewController) {
        
        self.videoBtnClick(self.videoBtn)
    }
}

// MARK:  延长会议弹框代理 - ViewOnlyMinuteDelegate
extension AVCMeetingViewController: ViewOnlyMinuteDelegate {
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

// MARK: 小画面代理及一些处理
extension AVCMeetingViewController {
    // 小画面位置处理
    private func resumeSmallViewFrame() {
        UIView.animate(withDuration: 0.25) {
//            self.localVideoBottomConstraint.constant = 20
        }
    }
}

// MARK: 会议密码弹框 - AlertSingleTextFieldViewDelegate,UITextFieldDelegate
extension AVCMeetingViewController: AlertSingleTextFieldViewDelegate, UITextFieldDelegate {
    func alertSingleTextFieldViewViewDidLoad(viewVC: AlertSingleTextFieldViewController) {
        viewVC.showTitleLabel.text = tr("主持人密码")
        viewVC.showInputTextField.isSecureTextEntry = true
        viewVC.showInputTextField.placeholder = tr("请输入密码")
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
    func updateBotomSmalIV()  {
        // 显示小画面 更新本地小画面
        if !self.showRightBottomSmallIV.isHidden {
            self.manager.updateVideoWindow(localView: self.locationVideoView, callId: PicInPicView.id)
        }
//        self.updateCameraOpenClose()
    }
}

// MARK: PopTitleNormalViewDelegate
extension AVCMeetingViewController: PopTitleNormalViewDelegate {
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController) {
    }
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath) {
        
        SessionManager.shared.watchingAttend = nil
        SessionManager.shared.chairPassword = ""
        SessionManager.shared.isCameraOpen = false
        
        alertSingalVC?.destroyVC()
        
        if index.row == 0 {
            self.endMeetingDismissVC()
            showBottomHUD(tr("离开会议"))
        } else if index.row == 1 {
            self.endMeetingDismissVC(isEndConf: true)
            Toast.showBottomMessage(tr("会议已结束"))
        }else { //取消
            viewVC.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Menu弹框
extension AVCMeetingViewController {
    
    fileprivate func isShowSwitchCamera() -> Bool {
        // 共享界面
        if auxRecvinng && videoStreamView?.currentPage == 0 {
            return false
        }
        return SessionManager.shared.isCameraOpen
    }
    fileprivate func getChairmanMoreAction() -> [YCMenuAction] {
        var actionArray: [YCMenuAction] = []
        // 主持人
        
        if isShowSwitchCamera() {
            actionArray.append(YCMenuAction.init(title: tr("切换摄像头"), image: nil) { [weak self](_) in
                guard let self = self else { return }
                CLLog("切换摄像头")
                self.switchCamera(cameraIndex: nil)
            })
        }else {
            //隐藏切换摄像头功能
        }
        
        // 画廊模式和辅流界面更多中不需要显示小画面
        if let videoStreamView = self.videoStreamView {
            if (videoStreamView.isAuxiliary && videoStreamView.currentPage == 1) || !videoStreamView.isAuxiliary {
                let littleViewTitle = self.showRightBottomSmallIV.isHidden ? tr("显示小画面") :tr("隐藏小画面")
                if self.attendeeArray.count >= 2 {
                    actionArray.append(YCMenuAction.init(title: littleViewTitle, image: nil) { [weak self] (_) in
                        guard let self = self else { return }
                        self.videoStreamView?.isUserControlForLocalVideoView = true

                        self.showRightBottomSmallIV.isHidden = !self.showRightBottomSmallIV.isHidden
                        self.videoStreamView?.userChooseSmallViewIsHidden = self.showRightBottomSmallIV.isHidden

                        // 显示小画面 更新本地小画面
                        if !self.showRightBottomSmallIV.isHidden {
                            self.manager.updateVideoWindow(localView: self.locationVideoView, callId: PicInPicView.id)
                        }
                    })
                }
            }
        }
        
        
        // 添加释放主持人按钮
        actionArray.append(YCMenuAction(title: tr("释放主持人"), image: nil, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.releaseChairmanWithAlert(num: self.mineConfInfo?.participant_id)
        }))
        
        if !(self.meetInfo?.endTime == nil || self.meetInfo?.endTime == "") {
            actionArray.append(YCMenuAction.init(title: tr("延长会议"), image: nil) { [weak self] (_) in
                CLLog("延长会议")
                guard let self = self else { return }
        
                // 设置会议时长
                let hourMinutePickerVC = ViewMinutesViewController.init(nibName: "ViewMinutesViewController", bundle: nil)
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
            searchAttendee.isAvcVideoComing = true
            self.navigationController?.pushViewController(searchAttendee, animated: true)
  
        }))
        return actionArray
    }
    
    fileprivate func getAttendeeMoreAction() -> [YCMenuAction] {
        
        var actionArray: [YCMenuAction] = []
        guard let mineConfInfo = self.mineConfInfo else { return actionArray }
//        //判断会议中是否有主持人
//        var isHaveChairMan = false
//        for att in self.attendeeArray {
//            if att.role == .CONF_ROLE_CHAIRMAN {
//                isHaveChairMan = true
//            }
//        }
        
        let title = mineConfInfo.hand_state ? tr("手放下") : tr("举手")
        actionArray.append(YCMenuAction.init(title: title,titleColor: (!(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) && !mineConfInfo.hand_state) ? .lightGray : .white, image: nil) { [weak self] (_) in
            guard let self = self else { return }
            if !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) && !mineConfInfo.hand_state {
//                self.showBottomHUD(tr("会议无主持人，不能举手"), view: self.view)
            } else {
                let isSuccess = self.manager.raiseHand(handState: !mineConfInfo.hand_state, number: mineConfInfo.number)
                if !mineConfInfo.hand_state {
                    self.showBottomHUD(isSuccess ? tr("举手成功") : tr("举手失败"), view: self.view)
                }else {
                    self.showBottomHUD(isSuccess ? tr("取消举手成功") : tr("取消举手失败"), view: self.view)
                }
                CLLog("\(title)\(isSuccess ? "成功" : "失败")")
                if isSuccess {
                    mineConfInfo.hand_state = !mineConfInfo.hand_state
                }
            }
        })
        
        // 添加释放主持人按钮
        actionArray.append(YCMenuAction(title: tr("申请主持人"), titleColor: (manager.currentConfBaseInfo()?.hasChairman ?? false) ? .lightGray : .white,image: nil, handler: { [weak self] (_) in
            guard let self = self else { return }
            if self.manager.currentConfBaseInfo()?.hasChairman ?? false {
//                self.showBottomHUD(tr("会议已存在主持人，暂无法申请主持人"), view: self.view)
                return
            }
            self.isPWBullet = false
            
            if !self.manager.isSMC3(), SessionManager.shared.isSelfPlayCurrentMeeting, SessionManager.shared.isMeetingVMR  {
                CLLog("smc 2.0 vmr Chairperson----")
                ManagerService.confService()?.confCtrlRequestChairman(SessionManager.shared.cloudMeetInfo.chairmanPwd, number: mineConfInfo.participant_id)
                return
            }
            
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

            //没有主持人的情况
            ManagerService.confService()?.confCtrlRequestChairman("", number: mineConfInfo.participant_id)
        }))
        
        // 共享界面隐藏切换摄像头
        if isShowSwitchCamera() {
            // 与会者
            actionArray.append(YCMenuAction.init(title: tr("切换摄像头"), image: nil) { [weak self] (_) in
                CLLog("切换摄像头")
                guard let self = self else { return }
                self.switchCamera(cameraIndex: nil)
            })
        }else {
            //隐藏切换摄像头功能
        }
        
        // 画廊模式和辅流界面更多中不需要显示小画面
        if let videoStreamView = self.videoStreamView {
            if (videoStreamView.isAuxiliary && videoStreamView.currentPage == 1) || !videoStreamView.isAuxiliary {
                let littleViewTitle = self.showRightBottomSmallIV.isHidden ? tr("显示小画面") :tr("隐藏小画面")
                if self.attendeeArray.count >= 2 {
                    actionArray.append(YCMenuAction.init(title: littleViewTitle, image: nil) { [weak self] (_) in
                        guard let self = self else { return }
                        self.videoStreamView?.isUserControlForLocalVideoView = true

                        self.showRightBottomSmallIV.isHidden = !self.showRightBottomSmallIV.isHidden
                        self.videoStreamView?.userChooseSmallViewIsHidden = self.showRightBottomSmallIV.isHidden

                        // 显示小画面 更新本地小画面
                        if !self.showRightBottomSmallIV.isHidden {
                            self.manager.updateVideoWindow(localView: self.locationVideoView, callId: PicInPicView.id)
                        }
                    })
                }
            }
        }
        
        return actionArray
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
        menu?.delegate = self
        menu?.show()
    }
}

// MARK: 会控处理
extension AVCMeetingViewController {
    // 设置导航栏和底部菜单栏是否显示
    func setControlNaviAndBottomMenuShow(isShow: Bool, isAnimated: Bool) {
        self.hideFuncBtnsCount = 0
        self.isShowFuncBtns = isShow
        UIView.animate(withDuration: isAnimated ? 0.25 : 0) {
            if isShow {
                self.showNaviAndBottom()
            } else {
                self.hideNaviAndBottom()
            }
        }
    }
    // 隐藏
    func hideNaviAndBottom() {
        self.bottomMenuBottomConstraint.constant = -60.0
        self.navTopConstraint.constant = -62
        if UI_IS_BANG_SCREEN {
            self.soundLeftConstraint.constant = -84.0
        } else {
            self.soundLeftConstraint.constant = -60.0
        }
        // 隐藏menu
        self.menuView?.dismiss()
        showRightSmallFrame(isShow: false)
    }
    // 显示
    func showNaviAndBottom() {
        self.bottomMenuBottomConstraint.constant = 0.0
        self.navTopConstraint.constant = 0
        self.soundLeftConstraint.constant = 16.0
        showRightSmallFrame(isShow: true)
    }

    func showRightSmallFrame(isShow: Bool) {
        showRightBottomSmallIV.interfaceOrientationChange = self.displayShowRotation

        let screenHeight = min(SCREEN_WIDTH, SCREEN_HEIGHT)
        var localVideoFrame: CGRect = self.showRightBottomSmallIV.frame
        let bottomViewHeight = self.bottomView.frame.size.height
        if localVideoFrame.origin.y >= (screenHeight - bottomViewHeight - localVideoFrame.size.height - 10) {
            if isShow {
                localVideoFrame.origin.y = screenHeight - bottomViewHeight - localVideoFrame.size.height - 10
            } else {
                localVideoFrame.origin.y = screenHeight - localVideoFrame.size.height
            }
        }
        
        if localVideoFrame.origin.y <= self.navBackView.frame.height  {
            if isShow {
                localVideoFrame.origin.y = self.navBackView.frame.height
            }else {
                localVideoFrame.origin.y = 0
            }
        }
        self.showRightBottomSmallIV.frame = localVideoFrame
    }
}

// MARK: - 通知
extension AVCMeetingViewController {

    func installNotification() {
        // 广播事件
        NotificationCenter.default.addObserver(self, selector: #selector(notificationBroadcoatInd), name: NSNotification.Name(CALL_S_CONF_EVT_BROADCAST_IND), object: nil)
        //是否真正进会
        NotificationCenter.default.addObserver(self, selector: #selector(notficationRealJoinMeeting(notification:)), name: NSNotification.Name.init(CALL_S_CONF_BASEINFO_UPDATE_KEY), object: nil)
        
        //stop tuoluoyi
        NotificationCenter.default.addObserver(self, selector: #selector(notficationStartTuoluoyi(notification:)), name: NSNotification.Name.init("STOP_TUOLOUYI_NOTIFI"), object: nil)
        
        //举手主席提示
        NotificationCenter.default.addObserver(self, selector: #selector(notficationHandUpResult(notification:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_HAND_UP_IND), object: nil)
        //会议签到
        NotificationCenter.default.addObserver(self, selector: #selector(notficationMeetCheckInResult), name: NSNotification.Name.init(CALL_S_CONF_EVT_CHECKIN_RESULT), object: nil)
        // 离开或结束会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl), name: NSNotification.Name(CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: nil)
        
        // 离开或结束会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallEnd), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_ENDED), object: nil)
        //查看音视频会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationLookAudioAndVideoQualityViewCtrl), name: NSNotification.Name(LookAudioAndVideoQualityNotifiName), object: nil)

        // 进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAppInactiveNotify), name: UIApplication.willResignActiveNotification, object: nil)
        // 进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAppActiveNotify), name: UIApplication.didBecomeActiveNotification, object: nil)
        // 与会者列表更新
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAttendeeUpdate), name: NSNotification.Name(CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE), object: nil)
        // 延长会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationExtensionConfLen), name: NSNotification.Name(CALL_S_E_CONF_POSTPONE_CONF), object: nil)
        // 加入共享辅流回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationShareData), name: NSNotification.Name(CALL_S_CALL_EVT_DECODE_SUCCESS), object: nil)
        
        // 开始共享辅流decode_sucess
        NotificationCenter.default.addObserver(self, selector: #selector(notificationStartShareData), name: NSNotification.Name(CALL_S_CONF_CALL_EVT_DATA_START), object: nil)
        // 共享绑定
        NotificationCenter.default.addObserver(self, selector: #selector(notificationappShareAttach), name: NSNotification.Name(DATA_CONF_AUX_STREAM_BIND_NOTIFY), object: nil)
        // 辅流共享失败
        NotificationCenter.default.addObserver(self, selector: #selector(notficationStartFailure(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_AUX_SHARE_FAILED), object: nil)
        // 停止辅流（停止接收共享）
        NotificationCenter.default.addObserver(self, selector: #selector(notificationStopShareData), name: NSNotification.Name(CALL_S_CALL_EVT_AUX_DATA_STOPPED), object: nil)
        // 申请主持人通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRequestChairman), name: NSNotification.Name(CALL_S_CONF_REQUEST_CHAIRMAN), object: nil)
        // 释放主持人通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReleaseChairman), name: NSNotification.Name(CALL_S_CONF_RELEASE_CHAIRMAN), object: nil)
        // 当前屏幕方向监听
        NotificationCenter.default.addObserver(self, selector: #selector(deviceCurrentMotionOrientationChanged), name: NSNotification.Name(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
        // 呼出事件
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallOutgoing), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_OUTGOING), object: nil)
        // 设备管理TSDK回调，对应 ID：2014 接口
        NotificationCenter.default.addObserver(self, selector: #selector(notificationListenListenChange(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_CALL_ROUTE_CHANGE), object: nil)
        // 关闭视频通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationDowngradeVideo), name: NSNotification.Name(CALL_S_CALL_EVT_CLOSE_VIDEO_IND), object: nil)
        // 视频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationVideoQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_VIDEO_NET_QUALITY), object: nil)
        // 音频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationAudioQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_AUDIO_NET_QUALITY), object: nil)
        
        //呼叫转移
        NotificationCenter.default.addObserver(self, selector: #selector(notficationRefer(notification:)), name: NSNotification.Name(CALL_S_CALL_EVT_REFER_NOTIFY), object: nil)
        
        self.registerExtensionRecordLogsUpdate()
    }
    
    //呼叫转移
    @objc func notficationRefer(notification: Notification) {
        //呼叫转移后重新判断摄像头状态
        CLLog("--CALL_S_CALL_EVT_REFER_NOTIFY--")
        setCameraOpenCloseJoninMeetingNow()
    }
    
    @objc func notficationStartTuoluoyi(notification: Notification) {
        DeviceMotionManager.sharedInstance()?.start()
    }
    
    // 广播事件
    @objc func notificationBroadcoatInd(notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Any],
              let isBroadcast = userInfo["isBroadcast"] as? String  else {
            return
        }
        (isBroadcast == "1") ? (isHaveBroadcastForEvt = true) :  (isHaveBroadcastForEvt = false)
    }
    
    @objc func notificationCallEnd()  {
        CLLog("收到了SDK离会通知")
    }
    
    @objc func notficationHandUpResult(notification:Notification) {
        guard let noti = notification.userInfo as? [String:String] else {
            return
        }
        let handUpInfo = noti[ECCONF_HAND_UP_RESULT_KEY]
        if self.mineConfInfo?.name != handUpInfo {
            self.showBottomHUD("\(handUpInfo ?? "")" + tr("正在举手"), view: self.view)
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
            let text = String(format: tr("%@的会议"), self.mineConfInfo?.name ?? "")
            let text2 = String(format: tr("%@的会议"), self.mineConfInfo?.name ?? "")
            self.showUserNameLabel.text = SessionManager.shared.isMeetingVMR ? ("\(self.meetInfo?.confSubject ?? text)") : "\(self.meetInfo?.confSubject ?? text2)"
            self.attCountLable.text = "(\(self.attendeeArray.count))"
            refreshAttendeeInfo()
        }
    }
    
        //会议签到提示
    @objc func notficationMeetCheckInResult(notification:Notification) {
        MBProgressHUD.showBottom(tr("会议签到成功"), icon: nil, view: nil)
    }
    
    @objc func notificationListenListenChange(notification:Notification){
//        self.showTopVoiceBtn.isEnabled = true
        guard let noti = notification.userInfo as? [String:String] else {
            return
        }
        let routeType = noti[AUDIO_ROUTE_KEY]
        CLLog("avc >> notify >>routeType:\((routeType)!)")
        switch routeType {
        case "0":
            CLLog("avc >> notify >>routeTypeError:\((routeType)!)")
            break
        case "1":
            self.enterLouderSpeakerModel()
            break
        case "2","4":
            self.enterHeadSetModel()
            break
        case "3":
            self.enterSpeakerModel()
           break
        default:
            break
        }
    }

    /// 查看音视频质量
    /// - Parameter notification: nil
    @objc func notificationLookAudioAndVideoQualityViewCtrl (notification: Notification) {
//        refreshSignalButtonImg()
        presentSignalAlert()
    }
    // 离开或结束会议
    @objc func notificationQuitToListViewCtrl(notification: Notification) {
        CLLog("notificationQuitToListViewCtrl")
        SessionManager.shared.watchingAttend = nil
        SessionManager.shared.chairPassword = ""
        self.endMeetingDismissVC()
        if let _ = notification.object as? String {
            CLLog("会议已结束")
            Toast.showBottomMessage(tr("会议已结束"))
        }
    }
    // 进入后台
    @objc func notificationAppInactiveNotify(notification: Notification) {
        CLLog("notificationAppInactiveNotify")
        guard let callInfo = self.callInfo else {
            return
        }
        DeviceMotionManager.sharedInstance()?.stop()
        manager.switchCameraOpen(false, callId: PicInPicView.id)
        self.refreshVideoImageWith(cameraStatus: false)
        if callInfo.stateInfo.callType == CALL_VIDEO && callInfo.stateInfo.callState == CallState.taking && SessionManager.shared.isCameraOpen {
        }
        self.resetScreenShareStatus()
        if auxRecvinng {
            ManagerService.call()?.controlAuxData(whenApplicationResignActive: false, callId: PicInPicView.id)
            ManagerService.call()?.controlAuxData(whenApplicationResignActive: true, callId: PicInPicView.id)
        }
        
        // FIX_WANGLIANJIE_START
        /**
         manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x03), andIsSync: true, callId: callInfo.stateInfo.callId )
         manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x02), andModule: EN_VIDEO_OPERATION_MODULE.init(0x03), andIsSync: true, callId: callInfo.stateInfo.callId )
         */
        // FIX_WANGLIANJIE_END
        
    }
     
    // MARK: App进入前台
    @objc func notificationAppActiveNotify(notification: Notification) {
        CLLog("notificationAppActiveNotify")
        guard let callInfo = self.callInfo else {
            return
        }
        resetCameraStatus()
        
        if myShare {
            manager.switchCameraOpen(false, callId: PicInPicView.id)
            refreshVideoImageWith(cameraStatus: false)
        }
        if auxRecvinng {
            ManagerService.call()?.controlAuxData(whenApplicationResignActive: false, callId: PicInPicView.id)
            ManagerService.call()?.controlAuxData(whenApplicationResignActive: true, callId: PicInPicView.id)
            self.updateScreenShareStatus(updateNow: true)
        }

        // FIX_WANGLIANJIE_START
        /**
         manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x03), andIsSync: true, callId: callInfo.stateInfo.callId)
         manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x01), andModule: EN_VIDEO_OPERATION_MODULE.init(0x03), andIsSync: true, callId: callInfo.stateInfo.callId)
         manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x04), andModule: EN_VIDEO_OPERATION_MODULE.init(0x03), andIsSync: true, callId: callInfo.stateInfo.callId)
         */
        // FIX_WANGLIANJIE_START
        
    }
    // 与会者列表更新回调通知
    @objc func notificationAttendeeUpdate(notification: Notification) {
        CLLog("notificationAttendeeUpdate")
        
        // 更新会议ID
        
        if let confInfo = manager.currentConfBaseInfo() {
            self.meetInfo = confInfo
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
            if let confInfo = self.manager.currentConfBaseInfo() {
                self.meetInfo?.confSubject = confInfo.confSubject
                let text = String(format: tr("%@的会议"), self.mineConfInfo?.name ?? "")
                let text2 = String(format: tr("%@的会议"), self.mineConfInfo?.name ?? "")
                self.showUserNameLabel.text = SessionManager.shared.isMeetingVMR ? ("\(self.meetInfo?.confSubject ?? text)") : "\(self.meetInfo?.confSubject ?? text2)"
                self.attCountLable.text = "(\(self.attendeeArray.count))"
                //刷新小画面是否隐藏  大于2个在没操作过前显示
                if attendeeArray.count > 1 && (!(self.videoStreamView?.isUserControlForLocalVideoView ?? false)) && !isHaveFirstShowSmallIV {
                    isHaveFirstShowSmallIV = true
                    self.showRightBottomSmallIV.isHidden = false
                    self.manager.updateVideoWindow(localView: self.locationVideoView, callId: PicInPicView.id)
                }else if attendeeArray.count <= 1 && !(self.videoStreamView?.isUserControlForLocalVideoView ?? true) {
                    isHaveFirstShowSmallIV = false
                    self.showRightBottomSmallIV.isHidden = true
                    isHaveFirstShowSmallIV = false
                }
            }
       }
       
        self.refreshAttendeeInfo()
        
        // 与会者发生改变
        NotificationCenter.default.post(name: NSNotification.Name("SUSPEN_ECCONF_ATTENDEE_UPDATE_KEY"), object: nil)
    }
    // 延长会议回调通知
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
    // 加入共享辅流回调通知  CALL_S_CALL_EVT_DECODE_SUCCESS  解码成功>>>明确有视频数据的回调
    @objc func notificationShareData(notification: Notification) {
        if self.meetInfo != nil {
            self.updateVideoConfig()
        }
        CLLog("DECODE_SUCCESS>> 1,收到辅流>")
//        self.updateScreenShareStatus(updateNow: false)
        if !UserDefaults.standard.bool(forKey: "aux_rec") {return}
        // 如果自己有共享。被抢共享后需要停止本地共享
        self.passiveStopShareScreen()
        
        self.auxRecvinng = true
        self.isShare = true
        self.myShare = false
        SessionManager.shared.bfcpStatus = .remoteRecvBFCP
        // 接收到辅流数据
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AUX_RECCVING_SHARE_DATA), object: nil)
        // 更新辅流数据
        self.videoStreamView?.isMyshare = self.myShare
        self.videoStreamView?.isAuxiliary = true
        self.shareBackView.dismissCurrentView()
        CLLog("DECODE_SUCCESS>> 2,收到辅流>")
    }
    // 开始共享辅流回调通知s
    @objc func notificationStartShareData(notification: Notification) {
        self.auxStartSending()
        CLLog("辅流>>>>本端开始共享")
        self.auxRecvinng = false
    
    }
    // 共享绑定回调通知
    @objc func notificationappShareAttach(notification: Notification) {
        CLLog("notificationappShareAttach")
        manager.appShareAttach(EAGLViewAvcManager.shared.viewForBFCP)
    }
    // 辅流发送失败
    @objc func notficationStartFailure(notfication: Notification) {
        CLLog("辅流发送失败")
        guard let reasonDIc = notfication.userInfo as? [String: String], let reason =  reasonDIc[TSDK_AUX_REASONCODE_KEY], let reasoncode = Int(reason) else {
            return
        }
        switch reasoncode {
        case 1:MBProgressHUD.showBottom(tr("申请共享权限失败"), icon: nil, view: nil)

        case 2:MBProgressHUD.showBottom(tr("网络异常"), icon: nil, view: nil)

        case 3:MBProgressHUD.showBottom(tr("网络异常"), icon: nil, view: nil)

        case 4:MBProgressHUD.showBottom(tr("申请共享权限失败"), icon: nil, view: nil)

        case 5:MBProgressHUD.showBottom(tr("申请共享权限失败"), icon: nil, view: nil)

        case 6:MBProgressHUD.showBottom(tr("抢占共享失败"), icon: nil, view: nil)

        case 7:MBProgressHUD.showBottom(tr("网络异常"), icon: nil, view: nil)

        case 8:MBProgressHUD.showBottom(tr("网络较差共享失败"), icon: nil, view: nil)

        default:
            MBProgressHUD.showBottom(tr("共享失败"), icon: nil, view: nil)
            break
        }
        CLLog("辅流发起失败原因：reasoncode \(reasoncode)")
        CLLog("辅流>>正在接收共享?： \(auxRecvinng)")
        
        self.auxRecvinng = false
        if reasoncode == 6 {
            self.auxRecvinng = true
        }
        self.isShare = self.auxRecvinng
        self.myShare = false
        SessionManager.shared.bfcpStatus = .noBFCP
        // 如果自己有共享。被抢共享后需要停止本地共享
        self.passiveStopShareScreen()
        self.shareBackView.dismissCurrentView()
        resetCameraStatus()
        self.videoStreamView?.isMyshare = self.myShare
        self.videoStreamView?.isAuxiliary = self.auxRecvinng
    }
    
    // 停止接收共享辅流回调通知
    @objc func notificationStopShareData(notification: Notification) {
        CLLog("辅流停止接收-MSGID = 2032(0)")
        //fix_20210219 yuep
        if self.meetInfo != nil {
            self.updateVideoConfig()
        }
        SessionManager.shared.bfcpStatus = .noBFCP
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AUX_RECCVING_STOP_SHARE), object: nil)
        self.shareBackView.dismissCurrentView()
        updateBotomSmalIV()
        if !myShare,auxRecvinng {
            CLLog("辅流停止接收-MSGID = 2032(他端停止)")
            self.isShare = false
            self.auxRecvinng = false
            UserDefaults.standard.setValue(false, forKey: "aux_rec")
            // 更新辅流数据
            self.updateScreenShareStatus(updateNow: self.auxRecvinng)
            return
        }
        //抢他端共享
        if myShare,auxRecvinng{
            self.deviceCurrentMotionOrientationChanged()
            resetCameraStatus()
            self.passiveStopShareScreen()
            myShare = false
            self.videoStreamView?.isMyshare = myShare
            CLLog("辅流停止接收-MSGID = 2032(本端停止)")
            return
        }
    }
    // 申请释放主持人回调
    @objc func notificationRequestChairman(notification: Notification) {
        CLLog("notificationRequestChairman")
        isApplayChairman = true
        guard let resultCode = notification.userInfo?[ECCONF_RESULT_KEY] as? NSNumber  else {
            if isPWBullet && isCurrentShow {
                showBottomHUD(tr("申请主持人失败"))
                isPWBullet = false
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
        
        if resultCode == 1 && isCurrentShow {
            CLLog("CONF_E_REQUEST_CHAIRMAN_RESULT - 申请主持人")
            if isCurrentShow {
                MBProgressHUD.hide(for: self.view, animated: true)
                showBottomHUD(tr("已申请主持人"), view: self.view)
            }
//            self.mineConfInfo!.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
//            self.isPWBullet = false
        } else  {
            if !self.isPWBullet && isCurrentShow{
                let alertVC = AlertSingleTextFieldViewController.init()
                alertVC.modalTransitionStyle = .crossDissolve
                alertVC.modalPresentationStyle = .overFullScreen
                alertVC.customDelegate = self
                self.alertVC = alertVC
                self.present(alertVC, animated: true) {
                    alertVC.showInputTextField.keyboardType = .numberPad
                    self.isPWBullet = true
                }
            } else {
                if isPWBullet && isCurrentShow {
                    showBottomHUD(tr("申请主持人失败"))
                    isPWBullet = false
                }
            }
        }
    }
    // 申请释放主持人回调
    @objc func notificationReleaseChairman(notification: Notification) {
        CLLog("notificationReleaseChairman")
        isApplayChairman = true
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
    // 陀螺仪监听旋转
    @objc func deviceCurrentMotionOrientationChanged() {
        CLLog("Device Orientation Changed - \(self.displayShowRotation.rawValue)")
        let callId = UInt32(meetInfo?.callId ?? 0)
//        self.displayShowRotation = SessionHelper.getOrientation()
//        if  (self.displayShowRotation == .landscapeLeft) || self.displayShowRotation == .landscapeRight {
            manager.rotationAVCVideo(callId: callId, cameraIndex: self.cameraCaptureIndex,
                                     showRotation: self.displayShowRotation)
//        }

    }
    
    // 呼出事件
    @objc func notificationCallOutgoing(notification: Notification) {
        CLLog("notificationCallOutgoing")
        if let result = notification.userInfo {
            self.callInfo = result[TSDK_CALL_INFO_KEY] as? CallInfo
            if let callId = self.callInfo?.stateInfo.callId {
                self.manager.currentConfBaseInfo()?.callId = Int32(callId)
                CLLog(">> changed camera status. callId:\(NSString.encryptNumber(with: String(callId)) ?? "0")")
                setCameraOpenCloseJoninMeetingNow()
            }
        }
    }
    
    @objc func notificationDowngradeVideo(notification: Notification) {
        CLLog("notificationDowngradeVideo - 视频会议转音频会议")
        
        ManagerService.call()?.currentCallInfo.stateInfo.callType = CALL_AUDIO
//        let convertModel = P2PConvertModel()
//        convertModel.meetInfo = meetInfo
//        convertModel.callInfo = callInfo
//        if let parentVC = self.parent as? MeetingContainerViewController {
//            parentVC.convertTo(type: .voiceMeeting, convertModel: convertModel)
//        }
    }
    
    // 视频质量变化
    @objc func notficationVideoQuality(notfication:Notification) {
        netLevelPicRefresh(notfication: notfication)
    }
    
    // 音频质量变化
    @objc func notficationAudioQuality(notfication:Notification) {
        netLevelPicRefresh(isVoice: true, notfication: notfication)
    }
    //抽离音视频质量图标刷新
    private func netLevelPicRefresh(isVoice: Bool = false, notfication:Notification) {
        guard let level = netLevelManager.getCurrenLevel(isVoice: isVoice, notfication: notfication) else {
            return
        }
        // 设置信号强度
        self.showsignalImageView.image = level.image
        netLevel = level.level
        NotificationCenter.default.post(name: NSNotification.Name("NET_LEVEL_UPDATE_NOTIFI"), object: nil, userInfo: ["netLevel": netLevel])
    }          
}

// MARK: 会议入会的麦克风摄像头耳机扬声器设置
extension AVCMeetingViewController {
    
    // 设置入会后摄像头打开或关闭
    func updateCameraOpenClose() {
        CLLog("updateCameraOpenClose")
        if let currentConf = manager.currentConfBaseInfo() {
            HWAuthorizationManager.shareInstanst.authorizeToCameraphone { [weak self] (isAuth) in
                guard let self = self else { return }
                if isAuth {
                  let _ = self.manager.switchCameraOpen(SessionManager.shared.isCameraOpen, callId: UInt32(currentConf.callId))
                    self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue) // 打开摄像头设置摄像头方向
                } else {
                    
                    if self.manager.switchCameraOpen(false, callId: UInt32(currentConf.callId)) {
                        SessionManager.shared.isCameraOpen = false
                    }
                }
                self.refreshVideoImage()
            }
        }
        // 屏幕旋转
        self.deviceCurrentMotionOrientationChanged()
    }
    
    // 切换摄像头
    func switchCamera(cameraIndex:Int?) {
        CLLog("switchCamera")
        if !SessionManager.shared.isCameraOpen {
            CLLog("switchCamera is off")
            return
        }
        
        if let currentConf = manager.currentConfBaseInfo() {
            if cameraIndex != nil {
                if cameraIndex == 0 {
                    self.cameraCaptureIndex = CameraIndex.back
                }else {
                    self.cameraCaptureIndex = CameraIndex.front
                }
            }else{
                self.cameraCaptureIndex = self.cameraCaptureIndex == CameraIndex.front ? CameraIndex.back : CameraIndex.front
            }
            manager.switchCameraIndex(self.cameraCaptureIndex, callId: UInt32(currentConf.callId))
            self.deviceCurrentMotionOrientationChanged()
        }
        
        if attendeeArray.count == 1 {
            manager.watchAttendeeNumber("") // 取消选看（选看多画面）
        }
    }
}

// MARK: - 拨号盘NumberBoardAble
extension AVCMeetingViewController: NumberBoardAble {
    
    @IBAction func dialNumber(_ sender: UIButton) {
        if self.numberKeyboardVc == nil {
            let numberKeyboardVc = NumberKeyboardController()
            numberKeyboardVc.delegate = self
            self.numberKeyboardVc = numberKeyboardVc
            numberKeyboardVc.interfaceOrientationChangeValue = self.displayShowRotation
            numberKeyboardVc.modalPresentationStyle = .overFullScreen
            numberKeyboardVc.modalTransitionStyle = .crossDissolve
            present(numberKeyboardVc, animated: true, completion: nil)
        }
    }
    
    func numberBoardText(_ resuleString: String, _ controller: UIViewController) {
        CLLog(resuleString)
        if resuleString == "" {
            return
        }
        
        CLLog("sendDTMF  +  \(resuleString)")
        let success = manager.sendDTMF(dialNum: resuleString, callId: manager.currentCallInfo()?.stateInfo.callId ?? 0)
        if resuleString == "#" {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: - YCMenuViewDelegate
extension AVCMeetingViewController: YCMenuViewDelegate {
    // 更多按钮弹框代理，作用为设弹框消失后小窗口下移
    func yCMenuViewDismiss() {
        resumeSmallViewFrame()
    }
}

// MARK: - VideoMeetingDelegate
extension AVCMeetingViewController: VideoMeetingDelegate {
    func isHiddenSmallVideoView() -> Bool {
        return self.showRightBottomSmallIV.isHidden
    }
    
    func showSmallVideoView() {
        self.showRightBottomSmallIV.isHidden = false
    }
    
    func hideSmallVideoView() {
        self.showRightBottomSmallIV.isHidden = true
    }
    
    func getLocalVideoView() -> EAGLView? {
        return self.locationVideoView
    }
}

extension AVCMeetingViewController: SuspendWindowDelegate {
    func svcLabelId() -> Int {
        return 0
    }
    
    func isSVCConf() -> Bool {
        return false
    }
    func isAuxNow() -> Bool {
        return auxRecvinng
    }
    func captureIndex() -> CameraIndex {
        return self.cameraCaptureIndex
    }
}

extension AVCMeetingViewController{
    func registerExtensionRecordLogsUpdate() -> Void {
        let notificationCenter = RecordNotifycationManager.sharedInstance()
        notificationCenter.register(forNotificationName: "ExtentionRecordStop") { [weak self] in
            //code to execute on notification
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if ManagerService.call()?.stopSendAuxData(withCallId:UInt32(self.meetInfo?.callId ?? 0)) ?? false {
                    self.isShare = false
                    SessionManager.shared.bfcpStatus = .noBFCP
                }
                CLLog("停止辅流")
                self.myShare = false
                self.videoStreamView?.isMyshare = self.myShare
                
                self.updateBotomSmalIV()
                self.resetCameraStatus()
                self.shareBtn.setTitle(tr("屏幕共享"), for: .normal)
                self.videoStreamView?.isAuxiliary = false
                self.shareBackView.removeFromSuperview()
                
            }
        }
        notificationCenter.register(forNotificationName: "ExtentionRecordFinished") { [weak self] in
            CLLog("用户主动停止共享>>ExtentionRecordFinished ")
           
            guard let self = self else { return }
            self.myShare = false
            self.videoStreamView?.isMyshare = self.myShare
            self.videoStreamView?.isAuxiliary = false
            self.shareBtn.setTitle(tr("屏幕共享"), for: .normal)
            self.shareBackView.removeFromSuperview()
            self.resetCameraStatus()
            autoreleasepool {
                ManagerService.call()?.stopSendAuxData(withCallId:UInt32(self.meetInfo?.callId ?? 0))
                // 接收到辅流数据
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:AUX_RECCVING_SHARE_DATA), object: nil)
            }
        }
        notificationCenter.register(forNotificationName: "ExtentionRecordStart") { [weak self] in
            CLLog("用户点击开始共享 ")
            autoreleasepool {
                guard let self = self else { return }
                self.auxStartSending()
            }
        }
        notificationCenter.register(forNotificationName: "ExtentionRecordSampleBufferUpdate") { [weak self] in
            guard self != nil else { return }
           CLLog("辅流正在更新>>>>")
       }
    }
    
    func updateScreenShareStatus(updateNow:Bool) -> Void {
        DispatchQueue.main.async {
            if updateNow {
                CLLog("GLVIEW-REBIND 刷新辅流......")
                self.isShare = true
                ManagerService.call()?.controlAuxData(whenApplicationResignActive: true, callId: PicInPicView.id)
                self.videoStreamView?.isMyshare = self.myShare
                self.videoStreamView?.isAuxiliary = true
                return
            }
            self.videoStreamView?.isMyshare = self.myShare
            self.videoStreamView?.isAuxiliary = false
        }
    }
    
    func resetScreenShareStatus() -> Void {
        self.videoStreamView?.currentBackGroudStatus = true
        if auxRecvinng {
            ManagerService.call()?.controlAuxData(whenApplicationResignActive: false, callId: PicInPicView.id)
        }
        CLLog("App进入后台")
    }
    
     func auxStartSending() {
        CLLog("notificationStartShareData，本端辅流已开始")
        if self.meetInfo != nil {
            self.updateVideoConfig()
        }
        self.auxRecvinng = false
        self.myShare = true
        self.isShare = true
        let callId = ManagerService.call()?.currentCallInfo.stateInfo.callId ?? 0
        ManagerService.call()?.startSendAuxData(withCallId: callId)
        manager.switchCameraOpen(false, callId: PicInPicView.id)
        refreshVideoImageWith(cameraStatus: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [self] in
            self.videoStreamView?.isMyshare = self.myShare
            SessionManager.shared.bfcpStatus = .localSendBFCP
            self.videoStreamView?.isAuxiliary = false
           //共享屏幕背景图
            self.shareBackViewConfig()
        }
    }
    
    private func shareBackViewConfig(){
        //改变按钮title
        if self.showBackgroundImageView.subviews.contains(self.shareBackView) {
            return
        }
        var  text = tr("停止共享")
        if !isCNlanguage() {
            text = " \(text) "
        }
        self.shareBtn.setTitle(text, for: .normal)
        //添加背景视图
        self.showBackgroundImageView.addSubview(self.shareBackView)
        self.shareBackView.mas_makeConstraints { (make) in
            make?.edges.equalTo()(0)
        }
        //添加手势点击
        let viewTapGesture = UITapGestureRecognizer.init(actionBlock: { [weak self](_) in
            guard let self = self else { return }
            self.setControlNaviAndBottomMenuShow(isShow: !self.isShowFuncBtns, isAnimated: true)
        })
        self.shareBackView.addGestureRecognizer(viewTapGesture)
        
        //停止屏幕共享
         self.shareBackView.callback = { [weak self] () in
             guard let self = self else {return}
            //停止共享
             self.passiveStopShareScreen()
         }
    }
    
    private func resetCameraStatus() {
//        manager.switchCameraOpen(false, callId: PicInPicView.id)
        if  SessionManager.shared.isCameraOpen {
            manager.switchCameraOpen(true, callId: PicInPicView.id)
            self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue) // 打开摄像头设置摄像头方向
            refreshVideoImageWith(cameraStatus: true)
            DeviceMotionManager.sharedInstance()?.start()
            self.deviceCurrentMotionOrientationChanged()
        }
    }
    //被动结束扩展进程
   private func passiveStopShareScreen() -> Void {
        self.myShare = false
        self.videoStreamView?.isMyshare = self.myShare
        let cfnotification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(cfnotification, CFNotificationName.init("STOPSHARED" as CFString), nil, nil, true)
        ManagerService.call()?.stopSendAuxData(withCallId:UInt32(self.meetInfo?.callId ?? 0))
        resetCameraStatus()
    }
    private func suspendwindowDisplay(isAux:Bool){
        // 移除方向监听
        removeOrientationObserver()
        //强制竖屏
        UIDevice.switchNewOrientation(.portrait)
        var tempType: SuspendType  = .video
        if isAux {
            tempType = .auxvid
        }
        
        SessionManager.shared.currentCalledSeconds = self.currentCalledSeconds
        suspend(coverImageName: "", type: tempType, svcManager: nil)
    }

}

extension AVCMeetingViewController {
    
     func enterHeadSetModel() {
        self.showTopVoiceBtn.setImage(UIImage.init(named: "session_video_headset"), for: .normal)
        self.previousRouteType = true
        self.showTopVoiceBtn.isSelected = false
    }
    
    func enterLouderSpeakerModel(){
        self.showTopVoiceBtn.isSelected = true
        self.showTopVoiceBtn.setImage(UIImage.init(named: "session_video_sound"), for: .normal)
    }
     func enterSpeakerModel() {
        
        self.showTopVoiceBtn.isSelected = false
        //拔掉耳机之后默认进入 听筒模式
        self.showTopVoiceBtn.setImage(UIImage.init(named: "session_video_headset"), for: .normal)
    }
}

