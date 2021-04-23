//
// JoinUsersViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import MessageUI

protocol JoinUsersViewDelegate: NSObjectProtocol {
    func joinUsersViewSwitchCamera(viewVC: JoinUsersViewController)
}

class JoinUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUserSpeakerLabel: UILabel!
    @IBOutlet weak var userSpearkerView: UIView!
    @IBOutlet weak var user2SpearkerView: UIView!
    @IBOutlet weak var user1SpeakerNameBtn: UIButton!
    @IBOutlet weak var user2SpeakerNameBtn: UIButton!

    @IBOutlet weak var showBottomView: UIView!
    @IBOutlet weak var showBottomHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var stackView: UIStackView!
    private var showBottomItem1Btn = UIButton()
    private var showBottomItem2Btn = UIButton()
    private var showBottomItem3Btn = UIButton()
    private var showBottomItem1View = UIView()
    private var showBottomItem2View = UIView()
    
    private lazy var share: ShareManager = ShareManager()
    var isHaveBroadcastForEvt = false

    weak var customDelegate: JoinUsersViewDelegate?
    weak var alertVC : AlertSingleTextFieldViewController?
    // 是否是语音会议
    var isVideoConf: Bool?
    // 与会者中的我
    var mineConfInfo: ConfAttendeeInConf?

    fileprivate var dataSource: [ConfAttendeeInConf] = []
    fileprivate var speakersArray: [ConfCtrlSpeaker] = []

//    // 是否有主持人
//    fileprivate var isHaveChairMan: Bool {
//        return ManagerService.confService()?.isHaveChair ?? false
//    }
    // 举手事件可以点击
    private var canHandsTap = true
    // 当前与会者个数
    private var attendCount = 0
    // 判断是否在当前屏幕
    private var isShowVC: Bool = false
    // 会议信息
    var meettingInfo: ConfBaseInfo?

    // 是否申请主持人填写密码弹框
    var isPWBullet: Bool = false

    // 当前点击的用户信息
    var selectedAttendInfo: ConfAttendeeInConf?

    fileprivate lazy var rightBarBtnItem: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(named: "session_participant"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
    }()
    
    private lazy var rightShareBarBtnItem: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(named: "contact_share"), style: .plain, target: self, action: #selector(rightShareBarBtnItemClick(sender:)))
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.shadowImage = UIImage()

        // 初始化
        title = getMeetingTitle() // 会影响tabbar的文字显示
        setViewUI()

        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick))
        navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.noUserSpeakerLabel.text = tr("当前无发言人")

        // table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: TableJoinUserCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableJoinUserCell.CELL_ID)
        // 去分割线
        tableView.separatorStyle = .none

        setInitData()

        registerNotify()

        setupButtonDoubleTap(button: user1SpeakerNameBtn)
        setupButtonDoubleTap(button: user2SpeakerNameBtn)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true

        // 设置在当前屏幕
        isShowVC = true

        title = getMeetingTitle(count: attendCount) // 会影响tabbar的文字显示
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        self.share.destroyShareView()

        ManagerService.confService()?.delegate = nil

        // 设置当前控制器不显示
        isShowVC = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func dismissVC (){
        alertVC?.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: false)

    }
    deinit {
        CLLog("JoinUsersViewController deinit")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知

    private func registerNotify() {
        // 监听通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSpeakerList), name: NSNotification.Name(CALL_S_CONF_EVT_SPEAKER_IND), object: nil)
        // 会议信息及状态状态更新
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAttendeeUpdate), name: NSNotification.Name(CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE), object: nil)
        // 邀请与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdateSelectedAttendee), name: NSNotification.Name(UpdataInvitationAttendee), object: nil)
        // 选看回调
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWatchAttendee), name: NSNotification.Name(CALL_S_CONF_WATCH_ATTENDEE), object: nil)
        // 广播指定与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notificationBroadcoatAttendee), name: NSNotification.Name(CALL_S_CONF_BROADCAST_ATTENDEE), object: nil)
        // 取消广播指定与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCancelBroadcoatAttendee), name: NSNotification.Name(CALL_S_CONF_CANCEL_BROADCAST_ATTENDEE), object: nil)
        // 广播事件
        NotificationCenter.default.addObserver(self, selector: #selector(notificationBroadcoatInd), name: NSNotification.Name(CALL_S_CONF_EVT_BROADCAST_IND), object: nil)
        // 全体闭音的通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationListenMute), name: NSNotification.Name(CALL_S_CONF_MUTE_CONF_SUCSESS), object: nil)
        // 全体取消闭音的通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUnmute), name: NSNotification.Name(CALL_S_CONF_UNMUTE_CONF_SUCSESS), object: nil)
        // 添加与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notficationAddAttendee), name: NSNotification.Name(CALL_S_CONF_ADD_ATTENDEE), object: nil)
        // 与会者举手
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSetHandup), name: NSNotification.Name(CALL_S_CONF_SET_HANDUP), object: nil)
        // 释放主持人
        NotificationCenter.default.addObserver(self, selector: #selector(notficationReleaseChairman), name: NSNotification.Name(CALL_S_CONF_RELEASE_CHAIRMAN), object: nil)
        // 申请释放主持人
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRequestChairman), name: NSNotification.Name(CALL_S_CONF_REQUEST_CHAIRMAN), object: nil)
        
        //举手主席提示
        NotificationCenter.default.addObserver(self, selector: #selector(notficationHandUpResult(notification:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_HAND_UP_IND), object: nil)
    }

    // 说话列表通知
    @objc func notificationSpeakerList(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: [ConfCtrlSpeaker]],
              let speaks = userInfo[CALL_S_CONF_EVT_SPEAKER_IND] else {
            return
        }
        speakersArray = speaks
        setViewUI()
        tableView.reloadData()
    }

    // 与会者更新通知
    @objc func notificationAttendeeUpdate(notification _: Notification) {
        setInitData()
    }

    // 邀请选中与会者通知
    @objc func notificationUpdateSelectedAttendee(notification _: Notification) {
        // 添加与会者
        if SessionManager.shared.currentAttendeeArray.count > 0 {
            let atteedeeArray = NSArray(array: SessionManager.shared.currentAttendeeArray) as? [LdapContactInfo]
            for atteedee in atteedeeArray! {
                print([atteedee])
                ManagerService.confService()?.confCtrlAddAttendee(toConfercene: [atteedee])
            }
            SessionManager.shared.currentAttendeeArray.removeAll()
        }
    }

    // 选看与会者通知
    @objc func notificationWatchAttendee(notification: Notification) {
        guard let resultCode = notification.userInfo?[ECCONF_RESULT_KEY] as? NSNumber
             else {
            MBProgressHUD.showBottom(tr("选看失败"), icon: nil, view: nil)
            SessionManager.shared.watchingAttend = nil
            return
        }
        
        if resultCode == 67109034 {
            MBProgressHUD.showBottom(tr("正在广播中, 暂时不能选看"), icon: nil, view: nil)
            SessionManager.shared.watchingAttend = nil
            return
        }
        
        if resultCode != 1 {
            MBProgressHUD.showBottom(tr("选看失败"), icon: nil, view: nil)
            SessionManager.shared.watchingAttend = nil
            return
        }
        
        self.getAttendeeUserList()
        self.leftBarBtnItemClick()
    }

    // 全体闭音
    @objc func notificationListenMute(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber],
              let _ = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("全体静音失败"), icon: nil, view: view)
            return
        }
        MBProgressHUD.showBottom(tr("已全体静音"), icon: nil, view: self.view)
        self.getAttendeeUserList()
    }

    // 取消全体闭音
    @objc func notificationUnmute(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber],
              let _ = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("取消全体静音失败"), icon: nil, view: view)
            return
        }
        MBProgressHUD.showBottom(tr("已取消全体静音"), icon: nil, view: self.view)
        self.getAttendeeUserList()
    }

    // 广播与会者通知
    @objc func notificationBroadcoatAttendee(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber],
              let _ = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("广播失败"), icon: nil, view: self.view)
            return
        }
        
        MBProgressHUD.showBottom(tr("广播成功"), icon: nil, view: self.view)
        //SessionManager.shared.watchingAttend = nil
        self.getAttendeeUserList()
        self.leftBarBtnItemClick()
    }
    
    // 广播事件
    @objc func notificationBroadcoatInd(notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Any],
              let isBroadcast = userInfo["isBroadcast"] as? String  else {
            return
        }
        (isBroadcast == "1") ? (isHaveBroadcastForEvt = true) :  (isHaveBroadcastForEvt = false)
    }

    // 添加与会者
    @objc func notficationAddAttendee(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber],
              let _ = userInfo[CALL_S_CONF_ADD_ATTENDEE] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("添加与会者失败"), icon: nil, view: self.view)
            return
        }
        MBProgressHUD.showBottom(tr("添加与会者成功"), icon: nil, view: view)
    }

    // 与会者举手
    @objc func notficationSetHandup(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber],
              let _ = userInfo[CALL_S_CONF_SET_HANDUP] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("会议无主持人，不能举手"), icon: nil, view: self.view)
            return
        }
