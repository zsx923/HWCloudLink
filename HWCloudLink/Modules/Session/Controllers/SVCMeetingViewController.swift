//
//  SVCMeetingViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/10.
//  Copyright © 2020 陈帆. All rights reserved.

import UIKit
import ReplayKit
import MediaPlayer



class SVCMeetingViewController: MeetingViewController {
    
    static var viewTapGesture : UITapGestureRecognizer?
    
    @IBOutlet weak var attendCount: UILabel!
    @IBOutlet weak var numberPadBtn: UIButton!
    @IBOutlet weak var navBackView: UIView!
    @IBOutlet weak var navTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var showRecordTimeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControlBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showBackgroundImageView: UIImageView!
    @IBOutlet weak var showRightBottomSmallIV: DrapView!
    @IBOutlet weak var showSecurityImageView: UIImageView!
    @IBOutlet weak var showsignalImageView: UIImageView!
    @IBOutlet weak var showMeetTitleView: UIView!
    @IBOutlet weak var showSignalView: UIView!
    @IBOutlet weak var showRecordTimeLabel: UILabel!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var showUserNameLabel: UILabel!
    @IBOutlet weak var showUserIDLabel: UILabel!
    @IBOutlet weak var showTopVoiceBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var signalLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var cammerButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sitesButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    // 导航栏字体颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    // 创建本地视频画面
    public lazy var locationVideoView: EAGLView  = {
        return createLocationVideoView()
    }() ?? EAGLViewAvcManager.shared.viewForLocal
    // 大画面
    var videoStreamView: SVCMeetingBackView?
    //录屏相关
    lazy var broadcastPickerView : RPSystemBroadcastPickerView =  {
        let broadcastPickerView = RPSystemBroadcastPickerView()
        broadcastPickerView.size = CGSize(width: 0.0001, height: 0.0001)
        broadcastPickerView.showsMicrophoneButton = false
        broadcastPickerView.preferredExtension = REPLAY_EXTENSION_ID
        return broadcastPickerView
    }()
    
    // svcManager
    public let svcManager = SVCMeetingManager()
    
    // device control mannager
    private var callManager = CallMeetingManager()
    private let netLevelManager = NetLevel()
    // 是否在入会在后更新一次摄像头和麦克风
    private var isUpdataCameraMicrophoneState = false
    // 是否是自动申请主席
    private var isAutomaticallyChairperson = false
    
    // 是否申请主持人填写密码弹框
    private  var isPWBullet : Bool = false
    // 底部控制栏是否展示
    fileprivate var isShowFuncBtns = true
    
    
    //右侧navItem点击之后 vc
    public weak var popTitleVC :PopTitleNormalViewController?
    //拨号盘vc
    public weak var numberKeyboardVc: NumberKeyboardController?
    //延长时间vc
    public weak var hourMinutePickerVC: ViewMinutesViewController?
    //信号vc
    public weak var alertSingalVC : AlertTableSingalViewController?
    //会议详情vc
    public weak var meetInfoVC : MeetingInfoViewController?
    
    // 摄像头类型
    public var cameraCaptureIndex = CameraIndex.front
    // 当前屏幕方向
    fileprivate var displayShowRotation: UIInterfaceOrientation = .portrait
    // 是否进入后台
    fileprivate var isEnterBackground = false
    
    
    var previousRouteType:Bool = false
    
    // 定时器
    fileprivate var timer: Timer?
    // fileprivate 当前通话秒数
    var currentCalledSeconds: Int = 1
    // 底部View显示时间  显示5秒后隐藏
    var bottomViewShowSeconds: Int = 0
    // 当前信号质量
    var netLevel:String = "5"
    // 是否打开了扬声器操作
    private var isOpenVoiceBtn: Bool = false
    
    var isShare :Bool = false
    var isShareBtnDisable :Bool = false
    
    private var auxRecvinng: Bool = false
    
    // 更多menu
    fileprivate var menuView: YCMenuView?
    // 小画面位置位置
    private var smallViewOldFrame: CGRect?
    
    
    // 如果需要回传数据则使用，否则不用
    var updatCallSecondBlock: UpdateCallSecondsBlock?
    
    
    //延长会议成功之后的文本提示
    private var delayTimeStr: String = ""
    
