//
//  SearchAttendeeViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class SearchAttendeeViewController: UIViewController {
    //预约会议上次选中的列表
//    var  hasBeDelectConfAttendees: [ConfAttendee] = []
    private static var loadMoreCellID = "LoadMoreCell"
   
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    
    private var CollectionView:UICollectionView!
    
    private var firstCharactorArr : [String] = []
    
    // 搜索框旁边collection显示数组
    private var searchAttendeeArr = NSMutableArray.init()
    
    private var firstCharactorArrTemp : [String] = []
    
    private var collectionContactDictionary = NSMutableDictionary.init()    // 收藏联系人
    
    private var commonContactArr = NSMutableArray.init() // 添加的联系人
    
    private var selectedArray = NSMutableArray.init()
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    private var companyContactDic = NSMutableDictionary.init() //企业通讯录字典（字母排序）
    
    private var companyArray = NSMutableArray.init() // 企业通讯录
    
    private var sNameArr = NSMutableArray.init() //企业通讯录的字母数组
    
    
    private var localContactArray = NSMutableArray.init() // 搜索本地联系人
    
    private var companyContactArray = NSMutableArray.init() // 搜索企业通讯录数据

    //是否直接从avc视频界面跳转邀请  牵扯到返回转横屏
    var isAvcVideoComing = false
    
    // 搜索模型
    private var search = SearchParam.init()
    // 所有联系人请求的分页
    private var cookieLen = 0
    private var pageCookie : NSData? = nil
    // 精准搜索的分页
    private var searchCookieLen = 0
    private var searchPageCookie : NSData? = nil
    
    //设定一个变量来记录键盘高度
    var keyboardHeight:CGFloat = 0.0
    
    //是否全部加在完成
    open var isLoadDataAll = false

    //搜索标志
    private var isSearch = false
    
    //点击search
    private var issearchAlreadyClick = false
    
    // 是否是第一次进入
    private var isFirstJoin = true
    
    //是否收藏联系人大于5
    private var isThanFive = false
    
    
    private var isdimSearch = false
    // 是否点击搜索 点击了不走模糊搜索
    private var isReturnSearch = false
    
    // 每点击完成之前加入的数组
    private var addAttendeeArr:[LdapContactInfo] = []
    // 与会者列表传入的数组
    public var meetingCofArr:[ConfAttendeeInConf] = []
    
    var footer:MJRefreshBackNormalFooter?
    
    
    
    @IBOutlet weak var searchBackView: UIView!
    
    @IBOutlet weak var SearchbackLeft: NSLayoutConstraint!
    @IBOutlet weak var doneViewBottomConstraint: NSLayoutConstraint!
    
    // 是否是预约会议跳转过来
    open var isFromPreMeeting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏是否透明(防止会议中邀请入会collectionView错位)
        self.edgesForExtendedLayout = []
        self.noDataLabel.isHidden = true
        self.noDataLabel.text = tr("暂无搜索结果")
        //先移除
        addAttendeeArr.removeAll()
        // 先处理数据
        if isFromPreMeeting {
            let attend = LdapContactInfo.init()
            attend.name = ("(" + tr("我") + ")")
            attend.number = (NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as? String)
            attend.number = attend.number+"@"+"114.114.114.114"
            attend.account = ("(" + tr("我") + ")")+"@"+"114.114.114.114"
            attend.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
            attend.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
            addAttendeeArr.append(attend)
            
            // 每次进页面刷新collectionView
            for Attendee in SessionManager.shared.currentAttendeeArray {
                addAttendeeArr.append(Attendee)
            }
        }
                        
        // 加载UI
        setupUI()
        
        // 加载监听通知
        registerNotification()
        
        // 刷新CollectionView页面
        loadCollectionView()
        
        // 底部完成
        self.updateCompleteBtn()
    }
    
    func updateCompleteBtn() {
        if addAttendeeArr.count == 0 {
            self.doneBtn.backgroundColor = UIColor.colorWithSystem(lightColor: "CCCCCC", darkColor: "333333")
            self.doneBtn.setTitleColor(UIColor.colorWithSystem(lightColor: "FFFFFF", darkColor: "666666"), for: .normal)
            self.doneBtn.isUserInteractionEnabled = false
            self.doneBtn.setTitle(tr("完成") + "(0)", for: .normal)
        } else {
            self.doneBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
            self.doneBtn.setTitleColor(UIColor.white, for: .normal)
            self.doneBtn.isUserInteractionEnabled = true
            self.doneBtn.setTitle(tr("完成") + "(\(addAttendeeArr.count))", for: .normal)
        }
    }
    
    // MARK: 加载UI
    private func setupUI () {
        
        self.title = tr("邀请")
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.searchTextField.placeholder = tr("搜索")
        //tableView初始化
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.searchTableView.estimatedRowHeight = 0
        self.searchTableView.estimatedSectionFooterHeight = 0
        self.searchTableView.estimatedSectionHeaderHeight = 0
        self.searchTableView.register(UINib.init(nibName: TableSearchAttendeeCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableSearchAttendeeCell.CELL_ID)
        self.searchTableView.register(TableHeaderFooterTextCell.classForCoder(), forHeaderFooterViewReuseIdentifier: TableHeaderFooterTextCell.CELL_ID)
        self.searchTableView.register(UINib.init(nibName: TableTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTextCell.CELL_ID)
        self.searchTableView.register(UINib.init(nibName: Self.loadMoreCellID, bundle: nil), forCellReuseIdentifier: Self.loadMoreCellID)
        
        //设置刷新
//        ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.searchTableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: nil, moreData: self.moreData)
        
        //MJ刷新控件
        footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(moreData))
        footer?.setTitle(tr("上拉可以加载更多"), for: .idle)
        footer?.setTitle(tr("松开立即加载更多"), for: .pulling)
        footer?.setTitle(tr("正在加载"), for: .refreshing)
        footer?.setTitle(tr("--没有更多了--"), for: .noMoreData)
        self.searchTableView.mj_footer = footer
        
        
        // 去分割线
        self.searchTableView.separatorStyle = .none
        
        //设置回调代理
        ManagerService.contactService()?.delegate = self
        
        self.doneBtn.backgroundColor = UIColor.colorWithSystem(lightColor: "CCCCCC", darkColor: "333333")
        self.doneBtn.setTitleColor(UIColor.colorWithSystem(lightColor: "FFFFFF", darkColor: "666666"), for: .normal)
        self.doneBtn.isUserInteractionEnabled = false
        
        searchTextField.delegate = self
        searchTextField.returnKeyType = .search
        
        // 搜索旁的Collection
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        let CollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        CollectionView.delegate = self
        CollectionView.dataSource = self
        CollectionView.showsHorizontalScrollIndicator = false
        CollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        CollectionView.register(UINib.init(nibName: SearchAttendeeItemCollectionViewCell.CELL_ID, bundle: nil), forCellWithReuseIdentifier: SearchAttendeeItemCollectionViewCell.CELL_ID)
        self.view.addSubview(CollectionView)
        self.CollectionView = CollectionView
        
        // chenfan：断网后的样式
        _ = WelcomeViewController.checkNetworkAndUpdateUI()
        //加载本地收藏通讯录
        initData()
    }
    
    // MARK: 注册通知监听
    private func registerNotification() {
        // 监听键盘弹出通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(note:)), name:UIResponder.keyboardWillShowNotification,object: nil)
        // 监听键盘隐藏通知
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardHidden(note:)),
                    name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        ManagerService.contactService()?.delegate = nil
        NotificationCenter.default.removeObserver(self)
        if isAvcVideoComing {
            APP_DELEGATE.rotateDirection = .landscape
            UIDevice.switchNewOrientation(.landscapeRight)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: done click
    @IBAction func doneBtnClick(_ sender: Any) {
        
        if isFromPreMeeting {
            addAttendeeArr.remove(at: 0)
        }else{
            //不管是AVC或SVC一次邀请最多十个
            //设置最大邀请人数
            if addAttendeeArr.count > 10{
                return MBProgressHUD.showBottom(tr("邀请人数最多为10人"), icon: nil, view: self.view)
            }
        }
        
        
        if isAvcVideoComing {
            //直接过来直接邀请  防止通知错乱邀请多次
            if addAttendeeArr.count > 0 {
                let atteedeeArray = NSArray(array: addAttendeeArr) as? [LdapContactInfo]
                ManagerService.confService()?.confCtrlAddAttendee(toConfercene:atteedeeArray)
            }
        }else {
            SessionManager.shared.currentAttendeeArray = addAttendeeArr
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: UpdataInvitationAttendee), object: nil)
        }
        
        self.leftBarBtnItemClick(sender: UIBarButtonItem.init())
    }
    func dismissVC (){
        self.navigationController?.popViewController(animated: false)

    }
    // MARK: 销毁VC
    deinit {
        //取消键盘通知的监听
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

// MARK: TextField代理
extension SearchAttendeeViewController: UITextFieldDelegate {
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         isReturnSearch = false
        if ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string).count == 0 {
            
            if companyContactDic.count == 0 {
                
                companyArray.removeAllObjects()
                companyContactArray.removeAllObjects()
                sNameArr.removeAllObjects()
                commonContactArr.removeAllObjects()
                companyContactDic.removeAllObjects()
                collectionContactDictionary.removeAllObjects()
                firstCharactorArr.removeAll()
                
                isSearch = false
                isFirstJoin = true
                cookieLen = 0
                pageCookie = nil
                // 开始加载企业通讯录
                // chenfan：断网后的样式
                if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.online {
                    MBProgressHUD.showMessage("", to: view)
                    // 企业联系人
                    loadCompnyList("*", cookieLen, pageCookie)
                }
                // 加载本地收藏通讯录
                initData()
            }else{
                isSearch = false
                CATransaction.setDisableActions(false)
                self.searchTableView.reloadData()
                CATransaction.commit()
                if self.isLoadDataAll {
                    searchTableView.mj_footer?.endRefreshingWithNoMoreData()
                }else{
                    searchTableView.mj_footer?.endRefreshing()
                }
            }
        }
        return true
    }
    
    //输入时进行输入
    func textFieldDidChangeSelection(_ textField: UITextField) {
//        return
        let nowString = self.searchTextField?.text
        if self.searchTextField?.markedTextRange == nil {
            //如果是企业查询实时查询
            if nowString != "" {
                //延时一分钟
                self.perform(#selector(SearchTextfield(object:)), with: nowString, afterDelay: 0.5)
            }
        }
    }
    
    @objc func SearchTextfield(object:String) {
        //重复数值不再进行搜索
        if self.searchTextField?.text != object || isReturnSearch == true {
            return
        }
        //进行数据搜索
        SearchLocalAndCompany(textField: self.self.searchTextField)
    }
    
    
    func SearchLocalAndCompany(textField:UITextField){
        // 查询企业通讯录和本地通讯录数据
        if textField.text != "" || textField.text != nil {
            isSearch = true
            // 查询企业
            searchCookieLen = 0
            searchPageCookie = nil
            
            //清空本地联系人
            localContactArray.removeAllObjects()
            // 查询本地
            let localModel = LocalContactModel.init()
            localModel.searchWord = textField.text!
            LocalContactBusiness.shareInstance.selectLocalContact(localContactModel: localModel) { (arr) in
                //筛选出已经选择过的
                for select in self.addAttendeeArr {
                    for att in arr {
                        if NSString.getSeacrhAttendeeNumber(select.number) == NSString.getSeacrhAttendeeNumber(att.number) {
                            att.isSelected = true
                            break
                        }
                    }
                }
                
                for select in self.meetingCofArr {
                    for att in arr {
                        if NSString.getSeacrhAttendeeNumber(String(select.number)) == NSString.getSeacrhAttendeeNumber(att.number) {
                            att.isSelf = true
                            break
                        }
                    }
                }
                
                let sortList = arr.sorted { (model1, model2) -> Bool in
                    if let name1 = model1.name, let name2 = model2.name {
                        return NSString(string: name1).compare(name2, options: NSString.CompareOptions.numeric) == .orderedAscending
                    } else {
                        return model1.name ?? "" < model2.name ?? ""
                    }
                }
                self.localContactArray.addObjects(from: sortList)
            }
            // chenfan：断网后的样式
            if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.offline {
                MBProgressHUD.hide(for: view, animated: true)
                self.view.resignFirstResponder()
            } else {
                loadCompnyList(textField.text, searchCookieLen, searchPageCookie)
            }
            
        } else {
            CATransaction.setDisableActions(false)
            self.searchTableView.reloadData()
            CATransaction.commit()
        }
    }
    
    
    // MARK: textFieldShouldBeginEditing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: search return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isReturnSearch = true
        if textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            MBProgressHUD.show(tr("请输入关键词搜索"), icon: nil, view: self.view)
            textField.text = ""
            return true
        }
        
        // 查询企业
        searchCookieLen = 0
        searchPageCookie = nil
        
        CLLog("点击搜索\(textField.text ?? "")")
        //点击搜索按钮后键盘退出, 防止重复点击造成的一直转圈圈
        self.view.endEditing(true)
        
        // 查询企业通讯录和本地通讯录数据
        if textField.text != "" || textField.text != nil {
            isSearch = true
            MBProgressHUD.showMessage("", to: view)
//           issearchAlreadyClick = true
            
            //清空本地联系人
            localContactArray.removeAllObjects()
            
            // 查询本地
            let localModel = LocalContactModel.init()
            localModel.searchWord = textField.text!
            LocalContactBusiness.shareInstance.selectLocalContact(localContactModel: localModel) { (arr) in
                //筛选出已经选择过的
                for select in self.addAttendeeArr {
                    for att in arr {
                        if NSString.getSeacrhAttendeeNumber(select.number) == NSString.getSeacrhAttendeeNumber(att.number) {
                            att.isSelected = true
                            break
                        }
                    }
                }
                
                for select in self.meetingCofArr {
                    for att in arr {
                        if NSString.getSeacrhAttendeeNumber(String(select.number)) == NSString.getSeacrhAttendeeNumber(att.number) {
                            att.isSelf = true
                            break
                        }
                    }
                }
                
                let sortList = arr.sorted { (model1, model2) -> Bool in
                    if let name1 = model1.name, let name2 = model2.name {
                        return NSString(string: name1).compare(name2, options: NSString.CompareOptions.numeric) == .orderedAscending
                    } else {
                        return model1.name ?? "" < model2.name ?? ""
                    }
                }
                self.localContactArray.addObjects(from: sortList)
            }
            // chenfan：断网后的样式
            if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.offline {
                MBProgressHUD.hide(for: view, animated: true)
                self.view.resignFirstResponder()
            } else {
                loadCompnyList(textField.text, searchCookieLen, searchPageCookie)
            }
            
        } else {
            CATransaction.setDisableActions(false)
            self.searchTableView.reloadData()
            CATransaction.commit()
        }
        return true
    }
}




