//
// NewPwdViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
// add at xuegd: 修改密码

import UIKit

class NewPwdViewController: UITableViewController, UITextFieldDelegate, TextTitleSingleBtnViewDelegate, TextTitleViewDelegate {
    // 特殊字符
    let specialCharacters = "`~!@#$%^&*()-_=+|[{}];:./?"
    // 旧密码
    @IBOutlet weak var oldPwdTitleLabel: UILabel!
    // 旧密码 - UITextField
    @IBOutlet weak var oldPwdValueTextField: NoCopyTextField!
    @IBOutlet weak var oldPwdEye: UIButton!
    @IBOutlet weak var oldPwdLine: UIView!
    // 新密码
    @IBOutlet weak var newPwdTitleLabel: UILabel!
    // 新密码 - UITextField
    @IBOutlet weak var newPwdValueTextField: NoCopyTextField!
    @IBOutlet weak var newPwdEye: UIButton!
    @IBOutlet weak var newPwdLine: UIView!
    // 确认新密码
    @IBOutlet weak var checkNewPwdTitleLabel: UILabel!
    // 确认新密码 - UITextField
    @IBOutlet weak var checkNewPwdValueTextField: NoCopyTextField!
    @IBOutlet weak var checkNewPwdEye: UIButton!
    @IBOutlet weak var checkNewPwdLine: UIView!
    // 密码规则
    @IBOutlet weak var pwdInfoTitleLabel: UILabel!
    // 完成 - UIButton
    @IBOutlet weak var doneBtn: UIButton!
    // 是否显示旧密码输入框（SMC3.0用户首次登录修改密码，不需要显示旧密码输入框）
    var isShowOldPassword : Bool = true
    
    var oldPassword : String = ""
    private var errorCodeStr:String?
    
    private var secretOldPwdString = ""     // 密码逐个删除临时替换字符串 - 旧密码
    private var secretNewPwdString = ""     // 密码逐个删除临时替换字符串 - 新密码
    private var secretNewSurePwdString = "" // 密码逐个删除临时替换字符串 - 新的确认密码

    override func viewDidLoad() {
        super.viewDidLoad()

        MBProgressHUD.hide()
        // Do any additional setup after loading the view.
        // 初始化
        self.title = LoginViewController.isFirstChangePassword ? tr("设置新密码") :
            tr("修改密码")
        self.doneBtn.layer.cornerRadius = 2.0
        
        self.oldPwdTitleLabel.text = tr("旧密码")
        self.oldPwdValueTextField.placeholder = tr("请输入旧密码")
        self.newPwdTitleLabel.text = tr("新密码")
        self.newPwdValueTextField.placeholder = tr("请输入新密码")
        self.checkNewPwdTitleLabel.text = tr("确认新密码")
        self.checkNewPwdValueTextField.placeholder = tr("请确认新密码")
        self.pwdInfoTitleLabel.text = tr("密码规则：\n        密码长度为8～32位且至少包含以下两种字符的组合：英文大写字母、英文小写字母、数字、特殊字符(`~!@#$%^&*()-_=+|[{}];:./?)；不能包含空格和逗号;不能为弱口令")
        self.doneBtn.setTitle(tr("完成"), for: .normal)
        
        if !self.isShowOldPassword { // 首次登录修改密码
            self.oldPwdValueTextField.text = self.oldPassword
        } else { // 修改密码
            self.checkNewPwdValueTextField.placeholder = tr("请确认新密码")
        }
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 去分割线
        self.tableView.separatorStyle = .none
        self.oldPwdValueTextField.delegate = self
        self.newPwdValueTextField.delegate = self
        self.checkNewPwdValueTextField.delegate = self
        
        // 设置删除按钮
        self.oldPwdValueTextField.rightView = self.createDeleteButton(textFeild: self.oldPwdValueTextField)
        self.newPwdValueTextField.rightView = self.createDeleteButton(textFeild: self.newPwdValueTextField)
        self.checkNewPwdValueTextField.rightView = self.createDeleteButton(textFeild: self.checkNewPwdValueTextField)
        self.oldPwdValueTextField.rightViewMode = .whileEditing
        self.newPwdValueTextField.rightViewMode = .whileEditing
        self.checkNewPwdValueTextField.rightViewMode = .whileEditing
    }

