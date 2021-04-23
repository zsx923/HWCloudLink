//
// WelcomeViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/6/13.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var joinConfBtn: UIButton!
    @IBOutlet weak var setUpBtn: UIButton!
    @IBOutlet weak var contentViewTopContraint: NSLayoutConstraint!
    
    // 网络监听接收到的通知
    private var netNotfic:Notification?
    private var isLogout: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        if JailBrokenHelper.shared.jailBrokenCheck(self) {
            return
        }
        
        self.addObserver()
        
        // 判断是否弹出隐私协议
        let status = UserDefaults.standard.string(forKey: DICT_SAVE_IS_AGREE_PRIVATEEXPLAIN)
        if status == nil {
            let privateExplainVC = PrivateExplainViewController.init()
            privateExplainVC.isShowBtn = true
            let baseNav = BaseNavigationController.init(rootViewController: privateExplainVC)
            baseNav.modalPresentationStyle = .overFullScreen
            baseNav.modalTransitionStyle = .crossDissolve
            self.present(baseNav, animated: true, completion: nil)
            return
        }
        
        self.autoLogin()
        initEAGLVIEWShareInstance()
    }

    // 自动登录
    func autoLogin() {
        if HistoryAccounts.isAutoLogin() {
            // 自动登录
            let loginVC = LoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
    
    func initEAGLVIEWShareInstance()  {
        var temV1 = EAGLViewAvcManager.shared.viewForRemote
            temV1 = EAGLViewAvcManager.shared.viewForBFCP
            temV1 = EAGLViewAvcManager.shared.viewForLocal
        
    }
    // 设置UI参数
    func setupUI() {
        welcomeLabel.text = tr("欢迎!")
        loginBtn.setTitle(tr("登录"), for: UIControl.State.normal)
        setUpBtn.setTitle(tr("登录设置"), for: UIControl.State.normal)
        
        welcomeLabel.textColor = UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#ffffff")
        setUpBtn.setTitleColor(UIColor.colorWithSystem(lightColor: UIColor.init(hexString: "#666666"), darkColor: UIColor.init(hexString: "#ffffff")), for: .normal)
        
        // 重新设置宽高 防止横屏进入宽高是反的的
        SCREEN_WIDTH = UIScreen.main.bounds.size.width
        SCREEN_HEIGHT = UIScreen.main.bounds.size.height

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        UIApplication.shared.isStatusBarHidden = false
                
        // set navigation
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)

        // Do any additional setup after loading the view.
        self.loginBtn.layer.masksToBounds = true
        self.loginBtn.layer.cornerRadius = 2.0
        self.loginBtn.layer.borderColor = UIColorFromRGB(rgbValue: 0x86C9FF).cgColor
        self.loginBtn.layer.borderWidth = 0.5 * 2
        if UI_IS_IPHONE_6 {
            self.contentViewTopContraint.constant = -20
        }
    }
    
    // 通知相关
    func addObserver() {
        // 监听网络变化
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNetworkStatus(notification:)), name: NSNotification.Name.init(rawValue: NETWORK_STATUS_CHAGNE_NOTIFY), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginout(notification:)), name: NSNotification.Name("LogOutSuccessClearPassword"), object: nil)
        
        // language change
        NotificationCenter.default.addObserver(self, selector: #selector(languageChange(notfic:)), name: NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE), object: nil)
    }

    @objc func loginout(notification:Notification) {
        isLogout = true
    }
    
    @objc func languageChange(notfic:NSNotification) {
        welcomeLabel.text = tr("欢迎!")
        loginBtn.setTitle(tr("登录"), for: UIControl.State.normal)
        setUpBtn.setTitle(tr("登录设置"), for: UIControl.State.normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.rotateDirection = .portrait
        UIDevice.switchNewOrientation(.portrait)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LogOutSuccessClearPassword"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 点击事件
extension WelcomeViewController {
    
    // 登录按钮
    @IBAction func loginBtnClick(_ sender: Any) {
        let loginVC = LoginViewController()
        loginVC.isLogout = isLogout
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    // 登录设置
    @IBAction func loginSettingBtnClick(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "LoginSettingViewController", bundle: nil);
        let loginSettingVC = storyboard.instantiateViewController(withIdentifier: "LoginSettingView") as! LoginSettingViewController
        self.navigationController?.pushViewController(loginSettingVC, animated: true)
    }
}

// MARK: - 网络状态
extension WelcomeViewController {
    @objc func notificationNetworkStatus(notification: Notification) {
        netNotfic = notification
        let netStatus = notification.object as! NSNumber
        TopToastView.showNetworkTopToast()
        switch netStatus {
        case 0:
            CLLog("网络发生变化：网络异常， 下放空ip，界面显示网络警告")
            LoginCenter.sharedInstance()?.setReconnectLocalIpWithInullIp(true)
            if LoginCenter.sharedInstance()?.getUserLoginStatus() != UserLoginStatus.unLogin {
                WelcomeViewController.checkNetworkChangeMeettingAlert()
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NETWORK_STATUS_CHAGNE_UI_NOTIFY), object: false)
        case 1:
            CLLog("已切换到WIFI")
            WelcomeViewController.reconnectLink()
        case 2:
            CLLog("已切换到移动网络")
            WelcomeViewController.reconnectLink()
        default:
            CLLog("not define.")
        }
    }
    
    // 二次重连
    static func reconnectLink() {
        CLLog("网络发生变化：重新下放ip")
        LoginCenter.sharedInstance()?.setReconnectLocalIpWithInullIp(false)
        
        // 未登录状态时，更新UI
        if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.unLogin {
            // 更新网络异常UI
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NETWORK_STATUS_CHAGNE_UI_NOTIFY), object: !NetworkUtils.unavailable())
        } else {
            // 更新网络异常UI
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NETWORK_STATUS_CHAGNE_UI_NOTIFY), object: false)

            self.checkNetworkChangeMeettingAlert()
        }
    }
    
    // 检查网络变化会议中断提示
    static func checkNetworkChangeMeettingAlert() {
        LoginCenter.sharedInstance()?.setUserLoginStatus(.offline)
        if SessionManager.shared.isCurrentMeeting && SessionManager.shared.isConf {
            // 会议中
            NotificationCenter.default.post(name: NSNotification.Name.init(CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: "1")
            _ = WelcomeViewController.checkNetworkWithNoNetworkAlert(confStatus: .inConf, isDelayShow: true)
        }
        if SessionManager.shared.isCurrentMeeting && !SessionManager.shared.isConf {
            // 点对点
            NotificationCenter.default.post(name: NSNotification.Name.init(CALL_S_CONF_QUITE_TO_CONFLISTVIEW), object: "0")
            _ = WelcomeViewController.checkNetworkWithNoNetworkAlert(confStatus: .inPointTwoPoint, isDelayShow: true)
        }
    }
}
