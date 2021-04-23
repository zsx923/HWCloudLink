//
// LoginViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/6.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import AVFoundation

class LoginViewController: UIViewController, UITextFieldDelegate, TextTitleSingleBtnViewDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    // add at xuegd 2021/01/12 : 首次登录修改密码成功登录失败提示处理
    static var isFirstChangePassword : Bool = false
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var accountView: UIView!
    
    // 登录设置
    @IBOutlet weak var setUpBtn: UIButton!
    // 账号
    @IBOutlet weak var userAccountTF: UITextField!
    // 密码
    @IBOutlet weak var passwordTF: NoCopyTextField!
    // 显示/隐藏密码
    @IBOutlet weak var showPasswordView: UIView!
    // 登录
    @IBOutlet weak var loginBtn: UIButton!
    // 历史记录
    @IBOutlet weak var showHistoryBtn: UIButton!
    //帐号存储
    fileprivate var accountHistoryArray : Array<String> = []
    // 错误提示
    private var errorCodeStr:String?
    // 是否强制退出
    fileprivate var isForceLogout = false

    var isLogout: Bool = false
    // 首次登录修改密码提示信息
    let firstLoginText = tr("首次登录，请修改密码")
    // 历史记录
    fileprivate lazy var historyNotes: HistoryNotes = {
        let temp = HistoryNotes.init(frame: CGRect.init(x: 30,
                                                        y: 250,
                                                        width: SCREEN_WIDTH - 30 * 2,
                                                        height: SCREEN_HEIGHT - 300 - 60),
                                     style: .plain
        )
        temp.backgroundColor = UIColor.clear
        return temp
    }()
    
    private var secretString = ""   // 密码逐个删除临时替换字符串

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        // 获取历史帐号列表
        self.accountHistoryArray.removeAll()
        self.accountHistoryArray = HistoryAccounts.all()
        if self.accountHistoryArray.count != 0 {
            self.historyNotes.data = self.accountHistoryArray
            self.historyNotes.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HW CloudLink"

        // 添加监听
        self.addObserver()
        // 初始化UI
        self.setViewUI()

        // 获取权限
        NetworkUtils.shareInstance()?.getCurrentNetworkStatus()
        
        //获取历史帐号的密码列表
        self.passwordTF.text = HistoryAccounts.getPassword(account: self.userAccountTF.text ?? "")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        CLLog("LoginViewController deinit")
    }

    // MARK: - 添加监听 Notification
    func addObserver() {
        // 登录授权失败
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginAuthFailed),
                                               name: NSNotification.Name.init(rawValue: LOGIN_AUTH_FAILED),
                                               object: nil
        )
        // 登录退出成功
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutSuccess), name:
                                                NSNotification.Name.init(rawValue: LOGIN_LOGOUT_SUCCESS_KEY),
                                               object: nil
        )
        // 帐号已被登录
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accountHaveLoging), name:
                                                NSNotification.Name.init(rawValue: LOGIN_C_FORCE_LOGOUT_SUCCESS_KEY),
                                               object: nil
        )
        // 注销清除登陆页面密码
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginout(notification:)), name:
                                                NSNotification.Name("LogOutSuccessClearPassword"),
                                               object: nil
        )
        // language change
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChange(notfic:)), name:
                                               NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE),
                                               object: nil
        )
        // 二次重连成功
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reconnectLinkSuccess), name:
                                                NSNotification.Name.init(rawValue: LOGIN_RECONNECTION_SUCCESS_KEY),
                                               object: nil
        )
        // 用户离线成功
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userOfflineSuccess), name:
                                                NSNotification.Name.init(rawValue: LOGIN_USER_OFFLINE_SUCCESS_KEY),
                                               object: nil
        )
    }

    // MARK: - 初始化UI
    func setViewUI() {
        // 重新设置宽高 防止横屏进入宽高是反的的
        SCREEN_WIDTH = UIScreen.main.bounds.size.width
        SCREEN_HEIGHT = UIScreen.main.bounds.size.height

        // NavigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        UIApplication.shared.isStatusBarHidden = false

        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(leftBarBtnItemClick(sender:))
        )
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

        // 改变 textField 的 placeholder 颜色
        NSObject.changeTextFieldPlaceholderColor(self.userAccountTF, andPlaceholderColor: COLOR_GRAY_WHITE)
        NSObject.changeTextFieldPlaceholderColor(self.passwordTF, andPlaceholderColor: COLOR_GRAY_WHITE)

        self.userAccountTF.delegate = self
        self.userAccountTF.clearButtonMode = .whileEditing
        self.userAccountTF.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#CCCCCC")
        self.userAccountTF.placeholder = tr("帐号")

        self.passwordTF.delegate = self
        self.passwordTF.baseTextFieldDelegate = self
        self.passwordTF.isSecureTextEntry = true
        self.passwordTF.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#CCCCCC")
        self.passwordTF.clearButtonMode = .whileEditing
        self.passwordTF.placeholder = tr("密码")

        self.loginBtn.setTitle(tr("登录"), for: UIControl.State.normal)
        self.setUpBtn.setTitle(tr("登录设置"), for: UIControl.State.normal)

        // 设置删除按钮
        self.userAccountTF.rightView = self.createDeleteButton(textFeild: self.userAccountTF)
        self.passwordTF.rightView = self.createDeleteButton(textFeild: self.passwordTF)
        self.userAccountTF.rightViewMode = .whileEditing
        self.passwordTF.rightViewMode = .whileEditing

        self.view.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer.init(actionBlock: { [weak self] (sender) in
            guard let self = self else { return }
            if self.showHistoryBtn.isSelected {
                self.showHistoryBtnClick(self.showHistoryBtn)
            }
            self.view.endEditing(true)
        })
        gesture.cancelsTouchesInView = true
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)

        self.view.addSubview(self.historyNotes)

        // 历史记录点击 Block
        self.deleteHistoryNotes()
        self.clickHistoryNotes()

        // change at xuegd: 获取本地用户登录数据<本地用户信息通过HistoryAccounts类进行操作>
        self.accountHistoryArray = HistoryAccounts.all()
        if self.accountHistoryArray.count > 0 {
            self.userAccountTF.text = self.accountHistoryArray[0]
            self.passwordTF.text = HistoryAccounts.getPassword(account: self.userAccountTF.text ?? "")
        }

        if HistoryAccounts.isAutoLogin() {
            // 自动登录
            self.loginApp()

        }
        
        // chenfan 修改二次重连样式
        _ = WelcomeViewController.checkNetworkAndUpdateUI()
    }

    // MARK: - 点击事件
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: 历史记录
    @IBAction func showHistoryBtnClick(_ sender: UIButton) {
        if self.accountHistoryArray.count == 0 { // 没有历史记录时，return
            CLLog("accountHistoryArray count == 0")
            return
        }
        self.view.endEditing(true)
        
        sender.isSelected = !sender.isSelected
        self.showAccountHistoryList(isShow: sender.isSelected)
    }

    // MARK: 密码显示/隐藏
    @IBAction func eyeBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.passwordTF.isSecureTextEntry = !sender.isSelected
    }

    // MARK: 登录按钮
    @IBAction func loginBtnClick(_ sender: UIButton) {
        // 重新登陆
        self.loginApp()
    }

    // MARK: join session
    @IBAction func joinSessionBtnClick(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let joinSessionViewVC = storyboard.instantiateViewController(withIdentifier: "JoinSessionView") as! JoinSessionViewController
        self.navigationController?.pushViewController(joinSessionViewVC, animated: true)
    }

    // MARK: 登录设置
    @IBAction func loginSettingBtnClick(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "LoginSettingViewController", bundle: nil);
        let loginSettingVC = storyboard.instantiateViewController(withIdentifier: "LoginSettingView") as! LoginSettingViewController
        self.navigationController?.pushViewController(loginSettingVC, animated: true)
    }

    // MARK:  登陆APP
    func loginApp() {
        self.view.endEditing(true)
        // 证书校验
        if !(LoginCenter.sharedInstance()?.isCalibrateCerSuccess() ?? false) {
            MBProgressHUD.showBottom(tr("证书已过期"), icon: nil, view: self.view)
            return
        }
        
        UserDefaults.standard.set("", forKey: DICT_SAVE_NIC_NAME)
        if self.userAccountTF.text == "" {
            MBProgressHUD.showBottom(tr("请输入用户名或密码!"), icon: nil, view: self.view)
            return
        }
        if self.userAccountTF.text!.count > 127 {
            MBProgressHUD.showBottom(tr("用户名长度超长!"), icon: nil, view: self.view)
            return
        }
        /*
        if judgeStringIncludeChineseWord(string: self.userAccountTF.text!) {
            MBProgressHUD.showBottom(tr("用户名不能输入中文!"), icon: nil, view: self.view)
            return
        }
        */
        if NetworkUtils.unavailable() {
            MBProgressHUD.showBottom(tr("网络异常"), icon: nil, view: self.view)
            return
        }

        let user = LoginInfo.init()
        // 获取ip和端口
        let serverArray = UserDefaults.standard.object(forKey: DICT_SAVE_SERVER_INFO) != nil ? UserDefaults.standard.object(forKey: DICT_SAVE_SERVER_INFO) as! NSArray : NSArray.init()

        if serverArray.count != 0 && serverArray.count > 1 {
            user.regServerAddress = serverArray[0] as? String
            user.regServerPort = serverArray[1] as? String
            if serverArray.count == 3 {
                // sipUrl
                user.sipUrl = serverArray[2] as? String
            }else{
                user.sipUrl = ""
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                HWLoginInfoManager.showMessageSingleBtnAlert(title: tr("请填写登录设置中的服务器地址和端口"), titleBtn: "确定")
            }
            return
        }
        MBProgressHUD.showMessage("", to: nil)
        user.account = self.userAccountTF.text
        user.password = self.passwordTF.text
        UserDefaults.standard.setValue(user.account, forKey: SAVE_USER_CONUT)
      NSObject.userDefaultSaveValue(user.account, forKey: DICT_SAVE_LOGIN_userName)

        ManagerService.loginService()?.authorizeLogin(with: user, loginCompletionBlock: { [weak self] (isSuccess, error) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                MBProgressHUD.hide()
                if isSuccess {
                    if LoginViewController.isFirstChangePassword {
                        LoginViewController.isFirstChangePassword = false
                        // 延迟是为了MBProgressHUD在present VC时，出现吐丝闪烁问题
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25) {
                            MBProgressHUD.showBottom(tr("密码修改成功"), icon: nil, view: nil)
                            if let newPwd = NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_password) as? String {
                                self.passwordTF.text = newPwd
                            }
                        }
                    } else {
                        // 存储历史帐号
                        self.saveAccountToLocal(user: user)
                    }
                    
                    UserSettingBusiness.shareInstance.saveUserSetting { (res) in
                        if res {
                            CLLog("登录成功 保存 视频质量信息res = \(res)")
                            let policy = UserSettingBusiness.shareInstance.getUserVideoPolicy()
                            
                            let isSuccess:Bool = ((ManagerService.call()?.setVideoDefinitionPolicy(policy)) == true)
                            if isSuccess {
                                CLLog("视频清晰度默认显示成功 -success")
                                ManagerService.call()?.definition = policy
                            }
                        } else {
                            CLLog(" 视频质量信息失败res = \(res)")
                        }
                    }
                    
                    // 跳转界面
                    self.pushHomeViewController()
                    UserDefaults.standard.set(false, forKey: "aux_rec")
                    
                    // 查询企业通讯录
                    HWLoginInfoManager.shareInstance.getLoginInfoByCorporateDirectory()
                }else{
                    LoginViewController.loginFailFirstChangePWDWith(error: error, vc: self)
                    self.dismiss(animated: true, completion: nil)
                    CLLog("Login Fail! Description:"+"\(String(describing: error.debugDescription))")
                    if let err = error as NSError? {
                        self.errorCodeStr = LoginViewController.loginFailMsgWith(error: err, type: true)
                        
                        let isServerSyncAcc = LoginViewController.loginFailAccountSyncMsgWith(error: err)
                        if isServerSyncAcc {
                            HWLoginInfoManager.showMessageSingleBtnAlert(title: tr("密码正在同步中，请稍后再试。"), titleBtn: tr("确定"))
                            LoginViewController.isFirstChangePassword = false
                        } else {
                            self.loginErrorWarning()
                        }
                    }
                }
            }
        }, changePasswordCompletionBlock: { [weak self] (isSuccess, error) in
            guard let self = self else {return}
            CLLog("Login change Password Completion Block! Description: isSuccess: \(isSuccess) \(String(describing: error.debugDescription))")
            DispatchQueue.main.async {
                MBProgressHUD.hide()
                self.errorCodeStr = self.firstLoginText
                self.loginErrorWarning()
            }
        })
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // chenfan 修改二次重连样式
        if WelcomeViewController.checkNetworkAndUpdateUI() {
            return true
        } else {
            self.loginBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
        }
        
        if let textString = textField.text as NSString? {
            let nowString = textString.replacingCharacters(in: range, with: string)

            if textField == self.userAccountTF {
                if nowString.count > WORDCOUNT_USERNAME {
                    return false
                }
                self.passwordTF.text = ""
            }

            if textField == self.passwordTF {
                if nowString.count > WORDCOUNT_USER_PASSWORD {
                    return false
                }
                return HWLoginInfoManager.setTextFieldDeleteOneByOne(textField: textField, globalStr: &secretString, string: string, range: range)
            }
        }
        
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == self.passwordTF {
            if textField.text?.count == 0 {
                return
            }
            for (_,value) in textField.text!.enumerated() {
                if value == " " {
                    continue
                }
                if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                    textFieldDidEndEditing(textField)
                    break
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.userAccountTF, self.showHistoryBtn.isSelected {
            self.showHistoryBtnClick(self.showHistoryBtn)
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.passwordTF {
            if textField.text == nil {
                return
            }
            var nowStr:String = ""
            for (_,value) in textField.text!.enumerated() {
                if value == " " {
                    continue
                }
                if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                    continue
                }
                nowStr = nowStr + String(value)
            }
            textField.text = nowStr
        }
    }

    // MARK: - 历史记录
    func clickHistoryNotes() {
        self.historyNotes.clickHistoryNotes = { [weak self] (index) in
            CLLog("click history account index: \(index).")
            guard let self = self else {return}
            self.userAccountTF.text = (self.accountHistoryArray[index] )
            self.passwordTF.text = HistoryAccounts.getPassword(account: self.accountHistoryArray[index] )
            self.showHistoryBtnClick(self.showHistoryBtn)
        }
    }

    // MARK: 删除
    func deleteHistoryNotes() {
        self.historyNotes.deleteHistoryNotes = { [weak self] (index) in
            guard let self = self else {return}
            if index == 0 {
                self.userAccountTF.text = ""
                self.passwordTF.text = ""
            }
            self.deleteAccount(index: index)
        }
    }

    // MARK: 删除操作
    func deleteAccount(index: Int) {
        CLLog("click delete history account index: \(index).")
        HistoryAccounts.deleteAccount(account: self.accountHistoryArray[index] )
        self.accountHistoryArray.remove(at: index)
        self.historyNotes.reloadData()
        if self.accountHistoryArray.count == 0 {
            self.showAccountHistoryList(isShow: false)
        }
    }

    // MARK: 存储帐号
    func saveAccountToLocal(user: LoginInfo) {
        CLLog("save account to local.")
        HistoryAccounts.addAcount(user: user)
    }

    func checkRes(reg:String,str:String) -> Bool {
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        let res = pre.evaluate(with: str)
        return res
    }

    func judgeStringIncludeChineseWord(string: String) -> Bool {
        for (_, value) in string.trimmingCharacters(in: .nonBaseCharacters).enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }
    
    func pushHomeViewController() {
        let tabBarController = CustomTabBarViewController.init()
        tabBarController.modalPresentationStyle = .fullScreen  // 界面显示模式
        tabBarController.modalTransitionStyle = .crossDissolve // 转场动画
        self.present(tabBarController, animated: true, completion: nil)
    }
    
    // 显示账户历史记录
    func showAccountHistoryList(isShow: Bool) {
        if isShow {
            // 选中
            // 更新frame
            self.historyNotes.y =  self.contentView.y + self.accountView.height

            self.historyNotes.isHidden = false
            self.historyNotes.alpha = 0
            UIView.animate(withDuration: 0.25) {
                self.historyNotes.alpha = 1.0
                self.showPasswordView.alpha = 0
                self.loginBtn.alpha = 0
            } completion: { (isComplete) in
                self.showPasswordView.isHidden = true
                self.loginBtn.isHidden = self.showPasswordView.isHidden
            }
        } else {
            self.showPasswordView.isHidden = false
            self.loginBtn.isHidden = self.showPasswordView.isHidden
            UIView.animate(withDuration: 0.25) {
                self.historyNotes.alpha = 0
                self.showPasswordView.alpha = 1.0
                self.loginBtn.alpha = 1.0
            } completion: { (isComplete) in
                self.historyNotes.isHidden = true
            }
        }
    }
}

