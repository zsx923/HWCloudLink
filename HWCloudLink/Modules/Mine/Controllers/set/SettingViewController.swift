//
// SettingViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UITableViewController, TextTitleViewDelegate {
    static let CELL_HEIGHT: CGFloat = 54.0
    
    // add at xuegd: 是否为AD用户
    var isADUser : Bool = false
    // 是否有VMR
    var hasVMR: Bool = false
    // add at xuegd: 2.0是否含有sipUrl
    var isSMC2HaveSipUrl : Bool = false
    // 是否为3.0
    var isSMC3: Bool = false
    // 是否含有新版本
    @IBOutlet weak var isHaveNewVersion: UILabel!
    // VMR会议接入码
    var vmrAccessNumber: String = ""
    var vmrChairmanPwd:String = ""
    var vmrGeneralPwd: String = ""

    @IBOutlet weak var confereLabel: UILabel!
    @IBOutlet weak var languageTitleLabel: UILabel!
    @IBOutlet weak var callInfoLabel: UILabel!
    @IBOutlet weak var modifyPwdLabel: UILabel!
    @IBOutlet weak var generalTitleLabel: UILabel!
    @IBOutlet weak var confereSettingTitleLabel: UILabel!
    @IBOutlet weak var advanceSetLabel: UILabel!    // 高级设置Title
    @IBOutlet weak var aboutTitleLabel: UILabel!
    @IBOutlet weak var loginOutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        self.title = tr("设置")
        
        self.languageTitleLabel.text = tr("语言")
//        self.languageTitleLabel.textColor = SessionManager.shared.isCurrentMeeting ? COLOR_LIGHT_GAY : UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
        self.languageTitleLabel.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
        self.callInfoLabel.text = tr("来电通知")
        self.modifyPwdLabel.text = tr("修改密码")
        self.generalTitleLabel.text = tr("通用设置")
        self.confereSettingTitleLabel.text = tr("个人会议设置")
        self.advanceSetLabel.text = tr("高级设置")
        self.aboutTitleLabel.text = tr("关于HW CloudLink")
        self.loginOutBtn.setTitle(tr("退出登录"), for: .normal)
        
        self.isHaveNewVersion.isHidden = true
        // change at xuegd: 外部认证用户(AD用户)
        let tempComTils = CommonUtils.getUserDefaultValue(withKey: CALL_EVT_AUTH_TYPE_KEY) as? String
        if (tempComTils != nil), tempComTils! == "2" {
            self.isADUser = true
        }
        // change at xuegd: 是否2.0认证用户
        self.isSMC2HaveSipUrl = ServerConfigInfo.value(forKey: .sipUri) != "" && !ManagerService.call().isSMC3
        self.isSMC3 = ManagerService.call().isSMC3
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

        // language change
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChange(notfic:)),
                                               name: NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE),
                                               object: nil)
        // 是否正在会议状态的变更通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentMeetingChangedNotification(notfic:)),
                                               name: NOTIFICATION_CURRENT_MEETING_STATUS_CHANGED,
                                               object: nil)
        
        if self.isSMC3 {
            //获取VMR信息
            getVMRUserInfoList()
//            MBProgressHUD.showMessage("")
//            ManagerService.confService()?.getVmrList()
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(getCurrentUserInfoList(noti:)),
//                                                   name: NSNotification.Name(CALL_S_CONF_EVT_GET_VMR_LIST_RESULT),
//                                                   object: nil);
        }
        
        self.advanceSetLabel.textColor = SessionManager.shared.isCurrentMeeting ? COLOR_LIGHT_GAY : UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
    }
    //MARK: - 获取用户vmr信息
    private func getVMRUserInfoList() {
        guard ManagerService.confService()?.vmrBaseInfo.accessNumber?.count ?? 0 > 0 else {
            CLLog("3.0 当前账号无VMR信息")
            hasVMR = false
                return
        }
        vmrAccessNumber =  ManagerService.confService()?.vmrBaseInfo.accessNumber ?? ""
        vmrChairmanPwd =  ManagerService.confService()?.vmrBaseInfo.chairmanPwd ?? ""
        vmrGeneralPwd =  ManagerService.confService()?.vmrBaseInfo.generalPwd ?? ""
        hasVMR = true
        CLLog("SettingViewController:当前账号有vmr信息:vmrConfId:\(NSString.encryptNumber(with: vmrAccessNumber) ?? "")")
        DispatchQueue.main.async {
        self.confereLabel.text = NSString.dealMeetingId(withSpaceString: self.vmrAccessNumber)
        self.tableView.reloadData()

        }
    }
    @objc func languageChange(notfic:Notification) {
        self.title = tr("设置")
        
        self.languageTitleLabel.text = tr("语言")
        self.callInfoLabel.text = tr("来电通知")
        self.modifyPwdLabel.text = tr("修改密码")
        self.generalTitleLabel.text = tr("通用设置")
        self.confereSettingTitleLabel.text = tr("个人会议设置")
        self.advanceSetLabel.text = tr("高级设置")
        self.aboutTitleLabel.text = tr("关于HW CloudLink")
        self.loginOutBtn.setTitle(tr("注销"), for: .normal)
        
        self.tableView.reloadData()
    }
    
    // 是否当前正在会议中或点对点状态变更通知
    @objc func currentMeetingChangedNotification(notfic:Notification) {
        guard let isCurrentMeeting = notfic.object as? Bool else {
            return
        }
//        self.languageTitleLabel.textColor = isCurrentMeeting ? COLOR_LIGHT_GAY : UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
        self.advanceSetLabel.textColor = isCurrentMeeting ? COLOR_LIGHT_GAY : UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
    }
    
    //MARK: - 获取用户vmr信息
