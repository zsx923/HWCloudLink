//
//  VideoViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/10.
//  Copyright © 2020 陈帆. All rights reserved.

import UIKit
import ReplayKit
import MediaPlayer
import AVFoundation

class VideoViewController: MeetingViewController {
    
    @IBOutlet weak var navBackView: UIView!
    @IBOutlet weak var navTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var showRecordTimeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showBackgroundImageView: UIImageView!
    @IBOutlet weak var showRightBottomSmallIV: DrapView!
    @IBOutlet weak var showsignalImageView: UIImageView!
    @IBOutlet weak var showRecordTimeLabel: UILabel!
    @IBOutlet weak var showBottomTipLabel: UILabel!
    @IBOutlet weak var showUserNameLabel: UILabel!
    @IBOutlet weak var showUserIDLabel: UILabel!

    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var listenBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var suspendWindowBtn: UIButton!
    
    @IBOutlet weak var callBackImageView: UIImageView!
    
    @IBOutlet weak var callLeaveBtn: UIButton!
    
    @IBOutlet weak var callNameLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    
    private let netLevelManager = NetLevel()
    
    //会议详情vc
    public weak var meetInfoVC : MeetingInfoViewController?
    
    // 是否是自己挂断
    private var isMineCloseCall = false
    // 点对点视频是否接听
    private var isAnswerVideo: Bool = false
    //当前是否是大窗口显示，默认是大窗口
    private var isCurrentFullScrren :Bool = true
    //第一次进入标识
    private var previousRouteType:Bool = false
    // 底部控制栏是否展示
    fileprivate var isShowFuncBtns = true
    fileprivate var currentBackStatus = false
    // 当前信号质量
    private var netLevel:String = "5"
    //信号vc
    private weak var alertSingalVC: AlertTableSingalViewController?
    
    fileprivate var displayShowRotation: UIInterfaceOrientation = .portrait
    // 定时器
    fileprivate var timer: Timer?
    // 隐藏会控栏按钮
    fileprivate var hideFuncBtnsCount = 0
    // 更多menu
    fileprivate var menuView: YCMenuView?
    // 小画面位置位置
    private var smallViewOldFrame: CGRect?
    // manager
    private var manager = CallMeetingManager()
    // 是否是转化过来的视频 默认是否
    var isTransfer: Bool = false
    // 静音状态，默认是非静音，在音视频转的过程中需要传递此状态，更新静音icon显示
    var silenceType: Bool = false
    // 扬声器状态, 默认是扬声器状态,在音视频转的过程中需要传递此状态，更新扬声器icon显示
    var soundType: Bool = false
    //是否点击了listenBtn按钮, 默认是false,在音视频转的过程中需要传递此状态，确认是否维持初始状态, video 默认 扬声器
    var isListenBtnType:Bool = false
    //是否点击了扬声器按钮
    var isOpenVoiceBtn :Bool = false
    // fileprivate 当前通话秒数
    var currentCalledSeconds: Int = 1
    //  block 如果需要回传数据则使用，否则不用
    var updatCallSecondBlock: UpdateCallSecondsBlock?
    // 摄像头类型
    var cameraCaptureIndex = CameraIndex.front
    // 创建本地视频画面
    var locationVideoView: EAGLView?
    // 大画面
    var bigVideoView: EAGLView?
    // MARK: - Life cycle
    
    // 导航栏字体颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        CLLog("VideoViewController - viewDidLoad")
        // 设置UI
        setViewUI()
    
        // set navigation
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
        self.setControlNaviAndBottomMenuShow(isShow: true, isAnimated: false)
        
        bottomView.isHidden = false
        self.callInfo = manager.currentCallInfo()
        
        //音频转过来的视频
        if isTransfer {
            self.hideTip()
            self.setCalledViewUI()
            self.setInitData()
            DeviceMotionManager.sharedInstance()?.start()
            self.updateVideoConfig(callId: self.callInfo?.stateInfo.callId ?? 0)
            updateSecondAndVoiceType(0, silence: silenceType)
            if isListenBtnType {
                //点击了listenBtn
                //设置扬声器的装态
                self.setSoundState(isSound: soundType)
            }else{
                //检测是否插入耳机
                let defaultRouteType:ROUTE_TYPE = manager.obtainMobileAudioRoute()
                if (defaultRouteType == ROUTE_TYPE.HEADSET_TYPE) || (defaultRouteType == ROUTE_TYPE.BLUETOOTH_TYPE){
                    initDefaultRouter()
                }else{
                    //默认为扬声器
                    self.setSoundState(isSound: true)
                    self.previousRouteType = true
                }
            }
            self.isAnswerVideo = true
        } else {
//            //默认为扬声器
//            self.setSoundState(isSound: true)
//            self.previousRouteType = true
//            //检测是够否插入耳机
//            initDefaultRouter()
            self.previousRouteType = true
            //检测是否插入耳机
            let defaultRouteType:ROUTE_TYPE = manager.obtainMobileAudioRoute()
            CLLog("========defaultRouteType.rawValue=========  \(defaultRouteType.rawValue)")
            if (defaultRouteType == ROUTE_TYPE.HEADSET_TYPE) || (defaultRouteType == ROUTE_TYPE.BLUETOOTH_TYPE){
                self.enterHeadSetModel2()
            }else{
                //默认为扬声器
                self.setSoundState(isSound: true)
            }
            
            // 非转视频 - 按照之前的逻辑不变
            self.installComingAndCong()
        }
        // 加载通知
        self.installNotification()
        
        
        
        CLLog("self.callInfo赋值 === \(self.callInfo)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CLLog("VideoViewController - viewWillAppear")
        
        if false ==  isRightCamera(){
            SessionManager.shared.isCameraOpen = false
            self.cameraBtn.isUserInteractionEnabled = false
            self.cameraBtn.setImageName("session_video_cammera_close", title: tr("视频"))
            self.cameraBtn.isSelected = SessionManager.shared.isCameraOpen
        }
    }
    private func initDefaultRouter() -> Void {
        var defaultRouteType:ROUTE_TYPE = manager.obtainMobileAudioRoute()
        print("tsdk告诉获取到的设备route是：",defaultRouteType.rawValue)
        CLLog("video >> get >>route:\(defaultRouteType.rawValue)(viewWillAppear)")
        switch defaultRouteType {
        case ROUTE_TYPE.HEADSET_TYPE, ROUTE_TYPE.BLUETOOTH_TYPE:
            self.enterHeadSetModel2()
            break
        default:
//            manager.openSpeaker()
            //默认看起扬声器
//            self.enterLouderSpeakerModel()
//            self.enterSpeakerModel2()
        
            break
        }
        
        //TODO:当前无论是TSDK还是系统自行监听获取到的是否耳机插入状态都是错误的，因此发送0设置命令主动触发
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//           if(false == self.previousRouteType){
//            self.enterLouderSpeakerModel()
//           }
//        }
    }
    
