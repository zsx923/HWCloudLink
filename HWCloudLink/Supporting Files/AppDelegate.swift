//
// AppDelegate.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/6.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import PushKit
import CallKit
import SwiftTheme

//enum AllowRotateDirection {
//    case left
//    case landscape
//    case all
//    case portrait
//}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    var isAllowRotate = false  //是否允许横屏  默认竖屏
    public var rotateDirection: UIInterfaceOrientationMask = .portrait  // 屏幕支持方向

//    var bgTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 123)
    // 后台任务
    var backgroundTask: UIBackgroundTaskIdentifier! = UIBackgroundTaskIdentifier(rawValue: 123)

    var isBackground: Bool = false
    var backgroudActiveInstance = BackGroudActive()
    
    var timer: DispatchSourceTimer?

    static var isInToSession:Bool = false
    
    // MARK: -
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CLLog("APP启动成功")
        
        
        
        self.window?.backgroundColor = UIColor.white
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = BaseNavigationController.init(rootViewController: loginVC!)
        self.window?.makeKey()
        Log.start()
        
        //获取设备及App信息的日志
        HWAppInfoManager().getTotalDeviceInfo()
        //注册微信
        WXApi.registerApp(wechatShareAppId, universalLink: universalLink) ? CLLog("微信注册成功") : CLLog("微信注册失败")
        NetworkUtils.shareInstance()
     

        // start up tup module.(module: Call/Conference/SipLogin)
        ServiceManager.startup()

        // config parameter
