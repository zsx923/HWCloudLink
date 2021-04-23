//
//  CreatMeetingThreeVersionViewController.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/12/8.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class CreatMeetingThreeVersionViewController: UITableViewController , UITextFieldDelegate, TextTitleViewDelegate  {
                          
    // 会议类型
    @IBOutlet weak var meetingTypeTitleLabel: UILabel!
    @IBOutlet weak var meetingTypeLabel: UILabel!
     //个人会议，虚拟会议switch
    @IBOutlet weak var vmrSwitch: UISwitch!
     //使用个人会议id文字信息
    @IBOutlet weak var leftLabel: UILabel!

    @IBOutlet weak var generalLabel: UILabel! //zai3。0下显示来宾密码
    
    // 会议/主持人密码 - Switch
    @IBOutlet weak var passWordSwitch: UISwitch!
    // 来宾密码 - TextField
    @IBOutlet weak var passwordTF: NoCopyTextField!
    // change at xuegd 2020-12-29 : 显示/隐藏密码
    @IBOutlet weak var hideEye: UIButton!
    // 麦克风 - Switch
    @IBOutlet weak var microphoneTitleLabel: UILabel!
    @IBOutlet weak var microphoneSwitch: UISwitch!
     // 摄像头 - Switch
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var vmrTipsLabel: UILabel!
    
    @IBOutlet weak var beginBtnRef: UIButton!
    @IBOutlet weak var passwordLine: UIView! //编辑密码的时候，更改颜色
    var subject: String = "" //会议主题
    var  cloudInfo: ConfBaseInfo?
    private var isSure: Bool = false //没密码的状态下，确认继续
    private var disPlayNormal: Bool = true //密码在正常状态下是秘文
    public var isVoiceMeeting: Bool = false //默认视频会议
    private var isGeneralPwdSet :Bool = false //来宾密码修改
    private var generalPassword = ""