    func isSystemHeadsetPluggedIn()->Bool{
         let route = AVAudioSession.sharedInstance().currentRoute
         for desc in route.outputs {
            print("tsdk告诉获取到的设备ROUTE是",desc.portName,desc.portType)
            if desc.portType == AVAudioSession.Port.headphones {
                 return true
             }
         }
         return false
     }
    
    // 相机权限
   private func isRightCamera() -> Bool {

        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return authStatus != .restricted && authStatus != .denied
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CLLog("VideoViewController - viewWillDisappear")
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CLLog("VideoViewController - viewDidAppear")
        self.displayShowRotation = .portrait
        // 调节摄像头方向
        DeviceMotionManager.sharedInstance()?.start()
        
        self.deviceCurrentMotionOrientationChanged()
        // 屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
        self.isCurrentFullScrren = true
//        self.initDefaultRouter()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CLLog("VideoViewController - viewDidDisappear")
        self.alertSingalVC?.destroyVC()
    }

    deinit {
        CLLog("VideoViewController - deinit")
        //p2pType 0 为语音点呼   其他为视频点呼
        NotificationCenter.default.post(name: NSNotification.Name.init(P2PCallDeinitStatus), object: nil, userInfo: ["P2PType": "1"])
        NotificationCenter.default.removeObserver(self)
        // 关闭设备监听
        DeviceMotionManager.sharedInstance()?.stop()
        NotificationCenter.default.post(name: NSNotification.Name("STOP_TUOLOUYI_NOTIFI"), object: nil)
        // 结束铃声
        SessionHelper.stopMediaPlay()
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }

    }

    override func noStreamAlertAction() {
        CLLog("noStreamAlertAction")
        closeClick(isAnswer: self.isAnswerVideo)
    }
    // MARK: - Private
    private func installComingAndCong() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            self.currentCalledSeconds = 1
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            self.currentCalledSeconds += 1
        })
        
        if !isComing() {
            self.callNameLabel.isHidden = false
            self.callLeaveBtn.isHidden = false
            self.callBackImageView.isHidden = false
            self.showBackgroundImageView.isHidden = true
            self.navBackView.isHidden = true
        
            SessionManager.shared.isConf = false
            bottomView.isHidden = true
            self.showTip(text: tr("正在呼叫") + "\(self.meetInfo?.scheduleUserName ?? "")")
            // 发起语音呼叫（视频）
            manager.startCall(number: self.meetInfo?.accessNumber ?? "", name: self.meetInfo?.name ?? "", type: CALL_VIDEO)
            // 播放铃声ring_back
            SessionHelper.mediaStartPlayWithMediaName(name: "ring_back.wav", isSupportVibrate: false)
            
//            self.listenBtn.isSelected = false
            // 更新扬声器状态
            self.updateCameraOpenClose()
        } else {
            bottomView.isHidden = false
//            self.listenBtn.isSelected = false
            
            self.updateCameraOpenClose()
            // 更新扬声器状态
            self.callInfo = manager.currentCallInfo()
            // 被视频呼叫点对点
            self.hideTip()
            self.setCalledViewUI()
            self.updateVideoConfig(callId: UInt32(self.meetInfo?.callId ?? 0))
        }
    }

    func setViewUI() {
        self.callNameLabel.text = tr("正在呼叫")
        self.showBottomTipLabel.text = tr("正在呼叫")
        
        if let currentConf = manager.currentCallInfo() {
            manager.switchCameraOpen(false, callId: UInt32(currentConf.stateInfo.callId))
        }
        SessionManager.shared.isCameraOpen = true
        self.showRightBottomSmallIV.isHidden = true
        
        self.showRecordTimeLabel.layer.shadowColor = UIColor.black.cgColor
        self.showRecordTimeLabel.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.showRecordTimeLabel.layer.shadowRadius = 2.0
        self.showRecordTimeLabel.layer.shadowOpacity = 0.7
        self.showRecordTimeLabel.isHidden = true
        
        // 隐藏最小化按钮
        self.suspendWindowBtn.isHidden = true
        
        self.showBackgroundImageView.isHidden = true
        self.navBackView.isHidden = true
        
        //渐变色
        contentView.backgroundColor = UIColor.gradient(size: CGSize(width: kScreenWidth, height: kScreenHeight), direction: .default, start: UIColor(white: 0, alpha: 0.3), end: UIColor(white: 0, alpha: 1))
        
        //设置背景
        let userCardStyle = getCardImageAndColor(from: self.meetInfo?.scheduleUserName ?? "")
        self.callBackImageView.image = userCardStyle.cardImage
        self.callBackImageView.alpha = 0.3
//        self.view.backgroundColor = userCardStyle.textColor
        
        
        //被呼叫用户
        self.callNameLabel.text = "\(self.meetInfo?.scheduleUserName ?? "")"
        
        
        // 添加背景点击
        self.showBackgroundImageView.isUserInteractionEnabled = true
        let viewTapGesture = UITapGestureRecognizer.init(actionBlock: { [weak self] (_) in
            guard let self = self else { return }
            self.setControlNaviAndBottomMenuShow(isShow: !self.isShowFuncBtns, isAnimated: true)
        })
        
        self.showBackgroundImageView.addGestureRecognizer(viewTapGesture)
        
        self.leaveBtn.layer.borderColor = COLOR_RED.cgColor
        self.leaveBtn.layer.borderWidth = 1.0
        
        // me video
        self.showRightBottomSmallIV.clipsToBounds = true
        self.showRightBottomSmallIV.layer.cornerRadius = 2.0
        self.showRightBottomSmallIV.layer.borderColor = UIColorFromRGB(rgbValue: 0x979797).cgColor
        self.showRightBottomSmallIV.layer.borderWidth = 0.5
        
        // bottom tip
        self.showBottomTipLabel.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.showBottomTipLabel.clipsToBounds = true
        self.showBottomTipLabel.layer.cornerRadius = self.showBottomTipLabel.height / 2.0
        self.muteBtn.isUserInteractionEnabled = false
        self.listenBtn.isUserInteractionEnabled = false
        self.cameraBtn.isUserInteractionEnabled = false
        self.moreBtn.isUserInteractionEnabled = false
        
        // 设置信号强度
        let signalImg = SessionHelper.getSignalImage(recvLossPercent: 0.0)
//        self.showsignalImageView.image = signalImg
        
        //视屏添加信号点击事件
        self.showsignalImageView.isUserInteractionEnabled = false
        self.showUserNameLabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [weak self] (_) in
            guard let self = self else { return }
            // 会议详情
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
            infoVC.displayShowRotation = self.displayShowRotation
            self.present(infoVC, animated: true) {
            }
            self.meetInfoVC = infoVC
        }))
        
        self.cameraBtn.setImageName(SessionManager.shared.isCameraOpen ? "session_video_cammera" : "session_video_cammera_close", title: tr("视频"))
        self.leaveBtn.setTitle(tr("挂断"), for: .normal)
        
        self.moreBtn.setImageName("more", title: tr("更多"))
        
        // 设置默认为扬声器
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            
            self.listenBtn.isSelected = true