// MARK: TableView代理
extension SearchAttendeeViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearch {
            return 2
        }
        
        var sestionCount = 0
        let commSestionCount = isFirstJoin ? caculateSectionCountAndRowsCount().0 : collectionContactDictionary.allKeys.count
        
        if self.collectionContactDictionary.allKeys.count != 0 && self.commonContactArr.count != 0  && companyContactDic.allKeys.count != 0 {
            // 常用联系人 + 收藏联系人 + 企业联系人
            sestionCount = 1 + commSestionCount + 1 + 1 + companyContactDic.allKeys.count
        } else if self.collectionContactDictionary.allKeys.count != 0 && self.commonContactArr.count == 0 && companyContactDic.allKeys.count == 0 {
            // 收藏联系人
            sestionCount = commSestionCount + 1
        } else if self.collectionContactDictionary.allKeys.count == 0 && self.commonContactArr.count != 0 && companyContactDic.allKeys.count == 0 {
            // 常用联系人
            sestionCount = 1
        }else if self.collectionContactDictionary.allKeys.count != 0 && self.commonContactArr.count != 0  && companyContactDic.allKeys.count == 0{
            // 收藏联系人 + 常用联系人
            sestionCount = 1 + commSestionCount + 1
        }else if self.collectionContactDictionary.allKeys.count == 0 && companyContactDic.allKeys.count != 0 &&  self.commonContactArr.count != 0 {
            //常用联系人 + 企业联系人
            sestionCount = 1 + companyContactDic.allKeys.count + 1
        }else if companyContactDic.allKeys.count != 0 && self.collectionContactDictionary.allKeys.count == 0 && self.commonContactArr.count == 0 {
            //企业联系人
            sestionCount = 1 + companyContactDic.allKeys.count
        }else if self.collectionContactDictionary.allKeys.count != 0 && companyContactDic.allKeys.count != 0 &&  self.commonContactArr.count == 0 {
            // 收藏联系人 + 企业联系人
            sestionCount = 1 + commSestionCount + 1 + sNameArr.count
        }
        
        //是否隐藏footer
        footer?.isHidden = sestionCount != 0 ? false : true
        return sestionCount
     }
       
   // MARK: row count in section
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if isSearch {
            if section == 0 {
                return localContactArray.count
            }
            return companyContactArray.count
        }
       
        // 常用联系人
        if self.commonContactArr.count != 0 && section == 0 {
            return self.commonContactArr.count
        }
    
        // 收藏联系人不为空(企业联系人为空)
        if self.collectionContactDictionary.allKeys.count != 0  && companyArray.count == 0{
            
            let compareValue = self.commonContactArr.count == 0 ? 0 : 1
            if compareValue == 0 ? section == 0 : section == 1 {
                // 收藏联系人标题为空cell
                return 0
                
            }else if section < ((isFirstJoin ? caculateSectionCountAndRowsCount().0 : firstCharactorArr.count) + 1 + (compareValue == 0 ? 0 : 1) ) {
                
                if isFirstJoin {
                    //计算前五条数据需要几个
                    return caculateSectionCountAndRowsCount().1[compareValue == 0 ? section - 1 : section - 2]
                    
                }else{
                    let dataArray = self.collectionContactDictionary[self.firstCharactorArr[compareValue == 0 ? section - 1 : section - 2]] as! [LocalContactModel]
                    noDataLabel.isHidden = dataArray.count != 0 ? true:false
                    return dataArray.count
                }
            }
        }
    
        //收藏联系人为空（企业联系人不为空）
       if self.collectionContactDictionary.allKeys.count == 0  && companyArray.count != 0{
           
           let compareValue = self.commonContactArr.count == 0 ? 0 : 1
           if compareValue == 0 ? section == 0 : section == 1 {
               // 企业联系人为空cell
               return 0
               
           }else if section < (sNameArr.count + 1 + (compareValue == 0 ? 0 : 1) ) {
               
               let dataArray = self.companyContactDic[self.sNameArr[compareValue == 0 ? section - 1 : section - 2]] as! [LdapContactInfo]
                noDataLabel.isHidden = dataArray.count != 0 ? true:false
               return dataArray.count
           }
       }

      //收藏联系人为不为空（企业联系人不为空）
        if self.collectionContactDictionary.allKeys.count != 0  && companyArray.count != 0 {
            
             let compareValue = self.commonContactArr.count == 0 ? 0 : 1
            
             if compareValue == 0 ? section == 0 : section == 1 {
                 // 收藏联系人标题为空cell
                 return 0
             }else if section < ((isFirstJoin ? caculateSectionCountAndRowsCount().0 : firstCharactorArr.count) + 1 + (compareValue == 0 ? 0 : 1) ) {
                 
                if isFirstJoin {
                    
                     return caculateSectionCountAndRowsCount().1[compareValue == 0 ? section - 1 : section - 2]
                    
                }else{
                    let dataArray = self.collectionContactDictionary[self.firstCharactorArr[compareValue == 0 ? section - 1 : section - 2]] as! [LocalContactModel]
                    noDataLabel.isHidden = dataArray.count != 0 ? true:false
                    return dataArray.count
                }
                
                
             }
            
            if section == ((self.commonContactArr.count == 0 ? 0 : 1) + 1 + (isFirstJoin ? caculateSectionCountAndRowsCount().0 : self.firstCharactorArr.count)) {
                return 0
            }else{
            
                let dataArray = self.companyContactDic[self.sNameArr[compareValue == 0 ? section - 2 - (isFirstJoin ? caculateSectionCountAndRowsCount().0 : self.firstCharactorArr.count) : section - 3 - (isFirstJoin ? caculateSectionCountAndRowsCount().0 : self.firstCharactorArr.count)]] as! [LdapContactInfo]
                noDataLabel.isHidden = dataArray.count != 0 ? true:false
                return dataArray.count
            }
            
        }
    
        return 0
   }
       
       // MARK: cell content
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
           if isFirstJoin && indexPath.section == caculateSectionCountAndRowsCount().0 + (commonContactArr.count == 0 ? 0 : 1) && indexPath.row == (caculateSectionCountAndRowsCount().1.last ?? 0) - 1    {
               let cell = tableView.dequeueReusableCell(withIdentifier: Self.loadMoreCellID, for: indexPath)
               return cell
           }
            //是否搜索
            if isSearch {
                if indexPath.section == 0 {
                    //本地
                    return getCollectionContactImageTextCell(indexPath: indexPath)
                }
                //企业通讯录
                return getCompanyContactTableImageTextCell(indexPath: indexPath)
            }
        
            // 常用联系人
            if self.commonContactArr.count != 0 && indexPath.section == 0 {
                
                return getCommonContactTableImageTextCell(indexPath: indexPath)
                
            }else if collectionContactDictionary.allKeys.count != 0 && indexPath.section <= ( isFirstJoin ? caculateSectionCountAndRowsCount().0 + (commonContactArr.count == 0 ? 1 : 2) : collectionContactDictionary.allKeys.count + (commonContactArr.count == 0 ? 1 : 2)) { //收藏联系人
                // 收藏联系人
                return getCollectionContactImageTextCell(indexPath: indexPath)
             }
        
           return getCompanyContactTableImageTextCell(indexPath: indexPath)
       }
       
    // 本地收藏联系人
       func getCollectionContactImageTextCell(indexPath: IndexPath) -> UITableViewCell {
            // 收藏联系人
        let cell = searchTableView.dequeueReusableCell(withIdentifier: TableSearchAttendeeCell.CELL_ID) as! TableSearchAttendeeCell
        var contactInfo:LocalContactModel = LocalContactModel.init()
        if isSearch {
            contactInfo = self.localContactArray[indexPath.row] as! LocalContactModel
        }else{
            let compareValue = self.commonContactArr.count == 0 ? 0 : 1
            contactInfo = (collectionContactDictionary.object(forKey:firstCharactorArr[compareValue == 0 ? indexPath.section - 1 : indexPath.section - 2]) as! NSArray)[indexPath.row] as! LocalContactModel
        }
            
           let nameStr = contactInfo.name!
           let codeStr = ""
           cell.nameLabel.text = nameStr + "  " + codeStr
           cell.subTitleLabel.text = contactInfo.depart
        
           //如果是自己的话肯定是已经选择的并且置灰不让选择
            cell.chooseBtn.setImage(UIImage.init(named: "no_check"), for: .normal)
            cell.chooseBtn.setImage(UIImage.init(named: "check"), for: .selected)
            cell.chooseBtn.isSelected = contactInfo.isSelected
        
//        codeStr == NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as? String || contactInfo.isSelf
        if contactInfo.number ==  ManagerService.call().terminal || contactInfo.isSelf {
                cell.chooseBtn.setImage(UIImage(named: "check_Gay"), for: .normal)
                cell.chooseBtn.isEnabled = false
            }else {
                cell.chooseBtn.isEnabled = true
            }

            cell.headImageView.image = getUserIconWithAZ(name: nameStr)

           return cell
       }
       
       // 常用联系人
       func getCommonContactTableImageTextCell(indexPath: IndexPath) -> UITableViewCell {
           // 常用联系人
           let cell = searchTableView.dequeueReusableCell(withIdentifier: TableSearchAttendeeCell.CELL_ID) as! TableSearchAttendeeCell

           let userCallLogModel = self.commonContactArr[indexPath.row] as! UserCallLogModel
           
           let nameStr = userCallLogModel.userName!
           let codeStr = userCallLogModel.number!
//           cell.nameLabel.text = nameStr + "  " + codeStr
           cell.nameLabel.text = nameStr
           cell.subTitleLabel.text = userCallLogModel.title
           cell.chooseBtn.isSelected = userCallLogModel.isSelected
            
            cell.chooseBtn.setImage(UIImage.init(named: "no_check"), for: .normal)
            cell.chooseBtn.setImage(UIImage.init(named: "check"), for: .selected)
            if userCallLogModel.isSelf { // 已经在会议中 显示灰色不可被点击
                cell.chooseBtn.setImage(UIImage(named: "check_Gay"), for: .normal)
                cell.chooseBtn.isEnabled = false
            }else{
                cell.chooseBtn.isEnabled = true
            }
        
           // set image
           cell.headImageView.image = getUserIconWithAZ(name: nameStr)
        
           return cell
       }
    
    // Mark - 企业通讯录
    func getCompanyContactTableImageTextCell(indexPath: IndexPath) -> UITableViewCell {
        // 企业通讯录
        let cell = searchTableView.dequeueReusableCell(withIdentifier: TableSearchAttendeeCell.CELL_ID) as! TableSearchAttendeeCell
        
        var contactInfo: LdapContactInfo = LdapContactInfo()
        if isSearch {
            if companyContactArray.count > 0 {
                contactInfo = companyContactArray[indexPath.row] as! LdapContactInfo
            }
        }else{
            var index = self.commonContactArr.count == 0 ? 0 : 1
            index = self.collectionContactDictionary.allKeys.count == 0 ? index + 1 : index + 2
            index = indexPath.section - index - (isFirstJoin ? caculateSectionCountAndRowsCount().0 : firstCharactorArr.count)
            contactInfo = (companyContactDic.object(forKey: sNameArr[index]) as! NSArray)[indexPath.row] as! LdapContactInfo
        }
        
        let nameStr = contactInfo.name ?? ""
        let codeStr = ""
        cell.nameLabel.text = nameStr + " " + codeStr
        cell.nameLabel.attributedText = changeNameAndCodeTitleStyle(cellText: cell.nameLabel.text ?? "", nameStr: nameStr, codeStr: codeStr)
        cell.nameLabel.text = nameStr
        cell.subTitleLabel.text = contactInfo.deptName
//        cell.subTitleLabel.text = LdapContactInfo.getDeptName(contactInfo.corpName)
        
        cell.chooseBtn.setImage(UIImage.init(named: "no_check"), for: .normal)
        cell.chooseBtn.setImage(UIImage.init(named: "check"), for: .selected)
        cell.chooseBtn.isSelected = contactInfo.isSelected
        //如果是自己的话肯定是已经选择的并且置灰不让选择
//        print("------",codeStr,contactInfo.isSelf)
//        codeStr == NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as? String
        //默认选中
        if contactInfo.ucAcc ==  ManagerService.call().terminal || contactInfo.isSelf {
            cell.chooseBtn.setImage(UIImage(named: "check_Gay"), for: .normal)
            cell.chooseBtn.isEnabled = false
        }else{
            cell.chooseBtn.isEnabled = true
        }
                
        cell.headImageView.image = getUserIconWithAZ(name: nameStr)
        return cell
    }
    
       // MARK: cell click
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            tableView.deselectRow(at: indexPath, animated: false)
        
            if isSearch {
                // 企业通讯录搜索
                if indexPath.section == 1 {
                    let companyContactInfo = self.companyContactArray[indexPath.row] as! LdapContactInfo
                    // 如果是自己的话肯定是已经选择的并且置灰不让选择
                    if companyContactInfo.isSelf || ManagerService.call().terminal == companyContactInfo.ucAcc {
                        return
                    }
                    companyContactInfo.isSelected = !companyContactInfo.isSelected
                    // 刷新本地并处理数据
                    reloadLocalWithSelectCompany(contact: companyContactInfo)
                }
                    
                // 本地收藏联系人
                if indexPath.section == 0 {
                    // 本地收藏联系人
                    let localContactInfo = self.localContactArray[indexPath.row] as! LocalContactModel
                    // 如果是自己的话肯定是已经选择的并且置灰不让选择
                    if localContactInfo.isSelf || ManagerService.call().terminal == localContactInfo.number {
                        return
                    }
                    localContactInfo.isSelected = !localContactInfo.isSelected
                    // 刷新企业联系人并处理数据
                    reloadCompanyWithSelectLocal(contact: localContactInfo)
                    
                    
                }
                CATransaction.setDisableActions(false)
                //刷新tableView对应的行
                searchTableView.reloadRows(at: [indexPath], with: .none)
                //刷新整个tableView
//                searchTableView.reloadData()
                CATransaction.commit()
                //刷新collectionView界面
                loadCollectionView()
                
                // 底部按钮更新
                self.updateCompleteBtn()
                return
            }
        
            if isFirstJoin && indexPath.section == caculateSectionCountAndRowsCount().0 + (commonContactArr.count == 0 ? 0 : 1) + 1 - 1 && indexPath.row == (caculateSectionCountAndRowsCount().1.last ?? 0) - 1  {
                isFirstJoin = false
                //刷新tableView对应的section, 点击更多崩溃问题
//                searchTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                searchTableView.reloadData()
                return
            }
        
            // 常用联系人
            if self.commonContactArr.count != 0 && indexPath.section == 0 {
                let contactInfo = self.commonContactArr[indexPath.row] as! UserCallLogModel
                contactInfo.isSelected = !contactInfo.isSelected
            } else if collectionContactDictionary.allKeys.count != 0 && indexPath.section <= (isFirstJoin ? caculateSectionCountAndRowsCount().0 : collectionContactDictionary.allKeys.count + (commonContactArr.count != 0 ? 1 : 0 + 1))  {
                // 收藏联系人
                let compareValue = self.commonContactArr.count == 0 ? 0 : 1
                let contactInfo = (collectionContactDictionary.object(forKey: firstCharactorArr[compareValue == 0 ? indexPath.section - 1 : indexPath.section - 2]) as! NSArray)[indexPath.row] as! LocalContactModel
//                contactInfo.isSelf || NSString.getSeacrhAttendeeNumber(contactInfo.number) == (NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as! String)
                //自己不能选中
                if contactInfo.isSelf || NSString.getSeacrhAttendeeNumber(contactInfo.number) == ManagerService.call().terminal {
                    return
                }
                
                contactInfo.isSelected = !contactInfo.isSelected
                self.reloadSelectedlocalData(isSearch, contactInfo.isSelected, contactInfo, indexPath)
                
            }else{
        
                //企业通讯录
                var index = self.commonContactArr.count == 0 ? 0 : 1
                index = self.collectionContactDictionary.allKeys.count == 0 ? index + 1 : index + 2
                index = indexPath.section - index - (isFirstJoin ? caculateSectionCountAndRowsCount().0 : firstCharactorArr.count)
                
                let contactInfo = (companyContactDic.object(forKey: sNameArr[index]) as! NSArray)[indexPath.row] as! LdapContactInfo
                //如果是自己的话肯定是已经选择的并且置灰不让选择
                
//                contactInfo.isSelf || NSString.getSeacrhAttendeeNumber(contactInfo.ucAcc) == (NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as! String)
                if contactInfo.isSelf || NSString.getSeacrhAttendeeNumber(contactInfo.ucAcc) == ManagerService.call().terminal {
                    return
                }
                
                contactInfo.isSelected = !contactInfo.isSelected
                self.reloadSelectedCompanyData(isSearch, contactInfo.isSelected, contactInfo, indexPath)
            }
              
            self.updateCompleteBtn()
       }

   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableSearchAttendeeCell.CELL_HEIGHT
   }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if isSearch {
            if section == 0 && self.localContactArray.count != 0 {
                let headerView = view as! TableHeaderFooterTextCell
                headerView.label.text = tr("本地收藏联系人")
                headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
            }else if section == 1 && self.companyContactArray.count != 0 {
                let headerView = view as! TableHeaderFooterTextCell
                headerView.label.text = tr("企业通讯录")
                headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
            }
            return
        }
        
        let headerView = view as! TableHeaderFooterTextCell
        
        // 常用联系人
        if self.commonContactArr.count != 0 && section == 0 {
            headerView.label.text = tr("常用联系人")
            headerView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
            return
        }
    
        // 收藏联系人
        if self.collectionContactDictionary.allKeys.count != 0 && section <= (isFirstJoin ? caculateSectionCountAndRowsCount().0 :  collectionContactDictionary.allKeys.count + (commonContactArr.count != 0 ? 1 : 0 )) {
            let compareValue = self.commonContactArr.count == 0 ? 0 : 1
            if  section == compareValue {
                headerView.label.text = tr("本地收藏联系人")
                headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
            } else {
                headerView.label.text = self.firstCharactorArr[compareValue == 0 ? section - 1 : section - 2]
                headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#000000")
            }
            return
        }
        
        //企业通讯录
        if companyArray.count > 0 {
            headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
            var sectionForCompany = 0
            //判断是否有常用联系人
            if commonContactArr.count > 0 {
                sectionForCompany = 1
            }
            
            //判断是否有收藏联系人
            if collectionContactDictionary.allKeys.count > 0 {
                sectionForCompany = (commonContactArr.count != 0 ? 1 : 0 ) + 1 + (isFirstJoin ? caculateSectionCountAndRowsCount().0 : firstCharactorArr.count)
            }
            
            if section == sectionForCompany {
                headerView.label.text = tr("企业通讯录")
            }else{
                var compareValue = self.commonContactArr.count == 0 ? 0 : 1
                compareValue = self.collectionContactDictionary.allKeys.count == 0 ? compareValue + 1 : compareValue + 2
                headerView.label.text = self.sNameArr[section - compareValue - (isFirstJoin ? caculateSectionCountAndRowsCount().0 : firstCharactorArr.count)] as? String
                headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#000000")
            }
        }
        
    }
       
       func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearch {
            if self.localContactArray.count != 0 && section == 0 {
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderFooterTextCell.CELL_ID) as! TableHeaderFooterTextCell
                return headerView
            }else if self.companyContactArray.count != 0 && section == 1 {
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderFooterTextCell.CELL_ID) as! TableHeaderFooterTextCell
                return headerView
            }
            return UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.1))
        }
        
           let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderFooterTextCell.CELL_ID) as! TableHeaderFooterTextCell
            return headerView
       }
       
       // MARK: header height
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearch {
            if self.localContactArray.count != 0 && section == 0 {
                return TableHeaderFooterTextCell.CELL_HEIGHT
            }else if self.companyContactArray.count != 0 && section == 1 {
                return TableHeaderFooterTextCell.CELL_HEIGHT
            }
            return 0.1
        }
           return TableHeaderFooterTextCell.CELL_HEIGHT
       }
       
       // MARK: footer View
       func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isSearch && self.companyContactArray.count == 0  && self.localContactArray.count == 0 {
            return UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40.0))
        }
           return UIView.init()
       }

       // MARK: footer height
       func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isSearch && self.companyContactArray.count == 0  && self.localContactArray.count == 0 {
            return 40.0
        }
           return 0.1
       }
       
       // MARK: did scroll
       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           
       }
       
       // MARK: Will Begin Dragging
       func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            UIApplication.shared.keyWindow?.endEditing(true)
       }
}