    var shareBackView: ShareScreenBackView = {
        let shareView = ShareScreenBackView.shareScreenBackView()
        shareView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height:  kScreenHeight)
        return shareView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CLLog("viewWillAppear")
        //DTS2020122602742
        if !self.isOpenVoiceBtn{
            self.initDefaultRouter()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CLLog("viewWillDisappear")
        // 关闭屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CLLog("viewDidAppear")
        self.displayShowRotation = .portrait
        // 调节摄像头方向
        DeviceMotionManager.sharedInstance()?.start()
        // 旋转屏幕摄像头方向
        self.setCameraDirectionWithRotation()
        
        isShareBtnDisable = true
        // 4.GCD 主线程/子线程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            self.isShareBtnDisable = false
        }
        // 屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CLLog("viewDidDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CLLog("- 加入视频会议 - SVC - \(callManager.isSMC3())")
        // 设置导航栏
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
        self.setControlNaviAndBottomMenuShow(isShow: true, isAnimated: false)
        svcManager.isAuxiliary = false
        svcManager.isClickCancleRaise = false
        svcManager.isPolicy = SessionManager.shared.isPolicy
        SessionManager.shared.bfcpStatus = .noBFCP
        self.currentCalledSeconds = SessionManager.shared.currentCalledSeconds
        SessionManager.shared.currentCalledSeconds = 0
        // 设置UI
        self.setViewUI()
        // 设置当前会议默认状态
        self.setMeetingDefaultStatus()
        // 设置显示会议Cell信息
        self.setCalledViewUI()
        // 入会设置会议信息
        self.setMeetingDataTitle()
        // 加载通知
        self.installNotification()
    }
    
    func setMeetingDefaultStatus() {
        // 设置当前是会议
        SessionManager.shared.isConf = true
        // 当前接听的call对象信息
        svcManager.currentCallInfo = callManager.currentCallInfo()
        svcManager.bindWidth = Int(svcManager.currentCallInfo?.bandWidth ?? 1920)
        print("------------- bindWidth svcManager",svcManager.bindWidth)
        // 当前会议信息
        svcManager.currentMeetInfo = callManager.currentConfBaseInfo()
        // 判断是否显示拨号盘（3.0下有来宾密码显示拨号盘）
        if callManager.isSMC3() {
            if (svcManager.currentMeetInfo?.generalPwd == nil) || svcManager.currentMeetInfo?.generalPwd == "" {
                self.numberPadBtn.isHidden = false
            }
        }
        // 设置前置摄像头
        auxRecvinng = UserDefaults.standard.bool(forKey: "aux_rec")
    }
    // 设置
    func setViewUI() {
        self.showUserNameLabel.text = tr("会议")
        
        // 会议时间label
        self.showRecordTimeLabel.layer.shadowColor = UIColor.black.cgColor
        self.showRecordTimeLabel.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.showRecordTimeLabel.layer.shadowRadius = 2.0
        self.showRecordTimeLabel.layer.shadowOpacity = 0.7
        self.showRecordTimeLabel.isHidden = true
        
        // 离开按钮
        self.leaveBtn.layer.borderColor = COLOR_RED.cgColor
        self.leaveBtn.layer.borderWidth = 1.0
        self.leaveBtn.setTitle(tr("离开"), for: .normal)
        
        // 小画面
        self.showRightBottomSmallIV.isHidden = true
        self.showRightBottomSmallIV.clipsToBounds = true
        self.showRightBottomSmallIV.layer.cornerRadius = 2.0
        self.showRightBottomSmallIV.layer.borderWidth = 1.0
        self.showRightBottomSmallIV.layer.borderColor = UIColorFromRGB(rgbValue: 0x979797).cgColor
        
        let tempLocationV = self.locationVideoView
        self.showRightBottomSmallIV.addSubview(tempLocationV)
        
        
        // 首次入会底部按钮不能点击
        bottomBtnisEnabled(isEnabled: false)
        
        // 设置底部按钮图片颜色
        self.muteButton.isSelected = !SessionManager.shared.isMicrophoneOpen
        refreshMuteImage(isMute: true)
        self.cammerButton.isSelected = SessionManager.shared.isCameraOpen
        refreshVideoImage(isCameraOpen: false)
        refreshShareImage()
        refreshAddUserImage()
        refreshMoreImage()
        
        // 添加共享
        view.addSubview(broadcastPickerView)
        
        // 设置信号强度
        let signalImg = SessionHelper.getSignalQualityImage(netLevel: "5")
        self.showsignalImageView.image = signalImg
        
        // 标题点击
        let titleGesture = UITapGestureRecognizer.init(target: self, action: #selector(titleSelectShowMeetDetail(tapGesture:)))
        self.showMeetTitleView.addGestureRecognizer(titleGesture)
        
        // 分页三个小点
        self.pageControl.hidesForSinglePage = true
        self.pageControl.numberOfPages = 0
        
        self.videoStreamView = SVCMeetingBackView.svcMeetingBackView()
        self.videoStreamView?.svcManager = svcManager
        self.videoStreamView?.smallVideoViewHideBlock = { [weak self] (isHidden) in
            guard let self = self else { return }
            if isHidden {
                self.hideSmallVideoView()
            } else {
                self.showSmallVideoView()
            }
        }
        self.videoStreamView?.configSignalLabelBlock = { (str) in
            //            self?.signalLabel.text = str
        }
        // 添加背景点击
        SVCMeetingViewController.viewTapGesture = UITapGestureRecognizer.init(actionBlock: { [weak self] (gesture) in
            guard let self = self else { return }
            self.setControlNaviAndBottomMenuShow(isShow: !self.isShowFuncBtns, isAnimated: true)
        })
        
        //        viewTapGesture.delegate = self
        if let videoStreamView = self.videoStreamView {
            
            videoStreamView.isUserInteractionEnabled = true
            videoStreamView.addGestureRecognizer(SVCMeetingViewController.viewTapGesture ?? UITapGestureRecognizer.init())
            videoStreamView.pageControl = self.pageControl
            
            videoStreamView.frame = CGRect(x: 0, y: 0, width: self.showBackgroundImageView.size.width, height: self.showBackgroundImageView.size.height)
        }
        
        self.shareButton.titleLabel?.numberOfLines = 2
    }
    
    // 创建本地视频画面
    private func createLocationVideoView() -> EAGLView? {
        let temp = EAGLViewAvcManager.shared.viewForLocal
        temp.backgroundColor = UIColor.clear
        temp.frame = CGRect(x: 1, y: 1, width: self.showRightBottomSmallIV.width-2, height: self.showRightBottomSmallIV.height-2)
        temp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        return temp
    }
    
    func setCalledViewUI() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        // 保存会议信息
        if let callInfo = callManager.currentCallInfo() {
            SVCMeetingBackView.id = callInfo.stateInfo.callId
        }
        svcManager.currentCallInfo = callManager.callInfo()?.callInfoWithcallId(String(SVCMeetingBackView.id))
        svcManager.bindWidth = Int(svcManager.currentCallInfo?.bandWidth ?? 1920)
        print("------------- bindWidth svcManager 2",svcManager.bindWidth)
        svcManager.useLastSsrc = svcManager.currentCallInfo?.ulSvcSsrcStart ?? 0
        
        // 设置定时器
        self.showRecordTimeLabel.isHidden = false
        self.showRecordTimeLabel.text = NSString.init(format: "%@", NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds)) as String
        self.view.bringSubviewToFront(self.showRecordTimeLabel)
        self.view.bringSubviewToFront(self.pageControl)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (sender) in
            guard let self = self else { return }
            // 底部状态栏隐藏
            if self.isShowFuncBtns {
                self.bottomViewShowSeconds += 1
                if self.bottomViewShowSeconds == 5 {
                    self.setControlNaviAndBottomMenuShow(isShow: false, isAnimated: true)
                }
            }
            
            // 显示时间
            self.currentCalledSeconds += 1
            self.showRecordTimeLabel.text = NSString.init(format: "%@", NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds)) as String
            
            // 语音激励显示时间增加 5秒后设置边框颜色为空
            self.videoStreamView?.isHiddenBlueBox += 1
            self.videoStreamView?.setCurrentCellVideoBackColor(hiddenTime: 2)
            
            // 设置会议主题
            if self.isShowFuncBtns {
                self.setMeetingDataTitle()
            }
            
            // 获取当前远端帧率
            self.videoStreamView?.loadStreamData()
        })
        RunLoop.current.add(self.timer!, forMode: .common)
        
        // 底部图片
        self.view.insertSubview(self.showBackgroundImageView, at: 0)
        self.showBackgroundImageView.image = nil
        self.showBackgroundImageView.backgroundColor = UIColor.black
        if let videoStreamView = self.videoStreamView {
            self.showBackgroundImageView.addSubview(videoStreamView)
        }
    }
    
    
    // 设置当前会议中信息
    func setInitData() {
        // 未返回与会者则不执行操作
        if callManager.haveJoinAttendeeArray().count == 0 {
            return
        }
        // 处理会议中与会者数组信息、筛选主持人、选看、广播、自己
        self.svcManager.conferenceSetAttendeeArray()
        // 会议中第二次(SMC上打开麦克风)
        if self.svcManager.mineConfInfo != nil, self.isUpdataCameraMicrophoneState == true {
            HWAuthorizationManager.shareInstanst.authorizeToMicrophone { (isAuto) in
                if isAuto {  // 已授权麦克风
//                    self.muteButton.isSelected = self.svcManager.mineConfInfo?.is_mute ?? !SessionManager.shared.isMicrophoneOpen
                    self.muteButton.isSelected = !SessionManager.shared.isMicrophoneOpen
                    self.refreshMuteImage(isMute: self.muteButton.isSelected)
                    SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
                }
            }
        }
        // 入会后第一次更新摄像头麦克风状态
        if self.isUpdataCameraMicrophoneState == false && self.svcManager.mineConfInfo != nil {
            CLLog("svc meeting isUpdataCameraMicrophoneState \(self.callManager.isSMC3()) \(SessionManager.shared.isSelfPlayCurrentMeeting)")
            // 入会第一次申请主持人
            // smc2.0自己发起会议申请主席 条件：（自己发起，会议中就自己，2.0环境，不是加入的）
            if !self.callManager.isSMC3(), SessionManager.shared.isSelfPlayCurrentMeeting,
               !(self.svcManager.currentMeetInfo?.hasChairman ?? false), let meetInfo = svcManager.currentMeetInfo, !meetInfo.isVmrConf {
                CLLog("svc meeting smc 2.0 Automatically Chairperson")
                self.isAutomaticallyChairperson = true // 自动申请主持人
                let _ = self.callManager.requestChairman(password: SessionManager.shared.chairPassword ?? "", number: self.svcManager.mineConfInfo?.participant_id ?? "")
                SessionManager.shared.chairPassword = ""
            }
            // smc3.0自己发起的会议申请主席  条件：(自己的会议，与会者中有自己，3.0环境，有会议信息，第一次入会，会议中没有主席)
            if self.callManager.isSMC3(),let meetInfo = svcManager.currentMeetInfo, !(self.svcManager.currentMeetInfo?.hasChairman ?? false) , meetInfo.scheduleUserAccount == self.callManager.ldapContactInfo()?.userName {
                CLLog("svc meeting smc 3.0 Automatically Chairperson")
                self.isAutomaticallyChairperson = true // 自动申请主持人
                let _ = self.callManager.requestChairman(password: meetInfo.chairmanPwd ?? "", number: self.svcManager.mineConfInfo?.participant_id ?? "")
            }
            // 预约会议自动申请主席
            if UserDefaults.standard.value(forKey: "YUYUELEHUIYI") as? String == "1", !self.callManager.isSMC3(), !(self.svcManager.currentMeetInfo?.hasChairman ?? false), !SessionManager.shared.isSelfPlayCurrentMeeting {
                CLLog("svc meeting smc 2.0 Reservation Automatically Chairperson")
                self.isAutomaticallyChairperson = true // 自动申请主持人
                let _ = self.callManager.requestChairman(password: SessionManager.shared.chairPassword ?? "", number: self.svcManager.mineConfInfo?.participant_id ?? "")
                SessionManager.shared.isSelfPlayCurrentMeeting = false
                SessionManager.shared.chairPassword = ""
                UserDefaults.standard.setValue("", forKey: "YUYUELEHUIYI")
            }
            // 需要自动申请主席则不更新麦克风，不申请主席则更新
            self.setCameraOpenClose()
            // 没有自动申请主席，设置麦克风
            if !self.isAutomaticallyChairperson {
                self.setMicrophoneOpenClose()
            }
            self.isUpdataCameraMicrophoneState = true
            SessionManager.shared.isSelfPlayCurrentMeeting = false
        }
        // backView与会者处理
        self.videoStreamView?.updataByAttendeedChange()
        // 设置会议标题
        self.setMeetingDataTitle()
        // 设置底部按钮是否可以点击
        if self.svcManager.mineConfInfo == nil {
            CLLog("- svc meeting 当前会议中自己未入会 -")
            // 关闭本地麦克风
            self.callManager.muteMic(isSelected: true, callId: UInt32(svcManager.currentMeetInfo?.callId ?? 0))
            // 所有按钮不可点击
            self.bottomBtnisEnabled(isEnabled: false)
        }else{
            CLLog("- svc meeting 当前会议中自己已入会 -")
            self.bottomBtnisEnabled(isEnabled: true)
        }
    }
    
    // 设置会议标题
    func setMeetingDataTitle() {
        guard let currentMeet = callManager.currentConfBaseInfo() else {
            CLLog("svc meeting meeting Info 为 nil")
            return
        }
        // 用户名称
        let addCount = svcManager.mineConfInfo == nil ? 0 : 1
        if let confSubject = currentMeet.confSubject {
            CLLog("svc meeting meeting confSubject: \(confSubject)")
            self.showUserNameLabel.text = confSubject
            self.attendCount.text = "(\(svcManager.attendeeArray.count+svcManager.voiceAttendeeArray.count+addCount))"
        }else{
            CLLog("svc meeting meeting confSubject 为 nil")
        }
        let meetID:String = ((SessionManager.shared.isMeetingVMR && SessionManager.shared.cloudMeetInfo.accessNumber != nil) ? (SessionManager.shared.cloudMeetInfo.accessNumber ?? "") : (currentMeet.accessNumber ?? ""))
        self.showUserIDLabel.text = "ID:" + meetID.dealMeetingIdWithIDString()
        CLLog("svc meeting meeting ID: \(meetID))")
    }
    
    // 点击查看信号
    @objc func signalSelectShowSignaldetail(tapGesture:UITapGestureRecognizer) {
        guard let _ = svcManager.currentMeetInfo else {
            return
        }
        // 信号点击
        let alertSingalVC = AlertTableSingalViewController.init(nibName: AlertTableSingalViewController.vcID, bundle: nil)
        alertSingalVC.isSvc = true
        alertSingalVC.isAvc = false
        alertSingalVC.svcManager = svcManager
        alertSingalVC.isVideoNetCheck = true
        alertSingalVC.isHaveAuxiliaryData = self.isShare
        alertSingalVC.modalPresentationStyle = .overFullScreen
        alertSingalVC.modalTransitionStyle = .crossDissolve
        alertSingalVC.interfaceOrientationChange = self.displayShowRotation
        alertSingalVC.callId = UInt32(svcManager.currentMeetInfo?.callId ?? 0)
        self.alertSingalVC = alertSingalVC 
        self.present(alertSingalVC, animated: true, completion: nil)
    }
    
    // 点击查看会议信息
    @objc func titleSelectShowMeetDetail(tapGesture:UITapGestureRecognizer) {
        // 隐藏上下导航栏
        setControlNaviAndBottomMenuShow(isShow: false, isAnimated: true)
        // 会议详情
        let infoVC = MeetingInfoViewController()
        let infoModel = MeetingInfoModel()
        infoModel.type = .svcMeeting
        infoModel.isProtect = false
        let meetID:String = ((SessionManager.shared.isMeetingVMR && SessionManager.shared.cloudMeetInfo.accessNumber != nil) ? (SessionManager.shared.cloudMeetInfo.accessNumber ?? "") : (svcManager.currentMeetInfo?.accessNumber ?? ""))
        infoModel.meetingId = meetID // 会议ID
        infoModel.guestPassword = (svcManager.currentMeetInfo?.generalPwd ?? "") // 会议密码
        infoModel.isChairman = self.svcManager.mineConfInfo?.role == .CONF_ROLE_CHAIRMAN ? true : false // 自己是否是主席
        infoModel.chairmanPassword = ((SessionManager.shared.isMeetingVMR && SessionManager.shared.cloudMeetInfo.accessNumber != nil) ? SessionManager.shared.cloudMeetInfo.chairmanPwd : svcManager.currentMeetInfo?.chairmanPwd) ?? ""
        infoModel.name = svcManager.currentMeetInfo?.confSubject ?? "" // 会议主题
        CLLog("会议详情信息 -- 主题:\(infoModel.name)  开始时间:\(svcManager.currentMeetInfo?.startTime ?? "空")  结束时间:\(svcManager.currentMeetInfo?.endTime ?? "空")")
        // 跨天数
        let gapDay = NSDate.gapDayCount(withStartTime: svcManager.currentMeetInfo?.startTime, endTime: svcManager.currentMeetInfo?.endTime)
        let Time = NSString.getReadTime(withStartTime: self.svcManager.currentMeetInfo?.startTime ?? "", andEndTime: (""))
        let TimeArr:[String] = (Time?.components(separatedBy: "/"))!
        let dayArr:[String] = (TimeArr[2].components(separatedBy: " "))
        let dayStr = dayArr[1].components(separatedBy: "-")[0]
       // 会议时间
        if self.svcManager.currentMeetInfo?.endTime != nil && self.svcManager.currentMeetInfo?.endTime != ""  {
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
        infoVC.infoModel = infoModel
        infoVC.modalPresentationStyle = .overFullScreen
        infoVC.modalTransitionStyle = .crossDissolve
        infoVC.displayShowRotation = displayShowRotation
        infoVC.netLevel = self.netLevel
        self.present(infoVC, animated: true) {
        }
        self.meetInfoVC = infoVC
    }
    
    // 离开会议
    @IBAction func leaveBtnClick(_ sender: UIButton) {
        let popTitleVC = PopTitleNormalViewController.init(nibName: PopTitleNormalViewController.vcID, bundle: nil)
        popTitleVC.modalTransitionStyle = .crossDissolve
        popTitleVC.modalPresentationStyle = .overFullScreen
        popTitleVC.isAllowRote = true
        
        if svcManager.mineConfInfo != nil && svcManager.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
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
        if SessionManager.shared.isMeetingVMR && svcManager.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
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
        CLLog("svcManager.isMyShare \(svcManager.isMyShare)")
        self.isOpenVoiceBtn = true
        sender.isSelected = !sender.isSelected
        self.previousRouteType = false
        if sender.isSelected {
            self.showTopVoiceBtn.setImage(UIImage.init(named: "icon_speaker_default"), for: .normal)
            // 打开扬声器
            self.callManager.openSpeaker()
        } else {
            self.showTopVoiceBtn.setImage(UIImage.init(named: "session_video_headset"), for: .normal)
            // 关闭扬声器
            self.callManager.closeSpeaker()
        }
    }
    // 设置静音
    @IBAction func muteBtnClick(_ sender: UIButton) {
        CLLog("svcManager.isMyShare \(svcManager.isMyShare)")
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuto) in
            guard let self = self else { return }
            if isAuto {  // 已授权麦克风
                sender.isSelected = !sender.isSelected
                let result = self.callManager.confCtrlMuteAttendee(participantId: self.svcManager.mineConfInfo?.participant_id, isMute: self.muteButton.isSelected)
                CLLog("svc meeting 点击麦克风打开关闭 - \(String(result)) - \(self.muteButton.isSelected)")
                self.refreshMuteImage(isMute: sender.isSelected)
                SessionManager.shared.isMicrophoneOpen = !sender.isSelected
            }else {      // 未授权麦克风
                SessionManager.shared.isMicrophoneOpen = false
                self.requestMuteAlert()
            }
        }
    }
    // 打开关闭视频
    @IBAction func cammerBtnClick(_ sender: UIButton) {
        CLLog("svcManager.isMyShare \(svcManager.isMyShare)")
        if svcManager.isMyShare { return }
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone { [weak self] (isAuto) in
            guard let self = self else { return }
            if isAuto { // 已授权摄像头
                sender.isSelected = !sender.isSelected
                let result = self.callManager.switchCameraOpen(!self.cammerButton.isSelected, callId: UInt32(self.svcManager.currentMeetInfo?.callId ?? 0))
                CLLog("svc meeting 点击摄像头打开关闭 - \(result ? "true" : "false") - Call:\(UInt32(self.svcManager.currentMeetInfo?.callId ?? 0))")
                self.refreshVideoImage(isCameraOpen: !sender.isSelected)
                if !sender.isSelected && !self.showRightBottomSmallIV.isHidden {
                    self.callManager.updateVideoWindow(localView: self.locationVideoView, callId: SVCMeetingBackView.id)
                }
                SessionManager.shared.isCameraOpen = !sender.isSelected
                self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue) // 设置摄像头方向
            }else{      // 未授权摄像头
                SessionManager.shared.isCameraOpen = false
                self.requestCameraAlert()
            }
        }
    }
    // 共享
    @IBAction func shareBtnClick(_ sender: UIButton) {
        CLLog("svcManager.isMyShare \(svcManager.isMyShare)")
        if isShareBtnDisable {return}
        if svcManager.isMyShare {
            passiveStopShareScreen()
            return
        }
        isShareBtnDisable = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            self.isShareBtnDisable = false
        }
        // 共享
        if auxRecvinng {
            alertAuthRequest("auxReq")
            return
        }
        showReplayKitUI()
    }
    // 与会者
    @IBAction func sitesBtnClick(_ sender: UIButton) {
        CLLog("svcManager.isMyShare \(svcManager.isMyShare)")
        if svcManager.isMyShare { return }
        UIDevice.switchNewOrientation(.portrait)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            // 与会者
            let storyboard = UIStoryboard.init(name: "JoinUsersSVCViewController", bundle: nil)
            let joinUsersViewVC = storyboard.instantiateViewController(withIdentifier: "JoinUsersSVCViewController") as! JoinUsersSVCViewController
            joinUsersViewVC.svcManager = self.svcManager
            joinUsersViewVC.modalPresentationStyle = .custom
            joinUsersViewVC.meettingInfo = self.svcManager.currentMeetInfo
            joinUsersViewVC.watchConfInfo = self.svcManager.watchConfInfo
            joinUsersViewVC.navigationController?.navigationBar.shadowImage = UIImage.init()
            APP_DELEGATE.rotateDirection = .portrait
            self.navigationController?.pushViewController(joinUsersViewVC, animated: true)
        }
    }
    // 更多
    
    @IBAction func moreBtnClick(_ sender: UIButton) {
        CLLog("svcManager.isMyShare \(svcManager.isMyShare)")
        if svcManager.isMyShare { return }
        // 点击更多后隐藏底部会控隐藏延长5秒
        bottomViewShowSeconds = 0
        // 显示更多
        setMenuViewBtnsInfo()
        self.menuView!.show()
    }
    
    
    override func noStreamAlertAction() {
        CLLog("noStreamAlertAction")
        endMeetingDismissVC()
        SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func showReplayKitUI() {
        for screenBtn in broadcastPickerView.subviews {
            if screenBtn is UIButton {
                (screenBtn as! UIButton).sendActions(for: .allTouchEvents)
            }
        }
    }
    
    public func removeAll() {
        self.isOpenVoiceBtn = false
        CLLog("SVCMeetingViewController - deinit")
        // 移除所有与会者
        NotificationCenter.default.removeObserver(self)
        // 关闭设备监听
        DeviceMotionManager.sharedInstance()?.stop()
        // 结束铃声
        SessionHelper.stopMediaPlay()
        self.passiveStopShareScreen()
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    deinit {
        self.isOpenVoiceBtn = false
        CLLog("SVCMeetingViewController - deinit")
        // 移除所有与会者
        NotificationCenter.default.removeObserver(self)
        // 关闭设备监听
        DeviceMotionManager.sharedInstance()?.stop()
        // 结束铃声
        SessionHelper.stopMediaPlay()
        self.passiveStopShareScreen()
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}


// MARK: 屏幕旋转UI更新
extension SVCMeetingViewController {
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        CLLog("屏幕旋转 - \(toInterfaceOrientation)")
        if toInterfaceOrientation == .portraitUpsideDown {
            self.displayShowRotation = .portrait
            UIDevice.switchNewOrientation(.portrait)
            return
        }
        videoStreamView?.layoutIfNeeded() // 刷新CollectionView
        alertSingalVC?.interfaceOrientationChange = toInterfaceOrientation
        showRightBottomSmallIV.interfaceOrientationChange = toInterfaceOrientation
        numberKeyboardVc?.interfaceOrientationChangeValue = toInterfaceOrientation
        meetInfoVC?.displayShowRotation = toInterfaceOrientation
        
        // 旋转屏幕后设置导航栏高度
        self.setControlNaviAndBottomMenuShow(isShow: false, isAnimated: true)
        // 选转屏幕隐藏menu
        self.menuView?.dismiss()
        // 小画面
        let bottomHeight:CGFloat = isiPhoneXMore() ? 75.0 : 60.0
        var rightRect:CGRect = self.showRightBottomSmallIV.frame
        rightRect.size.height = (toInterfaceOrientation == UIInterfaceOrientation.portrait || toInterfaceOrientation == UIInterfaceOrientation.portraitUpsideDown) ? 146 : 84
        rightRect.size.width = (toInterfaceOrientation == UIInterfaceOrientation.portrait || toInterfaceOrientation == UIInterfaceOrientation.portraitUpsideDown) ? 84 : 146
        rightRect.origin.x = (toInterfaceOrientation == UIInterfaceOrientation.portrait || toInterfaceOrientation == UIInterfaceOrientation.portraitUpsideDown) ? (SCREEN_WIDTH - rightRect.size.width - 10) : (SCREEN_HEIGHT - rightRect.size.width - 10)
        rightRect.origin.y = (toInterfaceOrientation == UIInterfaceOrientation.portrait || toInterfaceOrientation == UIInterfaceOrientation.portraitUpsideDown) ? (SCREEN_HEIGHT - rightRect.size.height - bottomHeight) : (SCREEN_WIDTH - rightRect.size.height - bottomHeight)
        
        self.showRightBottomSmallIV.frame = rightRect
        CLLog("showRightBottomSmallIVFrame \(self.showRightBottomSmallIV.frame)")
        // 设置摄像头方向  Swift和OC左右方向取反了
        self.displayShowRotation = toInterfaceOrientation
        if toInterfaceOrientation == .landscapeLeft {
            self.displayShowRotation = .landscapeRight
        }else if toInterfaceOrientation == .landscapeRight {
            self.displayShowRotation = .landscapeLeft
        }
        self.setCameraDirectionWithRotation()
    }
}

// MARK: 与会者列表 - JoinUsersViewDelegate
extension SVCMeetingViewController: JoinUsersViewDelegate {
    // 切换摄像头
    func joinUsersViewSwitchCamera(viewVC: JoinUsersViewController) {
        
    }
}

// MARK:  延长会议弹框代理 - ViewOnlyMinuteDelegate
extension SVCMeetingViewController: ViewOnlyMinuteDelegate {
    func viewOnlyMinuteSureBtnClick(viewVC: ViewMinutesViewController, seconds: Int){
        // 设置延长会议
        let isSuccess = callManager.confService()?.postponeConferenceTime(String(seconds/60))
        self.delayTimeStr = String(seconds/60)
        if !isSuccess! {
            MBProgressHUD.showBottom(tr("延长会议失败"), icon: nil, view: nil)
            self.delayTimeStr = ""
            return
        }
    }
}


// MARK: 会议密码弹框 - AlertSingleTextFieldViewDelegate,UITextFieldDelegate
extension SVCMeetingViewController: AlertSingleTextFieldViewDelegate,UITextFieldDelegate {
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
        
    }
    
    // right btn click
    func alertSingleTextFieldViewRightBtnClick(viewVC: AlertSingleTextFieldViewController, sender: UIButton) {
        viewVC.dismiss(animated: true, completion: nil)
        let _ = callManager.requestChairman(password: (viewVC.showInputTextField.text?.count == 0 ? "" : viewVC.showInputTextField.text) ?? "", number: svcManager.mineConfInfo?.participant_id)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        return nowString.count <= 6
    }
}

