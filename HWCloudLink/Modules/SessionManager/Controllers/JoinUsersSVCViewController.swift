//
// JoinUsersSVCViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
// JoinUsersSVCViewController

import UIKit
import MessageUI

class JoinUsersSVCViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUserSpeakerLabel: UILabel!
    @IBOutlet weak var userSpearkerView: UIView!
    @IBOutlet weak var user2SpearkerView: UIView!
    @IBOutlet weak var user1SpeakerNameBtn: UIButton!
    @IBOutlet weak var user2SpeakerNameBtn: UIButton!
    @IBOutlet weak var showBottomView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var showBottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    private lazy var share: ShareManager = ShareManager()
    private var showBottomItem1Btn = UIButton()
    private var showBottomItem1View = UIView()
    private var showBottomItem2Btn = UIButton()
    private var showBottomItem2View = UIView()
    private var showBottomItem3Btn = UIButton()
    
    // svcManager.
    public var svcManager = SVCMeetingManager()
    
    //会议信息
    public var meettingInfo: ConfBaseInfo?
    // 与会者中的自己
    fileprivate var mineConfInfo: ConfAttendeeInConf?
    // 与会者中的主持人
    fileprivate var chairmanConfInfo: ConfAttendeeInConf?
    // 与会者中的选看对象
    public var watchConfInfo: ConfAttendeeInConf?
    // 与会者中的广播对象
    fileprivate var broadcastConfInfo: ConfAttendeeInConf?
    
    // 当前点击的用户信息
    fileprivate var selectedAttendInfo: ConfAttendeeInConf?
    
    // 定时器
    fileprivate var timer: Timer?
    // 无发言人累计秒数
    fileprivate var noSpeakerTimeCount : Int = 0
    
    // 与会者数组
    fileprivate var dataSource: [ConfAttendeeInConf] = []
    // 与会者语音数组
    fileprivate var speakersArray: [ConfCtrlSpeaker] = []

    
    // 当前与会者个数（有效的与会者个数：在会议中的）
    private var attendCount = 0

    // 是否申请主持人填写密码弹框
    var isPWBullet : Bool = false
        
    // 添加与会者 当自己是主持人时显示
    fileprivate lazy var rightBarBtnItem: UIBarButtonItem = {
         return UIBarButtonItem.init(image: UIImage.init(named: "session_participant"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
    }()
    
    private lazy var rightShareBarBtnItem: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(named: "contact_share"), style: .plain, target: self, action: #selector(rightShareBarBtnItemClick(sender:)))
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // 返回按钮
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        // 设置导航栏横线
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        // 会影响tabbar的文字显示
        self.title = getMeetingTitle(count: 0)
        
        self.noUserSpeakerLabel.text = tr("当前无发言人")
        
        // 更新UI
        self.setViewUI()
        // TableView设置
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: JoinUserSVCTableViewCell.CELL_ID, bundle: nil), forCellReuseIdentifier: JoinUserSVCTableViewCell.CELL_ID)
        self.tableView.separatorStyle = .none
        
        // 与会者数据处理
        self.setInitData()
        // 注册通知
        self.registerNotify()
        // 双击手势
        setupButtonDoubleTap(button: user1SpeakerNameBtn)
        setupButtonDoubleTap(button: user2SpeakerNameBtn)
        // UI布局
        self.stackViewBottomConstraint.constant = isiPhoneXMore() ? 20 : 0
        self.showBottomHeightConstraint.constant = isiPhoneXMore() ? 70 : 50
        self.tableViewBottomConstraint.constant = isiPhoneXMore() ? 70 : 50
//        // 3秒钟无人说话则移除发言人数组同时刷新页面
//        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (sender) in
//            guard let self = self else {return}
//            self.noSpeakerTimeCount += 1
//            if self.noSpeakerTimeCount == 10 {
//                self.speakersArray.removeAll()
//                self.setViewUI()
//                self.tableView.reloadData()
//            }
//        })
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = getMeetingTitle(count: attendCount)
        // 屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    // MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false // 关闭常亮
        self.share.destroyShareView()
    }
    
    // MARK: viewWillDisappear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        CLLog("JoinUsersSVCViewController deinit")
        NotificationCenter.default.removeObserver(self)
    }
        
}
// 数据处理及更新UI界面
extension JoinUsersSVCViewController {
    // 设置入会UI
    private func setViewUI() {
        self.showBottomView.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
        CLLog("speakersArray = \(speakersArray)")
        // 显示说话人
        if self.speakersArray.count == 0 {              // 当前与会者无发言
            self.noUserSpeakerLabel.isHidden = false
            self.userSpearkerView.isHidden = true
            self.user2SpearkerView.isHidden = true
            CLLog("speaker1Info = no speaker")
        } else if self.speakersArray.count == 1 {       // 当前与会者中只有一人发言
            self.noUserSpeakerLabel.isHidden = true
            self.userSpearkerView.isHidden = false
            // 隐藏用户2
            self.user2SpearkerView.isHidden = true
            let speaker1Info = self.speakersArray[0]
            self.user1SpeakerNameBtn.setTitle(showTextOfSpeaker(speaker1Info), for: .normal)
            CLLog("speaker1Info = \(NSString.encryptNumber(with: speaker1Info.dispalyname) ?? "")")
        } else {                                        // 当前页面有多人发言
            self.noUserSpeakerLabel.isHidden = true
            self.userSpearkerView.isHidden = false
            // speaker 1
            let speaker1Info = self.speakersArray[0]
            self.user1SpeakerNameBtn.setTitle(showTextOfSpeaker(speaker1Info), for: .normal)
            // speaker 2
            let speaker2Info = self.speakersArray[1]
            self.user2SpeakerNameBtn.setTitle(showTextOfSpeaker(speaker2Info), for: .normal)
            // 显示用户2
            self.user2SpearkerView.isHidden = false
            CLLog("speaker1Info = \(NSString.encryptNumber(with: speaker1Info.dispalyname) ?? "")")
            CLLog("speaker2Info = \(NSString.encryptNumber(with: speaker2Info.dispalyname) ?? "")")

        }
    }
    
