//
// CompanySearchViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//。7891011121314



import UIKit

enum SearchVCType {
    case localContact//本地搜索
    case companyContact//企业通讯录搜索
    case favouriteContact
}

class CompanySearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TUPContactServiceDelegate, PopTitleSubTitleViewDelegate {
    // 数据源
    var dataSource: NSArray?
    
    var searchType: SearchVCType?
    
    fileprivate var searchedDataSource: NSMutableArray?
    
    fileprivate var searchTextField: UITextField?
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var contactLdapMutableList = NSMutableArray.init()
    
    fileprivate var contactLocalMutableList = NSMutableArray.init()
    
    fileprivate var favouriteContactMutableList = NSMutableArray.init()
    
    fileprivate var sNameArr = NSMutableArray.init()
    
    fileprivate var contactMutableDict = NSMutableDictionary.init()
    
    fileprivate var nowSearchString: String?
    
    fileprivate var search = SearchParam.init()
    
    fileprivate var cookieLen = 0
    
    fileprivate var pageCookie : NSData? = nil
    fileprivate var isFirst = true
    
    fileprivate var footer:MJRefreshAutoNormalFooter?
    
    private var isActualSearch = true
    // 是否点击搜索 点击了不走模糊搜索
    private var isReturnSearch = false
    
    private var searchKeyWord: String = ""
    
    private var footerText = ""
    
    var isShowCompanySearchBtn:Bool = false//本地企业搜索按钮是否显示
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.clear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchTextField?.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        self.title = ""
        self.setViewUI()
        
        ManagerService.contactService()?.delegate = self
        
        //利用通知查询企业通讯录
        //        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextChange(notification:)), name: NSNotification.Name(UITextField.textDidChangeNotification.rawValue), object: nil)
        
        //企业通讯录(先不做判断......先加入上来加载)
//        if searchType == SearchVCType.companyContact {
            // 设置上拉加载刷新
//            ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: nil, moreData: self.moreData)
//            let AnimtionView : ESRefreshFooterAnimator = self.tableView.es_footer!.animator as! ESRefreshFooterAnimator
//            AnimtionView.loadingDescription = ""
//            AnimtionView.noMoreDataDescription = ""
        
        //MJ刷新控件
        footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(moreData))
        footer?.setTitle(tr("--没有更多了--"), for: MJRefreshState.noMoreData)
        
        self.tableView.mj_footer = footer
        
      

        
        
