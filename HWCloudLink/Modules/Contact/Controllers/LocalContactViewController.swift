//
// LocalContactViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import Contacts

class LocalContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopTitleSubTitleViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataSource: NSMutableDictionary?
    fileprivate var contactSource: [CNContact] = []
    fileprivate var sortedLetterKeysArray: [String] = []
    
    fileprivate var firstCharactorArr : [String] = []
    fileprivate var firstCharactorArrTemp : [String] = []
    fileprivate var localContactDictionary = NSMutableDictionary.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = tr("本地通讯录")
        self.setViewUI()
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 查找图标
        let rightBarBtnItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchBarItemClick(sender:)))
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        // table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: TableImageSingleTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageSingleTextCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTextCell.CELL_ID)
        // 去分割线
        self.tableView.separatorStyle = .none
        
        // init data
        self.setInitData()
    }
    
    // search click
    @objc func searchBarItemClick(sender: UIBarButtonItem) {
        let searchVC = CompanySearchViewController()
        searchVC.searchType = .localContact
        //searchVC.dataSource = self.contactSource as NSArray
        
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    // share click
    @IBAction func shareBarBtnItemClick(_ sender: Any) {
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.clear)
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setViewUI() {
        self.dataSource = NSMutableDictionary.init(capacity: 26)
    }
    
    func setInitData() {
        getData()
    }
    
    func getData(){
        LocalContactBusiness.shareInstance.selectFirstCharactor(type: -1) { (arr) in
            self.firstCharactorArr = arr
            var count = 0
            for firstCharactor in arr{
                LocalContactBusiness.shareInstance.selectLocalContactByFirstCharactor(type: -1,firstCharactor: firstCharactor) { (localContactArr) in
                    self.localContactDictionary.setValue(localContactArr, forKey: firstCharactor)
                    count = count + 1
                }
            }
            if arr.count == count{
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.firstCharactorArr.count
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = self.localContactDictionary[self.firstCharactorArr[section]] as! NSArray
        return array.count + 1
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // A-Z
        if indexPath.row == 0 {
            let indexAZCell = tableView.dequeueReusableCell(withIdentifier: TableTextCell.CELL_ID) as! TableTextCell
            
            // set text
            indexAZCell.showTitleLabel.text = self.firstCharactorArr[indexPath.section]
            
            return indexAZCell
        }
        
        let contactArray = self.localContactDictionary[self.firstCharactorArr[indexPath.section]] as! NSArray
        let contact = contactArray[indexPath.row - 1] as! LocalContactModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableImageSingleTextCell.CELL_ID) as! TableImageSingleTextCell
        
        // set image
        cell.showImageView.image = getUserIconWithAZ(name: contact.name!)
        
        // set title
        cell.showTitleLabel.text = contact.name
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contactArray = self.localContactDictionary[self.firstCharactorArr[indexPath.section]] as! NSArray
        if indexPath.row == 0 {
            return
        }
        let contact = contactArray[indexPath.row - 1] as! LocalContactModel
        
        let popTitleVC = PopTitleSubTitleViewController.init(nibName: "PopTitleSubTitleViewController", bundle: nil)
        popTitleVC.modalTransitionStyle = .crossDissolve
        popTitleVC.modalPresentationStyle = .overFullScreen
        
        popTitleVC.customDelegate = self
        popTitleVC.showTitle = contact.name
        popTitleVC.dataSource = []
        if contact.number != nil && contact.number!.count > 0 {
            popTitleVC.dataSource?.append([DICT_TITLE: tr("终端"), DICT_SUB_TITLE: contact.number!, DICT_IS_NEXT: "1"])
        }
        if contact.mobile != nil && contact.mobile!.count > 0 {
            popTitleVC.dataSource?.append([DICT_TITLE: tr("手机"), DICT_SUB_TITLE: contact.mobile!, DICT_IS_NEXT: "1"])
        }
        if contact.campany != nil && contact.campany!.count > 0 {
            popTitleVC.dataSource?.append([DICT_TITLE: tr("公司"), DICT_SUB_TITLE: contact.campany!])
        }
        if contact.depart != nil && contact.depart!.count > 0 {
            popTitleVC.dataSource?.append([DICT_TITLE: tr("职务"), DICT_SUB_TITLE: contact.depart!])
        }
        if contact.eMail != nil && contact.eMail!.count > 0 {
            popTitleVC.dataSource?.append([DICT_TITLE: tr("邮箱"), DICT_SUB_TITLE: contact.eMail!])
        }
        if contact.address != nil && contact.address!.count > 0 {
            popTitleVC.dataSource?.append([DICT_TITLE: tr("地址"), DICT_SUB_TITLE: contact.address!])
        }
        if contact.remark != nil && contact.remark!.count > 0 {
            popTitleVC.dataSource?.append([DICT_TITLE: tr("备注"), DICT_SUB_TITLE: contact.remark!])
        }
        
        popTitleVC.dataSource?.append([DICT_TITLE: tr("取消"), DICT_SUB_TITLE: ""])
       
        self.present(popTitleVC, animated: true, completion: nil)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row == 0 {
            return TableTextCell.CELL_HEIGHT
        }
        
        return TableImageSingleTextCell.CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        if indexPath.row == 0 {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: tr("删除")) { action, index in
              // 删除
              let contactArray = self.localContactDictionary[self.firstCharactorArr[indexPath.section]] as! NSArray
              let contact = contactArray[indexPath.row - 1] as! LocalContactModel
            LocalContactBusiness.shareInstance.deleteLocalContact(id: contact.localContactId!) { (isSuccess) in
                if isSuccess {
                    MBProgressHUD.showBottom(tr("删除成功"), icon: nil, view: self.view)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                        self.getData()
                    }
                } else {
                    MBProgressHUD.showBottom(tr("删除失败"), icon: nil, view: self.view)
                }
            }
          }

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return tr("删除")
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: - PopTitleSubTitleViewDelegate
    // MARK: popTitleSubTitleViewDidLoad
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*** 获取数据列表 */
    // MARK: 获取通讯录数据列表
    func getLocalContactsData() {
        //checkContactAuthorized()
    }

}

extension LocalContactViewController {
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
                    DispatchQueue.main.async {
                        MBProgressHUD.showBottom("授权失败", icon: nil, view: self.view)
                    }
                } else {
                    CLLog("授权成功")
                    DispatchQueue.global().async {
                        self.getContactData()
                    }
                }
            }
        } else {
            DispatchQueue.global().async {
                self.getContactData()
            }
        }
    }
    
    // MARK: get contact data
    func getContactData() {
        DispatchQueue.main.async {
            MBProgressHUD.showMessage("正在获取本地联系人")
        }
        
        self.contactSource.removeAll()
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
//                    CNContactNoteKey,  iOS 13之后禁止获取
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
            try contactStore.enumerateContacts(with: fetch, usingBlock: { (contact, stop) in
                self.contactSource.append(contact)
                // 重新将通讯录进行A-Z分块
                let userName = "\(contact.givenName)\(contact.familyName)"
                let fistLetter = NSString.firstCharactor(userName)
                var arrayContacts = self.dataSource?.object(forKey: fistLetter as Any) as! NSMutableArray?
                if arrayContacts == nil {
                    arrayContacts = NSMutableArray.init()
                    arrayContacts?.add(contact)
                    
                    if arrayContacts!.count > 0 {
                        self.dataSource![fistLetter as Any] = arrayContacts
                    }
                } else {
                    arrayContacts?.add(contact)
                }
            })
            // 排序字典key值
            self.sortedLetterKeysArray = self.dataSource?.allKeys.sorted(by: { (key1, key2) -> Bool in
                let key1Str =  key1 as! String
                let key2Str = key2 as! String
                
                let result =  key1Str.compare(key2Str)
                return result.rawValue < 0
            }) as! [String]

            DispatchQueue.main.async {
                self.tableView.reloadData()
                MBProgressHUD.hide()
            }
        } catch let error as NSError {
            CLLog(error)
        }
    }
}
