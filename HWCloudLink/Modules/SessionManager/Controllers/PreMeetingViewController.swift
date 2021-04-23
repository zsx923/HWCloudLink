//
//  PreMeetingViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class PreMeetingViewController: UITableViewController, UITextFieldDelegate, ViewDateTimePickerDelegate, ViewHourMinuteDelegate {
    // 会议ID
    @IBOutlet weak var meetingTitleLabel: UILabel!
    // 请输入会议ID
    @IBOutlet weak var meetingTitleTextField: UITextField!
    // 开始时间
    @IBOutlet weak var dateTitleLabel: UILabel!
    // 开始时间 - 10月8号
    @IBOutlet weak var dateValueLabel: UILabel!
    // 会议时长
    @IBOutlet weak var timeLengthTitleLabel: UILabel!
    // 会议时长 - 2小时
    @IBOutlet weak var timeLengthValueLabel: UILabel!
    // 会议类型
    @IBOutlet weak var meetingTypeTitleLabel: UILabel!
    // 会议类型 - 视频会议
    @IBOutlet weak var meetingTypeValueLabel: UILabel!
    // 来宾密码 - Switch
    @IBOutlet weak var guestSwitch: UISwitch!
    // 密码
    @IBOutlet weak var passwordTitle: UILabel!
    // 密码 - 输入框
    @IBOutlet weak var passwordTF: NoCopyTextField!
    // change at xuegd : 显示/隐藏密码
    @IBOutlet weak var hideEye: UIButton!
    // 与会者
    @IBOutlet weak var showAttendeeTitleLabel: UILabel!

    // attendee 1
    @IBOutlet weak var showAttendee1View: UIView!
    @IBOutlet weak var showAttendee1ImageView: UIImageView!
    @IBOutlet weak var showAtteedee1Label: UILabel!
    
    // attendee 2
    @IBOutlet weak var showAttendee2View: UIView!
    @IBOutlet weak var showAttendee2ImageView: UIImageView!
    @IBOutlet weak var showAtteedee2Label: UILabel!
    
    // attendee 3
    @IBOutlet weak var showAttendee3View: UIView!
    @IBOutlet weak var showAttendee3ImageView: UIImageView!
    @IBOutlet weak var showAtteedee3Label: UILabel!
    
    // attendee 4
    @IBOutlet weak var showAttendee4View: UIView!
    @IBOutlet weak var showAttendee4ImageView: UIImageView!
    @IBOutlet weak var showAtteedee4Label: UILabel!
    
    // attendee 5
    @IBOutlet weak var showAttendee5View: UIView!
    @IBOutlet weak var showAttendee5ImageView: UIImageView!
    @IBOutlet weak var showAtteedee5Label: UILabel!
    @IBOutlet weak var personConfIdTitleLabel: UILabel!
    @IBOutlet weak var personConfIdLabel: UILabel!
    @IBOutlet weak var personConfDescribeLabel: UILabel!
    
    @IBOutlet weak var personConSwitch: UISwitch!
    
    @IBOutlet weak var preConfBtn: UIButton!    // 预约会议按钮
    @IBOutlet weak var advancedSettingsLabel: UILabel!
    
    var timezoneModel: TimezoneModel?
    
    var timezoneList: [TimezoneModel] {
        return TimezoneManger.shared.timezoneList
    }
    
    private var isSMC3: Bool {
        return ManagerService.call()?.isSMC3 ?? false
    }
    
    private var isPreMeetingSettingViewVcCallack: Bool = false
    
    var confBaseInfo: ConfBaseInfo?
    
    private var isVMR: Bool = false
    private var isClickPreMeeting: Bool = false

    fileprivate var selectedDateStr = ""
    fileprivate var selectedTimeLen = 3600 // 1小时
    
    private var meetingType: MeetingType = .deafault {
           didSet{
               switch meetingType {
               case .deafault:
                   self.meetingTypeValueLabel.text = tr("视频会议")
               default:
                   self.meetingTypeValueLabel.text = tr("语音会议")
               }
           }
       }
    
    //密码
    private lazy var password = ""
    @IBOutlet weak var guestPwdLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: TableMoreImagesCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableMoreImagesCell.CELL_ID)

        self.title = tr("预约会议")
        self.meetingTypeValueLabel.text = tr("视频会议")
        
        self.setViewUI()
        
        if isSMC3 {
            getVMRUserInfoList()
            getTimezoneInfo()
        }
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.meetingTitleTextField.delegate = self
        meetingTitleTextField.addTarget(self, action: #selector(textFiledDidChanged), for: .editingChanged)
        
        self.setInitData()
        
        // 接收广播
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdateSelectedAttendee(notification:)), name: NSNotification.Name.init(rawValue: UpdataInvitationAttendee), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeVMRPassword(noti:)), name: NSNotification.Name("updateVMRResult"), object: nil)
        
        passwordTF.addTarget(self, action: #selector(passwordTFTextChange), for: .editingChanged)
    }
    
    private func getTimezoneInfo() {
        if timezoneList.isEmpty { return }
        let localName = (NSTimeZone.local as NSTimeZone).name
        let offset = (NSTimeZone.local as NSTimeZone).secondsFromGMT
        for model in timezoneList {
            if model.timeZoneName == localName, String(model.offset).contains(String(offset)) {
                self.timezoneModel = model
            }
        }
    }
    
    @objc private func textFiledDidChanged(textField: UITextField) {
        guard let toBeString = textField.text else { return }
        let maxNumber = 64
        // 键盘输入模式
        let lang = textField.textInputMode?.primaryLanguage
        if lang == "zh-Hans" {
            let selectedRange = textField.markedTextRange
            let position = textField.position(from: selectedRange?.start ?? UITextPosition(), offset: 0)
            if position != nil {
                if toBeString.getLenthOfBytes() > maxNumber {
                    textField.text = toBeString.subBytesOfstring(to: maxNumber)
                }
            }
        } else {
            if toBeString.getLenthOfBytes() > maxNumber {
                textField.text = toBeString.subBytesOfstring(to: maxNumber)
            }
        }
    }

    //MARK: - 获取用户vmr信息
    private func getVMRUserInfoList() {
        guard ManagerService.confService()?.vmrBaseInfo?.accessNumber?.count ?? 0 > 0  else { return }
        self.confBaseInfo = ManagerService.confService()?.vmrBaseInfo
        isVMR = true
        personConSwitch.isOn = isVMR
        self.guestSwitch.isOn = confBaseInfo?.generalPwd?.count ?? 0 > 0
        self.passwordTF.text = confBaseInfo?.generalPwd
        self.tableView.reloadData()
    }
    
    @objc func passwordTFTextChange(textFild: UITextField) {
        guard let text = textFild.text else { return }
        if text.count > 6 {
            textFild.text = text.subString(to: 6)
        }
    }
    
    @IBAction func eyeButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.passwordTF.isSecureTextEntry = !sender.isSelected
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // change at xuegd : 密码默认隐藏
        self.passwordTF.isSecureTextEntry = true
        self.hideEye.isSelected = false
    }
    
    // MARK: - 接收广播通知
    // MARK: - 接听邀请选中与会者通知
    @objc func notificationUpdateSelectedAttendee(notification: Notification) {
        self.setInitData()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        NSObject.userDefaultSaveValue("", forKey: DICT_SAVE_MEETING_ADVANCE_SETTING_PASSWORD)
        self.navigationController?.popViewController(animated: true)
        SessionManager.shared.currentAttendeeArray.removeAll()
    }
    
    func setViewUI() {
        self.meetingTitleLabel.text = tr("会议主题")
        self.meetingTitleTextField.placeholder = tr("请输入会议ID")
        self.dateTitleLabel.text = tr("开始时间")
        self.timeLengthTitleLabel.text = tr("会议时长")
        self.meetingTypeTitleLabel.text = tr("会议类型")
        self.personConfIdTitleLabel.text = tr("使用个人会议ID")
        self.guestPwdLabel.text = tr("来宾密码")
        self.showAttendeeTitleLabel.text = tr("与会者")
        self.showAtteedee1Label.text = tr("添加")
        self.advancedSettingsLabel.text = tr("高级设置")
        self.preConfBtn.setTitle(tr("预约会议"), for: .normal)
        self.passwordTF.placeholder = tr("请输入1-6位数字密码")
        
        // 设置时间
//        self.selectedDateStr = NSDate.dateToStringForOtherHour(fromNowHours: 0, andFormatterString: DATE_STANDARD_FORMATTER, andDate: Date())
        // 将UTC时间转为本地时间
//        self.selectedDateStr = CommonUtils.getLocalDateFormateUTCDate(self.selectedDateStr)
        
        // 直接获取本地时间,调整手机系统时区会导致预约会议开始时间显示错误
        let df = DateFormatter()
        df.dateFormat = DATE_STANDARD_FORMATTER
        self.selectedDateStr = df.string(from: Date())
        
        let currentminute:NSString = NSString.getRangeOfIndex(withStart: 14, andEnd: 16, andDealStr: self.selectedDateStr)! as NSString
        if currentminute.integerValue < 15 && currentminute.integerValue >= 0 {
            self.selectedDateStr = NSString.getRangeOfIndex(withStart: 0, andEnd: 14, andDealStr: self.selectedDateStr) + "15:00"
        }else if currentminute.integerValue < 30 && currentminute.integerValue >= 15 {
            self.selectedDateStr = NSString.getRangeOfIndex(withStart: 0, andEnd: 14, andDealStr: self.selectedDateStr) + "30:00"
        }else if currentminute.integerValue < 45 && currentminute.integerValue >= 30 {
            self.selectedDateStr = NSString.getRangeOfIndex(withStart: 0, andEnd: 14, andDealStr: self.selectedDateStr) + "45:00"
        }else {
            self.selectedDateStr = NSDate.dateToStringForOtherHour(fromNowHours: 1, andFormatterString: DATE_STANDARD_FORMATTER, andDate: Date())
//            self.selectedDateStr = CommonUtils.getLocalDateFormateUTCDate(self.selectedDateStr)
            self.selectedDateStr = NSString.getRangeOfIndex(withStart: 0, andEnd: 14, andDealStr: self.selectedDateStr) + "00:00"
        }
        
        // chenfan：断网后的样式
        _ = WelcomeViewController.checkNetworkAndUpdateUI()
    }
    
    func setInitData() {
        let userInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
        
        self.updateAttendeeList(attendeeArray: SessionManager.shared.currentAttendeeArray)
        showAttendeeTitleLabel.text = tr("与会者") + "（\(SessionManager.shared.currentAttendeeArray.count+1)）"
        
        if userInfo != nil {
            if HWLoginInfoManager.shareInstance.isSuccessGetName() {
                let name = UserDefaults.standard.object(forKey: DICT_SAVE_NIC_NAME)
                let text = String(format: tr("%@的会议"), name as! String)
                self.meetingTitleTextField.placeholder = text
            }else{
                let text = String(format: tr("%@的会议"), userInfo?.account ?? "")
                self.meetingTitleTextField.placeholder = text
                if !HWLoginInfoManager.shareInstance.isSuccessGetName() {
                    HWLoginInfoManager.shareInstance.getLoginInfoByCorporateDirectory()
                    HWLoginInfoManager.shareInstance.getLoginInfoBack = { (_ name:String) in
                        let text2 = String(format: tr("%@的会议"), name)
                        self.meetingTitleTextField.placeholder = text2
                    }
                }
            }
        }
        
        // 获取 时间
        let dateArray = NSDate.getYearMonthDay(withDatestandrdStr: self.selectedDateStr)
        let year = dateArray![0] as! Int
        let month = dateArray![1] as! Int
        let day = dateArray![2] as! Int
        let hour = dateArray![3] as! Int
        let minute = dateArray![4] as! Int
        
     self.dateValueLabel.text = "\(year)/\(String.init(format: "%02d", month))/\(String.init(format: "%02d", day)) " +  "\(String.init(format: "%02d", hour)):\(String.init(format: "%02d", minute))"
        
        // 设置时长
        let space = isCNlanguage() ? "" : " "
        if self.selectedTimeLen % 3600 == 0 {
            self.timeLengthValueLabel.text = "\(self.selectedTimeLen / 3600)" + space + tr("小时")
        } else if self.selectedTimeLen / 3600 == 0  {
            self.timeLengthValueLabel.text = "\(self.selectedTimeLen % 3600 / 60)" + space + tr("分钟")
        } else {
            self.timeLengthValueLabel.text = "\(self.selectedTimeLen / 3600)" + space  + tr("小时") + space + "\(self.selectedTimeLen % 3600 / 60)" + space + tr("分钟")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    // MARK: - 预约会议
    @IBAction func perMeetingBtnTouchDown(_ sender: UIButton) {
        if isSMC3 {
            if SessionManager.shared.currentAttendeeArray.count > 511 {
                MBProgressHUD.showBottom(tr("预约人数不能超过512"), icon: nil, view: self.view)
                return
            }
        } else {
            if SessionManager.shared.currentAttendeeArray.count > 29 {
                MBProgressHUD.showBottom(tr("预约人数不能超过30"), icon: nil, view: self.view)
                return
            }
        }
        NSObject.userDefaultSaveValue("", forKey: DICT_SAVE_MEETING_ADVANCE_SETTING_PASSWORD)
        SessionManager.shared.isBespeak = true
        
        var guestPassword = ""
        if personConSwitch.isOn {
            if guestSwitch.isOn {
                guestPassword = passwordTF.text ?? ""
                if !passwordTF.hasText {
                    MBProgressHUD.showBottom(tr("请输入1-6位数字密码"), icon: nil, view: self.view)
                    return
                }
                isClickPreMeeting = true
                if self.confBaseInfo?.generalPwd != passwordTF.text {
                    updateVMRInfo()
                    return
                }
            } else {
                guestPassword = ""
            }
        } else {
            guestPassword = guestSwitch.isOn ? getRamdomNum() : ""
        }
        createMeeting(confSubject: getMeetingTitle(),
                      startDate: getStartDate(),
                      confLen: selectedTimeLen,
                      otherAttendeeArray: NSArray.init(array: SessionManager.shared.currentAttendeeArray) as? [LdapContactInfo],
                      chairmanPassword: personConSwitch.isOn ? confBaseInfo?.chairmanPwd ?? "" : "",
                      guestPassword: guestPassword,
                      meetingType: meetingType,
                      timezone: self.timezoneModel ?? TimezoneModel(),
                      personalConfId: personConSwitch.isOn ? confBaseInfo?.accessNumber ?? "" : "")
        self.navigationController?.popViewController(animated: true)
        SessionManager.shared.currentAttendeeArray.removeAll()
    }
    
    private func getMeetingTitle() -> String {
        var meetingTitle = self.meetingTitleTextField.text
        if meetingTitle == "" {
            let placeholder = self.meetingTitleTextField.placeholder
            let length = placeholder?.getLenthOfBytes() ?? 0
            let max = 64
            if length > max {
                if isCNlanguage() {
                    meetingTitle = "\(placeholder?.subBytesOfstring(to: length - 12 - (length - max)) ?? "")...的会议"
                } else {
                    meetingTitle = "\(placeholder?.subBytesOfstring(to: length - 12 - (length - max)) ?? "")...'s Meeting"
                }
            } else {
                meetingTitle = placeholder
            }
        }
        return meetingTitle ?? ""
    }

    private func getStartDate() -> Date {
        return NSDate.init(from: self.selectedDateStr, andFormatterString: DATE_STANDARD_FORMATTER, andTimeZone:TimeZone.init(abbreviation: "UTC")) as Date
    }
    
    func getRamdomNum() -> String {
        let result = String(arc4random_uniform(899999) + 100000)
        return result
    }
    
    private func updateVMRInfo(){
        let result = ManagerService.confService()?.updateVmrList(confBaseInfo?.chairmanPwd, generalStr: passwordTF.text, confId: confBaseInfo?.accessNumber)
        print("3.0更新vmr信息返回结果result====\(String(describing: result)),generalPwd:\(confBaseInfo?.generalPwd ?? "")====ChairPwd:\(confBaseInfo?.chairmanPwd ?? "")===AccessNumber:\(confBaseInfo?.accessNumber ?? "")")
    }

    // 修改来宾密码回调
    @objc private func changeVMRPassword(noti:Notification) {
        DispatchQueue.main.async {
            guard let result = noti.userInfo?["result"] as? String else { return }
            if "0" == result {
                MBProgressHUD.showBottom(tr("密码修改成功"), icon: nil, view: self.view)
                ManagerService.confService()?.vmrBaseInfo.generalPwd = self.passwordTF.text
                if !self.isClickPreMeeting { return }
                
                NSObject.userDefaultSaveValue("", forKey: DICT_SAVE_MEETING_ADVANCE_SETTING_PASSWORD)
                SessionManager.shared.isBespeak = true
                self.createMeeting(confSubject: self.getMeetingTitle(),
                                   startDate: self.getStartDate(),
                                   confLen: self.selectedTimeLen,
                                   otherAttendeeArray: NSArray.init(array: SessionManager.shared.currentAttendeeArray) as? [LdapContactInfo],
                                   chairmanPassword: self.personConSwitch.isOn ? self.confBaseInfo?.chairmanPwd ?? "" : "",
                                   guestPassword: self.passwordTF.text ?? "",
                                   meetingType: self.meetingType,
                                   timezone: self.timezoneModel ?? TimezoneModel(),
                                   personalConfId: self.personConSwitch.isOn ? self.confBaseInfo?.accessNumber ?? "" : "")
                self.navigationController?.popViewController(animated: true)
                SessionManager.shared.currentAttendeeArray.removeAll()
            } else {
                if "67109102" == result {
                    MBProgressHUD.showBottom(tr("您的个人会议ID已被预约或正在召开会议，密码修改失败"), icon: nil, view: self.view)
                    return
                }
                MBProgressHUD.showBottom(tr("密码修改失败"), icon: nil, view: self.view)
            }
        }
    }
    
    private func createMeeting(confSubject: String?,
                               startDate: Date?,
                               confLen: Int,
                               otherAttendeeArray: [LdapContactInfo]?,
                               chairmanPassword: String = "",
                               guestPassword: String = "",
                               meetingType: MeetingType? = .deafault,
                               timezone: TimezoneModel = TimezoneModel(),
                               personalConfId: String = "") {
        MBProgressHUD.showMessage(tr("预约会议中") + "...")
        let attendeeArray = NSMutableArray.init()
        let mine = ManagerService.loginService()?.obtainCurrentLoginInfo()
        let myName = NSString.getSipaccount(ManagerService.call()?.sipAccount)
        if isSMC3 {
            let info = ManagerService.call()?.ldapContactInfo
            attendeeArray.add(info ?? LdapContactInfo())
        } else {
            let attendMe = LdapContactInfo.init()
            attendMe.name = HWLoginInfoManager.shareInstance.isSuccessGetName() ? (UserDefaults.standard.object(forKey: DICT_SAVE_NIC_NAME) as? String) : myName
            attendMe.number = ManagerService.call()?.terminal
            attendMe.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
            attendMe.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
            attendeeArray.add(attendMe)
        }
        if otherAttendeeArray != nil {
            attendeeArray.addObjects(from: otherAttendeeArray!)
        }
        // 会议类型
        let meetingType = (meetingType == .deafault) ? CONF_MEDIATYPE_VIDEO : CONF_MEDIATYPE_VOICE
        CLLog("预约会议类型 - \(meetingType)")
        let title = confSubject ?? mine?.account ?? ""
        let creatSucess = ManagerService.confService()?.createConference(withAttendee: attendeeArray as? [Any],
                                                                         mediaType: meetingType,
                                                                         subject: title,
                                                                         startTime: startDate,
                                                                         confLen: Int32(confLen / 60),
                                                                         chairmanPassword: chairmanPassword,
                                                                         guestPassword: guestPassword,
                                                                         timezoneModel: timezone,
                                                                         personalConfId: personalConfId)
        CLLog("\(isSMC3 ? "3.0" : "2.0")预约 \(personConSwitch.isOn ? "VMR" : "普通") 会议结果 = \(String(describing: creatSucess))")
    }
    
    // MARK: cell click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.view.endEditing(true)
        if indexPath.section == 0 && indexPath.row == 1 { // 开始时间
            let datePicker = EWDatePickerViewController()
            self.definesPresentationContext = true
            datePicker.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            datePicker.picker.reloadAllComponents()
            
            datePicker.backDate = {[weak self] date in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                // 选择时间
                self?.selectedDateStr = dateFormatter.string(from: date)
                self?.setInitData()
            }
            let dateArray = NSDate.getYearMonthDay(withDatestandrdStr: self.selectedDateStr)
            var dateCom = DateComponents.init()
            dateCom.year = (dateArray![0] as! Int)
            dateCom.month = (dateArray![1] as! Int)
            dateCom.day = (dateArray![2] as! Int)
            dateCom.hour = (dateArray![3] as! Int)
            dateCom.minute = (dateArray![4] as! Int)
            datePicker.selectDateCom = dateCom
            present(datePicker, animated: true)
        }
        
        if  indexPath.section == 0 && indexPath.row == 2 { // 会议时长
            let hourMinutePickerVC = ViewHourMinuteController.init(nibName: "ViewHourMinuteController", bundle: nil)
            hourMinutePickerVC.selectedTimeLen = self.selectedTimeLen
            hourMinutePickerVC.modalPresentationStyle = .overFullScreen
            hourMinutePickerVC.modalTransitionStyle = .crossDissolve
            hourMinutePickerVC.customDelegate = self
            hourMinutePickerVC.title = tr("请选择会议时长")
            self.present(hourMinutePickerVC, animated: true, completion: nil)
        }
        
        if  indexPath.section == 0 && indexPath.row == 3 { // 会议类型
            let meetingTypeSetViewVC = MeetingTypeSetViewController.init()

            meetingTypeSetViewVC.typeComeBack = {[weak self]type in
                self?.meetingType = type
            }
            meetingTypeSetViewVC.type = meetingType
            self.navigationController?.pushViewController(meetingTypeSetViewVC, animated: true)
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0: // 与会者
                let preMeetingAttendeeStoryboard = UIStoryboard.init(name: "PreMeetingAttendeeViewController", bundle: nil)
                let preMeetingAttendeeViewVC = preMeetingAttendeeStoryboard.instantiateViewController(withIdentifier: "PreMeetingAttendeeView") as! PreMeetingAttendeeViewController
                self.navigationController?.pushViewController(preMeetingAttendeeViewVC, animated: true)
            case 1: // 添加
                let searchAttendeeStoryboard = UIStoryboard.init(name: "SearchAttendeeViewController", bundle: nil)
                let searchAttendee = searchAttendeeStoryboard.instantiateViewController(withIdentifier: "SearchAttendeeView") as! SearchAttendeeViewController
                searchAttendee.isFromPreMeeting = true
                
                self.navigationController?.pushViewController(searchAttendee, animated: true)
            case 2: // 高级设置
                let storyboard = UIStoryboard.init(name: "MeetAdvanceSetViewController", bundle: nil)
                let preMeetingSettingViewVC = storyboard.instantiateViewController(withIdentifier: "MeetAdvanceSetView") as! MeetAdvanceSetViewController
                if timezoneList.isEmpty {
                    // 重新获取时区列表
                    TimezoneManger.shared.getTimezoneList()
                    MBProgressHUD.showBottom(tr("未查询到时区信息"), icon: nil, view: self.view)
                } else {
                    if !isPreMeetingSettingViewVcCallack {
                        getTimezoneInfo()
                    }
                    preMeetingSettingViewVC.meetingType = self.meetingType
                    preMeetingSettingViewVC.isFromPreMeeting = true
                    preMeetingSettingViewVC.timezoneModel = self.timezoneModel
                    preMeetingSettingViewVC.timezoneList = timezoneList
                    preMeetingSettingViewVC.passwordTwxtCallBack = {[weak self] password in
                        self?.password = password
                    }
                    preMeetingSettingViewVC.timezoneCallBack = {[weak self] (timezoneModel: TimezoneModel) in
                        self?.isPreMeetingSettingViewVcCallack = true
                        self?.timezoneModel = timezoneModel
                        print("offset = \(timezoneModel.offset), timeZoneId =  \(String(describing: timezoneModel.timeZoneId))")
                    }
                    self.navigationController?.pushViewController(preMeetingSettingViewVC, animated: true)
                }
            default:
                break
            }
        }
    }
    
    // 使用个人会议ID
    @IBAction func personalSwitchChanged(_ sender: UISwitch) {
        if !sender.isOn {
            guestSwitch.isOn = true
        }
        self.tableView.reloadData()
    }
    
    // 来宾密码
    @IBAction func clickGuestPassword(_ sender: UISwitch) {
        // chenfan：断网后的样式
        if WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            sender.setOn(!sender.isOn, animated: true)
            return
        }
        
        let result = LocalVMRInfoManager.getGeneralPwdAlertViewStatus()
        if personConSwitch.isOn, !sender.isOn {
            isClickPreMeeting = false
            if result {
                passwordTF.text = ""
                updateVMRInfo()
            }
        }
        
        self.passwordTF.isSecureTextEntry = true
        self.hideEye.isSelected = false
        
        if !sender.isOn {
            if !result { //弹窗处理
                let dangerView =  DangerStatementCustomView.creatDangerStatementCustomView()
                dangerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                let personalText = tr("来宾密码关闭后，所有个人会议ID:") + (NSString.dealMeetingId(withSpaceString: confBaseInfo?.accessNumber ?? "")) + tr("相关会议密码全部关闭，当前操作存在安全风险，建议开启来宾密码。")
                let noPersonalText = tr("当前会议未设置来宾密码，存在安全风险，建议开启来宾密码")
                dangerView.contentStr = personConSwitch.isOn ? personalText : noPersonalText
                self.view.addSubview(dangerView)
                dangerView.passAlertStatementValueBlock = { [self]( isAgree: Bool, isConfirm: Bool ) in
                    if isConfirm {//点击了确认按钮
                        if personConSwitch.isOn {
                            passwordTF.text = ""
                            updateVMRInfo()
                        }
                        sender.isOn = false
                        if isAgree {//选了同意并点击了确认按钮
                            LocalVMRInfoManager.updateGeneralPwdAlertViewStatus()
                        }
                    } else {//选择取消，重新打开switch
                        sender.isOn = true
                    }
                    self.tableView.reloadData()
                }
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - TableViewDelegate 代理方法的实现
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isSMC3 ? (isVMR ? (personConSwitch.isOn ? 8 : 6) : 6) : 4
        case 1:
            return isSMC3 ? 3 : 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 4 {
                return isVMR ? 54 : 0.001
            } else if indexPath.row == 6 {
                return guestSwitch.isOn ? 54 : 0.001
            } else {
                return indexPath.row == 0 ? 72 : 54
            }
        } else if indexPath.section == 1 {
            return indexPath.row == 1 ? 100 : 54
        }
        return 54
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        guestPwdLabel.text = isSMC3 ? tr("来宾密码") : tr("会议/主持人密码")
        if indexPath.section == 0 && indexPath.row == 4 {
            cell.isHidden = !isVMR
        }
        if isSMC3 {
            if confBaseInfo != nil {
                let number = NSString.dealMeetingId(withSpaceString: confBaseInfo?.accessNumber ?? "")
                self.personConfIdLabel.text = personConSwitch.isOn ? tr("使用个人会议ID") + tr("：") + "\(number ?? "")" : tr("使用个人会议ID")
                self.personConfDescribeLabel.text = tr("您的当前操作将用于个人会议ID:") + "\(number ?? "")" + tr("的全部会议")
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 10 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
        header.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "#fafafa"), darkColor: UIColor(hexString: "#1a1a1a"))
        return header
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: - ViewDateTimePickerDelegate
    // MARK: selected date
    func viewDateTimePickerSureBtnClick(viewVC: ViewDateTimePickerController, selectedDateStr: String) {
        // 选择时间
        self.selectedDateStr = selectedDateStr
        self.setInitData()
    }
    
    // MARK: - ViewHourMinuteDelegate
    // MARK: selected time
    func viewHourMinuteSureBtnClick(viewVC: ViewHourMinuteController, seconds: Int) {
        self.selectedTimeLen = seconds
        self.setInitData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 更新与会者列表
    func updateAttendeeList(attendeeArray: [LdapContactInfo]) {
        self.showAttendee1ImageView.image = UIImage.init(named: "invite_attendee_add")
        let loginInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
        self.showAttendee2ImageView.image = getUserIconWithAZ(name: loginInfo?.userName ?? ("(" + tr("我") + ")"))
        self.showAtteedee2Label.text = "(" + tr("我") + ")"
        self.showAttendee3View.isHidden = true
        self.showAttendee4View.isHidden = true
        self.showAttendee5View.isHidden = true
        
        switch attendeeArray.count+1 {
        case 0:
            CLLog("没有与会者")
        case 4...:
            let attendee5 = attendeeArray[2]
            self.showAttendee5ImageView.image = getUserIconWithAZ(name: attendee5.name)
            self.showAtteedee5Label.text = attendee5.name
            self.showAttendee5View.isHidden = false
            fallthrough
        case 3:
            let attendee4 = attendeeArray[1]
            self.showAttendee4ImageView.image = getUserIconWithAZ(name: attendee4.name)
            self.showAtteedee4Label.text = attendee4.name
            self.showAttendee4View.isHidden = false
            fallthrough
        case 2:
            let attendee3 = attendeeArray[0]
            self.showAttendee3ImageView.image = getUserIconWithAZ(name: attendee3.name)
            self.showAtteedee3Label.text = attendee3.name
            self.showAttendee3View.isHidden = false
            fallthrough
        case 1:
            CLLog("我")
        default:
            CLLog("not define.")
        }
    }

}