// MARK: Menu弹框
extension SVCMeetingViewController {
    func setMenuViewBtnsInfo() {
        var actionArray: [YCMenuAction] = []
        // 小画面显示隐藏
        var littleViewTitle = ""

        //TODO: fix_now 本端发送辅流时强制屏蔽menu点击响应
        if svcManager.isMyShare {
            self.showRightBottomSmallIV.isHidden = true
            return
        }
        if svcManager.isAuxiliary { // 共享中
            if self.videoStreamView?.scrollCurrentPage == 1, svcManager.mineConfInfo != nil, svcManager.attendeeArray.count != 0 {
                littleViewTitle =  self.showRightBottomSmallIV.isHidden ? tr("显示小画面") :tr("隐藏小画面")
            }
        }else {
            if self.videoStreamView?.scrollCurrentPage == 0, svcManager.mineConfInfo != nil, svcManager.attendeeArray.count != 0  {
                littleViewTitle = self.showRightBottomSmallIV.isHidden ? tr("显示小画面") :tr("隐藏小画面")
            }
        }
        
        // 会议
        if svcManager.mineConfInfo != nil && svcManager.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN { // 主持人
            // 切换摄像头 共享情况下在共享情况下在共享页不支持切换摄像头
            if auxRecvinng, self.videoStreamView?.scrollCurrentPage == 0 {} else {
                CLLog("辅流接收停止，更新本地menu显示")
                actionArray.append(YCMenuAction.init(title: tr("切换摄像头"), titleColor: !SessionManager.shared.isCameraOpen ? UIColor.init(hexString: "#999999") : nil, image: nil) { [weak self] (sender) in
                    guard let self = self else { return }
                    self.switchCamera(cameraIndex: nil)
                })
            }
            // 画廊模式和辅流界面更多中不需要显示小画面
            if littleViewTitle != "" {
                actionArray.append(YCMenuAction.init(title: littleViewTitle, image: nil) { [weak self] (sender) in
                    guard let self = self else { return }
                    self.isHiddenSmallVideoView() ? self.showSmallVideoView() : self.hideSmallVideoView()
                    // 小画面隐藏则设置为Yes 页面在滑动中不主动显示出来
                    self.videoStreamView?.userChooseSmallViewIsHidden = self.isHiddenSmallVideoView()
                })
            }
            // 添加释放主持人按钮
            actionArray.append(YCMenuAction(title: tr("释放主持人"), image: nil, handler: { [weak self] (sender) in
                guard let self = self else { return }
                self.releaseChairmanWithAlert(num: self.svcManager.mineConfInfo?.participant_id)
            }))
            // 延长会议
            actionArray.append(YCMenuAction.init(title: tr("延长会议"), image: nil) { [weak self] (sender) in
                guard let self = self else { return }
                // 如果是持续会议则提示不能延长会议
                if self.svcManager.currentMeetInfo?.endTime == nil || self.svcManager.currentMeetInfo?.endTime == "" {
                    MBProgressHUD.showBottom(tr("当前是永久会议，不能延长"), icon: nil, view: self.view)
                    return
                }
                // 设置会议时长
                let hourMinutePickerVC = ViewMinutesViewController.init(nibName: ViewMinutesViewController.vcID, bundle: nil)
                hourMinutePickerVC.modalPresentationStyle = .overFullScreen
                hourMinutePickerVC.modalTransitionStyle = .crossDissolve
                hourMinutePickerVC.customDelegate = self
                hourMinutePickerVC.title = tr("请选择延长时间")
                self.hourMinutePickerVC = hourMinutePickerVC
                self.present(hourMinutePickerVC, animated: true, completion: nil)
            })
            // 邀请与会者
            actionArray.append(YCMenuAction.init(title: tr("邀请"), image: nil, handler: { [weak self] (sender) in
                guard let self = self else {return}
                let storyboard = UIStoryboard.init(name: "SearchAttendeeViewController", bundle: nil)
                let searchAttendee = storyboard.instantiateViewController(withIdentifier: "SearchAttendeeView") as! SearchAttendeeViewController
                searchAttendee.meetingCofArr = self.callManager.haveJoinAttendeeArray()
                self.navigationController?.pushViewController(searchAttendee, animated: true)
            }))
        } else {
            // 举手功能
            actionArray.append(YCMenuAction.init(title: (svcManager.mineConfInfo?.hand_state ?? false) ? tr("手放下") : tr("举手"), titleColor: !(self.svcManager.currentMeetInfo?.hasChairman ?? false) ? UIColor.init(hexString: "#999999") : UIColor.white, image: nil, handler: { [weak self] (sender) in
                guard let self = self else { return }
                // 无主持人条件下不能举手
                if !(self.svcManager.currentMeetInfo?.hasChairman ?? false) {
                    return
                }
                // 点击举手设置为true
                self.svcManager.isClickCancleRaise = true
                let isSuccess = self.callManager.raiseHand(handState: !(self.svcManager.mineConfInfo!.hand_state), number: self.svcManager.mineConfInfo!.number)
                CLLog("举手 手放下是否成功：\(isSuccess)")
                if !isSuccess {
                    self.svcManager.isClickCancleRaise = false
                }
            }))
            
            // 添加申请主持人按钮
            actionArray.append(YCMenuAction(title: tr("申请主持人"), titleColor: (self.svcManager.currentMeetInfo?.hasChairman ?? false) ? UIColor.init(hexString: "#999999") : UIColor.white, image: nil, handler: { [weak self] (sender) in
                guard let self = self else { return }
                if (self.svcManager.currentMeetInfo?.hasChairman ?? false) {
                    return
                }
                if self.isPWBullet == false {
                    var passWord: String = ""
                    // SMC3.0
                    if self.callManager.isSMC3(),self.svcManager.currentMeetInfo?.scheduleUserAccount == self.callManager.ldapContactInfo()?.userName,let vmrId = (UserDefaults.standard.value(forKey: VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY) == nil) ? "" : UserDefaults.standard.value(forKey: VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY),vmrId as? String == (self.svcManager.currentMeetInfo?.accessNumber ?? "") {
                        passWord = self.svcManager.currentMeetInfo?.chairmanPwd ?? ""
                        CLLog("vrm meeting vmrId:\(vmrId) password:\(self.svcManager.currentMeetInfo?.accessNumber ?? "")")
                    }
                    // SMC2.0
                    if !self.callManager.isSMC3(),SessionManager.shared.isMeetingVMR, SessionManager.shared.cloudMeetInfo.accessNumber == ManagerService.confService()?.vmrBaseInfo.accessNumber {
                        passWord = SessionManager.shared.cloudMeetInfo.chairmanPwd
                    }
                    let reslut = self.callManager.requestChairman(password: passWord, number: self.svcManager.mineConfInfo?.participant_id)
                    if !reslut {
                        MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: self.view)
                    }
                    return
                }
                // 弹出输入密码弹框
                let alertVC = AlertSingleTextFieldViewController.init(nibName: AlertSingleTextFieldViewController.vcID, bundle: nil)
                alertVC.modalTransitionStyle = .crossDissolve
                alertVC.modalPresentationStyle = .overFullScreen
                alertVC.customDelegate = self
                self.present(alertVC, animated: true) {
                    alertVC.showInputTextField.keyboardType = .numberPad
                    self.isPWBullet = true
                }
            }))
            // 共享界面隐藏切换摄像头
            if auxRecvinng, self.videoStreamView?.scrollCurrentPage == 0 {} else {
                actionArray.append(YCMenuAction.init(title: tr("切换摄像头"), titleColor: !SessionManager.shared.isCameraOpen ? UIColor.init(hexString: "#999999") : nil, image: nil, handler: { [weak self] (sender) in
                    guard let self = self else { return }
                    self.switchCamera(cameraIndex: nil)
                }))
            }
            // 画廊模式和辅流界面更多中不需要显示小画面
            if littleViewTitle != "" {
                actionArray.append(YCMenuAction.init(title: littleViewTitle, image: nil) { [weak self] (sender) in
                    guard let self = self else { return }
                    self.isHiddenSmallVideoView() ? self.showSmallVideoView() : self.hideSmallVideoView()
                    // 小画面隐藏则设置为Yes 页面在滑动中不主动显示出来
                    self.videoStreamView?.userChooseSmallViewIsHidden = self.isHiddenSmallVideoView()
                })
            }
        }
        let menu = YCMenuView.menu(with: actionArray, width: 170.0, relyonView: self.moreButton)
        menu?.backgroundColor = COLOR_DARK_GAY
        menu?.textAlignment = .center
        menu?.separatorColor = COLOR_GAY
        menu?.isShadowShowing = false
        menu?.maxDisplayCount = 20
        menu?.offset = 10
        menu?.textColor = UIColor.white
        menu?.textFont = UIFont.systemFont(ofSize: 16.0)
        menu?.menuCellHeight = 50.0
        menu?.dismissOnselected = true
        menu?.dismissOnTouchOutside = true
        self.menuView = menu
    }
}