//            self.enterLouderSpeakerModel()
        }
        self.updateCameraOpenClose()
        
        self.setInitData()
        
        let smallVideoView = createLocationVideoView()
        self.showRightBottomSmallIV.addSubview(smallVideoView)
        self.locationVideoView = smallVideoView
    }
 
    
    func presentSignalAlert() {
        
        CLLog("video >> 信号强度点击1.")
        guard let callInfo = self.callInfo else {
            CLLog("video >> 信号强度2获取失败：callInfo=nil")
            return
        }
        // 信号点击
        let alertSingalVC = AlertTableSingalViewController()
        alertSingalVC.isSvc = false
        alertSingalVC.modalPresentationStyle = .overFullScreen
        alertSingalVC.modalTransitionStyle = .crossDissolve
        alertSingalVC.interfaceOrientationChange = self.displayShowRotation
        alertSingalVC.callId = callInfo.stateInfo.callId
        self.alertSingalVC = alertSingalVC
        self.present(alertSingalVC, animated: true, completion: nil)
    }
    
    fileprivate func refreshSignalButtonImg() {
        if let meetInfo = self.meetInfo {
            let isSuccess = manager.getCallStreamInfo(callId: UInt32(meetInfo.callId))
            if isSuccess {
                let recvLossPercent = manager.getRecvLossFraction()
                let signalImg = SessionHelper.getSignalImage(recvLossPercent: recvLossPercent)
//                self.showsignalImageView.image = signalImg
            } else {
                CLLog("video >> 获取会议中的信号信息失败")
            }
        }
    }
    
    func setCalledViewUI() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            self.currentCalledSeconds = 1
        }
        
        // 设置定时器
        self.showRecordTimeLabel.isHidden = false
        self.showRecordTimeLabel.text = NSString.init(format: "%@", NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds)) as String
        self.view.bringSubviewToFront(self.showRecordTimeLabel)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            self.currentCalledSeconds += 1
            self.hideFuncBtnsCount += 1
            self.showRecordTimeLabel.text = NSString.init(format: "%@", NSDate.stringReadStampHourMinuteSecond(withFormatted: self.currentCalledSeconds)) as String
            if self.hideFuncBtnsCount > 5 {
                self.setControlNaviAndBottomMenuShow(isShow: false, isAnimated: true)
                self.hideFuncBtnsCount = 0
            }
        })
        // 显示最小化按钮
        self.suspendWindowBtn.isHidden = false
        self.showsignalImageView.isUserInteractionEnabled = true
        self.showBottomTipLabel.isHidden = true
        self.bottomView.isHidden = false
        showRightBottomSmallIV.isHidden = true
        self.showBackgroundImageView.image = nil
        self.showBackgroundImageView.backgroundColor = UIColor.black
        self.muteBtn.isUserInteractionEnabled = true
        self.listenBtn.isUserInteractionEnabled = true
        self.cameraBtn.isUserInteractionEnabled = true
        self.moreBtn.isUserInteractionEnabled = true
                
        let bigVideoView = createRemoteVideoView()
        self.showBackgroundImageView.addSubview(bigVideoView)
        self.bigVideoView = bigVideoView
        
        
        self.setInitData()
        // 结束铃声
        SessionHelper.stopMediaPlay()
    }
    
    // 创建本地视频画面
    private func createLocationVideoView() -> EAGLView {
        let temp = EAGLViewAvcManager.shared.viewForLocal
//            EAGLViewAvcManager.shared.viewForLocal
        temp.backgroundColor = UIColor.clear
        temp.frame = self.showRightBottomSmallIV.bounds
        let rawValue = UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue
        temp.autoresizingMask = UIView.AutoresizingMask(rawValue: rawValue)
       let sucess =  ManagerService.call()?.updateVideoWindow(withLocal: temp, andRemote: nil, andBFCP: nil, callId: self.callInfo?.stateInfo.callId ?? 0)
        CLLog("video创建了LocalvideoView update_St>> \(sucess)")
        return temp
    }
    
    // 创建大画面
    private func createRemoteVideoView() -> EAGLView {
        let temp = EAGLViewAvcManager.shared.viewForRemote
        temp.backgroundColor = UIColor.clear
        temp.frame = self.showBackgroundImageView.bounds
        temp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        return temp
    }
    
    func setInitData() {
        //隐藏挂断按钮
        self.callNameLabel.isHidden = true
        self.callLeaveBtn.isHidden = true
        self.callBackImageView.isHidden = true
        self.showBackgroundImageView.isHidden = false
        self.navBackView.isHidden = false
        
        // 用户名称
        if !isComing() {
            // 呼叫
            self.showUserIDLabel.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.accessNumber ?? "")
            let name = String(format: tr("与%@通话中"), "\((self.meetInfo?.scheduleUserName) ?? "")")
            self.showUserNameLabel.text = name
        } else {
            // 接听
            if self.callInfo != nil {
                self.showUserIDLabel.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.accessNumber ?? "")
                var name = self.callInfo?.stateInfo.callName ?? ""
                if name.count == 0 {
                    name = self.meetInfo?.accessNumber ?? ""
                }
                let text = String(format: tr("与%@通话中"), "\(name)")
                self.showUserNameLabel.text = text
            } else {
                self.showUserIDLabel.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.accessNumber ?? "")
                let text = String(format: tr("与%@通话中"), "\((self.meetInfo?.accessNumber) ?? "")")
                self.showUserNameLabel.text = text
            }
        }
        self.setMute(isMute: self.silenceType)
    }

    //呼叫时挂断
    @IBAction func callLeaveBtnClick(_ sender: UIButton) {
        self.leaveBtnClick(sender)
    }
    
    // MARK: - IBActions
    // 离开会议
    @IBAction func leaveBtnClick(_ sender: UIButton) {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        isMineCloseCall = true
        CLLog("video >> 当前用户主动结束")
        // 点对点通话
        manager.closeCall(callId: self.callInfo?.stateInfo.callId ?? 0)
        manager.hangupAllCall()
        // 结束铃声
        SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
        SessionHelper.stopMediaPlay()
        ContactManager.shared.saveContactCallLog(callType: 2, name: (meetInfo?.scheduleUserName ?? meetInfo?.accessNumber) ?? "", number: meetInfo?.accessNumber ?? "", depart: "", isAnswer: self.isAnswerVideo, talkTime: self.isAnswerVideo ? self.currentCalledSeconds : self.currentCalledSeconds-1, isComing: meetInfo?.isComing ?? false)
        self.alertSingalVC?.destroyVC()
        self.dismiss(animated: false) {
            CLLog("dismiss")
            NotificationCenter.default.removeObserver(self)
        }
        self.parent?.dismiss(animated: true) {
            CLLog("dismiss")
            NotificationCenter.default.removeObserver(self)
        }
        
        if currentCalledSeconds != 1 {
            showBottomHUD(tr("通话已结束"))
        }
    }
    
    // 设置静音
    @IBAction func muteBtnClick(_ sender: UIButton) {
        
        self.callInfo = manager.currentCallInfo()
        
        // 麦克风未授权 弹框去授权
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuth) in
            guard let self = self else { return }
            if isAuth {
                if self.callInfo == nil {
                    CLLog("video >> callInfo 数据为空(muteBtnClick)")
                    return
                }
                sender.isSelected = !sender.isSelected
                self.manager.muteMic(isSelected: sender.isSelected, callId: self.callInfo?.stateInfo.callId ?? 0)
                self.setMute(isMute: sender.isSelected)
            } else { // 未授权
                self.requestMuteAlert()
            }
        }
    }
    
    //
    @IBAction func listenBtnClick(_ sender: UIButton) {
        
        CLLog("video >>listenBtnClick1->>>start")
        self.previousRouteType = false
        //是否点击了listenBtn
        self.isOpenVoiceBtn = true
        //设置按钮的状态
        var isSound = !sender.isSelected
        if let img = sender.accessibilityIdentifier {
           isSound = !(img == "sound")
        }
        self.setSoundState(isSound:isSound)
    }
    
    // 打开视频
    @IBAction func cameraBtnClick(_ sender: UIButton) {
        
        CLLog("video >>cameraBtnClick1->>>start")
        // 摄像头未授权
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone { [weak self] (isAuth) in
            guard let self = self else { return }
            if isAuth {
                // d打开视频
                SessionManager.shared.isCameraOpen = !SessionManager.shared.isCameraOpen
                if !SessionManager.shared.isCameraOpen {
                    self.cameraBtn.setImageName("session_video_cammera_close", title: tr("视频"))
                    CLLog("video >>cameraBtnClick2->>>st>>close")
                } else {
                    self.cameraBtn.setImageName("session_video_cammera", title: tr("视频"))
                    CLLog("video >>cameraBtnClick3->>>st>>open")
                }
                if let callInfo = self.callInfo {
                    self.manager.switchCameraOpen(SessionManager.shared.isCameraOpen, callId: UInt32(callInfo.stateInfo.callId))
                    self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue)
                    self.deviceCurrentMotionOrientationChanged()
                }
                
            } else { // 未授权
                CLLog("video >>cameraBtnClick4->>>st > \("requestCameraAlert")")
                self.requestCameraAlert()
            }
        }
    }
    
    // 更多
    @IBAction func moreBtnClick(_ sender: UIButton) {
        setMenuViewBtnsInfo()
//        if (self.showRightBottomSmallIV.frame.size.height + self.showRightBottomSmallIV
//            .frame.origin.y + 10) > self.menuView?.frame.origin.y ?? 0 {
//
//            self.smallViewOldFrame = self.showRightBottomSmallIV.frame
//
//            UIView.animate(withDuration: 0.25) {
//                self.showRightBottomSmallIV.frame = CGRect(x: self.showRightBottomSmallIV.frame.origin.x, y: self.menuView?.frame.origin.y ?? 0-20-self.showRightBottomSmallIV.frame.size.height, width: self.showRightBottomSmallIV.frame.size.width, height: self.showRightBottomSmallIV.frame.height)
//            }
//        }
        self.menuView?.show()
    }
    
    // 最小化窗口点击事件
    @IBAction func suspendWindowClick(_ sender: UIButton) {
        
        CLLogDebug("小窗口最小化点击")
        // 移除方向监听
        removeOrientationObserver()
        //强制竖屏
        UIDevice.switchNewOrientation(.portrait)
        suspend(coverImageName: "", type: .video, svcManager: nil)
        // 改变摄像头方向
        self.displayShowRotation = .portrait
        deviceCurrentMotionOrientationChanged()
        self.isCurrentFullScrren = false
    }
    
    // 小窗口移除屏幕方向监听
    func removeOrientationObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
    }
    
    // 恢复窗口后重新监听屏幕方向监听
    func addOrientationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceCurrentMotionOrientationChanged), name: NSNotification.Name(ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
    }
    
    private func endMeetingDismissVC(isTransfer: Bool = false) {
        CLLog("endMeetingDismissVC")
        
        if !isTransfer {
            ManagerService.call()?.switchCameraOpen(false, callId: self.callInfo?.stateInfo.callId ?? 0)
            ManagerService.call()?.switchCameraIndex(1, callId: self.callInfo?.stateInfo.callId ?? 0)
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
            ManagerService.call()?.updateVideoWindow(withLocal: EAGLViewAvcManager.shared.viewForLocal, andRemote: nil, andBFCP: nil, callId: self.callInfo?.stateInfo.callId ?? 0)
        }
        
//        Dispatch.DispatchQueue.asyncAfter(DispatchQueue)
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            NotificationCenter.default.removeObserver(self)
            self.alertSingalVC?.destroyVC()
            if isTransfer {
                self.joinVoiceCall()
            } else {
                self.parent?.dismiss(animated: true) {
                    CLLog("dismiss")
                }
            }
        }
    }
    
    private func joinVoiceCall() {
        NotificationCenter.default.post(name: NSNotification.Name.init(P2PCallDeinitStatus), object: nil, userInfo: ["P2PType": "1"])
        
        let convertModel = P2PConvertModel()
        convertModel.meetInfo = meetInfo
        convertModel.callInfo = callInfo
        //静音键状态
        convertModel.silenceType = self.silenceType
        //扬声器状态
        convertModel.soundType = self.soundType
        //是否点击了listenBtn按钮
        convertModel.isListenBtnClick = (self.isOpenVoiceBtn || self.isListenBtnType) ? true : false
        convertModel.currentCalledSeconds = currentCalledSeconds
    
        if let parentVC = self.parent as? MeetingContainerViewController {
            parentVC.convertTo(type: .p2pVoice, convertModel: convertModel)
        }
    }
    
    //  更新视频配置
    func updateVideoConfig(callId: UInt32) {
        if currentBackStatus {
            //FIX_WANGLIANJIE20210318_START,这一句规避在后台绑定EAGLVIEW
//            return
            //FIX_WANGLIANJIE20210318_END
        }
        // 获取本地视频数据 0: 后置摄像头 1：前置摄像头
        //点击悬浮窗小画面黑屏
        let bigVideoView = createRemoteVideoView()
        self.showBackgroundImageView.addSubview(bigVideoView)
        self.bigVideoView = bigVideoView
        
        CLLog("video >> 更新GLVIEW绑定配置:呼叫ID\(callId)")
        let isSuccess = ManagerService.call()?.updateVideoWindow(withLocal:nil, andRemote: self.bigVideoView, andBFCP: nil, callId: callId)
        // 设置不隐藏
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.showRightBottomSmallIV.isHidden = false
        }
        if !(isSuccess ?? false) {
            CLLog("打开摄像头失败")
            return
        }
        // 更新方向
        DispatchQueue.main.async {
            self.deviceCurrentMotionOrientationChanged()
        }
    }
}

