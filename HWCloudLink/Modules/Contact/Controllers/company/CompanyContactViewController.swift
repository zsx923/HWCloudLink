//
// CompanyContactViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

//protocol CompanyContactViewDelegate: NSObjectProtocol {
//    func companyContactViewSelectedData(viewVC: CompanyContactViewController, sureSelectedData: [LdapContactInfo])
//}

class CompanyContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,TUPContactServiceDelegate {

//    // 是否选中
//    var isSlectStatus: Bool?
//    weak var customDelegate: CompanyContactViewDelegate?
    @IBOutlet weak var tableView: UITableView!
    // [联系人]
    fileprivate var contactMutableList = NSMutableArray.init()
    // [标签字母]
    fileprivate var sNameArr = NSMutableArray.init()
    // 标签字母 : [联系人]
    fileprivate var contactMutableDict = NSMutableDictionary.init()
    // 0 标识首页查询；其他情况，标识 page_cookie 的长度
    fileprivate var cookieLen = 0
    // 非文本，上次分页查询Data由服务器返回
    fileprivate var pageCookie : NSData? = nil
    // 搜索参数
    fileprivate var search = SearchParam.init()
    var iconImage:UIImage?

    open var isLoadData = true
    private var pageNum: Int = 1
    private var currentPage: Int = 0
    
    let header = MJRefreshNormalHeader()
    
    fileprivate var footer:MJRefreshBackNormalFooter?
    
//    AutoNormalFooter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.clear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tr("企业通讯录")

        //数据代理方法
        ManagerService.contactService()?.delegate = self
        self.setViewUI()
//        // 解决该页面还没请求到数据就跳转企业搜索页面，代理只走一次，本页面没有数据
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshCompanyData), name: NSNotification.Name("RequestCompanydata"), object: nil)
    }
    
    // MARK: - 设置UI相关
    func setViewUI() {
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        // 搜索图标
        let rightBarBtnItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchBarItemClick(sender:)))
        rightBarBtnItem.tintColor = UIColor.init(hexString: "999999")
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        // tableView相关
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: TableImageTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageTextCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTextCell.CELL_ID)
        self.tableView.separatorStyle = .none
        // MJ刷新上拉加载

