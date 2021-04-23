//
//  AddMeetingViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/10.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
//AlertSingleTextFieldViewDelegate
class JoinMeetingViewController: UITableViewController,UITextFieldDelegate ,TextTitleViewDelegate{
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var meetingIDTextField: UITextField!
    //麦克风和摄像头switch
    @IBOutlet weak var microSwitch: UISwitch!
    @IBOutlet weak var cameraSwitch: UISwitch!
    
    @IBOutlet weak var joinConfBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var meetingIDTitle: UILabel!
    
    @IBOutlet weak var microTitle: UILabel!
    
    @IBOutlet weak var cameraTitle: UILabel!
    
    let btnArrow = UIButton(type: .custom)
    
    
    //加入会议的回调通知，点击加入会议，回调到首页，做处理
     var passJoinMeetBlock:((_ isYES: Bool) -> Void)?
    
    var meetingHistory = [MeetingHistoryModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tr("加入会议")
        
        self.meetingIDTitle.text = tr("会议ID")
        self.meetingIDTextField.placeholder = tr("请输入会议ID")
        self.microTitle.text = tr("麦克风")
        self.cameraTitle.text = tr("摄像头")
        self.joinConfBtn.setTitle(tr("加入会议"), for: .normal)
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        // 设置摄像头和麦克风，从本地读取数据,2.0 版本取消了高级设置，麦克风和摄像头放在了外面，
        let micro = UserDefaults.standard.bool(forKey: CurrentUserMicrophoneStatus)
        microSwitch.isOn =  micro
        let camer = UserDefaults.standard.bool(forKey: CurrentUserCameraStatus)
        cameraSwitch.isOn =  camer
        CLLog("====joinMeetimg:micro:\(micro),camer:\(camer)")
        // 选中颜色
        microSwitch.onTintColor = UIColor(hexString: "#4392F7")
        cameraSwitch.onTintColor = UIColor(hexString: "#4392F7")
        // 正常颜色
        microSwitch.tintColor = UIColor(hexString: "#CCCCCC")
        cameraSwitch.tintColor = UIColor(hexString: "#CCCCCC")
        //设置代理
        self.meetingIDTextField.delegate = self
//        self.meetingIDTextField.keyboardType = .numberPad
        
        self.btnArrow.setImage(UIImage(named: "arrow_down"), for: .normal)
        self.contentView.addSubview(self.btnArrow)
        self.btnArrow.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(self.contentView)?.offset()(-16)
            make?.centerY.mas_equalTo()(self.meetingIDTextField)
            make?.width.mas_equalTo()(24)
            make?.height.mas_equalTo()(24)
        }
        self.btnArrow.addTarget(self, action: #selector(showMeetingHistory(sender:)), for: .touchUpInside)
        
        // chenfan：断网后的样式
        _ = WelcomeViewController.checkNetworkAndUpdateUI()
        
        self.loadMeetingHistory()
        //会议连接成功。。。。
        NotificationCenter.default.addObserver(self, selector: #selector(notificationConfConnect(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_JOIN_CONF_RESULT), object: nil)

        //会议结束
        NotificationCenter.default.addObserver(self, selector: #selector(notificationEndCall), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_ENDED), object: nil)
    }

    // MARK: 发起会议 --》 连接会议回调通知
    @objc func notificationConfConnect(notification: Notification) {
        CLLog("连接会议回调通知")
        DispatchQueue.main.async {
            MBProgressHUD.hide()
        }
        guard let resultInfo = notification.userInfo ,
              let _ = resultInfo["CONF_E_CONNECT"] as? ConfBaseInfo,
              let _ = resultInfo["JONIN_MEETING_RESULT_KEY"] as? NSNumber
            else  {
            MBProgressHUD.showBottom(tr("会议ID或密码不正确"), icon: nil, view: nil)
            return
        }

        // 判断会议信息
        guard (ManagerService.confService()?.currentConfBaseInfo) != nil else {
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)
            return
        }
        CLLog(" 开始加入会议")
        navigationController?.popViewController(animated: true)

    }

    // 呼叫结束
    @objc func notificationEndCall(notification: Notification) {
        MBProgressHUD.hide()
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo else {
            CLLog("呼叫信息不正确")
            return
        }
        guard callInfo.isFocus else {
            if callInfo.serverConfId == nil {
                CLLog("当前是加入会议，需要提示")

                //xjc,2021-1-11,通过会议id判断，如果id为空，证明此会议会议未开始或不存在
//                MBProgressHUD.showBottomOnRootVC(with: tr("会议未开始或不存在"), icon: nil, view: tableView)
                MBProgressHUD.showBottom(tr("会议未开始或不存在"), icon: nil, view: tableView)
                return
            } else {
                CLLog("当前呼叫为点呼, 不提示")
                return
            }
        }

    }
    @IBAction func joinBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        
        if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
            self.getAuthAlertWithAccessibilityValue(value: "10")
            return
        }
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        if self.meetingIDTextField.text == "" {
            MBProgressHUD.showBottom(tr("请输入会议ID"), icon: nil, view: self.view)
            return
        }
        if let text = self.meetingIDTextField.text {
            self.joinMetting(accessNumber: text)
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
    
    @objc func showMeetingHistory(sender: UIButton) {
        self.view.endEditing(true)
        let vc = JoinMeetingHistoryViewController(self.meetingHistory)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.selectBlock = { [weak self](model) in
            self?.joinMetting(accessNumber: model.number)
        }
        vc.clearHistoryBlock = { [weak self] in
            self?.meetingHistory.removeAll()
            self?.btnArrow.isHidden = true
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func loadMeetingHistory() {
        if let arr = ContactManager.shared.getMeetingHistory() {
            self.meetingHistory = arr
            self.btnArrow.isHidden = (arr.count <= 0)
        } else {
            self.btnArrow.isHidden = true
        }
    }
}
//MARK: - 加入会议方法
extension JoinMeetingViewController {
    private func joinMetting(accessNumber: String){
        /*
        //        直接加入会议
        // 实际： 先获取会议详情 -- 已和SDK确认，没有会议详情接口
        let number = ManagerService.call()?.terminal
        // 进入会场
        // 模拟数据
        let callInfo = CallInfo.init()
        var serverConfId = self.meetingIDTextField.text!
        //判断是否加9000 ,  3.0状态 不能添加90000，不是3.0版本再添加9000
        if ManagerService.call()?.isSMC3 == false {//不是3。0版本
            if serverConfId.hasPrefix("9000") {
            }else{
                serverConfId = "9000" + serverConfId
            } 
        }
        callInfo.serverConfId = serverConfId
        
        MBProgressHUD.showMessage("")
        
        ManagerService.confService()?.joinConference(withConfId: nil, accessNumber: callInfo.serverConfId, confPassWord: "", joinNumber: number, isVideoJoin: true)
        
        */
        
        if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
            self.getAuthAlertWithAccessibilityValue(value: "10")
            return
        }
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        

        let number = ManagerService.call()?.terminal
        CLLog("开始加入会议,会议id:\(NSString.encryptNumber(with: accessNumber) ?? ""),terminal:\(NSString.encryptNumber(with: number) ?? ""))")
        MBProgressHUD.showMessage(tr("正在加入会议") + "...")
        SessionViewController.sessionJoinMeeting(confId: "", accessNumber: accessNumber, confPwd: "", joinNum: number!, isVideJoin: true )
        if passJoinMeetBlock != nil {
            passJoinMeetBlock!(true)
        }

    }
}
//MARK: - textfield 代理方法
extension JoinMeetingViewController {
    //xiejc 2021-01-05  会议id 没有长度限制，不需要是实现这个代理方法
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField != meetingIDTextField {
//            let textString = textField.text! as NSString
//            let nowString = textString.replacingCharacters(in: range, with: string)
//            return nowString.count <= 6
//        }
//        return true
//    }
    //xiejc 2021-01-05 输入会议id ，需要更改line的颜色
    func textFieldDidBeginEditing(_ textField: UITextField) {
         if textField == meetingIDTextField {
            self.lineView.backgroundColor = UIColor(hexString: "0D94FF")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         if textField == meetingIDTextField {
            self.lineView.backgroundColor = UIColor.colorWithSystem(lightColor: "#E9E9E9", darkColor: "#1F1F1F")
        }
    }
    
}
//MARK: - tableview 代理方法
extension JoinMeetingViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if 0 == indexPath.row {
            return 82
        }
        return 54
    }
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if ManagerService.call()?.isSMC3 == true {
//            if indexPath.section == 0 && 1 == indexPath.row {
//                cell.isHidden = true
//            }
//        } else {
//            if indexPath.section == 0 && 2 == indexPath.row || indexPath.section == 0 && 3 == indexPath.row {
//                cell.isHidden = true
//            }
//        }
//    }
  
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         
//        if  ManagerService.call()?.isSMC3 == false {
//            if indexPath.row == 1 {
//                let storyboard = UIStoryboard.init(name: "MeetAdvanceSetViewController", bundle: nil)
//                let meetAdvanceSetViewVC = storyboard.instantiateViewController(withIdentifier: "MeetAdvanceSetView") as! MeetAdvanceSetViewController
//                meetAdvanceSetViewVC.isJoinMeeting = true
//               
//                self.navigationController?.pushViewController(meetAdvanceSetViewVC, animated: true)
//            }
//        }
//        
//    }
}

extension JoinMeetingViewController {
    //MARK: - 麦克风点击方法
    @IBAction func clickMicroSwitch(_ sender: UISwitch) {
        // 当前是关闭状态，先判断权限，未授权弹框，授权直接打开即可
        HWAuthorizationManager.shareInstanst.authorizeToMicrophone { (isAuto) in
            if !isAuto {// 未授权 弹出授权框
                self.microSwitch.isOn = false
                UserDefaults.standard.setValue(false, forKey: CurrentUserMicrophoneStatus)
                self.getAuthAlertWithAccessibilityValue(value: "20")
            }else { // 设置关闭麦克风
                UserDefaults.standard.setValue(sender.isOn, forKey: CurrentUserMicrophoneStatus)
                 
            }
        }
        
    }
    //MARK: - 摄像头点击方法
    @IBAction func clickCameraSwitch(_ sender: UISwitch) {
        // 当前是关闭状态，先判断权限，未授权弹框，授权直接打开即可
        HWAuthorizationManager.shareInstanst.authorizeToCameraphone { (isAuto) in
            if !isAuto { // 未授权
                self.cameraSwitch.isOn = false
                UserDefaults.standard.setValue(false, forKey:  CurrentUserCameraStatus)
                // 弹出授权框，处理结果在下面的代理方法中
                self.getAuthAlertWithAccessibilityValue(value: "10")
            }else { // 打开摄像头
                UserDefaults.standard.setValue(sender.isOn, forKey: CurrentUserCameraStatus )
             }
        }
    }
}
//MARK: - 摄像头麦克风未授权弹框返回代理
extension JoinMeetingViewController {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("加入会议需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("加入会议需要开启麦克风权限")
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
//MARK: - 返回页面消失处理
extension JoinMeetingViewController {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        ManagerService.call()?.delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    @objc func handleTapSelf(){
        self.view.endEditing(true)
    }

    
}