//        LoginCenter.sharedInstance()?.configSipRelevantParam()
        
        //TODO: 先注释PUSH功能, 后续有推送再开启
        //configPush()

        initDB()

        configTheme()
        
        // 启动bugly
        Bugly.start(withAppId: BUGLY_APP_ID)

        configLogUploadStrategy()

        configLanguage()
       
        // 崩溃日志捕获
        CZFSingalCrash.observerCaughtException()
        
        // 初始化交换扩展方法
        UIViewController.initializeMethod()
        
        // 判断第一次是否设置铃声状态
        let soundBellStatus = NSObject.getUserDefaultValue(withKey: SOUND_BELL_KEY) as? String
        if soundBellStatus == nil {
            NSObject.userDefaultSaveValue(true, forKey: SOUND_BELL_KEY)
            NSObject.userDefaultSaveValue(true, forKey: VIBRATE_KEY)
        }
        self.logRecord()
        self.configLocalPush()
        
        guard let _ = UserDefaults.standard.value(forKey: VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY) else {
            UserDefaults.standard.setValue("0", forKey: VIRTUAL_MEETING_VMR_3_ID_SAVE_KEY)
            return true
        }
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        CLLog("ResignActive")
//        if self.backgroundTask != nil {
//            application.endBackgroundTask(self.backgroundTask)
//            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
//        }

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //判断是否有摄像头

        if SessionManager.shared.isCameraOpen, SessionManager.shared.isConf == false {
            let meetingInfo = ManagerService.confService()?.currentConfBaseInfo
            if meetingInfo != nil {
                ManagerService.call()?.switchCameraOpen(false, callId: UInt32(meetingInfo?.callId ?? 0))
            } else {
                let callInfo = ManagerService.call()?.currentCallInfo
                if callInfo != nil && callInfo?.stateInfo.callId != nil {
                    ManagerService.call()?.switchCameraOpen(false, callId: callInfo?.stateInfo.callId ?? 0)
                }
            }
        }

        isBackground = true
        
        self.backgroundTask = UIApplication.shared.beginBackgroundTask() {
            
            self.backgroudActiveInstance.startBGRun()
            CLLog("Background-- active start---")
        }
        
        CLLog("Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        if self.backgroundTask != nil {
            application.endBackgroundTask(self.backgroundTask)
//            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
        
//        self.backgroudActiveInstance.stopBGRun()
        isBackground = false

        CLLog("Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.backgroudActiveInstance.stopBGRun()
        CLLog("BecomeActive  BGactive(stop)")
        
        // 清除本地通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        //判断是否有摄像头
        if SessionManager.shared.isCameraOpen {
             let meetingInfo = ManagerService.confService()?.currentConfBaseInfo
             if meetingInfo != nil && meetingInfo?.callId != nil && meetingInfo?.callId  != 0 {
                ManagerService.call()?.switchCameraOpen(true, callId: UInt32(meetingInfo?.callId ?? 0))
             } else {
                let callInfo = ManagerService.call()?.currentCallInfo
                if callInfo != nil && callInfo?.stateInfo.callId != nil {
                    ManagerService.call()?.switchCameraOpen(true, callId: callInfo?.stateInfo.callId ?? 0)
                }
            }
        }
        
        //TODO: 先注释掉升级检查, 后续上架之前开启
        //UpgradeManager.shared.checkAppUpgradeInfo()

        configTheme()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if self.timer != nil {
            self.timer?.cancel()
            self.timer = nil
        }
        
        ManagerService.confService()?.confCtrlLeaveConference()
        ManagerService.confService()?.restoreConfParamsInitialValue()
        
        NotificationCenter.default.removeObserver(self)
        
        let notification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notification, CFNotificationName.init("STOPSHARED" as CFString), nil, nil, true)
        CLLog("APP 被停止 Terminate")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let str = NSString.init(data: deviceToken, encoding: String.Encoding.utf8.rawValue)
        if str != nil {
            var tokenStr = str?.replacingOccurrences(of: "<", with: "") as NSString?
            tokenStr = tokenStr?.replacingOccurrences(of: ">", with: "") as NSString?
            tokenStr = tokenStr?.replacingOccurrences(of: " ", with: "") as NSString?

        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CLLog("notification error desc:\(error.localizedDescription)")
    }

    //横竖屏
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        return self.rotateDirection
    }

    // MARK: - PKPushRegistryDelegate
    // MARK: didInvalidatePushTokenFor
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        CLLog("\(type)")
    }

    // MARK: pushCredentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        CLLog("enter")

        let str = NSString.init(data: pushCredentials.token, encoding: String.Encoding.utf8.rawValue)
        if str != nil {
            var tokenStr = str?.replacingOccurrences(of: "<", with: "") as NSString?
            tokenStr = tokenStr?.replacingOccurrences(of: ">", with: "") as NSString?
            tokenStr = tokenStr?.replacingOccurrences(of: " ", with: "") as NSString?

        }
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        let dictInfo = payload.dictionaryPayload
        let state = dictInfo["State"] as? NSString

        if state != nil && state?.integerValue == 1 {
            // push消息有2种，根据push携带的消息字典中的State值来区分，分别是发起呼叫(0)和取消呼叫(1),这里如果是取消呼叫的消息，我们不进行处理
            CLLog("[voip push] voip call canceled")
        }
    }

    func configPush() {
        // 注册voip push
        let pushRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [PKPushType.voIP] as Set<PKPushType>

        // 注册apns push
        let notiCenter = UNUserNotificationCenter.current()
        notiCenter.delegate = self
        notiCenter.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
            if !granted {
                // 再次检查通知权限
                self.checkNotificationAuth { (isgrand) in
                    CLLog("通知授权 - \(isgrand ? "OK" : "failed")")
                }
            } else {
                CLLog("通知授权 - OK")
            }
        }
        UIApplication.shared.registerForRemoteNotifications()  // 注册远程通知
    }

    // MARK: 检查通知权限
    func checkNotificationAuth(block: @escaping (_ granted: Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                block(true)
            } else {
                block(false)
            }
        }
    }
    
    // 配置本地通知
    func configLocalPush() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            CLLog("本地通知权限 - \(granted ? "已授权" : "未授权")")
        }
    }

    // MARK: - private

    func initDB() {
        
        //TODO:辅流全局状态偏好设置保存初始化，更多全局状态初始化需要抽离
        UserDefaults.standard.set(false, forKey: "aux_rec")
    
        //初始化数据库
        if DBManager.shared.createDB() {
            CLLog("数据库创建成功")
            let addUserSetting = DBManager.shared.addUserSettingTable()
            if addUserSetting {
                CLLog("数据库添加用户配置表成功")
            } else {
                CLLog("数据库添加用户配置表失败")
            }
        } else {
            CLLog("数据库创建失败")
        }
    }

    // 本地国际化
    func configLanguage() {
        // 第一次未记录本地化语言，跟随系统语言设置
        if UserDefaults.standard.string(forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH) == "" || UserDefaults.standard.string(forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH) == nil {
            if getCurrentLanguage().hasPrefix("zh") { // 本地汉语
                UserDefaults.standard.set("zh-Hans", forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH)
            } else { // 不是汉语就是汉语
                UserDefaults.standard.set("en", forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH)
            }
        }
    }

    func configLogUploadStrategy() {
        if NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOG_UPLOAD_IS_ON) as? String == ""
            || NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOG_UPLOAD_IS_ON) == nil {
            NSObject.userDefaultSaveValue("1", forKey: DICT_SAVE_LOG_UPLOAD_IS_ON)
        }
    }

    func configTheme() {
        // 适配暗黑模式
        let isDark = self.window?.traitCollection.userInterfaceStyle == .dark
        MyThemes.switchNight(isToNight: isDark)
        // navigation bar
        let navigationBar = UINavigationBar.appearance()
        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ]
        navigationBar.titleTextAttributes = titleAttributes
        UITabBar.appearance().backgroundColor = UIColor(hexString: isDark ? "#1A1A1A" : "#FAFAFA")
    }

    //MARK:---通过链接拉起app
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return true
        }
        let scheme = url.scheme
        let host = url.host
        let query = url.query
        let array = (query?.components(separatedBy: "&"))! as Array
        let manager = NickJionMeetingManager.manager
        if scheme == "hwcloudlink" && host == "kitsoftclient" {
            manager.isNickJoin = true
            for  innerItem   in  array {
                if innerItem.hasPrefix("site_url") {
                    manager.site_url = String(innerItem.suffix(innerItem.count - 9))
                } else if innerItem.hasPrefix("random") {
                    manager.random = String(innerItem.suffix(innerItem.count - 7))
                } else if innerItem.hasPrefix("version") {
                    manager.version = String(innerItem.suffix(innerItem.count - 8))
                }
            }
            
            if  ManagerService.call()?.ldapContactInfo != nil { // 此时处于登录状态并且是活跃状态,调用接口入会
                if manager.isObservering {
                    manager.removeJointMeetingObserver()
                }
                manager.linkJoinMeet(nickName: "")
            } else {//不是登录状态
                /*
                 HistoryAccounts.isAutoLogin() == true 表明本地有账号密码，登录完成之后在SessionViewController 里面处理，
                 此处只处理没有账号密码的情况，匿名入会
                 */
                if !HistoryAccounts.isAutoLogin() == true { //此时需要匿名入会
                    if !manager.isObservering{// 监听不存在，添加监听
                        manager.initJointMeetingObserver()
                    }
                    //本地不存在账号密码的情况下，弹框提示输入昵称
                    manager.displayShowNickNameView()
                }
            }
            return true
        }
        return false
    }
}

//MARK: -微信跳转回调
extension AppDelegate: WXApiDelegate {
    
    func onReq(_ req: BaseReq) {
        CLLog("微信分享跳转到微信  ==》 \(req.openID)")
    }
    
    func onResp(_ resp: BaseResp) {
        CLLog("微信分享跳转到回app  ==》 \(resp.errCode)")
    }
}

extension AppDelegate {
    // 日志收集
    func logRecord() {
        self.timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        self.timer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: .seconds(60))
        self.timer?.setEventHandler(handler: {
            CLLog("CPU使用率：\(DeviceTool.cpuUsageForApp() ?? "")，总内存：\(DeviceTool.devicePhysicalRunTimeSize() ?? "")，剩余内存：\(DeviceTool.deviceUnUsePhysicalRunTimeSize() ?? "")，APP内存占用：\(DeviceTool.memoryUsageForApp() ?? "")，本机IP地址：\(NSString.encryptIP(with: DeviceTool.getDeviceIPAddresses()) ?? "")")
        })
        self.timer?.resume()
    }
}