    // 根据数据处理页面显示
    func setInitData() {
        // 与会者数据处理
        self.getAttendeeUserList()
        // 自己是主席则可以添加与会者
        isSelfChairMan() ? (navigationItem.rightBarButtonItems = [rightBarBtnItem, rightShareBarBtnItem])  : (navigationItem.rightBarButtonItem = rightShareBarBtnItem)
        // 设置底部按钮
        self.resetStackView()
        // 自己是主席
        if isSelfChairMan() { //（全体静音，取消全体静音，释放主持人）
            // 左一按钮
            self.showBottomItem1Btn.isEnabled = true
            self.showBottomItem1Btn.setTitle(tr("全体静音"), for: .normal)
            self.showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
            self.showBottomItem1Btn.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
            self.showBottomItem1Btn.addTarget(self, action: #selector(setAllMuteBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(self.showBottomItem1Btn)
            // 居中按钮
            self.showBottomItem2Btn.isEnabled = true
            self.showBottomItem2Btn.setTitle(tr("取消全体静音"), for: .normal)
            self.showBottomItem2Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
            self.showBottomItem2Btn.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
            self.showBottomItem2Btn.addTarget(self, action: #selector(cancelAllMuteBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(self.showBottomItem2Btn)
            // 右边按钮
            self.showBottomItem3Btn.isEnabled = true
            self.showBottomItem3Btn.setTitle(tr("释放主持人"), for: .normal)
            self.showBottomItem3Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
            self.showBottomItem3Btn.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#444444")
            self.showBottomItem3Btn.addTarget(self, action: #selector(releaseChairManBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(self.showBottomItem3Btn)
        } else { // 自己不是主席 （举手，申请主席人）
            // 左边
            if self.mineConfInfo != nil && self.mineConfInfo!.hand_state {
                self.showBottomItem1Btn.isEnabled = true
                self.showBottomItem1Btn.setTitle(tr("手放下"), for: .normal)
                self.showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
                self.showBottomItem1Btn.addTarget(self, action: #selector(raiseOrPutDownHand), for: .touchUpInside)
                stackView.addArrangedSubview(self.showBottomItem1Btn)
            } else {
                self.showBottomItem1Btn.setTitle(tr("举手"), for: .normal)
                self.showBottomItem1Btn.addTarget(self, action: #selector(raiseOrPutDownHand), for: .touchUpInside)
                stackView.addArrangedSubview(self.showBottomItem1Btn)
                // 会议中没有主席
                if (self.svcManager.currentMeetInfo?.hasChairman ?? false) {
                    self.showBottomItem1Btn.isEnabled = true
                    self.showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: .normal)
                }else{
                    self.showBottomItem1Btn.isEnabled = false
                    self.showBottomItem1Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#CCCCCC", darkColor: "#656565"), for: .normal)
                }
            }
            // 右边按钮
            self.showBottomItem2Btn.setTitle(tr("申请主持人"), for: .normal)
            self.showBottomItem2Btn.addTarget(self, action: #selector(requestChairManBtnClick), for: .touchUpInside)
            stackView.addArrangedSubview(self.showBottomItem2Btn)
            // 会议中没有主席
            if !(self.svcManager.currentMeetInfo?.hasChairman ?? false) {
                self.showBottomItem2Btn.isEnabled = true
                self.showBottomItem2Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#CCCCCC"), for: UIControl.State.normal)
            }else{
                self.showBottomItem2Btn.isEnabled = false
                self.showBottomItem2Btn.setTitleColor(UIColor.colorWithSystem(lightColor: "#CCCCCC", darkColor: "#656565"), for: UIControl.State.normal)
            }
        }
        self.view.setNeedsLayout()
    }
    
       
    // 获取与会者列表及数据处理（排序：）
    func getAttendeeUserList() {
        CLLog("获取与会者列表")
        var isHaveSpeaker:Bool = false // 当前是否有未闭音的与会者
        
        // 与会者数组
        guard let attendeeArray = ManagerService.confService()?.haveJoinAttendeeArray as? [ConfAttendeeInConf] else { return }

        // 返回所有的与会者
        var tempAttendeeArray: [ConfAttendeeInConf] = []
        self.broadcastConfInfo = nil
        self.chairmanConfInfo = nil
        
        // 更新选看
        for attendInConf in attendeeArray {
            // 处理在会中的与会者是否有人未闭音
            if isHaveSpeaker == false,attendInConf.state == ATTENDEE_STATUS_IN_CONF {
                if !attendInConf.is_mute {
                    isHaveSpeaker = true
                }
            }
            // 选看
            if self.watchConfInfo != nil, NSString.getSipaccount(self.watchConfInfo?.number) == NSString.getSipaccount(attendInConf.number) {
                if attendInConf.state != ATTENDEE_STATUS_IN_CONF {
                    attendInConf.hasBeWatch = false
                    self.watchConfInfo = nil
                }else{
                    attendInConf.hasBeWatch = true
                }
            } else {
                attendInConf.hasBeWatch = false
            }
            // 主持人
            if attendInConf.role == .CONF_ROLE_CHAIRMAN {
                self.chairmanConfInfo = attendInConf
            }
            // 广播
            if attendInConf.isBroadcast {
                self.broadcastConfInfo = attendInConf
            }
            tempAttendeeArray.append(attendInConf)
        }
        
        //  总数组
        var newTempAttendeeArray: [ConfAttendeeInConf] = []
        //  广播
        var broadcastTempAttendeeArray: [ConfAttendeeInConf] = []
        //  选看
        var beWatchTempAttendeeArray: [ConfAttendeeInConf] = []
        //  主持人
        var chairManTempAttendeeArray: [ConfAttendeeInConf] = []
        //  在会议中的与会者
        var inConfTempAttendeeArray: [ConfAttendeeInConf] = []
        //  挂断与会者
        var haveLeaveTempAttendeeArray: [ConfAttendeeInConf] = []
        //  遍历数组处理排序问题
        for attend in tempAttendeeArray {
            // 找出自己（自己永远在数组最上层）
            if attend.isSelf || (self.mineConfInfo != nil && attend.number == self.mineConfInfo!.number) {
                attend.isSelf = true
                attend.is_open_camera = SessionManager.shared.isCameraOpen
                self.mineConfInfo = attend
                newTempAttendeeArray.insert(attend, at: 0)
            } else {
                // 2. 广播
                if attend.isBroadcast {
                    broadcastTempAttendeeArray.append(attend)
                    continue
                }
                // 3. 选看
                if attend.hasBeWatch {
                    beWatchTempAttendeeArray.append(attend)
                    continue
                }
                // 4. 主持人
                if attend.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
                    chairManTempAttendeeArray.append(attend)
                    continue
                }
                // 5. 在会与会者
                if attend.state == ATTENDEE_STATUS_IN_CONF {
                    inConfTempAttendeeArray.append(attend)
                    continue
                }
                // 6. 不在会议中的与会者 (只有自己是主席才显示)
                if mineConfInfo?.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
                    haveLeaveTempAttendeeArray.append(attend)
                }
                continue
            }
        }
        // 广播
        newTempAttendeeArray.append(contentsOf: broadcastTempAttendeeArray)
        // 选看
        newTempAttendeeArray.append(contentsOf: beWatchTempAttendeeArray)
        // 主持人
        newTempAttendeeArray.append(contentsOf: chairManTempAttendeeArray)
        // 与会者排序 根据终端号排序
        newTempAttendeeArray.append(contentsOf: inConfTempAttendeeArray.sorted { (attend1, attend2) -> Bool in
            NSString.firstCharactor(attend1.number) < NSString.firstCharactor(attend2.number)
        })
        // 不再会议中与会者 根据终端号排序
        newTempAttendeeArray.append(contentsOf: haveLeaveTempAttendeeArray.sorted { (attend1, attend2) -> Bool in
            NSString.firstCharactor(attend1.number) < NSString.firstCharactor(attend2.number)
        })
        // 如果当前全部人员闭音，处理顶部当前发音人展示
        if !isHaveSpeaker {
            speakersArray.removeAll()
            setViewUI()
        }
      
        // 处理总数组 更新页面
        if dataSource.count != 0 {
           dataSource.removeAll()
        }

        dataSource.append(contentsOf: newTempAttendeeArray)
        // 当前控制器是否显示
        self.attendCount = dataSource.count-haveLeaveTempAttendeeArray.count
        if isShowCurrentVC() {
            let nav = navigationController as? BaseNavigationController
            nav?.updateTitle(title: getMeetingTitle(count: attendCount))
        }
        
        // 刷新TableView
        tableView.reloadData()
    }
    
    // 设置顶部View当前说话人名字
    private func showTextOfSpeaker(_ speaker: ConfCtrlSpeaker) -> String {
        if speaker.dispalyname != nil && speaker.dispalyname.count > 0 {
            return speaker.dispalyname
        }
        return NSString.getSipaccount(speaker.number)
    }
    // 设置返回标题
    func getMeetingTitle(count: Int) -> String {
        return tr("与会者") + "(\(count))"
    }
}

//MARK: 底部按钮处理及点击事件处理
extension JoinUsersSVCViewController {
    // 设置底部三个按钮显示个数
    private func resetStackView() {
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.arrangedSubviews.forEach { (subView) in
            stackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        
        self.showBottomItem1Btn = UIButton()
        self.showBottomItem1Btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.showBottomItem1Btn.setTitleColor(UIColor(hexString: "#666666"), for: .normal)
        self.showBottomItem1Btn.titleLabel?.numberOfLines = 2
        self.showBottomItem1Btn.titleLabel?.textAlignment = .center
        
        self.showBottomItem2Btn = UIButton()
        self.showBottomItem2Btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.showBottomItem2Btn.setTitleColor(UIColor(hexString: "#666666"), for: .normal)
        self.showBottomItem2Btn.titleLabel?.numberOfLines = 2
        self.showBottomItem2Btn.titleLabel?.textAlignment = .center
        
        self.showBottomItem1View = UIView.init(frame: CGRect(x: 0, y: 14, width: 1, height: 22))
        self.showBottomItem1View.backgroundColor = UIColor(hexString: "#DDDDDD")
        self.showBottomItem2Btn.addSubview(showBottomItem1View)
        
        self.showBottomItem3Btn = UIButton()
        self.showBottomItem3Btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.showBottomItem3Btn.setTitleColor(UIColor(hexString: "#666666"), for: .normal)
        self.showBottomItem3Btn.titleLabel?.numberOfLines = 2
        self.showBottomItem3Btn.titleLabel?.textAlignment = .center
        
        self.showBottomItem2View = UIView.init(frame: CGRect(x: 0, y: 14, width: 1, height: 22))
        self.showBottomItem2View.backgroundColor = UIColor(hexString: "#DDDDDD")
        self.showBottomItem3Btn.addSubview(showBottomItem2View)
    }
    // 设置全体静音
    @objc func setAllMuteBtnClick() {
        if svcManager.mineConfInfo == nil {
            return
        }
        CLLog("设置全体静音")
        // 全体静音
        ManagerService.confService()?.confCtrlMuteConference(true)
    }
    // 取消全体静音
    @objc func cancelAllMuteBtnClick() {
        if svcManager.mineConfInfo == nil {
            return
        }
        CLLog("取消全体静音")
        ManagerService.confService()?.confCtrlMuteConference(false)
    }
    // 释放主持人
    @objc func releaseChairManBtnClick() {
        if svcManager.mineConfInfo == nil {
            return
        }
        CLLog("释放主持人")
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    // 申请主持人
    @objc func requestChairManBtnClick() {
        if svcManager.mineConfInfo == nil {
            return
        }
        CLLog("申请主持人")
        if (self.svcManager.currentMeetInfo?.hasChairman ?? false) {
            CLLog("会议已存在主持人")
            MBProgressHUD.showBottom(tr("会议已存在主持人，暂无法申请主持人"), icon: nil, view: self.view)
            return
        }
        self.requestOrReleaseChair()
    }
    // 举手
    @objc func raiseOrPutDownHand() {
        if svcManager.mineConfInfo == nil {
            return
        }
        if !(self.svcManager.currentMeetInfo?.hasChairman ?? false) {
            CLLog("会议无主持人，不能举手")
            MBProgressHUD.showBottom(tr("会议无主持人，不能举手"), icon: nil, view: nil)
            return
        }
        svcManager.isClickCancleRaise = true
        let isSuccess = ManagerService.confService()?.confCtrlRaiseHand(!(self.mineConfInfo?.hand_state ?? false), attendeeNumber: NSString.getSipaccount(self.mineConfInfo?.number))
        if !isSuccess! {
            if self.mineConfInfo?.hand_state == false {
                svcManager.isClickCancleRaise = false
                CLLog("举手失败")
                MBProgressHUD.showBottom(tr("举手失败"), icon: nil, view: nil)
            }
        } else {
            self.mineConfInfo?.hand_state = !(self.mineConfInfo?.hand_state ?? false)
        }
    }
}

//MARK: 手势点击事件及处理
extension JoinUsersSVCViewController {
    // 添加双击手势
    private func setupButtonDoubleTap(button: UIButton) {
        let doubleClickGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleClickGestureCallBack(gesture:)))
        doubleClickGesture.numberOfTapsRequired = 2
        doubleClickGesture.numberOfTouchesRequired = 1
        button.addGestureRecognizer(doubleClickGesture)
    }
    
    // 双击处理
    @objc private func doubleClickGestureCallBack(gesture: UITapGestureRecognizer) {
        let textVC = WhiteTextViewController.init(nibName: "WhiteTextViewController", bundle: nil)
        textVC.showText = (gesture.view as! UIButton).titleLabel!.text ?? ""
        textVC.modalPresentationStyle = .overFullScreen
        textVC.modalTransitionStyle = .crossDissolve
        ViewControllerUtil.getCurrentViewController().present(textVC, animated: true, completion: nil)
    }
}

// MARK: 通知
extension JoinUsersSVCViewController {
    // MARK: - 通知
    private func registerNotify() {
        // 发言方通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSpeakerList(notfication:)), name: NSNotification.Name(CALL_S_CONF_EVT_SPEAKER_IND), object: nil)
        // 会议信息及状态状态更新
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAttendeeUpdate(notfication:)), name: NSNotification.Name(CALL_S_CONF_EVT_INFO_AND_STATUS_UPDATE), object: nil)
        // 邀请与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdateSelectedAttendee(notfication:)), name: NSNotification.Name(UpdataInvitationAttendee), object: nil)
        // 广播指定与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notificationBroadcoatAttendee(notfication:)), name: NSNotification.Name(CALL_S_CONF_BROADCAST_ATTENDEE), object: nil)
        // 取消广播指定与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCancelBroadcoatAttendee(notfication:)), name: NSNotification.Name(CALL_S_CONF_CANCEL_BROADCAST_ATTENDEE), object: nil)
         // 全体闭音的通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationListenMute(notfication:)), name: NSNotification.Name(CALL_S_CONF_MUTE_CONF_SUCSESS), object: nil)
        // 全体取消闭音的通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUnmute(notfication:)), name: NSNotification.Name(CALL_S_CONF_UNMUTE_CONF_SUCSESS), object: nil)
        // 添加与会者
        NotificationCenter.default.addObserver(self, selector: #selector(notficationAddAttendee(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_ADD_ATTENDEE), object: nil)
        // 与会者举手
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSetHandup(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_SET_HANDUP), object: nil)
        // 释放主持人
        NotificationCenter.default.addObserver(self, selector: #selector(notficationReleaseChairman(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_RELEASE_CHAIRMAN), object: nil)
        // 申请释放主持人
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRequestChairman(notfication:)), name: NSNotification.Name(CALL_S_CONF_REQUEST_CHAIRMAN), object: nil)
    }
    
    
    // 发言人列表通知
    @objc func notificationSpeakerList(notfication: Notification) {
        guard let userInfo = notfication.userInfo as? [String: [ConfCtrlSpeaker]],let speaks = userInfo[CALL_S_CONF_EVT_SPEAKER_IND] else {
            speakersArray.removeAll()
            self.setViewUI()
            return
        }
        // 有人发言则将该数据置为0
        self.noSpeakerTimeCount = 0
        // 发言人数组
        speakersArray = speaks
        self.setViewUI()
    }
    // 与会者更新通知
    @objc func notificationAttendeeUpdate(notfication: Notification) {
        self.setInitData()
    }
    // 邀请选中与会者通知
    @objc func notificationUpdateSelectedAttendee(notfication: Notification) {
        // 添加与会者
        if SessionManager.shared.currentAttendeeArray.count > 0 {
            let atteedeeArray = NSArray.init(array: SessionManager.shared.currentAttendeeArray) as? [LdapContactInfo]
            if atteedeeArray?.count == 0 {
                return
            }
            CLLog("邀请与会者信息 - \(svcManager.getInviteAttendeesMessage(attendees: atteedeeArray ?? [LdapContactInfo()]))")
            for atteedee in atteedeeArray! {
                ManagerService.confService()?.confCtrlAddAttendee(toConfercene: [atteedee])
            }
            SessionManager.shared.currentAttendeeArray.removeAll()
        }
    }
    // 广播与会者通知
    @objc func notificationBroadcoatAttendee(notfication: Notification) {
        DispatchQueue.main.async {
            guard let userInfo =  notfication.userInfo as? [String: NSNumber], let isSucsess = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
                MBProgressHUD.showBottom(tr("广播失败"), icon: nil, view: self.view)
                return
            }
            if isSucsess {
                MBProgressHUD.showBottom(tr("广播成功"), icon: nil, view: self.view)
                self.getAttendeeUserList()
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.leftBarBtnItemClick()
                }
            }else {
                MBProgressHUD.showBottom(tr("广播失败"), icon: nil, view: self.view)
            }
        }
    }
    // 取消广播
    @objc func notificationCancelBroadcoatAttendee(notfication: Notification) {
        DispatchQueue.main.async {
            guard let userInfo =  notfication.userInfo as? [String: NSNumber], let isSucsess = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
                MBProgressHUD.showBottom(tr("取消广播失败"), icon: nil, view: self.view)
                return
            }
            if isSucsess {
                MBProgressHUD.showBottom(tr("取消广播成功"), icon: nil, view: self.view)
                self.getAttendeeUserList()
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.leftBarBtnItemClick()
                }
            } else {
                MBProgressHUD.showBottom(tr("取消广播失败"), icon: nil, view: self.view)
            }
        }
    }
    // 全体闭音
    @objc func notificationListenMute(notfication: Notification) {
        guard let userInfo =  notfication.userInfo as? [String: NSNumber], let isSucsess = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("全体静音失败"), icon: nil, view: self.view)
            return
        }
        if isSucsess {
            DispatchQueue.main.async {
                self.getAttendeeUserList()
                MBProgressHUD.showBottom(tr("已全体静音"), icon: nil, view: self.view)
            }
        }else {
            MBProgressHUD.showBottom(tr("全体静音失败"), icon: nil, view: self.view)
        }
    }
    // 取消全体闭音
    @objc func notificationUnmute(notfication: Notification) {
        guard let userInfo =  notfication.userInfo as? [String: NSNumber], let isSucsess = userInfo[ECCONF_RESULT_KEY] == 0 ? false : true else {
            MBProgressHUD.showBottom(tr("取消全体静音失败"), icon: nil, view: self.view)
            return
        }
        if isSucsess {
            DispatchQueue.main.async {
                self.getAttendeeUserList()
                MBProgressHUD.showBottom(tr("已取消全体静音"), icon: nil, view: self.view)
            }
        }else {
            MBProgressHUD.showBottom(tr("取消全体静音失败"), icon: nil, view: self.view)
        }
    }
    // 添加与会者
    @objc func notficationAddAttendee(notfication:Notification) {
        if let resultDictionary = notfication.userInfo {
            MBProgressHUD.hide(for: self.view, animated: true)
            let result = resultDictionary[CALL_S_CONF_ADD_ATTENDEE] as! Int32
            if result == 0 {
                MBProgressHUD.showBottom(tr("添加与会者成功"), icon: nil, view: self.view)
            }
        }
    }
    // 与会者举手
    @objc func notficationSetHandup(notfication:Notification) {
        if let resultDictionary = notfication.userInfo {
            MBProgressHUD.hide(for: self.view, animated: true)
            let result = resultDictionary[CALL_S_CONF_SET_HANDUP] as! NSNumber
            if result.boolValue {
            } else {
                MBProgressHUD.showBottom(tr("会议无主持人，不能举手"), icon: nil, view: self.view)
            }
        }
    }
    // 释放主持人
    @objc func notficationReleaseChairman(notfication:Notification) {
        if let resultDictionary = notfication.userInfo {
            CLLog("CONF_E_RELEASE_CHAIRMAN_RESULT - 释放主持人")
            MBProgressHUD.hide(for: self.view, animated: true)
            guard let resultCode = resultDictionary[ECCONF_RESULT_KEY] as? NSNumber  else {
                MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: nil)
                return
            }
            if resultCode == 1 {
                MBProgressHUD.showBottom(tr("主持人已释放"), icon: nil, view: nil)
                if svcManager.isPolicy {
                    watchConfInfo = nil
                    svcManager.watchConfInfo = nil
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.leftBarBtnItemClick()
                }
            }else{
                MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: nil)
            }
        }
    }
    // 申请主持人
    @objc func notificationRequestChairman(notfication:Notification) {
        if let resultDictionary = notfication.userInfo {
            MBProgressHUD.hide(for: self.view, animated: true)
            guard let resultCode = resultDictionary[ECCONF_RESULT_KEY] as? NSNumber  else {
                MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: self.view)
               return
           }
           
           if resultCode == 1 {
            CLLog("CONF_E_REQUEST_CHAIRMAN_RESULT - 申请主持人")
            MBProgressHUD.hide(for: self.view, animated: true)
            MBProgressHUD.showBottom(tr("已申请主持人"), icon: nil, view: self.view)
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.leftBarBtnItemClick()
            }
           }else{
                if self.isPWBullet == false {
                    let alertVC = AlertSingleTextFieldViewController.init(nibName: AlertSingleTextFieldViewController.vcID, bundle: nil)
                    alertVC.modalTransitionStyle = .crossDissolve
                    alertVC.modalPresentationStyle = .overFullScreen
                    alertVC.customDelegate = self
                    self.present(alertVC, animated: true) {
                        alertVC.showInputTextField.keyboardType = .numberPad
                        self.isPWBullet = true
                    }
                    return
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

// MARK: UITableViewDelegate, UITableViewDataSource
extension JoinUsersSVCViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JoinUserSVCTableViewCell.CELL_ID) as! JoinUserSVCTableViewCell
        cell.selectionStyle = .none
        cell.showVoiceBtn.isUserInteractionEnabled = false
        // 解析数据
        let confAttendInfo = self.dataSource[indexPath.row]
        //  加载数据
        cell.loadData(confAttendInfo: confAttendInfo, speakersArray: self.speakersArray)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if svcManager.mineConfInfo == nil {
            return
        }
        if self.mineConfInfo == nil {
            return
        }
        
        // 解析数据
        let confAttendInfo = self.dataSource[indexPath.row]
        self.selectedAttendInfo = confAttendInfo
        
        let popTitleVC = PopTitleNormalViewController.init(nibName:PopTitleNormalViewController.vcID, bundle: nil)
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
        
        self.present(popTitleVC, animated: true, completion: nil)
    }
    
    // cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return JoinUserSVCTableViewCell.CELL_HEIGHT
    }
    
    // header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    
    // footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // header view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.01))
    }
    
    // footer view
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.01))
    }
    
    // 会控菜单 - 自己
    fileprivate func setMyMenus(strArray: inout [String], confAttendInfo: ConfAttendeeInConf,
                                itemBlocks: inout [(Int) -> ()]) {
        strArray.append(confAttendInfo.is_mute ? tr("取消静音") : tr("静音"))
        itemBlocks.append(self.setMute(index:))
        if isSelfChairMan() { // 自己是主持人
            
            strArray.append(confAttendInfo.is_open_camera ? tr("关闭视频") : tr("打开视频"))
            itemBlocks.append(self.setCamera(index:))
            
            strArray.append(confAttendInfo.isBroadcast ? tr("取消广播") : tr("广播"))
            itemBlocks.append(self.setBroadcast(index:))
            
            if self.attendCount > 2 {
                strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                itemBlocks.append(self.setWatchAttendee(index:))
            }
            
            strArray.append(tr("释放主持人"))
            itemBlocks.append(self.requestOrReleaseChair(index:))
        } else {
            // 自己是与会者
            strArray.append(confAttendInfo.is_open_camera ? tr("关闭视频") : tr("打开视频"))
            itemBlocks.append(self.setCamera(index:))
            
            // 大会模式下不能有选看
            if svcManager.isPolicy == false && self.attendCount > 2 {
                strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                itemBlocks.append(self.setWatchAttendee(index:))
            }
            // 当前会议有主席
            if (self.svcManager.currentMeetInfo?.hasChairman ?? false) {
                strArray.append(confAttendInfo.hand_state ? tr("手放下") : tr("举手"))
                itemBlocks.append(self.setRaiseHandAndDownHand(index:))
            }
        }
    }
    
    // 会控菜单 - 其他人
    fileprivate func setOtherMenus(strArray: inout [String], confAttendInfo: ConfAttendeeInConf,
                                   itemBlocks: inout [(Int) -> ()], _ popTitleVC: PopTitleNormalViewController) {
        // 是否视频会议
        if isSelfChairMan() {
            // 自己是主持人
            strArray.append(confAttendInfo.is_mute ? tr("取消静音") : tr("静音"))
            itemBlocks.append(self.setMute(index:))
            
            strArray.append(confAttendInfo.isBroadcast ? tr("取消广播") : tr("广播"))
            itemBlocks.append(self.setBroadcast(index:))
            
            if self.attendCount > 2 {
                strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                itemBlocks.append(self.setWatchAttendee(index:))
            }
            
            if confAttendInfo.hand_state, !(ManagerService.call()?.isSMC3 ?? false) {
                strArray.append(tr("手放下"))
                itemBlocks.append(self.downHand(index:))
            }
            
            popTitleVC.isShowDestroyColor = true
            popTitleVC.isShowDestroyColor2 = true
            strArray.append(tr("挂断"))
            itemBlocks.append(self.setHangUp(index:))
            strArray.append(tr("移除"))
            itemBlocks.append(self.deleteAttendee(index:))
        } else {
            // 自己是与会者
            // 大会模式下不能有选看
            if svcManager.isPolicy == false && self.attendCount > 2 {
                strArray.append(confAttendInfo.hasBeWatch ? tr("取消选看") : tr("选看"))
                itemBlocks.append(self.setWatchAttendee(index:))
            }
        }
    }
}