//        MBProgressHUD.showBottom("举手成功", icon: nil, view: view)
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
    
    // 释放主持人
    @objc func notficationReleaseChairman(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber] else {
            CLLog("释放主持人失败")
            MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: nil)
            return
        }
        
        let resultCode = userInfo[ECCONF_RESULT_KEY]
        
        if resultCode == 1 {
            CLLog("释放主持人成功")
            MBProgressHUD.showBottom(tr("主持人已释放"), icon: nil, view: nil)
            perform(#selector(leftBarBtnItemClick), with: nil, afterDelay: 1.0)
        }else{
            MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: nil)
        }
    }

    // 申请主持人
    @objc func notificationRequestChairman(notification: Notification) {

        CLLog("notificationRequestChairman")
        guard let resultCode = notification.userInfo?[ECCONF_RESULT_KEY] as? NSNumber  else {
            
            if isPWBullet {
                MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: nil)
                isPWBullet = false
            }
            return
        }
        
        CLLog("notificationRequestChairman  --  resultCode  =====   \(resultCode)")
        
        if resultCode == 67109022 {
            isPWBullet = false
            MBProgressHUD.showBottom(tr("会议已存在主持人，暂无法申请主持人"), icon: nil, view: view)
            return
        }
        
        if resultCode == 67109023 {
            isPWBullet = false
            MBProgressHUD.showBottom(tr("密码错误"), icon: nil, view: self.view)
            return
        }
        
        if resultCode == 1 {
            CLLog("CONF_E_REQUEST_CHAIRMAN_RESULT - 申请主持人")
            MBProgressHUD.showBottom(tr("已申请主持人"), icon: nil, view: view)
//            self.mineConfInfo!.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
            perform(#selector(leftBarBtnItemClick), with: nil, afterDelay: 1.0)
        } else {
            
            if !self.isPWBullet {
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
                if isPWBullet {
                    MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: nil)
                    isPWBullet = false
                }
            }
        }
    }

    // 取消广播
    @objc func notificationCancelBroadcoatAttendee(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NSNumber],
              let _ = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("取消广播失败"), icon: nil, view: self.view)
            return
        }

        //取消广播成功后是否调用选看多画面或者选看对方