// MARK: - 错误处理
extension LoginViewController {

    // 登录失败、错误提示
    private func loginErrorWarning(){
        let alertTitleVC = TextTitleSingleBtnViewController()
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }

    func textTitleSingleBtnViewDidLoad(viewVC: TextTitleSingleBtnViewController) {
        viewVC.showTitleLabel.text = errorCodeStr
    }

    func textTitleSingleBtnViewSureBtnClick(viewVC: TextTitleSingleBtnViewController, sender: UIButton) {
        if viewVC.showTitleLabel.text == self.firstLoginText {
            MBProgressHUD.showMessage("", to: nil)
            LoginViewController.isFirstChangePassword = true
            let storyboard = UIStoryboard.init(name: "NewPwdViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NewPwdView") as! NewPwdViewController
            vc.isShowOldPassword = true
            vc.oldPassword = self.passwordTF.text ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        } else if viewVC.showTitleLabel.text?.hasPrefix("密码有效期剩余") ?? false {
            self.pushHomeViewController()
        }
    }
}

// MARK: - UIGesture 代理方法实现
extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view else {
            return true
        }
         //点为UITableViewCellContentView（即点击了UITabelViewCell）则不接收该点击事件
        if NSStringFromClass(touchView.classForCoder) == "UITableViewCellContentView" ||
            NSStringFromClass(touchView.classForCoder) == "UITableView" {
            return false
        }

        return true;
    }
}