// MARK: 监听通知
extension SearchAttendeeViewController {
    //键盘弹出监听
      @objc func keyboardShow(note: Notification)  {
          guard let userInfo = note.userInfo else {return}
          guard let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else{return}
          //获取动画执行的时间
          var duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
          if duration == nil { duration = 0.25 }
    
         //获取键盘弹起的高度
          let keyboardTopYPosition = keyboardRect.height
          keyboardHeight = keyboardTopYPosition
          self.view.layoutIfNeeded()
          UIView.animate(withDuration: duration!, delay: 0, options: .allowAnimatedContent, animations: {
              //这一步是至关重要的，设置当前textField的y值为原始y值减去键盘高度，由于始终是用原始y值去减，所以不管通知几次都不会错
              self.doneViewBottomConstraint.constant = self.keyboardHeight
              self.view.layoutIfNeeded()
          }, completion: nil)
      }

      //键盘隐藏监听
      @objc func keyboardHidden(note: Notification){
          self.view.layoutIfNeeded()
          UIView.animate(withDuration: 0.3, delay: 0, options: .allowAnimatedContent, animations: {
            //用当前的y值加上键盘高度，最终使得textField回归原位
              self.doneViewBottomConstraint.constant = 0
              self.view.layoutIfNeeded()
          }, completion: nil)
      }
}

