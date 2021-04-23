//
//  MeetingSetViewController.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/12/26.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetingSetViewController: UITableViewController ,UITextFieldDelegate {
 
    @IBOutlet weak var userConfId: UILabel!
    
    @IBOutlet weak var generalSwitch: UISwitch!
    @IBOutlet weak var generalTextField: UITextField!
    // add at xuegd 2020/12/28 : 来宾密码显示/隐藏
    @IBOutlet weak var generalEye: UIButton!
    @IBOutlet weak var chairmanSwitch: UISwitch!
    @IBOutlet weak var chairmanTextField: UITextField!
    // add at xuegd 2020/12/28 : 主席密码显示/隐藏
    @IBOutlet weak var chairmanEye: UIButton!
    @IBOutlet weak var saveBtn: UIButton! //保存按钮
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var myMeettingIDTitleLabel: UILabel!
    @IBOutlet weak var guestPwdTitleLabel: UILabel!
    @IBOutlet weak var ChairPwdTitleLabel: UILabel!
    
    var passSuccessBlock: ((_ chairStr: String,_ generalStr: String)->Void)?
    var isClickSaveBtn: Bool = true
    var tempAccessNumber :String = ""
    var tempChairmanPwd: String = ""
    var tempGeneralPwd: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tr("个人会议设置")
        
        self.myMeettingIDTitleLabel.text = tr("我的个人会议ID")
        self.guestPwdTitleLabel.text = tr("来宾密码")
        self.ChairPwdTitleLabel.text = tr("主持人密码")
        self.saveBtn.setTitle(tr("保存"), for: .normal)
        self.generalTextField.placeholder = tr("请输入1-6位数字密码")
        self.chairmanTextField.placeholder = tr("请输入1-6位数字密码")
        
        tableView.separatorStyle = .none
//        var tempStr = tempAccessNumber
//        let index = tempStr.index(tempStr.startIndex, offsetBy: 3)
//        tempStr.insert(" ", at: index)
        userConfId.text = NSString.dealMeetingId(withSpaceString: tempAccessNumber)
        bottomLabel.text = tr("您的当前操作将用于个人会议ID:") + (userConfId.text ?? "") + tr("的全部会议")
        saveBtn.isEnabled = false
        saveBtn.layer.cornerRadius = 2
        saveBtn.layer.masksToBounds = true
        chairmanTextField.isSecureTextEntry = true
        generalTextField.isSecureTextEntry = true
        chairmanTextField.delegate = self
        generalTextField.delegate = self
        chairmanTextField.text = ""
        generalTextField.text = ""
        // 选中颜色
        chairmanSwitch.onTintColor = UIColor(hexString: "#4392F7")
        generalSwitch.onTintColor = UIColor(hexString: "#4392F7")
        // 正常颜色
        chairmanSwitch.tintColor = UIColor(hexString: "#CCCCCC")
        generalSwitch.tintColor = UIColor(hexString: "#CCCCCC")

//        let chairStatus  = LocalVMRInfoManager.getChairmanPwdStatus()
        chairmanSwitch.isOn = tempChairmanPwd != "" //主持人密码/状态
        chairmanTextField.text = tempChairmanPwd