    // MARK: - 点击事件
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        if LoginViewController.isFirstChangePassword {
            LoginViewController.isFirstChangePassword = false
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: 完成按钮
    @IBAction func doneBtnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if SessionManager.shared.isCurrentMeeting { // 正在会议中时，需要弹窗提醒
            let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
            alertTitleVC.modalTransitionStyle = .crossDissolve
            alertTitleVC.modalPresentationStyle = .overFullScreen
            alertTitleVC.customDelegate = self
            alertTitleVC.isCancelBgViewTouch = true
            self.present(alertTitleVC, animated: true, completion: nil)
        } else {
            self.modifyPasswordRequest()
        }
    }
    
    // 修改密码请求
    func modifyPasswordRequest() {
        if oldPwdValueTextField.text == "" || oldPwdValueTextField.text == nil {
            self.errorCodeStr = tr("旧密码输入不能为空")
            self.changePasswordError()
            return
        }

        if newPwdValueTextField.text == "" || newPwdValueTextField.text == nil {
            self.errorCodeStr = tr("新密码输入不能为空")
            self.changePasswordError()
            return
        }

        if checkNewPwdValueTextField.text == "" || checkNewPwdValueTextField.text == nil {
            self.errorCodeStr = tr("请再次输入密码")
            self.changePasswordError()
            return
        }

        if newPwdValueTextField.text != checkNewPwdValueTextField.text {
            self.errorCodeStr = tr("两次密码输入不一致")
            self.changePasswordError()
            return
        }
        
        // 密码复杂度校验
        let reg = "^(?![0-9]+$)(?![a-z]+$)(?![A-Z]+$)(?!([^(0-9a-zA-Z)])+$).{8,32}$"
        if !self.checkRes(reg: reg, str: self.checkNewPwdValueTextField.text ?? "") {
            self.errorCodeStr = tr("新密码复杂度不满足要求")
            self.changePasswordError()
            return
        }
        
        MBProgressHUD.showMessage("", to: nil)
        ManagerService.loginService()?.changePasswordWitholdPassword(oldPwdValueTextField.text, newPassword: checkNewPwdValueTextField.text, completionBlock: { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {
                    NSObject.userDefaultSaveValue(self.checkNewPwdValueTextField.text, forKey: DICT_SAVE_LOGIN_password)
                    if LoginViewController.isFirstChangePassword {
                        // 更新账号信息
                        self.updateAccountForlocalTable()
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    MBProgressHUD.hide()
                    // 发送通知注销并清除密码
                    NotificationCenter.default.post(name: NSNotification.Name("LogOutSuccessClearPassword"), object: true, userInfo: ["tip":tr("密码修改成功")])
                    // 清除用户数据
                    UserDefaults.standard.set("", forKey: DICT_SAVE_NIC_NAME)
                    NSObject.userDefaultSaveValue("", forKey: DICT_SAVE_LOGIN_password)
                } else {
                    MBProgressHUD.hide()
                    CLLog("Change Pwd Fail! Description:"+"\(String(describing: error.debugDescription))")
                    if let err = error as NSError? {
                        self.errorCodeStr = LoginViewController.loginFailMsgWith(error: err, type: false)
                        
                        let isServerSyncAcc = LoginViewController.loginFailAccountSyncMsgWith(error: err)
                        if isServerSyncAcc {
                            self.navigationController?.popViewController(animated: true)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                                HWLoginInfoManager.showMessageSingleBtnAlert(title: "密码正在同步中，请稍后再试。", titleBtn: "确定")
                            }
                        } else {
                            self.changePasswordError()
                        }
                    }
                }
            }
        })
    }
    
    // 更新历史账号
    func updateAccountForlocalTable() {
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
        }
        
        if let account = NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as? String {
            user.account = account
            user.password = self.checkNewPwdValueTextField.text
            HistoryAccounts.addAcount(user: user)
        }
    }

    // MARK: 密码显示/隐藏
    @IBAction func clickEye(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.tag {
        case oldPwdEye.tag:
            oldPwdValueTextField.isSecureTextEntry = !sender.isSelected
        case newPwdEye.tag:
            newPwdValueTextField.isSecureTextEntry = !sender.isSelected
        case checkNewPwdEye.tag:
            checkNewPwdValueTextField.isSecureTextEntry = !sender.isSelected
        default:
            break
        }
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !self.isShowOldPassword && indexPath.section == 0 && indexPath.row == 0 { // 旧密码: 不显示
            return 0.0
        } else if indexPath.section == 1 {
            return 220
        } else {
            return 72.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.oldPwdValueTextField.resignFirstResponder()
            self.newPwdValueTextField.resignFirstResponder()
            self.checkNewPwdValueTextField.resignFirstResponder()
        }
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /* 密码应满足8～32位且至少包含以下两种字符的组合：
         英文大写字母
         英文小写字母
         数字
         特殊字符(`~!@#$%^&*()-_=+|[{}];:./?)；
         不能包含空格和逗号;不能为弱密码
        */
        let reg = "^[A-Za-z0-9]+$"
        if string == "" || self.checkRes(reg: reg, str: string) || self.specialCharacters.contains(string){
            let textString = textField.text! as NSString
            let nowString = textString.replacingCharacters(in: range, with: string)
            if nowString.count > WORDCOUNT_USER_PASSWORD {
                return false
            }
            
            if textField == self.oldPwdValueTextField {
                return HWLoginInfoManager.setTextFieldDeleteOneByOne(textField: textField, globalStr: &secretOldPwdString, string: string, range: range)
            }
            if textField == self.newPwdValueTextField {
                return HWLoginInfoManager.setTextFieldDeleteOneByOne(textField: textField, globalStr: &secretNewPwdString, string: string, range: range)
            }
            if textField == self.checkNewPwdValueTextField {
                return HWLoginInfoManager.setTextFieldDeleteOneByOne(textField: textField, globalStr: &secretNewSurePwdString, string: string, range: range)
            }
            
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case oldPwdValueTextField.tag:
            oldPwdLine.backgroundColor = UIColorFromRGB(rgbValue: 0x0D94FF)
            break
        case newPwdValueTextField.tag:
            newPwdLine.backgroundColor = UIColorFromRGB(rgbValue: 0x0D94FF)
            break
        case checkNewPwdValueTextField.tag:
            checkNewPwdLine.backgroundColor = UIColorFromRGB(rgbValue: 0x0D94FF)
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case oldPwdValueTextField.tag:
            oldPwdLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            break
        case newPwdValueTextField.tag:
            newPwdLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            break
        case checkNewPwdValueTextField.tag:
            checkNewPwdLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            break
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: - Alert Delegate
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        
        viewVC.showTitleLabel.text = SessionManager.shared.isConf ? tr("修改密码会议将中断，需要重新登录，确定是否修改？") : tr("修改密码通话将中断，需要重新登录，确定是否修改？")
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        viewVC.showRightBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
    }

    // MARK: 取消
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
    
    }

    // MARK:确认修改密码
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        self.modifyPasswordRequest()
    }
}

extension NewPwdViewController {
    func checkRes(reg:String,str:String) -> Bool {
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        let res = pre.evaluate(with: str)
        return res
    }

    private func changePasswordError(){
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
        
    }
    
    // MARK: 创建删除按钮
    private func createDeleteButton(textFeild: UITextField) -> UIButton {
        let deleteButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
        deleteButton.setImage(UIImage.init(named: "login_account_close"), for: .normal)
        deleteButton.tintColor = COLOR_GAY
        deleteButton.addTarget({ (sender) in
            textFeild.text = ""
        }, andEvent: .touchUpInside)
        return deleteButton
    }
}