//        if attendCount > 2 && !(ManagerService.call()?.isSMC3 ?? true) && SessionManager.shared.watchingAttend == nil {
//            ManagerService.confService()?.watchAttendeeNumber("") 
//        }
        MBProgressHUD.showBottom(tr("取消广播成功"), icon: nil, view: self.view)
        self.getAttendeeUserList()
        self.leftBarBtnItemClick()
        
    }

    // MARK: - Private Funcs

    // left Bar Btn Item Click
    @objc func leftBarBtnItemClick() {
        if isVideoConf ?? false {
            APP_DELEGATE.rotateDirection = .landscape
            UIDevice.switchNewOrientation(.landscapeRight)
        }
        ManagerService.confService()?.delegate = nil
        //延时是为了不让用户看到竖屏布局错乱的感觉
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigationController?.popViewController(animated: false)
        }
        NotificationCenter.default.removeObserver(self)
    }

    // right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender _: UIBarButtonItem) {
        CLLog("添加与会者")
        let storyboard = UIStoryboard(name: "SearchAttendeeViewController", bundle: nil)
        let searchAttendee = storyboard.instantiateViewController(withIdentifier: "SearchAttendeeView") as! SearchAttendeeViewController
        searchAttendee.meetingCofArr = self.dataSource
        self.navigationController?.pushViewController(searchAttendee, animated: true)
    }
    
    //分享按钮
    @objc private func rightShareBarBtnItemClick(sender _: UIBarButtonItem) {
        
        share.share(meetingInfo: self.meettingInfo, from: self, isMeeting: true)
    }

    private func showTextOfSpeaker(_ speaker: ConfCtrlSpeaker) -> String {
        if speaker.dispalyname != nil, speaker.dispalyname.count > 0 {
            return speaker.dispalyname
        }
        return NSString.getSipaccount(speaker.number)
    }

    func setViewUI() {
        self.showBottomView.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
        CLLogDebug("speakersArray = \(speakersArray)")
        // 显示说话人
        if speakersArray.count == 0 {
            noUserSpeakerLabel.isHidden = false
            userSpearkerView.isHidden = true
            user2SpearkerView.isHidden = true
        } else if speakersArray.count == 1 {
            noUserSpeakerLabel.isHidden = true
            userSpearkerView.isHidden = false

            // 隐藏用户2
            user2SpearkerView.isHidden = true

            let speaker1Info = speakersArray[0]
            user1SpeakerNameBtn.setTitle(showTextOfSpeaker(speaker1Info), for: .normal)
            CLLogDebug("speaker1Info = \(NSString.encryptNumber(with: speaker1Info.dispalyname) ?? "")")

        } else {
            noUserSpeakerLabel.isHidden = true
            userSpearkerView.isHidden = false

            // speaker 1
            let speaker1Info = speakersArray[0]
            user1SpeakerNameBtn.setTitle(showTextOfSpeaker(speaker1Info), for: .normal)

            // speaker 2
            let speaker2Info = speakersArray[1]
            user2SpeakerNameBtn.setTitle(showTextOfSpeaker(speaker2Info), for: .normal)
            // 显示用户2
            user2SpearkerView.isHidden = false
            CLLogDebug("speaker1Info = \(NSString.encryptNumber(with: speaker1Info.dispalyname) ?? "")")
            CLLogDebug("speaker2Info = \(NSString.encryptNumber(with: speaker2Info.dispalyname) ?? "")")
        }
        showBottomHeightConstraint.constant = UI_IS_BANG_SCREEN ? 70 : 50
    }

    private func setupButtonDoubleTap(button: UIButton) {
        // 添加双击手势
        let doubleClickGesture = UITapGestureRecognizer(target: self, action: #selector(doubleClickGestureCallBack(gesture:)))
        doubleClickGesture.numberOfTapsRequired = 2
        doubleClickGesture.numberOfTouchesRequired = 1
        button.addGestureRecognizer(doubleClickGesture)
    }

    @objc private func doubleClickGestureCallBack(gesture: UITapGestureRecognizer) {
        // 双击处理
        let textVC = WhiteTextViewController(nibName: "WhiteTextViewController", bundle: nil)
        textVC.showText = (gesture.view as! UIButton).titleLabel!.text ?? ""
        textVC.modalPresentationStyle = .overFullScreen
        textVC.modalTransitionStyle = .crossDissolve

        let currentVC = ViewControllerUtil.getCurrentViewController()
        currentVC.present(textVC, animated: true, completion: nil)
    }
    
    // 是否离会
    private func attendeeHasLeaved(_ attendee: ConfAttendeeInConf) -> Bool {
        return [ATTENDEE_STATUS_LEAVED, ATTENDEE_STATUS_NO_ANSWER,
            ATTENDEE_STATUS_REJECT, ATTENDEE_STATUS_CALL_FAILED].contains(attendee.state)
    }

    // 获取与会者列表
    func getAttendeeUserList() {
        CLLog("获取与会者列表")
        guard let attendeeArray = ManagerService.confService()?.haveJoinAttendeeArray as? [ConfAttendeeInConf] else {
            CLLog("获取与会者列表失败")
            return
        }
        var tempAttendeeArray: [ConfAttendeeInConf] = []
        for attendee in attendeeArray {
            // 是否被选看
            var beWatch = SessionManager.shared.watchingAttend?.number == attendee.number
            // 特殊处理排除（未在会议中)
            if attendeeHasLeaved(attendee) {
                if beWatch {
                    SessionManager.shared.watchingAttend = nil
                    beWatch = false
                }
                if let myConfInfo = self.mineConfInfo, myConfInfo.role == CONFCTRL_CONF_ROLE.CONF_ROLE_ATTENDEE {
                    continue
                }
            }
            
            attendee.hasBeWatch = beWatch
            tempAttendeeArray.append(attendee)
        }

        // 总数组
        var newTempAttendeeArray: [ConfAttendeeInConf] = []
        // 广播
        var broadcastTempAttendee: ConfAttendeeInConf?
        // 选看
        var beWatchTempAttendee: ConfAttendeeInConf?
        // 主持人
        var chairManTempAttendee: ConfAttendeeInConf?
        // 与会者
        var inConfTempAttendeeArray: [ConfAttendeeInConf] = []
        // 挂断与会者
        var leaveTempAttendeeArray: [ConfAttendeeInConf] = []

        for attend in tempAttendeeArray {
            if attend.isSelf || (mineConfInfo != nil && attend.number == mineConfInfo!.number) {
                attend.isSelf = true
                attend.is_open_camera = SessionManager.shared.isCameraOpen
                mineConfInfo = attend
                newTempAttendeeArray.insert(attend, at: 0)
                continue
            }
            if attend.isBroadcast {
                broadcastTempAttendee = attend
                continue
            }
            if attend.hasBeWatch {
                beWatchTempAttendee = attend
                continue
            }
            if attend.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
                chairManTempAttendee = attend
                continue
            }
            if attend.state == ATTENDEE_STATUS_IN_CONF {
                inConfTempAttendeeArray.append(attend)
                continue
            }
            leaveTempAttendeeArray.append(attend)
        }
        // chenfan: 如果广播与选看同时存在,依然保持选看记录
        if let broadcastAttendee = broadcastTempAttendee {
            newTempAttendeeArray.append(broadcastAttendee)
        }
        
        // 添加选看
        if let beWatchAttendee = beWatchTempAttendee {
            newTempAttendeeArray.append(beWatchAttendee)
        }
        
//        isHaveChairMan = false
        if let chairManAttendee = chairManTempAttendee {
//            isHaveChairMan = true
            newTempAttendeeArray.append(chairManAttendee)
        }
        
        newTempAttendeeArray.append(contentsOf: inConfTempAttendeeArray.sorted { (attend1, attend2) -> Bool in
            NSString.firstCharactor(attend1.number) < NSString.firstCharactor(attend2.number)
        })
        // 与会者人数
        attendCount = newTempAttendeeArray.count
        CLLog("与会者个数 ====== \(attendCount)")
        
        newTempAttendeeArray.append(contentsOf: leaveTempAttendeeArray.sorted { (attend1, attend2) -> Bool in
            NSString.firstCharactor(attend1.number) < NSString.firstCharactor(attend2.number)
        })

        dataSource.removeAll()
        dataSource.append(contentsOf: newTempAttendeeArray)
        tableView.reloadData()
        
        // 当前控制器是否显示
        if isShowVC {
            let nav = navigationController as? BaseNavigationController
            nav?.updateTitle(title: getMeetingTitle(count: attendCount))
            CLLog("与会者个数 ====== \(attendCount)")
        }

        if mineConfInfo == nil, newTempAttendeeArray.count > 0 {
            mineConfInfo = newTempAttendeeArray.first
        }
        canHandsTap = true
    }

    private func resetStackView() {
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.arrangedSubviews.forEach { subView in
            stackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }

        showBottomItem1Btn = UIButton()
        showBottomItem1Btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#cccccc"), for: .normal)
        showBottomItem1Btn.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
        showBottomItem1Btn.titleLabel?.numberOfLines = 2
        showBottomItem1Btn.titleLabel?.textAlignment = .center

        showBottomItem2Btn = UIButton()
        showBottomItem2Btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        showBottomItem2Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#cccccc"), for: .normal)
        showBottomItem2Btn.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
        showBottomItem2Btn.titleLabel?.numberOfLines = 2
        showBottomItem2Btn.titleLabel?.textAlignment = .center

        self.showBottomItem1View = UIView.init(frame: CGRect(x: 0, y: 14, width: 1, height: 22))
        self.showBottomItem1View.backgroundColor = UIColor(hexString: "#DDDDDD")
        self.showBottomItem2Btn.addSubview(showBottomItem1View)
//806967
        showBottomItem3Btn = UIButton()
        showBottomItem3Btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        showBottomItem3Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#cccccc"), for: .normal)
        showBottomItem3Btn.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
        showBottomItem3Btn.titleLabel?.numberOfLines = 2
        showBottomItem3Btn.titleLabel?.textAlignment = .center

        self.showBottomItem2View = UIView.init(frame: CGRect(x: 0, y: 14, width: 1, height: 22))
        self.showBottomItem2View.backgroundColor = UIColor(hexString: "#DDDDDD")
        self.showBottomItem3Btn.addSubview(showBottomItem2View)
    }

    func setInitData() {
        getAttendeeUserList()

        isSelfChairMan() ? (navigationItem.rightBarButtonItems = [rightBarBtnItem, rightShareBarBtnItem])  : (navigationItem.rightBarButtonItem = rightShareBarBtnItem)

        resetStackView()

        if isSelfChairMan() {
            showBottomItem1Btn.isEnabled = true
            showBottomItem1Btn.setTitle(tr("全体静音"), for: .normal)
            showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
            showBottomItem1Btn.addTarget(self, action: #selector(setAllMuteBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(showBottomItem1Btn)

            showBottomItem2Btn.isEnabled = true
            showBottomItem2Btn.setTitle(tr("取消全体静音"), for: .normal)
            showBottomItem2Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
            showBottomItem2Btn.addTarget(self, action: #selector(cancelAllMuteBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(showBottomItem2Btn)

            showBottomItem3Btn.isEnabled = true
            showBottomItem3Btn.setTitle(tr("释放主持人"), for: .normal)
            showBottomItem3Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
            showBottomItem3Btn.addTarget(self, action: #selector(releaseChairManBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(showBottomItem3Btn)

        } else {
            if mineConfInfo?.hand_state ?? false {
                self.showBottomItem1Btn.isEnabled = true
                showBottomItem1Btn.setTitle(tr("手放下"), for: .normal)
                showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
                showBottomItem1Btn.addTarget(self, action: #selector(raiseOrPutDownHand), for: .touchUpInside)
                stackView.addArrangedSubview(showBottomItem1Btn)
            } else {
                showBottomItem1Btn.setTitle(tr("举手"), for: .normal)
                showBottomItem1Btn.addTarget(self, action: #selector(raiseOrPutDownHand), for: .touchUpInside)
                stackView.addArrangedSubview(showBottomItem1Btn)

                // 会议中没有主席
                if(ManagerService.confService()?.currentConfBaseInfo != nil) {
                    if (ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) {
                        self.showBottomItem1Btn.isEnabled = true
                        self.showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: UIControl.State.normal)
                    }else{
                        self.showBottomItem1Btn.isEnabled = false
                        self.showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#CCCCCC", darkColor: "#656565"), for: UIControl.State.normal)
                    } 
                }
                
            }
            showBottomItem2Btn.setTitle(tr("申请主持人"), for: .normal)
            showBottomItem2Btn.addTarget(self, action: #selector(requestChairManBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(showBottomItem2Btn)

            // 会议中没有主席
            if !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? true) {
                self.showBottomItem2Btn.isEnabled = true
                self.showBottomItem2Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: UIControl.State.normal)
            }else{
                self.showBottomItem2Btn.isEnabled = false
                self.showBottomItem2Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#CCCCCC", darkColor: "#656565"), for: UIControl.State.normal)
            }
        }
        view.setNeedsLayout()
    }

    func getMeetingTitle(count: Int = 0) -> String {
        return tr("与会者") + "(\(count))"
    }

    // MARK: - IBActions

    @objc func setAllMuteBtnClick() {
        CLLog("设置全体静音")
        // 全体静音
        ManagerService.confService()?.confCtrlMuteConference(true)
    }

    @objc func cancelAllMuteBtnClick() {
        CLLog("取消全体静音")
        ManagerService.confService()?.confCtrlMuteConference(false)
    }

    @objc func releaseChairManBtnClick() {
        CLLog("释放主持人弹框")
        let alertTitleVC = TextTitleViewController(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.customDelegate = self
        present(alertTitleVC, animated: true, completion: nil)
    }

    @objc func requestChairManBtnClick() {
        CLLog("申请主持人")
        if  (ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) {
            CLLog("会议已存在主持人")
            MBProgressHUD.showBottom(tr("会议已存在主持人，暂无法申请主持人"), icon: nil, view: view)
            return
        }
        requestOrReleaseChair()
    }

    @objc func raiseOrPutDownHand() {
        
        // 举手
        if !(ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? true) {
            CLLog("会议无主持人，不能举手")
            MBProgressHUD.showBottom(tr("会议无主持人，不能举手"), icon: nil, view: nil)
            return
        }
        if canHandsTap == false {
            return
        }
        canHandsTap = false
        let isSuccess = ManagerService.confService()?.confCtrlRaiseHand(!(mineConfInfo?.hand_state ?? false), attendeeNumber: mineConfInfo?.number)
        if !isSuccess! {
            if mineConfInfo?.hand_state == false {
                CLLog("举手失败")
                MBProgressHUD.showBottom(tr("举手失败"), icon: nil, view: nil)
            }
        } else {
//            mineConfInfo!.hand_state = !mineConfInfo!.hand_state
            setInitData()
        }
    }

    // MARK: - UITableViewDelegate 代理方法的实现

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataSource.count
    }
    
    func configCell(_ cell: TableJoinUserCell, confAttendInfo: ConfAttendeeInConf) {
        var subTitle = ""
        // 主持人
        if confAttendInfo.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
            subTitle = tr("主持人")
        }
        // 是否广播
        if confAttendInfo.isBroadcast {
            subTitle += subTitle.count > 0 ? " | " + tr("广播") : tr("广播")
        }
        // 正在发言
        for speaker in speakersArray {
            if speaker.number == confAttendInfo.name, speaker.is_speaking {
                subTitle += subTitle.count > 0 ? " | " + tr("正在发言") : tr("正在发言")
                break
            }
        }
        // 与会者状态
        var isHangUp = false
        switch confAttendInfo.state {
        case ATTENDEE_STATUS_CALLING:
            subTitle = tr("正在呼叫")
        case ATTENDEE_STATUS_JOINING:
            subTitle = tr("正在加入")
        case ATTENDEE_STATUS_LEAVED:
            subTitle = tr("已挂断")
            subTitle = ""
            isHangUp = true
            cell.setMuteVoice(isMute: true)
            cell.setHangUp()
            cell.setHandUp(isHandup: false)
        case ATTENDEE_STATUS_NO_EXIST:
            subTitle = tr("用户不存在")
            cell.setMuteVoice(isMute: true)
        case ATTENDEE_STATUS_BUSY:
            subTitle = tr("正在忙")
        case ATTENDEE_STATUS_NO_ANSWER:
            subTitle = tr("未应答")
            cell.setMuteVoice(isMute: true)
        case ATTENDEE_STATUS_REJECT:
            subTitle = tr("拒绝加入")
            cell.setMuteVoice(isMute: true)
        case ATTENDEE_STATUS_CALL_FAILED:
            subTitle = tr("呼叫失败")
            cell.setMuteVoice(isMute: true)
        default:
            CLLog("正在会议中")
        }
        CLLog("与会者状态为 [\(subTitle.isEmpty ? "正在会议中" : subTitle)]")
        if isHangUp {
            cell.showSubTitleLabel.textColor = UIColor.red
        } else {
            cell.showSubTitleLabel.textColor = UIColor(hexString: "999999")
        }
        cell.showSubTitleLabel.text = subTitle
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableJoinUserCell.CELL_ID) as! TableJoinUserCell

        // 解析数据
        let confAttendInfo = dataSource[indexPath.row]
        cell.showVoiceBtn.isUserInteractionEnabled = false
        // set image
        cell.showImageView.image = getUserIconWithAZ(name: confAttendInfo.name ?? "")

        // set title
        let nameStr = confAttendInfo.name! + (confAttendInfo.isSelf ? "（" + tr("我") + "）" : "")
        CLLog("confAttendInfo.name:= \(NSString.encryptNumber(with: confAttendInfo.name) ?? "")")
//        let codeStr = NSString.getSipaccount(confAttendInfo.number!)!
        cell.showTitleLabel.text = "\(nameStr) \(confAttendInfo.number ?? "")"

        let strStyle = NSMutableAttributedString(string: cell.showTitleLabel.text!)
        strStyle.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0), range: NSRange(location: nameStr.count + 1, length: confAttendInfo.number.count))
        strStyle.addAttribute(.foregroundColor, value: COLOR_GAY, range: NSRange(location: nameStr.count + 1, length: confAttendInfo.number.count))

        cell.showTitleLabel.attributedText = strStyle
        CLLog("cell.showTitleLabel.text= \(NSString.encryptNumber(with: cell.showTitleLabel.text) ?? "")")
        // 是否静音
        cell.setMuteVoice(isMute: confAttendInfo.is_mute)

        // 是否举手
        cell.setHandUp(isHandup: confAttendInfo.hand_state)
        
        configCell(cell, confAttendInfo: confAttendInfo)
        cell.setTitleStyle(isTitleCenter: cell.showSubTitleLabel.text == "")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if mineConfInfo == nil {
            return
        }

        // 解析数据
        let confAttendInfo = dataSource[indexPath.row]
        selectedAttendInfo = confAttendInfo

        let popTitleVC = PopTitleNormalViewController(nibName: "PopTitleNormalViewController", bundle: nil)
        popTitleVC.showName = confAttendInfo.isSelf ? confAttendInfo.name + "（" + tr("我") + "）" : confAttendInfo.name
        popTitleVC.isShowDestroyColor = false
        popTitleVC.isShowDestroyColor2 = false
        popTitleVC.isAllowRote = false
        popTitleVC.selectedAtteendeeIndex = indexPath.row

        var strArray: [String] = []
        var itemBlocks: [PopTitleItemBlock] = []

        if confAttendInfo.isSelf {
            setMyMenus(strArray: &strArray, confAttendInfo: confAttendInfo, itemBlocks: &itemBlocks)
        } else {
            setOtherMenus(strArray: &strArray, confAttendInfo: confAttendInfo, itemBlocks: &itemBlocks, popTitleVC)
        }

        // 特殊状态处理
        if isSelfChairMan() {
            switch confAttendInfo.state {
            case ATTENDEE_STATUS_LEAVED, ATTENDEE_STATUS_NO_EXIST, ATTENDEE_STATUS_BUSY, ATTENDEE_STATUS_NO_ANSWER, ATTENDEE_STATUS_REJECT, ATTENDEE_STATUS_CALL_FAILED:
                strArray.removeAll()
                itemBlocks.removeAll()
                strArray.append(tr("重新呼叫"))
                itemBlocks.append(self.inviteAttendee(index:))
                strArray.append(tr("移除"))
                itemBlocks.append(self.deleteAttendee(index:))
                popTitleVC.isShowDestroyColor2 = false
            default:
                CLLog("not define.")
            }
        }

        if strArray.isEmpty {
            return
        }

        popTitleVC.itemBlocks = itemBlocks
        strArray.append(tr("取消"))
        popTitleVC.dataSource = strArray

        popTitleVC.customDelegate = self
        popTitleVC.modalTransitionStyle = .crossDissolve
        popTitleVC.modalPresentationStyle = .overFullScreen
        popTitleVC.view.tag = indexPath.row

        present(popTitleVC, animated: true, completion: nil)
    }

    // cell height
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return TableJoinUserCell.CELL_HEIGHT
    }

    // MARK: - 会控菜单

    fileprivate func isSelfChairMan() -> Bool {
        guard let mineConfInfo = self.mineConfInfo else { return false }

        return mineConfInfo.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
    }

    // 会控菜单 - 自己
    fileprivate func setMyMenus(strArray: inout [String], confAttendInfo: ConfAttendeeInConf,
                                itemBlocks: inout [(Int) -> Void]) {
        strArray.append(confAttendInfo.is_mute ? tr("取消静音") : tr("静音"))
        itemBlocks.append(setMute(index:))
        // 是否视频会议
        let isVideoConf = self.isVideoConf ?? false
        if isSelfChairMan() {
            // 自己是主持人
            if isVideoConf {
                strArray.append(confAttendInfo.is_open_camera ? tr("关闭视频") : tr("打开视频"))
                itemBlocks.append(setCamera(index:))

                strArray.append(confAttendInfo.isBroadcast ? tr("取消广播") : tr("广播"))
                itemBlocks.append(setBroadcast(index:))
                
//                if attendCount > 2 {
                    strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                    itemBlocks.append(setWatchAttendee(index:))
//                }
            }
            strArray.append(tr("释放主持人"))
            itemBlocks.append(requestOrReleaseChair(index:))
        } else {
            // 自己是与会者
            if isVideoConf {
                strArray.append(confAttendInfo.is_open_camera ? tr("关闭视频") : tr("打开视频"))
                itemBlocks.append(setCamera(index:))
//                if attendCount > 2 {
                    strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                    itemBlocks.append(setWatchAttendee(index:))
//                }
            }

            // 当前会议有主席
            if (ManagerService.confService()?.currentConfBaseInfo.hasChairman ?? false) {
                strArray.append(confAttendInfo.hand_state ? tr( tr("手放下")) : tr( tr("举手")))
                itemBlocks.append(self.setRaiseHandAndDownHand(index:))
            }else{
                strArray.append(tr( tr("申请主持人")))
                itemBlocks.append(self.setRequestChairMan(index:))
            }
        }
    }

    // 会控菜单 - 其他人
    fileprivate func setOtherMenus(strArray: inout [String], confAttendInfo: ConfAttendeeInConf,
                                   itemBlocks: inout [(Int) -> Void], _ popTitleVC: PopTitleNormalViewController) {
        // 是否视频会议
        let isVideoConf = self.isVideoConf ?? false
        if isSelfChairMan() {
            // 自己是主持人
            strArray.append(confAttendInfo.is_mute ? tr("取消静音") : tr("静音"))
            itemBlocks.append(setMute(index:))
            if isVideoConf {
                strArray.append(confAttendInfo.isBroadcast ? tr("取消广播") : tr("广播"))
                itemBlocks.append(setBroadcast(index:))
                
                if confAttendInfo.hand_state && !(ManagerService.call()?.isSMC3 ?? true) {
                    strArray.append(tr( tr("手放下")))
                    itemBlocks.append(self.setRaiseHandAndDownHand(index:))
                }

//                if attendCount > 2 {
                    strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                    itemBlocks.append(setWatchAttendee(index:))
//                }
            }
            
            if !isVideoConf {
                if confAttendInfo.hand_state && !(ManagerService.call()?.isSMC3 ?? true) {
                    strArray.append(tr( tr("手放下")))
                    itemBlocks.append(self.setRaiseHandAndDownHand(index:))
                }
            }
            
            popTitleVC.isShowDestroyColor = true
            popTitleVC.isShowDestroyColor2 = true
            strArray.append(tr("挂断"))
            itemBlocks.append(setHangUp(index:))
            strArray.append(tr("移除"))
            itemBlocks.append(deleteAttendee(index:))
        } else {
            // 自己是与会者
            if isVideoConf {
                strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                itemBlocks.append(setWatchAttendee(index:))
            }
        }
    }
    // MARK: - Actions

    // 释放主持人权限
    func requestOrReleaseChair(index _: Int = 0) {
        if isSelfChairMan() {
            // 释放主持人
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { //延时主要是让列表下去再弹出释放主席框
                self.releaseChairManBtnClick()
            }
        } else {
            
            self.isPWBullet = false
            if !ManagerService.call().isSMC3, SessionManager.shared.isSelfPlayCurrentMeeting, SessionManager.shared.isMeetingVMR  {
                CLLog("smc 2.0 vmr Chairperson----")
                ManagerService.confService()?.confCtrlRequestChairman(SessionManager.shared.cloudMeetInfo.chairmanPwd, number: mineConfInfo?.number)
                return
            }
            
            if ManagerService.call().isSMC3, SessionManager.shared.isSelfPlayCurrentMeeting, SessionManager.shared.isMeetingVMR {
                CLLog("smc 3.0 vmr Chairperson----")
                ManagerService.confService()?.confCtrlRequestChairman(meettingInfo?.chairmanPwd ?? "", number: mineConfInfo?.number)
                return
            }

            ManagerService.confService()?.confCtrlRequestChairman("", number: mineConfInfo?.number)
            
        }
    }

    func setMute(index _: Int) {
        guard let confAttendInfo = selectedAttendInfo else { return }
        let isSuccess = ManagerService.confService()?.confCtrlMuteAttendee(confAttendInfo.number, isMute: !confAttendInfo.is_mute) ?? false
        if isSuccess {
            SessionManager.shared.isMicrophoneOpen = !confAttendInfo.is_mute
            NotificationCenter.default.post(name: NSNotification.Name(MineMicrophoneStateChange), object: nil)
        }
        CLLog("设置静音\(isSuccess ? "成功" : "失败")")
    }

    // 设置摄像头
    func setCamera(index _: Int) {
        CLLog("setCamera")
        customDelegate?.joinUsersViewSwitchCamera(viewVC: self)
        getAttendeeUserList()
    }

    // 设置广播
    func setBroadcast(index _: Int) {
        CLLog("setBroadcast")
        guard let confAttendInfo = selectedAttendInfo else { return }
        if confAttendInfo.is_audio {
            MBProgressHUD.showBottom(tr("语音入会，不能广播"), icon: nil, view: view)
            return
        }
        
        if confAttendInfo.isBroadcast {  //正在被广播
            ManagerService.confService()?.broadcastAttendee(confAttendInfo.number, isBoardcast: false)
        } else {
            ManagerService.confService()?.broadcastAttendee(confAttendInfo.number, isBoardcast: true)
        }
    }

    // 设置选看
    func setWatchAttendee(index _: Int) {
        CLLog("setWatchAttendee")
        guard let confAttendInfo = selectedAttendInfo else { return }
        let broadcastArray = dataSource.filter { $0.isBroadcast }
        if !broadcastArray.isEmpty || isHaveBroadcastForEvt {
            if SessionManager.shared.watchingAttend != nil && SessionManager.shared.watchingAttend?.participant_id == confAttendInfo.participant_id {
                MBProgressHUD.showBottom(tr("正在广播中, 暂时不能取消选看"), icon: nil, view: view)
            }else {
                MBProgressHUD.showBottom(tr("正在广播中, 暂时不能选看"), icon: nil, view: view)
            }
            return
        }
        if confAttendInfo.is_audio {
            MBProgressHUD.showBottom(tr("语音入会，不能选看"), icon: nil, view: view)
            return
        }
        // 正在被选看
        if confAttendInfo.hasBeWatch {
            // 取消选看
            SessionManager.shared.watchingAttend = nil
            ManagerService.confService()?.watchAttendeeNumber("")
        } else {
            // 选看
            SessionManager.shared.watchingAttend = confAttendInfo
            ManagerService.confService()?.watchAttendeeNumber(NSString.getSipaccount(confAttendInfo.number))
        }
    }

    // 设置挂断
    func setHangUp(index _: Int) {
        guard let confAttendInfo = selectedAttendInfo else { return }
        if SessionManager.shared.watchingAttend?.number == confAttendInfo.number {
            SessionManager.shared.watchingAttend = nil
            SessionManager.shared.chairPassword = ""
        }
        let isSuccess = ManagerService.confService()?.confCtrlHangUpAttendee(confAttendInfo.number) ?? false
        CLLog("设置挂断\(isSuccess ? "成功" : "失败")")
        isSuccess ? MBProgressHUD.showBottom(tr("挂断成功"), icon: nil, view: nil) : MBProgressHUD.showBottom(tr("挂断失败"), icon: nil, view: nil)
    }

    // 设置举手和手放下
    func setRaiseHandAndDownHand(index: Int) {
        // 自己主席 放下别人的手
        if selectedAttendInfo?.number != self.mineConfInfo?.number && selectedAttendInfo?.isSelf == false {
            guard let selectedAttendInfo = selectedAttendInfo else {
                return
            }
            if ManagerService.confService()?.confCtrlRaiseHand(!(selectedAttendInfo.hand_state), attendeeNumber: selectedAttendInfo.number) ?? false {
                setInitData()
            }
            return
        }
        raiseOrPutDownHand()
    }

    // 申请主持人
    func setRequestChairMan(index:Int) {
        self.requestChairManBtnClick()
    }

    func downHand(index _: Int) {
        CLLog("downHand")
        guard let confAttendInfo = selectedAttendInfo else { return }
        if confAttendInfo.hand_state == true {
            let isSuccess = ManagerService.confService()?.confCtrlRaiseHand(!confAttendInfo.hand_state, attendeeNumber: confAttendInfo.number) ?? false
            CLLog("手放下\(isSuccess ? "成功" : "失败")")
            if !isSuccess {
                if confAttendInfo.hand_state == false {
                    MBProgressHUD.showBottom(tr("手放下失败"), icon: nil, view: nil)
                }
            } else {
                confAttendInfo.hand_state = !confAttendInfo.hand_state
            }
        }
    }

    // 重新邀请
    func inviteAttendee(index _: Int) {
        guard let confAttendInfo = selectedAttendInfo else { return }
        let isSuccess = ManagerService.confService()?.confCtrlRecallAttendee(confAttendInfo.number) ?? false
        CLLog("重新邀请\(isSuccess ? "成功" : "失败")")
    }

    // 删除与会者
    func deleteAttendee(index _: Int) {
        guard let confAttendInfo = selectedAttendInfo else { return }
        if SessionManager.shared.watchingAttend?.number == confAttendInfo.number {
            SessionManager.shared.watchingAttend = nil
            SessionManager.shared.chairPassword = ""
        }
        let isSuccess = ManagerService.confService()?.confCtrlRemoveAttendee(confAttendInfo.number) ?? false
        CLLog("删除与会者\(isSuccess ? "成功" : "失败")")
    }
}