// MARK: 屏幕旋转UI更新
extension VideoViewController {
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.alertSingalVC?.interfaceOrientationChange = toInterfaceOrientation
        showRightBottomSmallIV.interfaceOrientationChange = toInterfaceOrientation
        
        meetInfoVC?.displayShowRotation = toInterfaceOrientation
        self.displayShowRotation = toInterfaceOrientation
        
        
        // 选转屏幕隐藏menu
        self.menuView?.dismiss()
        // 小画面
        if toInterfaceOrientation == .portrait || toInterfaceOrientation == .portraitUpsideDown {
            var rightRect: CGRect = self.showRightBottomSmallIV.frame
            rightRect.origin.y = SCREEN_HEIGHT-self.bottomView.frame.size.height-rightRect.size.height-10
            self.showRightBottomSmallIV.frame = rightRect
        } else {
            var rightRect: CGRect = self.showRightBottomSmallIV.frame
            rightRect.origin.y = SCREEN_WIDTH-self.bottomView.frame.size.height-rightRect.size.height-10
            self.showRightBottomSmallIV.frame = rightRect
        }
       
        
//        // 设置摄像头方向  Swift和OC左右方向取反了
//        self.displayShowRotation = toInterfaceOrientation
//        if toInterfaceOrientation == .landscapeLeft {
//            self.displayShowRotation = .landscapeRight
//        }else if toInterfaceOrientation == .landscapeRight {
//            self.displayShowRotation = .landscapeLeft
//        }
//        self.setCameraDirectionWithRotation()
        
        
    }
}

