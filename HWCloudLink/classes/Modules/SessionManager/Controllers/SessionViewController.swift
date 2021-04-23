//
// SessionViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class SessionViewController: UITableViewController {

    @IBOutlet weak var addBarItem: UIBarButtonItem!
    private var isJoining: Bool = false //是否是加入会议，回调改为true
    // lazy
    fileprivate var menuView: YCMenuView!
    
    private var abnormalTimer: Timer?
    
    fileprivate var emptyDataSource = [[DICT_TITLE: tr("发起会议"),
                       DICT_SUB_TITLE: tr("立即开启会议并直接邀请与会者"),
                       DICT_IMAGE_PATH: "create_meeting"],
                       
                       [DICT_TITLE: tr("加入会议"),
                       DICT_SUB_TITLE: tr("输入会议ID或会议室ID加入会议"),
                       DICT_IMAGE_PATH: "join_meeting",],
                       
                       [DICT_TITLE: tr("预约会议"),
                       DICT_SUB_TITLE: tr("预约会议并通知与会者"),
                       DICT_IMAGE_PATH: "prev_meeting_room",],
                       
                       [DICT_TITLE: tr("我的会议"),
                       DICT_SUB_TITLE: tr("查询日程或加入您的会议"),
                       DICT_IMAGE_PATH: "mymeeting",]
    ]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CLLog("viewWillAppear")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        UIApplication.shared.isStatusBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CLLog("viewDidAppear")
        // 重新设置宽高 防止横屏进入宽高是反的的
        SCREEN_WIDTH = UIScreen.main.bounds.size.width
        SCREEN_HEIGHT = UIScreen.main.bounds.size.height
        
        AppDelegate.isInToSession = true
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        CLLog("viewDidLoad")
        // 设置摄像头和麦克风成灰色
        UserDefaults.standard.set(false, forKey: DICT_SAVE_MICROPHONE_IS_ON)
        UserDefaults.standard.set(false, forKey: DICT_SAVE_VIDEO_IS_ON)
        
        TimezoneManger.shared.getTimezoneList()
        
        
        
        /// 申请系统权限
        CCPAuthorization.album.mediaPlayerApply()
        // 麦克风权限
        CCPAuthorization.microphone.apply()
        
        // set navigation
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
        // table view
        self.tableView.register(UINib.init(nibName: TableImageTextNextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageTextNextCell.CELL_ID)
        self.tableView.register(TableHeaderFooterTextCell.classForCoder(), forHeaderFooterViewReuseIdentifier: TableHeaderFooterTextCell.CELL_ID)
        // 去分割线
        self.tableView.separatorStyle = .none
        //加入会议请求失败
        NotificationCenter.default.addObserver(self, selector:#selector(notifcationSdkJoinFail), name: NSNotification.Name.init(rawValue: "JOINCONFFAIL"), object: nil)
        // 来电通知
        NotificationCenter.default.addObserver(self, selector:#selector(notifcationSdkComingCall), name: NSNotification.Name.init(rawValue: CALL_S_COMING_CALL_NOTIFY), object: nil)
        // 接收广播，创普通会成功。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationConfCreateSuccess), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_BOOK_CONF_RESULT), object: nil)
        //会议连接成功。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationJoinConfResult), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_JOIN_CONF_RESULT), object: nil)
        //xjc销毁通知，1，加入会议会议id不对或者其他异常出现 。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallDestory), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_CALL_DESTROY), object: nil)
       //通话建立的通知，用来获取 callinfo 信息。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallConnected), name: NSNotification.Name.init(rawValue: CONF_S_CALL_EVT_CONF_CONNECTED), object: nil)
        // 会话修改完成通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallModify), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_MODIFY), object: nil)
        // 大会模式
        NotificationCenter.default.addObserver(self, selector: #selector(notficationSvcWatchPolicy(notfication:)), name: NSNotification.Name.init(CALL_S_CONF_EVT_SVC_WATCH_POLICY_IND), object: nil)
        //会议结束
        NotificationCenter.default.addObserver(self, selector: #selector(notificationEndCall), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_ENDED), object: nil)
        
        //这两个通知是在登录状态下通过链接入会的通知
        NotificationCenter.default.addObserver(self, selector: #selector(loginStatusLinkJoinMeetingSuccess(noti:)), name: NSNotification.Name(LOGIN_STATUS_LINK_JOINMEETING_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginStatusLinkJoinMeetingError), name: NSNotification.Name(LOGIN_STATUS_LINK_JOINMEETING_ERROR), object: nil)
        // language change
        NotificationCenter.default.addObserver(self, selector: #selector(languageChange(notfic:)), name: NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE), object: nil)
        /*
         走完登录，在此处做一个判断，是不是链接拉起来的app，
         1：app本地存储了账号密码，
         2：不是出于活跃状态，
         3：是通过链接拉起app，此时 isNickJoin == true，登录成功
         满足以上三个条件，走这个判断方法
         */
        let manager = NickJionMeetingManager.manager
        if manager.isNickJoin == true {
            manager.linkJoinMeet(nickName: "")
        }
        
        // 密码有效期提示
        HWLoginInfoManager.checkPasswordExpireShowToast(view: nil)
    }
    
    @objc func languageChange(notfic:Notification) {
        emptyDataSource = [[DICT_TITLE: tr("发起会议"),
                           DICT_SUB_TITLE: tr("立即开启会议并直接邀请与会者"),
                           DICT_IMAGE_PATH: "create_meeting"],
                           
                           [DICT_TITLE: tr("加入会议"),
                           DICT_SUB_TITLE: tr("输入会议ID或会议室ID加入会议"),
                           DICT_IMAGE_PATH: "join_meeting",],
                           
                           [DICT_TITLE: tr("预约会议"),
                           DICT_SUB_TITLE: tr("预约会议并通知与会者"),
                           DICT_IMAGE_PATH: "prev_meeting_room",],
                           
                           [DICT_TITLE: tr("我的会议"),
                           DICT_SUB_TITLE: tr("查询日程或加入您的会议"),
                           DICT_IMAGE_PATH: "mymeeting",]
        ]
        self.tableView.reloadData()
        
        TimezoneManger.shared.getTimezoneList(true)
    }
    @objc func notifcationSdkJoinFail(){
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)

        }
    }
    // MARK: - 链接入会--接收成功通知
    @objc func loginStatusLinkJoinMeetingSuccess(noti:Notification) {
        if let dict = noti.userInfo as? [String:Any] , let accessNum = dict["accessCode"] as? String {
            if accessNum.count > 0  {
                let confPwd = dict["confPwd"] as? String
                let number = ManagerService.call()?.terminal
                let result = ManagerService.confService()?.joinConference(withConfId: nil, accessNumber: accessNum, confPassWord: confPwd, joinNumber: number, isVideoJoin: true  ) //isVideoJoin = true  ； tup 确定的，不管smc 生成音频还是视频，此处都是视频来处理
                CLLog("登录状态下链接入会：result:\(String(describing: result)),accessNum:\(NSString.encryptNumber(with: accessNum) ?? "")===number:\(NSString.encryptNumber(with: number) ?? "")")
                DispatchQueue.main.async {
                    MBProgressHUD.hide()
                    MBProgressHUD.showMessage(tr("正在加入会议") + "...")
                }
            }
        } else {
            CLLog("登录状态下链接入会失败:\(String(describing: noti.userInfo as? [String:Any]))")
            DispatchQueue.main.async {
                MBProgressHUD.hide()
                MBProgressHUD.showBottom("入会失败", icon: nil, view:nil)
            }
        }
    }
    // MARK: - 链接入会--接收失败通知
    @objc func loginStatusLinkJoinMeetingError(){
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            MBProgressHUD.showBottom("入会失败", icon: nil, view: nil)
        }
        
    }
    // MARK:  发起会议yes ---(预约会议) - 回调通知
    @objc func notificationConfCreateSuccess(notification: Notification) {
        CLLog("发起会议---(预约会议) - 回调通知 notification.userInfo = \(notification.userInfo ?? ["nil": "nil"])")
        let text = SessionManager.shared.isBespeak ? "预约会议" : "创建会议"    // 此处不需要翻译
        SessionManager.shared.isSelfPlayConf = !SessionManager.shared.isBespeak
      
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            if notification.userInfo != nil {
               let num = notification.userInfo![ECCONF_RESULT_KEY] as! String
                 if num == "1" { //返回 1  表示预约成功
                    MBProgressHUD.showBottom("\(tr(text)) "+tr("成功"), icon: nil, view: nil)
                    if ManagerService.call()?.isSMC3 != true && SessionManager.shared.isBespeak {
                        UserDefaults.standard.setValue("1", forKey: "YUYUELEHUIYI")
                    }
                    
                } else {  // 其余返回失败
                    self.dealJoinMeetingErrorWithCode(errorCode: num, text: text)
                }
            }
            SessionManager.shared.isBespeak = false
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // fix网络差的情况下HUD无法消失
                for subView in CLWindow?.subviews ?? [UIView]() {
                    if subView is MBProgressHUD {
                        subView.removeFromSuperview()
                    }
                }
            }
            */
        }
    }
    
    private func isSMC2() -> Bool {
        return !(ManagerService.call()?.isSMC3 ?? false)
    }
    
    // MARK: 发起会议 --》 连接会议回调通知
    @objc func notificationJoinConfResult(notification: Notification) {
        CLLog("##3.连接会议回调通知")
        MBProgressHUD.hide()
        // 停止异常入会定时器
        stopAbnormalTimer()
        // 销毁定时器
        NickJionMeetingManager.manager.stopAbnormalTimer()
        guard let resultInfo = notification.userInfo ,
              let _ = resultInfo["CONF_E_CONNECT"] as? ConfBaseInfo,
              let _ = resultInfo["JONIN_MEETING_RESULT_KEY"] as? NSNumber
            else  {
            MBProgressHUD.showBottom(tr("会议ID或密码不正确"), icon: nil, view: nil)
            return
        }

        // 判断会议信息
        guard let meetInfo = ManagerService.confService()?.currentConfBaseInfo else {
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
            return
        }
        CLLog(" 开始加入会议")
        if isJoining { //如果是加入会议，此时需要把isjoining 置位false ，因为会议结束的时候也会收到会议结束的通知，
            isJoining = false
        }
        // 进入会场
        let callInfo = ManagerService.call()?.currentCallInfo
        let cloudInfo =  SessionManager.shared.cloudMeetInfo
//        let userInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
        meetInfo.scheduleUserName = ""
        SessionManager.shared.currentCallId = UInt32(meetInfo.callId)
        meetInfo.mediaType = callInfo?.stateInfo.callType == CALL_VIDEO ? CONF_MEDIATYPE_VIDEO : CONF_MEDIATYPE_VOICE
        CLLog("==========会议类型mediaType:\(meetInfo.mediaType) 【0:voice，1:video】")
        meetInfo.confSubject = SessionManager.shared.isMeetingVMR ? cloudInfo.confSubject : ""
        meetInfo.accessNumber = SessionManager.shared.isMeetingVMR ? cloudInfo.accessNumber : (callInfo != nil ? callInfo?.telNumTel : "000 000")
        let numberArray = NSString.getArraySplitChar(meetInfo.accessNumber, componentsSeparatedBy: "*") as? [String]
        if numberArray != nil {
            meetInfo.accessNumber = numberArray?[0]
            if numberArray!.count > 1 {
                meetInfo.generalPwd = numberArray?[1]
            }
        }

        meetInfo.isConf = true
        meetInfo.isImmediately = true

        CLLog("连接会议回调 - ECONF_E_CONNECT_KEY \(meetInfo.mediaType)")
        if let currentCallInfo = callInfo {
            var sessionType = SessionType.voiceMeeting
            CLLog("##4.跳转页面 isSVC[\(currentCallInfo.isSvcCall)]")
            if meetInfo.mediaType == CONF_MEDIATYPE_VIDEO {
                sessionType = currentCallInfo.isSvcCall ? .svcMeeting : .avcMeeting
            }
            CLLog("========入会sessionType:\(sessionType) ===:mediaType:\(meetInfo.mediaType)")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { // 延迟0.5秒跳转
                SessionManager.shared.jumpConfMeetVC(sessionType: sessionType, meetInfo: meetInfo, animated: true)
            }
        } else {
            CLLog("callInfo is nil")
        }
    }
    
    // MARK: 通话信息修改通知
    @objc func notificationCallModify(notification: Notification) {
        CLLog("##2.会议信息修改回调通知")
        // 判断call 信息
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
            else {
            CLLog("通话信息修改失败")
            return
        }
        ManagerService.call()?.currentCallInfo = callInfo
        CLLog("========isSvc:\(callInfo) ===:callType:\(callInfo.stateInfo.callType)")
    }
    
    // MARK: 进入大会模式通知
    @objc func notficationSvcWatchPolicy(notfication: Notification) {
        CLLog("Has entered conference mode")
        SessionManager.shared.isPolicy = true
        NotificationCenter.default.post(name: NSNotification.Name.init("MeetingEnterPolicy"), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            MBProgressHUD.showBottom(tr("进入大会模式，当前不支持自由选看"), icon: nil, view: nil)
        }
    }
    
    // MARK: call connected回调通知
    @objc func notificationCallConnected(notification: Notification) {
        CLLog("##1.通话已建立通知")
        // 判断call 信息
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
            else {
            CLLog("notificationCallConnected 加入会议失败")
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)
            return
        }
        CLLog("notificationCallConnected 加入会议成功")
        CLLog("会议类型：callType:\(callInfo.stateInfo.callType) 【0:audio,1:video】")

        ManagerService.call()?.currentCallInfo = callInfo
        // 保存VMR会议信息
        if SessionManager.shared.isMeetingVMR {
            let callNum = callInfo.telNumTel
            let numArray:[String] = callNum?.components(separatedBy: "*") ?? []
            if (ManagerService.call()?.isSMC3 ?? false) {
                if numArray.count > 0 {
                    UserDefaults.standard.setValue(numArray[0], forKey: VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY)
                }
                CLLog("smc3.0 vmr CallID:\(numArray[0])")
            }
        }
        //防止加入会议时摄像头是开着
        let isOpen = UserDefaults.standard.bool(forKey: CurrentUserCameraStatus)
        ManagerService.call()?.switchCameraOpen(isOpen, callId: callInfo.stateInfo.callId)
        SessionManager.shared.isCameraOpen = isOpen
        ManagerService.call()?.muteMic(true, callId: UInt32(callInfo.stateInfo.callId))
        if !SessionManager.shared.isCurrentMeeting {
            // 非会议中启动异常入会定时器, 如果在20S内没有会控回调过来, 结束会议
            startAbnormalTimer()
        }
    }
    // 呼叫结束
    @objc func notificationEndCall(notification: Notification) {
        stopAbnormalTimer()
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            MBProgressHUD.hide()
        }
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo else {
            CLLog("呼叫信息不正确")
            return
        }
        guard callInfo.isFocus else {
            if isJoining && callInfo.serverConfId == nil {
                CLLog("当前是加入会议，需要提示")
                isJoining = false
                //xjc,2021-1-11,通过会议id判断，如果id为空，证明此会议会议未开始或不存在
//                MBProgressHUD.showBottomOnRootVC(with: tr("会议未开始或不存在"), icon: nil, view: tableView)
                MBProgressHUD.showBottom(tr("会议未开始或不存在"), icon: nil, view: tableView)
                return
            } else {
                CLLog("当前呼叫为点呼, 不提示")
                return
            }
        }
        if reasonCodeIsEqualErrorType(reasonCode: callInfo.stateInfo.reasonCode, type: TSDK_E_CALL_ERR_REASON_CODE_NOTFOUND.rawValue) {
            MBProgressHUD.showBottom(tr("会议未开始或不存在"), icon: nil, view: nil)
        } else if reasonCodeIsEqualErrorType(reasonCode: callInfo.stateInfo.reasonCode, type: TSDK_E_CALL_ERR_UNKNOWN.rawValue) {
            MBProgressHUD.showBottom(tr("会议未开始或不存在"), icon: nil, view: nil)
        }
        
        if SessionManager.shared.meetingMainVC?.isShowInWindow ?? false {
            CLLog("dismiss")
            SessionManager.shared.meetingMainVC?.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: call 销毁通知
    @objc func notificationCallDestory(notification: Notification) {
        CLLog("会议销毁通知")
        stopAbnormalTimer()
        MBProgressHUD.hide()
        isJoining = false
        UserDefaults.standard.setValue(false, forKey: "aux_rec")
        SessionManager.shared.isCurrentMeeting = false
    }
    
    //MARK: - naviBar 搜索 方法
    @IBAction func searchBarItemClick(_ sender: UIBarButtonItem) {
        let companySearchViewVC = CompanySearchViewController()
        companySearchViewVC.hidesBottomBarWhenPushed = true
        companySearchViewVC.searchType = .localContact
        self.navigationController?.pushViewController(companySearchViewVC, animated: true)
    }
    //MARK: - naviBar 添加 方法
    @IBAction func addBarItemClick(_ sender: UIBarButtonItem) {
        let action1 = YCMenuAction.init(title: tr("发起会议"), image: nil) { [weak self] (sender) in
            guard let self = self else {return}
            
            // chenfan：断网后的样式
            if WelcomeViewController.checkNetworkWithNoNetworkAlert() { return }
            
            CLLog("action1")
            if SuspendTool.isMeeting() {
                SessionManager.showMeetingWarning()
                return
            }
            //xiejc 2021-01-05 发起会议，2.0 和 3.0 区分
            if  ManagerService.call()?.isSMC3 == true {
                let storyboard = UIStoryboard.init(name: "CreatMeetingThreeVersionViewController", bundle: nil)
                let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreatMeetingThreeVersionViewController") as! CreatMeetingThreeVersionViewController
                creatMeetingVC.hidesBottomBarWhenPushed = true
     
                self.navigationController?.pushViewController(creatMeetingVC, animated: true)
            } else {
                let storyboard = UIStoryboard.init(name: "CreateMeetingViewController", bundle: nil)
                let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreateMeetingView") as! CreateMeetingViewController
                creatMeetingVC.hidesBottomBarWhenPushed = true
     
                self.navigationController?.pushViewController(creatMeetingVC, animated: true)
            }
        }
        let action2 = YCMenuAction.init(title: tr("添加联系人"), image: nil) { [weak self] (sender) in
            guard let self = self else {return}
            CLLog("action2")
            let addLocalContactVC = AddLocalContactViewController()
            addLocalContactVC.operationType = .addContact
            addLocalContactVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addLocalContactVC, animated: true)
        }
        
        let menu = YCMenuView.menu(with: [action1!, action2!], width: 150.0, relyonView: self.addBarItem)
        
        // config
        menu?.backgroundColor = UIColor.white
        menu?.textAlignment = .center
        menu?.separatorColor = UIColor.colorWithSystem(lightColor: COLOR_SEPARATOR_LINE, darkColor: COLOR_GAY)
        menu?.maxDisplayCount = 20
        menu?.offset = 0
        menu?.textColor = COLOR_DARK_GAY
        menu?.textFont = UIFont.systemFont(ofSize: 16.0)
        menu?.menuCellHeight = 50.0
        menu?.dismissOnselected = true
        menu?.dismissOnTouchOutside = true
        menu?.show()
        self.menuView = menu
    }
    deinit {
        CLLog("SessionViewController deinit")
        NotificationCenter.default.removeObserver(self)
    }
}
//MARK: - tableview 代理方法
extension SessionViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableImageTextNextCell.CELL_HEIGHT
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.emptyDataSource.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell = tableView.dequeueReusableCell(withIdentifier: TableImageTextNextCell.CELL_ID) as! TableImageTextNextCell
        let dataDict = self.emptyDataSource[indexPath.row]
        menuCell.showImageView.image = UIImage.init(named: dataDict[DICT_IMAGE_PATH]!)
        menuCell.showTitleLabel.text = dataDict[DICT_TITLE]
        menuCell.showTitleLabel.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
        menuCell.showSubTitleLabel.text = dataDict[DICT_SUB_TITLE]
        menuCell.showSubTitleLabel.textColor = UIColor(hexString: "#999999")
        menuCell.backgroundColor = .clear
        return menuCell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {// 发起会议
            self.createMeetingViewClick()
        } else if indexPath.row == 1 {// 加入会议
            self.joinMeetingViewClick()
        } else if indexPath.row == 2 {// 预约会议
            self.prevMeetingViewClick()
        } else if indexPath.row == 3 {// 我的会议
            self.mineMeetingViewClick()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 98)
