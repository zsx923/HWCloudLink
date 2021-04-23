//
//  NickJionMeetingManager.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/12/15.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class NickJionMeetingManager: NSObject {

    // 登陆配置
    // 本地存储的服务器配置
    private var srtpMode:SRTP_MODE = SRTP_MODE_OPTION
    private var transportMode:TRANSPORT_MODE = TRANSPORT_MODE_TLS
    private var bfcpModel:TSDK_E_BFCP_TRANSPORT_MODE = TSDK_E_BFCP_TRANSPORT_AUTO

    private var priorityType:CONFIG_PRIORITY_TYPE = CONFIG_PRIORITY_TYPE_APP
    private var tunnelMode:TUNNEL_MODE = TUNNEL_MODE_DEFAULT
    private var sipPortPriority:Bool = false
    // 本地存储的服务器配置
    private var serverArray:NSArray = [];
    private var abnormalTimer: Timer?

    static let manager = NickJionMeetingManager()
    var NickNameView: JoinMeetingNickNameView?
    var isNickJoin: Bool = false
    var site_url: String = ""
    var version: String = ""
    var random: String = ""
    var nickName: String = ""
    var isObservering: Bool = false //匿名链接入会，添加监听，改为true，表明有监听存在，登录之后需要释放通知
    override init() {
        super.init()
    }
    //MARK: - 初始化通知
    func initJointMeetingObserver(){
        if !isObservering { //通知已经监听了就不在监听
            CLLog("jointMeeting:===Manager添加监听")
            isObservering = true
            /*这两个通知是在未登录状态下的通知*/
            NotificationCenter.default.addObserver(self, selector: #selector(notificationConfConnect(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_JOIN_CONF_RESULT), object: nil)
            
            //通话建立的通知，用来获取 callinfo 信息。。。。
            NotificationCenter.default.addObserver(self, selector: #selector(notificationCallConnected(notification:)), name: NSNotification.Name.init(rawValue: CONF_S_CALL_EVT_CONF_CONNECTED), object: nil)
            // 添加通知监听
            NotificationCenter.default.addObserver(self, selector: #selector(joinMeetingNotification(notification:)), name: NSNotification.Name.init(rawValue: LOGIN_C_GET_TEMP_USER_INFO_FAILD), object: nil)
        }
    }

    @objc func joinMeetingNotification(notification: Notification) {
//        let dataDict = notification.object as? NSDictionary
        CLLog("匿名加入会议失败")
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view:nil)
        }

    }

    //MARK: - 移除通知
    func removeJointMeetingObserver(){
        if isObservering {
            CLLog("jointMeeting:===Manager移除监听")
            isObservering = false
            NotificationCenter.default.removeObserver(self)
        }
    }
    @objc func notificationConfConnect(notification:Notification){
        self.stopAbnormalTimer()
        DispatchQueue.main.async {
            MBProgressHUD.hide()
        }
        // 进入会场
        let callInfo = ManagerService.call()?.currentCallInfo
        // 判断会议信息
        guard let meetInfo = ManagerService.confService()?.currentConfBaseInfo else {
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
            return
        }
        meetInfo.scheduleUserName = ""
        SessionManager.shared.currentCallId = UInt32(meetInfo.callId)
        meetInfo.mediaType = callInfo?.stateInfo.callType == CALL_VIDEO ? CONF_MEDIATYPE_VIDEO : CONF_MEDIATYPE_VOICE
//        meetInfo.confSubject = NickJionMeetingManager.manager.nickName      //因为是未登录，输入什么就显示什么
//            SessionManager.shared.isMeetingVMR ? self.cloudInfo.confSubject : "\((userInfo?.account)!) " + tr("会议")
        meetInfo.accessNumber = callInfo != nil ? callInfo?.telNumTel : "000 000"  //SessionManager.shared.isMeetingVMR ? self.cloudInfo.accessNumber : (callInfo != nil ? callInfo?.telNumTel : "000 000")
//        print("callinfo:\(callInfo)====telNum:\(callInfo?.telNumTel)")
        let numberArray = NSString.getArraySplitChar(meetInfo.accessNumber, componentsSeparatedBy: "*") as? [String]
        if numberArray != nil {
            meetInfo.accessNumber = numberArray?[0]
            if numberArray!.count > 1 {
                meetInfo.generalPwd = numberArray?[1]
            }
        }
        meetInfo.isConf = true
        meetInfo.isImmediately = true
        
        var sessionType = SessionType.voiceMeeting
        if meetInfo.mediaType == CONF_MEDIATYPE_VIDEO {
            sessionType = callInfo!.isSvcCall ? .svcMeeting : .avcMeeting
        }
        SessionManager.shared.jumpConfMeetVC(sessionType: sessionType, meetInfo: meetInfo, animated: true)
    }
    @objc func notificationCallConnected(notification:Notification){
        // 判断call 信息
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
            else {
            DispatchQueue.main.async {
                MBProgressHUD.hide()
                MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)
            }
            return
        }
        ManagerService.call()?.currentCallInfo = callInfo
    }

    func removeNickNameView() {
        if NickNameView != nil {
            NickNameView?.removeFromSuperview()
        }
    }
    //MARK:---展示输入昵称的view
    public func displayShowNickNameView(){
        removeNickNameView()
        let view =  JoinMeetingNickNameView.creatJoinMeetingNickNameView()
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        NickNameView = view
        //点击确定的回调
        view.passActionSureBlock = {(isYES: Bool,text: String) in
            if  isYES { //点击了确认按钮
                self.nickName = text
                self.linkJoinMeet(nickName: text)
            }else{
                self.isNickJoin = false
            }
        }
        
        let window = (UIApplication.shared.delegate?.window)!
        window?.rootViewController?.view.addSubview(view)
        view.center = window!.center  
        //获取是否曾经输入过ip地址，没有就获取本地ip 地址
        let ip = ServerConfigInfo.value(forKey: .address)
        let port = ServerConfigInfo.value(forKey: .port)
        if ip.count > 0   && port.count > 0  {
             let info = ManagerService.loginService()?.obtainCurrentLoginInfo()
            if info != nil {
                LoginCenter.sharedInstance()?.updateServerConfigInfo(true)
            } else {
                LoginCenter.sharedInstance()?.setLocalIp()
            }
        }else{
            LoginCenter.sharedInstance()?.setLocalIp()
        }
        
    }
    
    /*这个方法的作用是：
     通过链接拉起app，先调用这个接口，不管是不是登录状态都要调用这个方法
     1：登陆状态下，调用成功会走一个通知LOGIN_STATUS_LINK_JOINMEETING_SUCCESS
     在这个通知里可以获取加入会议的参数，然后调用加入会议的接口，
     调用成功会返回一个成功通知
     2： 在未登录状态下，也要调用这个方法，此时会受到另外两个通知，
     CALL_S_CALL_EVT_CALL_CONNECTED  回话建立通知
     CALL_S_CONF_EVT_JOIN_CONF_RESULT 回话链接成功，在这个通知方法里入会
     */
    public func linkJoinMeet(nickName:String){
        NickJionMeetingManager.manager.isNickJoin = false
        CLLog("正在发起链接入会SITE_URL:\(site_url)NICKNAME:\(nickName)random\(random)")
        MBProgressHUD.showMessage(tr("正在加入会议") + "...")
       
        #if false
        let url = getCapString(obj: site_url)
        let srtp = String.init(format: "%d", srtpMode.rawValue)
        let transport = String.init(format: "%d", transportMode.rawValue)
        let priority = String.init(format: "%d", priorityType.rawValue)
        let portPriority = "1"
        let tunnel = String.init(format: "%d", tunnelMode.rawValue)
        let udpPort = "5060"
        let tlsport = "5061"
//        let bfcp = String.init(format: "%d",  bfcpModel.rawValue)
//        let status = UserDefaults.standard.string(forKey: DICT_SAVE_IS_AGREE_PRIVATEEXPLAIN)
        ServerConfigInfo.setValuesWithDictionary(dic: [
            .address :url,
            .port : "5061",
            .sipUri :"",
            .httpsPort :"443",
            .udpPort : "5060",
            .tlsPort : "5061",
            .srtp : srtp,
            .transport :transport,
//            .bfcp :(status == nil ? bfcp :""),
            .priorityType :priority,
            .tunnel : tunnel,
            .smSecurity : "0",
            .tlsCompatibility:"0"
        ])

        let infoArr = NSArray.init(objects: url,"5061")
        UserDefaults.standard.setValue(infoArr, forKey: DICT_SAVE_SERVER_INFO)
        let serArr = NSArray.init(objects: srtp, transport, priority, udpPort, tlsport, portPriority, tunnel, "0")
        UserDefaults.standard.setValue(serArr, forKey: SRTP_TRANSPORT_MODE)

        let serverInfo = ServerConfigInfo.valuesArray()
        UserDefaults.standard.setValue(serverInfo, forKey: SERVER_CONFIG_INFO)

        NSObject.userDefaultSaveValue("1", forKey: USE_IDO_CONFCTRL)

        NSObject.userDefaultSaveValue( "0", forKey: DICT_SAVE_SERVER_INFO_GUOMI_IS_ON)
        #endif
        ManagerService.confService()?.joinConference(withDisPlayName: nickName, confId: nil, passWord: nil, serverAdd: site_url, random: random, serverPort: 0 , authType: 0  )
        
        startAbnormalTimer()
    }

     public   func stopAbnormalTimer() {
            CLLog("stopAbnormalTimer")
            self.abnormalTimer?.invalidate()
            self.abnormalTimer = nil
        }
        func startAbnormalTimer() {
            self.stopAbnormalTimer()
            CLLog("startAbnormalTimer")
            self.abnormalTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { (timer) in
                CLLog("加入会议60s超时")
                self.stopAbnormalTimer()
                SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: SessionManager.shared.isJoinImmediately)
                DispatchQueue.main.async {
                    MBProgressHUD.hide()
                }
                self.stopAbnormalTimer()
            }
        }

    
    //匿名链接入会存储IP
    func getCapString(obj:String ) -> String {
        let temStr = String(obj.suffix(obj.count - 8))
        let temIP = temStr.components(separatedBy: "/")
        return temIP.first ?? ""
    }

}