// MARK: PopTitleNormalViewDelegate, AlertSingleTextFieldViewDelegate, TextTitleViewDelegate
extension JoinUsersSVCViewController: PopTitleNormalViewDelegate, AlertSingleTextFieldViewDelegate, TextTitleViewDelegate {
    // MARK: - PopTitleNormalViewDelegate
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController) {
        
    }
    
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath) {
        viewVC.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - AlertSingleTextFieldViewDelegate
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
        // 先传“”空值，如是密码会议则申请失败，失败输入密码的弹框，如果输入密码是空点击了确认，则传1让其申请失败
        let password = viewVC.showInputTextField.text?.count == 0 ? "" : viewVC.showInputTextField.text
        let isSuccess = ManagerService.confService()?.confCtrlRequestChairman(password, number: self.mineConfInfo?.number) ?? false
        if !isSuccess {
            MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: nil)
        }
    }
    
    // MARK: - TextTitleViewDelegate
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        viewVC.showTitleLabel.text = tr("会议将无主持人，是否释放")
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
    }
    
    // left btn click
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        
    }
    
    // right btn click
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        CLLog("用户选择释放主持人")
        MBProgressHUD.showMessage("", to: self.view)
        // 释放主持人
        self.requestOrReleaseChair()
    }
}