//        let isConfTipsLabel = UILabel.init()//和乐鹏确定此提示一直显示
//        isConfTipsLabel.frame = CGRect(x: 20, y: headerView.height - 34, width: SCREEN_WIDTH - 64, height: 18)
//        isConfTipsLabel.text = tr("暂无会议，您可以：")
//        isConfTipsLabel.textColor = UIColor(hexString: "#999999")
//        isConfTipsLabel.font = UIFont.systemFont(ofSize: 12)
//        headerView.addSubview(isConfTipsLabel)
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 98
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
//MARK: - 发起会议---加入会议----预约会议----我的会议---虚拟会议
extension SessionViewController {
    
    // 发起会议
    @objc func createMeetingViewClick() {
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        
//        let vc = HWCreateMeetingController.init()
//        self.navigationController?.pushViewController(vc, animated: true)
//        return
        
        if  ManagerService.call()?.isSMC3 == true {
            let storyboard = UIStoryboard.init(name: "CreatMeetingThreeVersionViewController", bundle: nil)
            let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreatMeetingThreeVersionViewController") as! CreatMeetingThreeVersionViewController
            creatMeetingVC.hidesBottomBarWhenPushed = true
 
            self.navigationController?.pushViewController(creatMeetingVC, animated: true)
        } else {
            let storyboard = UIStoryboard.init(name: "CreateMeetingViewController", bundle: nil)
            let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreateMeetingView") as! CreateMeetingViewController
            creatMeetingVC.hidesBottomBarWhenPushed = true
 
            self.navigationController?.pushViewController(creatMeetingVC, animated: true)
        }
        
        
        
    }
    // 加入会议
    @objc func joinMeetingViewClick() {
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        
        let storyboard = UIStoryboard.init(name: "JoinMeetingViewController", bundle: nil)
        let joinMeetingViewVC = storyboard.instantiateViewController(withIdentifier: "JoinMeetingView") as! JoinMeetingViewController
        joinMeetingViewVC.passJoinMeetBlock = { (isJion: Bool) in
            self.isJoining = isJion
        }
        joinMeetingViewVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(joinMeetingViewVC, animated: true)
    }
    //预约会议
    @objc func prevMeetingViewClick() {
        let storyboard = UIStoryboard.init(name: "PreMeetingViewController", bundle: nil)
        let prevMeetingViewVC = storyboard.instantiateViewController(withIdentifier: "PreMeetingView") as! PreMeetingViewController
        prevMeetingViewVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(prevMeetingViewVC, animated: true)
    }
    //我的会议
    @objc func mineMeetingViewClick() {
//          if SuspendTool.isMeeting() {
//              SessionManager.showMeetingWarning()
//              return
//          }
          let myMeetVC = MyMeetingListViewController.init()
          myMeetVC.hidesBottomBarWhenPushed = true
          navigationController?.pushViewController(myMeetVC, animated: true)
      }
}