// MARK: - UITextFieldDelegate
extension JoinUsersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)

        return nowString.count <= 6
    }
}

// MARK: - TextTitleViewDelegate
extension JoinUsersViewController: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        viewVC.showTitleLabel.text = tr("会议将无主持人，是否释放")
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
    }
    
    func textTitleViewLeftBtnClick(viewVC _: TextTitleViewController, sender _: UIButton) {}
    
    func textTitleViewRightBtnClick(viewVC _: TextTitleViewController, sender _: UIButton) {
        CLLog("用户选择释放主持人")
        // 释放主持人
        let isSuccess = ManagerService.confService()?.confCtrlReleaseChairman(mineConfInfo?.number) ?? false
        CLLog("释放主持人接口调用\(isSuccess ? "成功" : "失败")")
        if !isSuccess {
            MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: view)
        }
    }
}

// MARK: - AlertSingleTextFieldViewDelegate
extension JoinUsersViewController: AlertSingleTextFieldViewDelegate {
    
    func showPasswordAlert() {
        let alertVC = AlertSingleTextFieldViewController(nibName: "AlertSingleTextFieldViewController", bundle: nil)
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.customDelegate = self
        self.alertVC = alertVC
        present(self.alertVC!, animated: true) {
            self.alertVC!.showInputTextField.keyboardType = .numberPad
        }
    }
    