// MARK: -  Menu弹框
extension VideoViewController {
    func setMenuViewBtnsInfo() {
        var actionArray: [YCMenuAction] = []
        
        // 点对点
        if SessionManager.shared.isCameraOpen {
            actionArray.append(YCMenuAction.init(title: tr("切换摄像头"), image: nil) { [weak self] (_) in
                CLLog("video >> 切换摄像头")
                guard let self = self else { return }
                self.switchCamera(cameraIndex: nil)
            })
        }
        actionArray.append(YCMenuAction.init(title: tr("转语音通话"), image: nil) { [weak self] (_) in
            guard let self = self else { return }
            CLLog("video >>点击 视频转语音通话 callID \(self.callInfo?.stateInfo.callId ?? 0)")
            if self.callInfo != nil {
                self.alertSingalVC?.destroyVC()
                self.manager.downgradeVideoToAudioCall(callId: self.callInfo?.stateInfo.callId ?? 0)
            } else {
                print("--callinfo is nil ---")
                CLLog("video >> callinfo is nil")
            }
        })
        
        let menu = YCMenuView.menu(with: actionArray, width: 150.0, relyonView: self.moreBtn)
        // config
        menu?.backgroundColor = COLOR_DARK_GAY
        menu?.textAlignment = .center
        menu?.separatorColor = COLOR_GAY
        menu?.maxDisplayCount = 20
        menu?.offset = 0
        menu?.textColor = UIColor.white
        menu?.textFont = UIFont.systemFont(ofSize: 16.0)
        menu?.menuCellHeight = 50.0
        menu?.dismissOnselected = true
        menu?.dismissOnTouchOutside = true
        menu?.delegate = self
        self.menuView = menu
    }
}

// MARK: 视频转音频
extension VideoViewController {
    // 转音频
    private func transforToVoiceVC() {
        CLLog("video >> 转换 voice")
        self.endMeetingDismissVC(isTransfer: true)
    }
    // 视频转语音跳转
    func jumpToVoiceVC() {
        CLLog("video >> jumpToVoiceVC")
        guard let meetInfo = self.meetInfo else {
            CLLog("video >> self.meetInfo is nil")
            return
        }
        meetInfo.callId = Int32(self.callInfo?.stateInfo.callId ?? 0)
        meetInfo.confId = self.callInfo?.serverConfId
        meetInfo.mediaType = CONF_MEDIATYPE_VOICE
        meetInfo.isConf = false
        meetInfo.isComing = false
        meetInfo.isImmediately = true
        meetInfo.nameForVoice = self.callInfo?.stateInfo.callName
        ManagerService.call()?.currentCallInfo = self.callInfo
        
        let convertModel = P2PConvertModel()
        convertModel.meetInfo = meetInfo
        convertModel.callInfo = callInfo
    
        if let parentVC = self.parent as? MeetingContainerViewController {
            parentVC.convertTo(type: .p2pVoice, convertModel: convertModel)
        }
        
    }
    // 默认设置为扬声器
    private func updateSecondAndVoiceType(_ updateSeconds: Int, silence: Bool) {
        //更新扬声器状态
        let voiceType = manager.obtainMobileAudioRoute()
//        self.listenBtn.isSelected = voiceType == ROUTE_TYPE.LOUDSPEAKER_TYPE ? false : true
        self.updateCameraOpenClose()
        //更新静音状态
        manager.muteMic(isSelected: silence, callId: self.callInfo?.stateInfo.callId ?? 0)
        self.setMute(isMute: silence)
    }
}