//        }
    }
    
    func setViewUI() {
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: TableImageTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageTextCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableImageSingleTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageSingleTextCell.CELL_ID)
        self.tableView.separatorStyle = .none
        
        // searchTextField
        self.searchTextField = UITextField(frame: CGRect(x: 44, y: 0, width: SCREEN_WIDTH - 60, height: 44))
        
        let lineView = UIImageView(frame:CGRect(x: 0, y: 44-1, width: SCREEN_WIDTH - 60, height: 1));
        lineView.backgroundColor = UIColor(hexString: "0D94FF")
        self.searchTextField!.addSubview(lineView)
        
        self.navigationItem.titleView = self.searchTextField
        self.searchTextField?.delegate = self
        searchTextField?.tintColor = UIColor(hexString: "0D94FF")
        searchTextField?.clearButtonMode = .whileEditing
        self.searchTextField?.returnKeyType = .search
        //搜索企业通讯录
        if searchType == SearchVCType.companyContact{
            self.searchTextField?.placeholder = tr("搜索企业通讯录")
        }else{
            self.searchTextField?.placeholder = tr("搜索本地收藏联系人")
        }
        self.searchedDataSource = NSMutableArray.init()
    }
    
    // MARK: 刷新
    @objc func moreData() {
        
        if self.cookieLen == 0 {
            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        self.isFirst = false
        isActualSearch = false
        initCompanyContactData()
        // 停止刷新
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//        }
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.searchTextField?.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    //搜索本地通讯录
    private func searchLocalContacts(_ nowString: String) {
        self.contactLocalMutableList.removeAllObjects()
        self.tableView.reloadData()
        self.searchKeyWord = nowString
        let localContactModel = LocalContactModel.init()
        localContactModel.searchWord = nowString
        LocalContactBusiness.shareInstance.selectLocalContact(localContactModel: localContactModel) { (arr) in
            let sortList = arr.sorted { (model1, model2) -> Bool in
                if let name1 = model1.name, let name2 = model2.name {
                    return NSString(string: name1).compare(name2, options: NSString.CompareOptions.numeric) == .orderedAscending
                } else {
                    return model1.name ?? "" < model2.name ?? ""
                }
            }
            self.contactLocalMutableList.addObjects(from: sortList)
            MBProgressHUD.hide(for: self.view)
            self.tableView.reloadData()
        }
    }
    
    func initCompanyContactData() {
        if isFirst {
            self.cookieLen = 0
            self.pageCookie = nil
        }
        //search.curentBaseDn = "ou=VC,dc=Huawei,dc=com"
        
        //        if NSString.matchSingleCharAllStr(search.keywords, matchChar: "*") {
        //             search.curentBaseDn = ""
        //             search.sortAttribute = ""
        //        } else {
        //            search.sortAttribute = "name_"
        //        }
        search.curentBaseDn = ""
        search.sortAttribute = ""
//        footerText = tr("正在加载") + "..."
        search.searchSingleLevel = 0
        search.pageSize = PAGE_COUNT_50PER
        search.cookieLength = Int32(self.cookieLen)
        search.pageCookie = self.pageCookie as Data?
        //data数据搜索
        let isSuccess = ManagerService.contactService()?.searchLdapContact(with: search)
        if !isSuccess! {
            MBProgressHUD.hide(for: view)
            //去除加载框
//            MBProgressHUD.showMessage("", to: view)
            MBProgressHUD.showBottom(tr("查询失败"), icon: nil, view: self.view)
        }
    }
    //data搜索数据回调
    func contactEventCallback(_ contactEvent: TUP_CONTACT_EVENT_TYPE, result resultDictionary: [AnyHashable : Any]!) {
        MBProgressHUD.hide(for: view)
        tableView.mj_footer?.endRefreshing()
        guard (resultDictionary != nil) else {
            CLLog("resultDictionary is equal nil")
            return
        }
        
        // 请求是否成功
        let res = resultDictionary[TUP_CONTACT_EVENT_RESULT_KEY] as! Bool
        if !res {
            // 修改问题单 DTS2020121506395
            MBProgressHUD.animate(withDuration: 1.0) {
                MBProgressHUD.showBottom(tr("查询失败"), icon: nil, view: self.view)
            }
            CLLog("Search contact failed!")
            return
        }
        
        switch contactEvent {
        case CONTACT_E_SEARCH_LDAP_CONTACT_RESULT:
            //判断是否为实时搜索
            if isActualSearch && self.searchType == SearchVCType.companyContact {
                self.contactLdapMutableList.removeAllObjects()
                self.sNameArr.removeAllObjects()
                self.contactMutableDict.removeAllObjects()
            }
            
            var contactList = resultDictionary[TUP_CONTACT_KEY] as! [LdapContactInfo];
            print("contactList count =",contactList.count)
            if contactList.count == 0 {
                CLLog("contactList Empty")
            }
            
            self.cookieLen = resultDictionary[COOKIE_LEN] as! Int
            self.pageCookie = resultDictionary[PAGE_COOKIE] as? NSData
            
            if self.cookieLen == 0 {
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
            if search.keywords == nil {
                // 当没有搜索关键词时请求到的数据上企业联系人的数据 需要回传回去
                NotificationCenter.default.post(name: NSNotification.Name("RequestCompanydata"), object: nil, userInfo: resultDictionary)
                contactList.removeAll()
                return
            }
            // 去除名字或者终端号为空的用户
            changeData(contactList: contactList)
            
            break;
        default:
            break;
        }
        
    }
    
    func changeData(contactList:[LdapContactInfo]) {
        for contact in contactList {
            if contact.name == nil || contact.name.count == 0{
                contact.name = "666"
                continue
            }
            let firstChar = LocalContactModel.init().getFirstCharactor(name: contact.name)
            if (contactMutableDict.object(forKey: firstChar) != nil){
                let ContArr:NSMutableArray = contactMutableDict.object(forKey: firstChar) as! NSMutableArray
                ContArr.add(contact)
                ContArr.sort { (Info1, Info2) -> ComparisonResult in
                    let info1Str:String = (Info1 as! LdapContactInfo).name.subString(to: 1)
                    let info2Str:String = (Info2 as! LdapContactInfo).name.subString(to: 1)
                    let info1ASCIINumber:UInt32 = info1Str.unicodeScalars[info1Str.unicodeScalars.startIndex].value
                    let info2ASCIINumber:UInt32 = info2Str.unicodeScalars[info2Str.unicodeScalars.startIndex].value
                    if info1ASCIINumber > info2ASCIINumber {
                        return .orderedDescending
                    }else{
                        return .orderedAscending
                    }
                }
            }else{
                let tempArr = NSMutableArray.init()
                tempArr.add(contact)
                contactMutableDict.setValue(tempArr, forKey: firstChar)
            }
        }
        sNameArr.removeAllObjects()
        sNameArr.addObjects(from: contactMutableDict.allKeys)
        sNameArr.sort {(s1, s2) -> ComparisonResult in
            if s1 as! String > s2 as! String{
                return .orderedDescending
            }else{
                return .orderedAscending
            }
        }
        self.contactLdapMutableList.removeAllObjects()
        for value in sNameArr {
            let valueStr:String = value as! String
            let companyArr:[LdapContactInfo] = contactMutableDict[valueStr] as! [LdapContactInfo]
            self.contactLdapMutableList.addObjects(from: companyArr)
        }
        self.tableView.reloadData()
    }
    
    func judgeNumber(str: String) -> Bool{
        let reg = "^[1-9]d*$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        if pre.evaluate(with: str) {
            return true
        }else{
            return false
        }
    }
    
    func getFirstCharactor(name:String) -> String {
        let str = CFStringCreateMutableCopy(nil,0,name as CFString)
        CFStringTransform(str, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)
        return (str as! NSString).substring(to: 1).uppercased()
    }
    
    // MARK: - PopTitleSubTitleViewDelegate
    func popTitleSubTitleViewDidLoad(viewVC: PopTitleSubTitleViewController) {
        
    }
    
    // MARK: popTitleSubTitleViewCellClick
    func popTitleSubTitleViewCellClick(viewVC: PopTitleSubTitleViewController, dataDict: [String : String]?) {
        viewVC.dismiss(animated: true, completion: nil)
        if dataDict != nil {
            let isNext = dataDict![DICT_IS_NEXT]
            if isNext != nil && isNext! == "1" {
                let callNum = dataDict![DICT_SUB_TITLE]
                if NSString.checkPhoneNumInput(withPhoneNum: callNum!) {
                    callPhone(dataDict![DICT_SUB_TITLE]!)
                } else {
                    // 拨打终端号
                    SessionManager.shared.showCallSelectView(name: viewVC.showTitle, number: callNum, depart: "", vc: self)
                }
            }
        }
    }
    
    // 设置样式类型
    func changeNameAndCodeTitleStyleSearchColor(cellText:String, nameStr:String, codeStr:String, searchText: String) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString.init(string: cellText)
        attributeString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0), range: NSRange.init(location: nameStr.count + 1, length: codeStr.count))
        attributeString.addAttribute(.foregroundColor, value: COLOR_GAY, range: NSRange.init(location: nameStr.count + 1, length: codeStr.count))
        if searchText.count > 0 {
            do {
                // 数字正则表达式
                let regexExpression = try NSRegularExpression(pattern: searchText, options: NSRegularExpression.Options())
                let result = regexExpression.matches(
                    in: cellText,
                    options: NSRegularExpression.MatchingOptions(),
                    range: NSMakeRange(0, cellText.count)
                )
                for item in result {
                    attributeString.setAttributes(
                        [.foregroundColor : COLOR_HIGHT_LIGHT_SYSTEM],
                        range: item.range
                    )
                }
            } catch {
                print("Failed with error: \(error)")
            }
        }
        return attributeString
    }
    
    private func isChineseWithStr(Str:String) -> Bool {
        for (_, value) in Str.enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - UITableViewDelegate
extension CompanySearchViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchType == SearchVCType.companyContact {
            //当显示 ""暂无搜索结果"时 底部的"--没有更多了--"不显示
            footer?.isHidden = self.contactLdapMutableList.count != 0 ? false : true
            return self.contactLdapMutableList.count
        }
        if self.searchType == SearchVCType.localContact {
            
            footer?.isHidden = self.contactLocalMutableList.count != 0 ? false : true
            return self.contactLocalMutableList.count
        }
        if self.searchType == SearchVCType.favouriteContact {
            footer?.isHidden = self.favouriteContactMutableList.count != 0 ? false : true
            return self.favouriteContactMutableList.count
        }
        
        footer?.isHidden = self.searchedDataSource!.count != 0 ? false : true
        return self.searchedDataSource!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.searchType == SearchVCType.localContact {
            return TableImageSingleTextCell.CELL_HEIGHT
        }
        return TableImageTextCell.CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchType == SearchVCType.localContact {
            if self.contactLocalMutableList.count != 0 {
                return 30.0
            }
        }else if searchType == SearchVCType.companyContact {
            if self.contactLdapMutableList.count != 0 {
                return 30.0
            }
            return 0.01
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if searchType == SearchVCType.localContact {
            if self.contactLocalMutableList.count != 0 || nowSearchString != nil {
                return 30
            }
        }else if searchType == SearchVCType.companyContact {
            if search.keywords != nil && self.contactLdapMutableList.count == 0 {
                return SCREEN_HEIGHT/2.0
            }else if search.keywords != nil {
                return 0.01
            }
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchType == SearchVCType.localContact { // 本地查询
            if self.contactLocalMutableList.count != 0 {
                let backView  = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 30))
                backView.backgroundColor = UIColor(hexString: "FAFAFA")
                let Label = UILabel.init(frame: CGRect(x: 16, y: 0, width: SCREEN_WIDTH-16, height: 30))
                Label.text = tr("本地收藏联系人")
                Label.font = UIFont.systemFont(ofSize: 14)
                Label.textColor = UIColor(hexString: "999999")
                backView.addSubview(Label)
                return backView
            }
        }else if searchType == SearchVCType.companyContact {
            let backView  = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 30))
            backView.backgroundColor = UIColor(hexString: "FAFAFA")
            let Label = UILabel.init(frame: CGRect(x: 16, y: 0, width: SCREEN_WIDTH-16, height: 30))
            Label.text = tr("企业通讯录")
            Label.font = UIFont.systemFont(ofSize: 14)
            Label.textColor = UIColor(hexString: "999999")
            backView.addSubview(Label)
            
            backView.isHidden = self.contactLdapMutableList.count != 0 ? false:true
            
            return backView
        }
        return UIView.init()
    }
    
    //底部提示
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if searchType == SearchVCType.localContact { // 本地查询
            if self.contactLocalMutableList.count != 0 || nowSearchString != nil {
//                let Label = UILabel.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
//                Label.text = "--没有更多了--"
//                Label.textAlignment = .center
//                Label.font = UIFont.systemFont(ofSize: 14)
//                Label.textColor = UIColor(hexString: "cccccc")
//                return Label
//
                let btn = UIButton.init(frame: CGRect(x: 0, y: 5, width: SCREEN_WIDTH, height: 30))
                btn.setTitle(tr("在企业通讯录中搜索"), for: .normal)
                btn.setTitleColor(UIColor(hexString: "0D94FF"), for: .normal)
                btn.addTarget(self, action: #selector(searchDataFromCompany), for: .touchUpInside)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                btn.titleLabel?.textAlignment = .center
                
                btn.isHidden = LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.offline
                
                return btn
            }
        }else if searchType == SearchVCType.companyContact {
            if search.keywords != nil && self.contactLdapMutableList.count == 0 {
                
                let View = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2.0))
                let Label = UILabel.init(frame: CGRect(x: 0, y: SCREEN_HEIGHT/2.0-100, width: SCREEN_WIDTH, height: 100))
                Label.text = tr("暂无搜索结果")
                Label.textAlignment = .center
                Label.numberOfLines = 1
                Label.font = UIFont.systemFont(ofSize: 16)
                Label.textColor = UIColor(hexString: "666666")
                View.addSubview(Label)
                return View
                
            }else if search.keywords != nil {
                let Label = UILabel.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.01))