// MARK: - Actions
extension JoinUsersSVCViewController {
    // 申请释放主持人权限
    func requestOrReleaseChair(index: Int = 0) {
        if isSelfChairMan() {
           // 释放主持人
           let isSuccess = ManagerService.confService()?.confCtrlReleaseChairman(self.mineConfInfo?.number)
            if !isSuccess! { // 失败
                MBProgressHUD.hide(for: self.view, animated: true)
                MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: self.view)
                CLLog("释放主持人失败")
            }
        } else {
            // 先传“”空值，如是密码会议则申请失败，失败输入密码的弹框，如果输入密码是空点击了确认，则传1让其申请失败

            if isPWBullet == false {
                var passWord: String = ""
                // SMC3.0
                if (ManagerService.call()?.isSMC3 ?? false),self.svcManager.currentMeetInfo?.scheduleUserAccount == ManagerService.call()?.ldapContactInfo.userName,let vmrId = (UserDefaults.standard.value(forKey: VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY) == nil) ? "" : UserDefaults.standard.value(forKey: VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY),vmrId as? String == (self.svcManager.currentMeetInfo?.accessNumber ?? "") {
                    passWord = self.svcManager.currentMeetInfo?.chairmanPwd ?? ""
                }
                // SMC2.0
                if !(ManagerService.call()?.isSMC3 ?? false),SessionManager.shared.isMeetingVMR, SessionManager.shared.cloudMeetInfo.accessNumber == ManagerService.confService()?.vmrBaseInfo.accessNumber {
                    passWord = SessionManager.shared.cloudMeetInfo.chairmanPwd
                }
                let isSuccess = ManagerService.confService()?.confCtrlRequestChairman(passWord, number: self.mineConfInfo?.participant_id) ?? false
                if !isSuccess {
                    MBProgressHUD.showBottom(tr("申请主持人失败"), icon: nil, view: self.view)
                }
                CLLog("申请主持人\(isSuccess ? "成功" : "失败")")
                return
            }
            let alertVC = AlertSingleTextFieldViewController.init(nibName: "AlertSingleTextFieldViewController", bundle: nil)
            alertVC.modalTransitionStyle = .crossDissolve
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.customDelegate = self
            self.present(alertVC, animated: true) {
                alertVC.showInputTextField.keyboardType = .numberPad
            }
        }
    }
    
    // 设置静音
    func setMute(index: Int) {
        guard let confAttendInfo = self.selectedAttendInfo else { return }
        let isSuccess = ManagerService.confService()?.confCtrlMuteAttendee(confAttendInfo.participant_id, isMute: !confAttendInfo.is_mute) ?? false
        if isSuccess {
            SessionManager.shared.isMicrophoneOpen = !confAttendInfo.is_mute
            NotificationCenter.default.post(name: NSNotification.Name.init(MineMicrophoneStateChange), object: nil)
        }
        CLLog("设置静音\(isSuccess ? "成功" : "失败")")
    }
    
    // 设置摄像头
    func setCamera(index: Int) {
        CLLog("setCamera")
        guard let confAttendInfo = self.selectedAttendInfo else {
            return
        }
        let isSuccess = ManagerService.call()?.switchCameraOpen(!confAttendInfo.is_open_camera, callId: UInt32(self.meettingInfo?.callId ?? 0)) ?? false
        if isSuccess {
            SessionManager.shared.isCameraOpen = !confAttendInfo.is_open_camera
            NotificationCenter.default.post(name: NSNotification.Name.init(MineCameraStateChange), object: nil)
        }
        CLLog("设置摄像头\(isSuccess ? "成功" : "失败")")
        self.getAttendeeUserList()
    }
    
    // 设置广播
    func setBroadcast(index: Int) {
        CLLog("setBroadcast")
        guard let confAttendInfo = self.selectedAttendInfo else { return }
        if confAttendInfo.is_audio { // 语音入会，不能广播
            MBProgressHUD.showBottom(tr("语音入会，不能广播"), icon: nil, view: self.view)
            return
        }
        if confAttendInfo.isBroadcast {  //正在被广播
            ManagerService.confService()?.broadcastAttendee(confAttendInfo.number, isBoardcast: false)
        } else {
            ManagerService.confService()?.broadcastAttendee(confAttendInfo.number, isBoardcast: true)
        }
    }
    
    // 设置选看
    func setWatchAttendee(index: Int) {
        CLLog("setWatchAttendee")
        guard let confAttendInfo = self.selectedAttendInfo else { return }
        let broadcastArray = self.dataSource.filter{ $0.isBroadcast }
        if !broadcastArray.isEmpty {
            MBProgressHUD.showBottom(confAttendInfo.hasBeWatch ? tr("正在广播中, 暂时不能取消选看") : tr("正在广播中, 暂时不能选看"), icon: nil, view: self.view)
            return
        }
        if confAttendInfo.is_audio {
            MBProgressHUD.showBottom(tr("语音入会，不能选看"), icon: nil, view: self.view)
            return
        }
        
        if confAttendInfo.hasBeWatch { // 正在被选看
            // 选看和取消选看成功回调通知 BeWatchSuccessAttendees:选看的与会者，为空时为取消选看
            NotificationCenter.default.post(name: NSNotification.Name.init(BeWatchSuccessAttendees), object: nil, userInfo: nil)
            UIView.animate(withDuration: 1.0) {
            } completion: { (isFinish) in
                self.leftBarBtnItemClick()
            }
        }else { // 没有被选看
            // 选看和取消选看成功回调通知 BeWatchSuccessAttendees:选看的与会者，为空时为取消选看
            NotificationCenter.default.post(name: NSNotification.Name.init(BeWatchSuccessAttendees), object: self.selectedAttendInfo, userInfo: nil)
            UIView.animate(withDuration: 1.0) {
            } completion: { (isFinish) in
                self.leftBarBtnItemClick()
            }
        }
    }
    
    
    
    // 设置挂断
    func setHangUp(index: Int) {
        guard let confAttendInfo = self.selectedAttendInfo else { return }
        let isSuccess = ManagerService.confService()?.confCtrlHangUpAttendee(confAttendInfo.number) ?? false
        CLLog("设置挂断\(isSuccess ? "成功" : "失败")")
    }
    
    // 设置举手和手放下
    func setRaiseHandAndDownHand(index: Int) {
        self.raiseOrPutDownHand()
    }
    
    // 申请主持人
    func setRequestChairMan(index:Int) {
        self.requestChairManBtnClick()
    }
    
    //  设置手放下
    func downHand(index: Int) {
        CLLog("downHand")
        guard let confAttendInfo = self.selectedAttendInfo else { return }
        if confAttendInfo.hand_state == true {
            // 点击了取消举手
            svcManager.isClickCancleRaise = true
            let isSuccess = ManagerService.confService()?.confCtrlRaiseHand(!(confAttendInfo.hand_state), attendeeNumber: confAttendInfo.number) ?? false
            CLLog("手放下\(isSuccess ? "成功" : "失败")")
            if !isSuccess {
                if confAttendInfo.hand_state == false {
                    svcManager.isClickCancleRaise = false // 取消举手失败置为false
                    MBProgressHUD.showBottom(tr("取消举手失败"), icon: nil, view: nil)
                }
            } else {
                confAttendInfo.hand_state = !confAttendInfo.hand_state
            }
        }
    }
    
    // 重新邀请
    func inviteAttendee(index: Int) {
        guard let confAttendInfo = self.selectedAttendInfo else { return }
        let isSuccess = ManagerService.confService()?.confCtrlRecallAttendee(confAttendInfo.number) ?? false
        CLLog("重新邀请\(isSuccess ? "成功" : "失败")")
    }
    
    // 删除与会者
    func deleteAttendee(index: Int) {
        guard let confAttendInfo = self.selectedAttendInfo else { return }
        let isSuccess = ManagerService.confService()?.confCtrlRemoveAttendee(confAttendInfo.number) ?? false
        CLLog("删除与会者\(isSuccess ? "成功" : "失败")")
    }
}