// MARK: TUP搜索代理
extension SearchAttendeeViewController:TUPContactServiceDelegate {
    //加载企业通讯录
    private func loadCompnyList(_ keywords: String? = "*",_ cookieLen: Int = 0,_ pageCookie: NSData? = nil) {
        
        if isSearch && (cookieLen == 0){
            //去除原先的数组
            companyContactArray.removeAllObjects()
//            localContactArray.removeAllObjects()
            self.searchTableView.reloadData()
            
        }
        //加载企业通讯录
         search.keywords = keywords
         search.curentBaseDn = ""
         search.sortAttribute = ""
         search.searchSingleLevel = 0
         search.pageSize = PAGE_COUNT_50PER
         search.cookieLength = Int32(cookieLen)
         search.pageCookie = pageCookie as Data?
         let isSuccess = ManagerService.contactService()?.searchLdapContact(with: search)
         if !isSuccess! {
//            issearchAlreadyClick = false
             MBProgressHUD.hide(for: view)
             MBProgressHUD.showBottom(tr("查询失败"), icon: nil, view: self.view)
            CLLog("=====SDK问题查询失败")
         }
    }
    
   @objc func moreData() {
        //加载更多企业通讯录
        isSearch ? loadCompnyList(searchTextField.text,self.searchCookieLen,self.searchPageCookie) : loadCompnyList("*", self.cookieLen, self.pageCookie)
//        // 停止刷新
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.searchTableView.mj_footer?.endRefreshing()
//        }
    }
    func contactEventCallback(_ contactEvent: TUP_CONTACT_EVENT_TYPE, result resultDictionary: [AnyHashable : Any]!) {
    
        //去除原先的数据
        MBProgressHUD.hide(for: view)
        switch contactEvent {
        case CONTACT_E_SEARCH_LDAP_CONTACT_RESULT:
            
            if isSearch && (search.cookieLength == 0){
                //去除原先的数组
                companyContactArray.removeAllObjects()
//                localContactArray.removeAllObjects()
            }
            
            let res = resultDictionary[TUP_CONTACT_EVENT_RESULT_KEY] as! Bool
            if !res{
                CLLog("Search ldap contact failed!")
            }
            
            //去除没有终端号的用户
            let dataArray = resultDictionary[TUP_CONTACT_KEY] as! [LdapContactInfo];
            let resultArray = NSMutableArray.init()
            for model in dataArray {
                if model.ucAcc != "" {
                    resultArray.add(model)
                }
            }
          
            let contactList = resultArray as! [LdapContactInfo]
            CLLog("contactList count =\(contactList.count)")
            if contactList.count == 0 {
                CLLog("contactList Empty")
            }
            
            searchTableView.mj_footer?.endRefreshing()
            if (resultDictionary[COOKIE_LEN] as! Int) == 0 {
                searchTableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
            // 当前是搜索状态
            if isSearch {
                self.searchCookieLen = resultDictionary[COOKIE_LEN] as! Int
                self.searchPageCookie = resultDictionary[PAGE_COOKIE] as? NSData
            }else{ // 当前是非搜索状态
                self.cookieLen = resultDictionary[COOKIE_LEN] as! Int
                self.pageCookie = resultDictionary[PAGE_COOKIE] as? NSData
                // 企业通讯录全部加在完成
                if self.cookieLen == 0 {
                    self.isLoadDataAll = true
                }
            }
            //筛选出已经选择过的
            for select in addAttendeeArr {
                for att in contactList {
                    if NSString.getSeacrhAttendeeNumber(select.number) == NSString.getSeacrhAttendeeNumber(att.ucAcc) {
                        att.isSelected = true
                        break
                    }
                }
            }
            
            // 不是搜索去排序
            for select in meetingCofArr {
                for att in contactList {
                    if NSString.getSeacrhAttendeeNumber(select.number) == NSString.getSeacrhAttendeeNumber(att.ucAcc)  {
                        att.isSelf = true
                        break
                    }
                }
            }
            
            //搜索数据
            if isSearch {
                self.companyContactArray.addObjects(from: contactList)
                if (companyContactArray.count != 0) {
                    noDataLabel.isHidden = true
                    footer?.setTitle(tr("--没有更多了--"), for: .noMoreData)
                }else{
                    noDataLabel.isHidden = localContactArray.count != 0 ? true : false
                    footer?.setTitle(tr(""), for: .noMoreData)
                }
                CATransaction.setDisableActions(false)
                self.searchTableView.reloadData()
                CATransaction.commit()
                return
            }
            // 搜索不排序
            self.companyArray.addObjects(from: contactList)
            
            if (companyArray.count != 0) {
                noDataLabel.isHidden = true
                footer?.setTitle(tr("--没有更多了--"), for: .noMoreData)
            }else{
                noDataLabel.isHidden = localContactArray.count != 0 ? true : false
                footer?.setTitle(tr(""), for: .noMoreData)
            }
            //排序
            changeData(contactList: contactList)
        default:
            break;
        }
    }
        
    private func changeData(contactList:[LdapContactInfo]) {
        for contact in contactList {
            if contact.name == nil || contact.name.count == 0{
                contact.name = "666"
                continue
            }
            let firstChar = LocalContactModel.init().getFirstCharactor(name: contact.name)
            if (companyContactDic.object(forKey: firstChar) != nil){
                let ContArr:NSMutableArray = companyContactDic.object(forKey: firstChar) as! NSMutableArray
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
                //根据根按首字母将数据分类
                companyContactDic.setValue(tempArr, forKey: firstChar)
            }
        }
        sNameArr.removeAllObjects()
        //存储字母key
        sNameArr.addObjects(from: companyContactDic.allKeys)
        //排序
        sNameArr.sort {(s1, s2) -> ComparisonResult in
            if s1 as! String > s2 as! String{
                return .orderedDescending
            }else{
                return .orderedAscending
            }
        }

        CATransaction.setDisableActions(false)
        self.searchTableView.reloadData()
        CATransaction.commit()
    }
}

// MARK: 精准搜索数据处理
extension SearchAttendeeViewController {
    