// MARK: 会控处理
extension SVCMeetingViewController:UIGestureRecognizerDelegate {
    
    // 设置导航栏和底部菜单栏是否显示
    func setControlNaviAndBottomMenuShow(isShow: Bool, isAnimated: Bool) {
                
        self.isShowFuncBtns = isShow;
        // 显示时间设为0
        self.bottomViewShowSeconds = 0
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: isAnimated ? 0.25 : 0) {
            if isShow {
                let currentStatusBarHeight =  UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height
                // 显示
                self.showRecordTimeTopConstraint.constant = 16
                self.soundLeftConstraint.constant = 16.0
                self.bottomMenuBottomConstraint.constant = 0.0
                self.pageControlBottomConstraint.constant = 20
                if UI_IS_BANG_SCREEN {
                    // 刘海屏
                    self.navTopConstraint.constant = -(currentStatusBarHeight ?? 0)
                    self.navHeightConstraint.constant = (UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height) ? 60 : 95
                    self.bottomMenuHeightConstraint.constant = 75
                } else {
                    // 普通屏
                    self.navTopConstraint.constant = -(currentStatusBarHeight ?? 0)
                    self.navHeightConstraint.constant = (UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height) ? 60 : 70
                    self.bottomMenuHeightConstraint.constant = 60
                }
                
                if (UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height) { // 竖屏
                    if (self.showRightBottomSmallIV.frame.origin.y+self.showRightBottomSmallIV.frame.size.height) > SCREEN_HEIGHT-self.bottomView.frame.size.height {
                        var rightRect:CGRect = self.showRightBottomSmallIV.frame
                        rightRect.origin.y = self.bottomView.frame.origin.y-self.bottomView.frame.size.height-rightRect.size.height-10
                        self.showRightBottomSmallIV.frame = rightRect
                    }
                }else{
                    if (self.showRightBottomSmallIV.frame.origin.y+self.showRightBottomSmallIV.frame.size.height) > SCREEN_WIDTH-self.bottomView.frame.size.height {
                        var rightRect:CGRect = self.showRightBottomSmallIV.frame
                        rightRect.origin.y = self.bottomView.frame.origin.y-self.bottomView.frame.size.height-rightRect.size.height-10
                        self.showRightBottomSmallIV.frame = rightRect
                    }
                }
                // 发送Cell内的名字偏移量
                if (UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height) {
                    NotificationCenter.default.post(name: NSNotification.Name.init(SVCParticipantNameOffset), object:  isiPhoneXMore() ? self.bottomMenuHeightConstraint.constant-34 : self.bottomMenuHeightConstraint.constant)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name.init(SVCParticipantNameOffset), object:  self.bottomMenuHeightConstraint.constant)
                }
                
            } else {
                if UI_IS_BANG_SCREEN {
                    // 刘海屏
                    self.navHeightConstraint.constant = (UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height) ? 60 : 95
                    self.showRecordTimeTopConstraint.constant = NAVIGATION_BAR_HEIGHT
                    self.navTopConstraint.constant = -NAVIGATION_BAR_HEIGHT - self.navHeightConstraint.constant
                    self.bottomMenuHeightConstraint.constant = 75
                    self.pageControlBottomConstraint.constant = 10
                } else {
                    // 普通屏
                    self.navHeightConstraint.constant = (UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height) ? 60 : 70
                    self.navTopConstraint.constant = -STATUS_BAR_HEIGHT - self.navHeightConstraint.constant
                    self.bottomMenuHeightConstraint.constant = 60
                    self.pageControlBottomConstraint.constant = 20
                }
                // 隐藏
                self.soundLeftConstraint.constant = -100.0
                self.bottomMenuBottomConstraint.constant = -self.bottomMenuHeightConstraint.constant
                // 隐藏menu
                self.menuView?.dismiss()
                // 发送Cell内的名字偏移量
                NotificationCenter.default.post(name: NSNotification.Name.init(SVCParticipantNameOffset), object:  0)
            }
            self.view.layoutIfNeeded()
        } completion: { (isFinish) in
        }
    }
}

// MARK: 加载监听通知
extension SVCMeetingViewController {
    