//    public var needOpen: Bool = false //是否是打开状态，只用来控制来宾密码输入行是否显示
//    private var tempSecureStr: String = ""
    var vmrAccessNumber: String = ""
    var vmrChairPwd: String = ""
    var vmrGeneralPwd: String = ""
    var hasVMR:Bool = true
    var randomStr: String = "" //进入页面赋初值 6位
    private var type: MeetingType = .deafault {
        didSet{
            switch type {
            case .deafault:
                self.meetingTypeLabel.text = tr("视频会议")
                isVoiceMeeting = false
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
        // change at xuegd 2020-12-29 : 密码默认隐藏
        self.passwordTF.isSecureTextEntry = true

        self.hideEye.isSelected = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.meetingTypeTitleLabel.text = tr("会议类型")
        self.microphoneTitleLabel.text = tr("麦克风")
        self.cameraTitleLabel.text = tr("摄像头")
        self.passwordTF.placeholder = tr("请输入1-6位数字密码")
        
        tableView.delegate = self; tableView.dataSource = self
        //用户是否有vmr信息
//        NotificationCenter.default.addObserver(self, selector: #selector(getCurrentUserInfoList(noti:)), name: NSNotification.Name(CALL_S_CONF_EVT_GET_VMR_LIST_RESULT), object: nil);
        //vmr信息更新收到的通知
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUpdateVMRInfo(noti:)), name: NSNotification.Name("updateVMRResult"), object: nil)
//        self.loadVMRMeeting()
        setupUI()
        //加载立即开始按钮
//        let beginBtn = UIButton.init(frame: CGRect(x: 16, y: SCREEN_HEIGHT - AppNaviHeight - 84, width: SCREEN_WIDTH - 32, height: 44))
//        beginBtn.setTitle("立即开始", for: .normal)
//        beginBtn.titleLabel?.font = font15
//        beginBtn.backgroundColor = UIColor.init(hexString: "#0D94FF")
//        beginBtn.layer.cornerRadius = 2
//        beginBtn.layer.masksToBounds = true
        beginBtnRef.addTarget(self, action: #selector(handleBeginBtnAction), for: .touchUpInside)
//        self.view.addSubview(beginBtn)

        
        // chenfan：断网后的样式
        _ = WelcomeViewController.checkNetworkAndUpdateUI()
        //获取VMR信息
        getVMRUserInfoList()
    }


    //MARK: - 获取用户vmr信息
    private func getVMRUserInfoList() {
        guard let accessNumber = ManagerService.confService()?.vmrBaseInfo.accessNumber, !accessNumber.isEmpty else {
            CLLog("3.0 当前账号无VMR信息")
            DispatchQueue.main.async {
                self.hasVMR = false
                self.passWordSwitch.isOn = true
                self.vmrSwitch.isOn = false
                self.randomStr = String(self.getRamdomNum())
                self.tableView.reloadData()

            }
            return
        }
        self.cloudInfo = ManagerService.confService().vmrBaseInfo
        self.passWordSwitch.isOn = cloudInfo?.generalPwd != ""

        self.passwordTF.text = cloudInfo?.generalPwd
        self.generalPassword = cloudInfo?.generalPwd ?? ""

        CLLog("3.0 当前账号有VMR信息：accessNumber:\(NSString.encryptNumber(with: cloudInfo?.accessNumber) ?? ""))")
        vmrAccessNumber = cloudInfo!.accessNumber  // "9152782"
        vmrChairPwd = cloudInfo!.chairmanPwd
        vmrGeneralPwd = cloudInfo!.generalPwd
        vmrSwitch.isOn = true
        hasVMR = true
        DispatchQueue.main.async {

            self.leftLabel.text = tr("使用个人会议ID") + tr("：") + NSString.dealMeetingId(withSpaceString: self.vmrAccessNumber)
            self.vmrTipsLabel.text = tr("您的当前操作将用于个人会议ID:") + NSString.dealMeetingId(withSpaceString: self.vmrAccessNumber) + tr("的全部会议")
//            var temp = self.vmrAccessNumber
//            let index =  temp.index(temp.startIndex, offsetBy: 3)
//            temp.insert(" ", at: index)

            if self.vmrGeneralPwd == "" ,!self.vmrSwitch.isOn,self.passWordSwitch.isOn{
                self.passwordTF.text = String(self.getRamdomNum())
            } else {
                self.passwordTF.text = self.vmrGeneralPwd
            }

            self.tableView.reloadData()
        }
    }
    
    //MARK: 使用个人会议id 打开关闭
    @IBAction func useVMRSwitch(_ sender: UISwitch) {
        self.isGeneralPwdSet = false
        if sender.isOn {//个人会议id 打开状态
            if passWordSwitch.isOn == true {//来宾密码开启状态
                self.isGeneralPwdSet = true
                passwordTF.text =  vmrGeneralPwd
            }
        } else { // 个人会议id 关闭状态，此时是普通会议
            if passWordSwitch.isOn == true { // 来宾密码打开状态，显示原密码
                randomStr  = String(self.getRamdomNum())
            }else{ // 来宾密码关闭状态，来宾密码随机数
                randomStr = ""
            }
        }
        tableView.reloadData()
    }
    //MARK: 来宾密码 打开关闭
    @IBAction func passwordClick(_ sender: UISwitch) {

        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            sender.setOn(!sender.isOn, animated: true)
            return
        }
        
        // change at xuegd 2020-12-29 : 密码默认为隐藏状态
        self.passwordTF.isSecureTextEntry = true
        self.hideEye.isSelected = false
        if sender.isOn {// 来宾密码打开
            if vmrSwitch.isOn == true { // 两个都打开状态
                self.isGeneralPwdSet = true
                if vmrGeneralPwd.isEmpty {
                    randomStr = ""
//                    randomStr =  String(self.getRamdomNum())
//                    vmrGeneralPwd = randomStr
                } else {
                    passwordTF.text = vmrGeneralPwd
                }
            } else { // 此时vmr 关闭
                randomStr = String(self.getRamdomNum())
            }
        } else {
            if vmrSwitch.isOn { //使用个人随机id ，弹出提示框
                let result = LocalVMRInfoManager.getGeneralPwdAlertViewStatus()
                if result == false  { //弹窗处理
                    let dangerView =  DangerStatementCustomView.creatDangerStatementCustomView()
                    dangerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                    dangerView.contentStr = tr("来宾密码关闭后，所有个人会议ID:") + vmrAccessNumber + tr("相关会议密码全部关闭，当前操作存在安全风险，建议开启来宾密码。")
                    self.view.addSubview(dangerView)
                    dangerView.passAlertStatementValueBlock = { [self]( isAgree: Bool, isConfirm: Bool ) in
                        if isConfirm {//选了确认，
                            self.passWordSwitch.isOn = false
                            self.isGeneralPwdSet = false
                            self.passwordTF.text = ""
                            self.vmrGeneralPwd = ""
                            self.updateVMRInfo()
                            if isAgree {//同时选中了提示框 和 确认，
                                LocalVMRInfoManager.updateGeneralPwdAlertViewStatus()
                            }
                        } else {
                            self.passWordSwitch.isOn = true
                            self.tableView.reloadData()
                        }
                    }
                } else { //不需要弹窗处理
                    self.passwordTF.text = ""
                    self.vmrGeneralPwd = ""
                    self.isGeneralPwdSet = false
                    print("5555555")
                    self.updateVMRInfo()
                    self.tableView.reloadData()
                }
            } else {//不使用个人随机id，弹出一种提示框
                //关闭主持人密码，如果未输入弹框提醒一下
                let loginInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
                let loginUserName = loginInfo?.account
                let result = UserDefaults.standard.bool(forKey: "\(String(describing: loginUserName))" + "dangerAlert")
                if !result && !isSure {//未输入密码，提示
                    let dangerView =  DangerStatementCustomView.creatDangerStatementCustomView()
                    dangerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                    self.view.addSubview(dangerView)
                    dangerView.passAlertStatementValueBlock = {( isAgree: Bool, isConfirm: Bool ) in
                        if isConfirm {
                            self.randomStr = ""
                            if  isAgree {
                                self.isGeneralPwdSet = false
                                UserDefaults.standard.set(true, forKey: "\(String(describing: loginUserName))" + "dangerAlert")
                            }
                        } else {
                            self.passWordSwitch.isOn = true
                            self.tableView.reloadData()
                        }
                    }
                } else { //不用弹窗提示
                    randomStr = ""
                    self.tableView.reloadData()
                }
            }
        }
        self.tableView.reloadData()
    }
    //MARK: - 会议密码明文或者秘文显示
    @IBAction func changeSecureStatusClick(_ sender: UIButton) {
        // change at xuegd 2020-12-29 : 密码默认为隐藏状态
        sender.isSelected = !sender.isSelected
        self.passwordTF.isSecureTextEntry = !sender.isSelected
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
    @IBAction func cameraClick(Switch:UISwitch) {
        // 当前是关闭状态，先判断权限，未授权弹框，授权直接打开即可
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
        let userInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
        if userInfo != nil {
            if HWLoginInfoManager.shareInstance.isSuccessGetName() {
                self.subject = UserDefaults.standard.object(forKey: DICT_SAVE_NIC_NAME) as? String ?? ""
                self.subjectMaxCountSet()
                let text = String(format: tr("%@的会议"), self.subject)
                self.subject = text
            }else{
                self.subject = userInfo?.account ?? ""
                if !HWLoginInfoManager.shareInstance.isSuccessGetName() {
                    HWLoginInfoManager.shareInstance.getLoginInfoByCorporateDirectory()
                    HWLoginInfoManager.shareInstance.getLoginInfoBack = { (_ name:String) in
                        self.subjectMaxCountSet()
                        let text = String(format: tr("%@的会议"), name)
                        self.subject = text
                    }
                }
            }
        }
        self.meetingTypeLabel.text = tr("视频会议")
        self.passwordTF.isSecureTextEntry = true
        self.passwordTF.delegate = self
        self.passwordTF.keyboardType = .numberPad

        self.passwordTF.delegate = self
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
        self.tableView.separatorStyle = .none
        passWordSwitch.isOn = true
        vmrSwitch.isOn = true
        if ManagerService.call()?.isSMC3 == true {
            generalLabel.text = tr("来宾密码")
        }
        //从本地获取摄像头麦克风开关状态
        let micro = UserDefaults.standard.bool(forKey: CurrentUserMicrophoneStatus)
        microphoneSwitch.isOn =  micro
        let camer = UserDefaults.standard.bool(forKey: CurrentUserCameraStatus)
        cameraSwitch.isOn =  camer
        tableView.reloadData()
        
        self.leftLabel.text = tr("使用个人会议ID") + tr("：")
        self.beginBtnRef.setTitle(tr("立即开始"), for: .normal)
    }
    //会议名称设置
    func subjectMaxCountSet() {
        let maxCount = 55
        if subject.getLenthOfBytes() > maxCount {
            subject = subject.subBytesOfstring(to: maxCount)
        }
    }
    //MARK:  立即开始 会议
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
        
        if self.vmrSwitch.isOn && passWordSwitch.isOn { // 虚拟会议并且有密码
            if passwordTF.text?.count == 0 {
                 MBProgressHUD.showBottom(tr("请输入1-6位数字密码"), icon: nil, view: self.view)
                return
            }
            if self.passwordTF.text != nil && !NSString.isNum(passwordTF.text) {
                MBProgressHUD.showBottom(tr("会议密码仅支持数字"), icon: nil, view: self.view)
                self.view.endEditing(true)
                return
            }
        }
        SessionManager.shared.isJoinImmediately = true
//        NotificationCenter.default.removeObserver(self)
        if vmrSwitch.isOn == true { //虚拟会议
            SessionManager.shared.isSelfPlayCurrentMeeting = true
            SessionManager.shared.isMeetingVMR = true
            self.cloudInfo?.isConf = true
            self.cloudInfo?.isImmediately = true
//            self.navigationController?.popViewController(animated: true)
            // 实际： 先获取会议详情 -- 已和SDK确认，没有会议详情接口
            if !self.isGeneralPwdSet {
                if passwordTF.text != self.generalPassword {
                    self.isGeneralPwdSet = true
                    self.updateVMRInfo()
                    return
                }
                self.creatVMRMeet()
                CLLog("3.0创建了VMR会议")
                return
            }
            self.updateVMRInfo()

        } else {//立即开始普通会议
            CLLog("3.0创建了普通会议")
            self.creatCommentMeeting()
        }
    }
}
extension CreatMeetingThreeVersionViewController {
    private func creatCommentMeeting() {
        SessionManager.shared.isMeetingVMR = false
        SessionManager.shared.isSelfPlayCurrentMeeting = true
        MBProgressHUD.showMessage(tr("创建会议中") + "...")
        var attendeeArray:[LdapContactInfo] = []
        if let info = ManagerService.call()?.ldapContactInfo {
            attendeeArray.append(info)
            CLLog("ldapContactInfo有数据")
        } else {
            CLLog("ldapContactInfo没有获取到数据")
        }
        ManagerService.confService()?.vmrBaseInfo.generalPwd = self.passwordTF.text
        // 会议类型
        let meetingType = (type == .deafault) ? CONF_MEDIATYPE_VIDEO : CONF_MEDIATYPE_VOICE 
        let creatSuccess = ManagerService.confService()?.creatCommonConference(withAttendee: attendeeArray, mediaType: meetingType, subject: subject, password: randomStr) ?? false
        
        CLLog("3.0创建普通会议结果result=====:::\(String(describing: creatSuccess))，subject:\(NSString.encryptNumber(with: subject) ?? ""),meetType:\(meetingType)")
        
        guard creatSuccess else {
            showCreateMeetingFailAlert()
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func showCreateMeetingFailAlert() {
        SessionManager.shared.isMeetingVMR = false
        SessionManager.shared.isSelfPlayCurrentMeeting = false
        SessionManager.shared.isBeInvitation = false
        SessionManager.shared.isJoinImmediately = false
        MBProgressHUD.hide()
        MBProgressHUD.showBottom(tr("创建会议失败"), icon: nil, view: nil)
    }
}
//MARK: - 发起3.0VMR 会议
extension CreatMeetingThreeVersionViewController {
    func creatVMRMeet() {
        MBProgressHUD.showMessage(tr("创建会议中") + "...")
        var attendeeArrays:[LdapContactInfo] = []
        if let info = ManagerService.call()?.ldapContactInfo {
            attendeeArrays.append(info)
        }
        // 会议类型
        let meetingType = (self.type == .deafault) ? CONF_MEDIATYPE_VIDEO : CONF_MEDIATYPE_VOICE
        SessionManager.shared.isMeetingVMR = true
        let cloundInfo = ConfBaseInfo()
        cloundInfo.confId = self.vmrChairPwd
        cloundInfo.accessNumber = self.vmrAccessNumber
        cloundInfo.chairmanPwd = self.vmrChairPwd
        SessionManager.shared.cloudMeetInfo = cloundInfo
        let creatSuccess = ManagerService.confService()?.createVMRConference(withAttendee: attendeeArrays, mediaType: meetingType, subject: self.subject, confId: vmrAccessNumber, chairPwd: vmrChairPwd, generalPwd: passwordTF.text ?? "") ?? false
        CLLog("3.0创建vmr会议结果result:\(String(describing: creatSuccess)),type:\(meetingType))===accessNum:\(NSString.encryptNumber(with: vmrAccessNumber) ?? "")")
        
        guard creatSuccess else {
            showCreateMeetingFailAlert()
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - tableview 代理方法
extension CreatMeetingThreeVersionViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if hasVMR {
            if 1 == indexPath.row {
                return 54
            }
            if 3 == indexPath.row {
                return  (vmrSwitch.isOn ? (passWordSwitch.isOn ? 54 : 0.01):0.01)
            }
            if  4 == indexPath.row {
                return (vmrSwitch.isOn ? 54 : 0.01)
            }
        } else {
            if 1 == indexPath.row || 3 == indexPath.row || 4 == indexPath.row{
                return 0.01
            }
        }
        //控制摄像头是否显示，单独处理
        if 6 == indexPath.row {
            if type == .voice {
                return 0.01
            }else {
                return 54
            }
        }
        return 54
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if hasVMR {
            if 1 == indexPath.row || 4 == indexPath.row {
                cell.isHidden = false
            }

            if 3 == indexPath.row {
                cell.isHidden = passWordSwitch.isOn ? false :true
            }
        } else {
            if 1 == indexPath.row || 3 == indexPath.row || 4 == indexPath.row{
                cell.isHidden = true
            }
        }
        //控制摄像头是否显示，单独处理
        if 6 == indexPath.row {
            if type == .voice {
                cell.isHidden = true
            }else {
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
extension CreatMeetingThreeVersionViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //((textField.text ?? "").count >= 6) ? false : true
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        
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
extension CreatMeetingThreeVersionViewController {
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
//MARK: - 加载虚拟会议信息  --
extension CreatMeetingThreeVersionViewController {
    private func loadVMRMeeting() {
        MBProgressHUD.showMessage("")
        let result = ManagerService.confService()?.getVmrList()
         if result == true {
             CLLog("3.0 获取VMR信息接口调用成功")
         } else{
             CLLog("3.0 获取VMR信息接口调用失败")
         }
    }
    //修改来宾密码
    @objc func receiveUpdateVMRInfo(noti:Notification){
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            guard let result = noti.userInfo?["result"] as? String else {
                return
            }

            if "0" == result {
                ManagerService.confService()?.vmrBaseInfo.generalPwd = self.passwordTF.text
                MBProgressHUD.showBottom(tr("来宾密码修改成功"), icon: nil, view: self.tableView)
                if self.isGeneralPwdSet == true{
                    CLLog("3 创建了VMR会议")
                    self.creatVMRMeet()
                }
            } else {
                MBProgressHUD.showBottom(tr("密码修改失败，请稍后重试"), icon: nil, view: self.tableView)
            }
        }
        
    }
}


//MARK: - 返回或者页面消失
extension CreatMeetingThreeVersionViewController{
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
extension CreatMeetingThreeVersionViewController {
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
//        UIApplication.shared.keyWindow?.endEditing(true)
        self.view.endEditing(true)
    }

    func updateVMRInfo(){
        getVmrGeneralPassword()
        let result = ManagerService.confService()?.updateVmrList(vmrChairPwd, generalStr: vmrGeneralPwd, confId: vmrAccessNumber)
        CLLog("3.0更新vmr信息返回结果result::::\(String(describing: result))===AccessNumber:\(vmrAccessNumber)")

    }
    func getVmrGeneralPassword () {
        CLLog("更新了来宾密码")
        if hasVMR {
            if vmrSwitch.isOn == true {
                vmrGeneralPwd = passwordTF.text ?? ""
            } else {
                randomStr = passwordTF?.text ?? ""
            }
        } else {
            randomStr = passwordTF.text ?? ""
        }
    }
    
    //3。0状态下获取随机6位数密码
    func getRamdomNum() -> NSInteger {
        let result = Int(arc4random_uniform(899999) + 100000)
        return result
    }
    
    
}