// MARK: - NoCopyTextField 代理方法实现
extension LoginViewController: NoCopyTextFieldDelegate {
    func baseTextFieldDeleteBackward(baseTextField: NoCopyTextField) {
        if baseTextField == self.passwordTF {
            passwordTF.text = secretString
            if passwordTF.text != "" && passwordTF.isSecureTextEntry {
                /// 让光标始终停在在最初的位置
                let start = baseTextField.position(from:baseTextField.beginningOfDocument, offset: 0)
                let end = baseTextField.position(from: start!, offset: 0)
                baseTextField.selectedTextRange = baseTextField.textRange(from: start!, to: end!)
            }
        }
    }
}

// MARK: - 通知事件 Notification
extension LoginViewController {

    // MARK: notification 登录授权失败
    @objc func loginAuthFailed() {
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            MBProgressHUD.hide(for: self.view, animated: true)
            self.errorCodeStr = tr("DNS解析失败")
            self.loginErrorWarning()
        }
    }

    // MARK: notification 登录退出成功
    @objc func logoutSuccess() {
        passiveStopShareScreen()
        if !self.isForceLogout {
            ManagerService.loginService()?.logoutCompletionBlock({ [weak self] (isSuccess, error) in
                guard let self = self else {return}
                if isSuccess {
                    DispatchQueue.main.async {
                        ManagerService.confService()?.confCtrlLeaveConference()
                        ManagerService.confService()?.restoreConfParamsInitialValue()
                        CLLog("Notification logout success!")
                        self.dismiss(animated: true, completion: nil)
                        MBProgressHUD.hide()
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.passwordTF.text = ""
                        ManagerService.call()?.ldapContactInfo = nil
                        self.errorCodeStr = tr("已退出登录")
                        self.loginErrorWarning()
                        MBProgressHUD.showBottom(tr("已退出登录"), icon: nil, view: self.view)
                    }
                }
            })
        } else {
            CLLog("Notification logout Fail!")
            self.isForceLogout = false
        }
        DispatchQueue.main.async {
            // 目前有小窗口
            if SuspendTool.isMeeting() {
                SuspendTool.remove()
                // 结束会议
                SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: true)
            }
            self.passwordTF.text = ""
            // 清除用户数据
            HistoryAccounts.setPassword(account: self.userAccountTF.text ?? "", password: "")
        }
    }

    // MARK: notification 帐号已被登录，强制登出
    @objc func accountHaveLoging() {
        passiveStopShareScreen()
        self.isForceLogout = true
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                ManagerService.confService()?.confCtrlLeaveConference()
                ManagerService.confService()?.restoreConfParamsInitialValue()
                MBProgressHUD.hide()
                MBProgressHUD.hide(for: self.view, animated: true)
                ManagerService.loginService()?.logoutCompletionBlock({ (isSuccess, error) in

                })
                ManagerService.call()?.ldapContactInfo = nil
                self.errorCodeStr = tr("此帐号已在其他终端登录")
                self.loginErrorWarning()

                // 目前有小窗口 移除小窗口
                if SuspendTool.isMeeting() {
                    SuspendTool.remove()
                    // 结束会议
                    SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: true)
                }
            }
        }
    }

    // MARK: notification 注销并清除密码  注意通知的Object为true时，清空密码
    @objc func loginout(notification:Notification) {
        passiveStopShareScreen()
        self.dismiss(animated: true, completion: nil)
        if notification.object as? Bool ?? false {
            self.passwordTF.text = ""
            HistoryAccounts.setPassword(account: self.userAccountTF.text ?? "", password: "")
        }
        self.historyNotes.reloadData()
        ManagerService.call()?.ldapContactInfo = nil
        
        // 目前有小窗口 移除小窗口
        if SuspendTool.isMeeting() {
            SuspendTool.remove()
            // 结束会议
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: true)
        }
        
        if LoginCenter.sharedInstance()?.getUserLoginStatus() != UserLoginStatus.unLogin {
            if let tipMessage = notification.userInfo?["tip"] as! String? {
                self.passwordTF.text = ""
                MBProgressHUD.showBottom(tipMessage, icon: nil, view: nil)
            } else {
                MBProgressHUD.showBottom(tr("已退出登录"), icon: nil, view: self.view)
            }
            return
        }
    }

    // MARK: notification 切换语言
    @objc func languageChange(notfic:Notification) {
        self.userAccountTF.placeholder = tr("姓名")
        self.passwordTF.placeholder = tr("密码")
        self.loginBtn.setTitle(tr("登录"), for: UIControl.State.normal)
        self.setUpBtn.setTitle(tr("登录设置"), for: UIControl.State.normal)
    }
    
    // MARK: notification 二次重连成功
    @objc func reconnectLinkSuccess() {
        CLLog("网络发生变化：二次重连成功，隐藏网络警告提示框和更新UI")
        // 隐藏网络提示框
        TopToastView.hideNetworkTopToast()

        // 更新网络异常UI
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NETWORK_STATUS_CHAGNE_UI_NOTIFY), object: true)
    }
    
    // MARK: notification 用户离线成功
    @objc func userOfflineSuccess() {
        CLLog("网络发生变化：用户离线成功，显示网络警告提示框和更新UI")
        // 显示网络提示框
        TopToastView.showNetworkTopToast()

        // 更新网络异常UI
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NETWORK_STATUS_CHAGNE_UI_NOTIFY), object: false)
    }
}

// MARK: -
extension LoginViewController {
    // MARK: 中文字符处理
    private func isItChineseCharacter(str:String) -> Bool {
        for (_, value) in str.enumerated() {
               if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                   return true
               }
           }
           return false
    }

    // MARK: 创建删除按钮
    private func createDeleteButton(textFeild: UITextField) -> UIButton {
        let deleteButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
        deleteButton.setImage(UIImage.init(named: "login_account_close"), for: .normal)
        deleteButton.tintColor = COLOR_GAY
        deleteButton.addTarget({ (sender) in
            if textFeild == self.userAccountTF {
                self.passwordTF.text = ""
            }
            textFeild.text = ""
        }, andEvent: .touchUpInside)
        return deleteButton
    }
}
extension LoginViewController {
    //被动结束扩展进程
   private func passiveStopShareScreen() -> Void {
        
        let cfnotification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(cfnotification, CFNotificationName.init("STOPSHARED" as CFString), nil, nil, true)
       
    }
    
}