    func installNotification() {
        //是否真正进会
        NotificationCenter.default.addObserver(self, selector: #selector(notficationRealJoinMeeting(notification:)), name: NSNotification.Name.init(CALL_S_CONF_BASEINFO_UPDATE_KEY), object: nil)
        // 呼出事件
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallOutgoing(notification:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_CALL_OUTGOING), object: nil)
        // 离开或结束会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: nil)
        // 进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAppInactiveNotify(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
       // 进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAppActiveNotify(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        // 与会者列表更新
        NotificationCenter.default.addObserver(self, selector:  #selector(notificationAttendeeUpdate(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE), object: nil)
        // 延长会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationExtensionConfLen(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_E_CONF_POSTPONE_CONF), object: nil)
        
        // 开始共享辅流decode_sucess
        NotificationCenter.default.addObserver(self, selector: #selector(notificationStartShareData), name: NSNotification.Name(CALL_S_CONF_CALL_EVT_DATA_START), object: nil)
        
        // 加入共享辅流回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationShareData), name: NSNotification.Name(CALL_S_CALL_EVT_DECODE_SUCCESS), object: nil)
        
        // 开始共享辅流回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationStartShareData(notification:)), name: NSNotification.Name(rawValue: CALL_S_CONF_CALL_EVT_DATA_START), object: nil)
        // 辅流共享失败
        NotificationCenter.default.addObserver(self, selector: #selector(notficationStartFailure(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_AUX_SHARE_FAILED), object: nil)
        // 共享绑定
        NotificationCenter.default.addObserver(self, selector: #selector(notificationappShareAttach(notification:)), name: NSNotification.Name.init(rawValue: DATA_CONF_AUX_STREAM_BIND_NOTIFY), object: nil)
        // 停止接收辅流（停止共享）
        NotificationCenter.default.addObserver(self, selector: #selector(notificationStopShareData(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_AUX_DATA_STOPPED), object: nil)
        
        // 申请释放主持人
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRequestChairman(notification:)), name: NSNotification.Name(CALL_S_CONF_REQUEST_CHAIRMAN), object: nil)
        // 释放主持人通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReleaseChairman(notification:)), name: NSNotification.Name(CALL_S_CONF_RELEASE_CHAIRMAN), object: nil)
        // 与会者举手
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSetHandup(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_SET_HANDUP), object: nil)
        // 取消举手
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSetCanclehandup(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_CANCLE_HANDUP), object: nil)
        // 当前屏幕方向监听
        NotificationCenter.default.addObserver(self, selector: #selector(deviceCurrentMotionOrientationChanged), name: NSNotification.Name.init(rawValue: ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
        // 与会者页面改变摄像头
        NotificationCenter.default.addObserver(self, selector: #selector(mineCameraStateChange(notfication:)), name: NSNotification.Name.init(MineCameraStateChange), object: nil)
        // 与会者页面改变摄像头状态
        NotificationCenter.default.addObserver(self, selector: #selector(mineMicrophoneStateChange(notfication:)), name: NSNotification.Name.init(MineMicrophoneStateChange), object: nil)
        // 大会模式
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSvcWatchPolicy(notfication:)), name: NSNotification.Name.init("MeetingEnterPolicy"), object: nil)
        // 设备管理TSDK回调，对应 ID：2014 接口
        NotificationCenter.default.addObserver(self, selector: #selector(notificationListenListenChange(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_CALL_ROUTE_CHANGE), object: nil)
        // 会议详情视频质量点击通知
        NotificationCenter.default.addObserver(self, selector: #selector(notficationLookAudioClick(notfication:)), name: NSNotification.Name.init(LookAudioAndVideoQualityNotifiName), object: nil)
        // 小窗口点击放大刷新页面通知
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSmallWindowZoom(notfication:)), name: NSNotification.Name.init(SVCSmallWindowZoomChange), object: nil)
        // 会议签到回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(notficationConferenceSignIn(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_CHECKIN_RESULT), object: nil)
        // 邀请与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdateSelectedAttendee(notfication:)), name: NSNotification.Name(UpdataInvitationAttendee), object: nil)
        // 与会者举手提示
        NotificationCenter.default.addObserver(self, selector: #selector(notficationHandUpAttendee(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_HAND_UP_IND), object: nil)
        // 视频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationVideoQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_VIDEO_NET_QUALITY), object: nil)
        // 音频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationAudioQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_AUDIO_NET_QUALITY), object: nil)
        // 会话修改完成通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallModify(notfication:)), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_MODIFY), object: nil)
        // 上报设备状态
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallDeviceState(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_DEVICE_STATE), object: nil)
        // 广播和取消广播与会者通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallBoardcastInd(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_BROADCAST_IND), object: nil)
        // 动态带宽策略通知
        NotificationCenter.default.addObserver(self, selector: #selector(notficationBindWidthChange(notfication:)), name: NSNotification.Name(CALL_S_CALL_EVT_BAND_WIDTH_CHANGE), object: nil)
        // 辅流扩展进程更新日志收集入口
        self.registerExtensionRecordLogsUpdate()
        
    }
}

// MARK: 通知方法回调
extension SVCMeetingViewController {
    
    // 判断是否真正进入会议
    @objc func notficationRealJoinMeeting(notification:Notification) {
        // 当前会议信息
        svcManager.currentMeetInfo = callManager.currentConfBaseInfo()
        // 当前接听的call对象信息
        svcManager.currentCallInfo = callManager.currentCallInfo()
        // 真正入会 设置会议标题
        self.setMeetingDataTitle()
    }

    // 离开或结束会议
    @objc func notificationQuitToListViewCtrl(notification: Notification) {
        self.endMeetingDismissVC()
        SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
        NotificationCenter.default.removeObserver(self)
        let object = notification.object as? String
        if object != nil {
            CLLog("Leave or end the meeting")
            Toast.showBottomMessage(tr("会议已结束"))
        }
        self.passiveStopShareScreen()
    }
    // 呼出事件
    @objc func notificationCallOutgoing(notification: Notification) {
        if let result = notification.userInfo {
            svcManager.currentCallInfo = result[TSDK_CALL_INFO_KEY] as? CallInfo
        }
    }
    
    // 进入后台
    @objc func notificationAppInactiveNotify(notification: Notification) {
        if svcManager.currentCallInfo == nil {
            return
        }
        let result = callManager.switchCameraOpen(false, callId: svcManager.currentCallInfo?.stateInfo.callId ?? 0)
        if result {
            refreshVideoImage(isCameraOpen: false)
        }
        CLLog("进入后台设置摄像头 - \(result ? "true" : "false")")
        DeviceMotionManager.sharedInstance()?.stop()
        self.resetScreenShareStatus()
        // 返回后台将滑动到大画面
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.videoStreamView?.collectionForPageView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.videoStreamView?.scrollCurrentPage = 0
            self.videoStreamView?.pageControl?.currentPage = self.videoStreamView?.currentPageControlShowIndex(currentScrolPage: 0) ?? 0
        }
    }
    // 进入前台
    @objc func notificationAppActiveNotify(notification: Notification) {
        if svcManager.currentCallInfo == nil {
            return
        }
        
        self.videoStreamView?.isShowBigLoadingImage = false
        DeviceMotionManager.sharedInstance()?.start()
        self.setCameraDirectionWithRotation()
        resetCameraStatus()
        if auxRecvinng {
            self.updateScreenShareStatus(updateNow: auxRecvinng)
        }
        if svcManager.isMyShare {
            let result = callManager.switchCameraOpen(false, callId: SVCMeetingBackView.id)
            if result {
                refreshVideoImage(isCameraOpen: false)
            }
            CLLog("我正在共享 - 进入前台设置摄像头 - \(result ? "true" : "false")")
        }
        
    }
    // 与会者列表更新回调通知
    @objc func notificationAttendeeUpdate(notification: Notification) {
        CLLog("Participant list update callback notification")
        // 当前会议信息
        svcManager.currentMeetInfo = callManager.currentConfBaseInfo()
        // 当前接听的call对象信息
        svcManager.currentCallInfo = callManager.currentCallInfo()
        // 与会者数据处理
        self.setInitData()
    }
    // 延长会议回调通知
    @objc func notificationExtensionConfLen(notification: Notification) {
        guard let userInfoCode = notification.userInfo?[ECCONF_RESULT_KEY] as? Int  else {
            MBProgressHUD.showBottom(tr("延长会议失败"), icon: nil, view: self.view)
            return
        }
        if self.delayTimeStr.count > 0 && userInfoCode == 1 {
            MBProgressHUD.showBottom(tr("会议已延长")+" "+self.delayTimeStr+" "+tr("分钟"), icon: nil, view: self.view)
        } else {
            MBProgressHUD.showBottom(tr("延长会议失败"), icon: nil, view: self.view)
        }
    }
    // 加入共享辅流回调通知
    @objc func notificationShareData(notification: Notification) {
        CLLog("辅流MSGID DECODE_SUCCESS>> 1,收到辅流>")
//        self.updateScreenShareStatus(updateNow: false)
        if !UserDefaults.standard.bool(forKey: "aux_rec") {return}
        // 如果自己有共享。被抢共享后需要停止本地共享
        self.passiveStopShareScreen()
        self.isShare = true
        self.svcManager.isMyShare = false
        self.auxRecvinng = true
        self.svcManager.isAuxiliary = true
        // 接收到辅流数据
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AUX_RECCVING_SHARE_DATA), object: nil)
        // 更新辅流数据
        self.shareBackView.dismissCurrentView()
        self.updateScreenShareStatus(updateNow: true)
        
        CLLog("辅流MSGID DECODE_SUCCESS>> 2,收到辅流>")
        
    }
    // 开始共享辅流回调myshare SUCCESS
    @objc func notificationStartShareData(notification: Notification) {
        self.shareBackViewConfig()
        self.auxStartSending()
        CLLog("辅流MSGID 本端发送成功，开启直播")
    }
    // 共享绑定回调通知
    @objc func notificationappShareAttach(notification: Notification) {
        callManager.confService()?.appShareAttach(EAGLViewAvcManager.shared.viewForBFCP)
    }
    // 辅流发送失败
    @objc func notficationStartFailure(notfication: Notification) {
        CLLog("辅流发送失败回调")
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
        svcManager.isAuxiliary = false
        self.isShare = false
        self.auxRecvinng = false
        svcManager.isMyShare = false
        if reasoncode == 6 {
            self.auxRecvinng = true
        }
        SessionManager.shared.bfcpStatus = auxRecvinng ?(.remoteRecvBFCP): (.noBFCP)
        // 如果自己有共享。被抢共享后需要停止本地共享
        self.passiveStopShareScreen()
        // 提示
        MBProgressHUD.showBottom(tr("申请共享权限失败"), icon: nil, view: nil)
        self.shareBackView.dismissCurrentView()
        resetCameraStatus()
        if auxRecvinng {
            self.updateScreenShareStatus(updateNow: true)
        }
    }
    // 停止接收共享辅流回调通知
    @objc func notificationStopShareData(notification: Notification) {
        CLLog("停止辅流MSGID=2032(0) svcManager.isMyShare?(\(svcManager.isMyShare)),auxR?(\(auxRecvinng))")
        

        //通知小窗口辅流共享已经停止了
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AUX_RECCVING_STOP_SHARE), object: nil)
        self.shareBackView.dismissCurrentView()
        if !svcManager.isMyShare,auxRecvinng {
            // 更新辅流数据
            self.svcManager.isAuxiliary = false
            self.isShare = false
            self.auxRecvinng = false
            SessionManager.shared.bfcpStatus = .noBFCP
            UserDefaults.standard.setValue(false, forKey: "aux_rec")
            // 滑动到辅流页面
            self.updateScreenShareStatus(updateNow: false)
            resetCameraStatus()
            CLLog("辅流停止接收-MSGID = 2032(接收停止)")
            return
        }
         
