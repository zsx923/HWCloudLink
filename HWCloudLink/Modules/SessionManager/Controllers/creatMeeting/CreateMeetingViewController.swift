//
//  CreateMeetingViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/10.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class CreateMeetingViewController: UITableViewController, UITextFieldDelegate, TextTitleViewDelegate  {
   
    //个人会议，虚拟会议switch
    @IBOutlet weak var vmrSwitch: UISwitch!
    //使用个人会议id文字
    @IBOutlet weak var leftLabel: UILabel!
    //主持人密码
    @IBOutlet weak var chairmanTitleLabel: UILabel!
    @IBOutlet weak var chairmanTextField: UITextField!
    //查看主持人密码，
    @IBOutlet weak var chairmanBtn: UIButton!
    // 会议类型
    @IBOutlet weak var meetingTypeTitleLabel: UILabel!
    @IBOutlet weak var meetingTypeLabel: UILabel!
    // 会议/主持人密码 - Switch 默认false
    @IBOutlet weak var passWordTitleSwitch: UILabel!
    @IBOutlet weak var passWordSwitch: UISwitch!
    // 密码 - TextField

    @IBOutlet weak var passwordTF: NoCopyTextField!
    //密码输入框的线，编辑时更改颜色
    @IBOutlet weak var passwordLine: UIView!
    //查看会议密码btn
    @IBOutlet weak var passWordBtn: UIButton!
    // 麦克风 - Switch
    @IBOutlet weak var microphoneTitleLabel: UILabel!
    @IBOutlet weak var microphoneSwitch: UISwitch!
    // 摄像头 - Switch
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var cameraSwitch: UISwitch!

    @IBOutlet weak var beginBtnRef: UIButton!
    //获取是否含有vmr 会议
    public var pass_hasVMR: Bool = false
    var  cloudInfo: ConfBaseInfo?
    private var isSure: Bool = false //没密码的状态下，确认继续
    private var disPlayNormal: Bool = true //密码在正常状态下是秘文
    public var isVoiceMeeting: Bool = false //是否是语音会议，默认为no，在语音会议状态下，直接不显示个人会议id一项
    var meetSubject: String = "" //会议主题
    var timer:Timer = Timer()
    private var type: MeetingType = .deafault {
        didSet{
            switch type {
            //2.0状态下只有视频会议，没有语音会议，切换到语音会议就是放弃了使用个人会议这个功能
            case .deafault:
                self.meetingTypeLabel.text = tr("视频会议")
                isVoiceMeeting = false
                if passWordSwitch.isOn && vmrSwitch.isOn {
                    passWordSwitch.isOn = false
                }
            default:
                self.meetingTypeLabel.text = tr("语音会议")
                isVoiceMeeting = true
            }
            self.tableView.reloadData()
        }
    }

//    weak var beginBtnRef: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // change at xuegd 2020-12-30 : 来宾密码/主持人密码默认密文显示
        passwordTF.isSecureTextEntry = true
        passWordBtn.isSelected = false
        chairmanTextField.isSecureTextEntry = true
        chairmanBtn.isSelected = false        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化默认数据
        setupUI()
        //加载vmr信息
//        self.loadVMRMeeting()
        //加载立即开始按钮