// MARK: 顶部导航栏两个按钮点击事件
extension JoinUsersSVCViewController {
    // left Bar Btn Item Click （点击返回后移除所有监听）
    @objc func leftBarBtnItemClick() {
        APP_DELEGATE.rotateDirection = .portrait
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    // right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        CLLog("添加与会者")
        let storyboard = UIStoryboard.init(name: "SearchAttendeeViewController", bundle: nil)
        let searchAttendee = storyboard.instantiateViewController(withIdentifier: "SearchAttendeeView") as! SearchAttendeeViewController
        searchAttendee.meetingCofArr = self.dataSource
        self.navigationController?.pushViewController(searchAttendee, animated: true)
    }
    
    //分享按钮
    @objc private func rightShareBarBtnItemClick(sender _: UIBarButtonItem) {
        share.share(meetingInfo: self.meettingInfo, from: self ,isMeeting: true)
    }
}

// MARK: 页面的一些判断
extension JoinUsersSVCViewController {
    // 判断当前屏幕是否是当前控制器
    func isShowCurrentVC() -> Bool {
        let curretVC = ViewControllerUtil.getCurrentViewController()
        if curretVC is JoinUsersSVCViewController {
            return true
        }
        return false
    }
    // MARK: - 会控菜单
    fileprivate func isSelfChairMan() -> Bool {
        guard let mineConfInfo = self.mineConfInfo else { return false }
        return mineConfInfo.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
    }
    // 是否显示举手
    func canRaiseHand() -> Bool {
        return !(ManagerService.call()?.isSMC3 ?? false)
    }
}


// MARK: UITextFieldDelegate
extension JoinUsersSVCViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        return nowString.count <= 6
    }
}

