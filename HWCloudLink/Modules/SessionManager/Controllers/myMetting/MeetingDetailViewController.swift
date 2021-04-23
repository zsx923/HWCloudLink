//
//  MeetingDetailController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/10.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import MessageUI

class MeetingDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TextTitleViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!

    var isShowJoinBtn: Bool = false
    
    // 会议主题高度
    var themeCellHeight:CGFloat = 0.0
    // 来宾密码密文显示
    var isGuestCiphertextClose:Bool = false
    // 主持人密码密文显示
    var isChairmanCiphertextClose:Bool = true
    
    var meetInfo: ConfBaseInfo?
    
    var footerView: MeetingDetailFooterView = MeetingDetailFooterView.detailFooterView()
    // 是否召集人
    var isConvener: Bool {
        get {
            if ManagerService.call()?.isSMC3 ?? false {
                let account = ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? ""
                if account == meetInfo?.scheduleUserAccount ?? "" {
                    return true
                }
                return false
          }
            return false
        }
    }
    // 是否将来会议
//    private var isFutureMeeting: Bool = false
    
    private lazy var share: ShareManager = ShareManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 标题
        self.title = tr("会议详情")

        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        let rightBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "contact_share"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        // 设置UI
        self.setViewUI()
}
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            return
        }
        share.share(meetingInfo: self.meetInfo, from: self)
    }
    
    // set view ui
    func setViewUI() {
        
        // 设置tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor(hexString: "#000000", alpha: 0.0)
        self.tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = footerView
        
        footerView.cancelMeetingBtn.addTarget(self, action: #selector(cancelMeetingBtnClick(_:)), for: .touchUpInside)
        footerView.joinMeetingBtn.addTarget(self, action: #selector(addMeetingBtnClick(_:)), for: .touchUpInside)
        
        // SMC 3.0
        self.tableView.register(UINib.init(nibName: MeetingDetailTableViewCell.cellID, bundle: nil), forCellReuseIdentifier: MeetingDetailTableViewCell.cellID)
        self.tableView.register(UINib.init(nibName: MeetingDetailAttendeesTableViewCell.cellID, bundle: nil), forCellReuseIdentifier: MeetingDetailAttendeesTableViewCell.cellID)
        self.tableView.register(UINib.init(nibName: MeetingDetailThemeTableViewCell.cellID, bundle: nil), forCellReuseIdentifier: MeetingDetailThemeTableViewCell.cellID)
        self.tableView.register(UINib.init(nibName: MeetingDetailAttendCountTableViewCell.cellID, bundle: nil), forCellReuseIdentifier: MeetingDetailAttendCountTableViewCell.cellID)

        // set按钮样式
        footerView.setButtonStyle(isActive: meetInfo?.isActive ?? false, isConvener: isConvener, isShowJoinBtn: isShowJoinBtn)
        
        // chenfan：断网后的样式
        _ = WelcomeViewController.checkNetworkAndUpdateUI()
    }

    @IBAction func shareBarBtnItemClick(_ sender: Any) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            return
        }
        
        let popTitleVC = PopSocialShareViewController.init(nibName: "PopSocialShareViewController", bundle: nil)
        popTitleVC.modalTransitionStyle = .crossDissolve
        popTitleVC.modalPresentationStyle = .overFullScreen
        self.present(popTitleVC, animated: true, completion: nil)
    }
    
    @objc private func addMeetingBtnClick(_ sender: UIButton) {
        
        if meetInfo?.confType == TSDK_E_CONF_EX_AUDIO {
            if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
                self.getAuthAlertWithAccessibilityValue(value: "20")
                return
            }
        } else {
            if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
                self.getAuthAlertWithAccessibilityValue(value: "10")
                return
            }
            if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
                self.getAuthAlertWithAccessibilityValue(value: "20")
                return
            }
        }
        
        if SuspendTool.sharedInstance.suspendWindows.count != 0 {
            SessionManager.showMeetingWarning()
            return
        }
        self.meetInfo!.isConf = true
        
        self.navigationController?.popViewController(animated: true)
        // 实际： 先获取会议详情 -- 已和SDK确认，没有会议详情接口
        let number = ManagerService.call()?.terminal
        ManagerService.confService()?.joinConference(withConfId: self.meetInfo?.confId, accessNumber: self.meetInfo?.accessNumber, confPassWord: self.meetInfo?.generalPwd, joinNumber: number, isVideoJoin: true  )
        MBProgressHUD.showMessage(tr("正在加入会议") + "...")
    }
    
    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    @objc private func cancelMeetingBtnClick(_ sender: UIButton) {
        self.getAuthAlertWithAccessibilityValue(value: "")
    }
    
    // MARK: - TextTitleViewDelegate
    // MARK: view did load
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("加入会议需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        } else if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("加入会议需要开启麦克风权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        } else {
            viewVC.showTitleLabel.text = tr("确定取消本次会议吗？")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
    }
    
    // MARK: left btn click
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
    }
    
    // MARK: right btn click
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        if viewVC.accessibilityValue == "10" || viewVC.accessibilityValue == "20" {
            viewVC.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            return
        }
        MBProgressHUD.showMessage(nil)
        ManagerService.confService()?.cancelConferenceConfId(self.meetInfo?.confIdV3, completion: { (isSuccess, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hide()
                if isSuccess { // 取消会议成功
                    // 取消会议操作
                    NotificationCenter.default.post(name: NSNotification.Name.init(CancelTheMeetingSuccess), object: nil, userInfo: ["confID":self.meetInfo?.accessNumber ?? "0"])
                    MBProgressHUD.showBottom(tr("已取消本次会议"), icon: nil, view: nil)
                    self.navigationController?.popViewController(animated: true)
                }else { // 取消会议失败
                    MBProgressHUD.showBottom(tr("取消会议失败"), icon: nil, view: nil)
                }
            }
        })
        
    }
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return ManagerService.call()?.isSMC3 ?? false ? 3 : 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ManagerService.call()?.isSMC3 == false {
            return 3
        }
        if section == 0 {
            return 2
        }else if section == 1 {
            return isConvener ? 3 : 2
        }else if section == 2 {
            return 2
        }
        return 0
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: MeetingDetailThemeTableViewCell.cellID) as! MeetingDetailThemeTableViewCell
                cell.ContentLabel.text = meetInfo?.confSubject ?? ""
                if ManagerService.call()?.isSMC3 == true {
                    if self.meetInfo?.confType == TSDK_E_CONF_EX_AUDIO {
                        cell.confTypeImageView.image = UIImage(named: "icon_meetdetail_voice_press")
                    } else if self.meetInfo?.confType == TSDK_E_CONF_EX_VIDEO {
                        cell.confTypeImageView.image = UIImage(named: "icon_meetdetail_video_press")
                    }
                }
                themeCellHeight = cell.cellHeight()
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: MeetingDetailTableViewCell.cellID) as! MeetingDetailTableViewCell
            cell.eyeImageView.isHidden = true;
            if indexPath.row == 1 {
                cell.TitleLabel.text = tr("会议时间")
                if self.meetInfo?.endTime != nil && self.meetInfo?.endTime != ""  {
                    // 跨天数
                    let startDate = String.string2Date(meetInfo?.startTime.components(separatedBy: " ").first ?? "", dateFormat: "yyyy-MM-dd")
                    let endDate = String.string2Date(meetInfo?.endTime.components(separatedBy: " ").first ?? "", dateFormat: "yyyy-MM-dd")
                    let gapDay = NSCalendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                    
                    var startTiem = self.meetInfo?.startTime.replacingOccurrences(of: "-", with: "/")
                    startTiem?.removeLast(3)
                    var endTime = self.meetInfo?.endTime.components(separatedBy: " ").last
                    endTime?.removeLast(3)
                    var allTime = "\(startTiem ?? "")-\(endTime ?? "")"
                    
                    if gapDay > 0 {
                        allTime = "\(allTime)+\(String(gapDay))"
                        let attStr = NSMutableAttributedString.init(string: allTime)
                        attStr.setAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#999999")!,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], range: NSMakeRange(0, allTime.count - 2))
                        attStr.setAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#0091FF")!,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], range: NSMakeRange(allTime.count - 2, 2))
                        cell.subTitleLabel.attributedText = attStr
                    } else {
                        cell.subTitleLabel.text = allTime
                    }
                } else {
                    var time = self.meetInfo?.startTime ?? ""
                    if !time.isEmpty {
                        time = time.replacingOccurrences(of: "-", with: "/")
                        time.removeLast(3)
                        cell.subTitleLabel.text! += ("\(time)-" + tr("持续会议"))
                    }
                }
            } else if indexPath.row == 2 {
                if ManagerService.call()?.isSMC3 == false {
                    cell.TitleLabel.text = tr("会议ID")
                    cell.subTitleLabel.text = NSString.dealMeetingId(withSpaceString: self.meetInfo?.accessNumber ?? "")
                }
            }
            return cell
        }else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: MeetingDetailTableViewCell.cellID) as! MeetingDetailTableViewCell
                cell.subTitleTextField.isHidden = false;
                cell.eyeImageView.isHidden = true
                cell.TitleLabel.text = tr("会议ID")
                cell.subTitleTextField.text = NSString.dealMeetingId(withSpaceString: self.meetInfo?.accessNumber ?? "")
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: MeetingDetailTableViewCell.cellID) as! MeetingDetailTableViewCell
                cell.subTitleTextField.isHidden = false;
                cell.subTitleTextField.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.generalPwd ?? "0", divideCount: 3)
                cell.TitleLabel.text = tr("来宾密码")