//    @objc func getCurrentUserInfoList(noti:Notification){
//        DispatchQueue.main.async {
//            MBProgressHUD.hide()
//        }
//        CLLog("SettingViewController:返回vmr信息")
//        if noti.userInfo != nil  {
//            let result = noti.userInfo!["VIRTUAL_MEETING_ROOM_LIST_KEY"] as? ConfBaseInfo
//            if  result != nil  {
//                if result!.accessNumber.count > 0 {
//                    vmrAccessNumber =  result!.accessNumber
//                    vmrChairmanPwd = result!.chairmanPwd
//                    vmrGeneralPwd = result!.generalPwd
//                    hasVMR = true
//                    CLLog("SettingViewController:当前账号有vmr信息:vmrConfId:\(vmrAccessNumber)===vmrChairmanPwd:\(vmrChairmanPwd)==vmrGeneralPwd:\(vmrGeneralPwd)")
//                    DispatchQueue.main.async {
//                        self.confereLabel.text = self.vmrAccessNumber
//                        self.tableView.reloadData()
//                    }
//                } else {
//                    CLLog("SettingViewController:当前账号无vmr信息")
//                }
//
//            } else {
//                CLLog("SettingViewController:返回vmr信息：noti.userInfo为空")
//            }
//        }
//    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return hasVMR ? 5 : 4 // 是否显示VMR
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 { // 语言
            return SettingViewController.CELL_HEIGHT
        } else if indexPath.section == 0 && indexPath.row == 1 { // 来电通知
            return SettingViewController.CELL_HEIGHT
        } else if indexPath.section == 0 && indexPath.row == 2 { // 修改密码
            // change at xuegd: SMC2.0认证用户 和 SMC3.0用户 显示修改密码
            return isADUser ? 0.01 : isSMC3 || isSMC2HaveSipUrl ? SettingViewController.CELL_HEIGHT : 0.01
        } else if indexPath.section == 3 { // 注销
            return 70
        } else if indexPath.section == 0,indexPath.row == 4 {
            return hasVMR ? SettingViewController.CELL_HEIGHT : 0
        }else {
            return  SettingViewController.CELL_HEIGHT
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0: // 基本设置
            self.pushViewControllerOfBasicSetup(index: indexPath.row)
            break
        case 1: // 其他设置
            self.pushViewControllerOfOtherSettings(index: indexPath.row)
            break
        case 2: // 关于
            self.pushViewControllerOfAbout(index: indexPath.row)
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.black)
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textAlignment = .left
        lab.textColor = UIColor.colorWithSystem(lightColor: "#666666", darkColor: "#F0F0F0")
        if section == 0 {
            lab.text = tr("基本设置")
        } else if section == 1 {
            lab.text = tr("其他设置")
        } else if section == 2 {
            lab.text = tr("关于")
        } else {
            lab.text = nil
        }
        view.addSubview(lab)
        lab.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(view)?.offset()(16)
            make?.right.mas_equalTo()(view)?.offset()(-16)
            make?.centerY.mas_equalTo()(view.centerY)
            make?.height.mas_equalTo()(view)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - 注销
    @IBAction func logout(_ sender: UIButton) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = "20"
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        viewVC.showTitleLabel.text = tr("确定退出登录吗?")
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("退出登录"), for: .normal)
        viewVC.showRightBtn.setTitleColor(COLOR_RED, for: .normal)
    }

    // MARK: 取消
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
    
    }

    // MARK:注销
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        MBProgressHUD.showMessage("", to: self.view)
        ManagerService.confService()?.vmrBaseInfo.accessNumber = nil
        ManagerService.loginService()?.logoutCompletionBlock({ (isSuccess, error) in
            if isSuccess {
                DispatchQueue.main.async {
                    CLLog("Logout success!")
                    // 发送通知注销并清除密码
                    NotificationCenter.default.post(name: NSNotification.Name("LogOutSuccessClearPassword"), object: true)
                    // 清除用户数据
                    FeedBackCommitViewController.isLogUpLoad = false
//                    ManagerService.confService()?.vmrBaseInfo.accessNumber = nil
                    UserDefaults.standard.set("", forKey: DICT_SAVE_NIC_NAME)
                    NSObject.userDefaultSaveValue("", forKey: DICT_SAVE_LOGIN_password)
                    MBProgressHUD.hide()
                    
                    // 防止在离线模式下，没有回调
                    LoginCenter.sharedInstance()?.setUserLoginStatus(.unLogin)
                    WelcomeViewController.reconnectLink()   // 根据网络情况刷新界面
                }
            } else {
                CLLog("Logout Fail! Description:"+"\(String(describing: error.debugDescription))")
                MBProgressHUD.hide()
            }
        })
    }
    
    // MARK: - 返回按钮
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.popViewController(animated: true)
       }
}

