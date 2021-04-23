//
// MeetAdvanceSetViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetAdvanceSetViewController: UITableViewController,UITextFieldDelegate {

    typealias PasswordTwxtCallBack = (_ password: String)->()
    // 麦克风 - Switch
    @IBOutlet weak var microphoneSwitch: UISwitch!
    // 摄像头 - Switch
    @IBOutlet weak var videoSwitch: UISwitch!
    // 主持人/会议密码 - Switch
    @IBOutlet weak var comerPasswordSwtich: UISwitch!
    // 麦克风
    @IBOutlet weak var microphoneLabel: UILabel!
    // 摄像头
    @IBOutlet weak var videoLabel: UILabel!
    // 主持人/会议密码
    @IBOutlet weak var comerPasswordLabel: UILabel!
    // 请输入密码
    @IBOutlet weak var comerPasswordTitleLabel: UILabel!
    // 请输入密码 - TextField
    @IBOutlet weak var comerPasswordTextField: UITextField!
    @IBOutlet weak var timezoneLabel: UILabel!
    @IBOutlet weak var timezoneTitleLable: UILabel!
    
    var passwordTwxtCallBack: PasswordTwxtCallBack?
    
    var isJoinMeeting: Bool?
    var meetingType: MeetingType = .deafault
    
    typealias TimezoneCallBack = (_ timezoneModel: TimezoneModel) -> Void
    var timezoneCallBack: TimezoneCallBack?
    var timezoneModel: TimezoneModel?
    var timezoneList: [TimezoneModel] = []
    
    // 是否从预约会议见面跳转过来
    var isFromPreMeeting: Bool = false
    private var onlyShowTimezone: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = tr("高级设置")
        
        if isFromPreMeeting, ManagerService.call()?.isSMC3 == true {
            onlyShowTimezone = true
        }
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 去分割线
        self.tableView.separatorStyle = .none
        
        initView()
        initDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initView()  {
        comerPasswordTextField.isSecureTextEntry = true
        comerPasswordTextField.clearButtonMode = .whileEditing
        
        self.comerPasswordTextField.delegate = self
        self.comerPasswordTextField.keyboardType = .numberPad
        self.comerPasswordSwtich.setOn(false, animated: true)
        
        self.timezoneTitleLable.text = tr("时区")
        self.timezoneLabel.lineBreakMode = .byTruncatingTail
    }
    
    func initDate() {
        let passpwd = NSObject.getUserDefaultValue(withKey: DICT_SAVE_MEETING_ADVANCE_SETTING_PASSWORD)
        if passpwd != nil {
            self.comerPasswordTextField.text = passpwd as? String
            self.comerPasswordSwtich.setOn(self.comerPasswordTextField.text!.count > 0, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //((textField.text ?? "").count >= 6) ? false : true
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        
        return nowString.count <= 6
    }
    
    @IBAction func microphoneChange(_ sender: UISwitch) {
        // 判断麦克风权限是否开启
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { (isAuto) in
                if isAuto { // 已授权
                    let isOn = UserDefaults.standard.bool(forKey: CurrentUserMicrophoneStatus)
                    self.microphoneSwitch.isOn = isOn
            }else { // 弹框让去授权
                self.microphoneSwitch.isOn = false
                UserDefaults.standard.set(false, forKey: CurrentUserMicrophoneStatus)
                self.getAuthAlertWithAccessibilityValue(value: "20")
            }
        }
    }
    
    @IBAction func cameraChange(_ sender: UISwitch) {
        // 判断摄像头权限开启
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone { (isAuto) in
               if isAuto { // 已授权
                let isOn = UserDefaults.standard.bool(forKey: CurrentUserCameraStatus)
                self.videoSwitch.isOn = isOn
            }else { // 弹框让去授权
                self.videoSwitch.isOn = false
                UserDefaults.standard.set(false, forKey: CurrentUserCameraStatus)
                self.getAuthAlertWithAccessibilityValue(value: "10")
            }
        }
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        UserDefaults.standard.set(self.microphoneSwitch.isOn, forKey: DICT_SAVE_MICROPHONE_IS_ON)
        UserDefaults.standard.set(self.videoSwitch.isOn, forKey: DICT_SAVE_VIDEO_IS_ON)
        // 传递密码如果有的话
        if comerPasswordTextField.text != "" && passwordTwxtCallBack != nil {
//            if self.comerPasswordSwtich.isOn && (!NSString.isNum(comerPasswordTextField.text) || comerPasswordTextField.text!.count != 6) {
//                MBProgressHUD.showBottom("请出入1-6位数字密码", icon: nil, view: self.view)
//                self.view.endEditing(true)
//                return
//            }
            passwordTwxtCallBack?(comerPasswordTextField.text ?? "")
            NSObject.userDefaultSaveValue(comerPasswordTextField.text, forKey: DICT_SAVE_MEETING_ADVANCE_SETTING_PASSWORD)
        }
        
        if (self.timezoneModel != nil) {
            timezoneCallBack!(self.timezoneModel!)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func comePasswordSwtichValueChange(_ sender: UISwitch) {
        if !sender.isOn {
            // 清除密码
            comerPasswordTextField.text = ""
        }
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isJoinMeeting != nil && self.isJoinMeeting! {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.meetingType == .voice ? 1 : 2
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if timezoneModel?.timeZoneDesc.count ?? 0 > 0 {
            timezoneLabel.text = timezoneModel?.timeZoneDesc
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            if !self.comerPasswordSwtich.isOn{
                cell.isHidden = true
            }else{
                cell.isHidden = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return onlyShowTimezone ? 0.001 : 54
        }
        return 54
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return onlyShowTimezone ? 0.001 : 30
        }
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return onlyShowTimezone ? "" : "本端控制"
        }
        return tr("会议设置")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
       
        if indexPath.section == 1 {
            let vc = TimezoneViewController()
            vc.timezoneLists = timezoneList
            vc.selectCallBack = {(timezoneModel: TimezoneModel) in
                self.timezoneLabel.text = timezoneModel.timeZoneDesc
                self.timezoneModel = timezoneModel
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MeetAdvanceSetViewController:TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("打开摄像头需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("打开麦克风需要开启麦克风权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
    }
    
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        
    }
    
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        viewVC.dismiss(animated: true, completion: nil)
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
}