//                if self.meetInfo?.generalPwd == nil || self.meetInfo?.generalPwd == "" {
//                    cell.eyeImageView.isHidden = true
//                    cell.subTitleTextField.text = ""
//                }else{
//                    cell.eyeImageView.isHidden = false
//                    cell.subTitleTextField.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.generalPwd ?? "0", divideCount: 3)
//                    cell.subTitleTextField.isSecureTextEntry = isGuestCiphertextClose
//                    cell.eyeImageView.image = isGuestCiphertextClose ? UIImage.init(named: "password_eye") : UIImage.init(named: "password_eye_open")
//                }
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: MeetingDetailTableViewCell.cellID) as! MeetingDetailTableViewCell
                cell.TitleLabel.text = tr("主持人密码")
                cell.subTitleTextField.isHidden = false;
                if self.meetInfo?.chairmanPwd == nil || self.meetInfo?.chairmanPwd == "" {
                    cell.eyeImageView.isHidden = true
                    cell.subTitleTextField.text = ""
                }else{
                    cell.eyeImageView.isHidden = false
                    cell.subTitleTextField.text = SessionHelper.setMeetingIDType(meetingId: self.meetInfo?.chairmanPwd ?? "0", divideCount: 3)
                    cell.subTitleTextField.isSecureTextEntry = isChairmanCiphertextClose
                    cell.eyeImageView.image = isChairmanCiphertextClose ? UIImage.init(named: "password_eye") : UIImage.init(named: "password_eye_open")
                }
                return cell
            }
        }else if indexPath.section == 2 {
            
            if meetInfo?.attendeesArray.count ?? 0 > 1 {
                let attends = meetInfo?.attendeesArray as! [ConfAttendee]
                // 通过conferenceAttendeesType过滤重复数据
                meetInfo?.attendeesArray = attends.filter { $0.conferenceAttendeesType == TSDK_E_CONFERENCE_ATTENDEE_TYPE.init(rawValue: 0) }
            }
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: MeetingDetailAttendCountTableViewCell.cellID) as! MeetingDetailAttendCountTableViewCell
                cell.TitleLabel.text = tr("与会者") + "(" + String(meetInfo?.attendeesArray.count ?? 0) + ")"
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: MeetingDetailAttendeesTableViewCell.cellID) as! MeetingDetailAttendeesTableViewCell
                cell.selectionStyle = .none
                cell.loadData(attendees: meetInfo?.attendeesArray as! [ConfAttendee], convener: meetInfo?.scheduleUserName ?? "")
                return cell
            }
        }
        
        return UITableViewCell.init()
    }
    
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        // SMC 3.0点击
        if ManagerService.call()?.isSMC3 == true {
            if indexPath.section == 1 {
                if indexPath.row == 1 {
//                    isGuestCiphertextClose = !isGuestCiphertextClose
//                    tableView.reloadRows(at: [IndexPath.init(row: 1, section: 1)], with: UITableView.RowAnimation.none)
                }
                if indexPath.row == 2 {
                    isChairmanCiphertextClose = !isChairmanCiphertextClose
                    tableView.reloadRows(at: [IndexPath.init(row: 2, section: 1)], with: UITableView.RowAnimation.none)
                }
            }
        }
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return themeCellHeight
            }
            return MeetingDetailTableViewCell.cellHeight
        }else if indexPath.section == 1 {
            if indexPath.row == 1 {
                return self.meetInfo?.generalPwd != "" || self.meetInfo?.generalPwd.count ?? 0 > 0 ?  MeetingDetailTableViewCell.cellHeight : 0.0001
            }
            return MeetingDetailTableViewCell.cellHeight
        }else if indexPath.section == 2 {
            if indexPath.row == 0 {
                return MeetingDetailAttendCountTableViewCell.cellHeight
            }
            let meetAttCount:Int = self.meetInfo?.attendeesArray.count ?? 0
            if meetAttCount%5 == 0 {
                return CGFloat((meetAttCount/5)*100)
            }
            return CGFloat((meetAttCount/5+1)*100)
        }
        return 44
    }
    
    
    // MARK: header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 10))
            headerView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
            return headerView
        }
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.1))
        headerView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
        return headerView
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0.01}
        return 10.0
    }
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.1))
        headerView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
        return headerView
    }
}