//        let footer = MJRefreshBackFooter.init(refreshingTarget: self, refreshingAction: #selector(addNewInfo))
//        tableView.mj_footer = footer
        
        footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(addNewInfo))
        footer?.setTitle(tr("上拉可以加载更多"), for: .idle)
        footer?.setTitle(tr("松开立即加载更多"), for: .pulling)
        footer?.setTitle(tr("正在加载"), for: .refreshing)
        footer?.setTitle(tr("--没有更多了--"), for: MJRefreshState.noMoreData)
        self.tableView.mj_footer = footer

        // chenfan：断网后的样式
        if !WelcomeViewController.checkNetworkWithNoNetworkAlert() {
            CLLog("菊花旋转")
            //加载圈
            //问题单号DTS2020121504113
            MBProgressHUD.showMessage("", to: view)
            //请求数据
            self.moreData()
        }
    }
    
    //MARK: -  加载方法
    @objc func addNewInfo (){
        self.initData()
    }
    // MARK: 刷新
    private func moreData() {
        if isLoadData {
            initData()
        }
        
        if self.cookieLen == 0 {
            tableView.mj_footer?.endRefreshingWithNoMoreData()
        }
        
        // if currentPage != pageNum, self.contactMutableList.count % Int(PAGE_COUNT_50PER) == 0 {
        //     tableView.es_footer?.noticeNoMoreData()
        //     tableView.es_footer?.noMoreData = true
        // }
        //
        // 停止刷新
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        //     self.tableView.es_stopLoadingMore()
        // }
    }
    
    //MARK: - 初始化 请求的参数
    func initData() {
        search.keywords = "*"
        // 当前分组
        search.curentBaseDn = ""
        // 排序属性
        search.sortAttribute = ""
        // 默认搜索所有分组层级下的地址本
        search.searchSingleLevel = 0
        // 每页联系人条数 50
        search.pageSize = PAGE_COUNT_50PER
        // 若分页 0标识首页查询  其他情况 标识pcPageCookie长度
        search.cookieLength = Int32(self.cookieLen)
        // 非文本，上次分页查询由服务器返回
        search.pageCookie = self.pageCookie as Data?
        let isSuccess = ManagerService.contactService()?.searchLdapContact(with: search)
        if !isSuccess! {
            //问题单号DTS2020122403408
            MBProgressHUD.hide(for: self.view)
            MBProgressHUD.showBottom(tr("查询失败"), icon: nil, view: self.view)
            //结束下拉加载
            tableView.mj_footer?.endRefreshing()
            CLLog("=====SDK问题查询失败")
        }
    }

    //MARK: - 请求数据 代理方法 TUPContactServiceDelegate
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
            MBProgressHUD.animate(withDuration: 2.0) {
                MBProgressHUD.showBottom(tr("查询失败"), icon: nil, view: self.view)
            }
            //endRefreshing 和endRefreshingWithNoMoreData方法不能同时使用, endrefreshing方法还存在下拉刷新
            tableView.mj_footer?.endRefreshing()
            CLLog("Search ldap contact failed!")
            return
        }
        switch contactEvent {
        // 联系人搜索结果
        case CONTACT_E_SEARCH_CONTACT_RESULT:
            break
        // 联系人部门搜索结果
        case CONTACT_E_SEARCH_DEPARTMENT_RESULT:
            break
        // 联系人头像搜索结果
        case CONTACT_E_SEARCH_GET_ICON_RESULT:
            break
        // 企业地址本搜索结果
        case CONTACT_E_SEARCH_LDAP_CONTACT_RESULT:
            let contactList = resultDictionary[TUP_CONTACT_KEY] as! [LdapContactInfo];
            // 数据是否为空
            if contactList.count == 0 {
                CLLog("contactList Empty")
                MBProgressHUD.animate(withDuration: 2.0) {
                    MBProgressHUD.showBottom(tr("查询失败"), icon: nil, view: self.view)
                }
                MBProgressHUD.hide(for: view)
                tableView.mj_footer?.endRefreshing()
                return
            } else {
                self.contactMutableList.addObjects(from: contactList)
                self.pageNum = self.contactMutableList.count / Int(PAGE_COUNT_50PER)
                self.currentPage += 1
                changeData(contactList: contactList)
            }
            // 0 表示当前为最后一页
            self.cookieLen = resultDictionary[COOKIE_LEN] as! Int
            CLLog("cookie:\(self.cookieLen)");
            if self.cookieLen == 0 {
                self.isLoadData = false
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                tableView.mj_footer?.endRefreshing()
            }
            self.pageCookie = resultDictionary[PAGE_COOKIE] as? NSData
            break;
        default:
            break;
        }
    }
    
    //MARK: - 数据排序
    func changeData(contactList:[LdapContactInfo]) {
        for contact in contactList {
            if contact.name == nil || contact.name.count == 0{
                contact.name = "666"
                continue
            }
            // 首字母
            let firstChar = LocalContactModel.init().getFirstCharactor(name: contact.name)
            // 同一标签下的[联系人]
            if contactMutableDict.object(forKey: firstChar) != nil {
                // 同一标签下的[联系人]
                let ContArr: NSMutableArray = contactMutableDict.object(forKey: firstChar) as! NSMutableArray
                // 添加联系人
                ContArr.add(contact)
                // 同一标签下的[联系人]排序
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
            } else {
                let tempArr = NSMutableArray.init()
                tempArr.add(contact)
                contactMutableDict.setValue(tempArr, forKey: firstChar)
            }
            
            
        }
        sNameArr.removeAllObjects()
        sNameArr.addObjects(from: contactMutableDict.allKeys)
        
        print("\(sNameArr)")
        
        sNameArr.sort {(s1, s2) -> ComparisonResult in
            if s1 as! String > s2 as! String{
                return .orderedDescending
            } else {
                return .orderedAscending
            }
        }
        self.tableView.reloadData()
    }
    
    func judgeNumber(str: String) -> Bool {
        let reg = "^[1-9]+$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        if pre.evaluate(with: str) {
            return true
        } else {
            return false
        }
    }
    
    func getFirstCharactor(name:String) -> String {
        let str = CFStringCreateMutableCopy(nil,0,name as CFString)
        CFStringTransform(str, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)
        return (str as! NSString).substring(to: 1).uppercased()
    }
}

