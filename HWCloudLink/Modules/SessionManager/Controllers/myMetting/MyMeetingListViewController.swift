//
//  MyMeetingListViewController.swift
//  HWCloudLink
//
//  Created by mac on 2020/12/25.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MyMeetingListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var TableViewBottomConstraints: NSLayoutConstraint!
    
    fileprivate var page: Int32 = 0
    var allMeetArr:NSMutableArray = NSMutableArray.init()
    var dataSource: NSMutableDictionary = [:]
    var dataKeysArray: [String] = []
    private var isRequest = false
    
    private var isLeaveMeeting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tr("我的会议")
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 获取网络数据
        MBProgressHUD.showMessage("")
        ManagerService.confService()?.obtainConferenceList(withPageIndex: self.page, pageSize: 8)
        
//        self.TableView.estimatedRowHeight = 0
//        self.TableView.estimatedSectionHeaderHeight = 0
//        self.TableView.estimatedSectionFooterHeight = 0
        self.TableView.register(UINib.init(nibName: MyMeetingTwoSMCTableViewCell.CellID, bundle: nil), forCellReuseIdentifier: MyMeetingTwoSMCTableViewCell.CellID)
        self.TableView.register(UINib.init(nibName: MyMeetingThreeSMCTableViewCell.CellID, bundle: nil), forCellReuseIdentifier: MyMeetingThreeSMCTableViewCell.CellID)
        self.TableView.register(UINib.init(nibName: MyMeetingEmptyTableViewCell.CellID, bundle: nil), forCellReuseIdentifier: MyMeetingEmptyTableViewCell.CellID)
        self.TableView.register(MyMeetingDayTimeHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: MyMeetingDayTimeHeaderView.CellID)
        self.TableView.separatorStyle = .none
        
        // chenfan：断网后的样式
        _ = WelcomeViewController.checkNetworkWithNoNetworkAlert()
        
        // 2.0有下拉加载
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(self.headerRefresh))
        header.setTitle(tr("下拉刷新"), for: .idle)
        header.setTitle(tr("松开立即刷新"), for: .pulling)
        header.setTitle(tr("正在加载"), for: .refreshing)
        header.lastUpdatedTimeLabel?.isHidden = true
        self.TableView.mj_header = header
        // 3.0有上拉加载
        if ManagerService.call()?.isSMC3 == true {
            //  fix jiangbz 上拉加载更多显示在安全区问题
            if isiPhoneXMore() {
                self.TableViewBottomConstraints.constant = -34
            }else{
                self.TableViewBottomConstraints.constant = 0
            }
            let footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(self.footerRefresh))
            footer.setTitle(tr("上拉可以加载更多"), for: .idle)
            footer.setTitle(tr("松开立即加载更多"), for: .pulling)
            footer.setTitle(tr("正在加载"), for: .refreshing)
            footer.setTitle(tr("--没有更多了--"), for: MJRefreshState.noMoreData)
            self.TableView.mj_footer = footer
        }
        // 接收广播
        NotificationCenter.default.addObserver(self, selector: #selector(notificationConfList(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_QUERY_CONF_LIST_RESULT), object: nil)
        // 取消会议刷新
        NotificationCenter.default.addObserver(self, selector: #selector(cancleMeetingNotfic(notfication:)), name: NSNotification.Name.init(CancelTheMeetingSuccess), object: nil)
        //会议结束
        NotificationCenter.default.addObserver(self, selector: #selector(notificationEndCall), name: NSNotification.Name(CALL_S_CALL_EVT_CALL_ENDED), object: nil)
    }
    
    // 下拉刷新
    @objc func headerRefresh() {
        self.page = 0
        self.dataSource.removeAllObjects()
        self.allMeetArr.removeAllObjects()
        ManagerService.confService()?.obtainConferenceList(withPageIndex: self.page, pageSize: PAGE_COUNT_8PRE)
    }
    
    // 下拉加载
    @objc func footerRefresh() {
        self.page += 1
        ManagerService.confService()?.obtainConferenceList(withPageIndex: self.page, pageSize: PAGE_COUNT_8PRE)
    }
    
    @objc func notificationEndCall(notification: Notification) {
        isLeaveMeeting = true
        MBProgressHUD.hide()
        guard let resultInfo = notification.userInfo ,
              let callInfo = resultInfo[TSDK_CALL_INFO_KEY] as? CallInfo
            else {
            CLLog("呼叫结束会议信息不正确")
            return
        }
        guard let _ = callInfo.serverConfId else {
            MBProgressHUD.showBottom(tr("会议未开始或不存在"), icon: nil, view: self.view)
            return
        }
        // 重新刷新会议列表
        if !UI_IS_LANDSCAPE {
            headerRefresh()
        }
        if reasonCodeIsEqualErrorType(reasonCode: callInfo.stateInfo.reasonCode, type: TSDK_E_CALL_ERR_REASON_CODE_NOTFOUND.rawValue) {
            MBProgressHUD.showBottom(tr("会议未开始或不存在"), icon: nil, view: nil)
        } else if reasonCodeIsEqualErrorType(reasonCode: callInfo.stateInfo.reasonCode, type: TSDK_E_CALL_ERR_UNKNOWN.rawValue) {
            MBProgressHUD.showBottom(tr("会议未开始或不存在"), icon: nil, view: nil)
        }
    }
    
    // 获取会议列表回调通知
    @objc func notificationConfList(notification: Notification) {
        isRequest = true
        MBProgressHUD.hide()
        self.TableView.mj_header?.endRefreshing()
        
        if ManagerService.call()?.isSMC3 ?? false  {
            if self.page == 0 || isLeaveMeeting {
                self.dataSource.removeAllObjects()
                self.allMeetArr.removeAllObjects()
                isLeaveMeeting = false
            }
        } else {
            self.dataSource.removeAllObjects()
            self.allMeetArr.removeAllObjects()
        }
        
        // 有数据
        if notification.object != nil {
            self.TableView.mj_footer?.endRefreshing()
            let resultArray = notification.object as? [ConfBaseInfo]
            
            if resultArray?.count ?? 0 < PAGE_COUNT_8PRE {
                self.TableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
            if resultArray?.count == 0 { // 下一页没有数据了
                self.TableView.mj_footer?.endRefreshingWithNoMoreData()
                self.TableView.reloadData()
                return
            }

            // 数据分割
            for meetInfo in resultArray! {
                if meetInfo.startTime == "" || meetInfo.startTime == nil {
                    continue
                }
                self.allMeetArr.add(meetInfo)
                let startDateStr = NSString.getRangeOfIndex(withStart: 0, andEnd: 11, andDealStr: meetInfo.startTime)
                var tempArray = self.dataSource.object(forKey: startDateStr as Any) as? NSMutableArray
                if tempArray == nil {
                    tempArray = NSMutableArray.init()
                    tempArray?.add(meetInfo)
                    self.dataSource.setValue(tempArray, forKey: startDateStr!)
                } else {
                    tempArray?.add(meetInfo)
                }
            }
            // 将key值进行排序
            self.dataKeysArray = (self.dataSource.allKeys.sorted(by: { (str1, str2) -> Bool in
                let str1Temp = str1 as! String
                let str2Temp = str2 as! String
                return str1Temp < str2Temp
            }) as? [String] ?? [])
            CLLog("!@#$%^&* 会议列表条目个数：\(resultArray?.count ?? 0)")
            self.TableView.reloadData()
        }else{
            if self.page != 0 {
                self.page -= 1
            }
            self.TableView.mj_footer?.endRefreshing()
            self.TableView.mj_footer?.endRefreshingWithNoMoreData()
        }
    }
    // 取消会议通知
    @objc func cancleMeetingNotfic(notfication:Notification) {
        if notfication.userInfo != nil {
            let confid = notfication.userInfo?["confID"] as! String
            // 移除对应的会议
            for confModel in self.allMeetArr {
                let meetModel:ConfBaseInfo = confModel as! ConfBaseInfo
                if meetModel.accessNumber == confid {
                    self.allMeetArr.remove(confModel)
                    break
                }
            }
            
            // 移除所有数据
            self.dataSource.removeAllObjects()
            // 从新排序刷新列表
            for meetConf in self.allMeetArr {
                let meetInfo:ConfBaseInfo = meetConf as! ConfBaseInfo
                let startDateStr = NSString.getRangeOfIndex(withStart: 0, andEnd: 11, andDealStr: meetInfo.startTime)
                var tempArray = self.dataSource.object(forKey: startDateStr as Any) as? NSMutableArray
                if tempArray == nil {
                    tempArray = NSMutableArray.init()
                    tempArray?.add(meetInfo)
                    self.dataSource.setValue(tempArray, forKey: startDateStr!)
                } else {
                    tempArray?.add(meetInfo)
                }
            }
            // 将key值进行排序
            self.dataKeysArray = (self.dataSource.allKeys.sorted(by: { (str1, str2) -> Bool in
                let str1Temp = str1 as! String
                let str2Temp = str2 as! String
                return str1Temp < str2Temp
            }) as? [String] ?? [])
            self.TableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.dataSource.count == 0 {
            if !isRequest {
                return 0
            }
            return 1
        }
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.dataSource.count == 0 {
            return 1
        }
        let key = dataKeysArray[section]
        let resultArray = self.dataSource[key] as! NSArray
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataSource.count == 0 {
            let Cell = tableView.dequeueReusableCell(withIdentifier: MyMeetingEmptyTableViewCell.CellID) as! MyMeetingEmptyTableViewCell
            Cell.selectionStyle = .none
            Cell.TitleLabel.text = tr("暂无会议")
            Cell.TitleLabel.textColor = UIColor(hexString: "#999999")
            return Cell
        }
        
        // 解析数据
        let key = self.dataKeysArray[indexPath.section]
        let resultArray = self.dataSource[key] as! Array<ConfBaseInfo>
        let meetInfo = resultArray[indexPath.row]
        
        // SMC 2.0
        if ManagerService.call()?.isSMC3 == false {
            let dataCell = tableView.dequeueReusableCell(withIdentifier: MyMeetingTwoSMCTableViewCell.CellID, for: indexPath) as! MyMeetingTwoSMCTableViewCell
            dataCell.showJoinBtn.isHidden = false
            dataCell.loadData(meetInfo: meetInfo, isShow: isShowJoinButton(meetInfo: meetInfo), indexPath: indexPath)
            dataCell.showJoinBtn.addTarget(self, action: #selector(joinBtnClick(sender:)), for: .touchUpInside)
            
            // chenfan：断网后的样式
            setDisconnectedStyle(button: dataCell.showJoinBtn)
            return dataCell
        }
        
        // SMC 3.0
        let dataCell = tableView.dequeueReusableCell(withIdentifier: MyMeetingThreeSMCTableViewCell.CellID, for: indexPath) as! MyMeetingThreeSMCTableViewCell
        dataCell.loadData(meetInfo: meetInfo, indexPath: indexPath)
        dataCell.joinInBtn.addTarget(self, action: #selector(joinBtnClick(sender:)), for: .touchUpInside)
        
        // chenfan：断网后的样式
        setDisconnectedStyle(button: dataCell.joinInBtn)
        return dataCell
    }
    
    // 2.0 是否显示加入会议按钮
    private func isShowJoinButton(meetInfo: ConfBaseInfo) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate =  NSDate(from: dateFormatter.string(from: Date()), andFormatterString: "yyyy-MM-dd", andTimeZone: nil) as Date
        let startDate = NSDate(from: meetInfo.startTime.components(separatedBy: " ").first ?? "", andFormatterString: "yyyy-MM-dd", andTimeZone: nil) as Date
        if !meetInfo.endTime.isEmpty {
            let endDate = NSDate(from: meetInfo.endTime.components(separatedBy: " ").first ?? "", andFormatterString: "yyyy-MM-dd", andTimeZone: nil) as Date
            if currentDate >= startDate, currentDate <= endDate {
                return true
            } else {
                return false
            }
        } else if currentDate >= startDate {
            return true
        } else {
            return false
        }
    }
    
    private func setDisconnectedStyle(button: UIButton) {
        if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.offline {
            UIView.hideSetBtnBorderColorNoAction(withYesOrNo: true, andView: button, andBorderColor: COLOR_GRAY_WHITE)
        } else {
            UIView.hideSetBtnBorderColorNoAction(withYesOrNo: false, andView: button, andBorderColor: COLOR_HIGHT_LIGHT_SYSTEM)
        }
    }
    
    /**  是否为今天 */
//    private func isToday(date: Date) -> Bool{
//        let calendar = Calendar.current
//        let unit: Set<Calendar.Component> = [.day,.month,.year]
//        let nowComps = calendar.dateComponents(unit, from: Date())
//        let selfCmps = calendar.dateComponents(unit, from: date)
//        return (selfCmps.year == nowComps.year) &&
//        (selfCmps.month == nowComps.month) &&
//        (selfCmps.day == nowComps.day)
//    }
//
//    private func string2Date(_ string:String, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> Date {
//        let formatter = DateFormatter()
//        formatter.locale = Locale.init(identifier: "zh_CN")
//        formatter.dateFormat = dateFormat
//        let date = formatter.date(from: string)
//        return date!
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataSource.count == 0 {
            return
        }

        let sessionDetailVC : MeetingDetailViewController = MeetingDetailViewController.init()
        sessionDetailVC.hidesBottomBarWhenPushed = true
        // 解析数据
        let key = self.dataKeysArray[indexPath.section]
        let resultArray = self.dataSource[key] as! Array<ConfBaseInfo>
        sessionDetailVC.meetInfo = resultArray[indexPath.row]
        let meetInfo = resultArray[indexPath.row]
        sessionDetailVC.isShowJoinBtn = isShowJoinButton(meetInfo: meetInfo)
        self.navigationController?.pushViewController(sessionDetailVC, animated: true)
    }
    
    // 是否是持续会议
//    private func isContinueConf(meetInfo: ConfBaseInfo) -> Bool {
//        if meetInfo.endTime != nil && meetInfo.endTime != "" { return false } else { return true }
//    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataSource.count == 0 {
            return MyMeetingEmptyTableViewCell.CellHeight
        }
        return isiPhoneXMore() ? (SCREEN_HEIGHT - AppNaviHeight - tableView.sectionHeaderHeight - 34) / CGFloat(PAGE_COUNT_8PRE) : MyMeetingTwoSMCTableViewCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.dataSource.count == 0 {
            return UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.01))
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyMeetingDayTimeHeaderView.CellID) as! MyMeetingDayTimeHeaderView
        headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#222222")
        // 解析数据
        let key = self.dataKeysArray[section]
        let todayDate = Date.init()
        let todayDateStr = NSDate.string(from: todayDate, andFormatterString: DATE_STANDARD_FORMATTER)
        let tomorrowDateStr = NSDate.string(from: NSDate.init(toStringForOtherDateFromNowDays: 1, andOriginalDate: todayDate) as Date?, andFormatterString: DATE_STANDARD_FORMATTER)
        
        if (todayDateStr?.contains(key))! {
            headerView.label.text = tr("今天")
        } else if (tomorrowDateStr?.contains(key))! {
            headerView.label.text = tr("明天")
        } else {
            headerView.label.text = key
        }
        
        return headerView
    }

    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.dataSource.count == 0 ? 0.01 : MyMeetingDayTimeHeaderView.CellHeight
    }
    
    // MARK: footer Title
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    // MARK: footer View
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.01))
    }
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    @objc func joinBtnClick(sender:UIButton) {
        isLeaveMeeting = false
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        
        // 频繁离会入会crash修复
        if self.dataSource.allKeys.isEmpty { return }

        let section = Int(sender.accessibilityValue!)
        let row = sender.tag
        
        // 解析数据
        let key = self.dataKeysArray[section!]
        let resultArray = self.dataSource[key] as! Array<ConfBaseInfo>
        let meetInfo = resultArray[row]
        
        if meetInfo.confType == TSDK_E_CONF_EX_AUDIO {
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
        
        MBProgressHUD.showMessage(tr("正在加入会议") + "...")
            
        meetInfo.isConf = true
        // 实际： 先获取会议详情 -- 已和SDK确认，没有会议详情接口
        let number = ManagerService.call()?.terminal
        // 加入会议弹框
        ManagerService.confService()?.joinConference(withConfId: meetInfo.confId, accessNumber: meetInfo.accessNumber, confPassWord: meetInfo.generalPwd, joinNumber: number, isVideoJoin: true  )
    }
    
    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    @objc func leftBarBtnItemClick() {
        /*
        nowTimer?.invalidate()
        nowTimer = nil
        */
        NotificationCenter.default.removeObserver(self)
        navigationController?.popViewController(animated: true)
    }
    
    
    deinit {
        /*
        nowTimer?.invalidate()
        nowTimer = nil
        */
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MyMeetingListViewController: TextTitleViewDelegate {
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