    // 点击了企业联系人，刷新本地联系人
    func reloadLocalWithSelectCompany(contact:LdapContactInfo) {
        // 处理CollectionView数据
        if !contact.isSelected { // 取消
            for (index, attend) in addAttendeeArr.enumerated() {
                if NSString.getSeacrhAttendeeNumber(attend.number) == NSString.getSeacrhAttendeeNumber(contact.ucAcc) {
                    addAttendeeArr.remove(at: index)
                    break
                }
            }
        }else {
            //选中
            var isHave:Bool = false
            for (_, attend) in addAttendeeArr.enumerated() {
                if NSString.getSeacrhAttendeeNumber(attend.number) == NSString.getSeacrhAttendeeNumber(contact.ucAcc) {
                    isHave = true
                    break
                }
            }
            // 当前没有这个与会者
            if !isHave {
                contact.number = contact.ucAcc
                contact.account = contact.ucAcc
                contact.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
                contact.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
                addAttendeeArr.append(contact)
            }
        }
        
        // 判断当前本地联系人是否有
        if self.localContactArray.count != 0 {
            for localInfo in self.localContactArray {
                let localContactInfo = localInfo as! LocalContactModel
                if contact.ucAcc == localContactInfo.number{
                    localContactInfo.isSelected = contact.isSelected
                    break
                }
            }
        }
        
        // 更新企业通讯录和本地通讯录
        reloadDataCompanyDictionary(contact.name, contact.ucAcc, contact.isSelected)
        reloadDataLocalDictionary(contact.name, contact.ucAcc, contact.isSelected)
    }
    