//        let beginBtn = UIButton.init(frame: CGRect(x: 16, y: SCREEN_HEIGHT - AppNaviHeight - 84, width: SCREEN_WIDTH - 32, height: 44))
//        beginBtn.setTitle("立即开始", for: .normal)
//        beginBtn.titleLabel?.font = font15
//        beginBtn.backgroundColor = UIColor.init(hexString: "#0D94FF")
//        beginBtn.layer.cornerRadius = 2
//        beginBtn.layer.masksToBounds = true
        beginBtnRef.addTarget(self, action: #selector(handleBeginBtnAction), for: .touchUpInside)
//        self.view.addSubview(beginBtn)
//        beginBtnRef = beginBtn
        
        // chenfan：断网后的样式
        _ = WelcomeViewController.checkNetworkAndUpdateUI()
        
        passWordBtn.setImage(UIImage(named: "password_eye"), for: .normal)
        // change at xuegd : 点击显示/隐藏密码，按钮图标对应
        passWordBtn.setImage(UIImage(named: "password_eye_open"), for: .selected)
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        //用户是否有vmr信息
//        NotificationCenter.default.addObserver(self, selector: #selector(getCurrentUserInfoList(noti:)), name: NSNotification.Name(CALL_S_CONF_EVT_GET_VMR_LIST_RESULT), object: nil);
        getVMRUserInfoList()
    }



    //MARK: - 获取用户vmr信息
    private func getVMRUserInfoList() {
        guard let accessNumber = ManagerService.confService()?.vmrBaseInfo.accessNumber, !accessNumber.isEmpty else {
            CLLog("2.0 当前账号无VMR信息")
            DispatchQueue.main.async {
                self.pass_hasVMR = false
                self.vmrSwitch.isOn = false
                self.tableView.reloadData()

            }
            return
        }
        self.cloudInfo = ManagerService.confService()?.vmrBaseInfo
        SessionManager.shared.cloudMeetInfo = ManagerService.confService().vmrBaseInfo
        CLLog("2.0 当前账号有VMR信息：accessNumber:\(NSString.encryptNumber(with: cloudInfo?.accessNumber) ?? "")")
        pass_hasVMR = true
        DispatchQueue.main.async {
            self.vmrSwitch.isOn = true
            self.leftLabel.text = tr("使用个人会议ID") + tr("：") + NSString.dealMeetingId(withSpaceString: self.cloudInfo?.accessNumber)
            self.chairmanTextField.text = self.cloudInfo?.chairmanPwd
            self.tableView.reloadData()
        }
      }
    //MARK: - 打开或者关闭个人会议
    @IBAction func personVmrSwitch(_ sw: UISwitch) {
        if sw.isOn {//使用个人会议，来宾密码要关闭
            beginBtnRef.isEnabled = true
            beginBtnRef.backgroundColor = UIColor.init(hexString: "#0D94FF")
            passWordSwitch.isOn = false
        }
//        else { //关闭了个人会议，主持人密码要打开
//            passWordSwitch.isOn = true
//        }
        tableView.reloadData()
    }
    //MARK: 主持人密码明文或者秘文显示
    @IBAction func chairmanSecureStatusBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            chairmanTextField.isSecureTextEntry = false
        } else {
            chairmanTextField.isSecureTextEntry = true
        }
        self.tableView.reloadData()
    }
    //MARK: 会议/主持人密码--打开关闭
    @IBAction func passwordClick(_ sender: UISwitch) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {

            sender.setOn(!sender.isOn, animated: true)
            return
        }
        
        if sender.isOn {
            if !vmrSwitch.isOn || isVoiceMeeting{
                beginBtnRef.isEnabled  = false
                beginBtnRef.backgroundColor = UIColor.init(hexString: "#CCCCCC")
            }
            // 清除密码
            passwordTF.text = ""
            // change at xuegd : 默认密文显示
            passwordTF.isSecureTextEntry = true
            passWordBtn.isSelected = false
        } else { //关闭主持人密码，如果未输入弹框提醒一下
            self.passwordTF.text = ""
            self.beginBtnRef.isEnabled  = true
            self.beginBtnRef.backgroundColor = UIColor.init(hexString: "#0D94FF")
            
//            let loginInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
//            let loginUserName = loginInfo?.account
//            let result = UserDefaults.standard.bool(forKey: "\(String(describing: loginUserName))" + "dangerAlert")
//            if !result && !isSure {//未输入密码，提示
//                let dangerView =  DangerStatementCustomView.creatDangerStatementCustomView()
//                dangerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//                dangerView.alertContentLabel.text = tr("当前会议未设置密码，存在安全风险，建议开启会议/主持人密码。")
//                self.view.addSubview(dangerView)
//                dangerView.passAlertStatementValueBlock = {( isAgree: Bool, isConfirm: Bool ) in
//                    if isAgree && isConfirm { //同时选中了提示框 和 确认，已知晓风险提示，其余状态不作处理
//                        UserDefaults.standard.set(true, forKey: "\(String(describing: loginUserName))" + "dangerAlert")
//                        self.passwordTF.text = ""
//
//                    } else if isConfirm {
//                        self.passwordTF.text = ""
//                    }else  { //选择了取消，此时再打开switch
//                        self.passWordSwitch.isOn = true
//                        if !self.vmrSwitch.isOn {
//                            self.beginBtnRef.isEnabled  = false
//                            self.beginBtnRef.backgroundColor = UIColor.init(hexString: "#CCCCCC")
//                        }
//
//                    }
//                    self.tableView.reloadData()
//                }
//
//            }
            
        }
        self.tableView.reloadData()
    }
    //MARK: - 密码是明文还是秘文显示
    @IBAction func changeSecureStatusClick(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            self.passwordTF.isSecureTextEntry = true
        } else {
            self.passwordTF.isSecureTextEntry = false
            sender.isSelected = true
        }
        tableView.reloadData()
    }
    //MARK: -  打开关闭 麦克风
    @IBAction func microphoneClick(Switch:UISwitch) {
        // 当前是关闭状态，先判断权限，未授权弹框，授权直接打开即可
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { (isAuto) in
            if !isAuto {// 未授权 弹出授权框
                UserDefaults.standard.set(false, forKey: CurrentUserMicrophoneStatus)
                self.microphoneSwitch.isOn = false
                self.getAuthAlertWithAccessibilityValue(value: "20")
            }else { // 设置关闭麦克风
                UserDefaults.standard.set(Switch.isOn, forKey: CurrentUserMicrophoneStatus)
            }
        }
        
    }
    //MARK: -  打开关闭 摄像头
    @IBAction func cameraClick(Switch:UISwitch) {  // 当前是关闭状态，先判断权限，未授权弹框，授权直接打开即可
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone { (isAuto) in
            if !isAuto { // 未授权
                UserDefaults.standard.set(false, forKey: CurrentUserCameraStatus)
                self.cameraSwitch.isOn = false
                // 弹出授权框，处理结果在下面的代理方法中
                self.getAuthAlertWithAccessibilityValue(value: "10")
            }else { // 打开摄像头
                UserDefaults.standard.set(Switch.isOn, forKey: CurrentUserCameraStatus)
            }
        }
        
    }
    
    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    private func setupUI() {
        // 初始化
        self.title = tr("发起会议")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.meetingTypeTitleLabel.text = tr("会议类型")
        self.chairmanTitleLabel.text = tr("主持人密码")
        self.passWordTitleSwitch.text = tr("会议/主持人密码")
//        self.passwordTitleTF.text = tr("会议/主持人密码")
        self.passwordTF.placeholder = tr("请输入1-6位数字密码")
        self.microphoneTitleLabel.text = tr("麦克风")
        self.cameraTitleLabel.text = tr("摄像头")
                
        let userInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
        if userInfo != nil {
            if HWLoginInfoManager.shareInstance.isSuccessGetName() {
                if let name = UserDefaults.standard.object(forKey: DICT_SAVE_NIC_NAME) as? String {
                    self.meetSubject = name
                    self.subjectMaxCountSet()
                    let text = String(format: tr("%@的会议"), self.meetSubject)
                    self.meetSubject = text
                }
            }else{
                if let name = userInfo?.account {
                    self.meetSubject = name
                }
                if !HWLoginInfoManager.shareInstance.isSuccessGetName() {
                    HWLoginInfoManager.shareInstance.getLoginInfoByCorporateDirectory()
                    HWLoginInfoManager.shareInstance.getLoginInfoBack = { (_ name:String) in
                        self.meetSubject = name
                        self.subjectMaxCountSet()
                        let text = String(format: tr("%@的会议"), self.meetSubject)
                        self.meetSubject = text
                    }
                }
            }
        }
        self.meetingTypeLabel.text = tr("视频会议")
        self.passwordTF.isSecureTextEntry = true
        self.passwordTF.delegate = self
        self.passwordTF.keyboardType = .numberPad
        self.passWordSwitch.setOn(false, animated: true)
        self.chairmanTextField.isSecureTextEntry = true
        // 设置摄像头和麦克风，从本地读取数据
        let micro = UserDefaults.standard.bool(forKey: CurrentUserMicrophoneStatus)
        self.microphoneSwitch.isOn = micro
        let camer = UserDefaults.standard.bool(forKey: CurrentUserCameraStatus)
        self.cameraSwitch.isOn =  camer
        CLLog("====createMeetimg:micro:\(micro),camer:\(camer)")
        // 选中颜色
        self.microphoneSwitch.onTintColor = UIColor(hexString: "#4392F7")
        self.cameraSwitch.onTintColor = UIColor(hexString: "#4392F7")
        self.passWordSwitch.onTintColor = UIColor(hexString: "#4392F7")
        vmrSwitch.onTintColor = UIColor(hexString: "#4392F7")
        // 正常颜色
        self.microphoneSwitch.tintColor = UIColor(hexString: "#CCCCCC")
        self.cameraSwitch.tintColor = UIColor(hexString: "#CCCCCC")
        self.passWordSwitch.tintColor = UIColor(hexString: "#CCCCCC")
        vmrSwitch.tintColor = UIColor(hexString: "#CCCCCC")
        
        self.leftLabel.text = tr("使用个人会议ID") + tr("：")
        self.beginBtnRef.setTitle(tr("立即开始"), for: .normal)
    }
    //会议名称设置
    func subjectMaxCountSet() {
        let maxCount = 55
        if meetSubject.getLenthOfBytes() > maxCount {
            meetSubject = meetSubject.subBytesOfstring(to: maxCount)
        }
    }
    //MARK:  立即开始 会议 --  普通会议 --- VMR 会议
    @objc func handleBeginBtnAction() {
        passwordTF.resignFirstResponder()
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        if self.type == .deafault {
            if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
                self.getAuthAlertWithAccessibilityValue(value: "10")
                return
            }
            if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
                self.getAuthAlertWithAccessibilityValue(value: "20")
                return
            }
        } else if type == .voice {
            if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
                self.getAuthAlertWithAccessibilityValue(value: "20")
                return
            }
        }
        SessionManager.shared.isJoinImmediately = true
        NotificationCenter.default.removeObserver(self)
        if isVoiceMeeting { // 语音会议，一定是普通会议
            CLLog("创建了普通语音会议")
            self.creatCommentMeeting()
        } else { // 视频会议存在是否是vmr会议
            if vmrSwitch.isOn { //虚拟会议
                CLLog("创建了vmr视频会议")
                self.creatVMRMeet()
            } else {//立即开始会议
                CLLog("创建了普通视频会议")
                self.creatCommentMeeting()
            }
        }
    }
    
    func showCreateMeetingFailAlert() {
        SessionManager.shared.isMeetingVMR = false
        SessionManager.shared.isSelfPlayCurrentMeeting = false
        SessionManager.shared.isBeInvitation = false
        SessionManager.shared.isJoinImmediately = false
        MBProgressHUD.hide()
        MBProgressHUD.showBottom(tr("创建会议失败"), icon: nil, view: nil)
    }
    
    func creatVMRMeet() {
        MBProgressHUD.showMessage(tr("创建会议中") + "...")
        SessionManager.shared.isMeetingVMR = true
        SessionManager.shared.isSelfPlayCurrentMeeting = true
        self.cloudInfo?.isConf = true
        self.cloudInfo?.isImmediately = true
        // 实际： 先获取会议详情 -- 已和SDK确认，没有会议详情接口
        let number = ManagerService.call()?.terminal
        let creatSuccess = ManagerService.confService()?.joinConference(withConfId: self.cloudInfo?.confId, accessNumber: self.cloudInfo?.accessNumber, confPassWord: self.cloudInfo?.generalPwd, joinNumber: number, isVideoJoin: true) ?? false
        CLLog("2.0发起虚拟会议result:\(String(describing: creatSuccess)),confId:\(NSString.encryptNumber(with: self.cloudInfo?.confId) ?? ""),accessNumber:\(String(describing: self.cloudInfo?.accessNumber))),terminal:\(NSString.encryptNumber(with: number) ?? "")")
        
        guard creatSuccess else {
            showCreateMeetingFailAlert()
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 创建普通会议
    func creatCommentMeeting(){
        if passWordSwitch.isOn {
            if self.passwordTF.text != nil && !NSString.isNum(passwordTF.text) {
                MBProgressHUD.showBottom(tr("会议密码仅支持数字"), icon: nil, view: self.view)
                self.view.endEditing(true)
                return
            }
            if passwordTF.text?.count == 0  {
                MBProgressHUD.showBottom(tr("请输入1-6位数字密码"), icon: nil, view: self.view)
                return
            }
        }
        MBProgressHUD.showMessage(tr("创建会议中") + "...")
        SessionManager.shared.isMeetingVMR = false
        SessionManager.shared.isSelfPlayCurrentMeeting = true
        SessionManager.shared.chairPassword = self.passwordTF.text
        var attendeeArray:[LdapContactInfo] = []
        let ldapInfo = LdapContactInfo.init()
        let myName = NSString.getSipaccount(ManagerService.call()?.sipAccount)
        ldapInfo.name = HWLoginInfoManager.shareInstance.isSuccessGetName() ? (UserDefaults.standard.object(forKey: DICT_SAVE_NIC_NAME) as? String) : myName
        ldapInfo.number = ManagerService.call()?.terminal
        ldapInfo.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
        ldapInfo.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
        attendeeArray.append(ldapInfo)
        // 会议类型
        let meetingType = (type == .deafault) ? CONF_MEDIATYPE_VIDEO : CONF_MEDIATYPE_VOICE 
        let creatSuccess = ManagerService.confService()?.creatCommonConference(withAttendee: attendeeArray, mediaType: meetingType, subject: meetSubject, password: passwordTF.text ?? "") ?? false
        
        CLLog("2.0创建普通会议result:\(String(describing: creatSuccess)),mediaType:\(meetingType),subject:\(NSString.encryptNumber(with: meetSubject) ?? "")")
        
        guard creatSuccess else {
            showCreateMeetingFailAlert()
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
} 
//MARK: - tableview 代理方法
extension CreateMeetingViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isVoiceMeeting { //语音会议
            if 1 == indexPath.row || 2 == indexPath.row {
                return 0.01
            }else if 4 == indexPath.row {
                if passWordSwitch.isOn {
                    return 54
                } else {
                    return 0.01
                }
            }else if 6 == indexPath.row {
                return 0.01
            }
            
        } else { // 此时会视频会议
            if 1 == indexPath.row {
                if pass_hasVMR {
                    return 54
                } else {
                    return 0.01
                }
            } else if 2 == indexPath.row {
                if vmrSwitch.isOn {
                    return 54
                } else {
                    return 0.01
                }
            } else if 3 == indexPath.row {
                if vmrSwitch.isOn {
                    return 0.01
                } else {
                    return 54
                }
            } else if 4 == indexPath.row {
                if passWordSwitch.isOn {
                    return 54
                } else{
                    return 0.01
                }
            }else if 6 == indexPath.row {
                return 54
            }
        } 
        return 54
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isVoiceMeeting { //语音会议
            if 1 == indexPath.row || 2 == indexPath.row {
                cell.isHidden = true
            }else if 3 == indexPath.row {
                cell.isHidden = false
            }else if 4 == indexPath.row {
                if passWordSwitch.isOn {
                    cell.isHidden = false
                } else {
                    cell.isHidden = true
                }
            }else if 6 == indexPath.row {
                cell.isHidden = true
            }
            
        } else { // 此时会视频会议
            if 1 == indexPath.row {
                if pass_hasVMR {
                    cell.isHidden = false
                } else {
                    cell.isHidden = true
                }
            } else if 2 == indexPath.row {
                if vmrSwitch.isOn {
                    cell.isHidden = false
                } else {
                    cell.isHidden = true
                }
            } else if 3 == indexPath.row {
                if vmrSwitch.isOn {
                    cell.isHidden = true
                } else {
                    cell.isHidden = false
                }
            } else if 4 == indexPath.row {
                if passWordSwitch.isOn {
                    cell.isHidden = false
                } else{
                    cell.isHidden = true
                }
            }else if 6 == indexPath.row {
                cell.isHidden = false
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            let meetingTypeSetVC = MeetingTypeSetViewController.init()
            meetingTypeSetVC.typeComeBack = {[weak self]type in
                if self?.type != type {
                    self?.type = type
                }
            }
            meetingTypeSetVC.type = type
            self.navigationController?.pushViewController(meetingTypeSetVC, animated: true)
        }
    }
 
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
//MARK: - textfield 代理方法
extension CreateMeetingViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //((textField.text ?? "").count >= 6) ? false : true
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        if nowString.count>0 {
            beginBtnRef.isEnabled  = true
            beginBtnRef.backgroundColor = UIColor.init(hexString: "#0D94FF")
        }
        return nowString.count <= 6
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
         if textField == passwordTF {
            self.passwordLine.backgroundColor = UIColor(hexString: "0D94FF")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         if textField == passwordTF {
            self.passwordLine.backgroundColor = UIColor.colorWithSystem(lightColor: "#E9E9E9", darkColor: "#1F1F1F")
        }
    }
}
//MARK: - 密码弹出框代理方法
extension CreateMeetingViewController {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("发起会议需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("发起会议需要开启麦克风权限")
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
}
//MARK: - 加载虚拟会议信息
//extension CreateMeetingViewController {
//    private func loadVMRMeeting() {
//        MBProgressHUD.showMessage("")
//       let result = ManagerService.confService()?.getVmrList()
//        if result == true {
//            CLLog("2.0 获取VMR信息接口调用成功")
//        } else{
//            CLLog("2.0 获取VMR信息接口调用失败")
//        }
//    }
//    //MARK: - 获取用户vmr信息
//    @objc func getCurrentUserInfoList(noti:Notification){
//        DispatchQueue.main.async {
//            MBProgressHUD.hide()
//        }
//        CLLog("2.0 获取VMR信息返回信息")
//        if noti.userInfo != nil  {
//            let result = noti.userInfo!["VIRTUAL_MEETING_ROOM_LIST_KEY"] as? ConfBaseInfo
//            if  result != nil  {
//                if result!.accessNumber.count > 0  {
//                    CLLog("2.0 当前账号有VMR信息：accessNumber:\(String(describing: result?.accessNumber)),chairmanPwd:\(String(describing: result?.chairmanPwd)),generalNum:\(String(describing: result?.generalPwd))")
//                    pass_hasVMR = true
//                    self.cloudInfo = result!
//                    SessionManager.shared.cloudMeetInfo = self.cloudInfo
//                    DispatchQueue.main.async {
//                        self.vmrSwitch.isOn = true
//                        self.vmrIdLabel.text = self.cloudInfo.accessNumber
//                        self.chairmanTextField.text = self.cloudInfo.chairmanPwd
//                        self.tableView.reloadData()
//                    }
//                } else {
//                    CLLog("2.0 当前账号无VMR信息：accessNumber:\(result!.accessNumber ?? "0"),chairmanPwd:\(result!.chairmanPwd ?? "0"),generalNum:\(result!.generalPwd ?? "0")")
//                    DispatchQueue.main.async {
//                        self.pass_hasVMR = false
//                        self.vmrSwitch.isOn = false
//                        self.tableView.reloadData()
//                    }
//                }
//            }else{
//                CLLog("2.0 获取VMR信息noti.userInfo为空")
//            }
//        }
//
//    }
//}


//MARK: - 返回或者页面消失
extension CreateMeetingViewController{
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
extension CreateMeetingViewController {
    /// - Parameter typeCode: 类型code
    static func getMeetTypeShowName(typeCode: String?) -> String {
        if typeCode == nil {
            return "视频会议"
        }
        switch typeCode {
        case "0":
            return "语音会议"
        case "1":
            return "视频会议"
        case "2":
            return "多媒体会议"
        case "3":
            return "视频+多媒体会议"
        case "4":
            return "桌面共享会议"
        default:
            CLLog("not define.")
        }
        
        return ""
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