//MARK: - UITableView 代理方法
extension CompanyContactViewController{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 标签字母
        if indexPath.row == 0 {
            return TableTextCell.CELL_HEIGHT
        }
        // 联系人
        return TableImageTextCell.CELL_HEIGHT
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        footer?.isHidden = self.sNameArr.count != 0 ? false : true
        return self.sNameArr.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.contactMutableDict.object(forKey: sNameArr[section]) as! NSMutableArray).count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 第一行显示标签字母
        if  indexPath.row == 0 {
            let indexAZCell = tableView.dequeueReusableCell(withIdentifier: TableTextCell.CELL_ID) as! TableTextCell
            indexAZCell.showTitleLabel.text = self.sNameArr[indexPath.section] as? String
            return indexAZCell
        }
        // 联系人
        let contactInfo = (contactMutableDict.object(forKey: sNameArr[indexPath.section]) as! NSMutableArray)[indexPath.row - 1] as! LdapContactInfo
        let cell = tableView.dequeueReusableCell(withIdentifier: TableImageTextCell.CELL_ID) as! TableImageTextCell
        let nameStr = contactInfo.name!
        let codeStr = ""
        cell.showTitleLabel.text = "\(nameStr) \(codeStr)"
        cell.showTitleLabel.attributedText = changeNameAndCodeTitleStyle(cellText:cell.showTitleLabel.text!,nameStr: nameStr,codeStr: codeStr)
        cell.showSubTitleLabel.text = contactInfo.deptName
        //获取图片信息
        cell.showImageView.image = getUserIconWithAZ(name: nameStr)

//        cell.showSubTitleLabel.text = LdapContactInfo.getDeptName(contactInfo.corpName)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 标签字母
        if indexPath.row == 0 {
            return
        }
        
        let cell = tableView .cellForRow(at: indexPath) as! TableImageTextCell
        self.iconImage = cell.showImageView.image
        // 联系人
        let contactInfo = (contactMutableDict.object(forKey: sNameArr[indexPath.section]) as! NSMutableArray)[indexPath.row - 1] as! LdapContactInfo
        
        
        self.clickContactDail(contactInfo: contactInfo)

//        // 发送代理
//        if self.isSlectStatus != nil && self.isSlectStatus! {
//            self.customDelegate?.companyContactViewSelectedData(viewVC: self, sureSelectedData: [contactInfo])
//            return
//        }
    }
}

//MARK: - 页面间跳转扩展方法
extension CompanyContactViewController {
    //MARK: 搜索
    @objc func searchBarItemClick(sender: UIBarButtonItem) {
        let companySearchViewVC = CompanySearchViewController()
        companySearchViewVC.searchType = .companyContact
        self.navigationController?.pushViewController(companySearchViewVC, animated: true)
    }
    // MARK: 返回
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: 跳转联系人详情
    func clickContactDail(contactInfo: LdapContactInfo) {
        let contactDetailViewVC = ContactDetailViewController()
        contactDetailViewVC.ldapContactInfo = contactInfo
        contactDetailViewVC.contactDetailVC = .companyContact
        contactDetailViewVC.fromVc = .companyVC
        contactDetailViewVC.iconImage = self.iconImage
        contactDetailViewVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(contactDetailViewVC, animated: true)
    }
}