//MARK: - 加入会议
extension SessionViewController {
    static func sessionJoinMeeting(confId: String,accessNumber:String,confPwd:String,joinNum:String,isVideJoin:Bool ){
        //        直接加入会议
        // 实际： 先获取会议详情 -- 已和SDK确认，没有会议详情接口
//        let number = ManagerService.call()?.terminal
        // 进入会场
        // 模拟数据
        let callInfo = CallInfo.init()
//        let serverConfId = accessNumber // self.meetingIDTextField.text!
        //判断是否加9000 ,  3.0状态 不能添加90000，不是3.0版本再添加9000
//        if !(ManagerService.call()?.isSMC3 ?? false) {
//            // 外部认证用户 为2时 是ad账号登录，会议id不做处理，其余要做处理(ad账号只有2.0才有)
//            if let authType = CommonUtils.getUserDefaultValue(withKey: CALL_EVT_AUTH_TYPE_KEY) as? String, authType != "2" {
//                if !serverConfId.hasPrefix("9000") {
//                    serverConfId = "9000" + serverConfId
//                }
//            }
//        }
       
        callInfo.serverConfId = accessNumber
       let result =  ManagerService.confService()?.joinConference(withConfId: nil, accessNumber: callInfo.serverConfId, confPassWord: confPwd, joinNumber: joinNum, isVideoJoin: isVideJoin) ?? false
        if !result {
            MBProgressHUD.hide()
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)
        }
        CLLog("加入会议返回结果result:\(String(describing: result)),confId:\(NSString.encryptNumber(with: callInfo.serverConfId) ?? ""))")
    }
     
}