//                Label.text = footerText
//                Label.textAlignment = .center
//                Label.font = UIFont.systemFont(ofSize: 14)
//                if footerText == "正在加载..." {
//                    Label.textColor = UIColor(hexString: "666666")
//                }else{
//                    Label.textColor = UIColor(hexString: "cccccc")
//                }
                return Label
            }
        }
        return UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.01))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.searchType == SearchVCType.localContact {
            let singleCell = tableView.dequeueReusableCell(withIdentifier: TableImageSingleTextCell.CELL_ID) as! TableImageSingleTextCell
            let contact = self.contactLocalMutableList[indexPath.row] as! LocalContactModel
            // set title
            singleCell.showTitleLabel.text = contact.name
            singleCell.showTitleLabel.attributedText = changeRegxSpecialStringStyle(goalStr: contact.name ?? "", color: COLOR_HIGHT_LIGHT_SYSTEM, font: singleCell.showTitleLabel.font, regx: self.searchKeyWord )
            singleCell.showImageView.image = getUserIconWithAZ(name: contact.name!)
            
            return singleCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TableImageTextCell.CELL_ID) as! TableImageTextCell
        
        var contactInfo: LdapContactInfo?
        
        if searchType == SearchVCType.companyContact {
            
            if contactLdapMutableList.count > 0 && contactLdapMutableList.count > indexPath.row {
                contactInfo = (contactLdapMutableList[indexPath.row] as! LdapContactInfo)
            }
            
        }else{
            
            contactInfo = (favouriteContactMutableList[indexPath.row] as! LdapContactInfo)
        }
        
        let nameStr = contactInfo?.name
        let codeStr = ""
        cell.showTitleLabel.text = "\(nameStr ?? "") \(codeStr)"
        if self.searchKeyWord != " " && self.searchKeyWord != "*" {
            cell.showTitleLabel.attributedText = self.changeNameAndCodeTitleStyleSearchColor(cellText: cell.showTitleLabel.text!, nameStr: nameStr ?? "", codeStr: codeStr ?? "", searchText: self.searchKeyWord)
        }
        //        cell.showSubTitleLabel.text = LdapContactInfo.getDeptName(contactInfo?.corpName)
        cell.showSubTitleLabel.text = contactInfo?.deptName
        
        cell.showImageView.image = getUserIconWithAZ(name: nameStr ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //本地搜索
        if self.searchType == SearchVCType.localContact {
            if indexPath.row > contactLocalMutableList.count {
                return
            }
            self.searchTextField?.resignFirstResponder()
            let contact = contactLocalMutableList[indexPath.row] as! LocalContactModel
            //            let popTitleVC = PopTitleSubTitleViewController.init(nibName: "PopTitleSubTitleViewController", bundle: nil)
            //            popTitleVC.modalTransitionStyle = .crossDissolve
            //            popTitleVC.modalPresentationStyle = .overFullScreen
            //
            //            popTitleVC.customDelegate = self
            //            popTitleVC.showTitle = contact.name
            //            popTitleVC.dataSource = []
            //            if contact.number != nil && contact.number!.count > 0 {
            //                popTitleVC.dataSource?.append([DICT_TITLE: "终端", DICT_SUB_TITLE: contact.number!, DICT_IS_NEXT: "1"])
            //            }
            //            if contact.mobile != nil && contact.mobile!.count > 0 {
            //                popTitleVC.dataSource?.append([DICT_TITLE: "手机", DICT_SUB_TITLE: contact.mobile!, DICT_IS_NEXT: "1"])
            //            }
            //            if contact.campany != nil && contact.campany!.count > 0 {
            //                popTitleVC.dataSource?.append([DICT_TITLE: "公司", DICT_SUB_TITLE: contact.campany!])
            //            }
            //            if contact.depart != nil && contact.depart!.count > 0 {
            //                popTitleVC.dataSource?.append([DICT_TITLE: "职务", DICT_SUB_TITLE: contact.depart!])
            //            }
            //            if contact.eMail != nil && contact.eMail!.count > 0 {
            //                popTitleVC.dataSource?.append([DICT_TITLE: "邮箱", DICT_SUB_TITLE: contact.eMail!])
            //            }
            //            if contact.address != nil && contact.address!.count > 0 {
            //                popTitleVC.dataSource?.append([DICT_TITLE: "地址", DICT_SUB_TITLE: contact.address!])
            //            }
            //            if contact.remark != nil && contact.remark!.count > 0 {
            //                popTitleVC.dataSource?.append([DICT_TITLE: "备注", DICT_SUB_TITLE: contact.remark!])
            //            }
            //
            //            popTitleVC.dataSource?.append([DICT_TITLE: "取消", DICT_SUB_TITLE: ""])
            //
            //            self.present(popTitleVC, animated: true, completion: nil)
            
            let contactDetailViewVC = ContactDetailViewController()
            contactDetailViewVC.localContactInfo = contact
            contactDetailViewVC.contactDetailVC = .localContact
            contactDetailViewVC.fromVc = .contactVC
            //获得cell的image
            let cell = tableView.cellForRow(at: indexPath) as! TableImageSingleTextCell
            contactDetailViewVC.iconImage = cell.showImageView.image
            
            contactDetailViewVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(contactDetailViewVC, animated: true)
            return
        }
        if indexPath.row > contactLdapMutableList.count {
            return
        }
        let contactDetailViewVC = ContactDetailViewController()
        contactDetailViewVC.fromVc = .searchVC
        
        //MARK ==== bug崩溃点 == 当点击搜索后立即点cell出现崩溃, (1.尝试方法: 点击搜索时,立马清空数据, 刷新cell)
        contactDetailViewVC.ldapContactInfo = (searchType == SearchVCType.companyContact ? contactLdapMutableList[indexPath.row] as! LdapContactInfo : favouriteContactMutableList[indexPath.row] as! LdapContactInfo)
        contactDetailViewVC.hidesBottomBarWhenPushed = true
        switch searchType {
        case .companyContact:
            contactDetailViewVC.contactDetailVC = .companyContact
            break;
        case .localContact:
            contactDetailViewVC.contactDetailVC = .localContact
            break;
        default:
            break;
        }
        //获得cell的image
        let cell = tableView .cellForRow(at: indexPath) as! TableImageTextCell
        contactDetailViewVC.iconImage = cell.showImageView.image
        self.navigationController?.pushViewController(contactDetailViewVC, animated: true)
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchTextField?.endEditing(true)
    }
    
}