    // 点击了本地联系人。刷新企业联系人
    func reloadCompanyWithSelectLocal(contact:LocalContactModel) {
        // 处理CollectionView数据
        if !contact.isSelected { // 取消
            for (index, attend) in addAttendeeArr.enumerated() {
                if NSString.getSeacrhAttendeeNumber(attend.number) == NSString.getSeacrhAttendeeNumber(contact.number) {
                    addAttendeeArr.remove(at: index)
                    break
                }
            }
        }else {
            var isHave:Bool = false
            for (_, attend) in addAttendeeArr.enumerated() {
                if NSString.getSeacrhAttendeeNumber(attend.number) == NSString.getSeacrhAttendeeNumber(contact.number) {
                    isHave = true
                    break
                }
            }
            // 当前没有这个与会者
            if !isHave {
                let attend = LdapContactInfo.init()
                attend.name = contact.name
                attend.number = NSString.getSeacrhAttendeeNumber(contact.number)
                attend.account = NSString.getSeacrhAttendeeNumber(contact.number)
                attend.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
                attend.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
                addAttendeeArr.append(attend)
            }
        }
        
        // 判断当前企业通讯录是否有
        if self.companyContactArray.count != 0 {
            for companyInfo in self.companyContactArray {
                let companyContactInfo = companyInfo as! LdapContactInfo
                if companyContactInfo.ucAcc == contact.number{
                    companyContactInfo.isSelected = contact.isSelected
                    break
                }
            }
        }
        
        // 更新企业通讯录和本地通讯录
        reloadDataCompanyDictionary(contact.name ?? "", contact.number ?? "", contact.isSelected)
        reloadDataLocalDictionary(contact.name ?? "", contact.number ?? "", contact.isSelected)
    }
    