extension SessionViewController {
    
    // 后台时显示本地通知
    private func pushLocalNotify() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "call", content: content, trigger: trigger)
        center.add(request) { (error) in
            CLLog("来电本地推送")
        }
    }
    
    // MARK: notification 来电通知
    @objc func notifcationSdkComingCall(notification: Notification) {
        let callInfo = notification.object as! CallInfo
        CLLog("calling number: \(NSString.encryptNumber(with: callInfo.telNumTel) ?? "")")
        
        pushLocalNotify()
        
        ManagerService.call()?.currentCallInfo = callInfo
        // 接收到来电通知后关闭摄像头，麦克风
        // 会议连接成功先关闭摄像头
        ManagerService.call()?.switchCameraOpen(false, callId: UInt32(callInfo.stateInfo.callId))
        // 会议连接成功先关闭麦克风
        ManagerService.call()?.muteMic(true, callId: UInt32(callInfo.stateInfo.callId))
        
        let currentVC = ViewControllerUtil.getCurrentViewController()
        
        if SessionManager.shared.isCurrentMeeting {
            CLLog("\(NSString.encryptNumber(with: callInfo.stateInfo.callName) ?? "") call coming...")
            return
        }
        
        // 非发起会议, 被邀入会
        if !SessionManager.shared.isJoinImmediately {
            SessionManager.shared.isBeInvitation = true
        }
        if ManagerService.call()?.isSMC3 == false {
            SessionManager.shared.isJoinImmediately = false
            let receiveCallVC = AnswerPhoneViewController.init()
            receiveCallVC.modalPresentationStyle = .overFullScreen
            receiveCallVC.modalTransitionStyle = .coverVertical
            receiveCallVC.callInfo = callInfo
            currentVC.present(receiveCallVC, animated: true, completion: nil)
        } else {
            let accessNumber = ManagerService.confService()?.currentConfBaseInfo?.accessNumber ?? ""
            CLLog("发会 accessNumber = \(NSString.encryptNumber(with: accessNumber) ?? "")")
            let telNumTel = ManagerService.call()?.currentCallInfo?.telNumTel ?? ""
            CLLog("来电 telNumTel = \(NSString.encryptNumber(with: telNumTel) ?? "")")
            // 解决3.0发会来电回调与被邀来电回调冲突场景，导致进入另一个会议的场景
            if SessionManager.shared.isJoinImmediately, accessNumber == telNumTel {
                // 3.0 发起会议不接听直接入会
                SessionManager.shared.isJoinImmediately = false
                MBProgressHUD.showMessage(tr("正在加入会议") + "...")
                ManagerService.call()?.answerComingCall(callInfo.stateInfo.callType == CALL_VIDEO ? CALL_VIDEO : CALL_AUDIO, callId: callInfo.stateInfo.callId)
//                let number = ManagerService.call()?.terminal
//                ManagerService.confService()?.joinConference(withConfId: callInfo.serverConfId, accessNumber: callInfo.stateInfo.callNum, confPassWord: "", joinNumber: number, isVideoJoin: true)
            } else {
                // 3.0 非发会, 来电呼入的时候，需要弹出接听界面
                let receiveCallVC = AnswerPhoneViewController.init()
                receiveCallVC.modalPresentationStyle = .overFullScreen
                receiveCallVC.modalTransitionStyle = .coverVertical
                receiveCallVC.callInfo = callInfo
                currentVC.present(receiveCallVC, animated: true, completion: nil)
            }
        }
    }
}