// MARK: - 设置导航栏和底部菜单栏是否显示
extension VideoViewController {
    func setControlNaviAndBottomMenuShow(isShow: Bool, isAnimated: Bool) {
        self.isShowFuncBtns = isShow
        UIView.animate(withDuration: isAnimated ? 0.25 : 0) {
            if isShow {
                self.showNaviAndBottom()
            } else {
                self.hideNaviAndBottom()
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // 隐藏
    func hideNaviAndBottom() {
        self.bottomMenuBottomConstraint.constant = -60.0
        if UI_IS_BANG_SCREEN {
            // 刘海屏
            self.navHeightConstraint.constant = 110.0
            self.showRecordTimeTopConstraint.constant = NAVIGATION_BAR_HEIGHT
            self.navTopConstraint.constant = -NAVIGATION_BAR_HEIGHT - self.navHeightConstraint.constant
        } else {
            // 普通屏
            self.navHeightConstraint.constant = 82
            self.navTopConstraint.constant = -STATUS_BAR_HEIGHT - self.navHeightConstraint.constant
        }
        // 隐藏menu
        self.menuView?.dismiss()
    }
    // 显示
    func showNaviAndBottom() {
        self.showRecordTimeTopConstraint.constant = 16
        self.bottomMenuBottomConstraint.constant = 0.0
        if UI_IS_BANG_SCREEN {
            // 刘海屏
            self.navTopConstraint.constant = -NAVIGATION_BAR_HEIGHT
            self.navHeightConstraint.constant = 110.0
        } else {
            // 普通屏
            self.navTopConstraint.constant = -STATUS_BAR_HEIGHT
            self.navHeightConstraint.constant = 82
        }
        
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait || statusBarOrientation == .portraitUpsideDown { // 竖屏
            if (self.showRightBottomSmallIV.frame.origin.y+self.showRightBottomSmallIV.frame.size.height) > SCREEN_HEIGHT-self.bottomView.frame.size.height {
                
                var rightRect: CGRect = self.showRightBottomSmallIV.frame
                rightRect.origin.y = self.bottomView.frame.origin.y-self.bottomView.frame.size.height-rightRect.size.height-10
                self.showRightBottomSmallIV.frame = rightRect
            }
        } else {
            if (self.showRightBottomSmallIV.frame.origin.y+self.showRightBottomSmallIV.frame.size.height) > SCREEN_WIDTH-self.bottomView.frame.size.height {
                var rightRect: CGRect = self.showRightBottomSmallIV.frame
                rightRect.origin.y = self.bottomView.frame.origin.y-self.bottomView.frame.size.height-rightRect.size.height-10
                self.showRightBottomSmallIV.frame = rightRect
            }
        }
    }
}

// MARK: 视频呼叫或接听界面的处理
extension VideoViewController {
    // 点对点视频呼叫界面
    private func showTip(text: String) {
//        self.showBottomTipLabel.text = text
        self.showBottomTipLabel.alpha = 0.0
        self.showBottomTipLabel.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            self.showBottomTipLabel.alpha = 1.0
        }) { (_) in
        }
    }
    func hideTip() {
        UIView.animate(withDuration: 0.25, animations: {
            self.showBottomTipLabel.alpha = 0.0
        }) { (_) in
            self.showBottomTipLabel.isHidden = true
        }
    }
}

// MARK: - 通知
extension VideoViewController {
    
    func installNotification() {
        // TUP刷新
        NotificationCenter.default.addObserver(self, selector: #selector(tupLocalVideoViewRefreshViewWithCallId(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_REFRESH_VIEW_IND), object: nil)
        // TUP解码成功
        NotificationCenter.default.addObserver(self, selector: #selector(tupRemoteVideoViewDecodeSuccessWithCallId(notification:)), name: NSNotification.Name.init(rawValue: TUP_CALL_DECODE_SUCCESS_NOTIFY), object: nil)
        // 离开或结束会议
        NotificationCenter.default.addObserver(self, selector: #selector(notificationQuitToListViewCtrl(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: nil)
        // 进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAppInactiveNotify(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        // 进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAppActiveNotify(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        // 当前屏幕方向监听
        NotificationCenter.default.addObserver(self, selector: #selector(deviceCurrentMotionOrientationChanged), name: NSNotification.Name.init(rawValue: ESPACE_DEVICE_ORIENTATION_CHANGED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationListenListenChange(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_CALL_ROUTE_CHANGE), object: nil)
        //通话建立的通知，用来获取 callinfo 信息。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallConnected), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_CONNECTED), object: nil)
        // 关闭视频通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationDowngradeVideo), name: NSNotification.Name(CALL_S_CALL_EVT_CLOSE_VIDEO_IND), object: nil)
        // 呼叫结束
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallEnd), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_ENDED), object: nil)
        // 呼出事件
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallOutgoing), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_OUTGOING), object: nil)
        
        // 会议详情视频质量点击通知
        NotificationCenter.default.addObserver(self, selector: #selector(notficationLookAudioClick(notfication:)), name: NSNotification.Name.init(LookAudioAndVideoQualityNotifiName), object: nil)
        
        // 视频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationVideoQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_VIDEO_NET_QUALITY), object: nil)
        // 音频质量变化
        NotificationCenter.default.addObserver(self, selector: #selector(notficationAudioQuality(notfication:)), name: NSNotification.Name.init(CALL_S_CALL_EVT_AUDIO_NET_QUALITY), object: nil)
      
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
    
    // 会议详情视频质量点击通知
    @objc func notficationLookAudioClick(notfication:Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            //查看信号
            self.presentSignalAlert()
            self.refreshSignalButtonImg()
        }
    }
    
    @objc func notificationCallOutgoing(notification: Notification) {
        CLLog("video >> CALL_OUTGOING")
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo else {
            CLLog("notificationCallOutgoing 呼出失败")
            return
        }
        self.callInfo = callInfo
    }
    
    @objc func notificationCallEnd(notification: Notification) {
        CLLog("video >> CALL_CLOSE - call关闭")
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo else {
            CLLog("notificationCallEnd 关闭失败")
            return
        }
        self.callInfo = callInfo
        
        if reasonCodeIsEqualErrorType(reasonCode: callInfo.stateInfo.reasonCode, type: TSDK_E_CALL_ERR_REASON_CODE_NOTFOUND.rawValue) {
            self.showBottomHUD(tr("用户未在线或不存在"))
            self.closeClick(isAnswer: false)
        } else if reasonCodeIsEqualErrorType(reasonCode: callInfo.stateInfo.reasonCode, type: TSDK_E_CALL_ERR_REASON_CODE_NON_STD_REASON.rawValue) {
            self.showBottomHUD(tr("对方忙，请稍后再试"))
            self.closeClick(isAnswer: false)
        } else{
            if ( callInfo.stateInfo.reasonCode == 0 || self.isMineCloseCall == true || callInfo.stateInfo.reasonCode == 50331745){
                self.showBottomHUD(tr("通话已结束"))
            } else {
                if callInfo.stateInfo.reasonCode == 50331648 || callInfo.stateInfo.reasonCode == 50331750 {
                    self.showBottomHUD(tr("会议未开始或不存在了"))
                } else {
                    self.showBottomHUD(tr("对方已挂断"))
                }
            }
            let button: UIButton = UIButton.init()
            button.tag = 10
            self.leaveBtnClick(button)
            self.isMineCloseCall = false
        }
    }
    
    @objc func notificationDowngradeVideo(notification: Notification) {
        CLLog("video >> CALL_DOWNGRADE_VIDEO_PASSIVE - 视频转音频")
        
        guard SuspendTool.isMeeting() else {
            self.transforToVoiceVC()
            return
        }
        
        // 小窗口时先结束小窗口
        NotificationCenter.default.post(name: NSNotification.Name(P2PCallConvertNotify), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.transforToVoiceVC()
        }
    }
  
    @objc func notificationCallConnected(notification:Notification) {
        
//        return
        // 判断call 信息
        CLLog("video >> CALL_CONNECT - 连接")
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo else {
            CLLog("notificationCallConnected 连接失败")
            return
        }
        
        //显示顶部视图
        self.navBackView.isHidden = false
        self.showBackgroundImageView.isHidden = false
        self.callNameLabel.isHidden = true
        self.callLeaveBtn.isHidden = true
        
        // 已经接听
        self.isAnswerVideo = true
        self.callInfo = callInfo
        self.updateVideoConfig(callId: callInfo.stateInfo.callId)
        ManagerService.call()?.switchCameraOpen(false, callId: self.callInfo?.stateInfo.callId ?? 0)
        if callInfo.stateInfo.callType == CALL_AUDIO {
            // 点对点语音接听
            self.jumpToVoiceVC()
            return
        }
        
        self.setCalledViewUI()
        self.setInitData()
        NSObject.stopSoundPlayer()
        
        // 设置扬声器
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25) {
            // 设置摄像头
            self.updateCameraOpenClose()
        }
    }
    
    
    @objc func notificationListenListenChange(notification:Notification){
        print("tsdk_set_mobile_audio状态更新了", notification)
        guard let noti = notification.userInfo as? [String:String] else {
            return
        }
        
        let routeType = noti[AUDIO_ROUTE_KEY]
        CLLog("video >>notify ç ->>>\(routeType)")
        
//        print("tsdk_set_mobile_audio：返回>>>>",routeType)
        switch routeType {
        case "0":
            break
        case "1":
            //扬声器模式
            self.listenBtn.isSelected = true
            self.listenBtn.setImageName("sound", title: tr("扬声器"))
            break
        case "2","4":
            //插入耳机
            self.enterHeadSetModel2()
            break
        case "3":
            if self.previousRouteType,!isOpenVoiceBtn {
                //拔出耳机
                self.enterLouderSpeakerModel()
            }else{
                //拔掉耳机
                self.listenBtn.isSelected = false
                self.listenBtn.isEnabled = true
                self.listenBtn.setImageName( "icon_receiver_default", title: tr("听筒"))
            }
           break

        default:
            break
        }
        
    }
    