    func alertSingleTextFieldViewViewDidLoad(viewVC: AlertSingleTextFieldViewController) {
        viewVC.showTitleLabel.text = tr("主持人密码")
        viewVC.showInputTextField.isSecureTextEntry = true
        viewVC.showInputTextField.placeholder = tr("请输入密码")
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        viewVC.showInputTextField.delegate = self
    }
    
    // left btn Click
    func alertSingleTextFieldViewLeftBtnClick(viewVC _: AlertSingleTextFieldViewController, sender _: UIButton) {
        isPWBullet = false
    }
    
    // right btn click
    func alertSingleTextFieldViewRightBtnClick(viewVC: AlertSingleTextFieldViewController, sender _: UIButton) {
        // 先传“”空值，如是密码会议则申请失败，失败输入密码的弹框，如果输入密码是空点击了确认，则传1让其申请失败
        
        // 申请主持人权限
        if ManagerService.confService()?.uPortalConfType == CONF_TOPOLOGY_SMC {
            let password = viewVC.showInputTextField.text?.count == 0 ? "" : viewVC.showInputTextField.text
            let isSuccess = ManagerService.confService()?.confCtrlRequestChairman(password, number: mineConfInfo?.number) ?? false
            CLLog("申请主持人接口调用\(isSuccess ? "成功" : "失败")")
        }
    }
}

// MARK: - PopTitleNormalViewDelegate
extension JoinUsersViewController: PopTitleNormalViewDelegate {
    func popTitleNormalViewDidLoad(viewVC _: PopTitleNormalViewController) {}
    
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index _: IndexPath) {
        viewVC.dismiss(animated: true, completion: nil)
    }
}