// MARK: - 页面跳转
extension SettingViewController {
    // MARK: 基本设置
    func pushViewControllerOfBasicSetup(index: Int) {
        switch index {
        case 0: // 语言
//            if SessionManager.shared.isCurrentMeeting {  // 正在会议中时，不能点击
//                return
//            }
            let lauguageSetVC = LauguageSetViewController.init()
            self.navigationController?.pushViewController(lauguageSetVC, animated: true)
            break
        case 1: // 来电通知
            let callComingVC = CallComingSetViewController.init()
            self.navigationController?.pushViewController(callComingVC, animated: true)
            break
        case 2: // 修改密码
            let storyboard = UIStoryboard.init(name: "NewPwdViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NewPwdView")
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3: // 通用设置
            let storyboard = UIStoryboard.init(name: "GeneralSettingsController", bundle: nil)
            let generalSettingsVC = storyboard.instantiateViewController(withIdentifier: "GeneralSettingsView")
            self.navigationController?.pushViewController(generalSettingsVC, animated: true)
            break
        case 4: // 个人会议设置
            let storyboard = UIStoryboard.init(name: "MeetingSetViewController", bundle: nil)
            let set = storyboard.instantiateViewController(withIdentifier: "MeetingSetVC") as! MeetingSetViewController
            set.tempAccessNumber = self.vmrAccessNumber
            set.tempChairmanPwd = vmrChairmanPwd
            set.tempGeneralPwd = vmrGeneralPwd
            set.passSuccessBlock = {(chairStr : String ,generalStr: String) in
                self.vmrChairmanPwd = chairStr
                self.vmrGeneralPwd = generalStr
                DispatchQueue.main.async {
                    MBProgressHUD.showBottom(tr("个人会议设置保存成功"), icon: nil, view: self.tableView)
                }
            }
            self.navigationController?.pushViewController(set, animated: true)
            break
        default:
            break
        }
    }

    // MARK: 其他设置
    func pushViewControllerOfOtherSettings(index: Int) {
        if SessionManager.shared.isCurrentMeeting {  // 正在会议中时，不能点击
            return
        }
        
        // 高级设置
        let advancedSetting = SettingAdvancedViewController.init()
        self.navigationController?.pushViewController(advancedSetting, animated: true)
    }

    // MARK: 关于
    func pushViewControllerOfAbout(index: Int) {
        let about = AboutCloudLinkViewController.init()
        self.navigationController?.pushViewController(about, animated: true)
    }
}
