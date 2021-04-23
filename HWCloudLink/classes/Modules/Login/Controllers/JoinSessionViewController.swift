//
// JoinSessionViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class JoinSessionViewController: UITableViewController,UITextFieldDelegate, ConferenceServiceDelegate, AlertSingleTextFieldViewDelegate {
    
    @IBOutlet weak var meetingIDTitleLabel: UILabel!
    
    @IBOutlet weak var meetingIDValueTextField: UITextField!
    
    @IBOutlet weak var joinMeetingNameTitleLabel: UILabel!
    
    @IBOutlet weak var joinMeetingNameValueTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = tr("加入会议")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.meetingIDValueTextField.keyboardType = .phonePad
        self.joinMeetingNameValueTextField.keyboardType = .phonePad
        
        // table view
        self.tableView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        // 去分割线
        self.tableView.separatorStyle = .none
        
        self.meetingIDValueTextField.delegate = self
        self.joinMeetingNameValueTextField.delegate = self
        
        // 添加通知监听
        NotificationCenter.default.addObserver(self, selector: #selector(joinMeetingNotification(notification:)), name: NSNotification.Name.init(rawValue: LOGIN_C_GET_TEMP_USER_INFO_FAILD), object: nil)
    }
    
    @objc func joinMeetingNotification(notification: Notification) {
//        let dataDict = notification.object as? NSDictionary
        CLLog("匿名加入会议失败")
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view:nil)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ManagerService.confService()?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ManagerService.confService()?.delegate = nil
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    
    @IBAction func joinMeetingBtnClick(_ sender: Any) {
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        self.view.endEditing(true)
        if self.meetingIDValueTextField.text == "" || self.joinMeetingNameValueTextField.text == "" {
            MBProgressHUD.showBottom(tr("请输入会议ID和入会名称"), icon: nil, view: self.view)
            return
        }
        
        // 输入密码
        let alertVC = AlertSingleTextFieldViewController.init(nibName: "AlertSingleTextFieldViewController", bundle: nil)
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overFullScreen
        
        alertVC.customDelegate = self
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - AlertSingleTextFieldViewDelegate
    // viewDidLoad
    func alertSingleTextFieldViewViewDidLoad(viewVC: AlertSingleTextFieldViewController) {
        viewVC.showTitleLabel.text = tr("会议密码")
        viewVC.showInputTextField.isSecureTextEntry = true
        viewVC.showInputTextField.placeholder = tr("请输入密码")
        viewVC.showInputTextField.keyboardType = .phonePad
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
    }
    
    // left btn Click
    func alertSingleTextFieldViewLeftBtnClick(viewVC: AlertSingleTextFieldViewController, sender: UIButton) {
        
    }
    
    // right btn click
    func alertSingleTextFieldViewRightBtnClick(viewVC: AlertSingleTextFieldViewController, sender: UIButton) {
        if viewVC.showInputTextField.text == "" {
            MBProgressHUD.showBottom(tr("请输入密码"), icon: nil, view: viewVC.view)
            return
        }
    
        let serverArray = NSObject.getUserDefaultValue(withKey: DICT_SAVE_SERVER_INFO) as? NSArray
        // 加入会议
        if serverArray != nil && serverArray!.count > 1 {
            self.dismiss(animated: true, completion: nil)
            
            let serverIp = serverArray![0] as? String
            let serverPort = serverArray![1] as? String
            
            let isSuccess = ManagerService.confService()?.joinConference(withDisPlayName: self.joinMeetingNameValueTextField.text, confId: self.meetingIDValueTextField.text, passWord: "", serverAdd: serverIp, random: viewVC.showInputTextField.text, serverPort: Int32(serverPort!)!, authType: 0)
            
            if !isSuccess! {
                MBProgressHUD.showBottom(tr("加入会议失败"), icon: nil, view: nil)
                return
            }
            
            // 加入会议操作？？？
            MBProgressHUD.showMessage(tr("正在加入会议") + "...")
            ManagerService.loginService()
        } else {
            MBProgressHUD.showBottom(tr("请先配置IP和端口"), icon: nil, view: nil)
        }
    }
    
    // MARK: - ConferenceServiceDelegate
    // MARK:
    func ecConferenceEventCallback(_ ecConfEvent: EC_CONF_E_TYPE, result resultDictionary: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            MBProgressHUD.hide()
            switch ecConfEvent {
            case CONF_E_CREATE_RESULT:
                CLLog("CONF_E_CREATE_RESULT")
            case CONF_E_ATTENDEE_UPDATE_INFO:
                CLLog("CONF_E_ATTENDEE_UPDATE_INFO")
            case CONF_E_CURRENTCONF_DETAIL:
                CLLog("CONF_E_CURRENTCONF_DETAIL")
            case CONF_E_GET_CONFLIST:
                CLLog("CONF_E_GET_CONFLIST")
                let resultArray = resultDictionary[CALL_S_CONF_EVT_QUERY_CONF_LIST_RESULT] as? [ConfBaseInfo]
            default:
                CLLog("default")
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.00
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
                let advanceSetViewVC = self.storyboard?.instantiateViewController(withIdentifier: "AdvanceSetView") as! AdvanceSetViewController
                self.navigationController?.pushViewController(advanceSetViewVC, animated: true)
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let storyboard = UIStoryboard.init(name: "ServerSettingViewController", bundle: nil);
            let serverSettingViewVC = storyboard.instantiateViewController(withIdentifier:
                "ServerSettingView") as! ServerSettingViewController
            self.navigationController?.pushViewController(serverSettingViewVC, animated: true)
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