    // 刷新整体数据
    func refreshAllData(isNetwork: Bool) {
        // 清空默认数据
        companyArray.removeAllObjects()
        companyContactDic.removeAllObjects()
        companyContactArray.removeAllObjects()
        
        if self.searchTextField.text == "" {
            // 开始加载企业通讯录
            if isNetwork {
                MBProgressHUD.showMessage("", to: view)
                loadCompnyList("*", cookieLen, pageCookie)
            }
            
            //加载本地收藏通讯录
            initData()
        } else {
            _ = self.textFieldShouldReturn(self.searchTextField)
        }
        
        self.searchTableView.reloadData()
        loadCollectionView()
    }
}

// MARK: 企业通讯录数据处理
extension SearchAttendeeViewController {
    func reloadSelectedCompanyData(_ isSearch:Bool = false,_ isSelect:Bool = false,_ contact:LdapContactInfo? = nil, _ indexPath:IndexPath) {
        // 为nil返回
        if contact == nil {
            return
        }
        
        if !isSelect {
            for (index, attend) in addAttendeeArr.enumerated() {
                
                if attend.number == contact?.ucAcc{
                    addAttendeeArr.remove(at: index)
                    break
                }
            }
        }else {
            var isHave:Bool = false
            for (_, attend) in addAttendeeArr.enumerated() {
                
                if attend.number == contact?.ucAcc{
                    isHave = true
                    break
                }
            }
            // 当前没有这个与会者
            if !isHave {
//                let attend = LdapContactInfo.init()
//                attend.name = contact?.name
//                attend.number = contact?.ucAcc
//                attend.account = contact?.ucAcc
//                attend.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
//                attend.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
//                addAttendeeArr.append(attend)
                contact?.number = contact?.ucAcc
                contact?.account = contact?.ucAcc
                contact?.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
                contact?.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
                addAttendeeArr.append(contact!)
            }
        }
        
        // 更新本地收藏联系人对应状态
        reloadDataLocalDictionary((contact?.name) ?? "", contact?.ucAcc ?? "", isSelect)
        
        // 不是搜索状态刷新
        if !isSearch {
            CATransaction.setDisableActions(false)
            //刷新对应的行
            UIView.performWithoutAnimation {
                self.searchTableView.reloadRows(at: [indexPath], with: .none)
            }
            CATransaction.commit()
            loadCollectionView()
        }
    }
    
    // 处理选中的在目前企业通讯录中是否存在
    func reloadDataCompanyDictionary(_ name:String = "",_ number:String = "", _ isSelect:Bool = false) {
        // 如果名字传控直接返回
        if name == "" {
            return
        }
        
        let firstChar = LocalContactModel.init().getFirstCharactor(name: name)
        let section = self.sNameArr.index(of: firstChar)
        // 当前选择的本地通讯录有 没有的不做处理
        if companyContactDic.object(forKey: firstChar) != nil {
            let companyArr:NSArray = companyContactDic[firstChar] as! NSArray
            for contact in companyArr {
                let contactModel:LdapContactInfo = contact as! LdapContactInfo
                if NSString.getSeacrhAttendeeNumber(number) == contactModel.ucAcc {
                    contactModel.isSelected = isSelect
                    //刷新整个TableView
//                    self.searchTableView.reloadData()
//                    let row = companyArr.index(of: contact)
//                    let indexPath = NSIndexPath.init(row: row, section: section) as IndexPath
//                    self.searchTableView.reloadRows(at: [indexPath], with: .none)
                    return
                }
            }
        }
    }
    
}

// MARK: 本地记录数据处理
extension SearchAttendeeViewController {
    //  加载本地通讯录
    private func initData(){
        // 收藏联系人
        //顶部collectionView数据源
        self.collectionContactDictionary.removeAllObjects()
        LocalContactBusiness.shareInstance.selectFirstCharactor(type: -1) { (arr) in
            self.firstCharactorArr = arr
            var commonTotalCount = 0
            for firstCharactor in arr {
                LocalContactBusiness.shareInstance.selectLocalContactByFirstCharactor(type: -1,firstCharactor: firstCharactor) { (localContactArr) in
                    commonTotalCount += localContactArr.count
                    self.collectionContactDictionary.setValue(localContactArr.filterDuplicates({$0.number}), forKey: firstCharactor)
                }
            }
            //如果小于5 就和点击过加载按钮一样所以(self.isFirstJoin = false)
            commonTotalCount > 5 ? (self.isThanFive = true) : (self.isFirstJoin = false)
            // 判断是否有选中的数据
            for selectedAttendee in self.addAttendeeArr {
                // 收藏联系人
                for letter in self.firstCharactorArr {
                    for tempAttend in (self.collectionContactDictionary[letter] as! [LocalContactModel]) {
                        if NSString.getSeacrhAttendeeNumber(selectedAttendee.account) == NSString.getSeacrhAttendeeNumber(tempAttend.number) {
                            tempAttend.isSelected = true
                        }
                    }
                }
                // 添加的联系人
                for tempAttend in self.commonContactArr as! [UserCallLogModel] {
                    if NSString.getSeacrhAttendeeNumber(selectedAttendee.account) == NSString.getSeacrhAttendeeNumber(tempAttend.number) {
                        tempAttend.isSelected = true
                    }
                }
            }

            // 会议中的全部置灰 不可被点击
            for selectedAttendee in self.meetingCofArr {
                // 收藏联系人
                for letter in self.firstCharactorArr {
                    for tempAttend in (self.collectionContactDictionary[letter] as! [LocalContactModel]) {
                        if NSString.getSeacrhAttendeeNumber(selectedAttendee.number) == NSString.getSeacrhAttendeeNumber(tempAttend.number) {
                            tempAttend.isSelf = true
                        }
                    }
                }
                // 常用联系人
                for tempAttend in self.commonContactArr as! [UserCallLogModel] {
                    if NSString.getSeacrhAttendeeNumber(selectedAttendee.number) == NSString.getSeacrhAttendeeNumber(tempAttend.number)
                    {
                        tempAttend.isSelf = true
                    }
                }
            }
            
            // 数据去重
            let commonContactArrayTemp = NSArray.init(array: self.commonContactArr) as! [UserCallLogModel]
            self.commonContactArr.removeAllObjects()
            for commonAttendee in commonContactArrayTemp  {
                var isHave = false
                for letter in self.firstCharactorArr {
                    for tempAttend in (self.collectionContactDictionary[letter] as! [LocalContactModel]) {
                        if NSString.getSeacrhAttendeeNumber(commonAttendee.number) == NSString.getSeacrhAttendeeNumber(tempAttend.number) {
                            isHave = true
                        }
                    }
                }
                if !isHave {
                    self.commonContactArr.add(commonAttendee)
                }
            }
            
            self.updateCompleteBtn()
            
            // 刷新CollectionView
            self.loadCollectionView()
        }
    }
    // 本地联系人处理
    func reloadSelectedlocalData(_ isSearch:Bool = false,_ isSelect:Bool = false,_ contact:LocalContactModel? = nil, _ indexPath:IndexPath){
        // 为nil返回
        if contact == nil {
            return
        }
        
        if !isSelect {
            for (index, attend) in addAttendeeArr.enumerated() {
                if NSString.getSeacrhAttendeeNumber(attend.number) == contact?.number!{
                    addAttendeeArr.remove(at: index)
                    break
                }
            }
        }else {
            var isHave:Bool = false
            for (_, attend) in addAttendeeArr.enumerated() {
                if NSString.getSeacrhAttendeeNumber(attend.number) == contact?.number! {
                    isHave = true
                    break
                }
            }
            // 当前没有这个与会者
            if !isHave {
                let attend = LdapContactInfo.init()
                attend.name = contact?.name
                attend.ucAcc = contact?.number!
                attend.number = contact?.number!
                attend.account = contact?.number!
                attend.type = CONFCTRL_ATTENDEE_TYPE.ATTENDEE_TYPE_NORMAL
                attend.role = CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN
                addAttendeeArr.append(attend)
            }
        }
        
        // 处理企业通讯录状态
        reloadDataCompanyDictionary(contact?.name ?? "", contact?.number ?? "", isSelect)
        
        // 不是搜索状态在刷新
        if !isSearch {
            CATransaction.setDisableActions(false)
            //刷新tableView对应的行
            self.searchTableView.reloadRows(at: [indexPath], with: .none)
//            self.searchTableView.reloadData()
            
            CATransaction.commit()
            loadCollectionView()
        }
    }
    