//        if svcManager.isMyShare,auxRecvinng{
//            resetCameraStatus()
//            CLLog("辅流停止接收-MSGID = 2032(本端停止)")
//            return
//        }
        if svcManager.isMyShare,!auxRecvinng{
            svcManager.isAuxiliary = true
//            passiveStopShareScreen()
            resetCameraStatus()
            CLLog("辅流停止接收-MSGID = 2032(本端被抢)")
            return
        }

    }
    
    // 申请主持人回调
    @objc func notificationRequestChairman(notification: Notification) {
        CLLog("Application host")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            guard let resultCode = notification.userInfo?[ECCONF_RESULT_KEY] as? NSNumber  else {
                if self.svcManager.isShowCurrentVC() {
                    MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: self.view)
                }
                // 自动申请主持人失败
                if self.isAutomaticallyChairperson {
                    self.setMicrophoneOpenClose()
                    self.isAutomaticallyChairperson = false
                }
                return
            }
            
            if resultCode == 1 {
                CLLog("CONF_E_REQUEST_CHAIRMAN_RESULT - 申请主持人成功")
                if self.svcManager.isShowCurrentVC() {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    MBProgressHUD.showBottom(tr("已申请主持人"), icon: nil, view: self.view)
                }
                // 设置麦克风状态
                HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuto) in
                    guard let self = self else { return }
                    if !isAuto {      // 未授权麦克风 关闭麦克风
                        self.isAutomaticallyChairperson = false
                        self.muteButton.isSelected = true
                        let result = self.callManager.confCtrlMuteAttendee(participantId: self.svcManager.mineConfInfo?.participant_id, isMute: self.muteButton.isSelected)
                        CLLog("申请主持人打开麦克风 - \(String(result))")
                        self.refreshMuteImage(isMute: self.muteButton.isSelected)
                        SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
                    }else {
                        if self.isAutomaticallyChairperson { // 自动申请主持人 授权麦克风权限 更新麦克风状态
                            self.muteButton.isSelected = !SessionManager.shared.isMicrophoneOpen
                            self.refreshMuteImage(isMute: self.muteButton.isSelected)
                            SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
                            self.isAutomaticallyChairperson = false
                        }
                    }
                }
            }else{
                CLLog("CONF_E_REQUEST_CHAIRMAN_RESULT - 申请主持人失败")
                // 自动申请主持人失败
                if self.isAutomaticallyChairperson {
                    self.setMicrophoneOpenClose()
                    self.isAutomaticallyChairperson = false
                    return
                }
                if self.svcManager.isShowCurrentVC() {
                    if self.isPWBullet == false {
                        let alertVC = AlertSingleTextFieldViewController.init(nibName: AlertSingleTextFieldViewController.vcID, bundle: nil)
                        alertVC.modalTransitionStyle = .crossDissolve
                        alertVC.modalPresentationStyle = .overFullScreen
                        alertVC.customDelegate = self
                        self.present(alertVC, animated: true) {
                            alertVC.showInputTextField.keyboardType = .numberPad
                            self.isPWBullet = true
                        }
                    }else if resultCode == 67109022 {
                        MBProgressHUD.showBottom(tr("会议已存在主持人，暂无法申请主持人"), icon: nil, view: self.view)
                    }else if resultCode == 67109023 {
                        MBProgressHUD.showBottom(tr("密码错误"), icon: nil, view: self.view)
                    }else{
                        MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: self.view)
                    }
                }
            }
        }
    }
    // 释放主持人回调
    @objc func notificationReleaseChairman(notification: Notification) {
        CLLog("Release the host")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if self.svcManager.isShowCurrentVC() {
                MBProgressHUD.hide(for: self.view, animated: true)
                guard let resultCode = notification.userInfo?[ECCONF_RESULT_KEY] as? NSNumber  else {
                    MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: nil)
                    return
                }
                if resultCode == 1 {
                    CLLog("CALL_S_CONF_RELEASE_CHAIRMAN - 释放主持人成功")
                    if self.svcManager.isPolicy { // 大会模式不选看
                        self.svcManager.watchConfInfo = nil
                    }
                    MBProgressHUD.showBottom(tr("主持人已释放"), icon: nil, view: self.view)
                    self.svcManager.chairmanConfInfo = nil // 主持人置为空
                }else{
                    CLLog("CALL_S_CONF_RELEASE_CHAIRMAN - 释放主持人失败")
                    MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: self.view)
                }
            }
        }
    }
    // 与会者举手
    @objc func notficationSetHandup(notfication:Notification) {
        CLLog("Participants raise their hands")
        if let resultDictionary = notfication.userInfo {
            MBProgressHUD.hide(for: self.view, animated: true)
            let result = resultDictionary[CALL_S_CONF_SET_HANDUP] as! NSNumber
            if result.boolValue {
                MBProgressHUD.showBottom(tr("举手成功"), icon: nil, view: self.view)
            } else {
                MBProgressHUD.showBottom(tr("举手失败"), icon: nil, view: self.view)
            }
        }
    }
    // 取消举手
    @objc func notficationSetCanclehandup(notfication:Notification) {
        CLLog("Participant cancels raise of hand")
        if let resultDictionary = notfication.userInfo {
            MBProgressHUD.hide(for: self.view, animated: true)
            if svcManager.isClickCancleRaise {
                let result = resultDictionary[ECCONF_RESULT_KEY] as! NSNumber
                if result.boolValue {
                    MBProgressHUD.showBottom(tr("取消举手成功"), icon: nil, view: self.view)
                } else {
                    MBProgressHUD.showBottom(tr("取消举手失败"), icon: nil, view: self.view)
                }
                //  又回调则置为空（蠢办法解决）
                svcManager.isClickCancleRaise = false
            }
        }
    }
    // 陀螺仪监听旋转
    @objc func deviceCurrentMotionOrientationChanged() {
        switch DeviceMotionManager.sharedInstance()?.lastOrientation.rawValue {
        case 1:
            self.displayShowRotation = .portrait
        case 2:
            self.displayShowRotation = .portrait
            UIDevice.switchNewOrientation(.portrait)
        case 3:
            self.displayShowRotation = .landscapeLeft
        case 4:
            self.displayShowRotation = .landscapeRight
        default:
            break
        }
        // 设置摄像头方向
        setCameraDirectionWithRotation()
    }
    // 与会者页面改变摄像头
    @objc func mineCameraStateChange(notfication:Notification) {
        CLLog("Change camera on participant page")
        self.cammerButton.isSelected = !SessionManager.shared.isCameraOpen
        self.refreshVideoImage(isCameraOpen: !self.cammerButton.isSelected)
    }
    // 与会者页面改变麦克风状态
    @objc func mineMicrophoneStateChange(notfication:Notification) {
        CLLog("Change microphone status on participant page")
        self.muteButton.isSelected = SessionManager.shared.isMicrophoneOpen
        self.refreshMuteImage(isMute: self.muteButton.isSelected)
    }
    // 大会模式 重新刷新页面
    @objc func notficationSvcWatchPolicy(notfication:Notification) {
        svcManager.isPolicy = SessionManager.shared.isPolicy
        // 自己不是主席请情况下选看置未空
        if svcManager.mineConfInfo != nil,svcManager.mineConfInfo?.role != CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
            svcManager.watchConfInfo = nil
        }
        if svcManager.mineConfInfo != nil && svcManager.attendeeArray.count != 0 && self.videoStreamView?.scrollCurrentPage != self.videoStreamView?.bigPageCurrentIndex() {
            self.videoStreamView?.collectionForPageView.scrollToItem(at: IndexPath.init(row: self.videoStreamView?.bigPageCurrentIndex() ?? 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.videoStreamView?.pageControl?.currentPage = self.videoStreamView?.bigPageCurrentIndex() ?? 0
            self.videoStreamView?.scrollCurrentPage = self.videoStreamView?.bigPageCurrentIndex() ?? 0
            CLLog("svc meet need refresh  ---------------------- 14")
            self.videoStreamView?.reloadDataWithRow(row: nil, isDeadline: 0.5)
        }
    }
    // 听筒模式扬声器模式切换
    @objc func notificationListenListenChange(notification:Notification){
        guard let noti = notification.userInfo as? [String:String] else {
            return
        }
        
        let routeType = noti[AUDIO_ROUTE_KEY]
        CLLog("svc >> notify >>routeType:\((routeType)!)")
        switch routeType {
        case "0":
            break
        case "1":
//            self.showTopVoiceBtn.isEnabled = true
            self.showTopVoiceBtn.isSelected = true
            self.refreshSpeakerImage(isSpeaker: true)
            //            self.showTopVoiceBtn.setImageName("sound", title: tr("扬声器"))
            //            self.enterLouderSpeakerModel()
            break
        case "2","4":
            self.enterHeadSetModel()
            break
        case "3":
            if self.previousRouteType == true {
                self.enterLouderSpeakerModel()
            }else{
                self.showTopVoiceBtn.isSelected = false
//                self.showTopVoiceBtn.isEnabled = true
                
                self.refreshSpeakerImage(isSpeaker: false)
                //                self.showTopVoiceBtn.setImageName( "headset", title:  "听筒")
                
            }
            break
            
        default:
            break
        }
        
    }
    // 会议详情视频质量点击通知
    @objc func notficationLookAudioClick(notfication:Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.signalSelectShowSignaldetail(tapGesture: UITapGestureRecognizer())
        }
    }
    // 小窗口点击放大刷新页面
    @objc func notficationSmallWindowZoom(notfication:Notification) {
        self.svcManager.isSmallWindow = false // 当前已经切换到回大画面模式
        // 处理小窗口广播后点击返回大画面黑屏问题
        if self.videoStreamView?.scrollCurrentPage != 0 {
            self.videoStreamView?.collectionForPageView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.videoStreamView?.scrollCurrentPage = 0
            self.videoStreamView?.pageControl?.currentPage = 0
        }
        if svcManager.attendeeArray.count == 0 {
            self.videoStreamView?.pageControl?.isHidden = true
        }
        CLLog("svc meet need refresh  ---------------------- 15")
        if !svcManager.isAuxiliary {
            self.videoStreamView?.smallWindowTobigPictureCell()
        }else{
            self.videoStreamView?.smallWindowToBfcpStreamCell()
        }
    }
    // 会议签到回调通知
    @objc func notficationConferenceSignIn(notfication:Notification) {
        if self.callManager.isSMC3() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                MBProgressHUD.showBottom(tr("会议签到成功"), icon: nil, view: self.view)
            }
        }
    }
    // 邀请选中与会者通知
    @objc func notificationUpdateSelectedAttendee(notfication: Notification) {
        // 添加与会者
        if SessionManager.shared.currentAttendeeArray.count > 0 {
            let atteedeeArray = NSArray.init(array: SessionManager.shared.currentAttendeeArray) as? [LdapContactInfo]
            for atteedee in atteedeeArray! {
                CLLog("邀请与会者信息,视频页面 - \(svcManager.getInviteAttendeesMessage(attendees: atteedeeArray ?? [LdapContactInfo()]))")
                ManagerService.confService()?.confCtrlAddAttendee(toConfercene: [atteedee])
            }
            SessionManager.shared.currentAttendeeArray.removeAll()
        }
    }
    // 与会者举手通知
    @objc func notficationHandUpAttendee(notfication:Notification) {
        CLLog("Some participants raised their hands")
        guard let resultDictionary = notfication.userInfo as? [String:String] else {
            return
        }
        if resultDictionary["ECCONF_HAND_UP_RESULT_NUMBER"] == svcManager.mineConfInfo?.number {
            return
        }
        let handUPName = resultDictionary[ECCONF_HAND_UP_RESULT_KEY]
        MBProgressHUD.showBottom("\(handUPName ?? "")" + (isCNlanguage() ? "" : " ") + tr("正在举手"), icon: nil, view: nil)
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
    // 会话修改完成
    @objc func notificationCallModify(notfication:Notification) {
        guard let callInfo = callManager.callInfo()?.callInfoWithcallId(String(SVCMeetingBackView.id)) else {
            return
        }
        svcManager.currentCallInfo = callInfo
    }
    
    // 广播和取消广播与会者通知
    @objc func notificationCallBoardcastInd(notfication:Notification) {
        guard let userInfo = notfication.userInfo else {
            return
        }
        CLLog("广播和取消广播 - \(userInfo)")
        let isBoardcast:String? = userInfo["isBroadcast"] as? String;
        if isBoardcast == "1" { // 广播
            let attendeeInfo:ConfAttendeeInConf? = userInfo["attendee"] as? ConfAttendeeInConf;
            if attendeeInfo?.isBeWatch == false { // 有广播对象，不可以选看
                svcManager.broadcastConfInfo = attendeeInfo
                if svcManager.attendeeArray.count == 0 {
                    return
                }
                self.videoStreamView?.broadcoatAttendee(isBroadAtt: true)
            }else { // 广播对象不在与会者中，不可以选看
                svcManager.broadcastConfInfo = nil
                if svcManager.attendeeArray.count == 0 {
                    return
                }
                self.videoStreamView?.broadcoatAttendee(isBroadAtt: false)
            }
        }else { // 取消广播
            svcManager.broadcastConfInfo = nil
            if svcManager.attendeeArray.count == 0 {
                return
            }
            self.videoStreamView?.broadcoatAttendee(isBroadAtt: false)
        }
    }
    
    // 设备信息上报
    @objc func notificationCallDeviceState(notfication:Notification) {
        guard let userInfo = notfication.userInfo, let deviceInfo = userInfo[CALL_S_CONF_EVT_DEVICE_STATE] else {
            CLLog("- 设备信息获取为空 -")
            return
        }
        // 跟新CallID和接听者信息，会议信息
        let deviceModel:ConfDeviceInfo? = (deviceInfo as? ConfDeviceInfo) ?? ConfDeviceInfo()
        ManagerService.call()?.currentCallInfo.stateInfo.callId = deviceModel?.callId ?? 0
        ManagerService.confService()?.currentConfBaseInfo.callId = Int32(deviceModel?.callId ?? 0)
        svcManager.currentCallInfo = ManagerService.call()?.currentCallInfo
        svcManager.currentMeetInfo = ManagerService.confService()?.currentConfBaseInfo
        SVCMeetingBackView.id = deviceModel?.callId ?? 0
        
        CLLog("设备信息上报 \(deviceModel?.mj_JSONString() ?? "")")
        // 设置前后摄像头
        switch deviceModel?.cameraIndex {
        case 0: // 后置摄像头
            self.switchCamera(cameraIndex: 0)
        case 1: // 前置摄像头
            self.switchCamera(cameraIndex: 1)
        default:
            print("cameraIndex default")
        }
        // 设置摄像头打开关闭
        switch deviceModel?.camera_type.rawValue {
        case 0:     // 关闭
            self.cammerButton.isSelected = false
            self.cammerBtnClick(self.cammerButton)
        case 1:     // 打开
            self.cammerButton.isSelected = true
            self.cammerBtnClick(self.cammerButton)
        case 2:     // 没有摄像头
            CLLog("CONF_CAMERA_NO")
        case 3:
            CLLog("CONF_CAMERA_BUTT")
        default:
            print("camera_type default")
        }
        // 设置扬声器
        switch deviceModel?.speaker_type.rawValue {
        case 0: // 扬声器关闭
            self.showTopVoiceBtn.isSelected = true
            self.showTopVoiceBtnClick(self.showTopVoiceBtn)
        case 1: // 扬声器开启
            self.showTopVoiceBtn.isSelected = false
            self.showTopVoiceBtnClick(self.showTopVoiceBtn)
        case 2:
            CLLog("CONF_SPEAKER_BUTT")
        default:
            print("speaker_type default")
        }
        // 设置麦克风
        switch deviceModel?.mic_type.rawValue {
        case 0 : //  麦克风关闭
            self.muteButton.isSelected = true
            self.muteBtnClick(self.muteButton)
        case 1:  //  麦克风打开
            self.muteButton.isSelected = false
            self.muteBtnClick(self.muteButton)
        case 2:
            CLLog("CONF_MIC_BUTT")
        default:
            print("mic_type default")
        }
    }
    // 动态带宽策略
    @objc func notficationBindWidthChange(notfication:Notification) {
        guard let userInfo = notfication.userInfo as? [String:String], let bindWidth = userInfo[CALL_S_CALL_EVT_BAND_WIDTH_CHANGE] else {
            return
        }
        let moveBindWidth:Int = Int(bindWidth) ?? 0
        if moveBindWidth == 0 {
            CLLog("动态带宽：返回的当前带宽为0")
            return
        }
        CLLog("动态带宽：\(String(moveBindWidth)) - 协商带宽：\(String(svcManager.bindWidth))")
        // 512KB以下
        if moveBindWidth != svcManager.bindWidth {
            if moveBindWidth >= 1920 {                              // 720P
                svcManager.bindWidth = 1920
            }else if moveBindWidth < 1920, moveBindWidth >= 1536 {  // 360P
                svcManager.bindWidth = 1536
            }else if moveBindWidth < 1536, moveBindWidth >= 512 {   // 180P
                svcManager.bindWidth = 512
            }else {                                                 // 90P
                svcManager.bindWidth = moveBindWidth
            }
            // 当前辅流页面不做处理
            if svcManager.isAuxiliary,self.videoStreamView?.scrollCurrentPage == 0 {
                CLLog("动态带宽调整 - 辅流页面 - 不做处理")
                return
            }
            // 直接刷新
            if svcManager.currentShowAttendeeArray.count == 1 { // 大画面
                CLLog("动态带宽调整 - 大画面 - \(self.videoStreamView?.scrollCurrentPage ?? 0)")
                self.videoStreamView?.svcWatchBigPictureCell(bigAttendees: svcManager.currentShowAttendeeArray, BigPictureCell: nil)
            }else if svcManager.currentShowAttendeeArray.count == 2 { // 两画面
                CLLog("动态带宽调整 - 两画面 - \(self.videoStreamView?.scrollCurrentPage ?? 0)")
                self.videoStreamView?.svcWatchGalleryTwoVideoCell(attendeeInConfs: svcManager.currentShowAttendeeArray, twoVideopCell: nil)
            }else if svcManager.currentShowAttendeeArray.count == 3 { // 三画面
                CLLog("动态带宽调整 - 三画面 - \(self.videoStreamView?.scrollCurrentPage ?? 0)")
                self.videoStreamView?.svcWatchGalleryThreeVideoCell(attendeeInConfs: svcManager.currentShowAttendeeArray, threeVideoCell: nil)
            }else { // 四画面
                CLLog("动态带宽调整 - 四画面 - \(self.videoStreamView?.scrollCurrentPage ?? 0)")
                self.videoStreamView?.svcWatchGalleryFourVideoCell(attendeeInConfs: svcManager.currentShowAttendeeArray, fourVideoCell: nil)
            }
        }
        
    }
}