//        let generalStatus  = LocalVMRInfoManager.getGeneralPwdStatus()
        generalSwitch.isOn = tempGeneralPwd != "" //来宾密码/状态
        generalTextField.text = tempGeneralPwd


        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUpdateVMRInfo(noti:)), name: NSNotification.Name("updateVMRResult"), object: nil)
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
    }
    @objc func receiveUpdateVMRInfo(noti:Notification){
        guard let result = noti.userInfo?["result"] as? String else {
            return
        }
        CLLog("个人设置修改vmr信息返回：result:\(result)")
        if isClickSaveBtn == false && "0" == result {
            if passSuccessBlock != nil {
                passSuccessBlock!(self.chairmanTextField.text ?? "" ,self.generalTextField.text ?? "")
            }
            return
        }
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            if "0" == result {
                //vmr信息保存
                ManagerService.confService()?.vmrBaseInfo.generalPwd = self.tempGeneralPwd
                ManagerService.confService()?.vmrBaseInfo.chairmanPwd = self.tempChairmanPwd
                if self.passSuccessBlock != nil {
                    self.passSuccessBlock!(self.chairmanTextField.text ?? "" ,self.generalTextField.text ?? "")
                }
                NotificationCenter.default.removeObserver(self)
                self.navigationController?.popViewController(animated: true)
            } else if "67109102" == result {
                MBProgressHUD.showBottom(tr("您的个人会议ID已被预约或正在召开会议，保存失败"), icon: nil, view: self.tableView)
            } else {
                MBProgressHUD.showBottom(tr("个人会议设置保存失败"), icon: nil, view: self.tableView)
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if 0 == section || 2 == section {
            return 0.01
        }
        return 10
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 10)
        view.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#1a1a1a")
        return view
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return 3
        } else if 1 == section {
            return 2
        } else if 2 == section {
            return 1
        }
        return 0 
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if 0 == indexPath.section {
            if 0 == indexPath.row {
                return 120
            } else if 1 == indexPath.row {
                return 54
            } else if 2 == indexPath.row {
                return generalSwitch.isOn ? 44 : 0.001
            }
        } else if 1 == indexPath.section {
            if 0 == indexPath.row {
                return 54
            } else if 1 == indexPath.row {
                return chairmanSwitch.isOn ? 44 : 0.001
            }
        } else if 2 == indexPath.section {
            return 145
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if 0 == indexPath.section {
            if 2 == indexPath.row {
                if generalSwitch.isOn == true {
                    cell.isHidden = false
                } else {
                    cell.isHidden = true
                }
            }
        } else if 1 == indexPath.section {
            if 1 == indexPath.row {
                if chairmanSwitch.isOn == true {
                    cell.isHidden = false
                } else {
                    cell.isHidden = true
                }
            }
        } else if 2 == indexPath.section{
            
        }
    }
   

    //MARK: - 保存方法
    @IBAction func clickSaveBtn(_ sender: Any) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() { return }
        if generalTextField.text?.count == 0 ,generalSwitch.isOn {
            MBProgressHUD.showBottom(tr("请输入1-6位数字密码"), icon: nil, view: tableView)
            return
        }
        if chairmanTextField.text?.count == 0,chairmanSwitch.isOn {
            MBProgressHUD.showBottom(tr("请输入1-6位数字密码"), icon: nil, view: tableView)
            return
        }
        isClickSaveBtn = true
        self.saveUserMeetInfo()
    }
    //MARK: - 更改来宾密码显示状态
    @IBAction func changeGeneralSecureStatus(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            generalTextField.isSecureTextEntry = true
        } else {
            sender.isSelected = true
            generalTextField.isSecureTextEntry = false
        }
        tableView.reloadData()
    }
    //MARK: - 更改主持人密码显示状态
    @IBAction func changeChairmanSecureStatus(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            chairmanTextField.isSecureTextEntry = true
        } else {
            sender.isSelected = true
            chairmanTextField.isSecureTextEntry = false
        }
        tableView.reloadData()
    }
    
    // MARK: - 设置密码的默认状态
    //  add at xuegd 2020/12/28 : 密码的默认状态
    func setDefalutPasswordStatus() {
        self.generalTextField.isSecureTextEntry = true
        self.chairmanTextField.isSecureTextEntry = true
        self.generalEye.isSelected = false
        self.chairmanEye.isSelected = false
    }
    
    //MARK: - 打开或者关闭来宾密码
    @IBAction func changeSwitchStatus(_ sender: UISwitch) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            sender.setOn(!sender.isOn, animated: true)
            return
        }
        
        // change at xuegd 2020/12/28 : 设置密码的默认状态
        self.setDefalutPasswordStatus()
        //关闭主席密码和来宾密码是否显示弹窗
        if sender.isOn == true {
            generalTextField.text = tempGeneralPwd
//            LocalVMRInfoManager.updateGeneralPwdStatus(status: true)
        } else{
            let result = LocalVMRInfoManager.getGeneralPwdAlertViewStatus()
            if result == false  { //弹窗处理
                let dangerView =  DangerStatementCustomView.creatDangerStatementCustomView()
                dangerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                dangerView.contentStr = tr("来宾密码关闭后，所有个人会议ID:") + (userConfId.text ?? "" ) + tr("相关会议密码全部关闭，当前操作存在安全风险，建议开启来宾密码。")
                self.view.addSubview(dangerView)
                dangerView.passAlertStatementValueBlock = { [self]( isAgree: Bool, isConfirm: Bool ) in
                    if isConfirm {//点击了确认按钮
//                        LocalVMRInfoManager.updateGeneralPwdStatus(status: false)
                        saveBtn.isEnabled = true
                        self.saveBtn.backgroundColor = UIColor.init(hexString: "#0D94FF")
                        self.isClickSaveBtn = false
                        self.generalSwitch.isOn = false
                        generalTextField.text = ""
                        self.tempGeneralPwd = ""
//                        self.saveUserMeetInfo()
                        if isAgree {//选了同意并点击了确认按钮
                            LocalVMRInfoManager.updateGeneralPwdAlertViewStatus()
                        }
                    } else {//选择取消，重新打开switch
                        self.generalSwitch.isOn = true
//                        LocalVMRInfoManager.updateGeneralPwdStatus(status: true)
                    }
                    self.tableView.reloadData()
                }
            } else {
//                LocalVMRInfoManager.updateGeneralPwdStatus(status: false)
                isClickSaveBtn = false
                generalTextField.text = ""
                tempGeneralPwd = ""
                self.saveUserMeetInfo()
            }
        }
        tableView.reloadData()
    }
    //MARK: - 打开或者关闭主持人密码
    @IBAction func changeGeneralSwitchStatus(_ sender: UISwitch) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            sender.setOn(!sender.isOn, animated: true)
            return
        }
        
        // change at xuegd 2020/12/28 : 设置密码的默认状态
        self.setDefalutPasswordStatus()
        if sender.isOn == true  {
            chairmanTextField.text = tempChairmanPwd
            LocalVMRInfoManager.updateChirmanPwdStatus(status: true)
        } else{
            let result = LocalVMRInfoManager.getChainManPwdAlertViewStatus()
            if result == false  { //弹窗处理
                let dangerView =  DangerStatementCustomView.creatDangerStatementCustomView()
                dangerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                dangerView.contentStr = tr("主持人密码关闭后，所有个人会议ID:") + (userConfId.text ?? "" ) + tr("相关会议密码全部关闭，当前操作存在安全风险，建议开启主持人密码。")
                self.view.addSubview(dangerView)
                dangerView.passAlertStatementValueBlock = { ( isAgree: Bool, isConfirm: Bool ) in
                    if isConfirm {//选了确认
                        self.saveBtn.isEnabled = true
                        self.saveBtn.backgroundColor = UIColor.init(hexString: "#0D94FF")
                        sender.isOn = false
                        self.chairmanTextField.text = ""
                        self.tempChairmanPwd = ""
                        LocalVMRInfoManager.updateChirmanPwdStatus(status: false)
                        if isAgree {//同时选中了提示框 和 确认
                            LocalVMRInfoManager.updateChairmanPwdAlertViewStatus()
                        }
                    } else {
                        sender.isOn = true
                        LocalVMRInfoManager.updateChirmanPwdStatus(status: true)
                    }
                    self.tableView.reloadData()
                }
            } else {
                tempChairmanPwd = ""
                chairmanTextField.text = ""
                LocalVMRInfoManager.updateChirmanPwdStatus(status: false)
            }
        }
        tableView.reloadData()
    }
}
//MARK: - 保存密码
extension MeetingSetViewController{
    func saveUserMeetInfo(){
        if  generalTextField.text!.count > 6   {
            MBProgressHUD.showBottom(tr("来宾密码最长为6位"), icon: nil, view: tableView)
            return
        }
        if  chairmanTextField.text!.count > 6   {
            MBProgressHUD.showBottom(tr("主席密码最长为6位"), icon: nil, view: tableView)
            return
        }
        if isClickSaveBtn == true {
            if chairmanTextField.text!.count == 0 ,chairmanSwitch.isOn{
                MBProgressHUD.showBottom(tr("请输入1-6位数字密码"), icon: nil, view: tableView)
                return
            }
        }
        if isClickSaveBtn == true {
            MBProgressHUD.showMessage("")
        }
        tempGeneralPwd = self.generalTextField?.text ?? ""
        tempChairmanPwd = self.chairmanTextField?.text ?? ""

        let result = ManagerService.confService()?.updateVmrList(tempChairmanPwd, generalStr: tempGeneralPwd, confId: tempAccessNumber)
        CLLog("更新vmr信息返回参数:accessNum:\(NSString.encryptNumber(with: tempAccessNumber) ?? ""),返回result结果:\(String(describing: result))")
    }
}


extension MeetingSetViewController {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        saveBtn.isEnabled = true
        saveBtn.backgroundColor = UIColor.init(hexString: "#0D94FF")
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    // add at xuegd 2020/12/28 : 密码最大长度不得大于6位
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        return nowString.count <= 6
    }
    // MARK: left Bar Btn Item Click  返回方法
       @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
           NotificationCenter.default.removeObserver(self)
           self.navigationController?.popViewController(animated: true)
       }
}
