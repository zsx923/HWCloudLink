//
// ContactViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import MessageUI
import Social

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var addBarItem: UIBarButtonItem!
    
    @IBOutlet weak var showTopView: UIView!
    // 企业通讯录
    @IBOutlet weak var companyContact: UIButton!
    // 本地通讯录
    @IBOutlet weak var localContact: UIButton!
    // 通话记录
    @IBOutlet weak var recentContact: UIButton!
    
    @IBOutlet weak var showTopTipLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var firstCharactorArr : [String] = []
    
    fileprivate var localContactDictionary = NSMutableDictionary.init()
    
    fileprivate var nearlyContactArr = NSMutableArray.init()
    
    fileprivate var iscellDataNull = true
    fileprivate var emptyDataSource = [[DICT_TITLE: tr("企业通讯录"),
                                       DICT_SUB_TITLE: tr("包含企业内所有的联系人"),
                                       DICT_IMAGE_PATH: "corporate"],
                                       
//                                       [DICT_TITLE: "本地通讯录",
//                                       DICT_SUB_TITLE: "可关联手机上的个人通讯录",
//                                       DICT_IMAGE_PATH: "mobile_phone",],
                                       
                                       [DICT_TITLE: tr("通话记录"),
                                       DICT_SUB_TITLE: tr("记录最近的20条通话记录"),
                                       DICT_IMAGE_PATH: "recent_call",],
                                       
                                       [DICT_TITLE: tr("拨号盘"),
                                       DICT_SUB_TITLE: tr("输入号码呼叫联系人"),
                                       DICT_IMAGE_PATH: "iphonekey",],
                                       
                    ]
    fileprivate var sectionNumber = 0
    fileprivate var vcardPath: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sectionNumber = 0
        setInitData()
        
        self.localContact.isHidden = false
        if self.sectionNumber == 0{
            self.companyContact.isHidden = true
            self.recentContact.isHidden = true
            self.localContact.isHidden = true
        }else{
            self.companyContact.isHidden = false
            self.recentContact.isHidden = false
            self.localContact.isHidden = false//先隐藏

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.title = "HW CloudLink"
        self.setViewUI()
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
        // 设置tableview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.registerCell()
        self.tableView.separatorStyle = .none
        self.companyContact.titleLabel?.numberOfLines = 2
        // language change
        NotificationCenter.default.addObserver(self, selector: #selector(languageChange(notfic:)), name: NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE), object: nil)
        
        // 去除首次加载时显示的网络异常提示
        WelcomeViewController.netWorkAndContentOffWithVC(viewController: self)
    }
    
    deinit {
        CLLog("ContactViewController deinit")
    }
    
    func registerCell() {
        self.tableView.register(UINib.init(nibName: TableImageTextNextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageTextNextCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableImageTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageTextCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableImageTextNextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageTextNextCell.CELL_ID)
        self.tableView.register(TableHeaderFooterTextCell.classForCoder(), forHeaderFooterViewReuseIdentifier: TableHeaderFooterTextCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTextCell.CELL_ID)
    }
    
    func setInitData(){
        LocalContactBusiness.shareInstance.selectFirstCharactor(type: -1) { (arr) in
            if arr.count != 0{
                self.sectionNumber += 1
            }
            self.firstCharactorArr = arr
            for firstCharactor in arr {
                //本地通讯录
                LocalContactBusiness.shareInstance.selectLocalContactByFirstCharactor(type: -1,firstCharactor: firstCharactor) { (localContactArr) in
                    self.localContactDictionary.setValue(localContactArr, forKey: firstCharactor)
                }
            }
            self.nearlyContactArr.removeAllObjects()
//            UserCallLogBusiness.shareInstance.selectNearlyUserCallLog { (arr) in
//                if arr.count != 0{
//                    self.sectionNumber += 1
//                }
//                self.nearlyContactArr.addObjects(from: arr)
//            }
        }
        
        // 判断空状态
        self.iscellDataNull = (self.firstCharactorArr.count == 0 && self.nearlyContactArr.count == 0)
        self.showTopTipLabel.isHidden = !self.iscellDataNull
        self.companyContact.isHidden = self.iscellDataNull
//        self.top2Btn.isHidden = self.iscellDataNull
//        self.top2Btn.isHidden = true
        self.recentContact.isHidden = self.iscellDataNull
        
        self.tableView.reloadData()
    }
    
    @objc func languageChange(notfic:Notification) {
        emptyDataSource = [[DICT_TITLE: tr("企业通讯录"),
                            DICT_SUB_TITLE: tr("包含企业内所有的联系人"),
                            DICT_IMAGE_PATH: "corporate"],
                           
//                           [DICT_TITLE: "本地通讯录",
//                           DICT_SUB_TITLE: "可关联手机上的个人通讯录",
//                           DICT_IMAGE_PATH: "mobile_phone",],
                                       
                           [DICT_TITLE: tr("通话记录"),
                           DICT_SUB_TITLE: tr("记录最近的20条通话记录"),
                           DICT_IMAGE_PATH: "recent_call",],
                           
                           [DICT_TITLE: tr("拨号盘"),
                           DICT_SUB_TITLE: tr("输入号码呼叫联系人"),
                           DICT_IMAGE_PATH: "iphonekey",],
                    ]
        self.setViewUI()
        self.tableView.reloadData()
    }
    
    func setViewUI() {
        self.companyContact.setTopAndBottomImage(UIImage.init(named: "corporate"), withTitle: tr("企业通讯录"), for: .normal, andTintColor: UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0"), withTextFont: UIFont.systemFont(ofSize: 13.0), andImageTitleGap: 26.0)
        
        self.recentContact.setTopAndBottomImage(UIImage.init(named: "recent_call"), withTitle: tr("通话记录"), for: .normal, andTintColor: UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0"), withTextFont: UIFont.systemFont(ofSize: 13.0), andImageTitleGap: 26.0)
        self.localContact.setTopAndBottomImage(UIImage.init(named: "iphonekey"), withTitle: tr("拨号盘"), for: .normal, andTintColor: UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0"), withTextFont: UIFont.systemFont(ofSize: 13.0), andImageTitleGap: 26.0)
        
        self.showTopTipLabel.text = tr("暂无收藏的联系人，您可以查看:")
        
        
        // 查找图标
        //        let rightBarBtnItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchBarItemClick(sender:)))
        //        let addBarBtnItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addBarItemClick(sender:)))
        //        self.navigationItem.rightBarButtonItems = [addBarBtnItem , rightBarBtnItem]
        
    }

    // MARK: - 点击事件
    // MARK: 搜索
    @IBAction func searchBarItemClick(_ sender: UIBarButtonItem) {
        let companySearchViewVC = CompanySearchViewController()
        companySearchViewVC.hidesBottomBarWhenPushed = true
        companySearchViewVC.searchType = .localContact
        self.navigationController?.pushViewController(companySearchViewVC, animated: true)
    }
    
    // MARK: 添加
    @IBAction func addBarItemClick(_ sender: UIBarButtonItem) {
        /*
        let headerView =  ContactHeaderView.creatContactHeaderView()
        headerView.frame = CGRect(x: 0, y: 100, width: SCREEN_WIDTH, height: 150);
        self.view.addSubview(headerView)
        headerView.passValueBlock = { (num: Int) in
            print("num:\(num)")
        }
        */
        // 发起会议
        let sendMeeting = YCMenuAction.init(title: tr("发起会议"), image: nil) { [weak self] (sender) in
            guard let self = self else {return}
            CLLog("sendMeeting")
            
            // chenfan：断网后的样式
            if WelcomeViewController.checkNetworkWithNoNetworkAlert() { return }
            if SuspendTool.isMeeting() {
                SessionManager.showMeetingWarning()
                return
            }
            /*
            let creatMeetingVC = UIStoryboard.init(name: "CreateMeetingViewController", bundle: nil).instantiateViewController(withIdentifier: "CreateMeetingView") as! CreateMeetingViewController
            creatMeetingVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(creatMeetingVC, animated: true)*/
            //xiejc 2021-01-05 发起会议，2.0 和 3.0 区分
            if  ManagerService.call()?.isSMC3 == true {
                let storyboard = UIStoryboard.init(name: "CreatMeetingThreeVersionViewController", bundle: nil)
                let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreatMeetingThreeVersionViewController") as! CreatMeetingThreeVersionViewController
                creatMeetingVC.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(creatMeetingVC, animated: true)
            } else {
                let storyboard = UIStoryboard.init(name: "CreateMeetingViewController", bundle: nil)
                let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreateMeetingView") as! CreateMeetingViewController
                creatMeetingVC.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(creatMeetingVC, animated: true)
            }
        }
        // 添加联系人
        let addContact = YCMenuAction.init(title: tr("添加联系人"), image: nil) { [weak self] (sender) in
            guard let self = self else {return}
            CLLog("addContact")
            let addLocalContactVC =  AddLocalContactViewController.init()
            addLocalContactVC.operationType = .addContact//添加联系人
            addLocalContactVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addLocalContactVC, animated: true)
        }
        // 弹框
        let menu = YCMenuView.menu(with: [sendMeeting!, addContact! ], width: 150.0, relyonView: self.addBarItem)
        menu?.backgroundColor = UIColor.white
        menu?.textAlignment = .center
        menu?.separatorColor = UIColor.colorWithSystem(lightColor: COLOR_SEPARATOR_LINE, darkColor: COLOR_GAY)
        menu?.maxDisplayCount = 20
        menu?.offset = 0
        menu?.textColor = COLOR_DARK_GAY
        menu?.textFont = UIFont.systemFont(ofSize: 16.0)
        menu?.menuCellHeight = 50.0
        menu?.dismissOnselected = true
        menu?.dismissOnTouchOutside = true
        menu?.show()
    }

    // MARK: 企业通讯录
    @IBAction func clickCompanyContact(_ sender: UIButton) {
        let companyContactVC = CompanyContactViewController()
        companyContactVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(companyContactVC, animated: true)
    }
    
    // MARK: 拨号盘
    @IBAction func clickLocalContact(_ sender: UIButton) {
        print("拨号盘")
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        let CallKeyVC = CallKeyViewController()
        CallKeyVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(CallKeyVC, animated: true)
    }
    
    // MARK: 最近联系人
    @IBAction func clickRecentContact(_ sender: UIButton) {
        let recentContactVC = RecentContactViewController()
        recentContactVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(recentContactVC, animated: true)
    }

    // MARK: - UITableViewDelegate 代理方法的实现
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.iscellDataNull {
            return 1
        }
        
        if self.sectionNumber == 0{
            return 1
        }
        if self.sectionNumber == 1 {
            if self.firstCharactorArr.count == 0{
                return 1
            }
        }
        return self.firstCharactorArr.count + self.sectionNumber
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.iscellDataNull {
            return self.emptyDataSource.count
        }
        
        if self.sectionNumber == 0{
            return 3
        }
        if self.sectionNumber == 1 {
            if self.firstCharactorArr.count == 0{
                return self.nearlyContactArr.count
            }else{
                if section == 0{
                    return 0
                }else{
                   return (self.localContactDictionary.object(forKey: self.firstCharactorArr[section - self.sectionNumber]) as! NSArray).count + 1
                }
            }
        }else{
            if section == 0{
                return self.nearlyContactArr.count
            }
            if section == 1{
                return 0
            }
            return (self.localContactDictionary.object(forKey: self.firstCharactorArr[section - self.sectionNumber]) as! NSArray).count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.iscellDataNull {
            let menuCell = tableView.dequeueReusableCell(withIdentifier: TableImageTextNextCell.CELL_ID) as! TableImageTextNextCell
            let dataDict = self.emptyDataSource[indexPath.row]
            menuCell.showImageView.image = UIImage.init(named: dataDict[DICT_IMAGE_PATH]!)
            menuCell.showTitleLabel.text = dataDict[DICT_TITLE]
            menuCell.showSubTitleLabel.text = dataDict[DICT_SUB_TITLE]

            return menuCell
        }
        if self.sectionNumber == 1{
            if self.firstCharactorArr.count == 0{
                return getNearlyTableImageTextCell(indexPath: indexPath)
            }else{
                if indexPath.row > 0{
                    return getFavTableImageTextCell(indexPath: indexPath)
                }else{
                    return getTableTextCell(indexPath: indexPath)
                }
            }
        }else{
            if indexPath.section == 0{
                return getNearlyTableImageTextCell(indexPath: indexPath)
            }
            if indexPath.section > 1 && indexPath.row == 0 {
                return getTableTextCell(indexPath: indexPath)
            }
            return getFavTableImageTextCell(indexPath: indexPath)
        }
    }
    
    func getTableTextCell(indexPath: IndexPath) -> UITableViewCell {
        // 索引 or section title
        let indexAZCell = tableView.dequeueReusableCell(withIdentifier: TableTextCell.CELL_ID) as! TableTextCell
        // set text
        indexAZCell.showTitleLabel.text = self.firstCharactorArr[indexPath.section - self.sectionNumber]
         return indexAZCell
    }
    
    func getFavTableImageTextCell(indexPath: IndexPath) -> UITableViewCell {
        // 收藏联系人
        let cell = tableView.dequeueReusableCell(withIdentifier: TableImageTextCell.CELL_ID) as! TableImageTextCell
        
        let contactInfo = (localContactDictionary.object(forKey: firstCharactorArr[indexPath.section - self.sectionNumber]) as! NSArray)[indexPath.row - 1] as! LocalContactModel
        
        let nameStr = contactInfo.name!
//        let codeStr = contactInfo.fax!
        // should show number --changed at 2020.7.14 by lisa
//        let codeStr = contactInfo.number!
//        cell.showTitleLabel.text = nameStr + " " + codeStr
//        cell.showTitleLabel.attributedText = changeNameAndCodeTitleStyle(cellText: cell.showTitleLabel.text!, nameStr: nameStr, codeStr: codeStr)
        cell.showTitleLabel.text = nameStr
        cell.showSubTitleLabel.text = contactInfo.depart
        
        cell.showImageView.image = getUserIconWithAZ(name: nameStr)
        
        return cell
    }
    
    func getNearlyTableImageTextCell(indexPath: IndexPath) -> UITableViewCell {
        // 常用联系人
        let cell = tableView.dequeueReusableCell(withIdentifier: TableImageTextCell.CELL_ID) as! TableImageTextCell
        
        let userCallLogModel = self.nearlyContactArr[indexPath.row] as! UserCallLogModel
        
        let nameStr = userCallLogModel.userName!
//        let codeStr = userCallLogModel.number!
//        // title
//        cell.showTitleLabel.text = nameStr + " " + codeStr
//        cell.showTitleLabel.attributedText = changeNameAndCodeTitleStyle(cellText: cell.showTitleLabel.text!, nameStr: nameStr, codeStr: codeStr)
        cell.showTitleLabel.text = nameStr
        
        // subtitle
        cell.showSubTitleLabel.text = userCallLogModel.title
        
        cell.showImageView.image = getUserIconWithAZ(name: nameStr)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.iscellDataNull {
            if indexPath.row == 0 {
               // 企业通讯录
                self.clickCompanyContact(UIButton.init())
            } else if indexPath.row == 1 {
                // 最近联系人
                self.clickRecentContact(UIButton.init())
            } else if indexPath.row == 2 {
                // 拨号盘
                self.clickLocalContact(UIButton.init())
            }
            return
        }
        
        if self.sectionNumber == 1{
            if self.nearlyContactArr.count != 0{
                // 常用联系人
                let userCallLogModel = self.nearlyContactArr[indexPath.row] as! UserCallLogModel
                SessionManager.shared.showCallSelectView(name: userCallLogModel.userName, number: userCallLogModel.number, depart: "", vc: self)
                return
            }else{
                if indexPath.row == 0{
                    // 常用联系人
                    let totalRow = self.nearlyContactArr.count - 1
                    if totalRow >= indexPath.row {
                        let userCallLogModel = self.nearlyContactArr[indexPath.row] as! UserCallLogModel
                        SessionManager.shared.showCallSelectView(name: userCallLogModel.userName , number: userCallLogModel.number, depart: "", vc: self)
                    }
                   
                    return
                }
            }
        }
        if self.sectionNumber == 2{
            if indexPath.section == 0{
                // 常用联系人
                let userCallLogModel = self.nearlyContactArr[indexPath.row] as! UserCallLogModel
                SessionManager.shared.showCallSelectView(name: userCallLogModel.userName, number: userCallLogModel.number, depart: "", vc: self)
                return
            }
            if indexPath.section == 1{
                return
            }
            if indexPath.row == 0{
                return
            }
        }
        let contactInfo = (localContactDictionary.object(forKey: firstCharactorArr[indexPath.section - self.sectionNumber]) as! NSArray)[indexPath.row - 1] as! LocalContactModel
        
        let cell = tableView.cellForRow(at: indexPath) as! TableImageTextCell
        let contactDetailViewVC = ContactDetailViewController()
        contactDetailViewVC.localContactInfo = contactInfo
        contactDetailViewVC.contactDetailVC = .localContact
        contactDetailViewVC.iconImage = cell.showImageView.image
        contactDetailViewVC.fromVc = .contactVC
        contactDetailViewVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(contactDetailViewVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.iscellDataNull {
            return TableImageTextNextCell.CELL_HEIGHT
        }
        
        if self.sectionNumber == 1{
            if self.firstCharactorArr.count == 0{
                return TableImageTextCell.CELL_HEIGHT
            }else{
                if indexPath.row > 0{
                    return TableImageTextCell.CELL_HEIGHT
                }else{
                    return TableTextCell.CELL_HEIGHT
                }
            }
        }else{
            if indexPath.section == 0{
                return TableImageTextCell.CELL_HEIGHT
            }
            if indexPath.section > 1 && indexPath.row == 0 {
                return TableTextCell.CELL_HEIGHT
            }
            return TableImageTextCell.CELL_HEIGHT
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.iscellDataNull {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderFooterTextCell.CELL_ID) as! TableHeaderFooterTextCell
        if self.sectionNumber == 0{
            headerView.label.text = tr("暂无收藏的联系人，您可以查看:")
            return headerView
        }
        if self.sectionNumber == 1{
            if self.firstCharactorArr.count == 0{
                if section == 0 {
                    headerView.label.text = tr("常用联系人")
                    return headerView
                }else{
                     return UIView.init()
                }
            }else{
                if section == 0 {
                    headerView.label.text = tr("本地收藏联系人")
                    return headerView
                }else{
                    return UIView.init()
                }
            }
        }else{
            if section == 0 {
                headerView.label.text = tr("常用联系人")
                return headerView
            } else if section == 1 {
                headerView.label.text = tr("本地收藏联系人")
                return headerView
            }
            return UIView.init()
        }
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.iscellDataNull {
            return 0.01
        }
        
        if section < self.sectionNumber{
            return TableHeaderFooterTextCell.CELL_HEIGHT
        }
        return 0.01
    }
    
    // MARK: footer Title
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    // MARK: footer View
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: -
extension ContactViewController {

    // MARK: check contact authorized
    func checkContactAuthorized() {
        // 验证授权
        // 1. 判断授权
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        // 2. 如果授权没有请求,需要请求
        if status != .authorized {
            // 请求授权
            CNContactStore().requestAccess(for: .contacts) { (granted, error) in
                if !granted {
                    CLLog("授权失败")
                    let alertTitleVC = TextTitleSingleBtnViewController()
                    alertTitleVC.modalTransitionStyle = .crossDissolve
                    alertTitleVC.modalPresentationStyle = .overFullScreen
                    alertTitleVC.showTitle = tr("获取通讯录权限失败")
                    
                    self.present(alertTitleVC, animated: true, completion: nil)
                } else {
                    CLLog("授权成功")
                    self.getContactData()
                }
            }
        } else {
            self.getContactData()
        }
    }
    
    // MARK: get contact data
    func getContactData() {
        // 获取所有联系人
        // 1.创建联系人仓库对象
        let contactStore = CNContactStore()
        
        let keys = [CNContactNamePrefixKey,
                    CNContactGivenNameKey,
                    CNContactMiddleNameKey,
                    CNContactFamilyNameKey,
                    CNContactPreviousFamilyNameKey,
                    CNContactNameSuffixKey,
                    CNContactNicknameKey,
                    CNContactOrganizationNameKey,
                    CNContactDepartmentNameKey,
                    CNContactJobTitleKey,
                    CNContactPhoneticGivenNameKey,
                    CNContactPhoneticMiddleNameKey,
                    CNContactPhoneticFamilyNameKey,
                    CNContactBirthdayKey,
                    CNContactNonGregorianBirthdayKey,
//                    CNContactNoteKey,
                    CNContactImageDataKey,
                    CNContactThumbnailImageDataKey,
                    CNContactImageDataAvailableKey,
                    CNContactTypeKey,
                    CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey,
                    CNContactPostalAddressesKey,
                    CNContactDatesKey,
                    CNContactUrlAddressesKey,
                    CNContactRelationsKey,
                    CNContactSocialProfilesKey,
                    CNContactInstantMessageAddressesKey]
        
        
        let fetch = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            var contactArray: [CNContact] = []
            try contactStore.enumerateContacts(with: fetch, usingBlock: { (contact, stop) in
                contactArray.append(contact)
            })
            
            self.vcardPath = NSString.generateVCard21String(with: contactArray)
            MBProgressHUD.hide()
            if self.vcardPath != nil {
                MBProgressHUD.showBottom(tr("通讯录编码完成"), icon: nil, view: nil)
                self.showSystemMailShare()
            }
        } catch let error as NSError {
            MBProgressHUD.hide()
            print(error)
        }
    }
    
    // 调用系统邮件分享
    func showSystemMailShare() {
//        let mailSender = MFMailComposeViewController.init()
//        mailSender.mailComposeDelegate = self
//        mailSender.setSubject("通讯录导出")
//        let data = NSData.init(contentsOfFile: self.vcardPath!)
//
//        mailSender.addAttachmentData(data! as Data, mimeType: "text/plain", fileName: "contact")
//        self.present(mailSender, animated: true, completion: nil)
        
        let data = NSData.init(contentsOfFile: self.vcardPath!)
        let activityController = UIActivityViewController.init(activityItems: [data as Any, URL.init(string: self.vcardPath!) as Any], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            CLLog("attachmentData -- cnacel")
        case .saved:
            CLLog("attachmentData -- saved")
        case .sent:
            CLLog("attachmentData -- sent")
            MBProgressHUD.showBottom(tr("导出成功"), icon: nil, view: self.view)
        case .failed:
            CLLog("attachmentData -- failed")
        @unknown default:
            CLLog("attachmentData -- unknown default")
        }
    }
}