// MARK: 左上角缩小到小画面
extension SVCMeetingViewController {
    @IBAction func suspendWindowClick(_ sender: UIButton) {
        if svcManager.isMyShare {
            return
        }
        UIDevice.switchNewOrientation(.portrait)
        self.videoStreamView?.isShowBigLoadingImage = false
        
        // 当前已经切换到小窗口模式
        self.svcManager.isSmallWindow = true
        // 移除方向监听
        self.removeOrientationObserver()
        SessionManager.shared.currentCalledSeconds = self.currentCalledSeconds
        self.suspend(coverImageName: "", type: .video, svcManager: self.svcManager)
        // 改变摄像头方向
        self.displayShowRotation = .portrait
        self.setCameraDirectionWithRotation()
        // 滑动到第0页
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.videoStreamView?.collectionForPageView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.videoStreamView?.scrollCurrentPage = 0
            self.videoStreamView?.pageControl?.currentPage = self.videoStreamView?.currentPageControlShowIndex(currentScrolPage: 0) ?? 0
        }
    }
    
    // 小窗口移除屏幕方向监听
    func removeOrientationObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
    }
    
    // 恢复窗口后重新监听屏幕方向监听
    func addOrientationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceCurrentMotionOrientationChanged), name: NSNotification.Name(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
    }
    
    func getLastVideoImageWithLastVideoView(view:UIView) -> UIImage {
        let Size = view.size
        UIGraphicsBeginImageContextWithOptions(Size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let Image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return Image
    }
    
}
// 按钮是否可点击扩展
extension SVCMeetingViewController {
    private func bottomBtnisEnabled(isEnabled:Bool) {
        CLLog("-底部会控模块是否可点击 - \(isEnabled)")
        // 底部五个会控按钮
        self.muteButton.isEnabled = isEnabled
        self.cammerButton.isEnabled = isEnabled
        self.shareButton.isEnabled = isEnabled
        self.sitesButton.isEnabled = true
        self.moreButton.isEnabled = isEnabled
        // 信号标题按钮可点击
        self.showSignalView.isUserInteractionEnabled = isEnabled
        self.showMeetTitleView.isUserInteractionEnabled = isEnabled
    }
    // 设置视频状态
    private func refreshVideoImage(isCameraOpen:Bool) {
        let normalImg = isCameraOpen ? "bottomicon_camera1_default" : "bottomicon_camera2_default"
        let _ = isCameraOpen ? "bottomicon_camera1_press" : "bottomicon_camera2_press"
        let _ = isCameraOpen ? "bottomicon_camera1_press" : "bottomicon_camera2_press"
        self.cammerButton.setImageName(normalImg: normalImg, pressImg: normalImg,
                                       disableImg: normalImg, title: tr("视频"))
    }
    
    // 设置麦克风状态
    private func refreshMuteImage(isMute:Bool) {
        let normalImg = isMute ? "icon_mute2_default" : "icon_mute1_default"
        let _ = isMute ? "icon_mute2_press" : "icon_mute1_press"
        let _ = isMute ? "icon_mute2_disabled" : "icon_mute1_disabled"
        self.muteButton.setImageName(normalImg: normalImg, pressImg: normalImg,
                                     disableImg: normalImg, title: tr("静音"))
    }
    // 共享
    private func refreshShareImage() {
        let normalImg = "bottomicon_share1_default"
        let _ = "bottomicon_share1_press"
        let _ = "bottomicon_share1_press"
        self.shareButton.setImageName(normalImg: normalImg, pressImg: normalImg,
                                      disableImg: normalImg, title:  tr("屏幕共享"))
    }
    
    // 设置与会者状态
    private func refreshAddUserImage() {
        let normalImg = "bottomicon_sites_default"
        let _ = "bottomicon_sites_press"
        let _ = "bottomicon_sites_press"
        self.sitesButton.setImageName(normalImg: normalImg, pressImg: normalImg,
                                      disableImg: normalImg, title: tr("与会者"))
    }
    
    // 更多
    private func refreshMoreImage() {
        let normalImg = "bottomicon_more_default"
        let _ = "bottomicon_more_press"
        let _ = "bottomicon_more_press"
        self.moreButton.setImageName(normalImg: normalImg, pressImg: normalImg,
                                     disableImg: normalImg, title: tr("更多"))
    }
    
    // 扬声器
    private func refreshSpeakerImage(isSpeaker:Bool) {
        let normalImg = isSpeaker ? "icon_speaker_default" : "session_video_headset"
        let _ = isSpeaker ? "icon_speaker_default" : "session_video_headset"
        let _ = isSpeaker ? "icon_speaker_default" : "session_video_headset"
        self.showTopVoiceBtn.setImage(UIImage.init(named: normalImg), for: UIControl.State.normal)
    }
}

// MARK: 拨号盘NumberBoardAble
extension SVCMeetingViewController {
    
    @IBAction func dialNumber(_ sender: UIButton) {
        CLLog("-点击打开拨盘-")
        let numberKeyboardVc = NumberKeyboardController()
        numberKeyboardVc.delegate = self
        numberKeyboardVc.interfaceOrientationChangeValue = self.displayShowRotation
        numberKeyboardVc.modalPresentationStyle = .overFullScreen
        numberKeyboardVc.modalTransitionStyle = .crossDissolve
        self.numberKeyboardVc = numberKeyboardVc
        present(numberKeyboardVc, animated: true, completion: nil)
    }
}


// MARK: 会议入会的麦克风摄像头耳机扬声器设置
extension SVCMeetingViewController {
    // 设置摄像头方向
    func setCameraDirectionWithRotation() {
        if svcManager.isMyShare || !SessionManager.shared.isCameraOpen {
            return
        }
        CLLog("陀螺仪返回当前屏幕方向 - \(self.displayShowRotation.rawValue) - 当前摄像头方向 - \(cameraCaptureIndex.rawValue)")
        var callId: UInt32 = 0
        if svcManager.currentMeetInfo != nil && ((svcManager.currentMeetInfo?.callId) != nil) {
            callId = UInt32(svcManager.currentMeetInfo?.callId ?? 0)
        }
        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        callManager.rotationVideo(callId: callId, cameraIndex: self.cameraCaptureIndex, showRotation: self.displayShowRotation)
    }
    // 设入会后麦克风打开和关闭（入会之前麦克风就是闭音）
    func setMicrophoneOpenClose() {
        // 自己是主席判断,并且不是被邀入会
        if self.svcManager.mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
            CLLog("麦克风 - 自己是主席 - 打开音频")
            
            self.muteButton.isSelected = !SessionManager.shared.isMicrophoneOpen
            let result = self.callManager.confCtrlMuteAttendee(participantId: self.svcManager.mineConfInfo?.participant_id, isMute: self.muteButton.isSelected)
            self.refreshMuteImage(isMute: self.muteButton.isSelected)
            SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
            CLLog("入会主持人打开麦克风 - \(String(describing: result)) - \(NSString.encryptNumber(with: self.svcManager.mineConfInfo?.participant_id) ?? "")")
            return
        }
        // MCU返回自己是否静音
        let mcuMineMute:Bool = self.svcManager.mineConfInfo?.is_mute ?? false
        // 自己本地麦克风状态
        let userMute:Bool = UserDefaults.standard.bool(forKey: CurrentUserMicrophoneStatus)
        // 自己闭音或者MCU返回闭音或被邀请入会则不知执行后续操作
        if !userMute || mcuMineMute || SessionManager.shared.isBeInvitation {
            CLLog("麦克风 - 本地闭音 - 与会者未闭音 - 被邀入会")
            self.muteButton.isSelected = true
            let _ = self.callManager.confCtrlMuteAttendee(participantId: self.svcManager.mineConfInfo?.participant_id, isMute: self.muteButton.isSelected)
            self.refreshMuteImage(isMute: self.muteButton.isSelected)
            SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
            return
        }
        // 设置状态
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuto) in
            guard let self = self else { return }
            if isAuto {
                CLLog("-已授权麦克风-")
                self.muteButton.isSelected = !SessionManager.shared.isMicrophoneOpen
                let result = self.callManager.confCtrlMuteAttendee(participantId: self.svcManager.mineConfInfo?.participant_id, isMute: self.muteButton.isSelected)
                self.refreshMuteImage(isMute: self.muteButton.isSelected)
                SessionManager.shared.isMicrophoneOpen = !self.muteButton.isSelected
                CLLog("入会自动打开麦克风 - \(String(describing: result)) - \(NSString.encryptNumber(with: self.svcManager.mineConfInfo?.participant_id) ?? "")")
                return
            }
            CLLog("-未授权麦克风-")
        }
    }
    
    // 设置入会后摄像头打开或关闭
    func setCameraOpenClose() {
        // 自己本地摄像头状态
        let cameraStatus:Bool = UserDefaults.standard.bool(forKey: CurrentUserCameraStatus)
        // 本地摄像头关闭或者被动入会则不知执行后续操作
        if !cameraStatus || SessionManager.shared.isBeInvitation {
            self.cammerButton.isSelected = true
            let result = self.callManager.switchCameraOpen(!self.cammerButton.isSelected, callId: UInt32(self.callManager.currentConfBaseInfo()?.callId ?? 0))
            if result {
                self.refreshVideoImage(isCameraOpen: !self.cammerButton.isSelected)
            }
            CLLog("入会自动设置摄像头 关闭 - \(result ? "true" : "false")")
            SessionManager.shared.isCameraOpen = !self.cammerButton.isSelected
            self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue) // 设置摄像头方向
            setCameraDirectionWithRotation() // 设置摄像头方向
            return
        }
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone { [weak self] (isAuto) in
            guard let self = self else { return }
            if isAuto {
                CLLog("-已授权摄像头")
                self.cammerButton.isSelected = false
                let result = self.callManager.switchCameraOpen(!self.cammerButton.isSelected, callId: UInt32(self.svcManager.currentMeetInfo?.callId ?? 0))
                if result {
                    self.refreshVideoImage(isCameraOpen: !self.cammerButton.isSelected)
                }
                CLLog("入会自动设置摄像头 打开 - \(result ? "true" : "false")")
                SessionManager.shared.isCameraOpen = !self.cammerButton.isSelected
                self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue) // 设置摄像头方向
                self.setCameraDirectionWithRotation() // 设置摄像头方向
                return
            }
            CLLog("-未授权摄像头")
        }
    }
    
    // 切换摄像头
    func switchCamera(cameraIndex:Int?) {
        if !SessionManager.shared.isCameraOpen {
            return
        }
        if let meetInfo = svcManager.currentMeetInfo {
            if cameraIndex != nil {
                if cameraIndex == 0 {
                    self.cameraCaptureIndex = CameraIndex.back
                }else {
                    self.cameraCaptureIndex = CameraIndex.front
                }
            }else {
                self.cameraCaptureIndex = self.cameraCaptureIndex == CameraIndex.front ? CameraIndex.back : CameraIndex.front
            }
            self.callManager.switchCameraIndex(self.cameraCaptureIndex, callId: UInt32(meetInfo.callId))
            // 切换摄像头后
            self.deviceCurrentMotionOrientationChanged()
        }
    }
}