extension SessionViewController {
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
//            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: SessionManager.shared.isJoinImmediately)
//            ManagerService.call()?.hangupAllCall()
            DispatchQueue.main.async {
                MBProgressHUD.hide()
//                Toast.showBottomMessage(tr("加入会议失败"))
//                if SessionManager.shared.meetingMainVC?.isShowInWindow ?? false {
//                    CLLog("dismiss")
//                    SessionManager.shared.meetingMainVC?.dismiss(animated: false, completion: nil)
//                }

            }
        }
    }
}

//MARK: - 处理加入会议异常情况
extension SessionViewController {
    private func dealJoinMeetingErrorWithCode(errorCode:String,text:String) {
        //3.0 状态下发起vmr 会议可能失败，在此处置位false
        if SessionManager.shared.isJoinImmediately {
            SessionManager.shared.isJoinImmediately = false
        }
//        if  errorCode == "0" {
//            MBProgressHUD.showBottom("\(text) "+tr("失败"), icon: nil, view: nil)
//        } else if errorCode == "67109096"{ // 此时是因为已经有了预约会议或者已经召开了VMR会议，当前会议还存在，不能继续预约或者召开会议,只有3.0 状态下才会出现这种情况
//            MBProgressHUD.showBottom( "您的个人会议ID已被预约或正在召开会议，" + "\(text) " + tr("失败"), icon: nil, view: nil)
//        }else if errorCode == "67108906"{
//            MBProgressHUD.showBottom( "MCU资源不足"  , icon: nil, view: nil)
//        }
        switch errorCode {
        case "67109058", "67109062", "67109065", "67109068", "67109070", "67109071", "67109072", "67109073", "67109074", "67109075", "67109076":
            let desc = text + "失败"  // 此处不需要翻译
            MBProgressHUD.showBottom("\(tr(desc))\(tr("，"))\(tr("请稍后再试"))", icon: nil, view: nil)
        case "67109060", "67109061", "67109063", "67109064", "67109066", "67109067", "67109069", "67109077", "67109078", "67109079", "67109080", "67109081":
            let desc = text + "失败"  // 此处不需要翻译
            MBProgressHUD.showBottom("\(tr(desc))\(tr("，"))\(tr("请联系管理员"))", icon: nil, view: nil)
        case "67109096":// 此时是因为已经有了预约会议或者已经召开了VMR会议，当前会议还存在，不能继续预约或者召开会议,只有3.0 状态下才会出现这种情况
            var desc = ""
            if isCNlanguage() {
                desc = "您的个人会议ID已被预约或正在召开会议，" + "\(text) " + "失败"
            } else {
                if SessionManager.shared.isBespeak {
                    desc = "Failed to schedule the meeting because your personal meeting ID has been occupied or the meeting is being held"
                } else {
                    desc = "Failed to initiate the meeting because your personal meeting ID has been occupied or the meeting is being held"
                }
            }
            MBProgressHUD.showBottom(desc, icon: nil, view: nil)
        case "67108876":
            MBProgressHUD.showBottom(tr("鉴权失败，请重新登录"), icon: nil, view: nil)
        case "50331749":
            MBProgressHUD.showBottom(tr("入会失败，请稍后重试"), icon: nil, view: nil)
        case "67108873":
            MBProgressHUD.showBottom(tr("网络异常，创建会议失败"), icon: nil, view: nil)
        default:
            MBProgressHUD.showBottom("\(tr(text)) "+tr("失败"), icon: nil, view: nil)
        }
        
        SessionManager.shared.isMeetingVMR = false
        SessionManager.shared.isBeInvitation = false
        SessionManager.shared.isSelfPlayCurrentMeeting = false
        SessionManager.shared.isJoinImmediately = false
    }
    
}