    // 处理选中的在目前企业通讯录中是否存在
    func reloadDataLocalDictionary(_ name:String = "",_ number:String = "", _ isSelect:Bool = false) {
        // 如果名字传控直接返回
        if name == "" {
            return
        }
        
        let firstChar = LocalContactModel.init().getFirstCharactor(name: name)
        // 当前选择的本地通讯录有 没有的不做处理
        if collectionContactDictionary.object(forKey: firstChar) != nil {
            let companyArr:NSArray = collectionContactDictionary[firstChar] as! NSArray
            for contact in companyArr {
                let contactModel:LocalContactModel = contact as! LocalContactModel
                if NSString.getSeacrhAttendeeNumber(number) == NSString.getSeacrhAttendeeNumber(contactModel.number){
                    contactModel.isSelected = isSelect
                    //刷新TableView
//                    searchTableView.reloadData()
                    return
                }
            }
        }
    }
    
    //计算收藏联系人 第一次进入时5调数据时 需要的section 个数  和分别的  row 个数
    private func caculateSectionCountAndRowsCount() -> (Int,[Int]) {
        
        if collectionContactDictionary.count == 0 || firstCharactorArr.count == 0 {
            return (0,[])
        }

        //计算收藏联系人总个数是否大于5
        var sesionCount = 0
        var count = 0
        var rowsCounts: [Int] = []
        for char in firstCharactorArr {
            sesionCount += 1
            count += (collectionContactDictionary[char] as! [LdapContactInfo]).count
            
            if count < 5 {
                rowsCounts.append((collectionContactDictionary[char] as! [LdapContactInfo]).count)
            }
            
            if count == 5 {
                rowsCounts.append((collectionContactDictionary[char] as! [LdapContactInfo]).count + 1)
                return (sesionCount,rowsCounts)
            }
            
            if count > 5 {
                rowsCounts.count > 0 ?  rowsCounts.append(count - 5 + 1) : rowsCounts.append(6)
                return (sesionCount,rowsCounts)
            }
        }
        return (sesionCount,rowsCounts)
    }
}

// MARK: 搜索旁边的CollectionView
extension SearchAttendeeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func loadCollectionView() {
        // 刷新
        CollectionView.reloadData()
        //横竖屏切换时collectionView不显示
        // collectionView和Textfield偏移
        if addAttendeeArr.count == 1 {
            let Attendee = addAttendeeArr[0]
            let Size = sizeWithText(text: Attendee.name! as NSString, font: UIFont.systemFont(ofSize: 14), size: UIScreen.main.bounds.size)
            if Size.width+20+8 > SCREEN_WIDTH-120 {
                SearchbackLeft.constant = SCREEN_WIDTH-120
                CollectionView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH-120, height: 63)
            }else{
                SearchbackLeft.constant = Size.width+20+8
                CollectionView.frame = CGRect(x: 0, y: 0, width: Size.width+20+8, height: 63)
            }
        }else if addAttendeeArr.count > 1 {
            if CollectionView.collectionViewLayout.collectionViewContentSize.width < (SCREEN_WIDTH-120) {
                CollectionView.frame = CGRect(x: 0, y: 0, width: CollectionView.collectionViewLayout.collectionViewContentSize.width, height: 63)
                SearchbackLeft.constant = CollectionView.collectionViewLayout.collectionViewContentSize.width
            }else{
                CollectionView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH-120, height: 63)
                SearchbackLeft.constant = SCREEN_WIDTH-120
                CollectionView.scrollToItem(at: IndexPath.init(row: addAttendeeArr.count-1, section: 0), at: UICollectionView.ScrollPosition.right, animated: true)
            }
        }else{
            SearchbackLeft.constant = 0
            CollectionView.frame = CGRect(x: 0, y: 0, width: 0, height: 63)
        }
        CollectionView.layoutIfNeeded()
        searchBackView.layoutIfNeeded()
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addAttendeeArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemModel = addAttendeeArr[indexPath.item]
        let Size = sizeWithText(text: itemModel.name! as NSString, font: UIFont.systemFont(ofSize: 14), size: UIScreen.main.bounds.size)
        return CGSize(width: Size.width+20, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchAttendeeItemCollectionViewCell.CELL_ID, for: indexPath) as! SearchAttendeeItemCollectionViewCell
        let itemModel = addAttendeeArr[indexPath.item]
        cell.SearchTextLabel.text = itemModel.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isFromPreMeeting && indexPath.row == 0 {
            return
        }
        
        // 需要移除的对象
        let Attend:LdapContactInfo = addAttendeeArr[indexPath.row]
        addAttendeeArr.remove(at: indexPath.item)
        // 当前是搜索状态则处理搜索问题
        if isSearch {
            
            if companyContactArray.count > 0 {
                for att in self.companyContactArray {
                    let curatt:LdapContactInfo = att as! LdapContactInfo
                    
                    
                    if NSString.getSeacrhAttendeeNumber(Attend.number) == NSString.getSeacrhAttendeeNumber(curatt.ucAcc){
                        curatt.isSelected = false
                        break
                    }
                }
            }
            
            if localContactArray.count > 0 {
                for att in self.localContactArray {
                    let curatt:LocalContactModel = att as! LocalContactModel
                    if NSString.getSeacrhAttendeeNumber(Attend.number) == NSString.getSeacrhAttendeeNumber(curatt.number) {
                        curatt.isSelected = false
                        break
                    }
                }
            }
        }
        
        // 处理企业联系人和本地联系人
        reloadDataCompanyDictionary(Attend.name, Attend.number, false)
        reloadDataLocalDictionary(Attend.name, Attend.number, false)
        
        // 底部完成
        self.updateCompleteBtn()
        loadCollectionView()
        CATransaction.setDisableActions(false)
        self.searchTableView.reloadData()
        CATransaction.commit()
    }
}