extension SVCMeetingViewController {
    
    // bug_fix yuepeng20201222 获取路由状态，显示与输出音频设备同步的UI
    private func initDefaultRouter() -> Void {
        
        let defaultRouteType:ROUTE_TYPE = self.callManager.obtainMobileAudioRoute()
        //        print("tsdk告诉获取到的设备route是：",defaultRouteType.rawValue)
        CLLog("avc video >> get >>tsdk >> routeType:\(defaultRouteType)")
        
        switch defaultRouteType {
        case ROUTE_TYPE.HEADSET_TYPE ,ROUTE_TYPE.BLUETOOTH_TYPE :
            self.enterHeadSetModel()
            
            self.refreshSpeakerImage(isSpeaker: false)
//            self.showTopVoiceBtn.isEnabled = false
            callManager.closeSpeaker()
            break
        default:
            //            manager.openSpeaker()
            //            self.enterLouderSpeakerModel()
            self.enterSpeakerModel()
            
            break
        }
        
        //TODO:当前无论是TSDK还是系统自行监听获取到的是否耳机插入状态都是错误的，因此发送0设置命令主动触发
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if(false == self.previousRouteType){
                self.enterLouderSpeakerModel()
            }
        }
    }
}

extension SVCMeetingViewController: VideoMeetingDelegate {
    func getLocalVideoView() -> EAGLView? {
        return self.locationVideoView
    }
    
    func isHiddenSmallVideoView() -> Bool {
        return self.showRightBottomSmallIV.isHidden
    }
    
    func showSmallVideoView() {
        if svcManager.mineConfInfo != nil {
            if svcManager.isMyShare {
                hideSmallVideoView()
                return
            }
            CLLog("Show small picture - \(String(self.videoStreamView?.scrollCurrentPage ?? 0))")
            self.showRightBottomSmallIV.isHidden = false
            if svcManager.isNeedRefreshLoc {
              let tepmLocationV = self.locationVideoView
                self.callManager.updateVideoWindow(localView: tepmLocationV, callId: SVCMeetingBackView.id)
                svcManager.isNeedRefreshLoc = false
            }
        }
    }
    
    func hideSmallVideoView() {
        CLLog("Hide small picture - \(String(self.videoStreamView?.scrollCurrentPage ?? 0))")
        self.showRightBottomSmallIV.isHidden = true
    }
    

}


extension SVCMeetingViewController: SuspendWindowDelegate {
    func svcLabelId() -> Int {
        return 0
    }
    
    func isSVCConf() -> Bool {
        return true
    }
    func isAuxNow() -> Bool {
        return self.auxRecvinng
    }
    func captureIndex() -> CameraIndex {
        return self.cameraCaptureIndex
    }
    
    
}

//MARK: 辅流发送停止
extension SVCMeetingViewController {
    func updateScreenShareStatus(updateNow:Bool) -> Void {
        DispatchQueue.main.async {
            if updateNow{
                self.isShare = true
                ManagerService.call()?.controlAuxData(whenApplicationResignActive: true, callId: SVCMeetingBackView.id)
                self.svcManager.isAuxiliary = true
                SessionManager.shared.bfcpStatus = .remoteRecvBFCP
                // 滑动到辅流页面
                CLLog("GLVIEW-REBIND 刷新辅流 Start......")
                self.videoStreamView?.updataByAuxiliaryChange()
            }else{
                if !self.auxRecvinng {
                    CLLog("GLVIEW-REBIND 刷新辅流 End......")
                    self.svcManager.isAuxiliary = false
                    self.videoStreamView?.updataByAuxiliaryChange()
                }
            }
        }
    }
    func auxStartSending() {
        if svcManager.isMyShare {return}
        svcManager.isAuxiliary = false
        self.isShare = true
        self.svcManager.isMyShare = true
        let result = callManager.switchCameraOpen(false, callId: SVCMeetingBackView.id)
        if result {
            refreshVideoImage(isCameraOpen: false)
        }
        CLLog("发送辅流设置摄像头 - \(result ? "true" : "false")")
        self.showRightBottomSmallIV.isHidden = true
        if auxRecvinng {
            self.auxRecvinng = false
            self.videoStreamView?.updataByAuxiliaryChange()
        }
        SessionManager.shared.bfcpStatus = .localSendBFCP
        //共享后的背景视图配置
       
        
    }
    //共享后的背景视图配置
    private func shareBackViewConfig(){
        if self.showBackgroundImageView.subviews.contains(self.shareBackView){
            return
        }
        self.pageControl.isHidden = true
        //改变按钮title
        var  text = tr("停止共享")
        if !isCNlanguage() {
            text = " \(text) "
        }
        self.shareButton.setTitle(text, for: .normal)
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
             self.passiveStopShareScreen()
         }
    }
    
    func resetScreenShareStatus() -> Void {
        self.videoStreamView?.currentBackGroudStatus = true
        CLLog("App进入后台")
    }
    
    //共享结束后
    private func shareScreenEnd(){
        self.shareButton.setTitle(tr("屏幕共享"), for: .normal)
        self.shareBackView.removeFromSuperview()
        self.pageControl.isHidden = false
    }
    
    // 辅流扩展进程更新日志收集入口
    func registerExtensionRecordLogsUpdate() -> Void {
        self.isShare = false
        svcManager.isMyShare = false
        let notificationCenter = RecordNotifycationManager.sharedInstance()
        notificationCenter.register(forNotificationName: "ExtentionRecordFinished"){ [weak self] in
            DispatchQueue.main.async {
                guard let self = self else {return}
                CLLog("用户主动停止辅流")
                self.updateRecordStatusToStop()
                //共享结束后
                self.shareScreenEnd()
            }
        }
        notificationCenter.register(forNotificationName: "ExtentionRecordStop") { [weak self] in
            //code to execute on notification
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.svcManager.isMyShare = false
                ManagerService.call()?.stopSendAuxData(withCallId:UInt32(self.meetInfo?.callId ?? 0))
                CLLog("停止辅流")
                self.updateRecordStatusToStop()
                //共享结束后
                self.shareScreenEnd()
            }
        }
        
        notificationCenter.register(forNotificationName: "ExtentionRecordStart") { [weak self] in
            CLLog("用户点击开始共享 ")
            autoreleasepool {
                DispatchQueue.main.async {
                    
                    let callId = ManagerService.call()?.currentCallInfo.stateInfo.callId ?? 0
                    ManagerService.call()?.startSendAuxData(withCallId: callId)
                    guard let self = self else { return }
//                    self.auxStartSending()
                }
            }
        }
    }
    
    //被动结束扩展进程
    func passiveStopShareScreen() -> Void {
        self.svcManager.isMyShare = false
        SessionManager.shared.bfcpStatus = .noBFCP
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AUX_RECCVING_SHARE_DATA), object: nil)
        ManagerService.call()?.stopSendAuxData(withCallId:UInt32(self.meetInfo?.callId ?? 0))
        let cfnotification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(cfnotification, CFNotificationName.init("STOPSHARED" as CFString), nil, nil, true)
        self.resetCameraStatus()
    }
    
    func updateRecordStatusToStop() {
        autoreleasepool {
            CLLog("updateRecordStatusToStop")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:AUX_RECCVING_SHARE_DATA), object: nil)
            ManagerService.call()?.stopSendAuxData(withCallId:UInt32(svcManager.currentMeetInfo?.callId ?? 0))
//            self.svcManager.isAuxiliary = false
            if svcManager.isMyShare {
                self.svcManager.isMyShare = false
                SessionManager.shared.bfcpStatus = .noBFCP
            }
//            self.videoStreamView?.updataByAuxiliaryChange()
            self.resetCameraStatus()
        }
    }
    private func resetCameraStatus() {
        if  SessionManager.shared.isCameraOpen, !svcManager.isMyShare {
            self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue) // 设置摄像头方向
            let result = callManager.switchCameraOpen(true, callId: SVCMeetingBackView.id)
            if result {
                self.refreshVideoImage(isCameraOpen: true)
            }
            CLLog("重置设置摄像头 - \(result ? "true" : "false")")
            self.setCameraDirectionWithRotation()
        }
    }
}

// 提示框扩展
extension SVCMeetingViewController: NumberBoardAble,PopTitleNormalViewDelegate {
    // NumberBoardAble
    func numberBoardText(_ resuleString: String, _ controller: UIViewController) {
        CLLog(resuleString)
        if resuleString == "" {
            return
        }
        
        CLLog("ManagerService.call()?.sendDTMF  +  \(resuleString)")
        ManagerService.call()?.sendDTMF(withDialNum: resuleString, callId: ManagerService.call()?.currentCallInfo.stateInfo.callId ?? 0)
        if resuleString == "#" {
            controller.dismiss(animated:true, completion: nil)
        }
    }
    // MARK: PopTitleNormalViewDelegate
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController) {
        
    }
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath) {
        
        if index.row == 0 {
            self.endMeetingDismissVC()
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
            MBProgressHUD.showBottom(tr("离开会议"), icon: nil, view: nil)
        } else if index.row == 1 {
            self.endMeetingDismissVC()
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: true)
            Toast.showBottomMessage(tr("会议已结束"))
        } else {
            viewVC.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // 结束会议
    public func endMeetingDismissVC() {
        UserDefaults.standard.setValue(false, forKey: "aux_rec")
        CLLog("endMeetingDismissVC")
        if let meetingInfo = self.meetInfo {
            ContactManager.shared.saveMeetingRecently(meetingInfo: meetingInfo, startTime: "", duration: self.currentCalledSeconds)
        }
        ManagerService.call()?.controlVideo(whenApplicationResignActive: false, callId: SVCMeetingBackView.id)
        self.numberKeyboardVc?.dismiss(animated: false, completion: nil)
        self.numberKeyboardVc = nil
        self.popTitleVC?.dismiss(animated: false, completion: nil)
        self.popTitleVC = nil
        self.hourMinutePickerVC?.dismiss(animated: false, completion: nil)
        self.hourMinutePickerVC = nil
        self.alertSingalVC?.destroyVC()
        self.alertSingalVC = nil
        self.parent?.dismiss(animated: true) {
            CLLog("dismiss parent")
            CLLog("dismiss parent \(self.parent ?? self)")
            NotificationCenter.default.removeObserver(self)
        }
        self.dismiss(animated: true) {
            CLLog("dismiss self")
            CLLog("dismiss self \(self)")
            NotificationCenter.default.removeObserver(self)
        }
    }
}

//设备管理
extension SVCMeetingViewController  {
    func enterHeadSetModel() {
        self.refreshSpeakerImage(isSpeaker: false)
        self.showTopVoiceBtn.isSelected = false
//        self.showTopVoiceBtn.isEnabled = false
        self.previousRouteType = true
    }
    
    func enterLouderSpeakerModel(){
//        self.showTopVoiceBtn.isEnabled = true
        callManager.openSpeaker()
        self.showTopVoiceBtn.isSelected = true
        self.refreshSpeakerImage(isSpeaker: true)
    }
    func enterSpeakerModel() {
        self.showTopVoiceBtn.isSelected = false
//        self.showTopVoiceBtn.isEnabled = true
        //拔掉耳机之后默认进入 听筒模式
        callManager.closeSpeaker()
        self.refreshSpeakerImage(isSpeaker: false)
    }
}