    // 刷新本地画面
    @objc func tupLocalVideoViewRefreshViewWithCallId(notification: Notification) {
   
    }
    // tupRemoteVideoViewDecodeSuccessWithCallId
    @objc func tupRemoteVideoViewDecodeSuccessWithCallId(notification: Notification) {
        
        guard let callidNumber = notification.object as? NSNumber else { return }
        
        let callId = callidNumber.intValue
        if UInt32(self.meetInfo?.callId ?? 0) != callId {
            CLLog("video >> call id is not equal to mcu conf callid, ignore!")
            return
        }
    }
    // 离开或结束会议
    @objc func notificationQuitToListViewCtrl(notification: Notification) {
        
        self.endMeetingDismissVC()
        
        let object = notification.object as? String
        if object != nil {
            CLLog("video >> 结束通话")
            showBottomHUD(tr("结束通话"))
            DispatchQueue.main.async {
                ContactManager.shared.saveContactCallLog(callType: 2, name: (self.meetInfo?.scheduleUserName ?? self.meetInfo?.accessNumber) ?? "", number: self.meetInfo?.accessNumber ?? "", depart: "", isAnswer: true, talkTime: self.isAnswerVideo ? self.currentCalledSeconds : self.currentCalledSeconds-1, isComing: self.meetInfo?.isComing ?? false)
            }
        }
    }
    // 进入后台
    @objc func notificationAppInactiveNotify(notification: Notification) {
        CLLog("video >> enter >>appback")
        
        if callInfo == nil {
            return
        }
        manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x01), andIsSync: true, callId: callInfo?.stateInfo.callId ?? 0 )
        manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x02), andIsSync: true, callId: callInfo?.stateInfo.callId ?? 0 )
       manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x02), andModule: EN_VIDEO_OPERATION_MODULE.init(0x01), andIsSync: true, callId: callInfo?.stateInfo.callId ?? 0 )
       manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x02), andModule: EN_VIDEO_OPERATION_MODULE.init(0x02), andIsSync: true, callId: callInfo?.stateInfo.callId ?? 0 )
        if callInfo?.stateInfo.callType == CALL_VIDEO && callInfo?.stateInfo.callState == CallState.taking && SessionManager.shared.isCameraOpen {
            manager.switchCameraOpen(false, callId: callInfo?.stateInfo.callId ?? 0)
            DeviceMotionManager.sharedInstance()?.stop()
        }
        currentBackStatus = true
        
    }
    // 进入前台
    @objc func notificationAppActiveNotify(notification: Notification) {
        CLLog("video >> enter >>active")
        currentBackStatus = false
        self.deviceCurrentMotionOrientationChanged()
        guard let callInfo = self.callInfo else {
            return
        }
        
        manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x01), andIsSync: true, callId: callInfo.stateInfo.callId)
        manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x02), andIsSync: true, callId: callInfo.stateInfo.callId )
       manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x02), andModule: EN_VIDEO_OPERATION_MODULE.init(0x01), andIsSync: true, callId: callInfo.stateInfo.callId)
       manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x02), andModule: EN_VIDEO_OPERATION_MODULE.init(0x02), andIsSync: true, callId: callInfo.stateInfo.callId )
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
            
            self.manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x01), andIsSync: true, callId: callInfo.stateInfo.callId)
            self.manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x08), andModule: EN_VIDEO_OPERATION_MODULE.init(0x02), andIsSync: true, callId: callInfo.stateInfo.callId)
            
            self.manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x01), andModule: EN_VIDEO_OPERATION_MODULE.init(0x01), andIsSync: true, callId: callInfo.stateInfo.callId)
            self.manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x01), andModule: EN_VIDEO_OPERATION_MODULE.init(0x02), andIsSync: true, callId: callInfo.stateInfo.callId)
            
            self.manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x04), andModule: EN_VIDEO_OPERATION_MODULE.init(0x01), andIsSync: true, callId: callInfo.stateInfo.callId)
            self.manager.callInfo()?.videoControl(withCmd: EN_VIDEO_OPERATION.init(0x04), andModule: EN_VIDEO_OPERATION_MODULE.init(0x02), andIsSync: true, callId: callInfo.stateInfo.callId)
            
        }
        if callInfo.stateInfo.callType == CALL_VIDEO && callInfo.stateInfo.callState == CallState.taking && SessionManager.shared.isCameraOpen {
            manager.switchCameraOpen(true, callId: callInfo.stateInfo.callId)
            self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue)
            DeviceMotionManager.sharedInstance()?.start()
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
    
   
    // 设置摄像头方向
    func setCameraDirectionWithRotation() {
        CLLog("陀螺仪返回当前屏幕方向 - \(self.displayShowRotation.rawValue) - 当前摄像头方向 - \(cameraCaptureIndex.rawValue)")
        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        let callId = UInt32(self.callInfo?.stateInfo.callId ?? 0)
        manager.rotationVideo(callId: callId, cameraIndex: self.cameraCaptureIndex, showRotation: self.displayShowRotation)
    }
    
}