extension CompanySearchViewController {
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isActualSearch = true
        isReturnSearch = false
        let textString =  textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        nowSearchString = nowString
        if nowString != "" && nowString.count >= WORDCOUNT_USERNAME {
            textField.text = (nowString as NSString).substring(to: WORDCOUNT_USERNAME)
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textString = textField.text! as NSString
        //let nowString = textString.replacingCharacters(in: range, with: string)
        if textString == "" {
            MBProgressHUD.show(tr("请输入关键词搜索"), icon: nil, view: self.view)
            return true
        }
        
        //点击搜索按钮后键盘退出, 防止重复点击造成的一直转圈圈
//        self.view.endEditing(true)
        self.searchTextField?.endEditing(true)
        
        let nowString = textString as String
        nowSearchString = nowString
        if nowString != "" && self.searchType == SearchVCType.localContact {
            //搜索本地
            MBProgressHUD.showMessage("", to: view)
            searchLocalContacts(nowString)
        }
        if nowString != "" && self.searchType == SearchVCType.companyContact {
            MBProgressHUD.showMessage("", to: view)
            //企业通讯录搜索
            self.cookieLen = 0
            //MBProgressHUD.showMessage("")
            self.isReturnSearch = true // 点击了搜索
            searchCompanyContacts(nowString)
        }
        if nowString == ""  {
            self.tableView.reloadData()
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textFieldTextChange()
    }
    
    @objc func textFieldTextChange() {
        let nowString = self.searchTextField?.text
        if self.searchTextField?.markedTextRange == nil {
            //如果是企业查询实时查询
            if nowString != "" && self.searchType == SearchVCType.companyContact {
                self.cookieLen = 0
                self.pageCookie = nil
                //延时一分钟
                self.perform(#selector(SearchTextfield(object:)), with: nowString, afterDelay: 1.0)
            }
            
            //本地通讯录也实时查询 -- changed at 2020.7.15 by lisa
            if nowString != "" && self.searchType == SearchVCType.localContact {
                searchLocalContacts(nowString ?? "")
            }
        }
    }
    
    @objc func SearchTextfield(object:String) {
        if self.searchTextField?.text != object || isReturnSearch == true {
            return
        }
        //搜索企业通讯录
        searchCompanyContacts(self.searchTextField?.text ?? "")
    }
    
    //搜索企业通讯录
    private func searchCompanyContacts(_ nowString: String) {
        self.searchKeyWord = nowString
        footerText = ""
        self.contactLdapMutableList.removeAllObjects()
        //        self.tableView.reloadData()
        if (nowString == "*") || (nowString == " ") {
            search.keywords = "*"
        }else{
            search.keywords = nowString
        }
        self.isFirst = true
        initCompanyContactData()
    }
    
    //从企业通讯录中搜索
    @objc func searchDataFromCompany(){
        //搜索企业通讯录
        searchType = SearchVCType.companyContact
        searchCompanyContacts(self.searchTextField?.text ?? "")
    }
    
}