// MARK: 会议入会的麦克风摄像头耳机扬声器设置
extension VideoViewController {
    // 设入会后麦克风打开和关闭
    func updateMicrophoneOpenClose() {
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { [weak self] (isAuth) in
            guard let self = self else { return }
            var is_muteMic = true
            if !isAuth {
                is_muteMic = true
            } else {
                let isOpen = !UserDefaults.standard.bool(forKey: DICT_SAVE_MICROPHONE_IS_ON)
                is_muteMic = isOpen
            }
            is_muteMic = true
            if is_muteMic {
                self.muteBtn.setImageName("microphone_close", title: tr("静音"))
            }
        }
    }
    
    // 设置入会后摄像头打开或关闭
    func updateCameraOpenClose() {
        
        //hot_fix yuepeng 20201215 首先判断相机权限是否正常 在开启相机状态控制btn的交互
        if self.isRightCamera() {
            self.cameraBtn.isUserInteractionEnabled = true
        }else{
            return
        }
        
        if let currentConf = manager.currentCallInfo() {
            HWAuthorizationManager.shareInstanst.authorizeToCameraphone { [weak self] (isAuth) in
                guard let self = self else { return }
                if isAuth {
                    SessionManager.shared.isCameraOpen = true
                    
                    self.manager.switchCameraOpen(SessionManager.shared.isCameraOpen, callId: UInt32(currentConf.stateInfo.callId))
                    self.cameraBtn.setImageName("session_video_cammera", title: tr("视频"))
                    self.cameraBtn.isSelected = SessionManager.shared.isCameraOpen
                } else {
                    SessionManager.shared.isCameraOpen = false
                    
                    self.manager.switchCameraOpen(SessionManager.shared.isCameraOpen, callId: UInt32(currentConf.stateInfo.callId))
                    self.cameraBtn.setImageName("session_video_cammera_close", title: tr("视频"))
                    self.cameraBtn.isSelected = SessionManager.shared.isCameraOpen
                }
                self.switchCamera(cameraIndex: self.cameraCaptureIndex.rawValue)
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
        
        if let currentConf = manager.currentCallInfo() {
            if cameraIndex != nil {
                if cameraIndex == 0 {
                    self.cameraCaptureIndex = CameraIndex.back
                }else {
                    self.cameraCaptureIndex = CameraIndex.front
                }
            }else{
                self.cameraCaptureIndex = self.cameraCaptureIndex == CameraIndex.front ? CameraIndex.back : CameraIndex.front
            }
            manager.switchCameraIndex(self.cameraCaptureIndex, callId: UInt32(currentConf.stateInfo.callId))
            self.deviceCurrentMotionOrientationChanged()
        }
    }
    
    // 设置麦克风状态
    func setMute(isMute: Bool) {
        if isMute {
            self.muteBtn.setImageName("microphone_close", title: tr("静音"))
            self.manager.muteMic(isSelected: true, callId: self.callInfo?.stateInfo.callId ?? 0)
        } else {
            self.muteBtn.setImageName("icon_mute1_default", title: tr("静音"))
            self.manager.muteMic(isSelected: false, callId: self.callInfo?.stateInfo.callId ?? 0)
        }
        self.silenceType = isMute
    }
    
    //设置扬声器的状态
    func setSoundState(isSound: Bool) {
        if isSound{
            //开启扬声器
            manager.openSpeaker()
            self.listenBtn.setImageName("sound", title: tr("扬声器"))
            CLLog("video >>listenBtnClick3->>>louder>speaker")
        }else{
            //关闭扬声器
            CLLog("video >>listenBtnClick2->>>speaker")
            self.listenBtn.setImageName( "icon_receiver_default", title:  tr("听筒"))
            manager.closeSpeaker()
        }
        
        //记录listenBtn的状态值
        self.listenBtn.isSelected = isSound
        //记录传的状态值
        self.soundType = isSound
        
    }
}

// MARK: - YCMenuViewDelegate
extension VideoViewController: YCMenuViewDelegate {
    //更多按钮弹框代理，作用为设弹框消失后小窗口下移
    func yCMenuViewDismiss() {
        resumeSmallViewFrame()
    }
    // 小画面位置处理
    private func resumeSmallViewFrame() {
        
        if let smallViewOldFrame = smallViewOldFrame {
            UIView.animate(withDuration: 0.25) {
                self.showRightBottomSmallIV.frame = smallViewOldFrame
                self.smallViewOldFrame = nil
            }
        }
    }
}

// MARK: - VideoMeetingDelegate
extension VideoViewController: VideoMeetingDelegate {
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

extension VideoViewController: SuspendWindowDelegate {
    func svcLabelId() -> Int {
        return 0
    }
    
    func isSVCConf() -> Bool {
        return false
    }
    func isAuxNow() -> Bool {
        return false
    }
    func captureIndex() -> CameraIndex {
        return self.cameraCaptureIndex
    }
}

// MARK: -
extension VideoViewController {
    // 关闭视频
    func closeClick(isAnswer: Bool) {
        // 点对点通话
        manager.closeCall(callId: self.callInfo?.stateInfo.callId ?? 0)
        manager.hangupAllCall()
        // 结束铃声
        SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
        SessionHelper.stopMediaPlay()
        ContactManager.shared.saveContactCallLog(callType: 2, name: (meetInfo?.scheduleUserName ?? meetInfo?.accessNumber) ?? "", number: meetInfo?.accessNumber ?? "", depart: "", isAnswer: isAnswer, talkTime: self.isAnswerVideo ? self.currentCalledSeconds : self.currentCalledSeconds-1, isComing: meetInfo?.isComing ?? false)
        self.alertSingalVC?.destroyVC()
        self.parent?.dismiss(animated: true) {
            CLLog("dismiss")
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func enterHeadSetModel2() {
       self.listenBtn.setImage(UIImage.init(named: "session_video_sound"), for: .normal)
        self.listenBtn.setImageName("icon_receiver_default", title: tr("耳机"))
        self.listenBtn.isSelected = false
        self.listenBtn.isEnabled = true
        self.previousRouteType = true
        manager.closeSpeaker()
        return
   }
   
   func enterLouderSpeakerModel(){
       self.listenBtn.isEnabled = true
       manager.openSpeaker()
       self.listenBtn.isSelected = true
       self.previousRouteType = true
       self.listenBtn.setImageName("sound", title: tr("扬声器"))
   }
    func enterSpeakerModel2() {
       
       self.listenBtn.isSelected = false
       self.listenBtn.isEnabled = true
       //拔掉耳机之后默认进入 听筒模式
       manager.closeSpeaker()
       self.listenBtn.setImageName( "icon_receiver_default", title:  tr("听筒"))
   }
   
    
}
