//
// AddLocalContactViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

enum LocalContactType {
    case addContact // 添加联系人
    case editContact  //编辑联系人
}

typealias EditCallBackBlock = (_ editModel:LocalContactModel) -> Void

class AddLocalContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TextTitleViewDelegate, TableNameFieldCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var editBackBlock:EditCallBackBlock?
    
    var operationType: LocalContactType?
    
    var editModel:LocalContactModel?
    
    var dataMutableDict : NSMutableDictionary!
    
    var model = LocalContactModel.init()
    
    var oldNumber = ""  // 备份终端号码
    
    fileprivate var isHavePhone = false // 是否有手机
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // 初始化
        self.title = (operationType == .addContact) ? tr("添加联系人"):tr("编辑联系人")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.saveButton.setTitle(tr("保存"), for: .normal)
        
        // table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.black)
        self.tableView.allowsSelection = false
        self.tableView.register(UINib.init(nibName: TableNameFieldCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableNameFieldCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableImageNameFieldCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageNameFieldCell.CELL_ID)
        // 去分割线
        self.tableView.separatorStyle = .none
        self.saveButton.addTarget(self,action:#selector(self.saveLocalContact), for: .touchUpInside)
        if operationType == .editContact{
            model = editModel!
            oldNumber = model.number ?? ""
        }else{
            model.campany = ""
            model.depart = ""
            model.eMail = ""
            model.post = ""
            model.remark = ""
            model.address = ""
            model.mobile = ""
        }
        
        //编辑联系人
        if operationType == .editContact{
            saveButton.isEnabled = true
            saveButton.backgroundColor = UIColor(hexString: "0D94FF")
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        let len = (nowString as NSString).convertToInt()
        print("length: \(len)")
        
        if textField.tag == 1{ //姓名
            if len > 192 {
                return false
            } else {
                model.name = nowString
            }
        }
        if textField.tag == 2{
            if len > 127 {
                return false
            }else {
                model.number = nowString
            }
        }
        if textField.tag == 3{
            model.campany = nowString
        }
        if textField.tag == 4{
            if len > 128 {
                return false
            } else {
                model.depart = nowString
            }
        }
        if textField.tag == 5{
            if len > 20 {
                return false
            } else {
                model.post = nowString
            }
        }
        if textField.tag == 6{
            if len > 128 {
                return false
            } else {
                model.eMail = nowString
            }
        }
        if textField.tag == 7{
            model.address = nowString
        }
        if textField.tag == 8{
            model.remark = nowString
        }
        if textField.tag == 11{
            if len > 20 {
                return false
            } else {
                model.mobile = nowString
            }
        }
        if textField.tag == 12 {
            if len > 20 {
                return false
            } else {
                model.post = nowString//代替个人会议id
            }
        }
        
        if operationType == .addContact{
            //保存按钮状态
            if model.name?.count ?? 0 > 0 && model.number?.count ?? 0 > 0 {
                saveButton.isEnabled = true
                saveButton.backgroundColor = UIColor(hexString: "0D94FF")
            }else{
                saveButton.isEnabled = false
                saveButton.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "CCCCCC"), darkColor: UIColor(hexString: "333333"))
            }
        }else{
            saveButton.isEnabled = true
            saveButton.backgroundColor = UIColor(hexString: "0D94FF")
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.clear)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)),name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyBoardWillHide(notification:)),name:UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    @objc func keyBoardWillShow(notification: NSNotification){
        let keyBoardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        self.tableView.contentInset = UIEdgeInsets(top: 0,left: 0, bottom: (keyBoardRect?.size.height)! - self.saveButton.frame.size.height,right: 0)
    }
    
    @objc func keyBoardWillHide(notification: NSNotification){
        self.tableView.contentInset = UIEdgeInsets.zero
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        if operationType == .addContact{
            if model.name?.count ?? 0 > 0 && model.number?.count ?? 0 > 0 {
                let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
                alertTitleVC.modalTransitionStyle = .crossDissolve
                alertTitleVC.modalPresentationStyle = .overFullScreen
                
                alertTitleVC.customDelegate = self
                self.present(alertTitleVC, animated: true, completion: nil)
            }else{
                navigationController?.popViewController(animated: true)
            }
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func saveLocalContact(){
        
        self.view.endEditing(true)
        if model.name == nil || model.name == ""{
            MBProgressHUD.showBottom(tr("姓名不能为空"), icon: nil, view: self.view)
            return
        }
        if model.name!.count > 128{
            MBProgressHUD.showBottom(tr("姓名长度超长"), icon: nil, view: self.view)
            return
        }
        model.firstCharactor = model.getFirstCharactor(name:model.name!)
        
        
        if model.number == nil || model.number == ""{
            MBProgressHUD.showBottom(tr("请输入终端号码"), icon: nil, view: self.view)
            return
        }
        
        if model.eMail != nil && model.eMail!.count > 0 {
//            let reg3 = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
//            let pre3 = NSPredicate(format: "SELF MATCHES %@", reg3)
//            if !pre3.evaluate(with: model.eMail) {
            if !(model.eMail! as NSString).validateEmail() {
                MBProgressHUD.showBottom(tr("邮箱格式不正确"), icon: nil, view: self.view)
                return
            }
        }else{
            model.eMail = ""
        }
        model.type = 1
        model.fax = ""
        print(model)
        
        
        
        if operationType == .editContact {

            if let number = model.number, number == self.oldNumber {
                self.updateLocalContact()
            } else {
                LocalContactBusiness.shareInstance.selectLocalContact(number: model.number ?? " ") { [weak self] (models) in
                    guard let self = self else {return}
                    if models.count > 0 {
                        MBProgressHUD.showBottom(tr("该终端号已存在"), icon: nil, view: self.view)
                        return
                    }else{
                        self.updateLocalContact()
                    }
                }
            }
            
        }else{
            //校验是否已经存在此帐号 添加联系人
            LocalContactBusiness.shareInstance.selectLocalContact(number: model.number ?? " ") { [weak self] (models) in
                guard let self = self else {return}
                if models.count > 0 {
                    MBProgressHUD.showBottom(tr("终端号已存在"), icon: nil, view: self.view)
                    return
                }else{
                    LocalContactBusiness.shareInstance.insertLocalContact(localContactModel: self.model) { (reslut) in
                        if reslut{
                            MBProgressHUD.showBottom(tr("保存成功"), icon: nil, view: nil)
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            MBProgressHUD.showBottom(tr("保存失败"), icon: nil, view: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        
    }
    
    func updateLocalContact() {
        // 编辑联系人
        LocalContactBusiness.shareInstance.updateLocalContact(localContactModel: self.model) { [weak self] (reslut) in
            guard let self = self else {return}
            if reslut{
                MBProgressHUD.showBottom(tr("保存成功"), icon: nil, view: nil)
                self.editBackBlock?(self.model)
                self.navigationController?.popViewController(animated: true)
            }else{
                MBProgressHUD.showBottom(tr("保存失败"), icon: nil, view: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setViewUI() {
        
    }
    
    // MARK: - TextTitleViewDelegate
    // MARK: view did load
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        viewVC.showTitleLabel.text = tr("是否保存联系人?")
        viewVC.showLeftBtn.setTitle(tr("不保存"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("保存"), for: .normal)
    }
    
    // MARK: left btn click
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right btn click
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        saveLocalContact()
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed(TableNameFieldCell.CELL_ID, owner: self, options: nil)?.last as! TableNameFieldCell
        cell.cellDelegate = self
        
        if indexPath.section == 0 {
            cell.showTitleLabel.text = tr("姓名")
            cell.showInputTextField.placeholder = tr("请输入姓名(必填)")
            cell.showInputTextField.tag = 1
            cell.showInputTextField.text = model.name
        }
        if indexPath.section == 2{
            cell.showTitleLabel.text = tr("终端号码")
            cell.showInputTextField.placeholder = tr("请输入终端号码(必填)")
            //            cell.showInputTextField.keyboardType = .numberPad
            cell.showInputTextField.tag = 2
            cell.showInputTextField.text = model.number
        }
        if indexPath.section == 1{
            cell.showTitleLabel.text = tr("部门")
            cell.showInputTextField.placeholder = tr("请输入部门")
            cell.showInputTextField.tag = 4
            cell.showInputTextField.text = model.depart
        }
        if indexPath.section == 3{
            cell.showTitleLabel.text = tr("个人会议ID")
            cell.showInputTextField.placeholder = tr("请输入个人会议ID")
            cell.showInputTextField.tag = 12
            cell.showInputTextField.keyboardType = .numberPad
            cell.showInputTextField.text = model.post//暂代会议id
        }
        if indexPath.section == 4{
            cell.showTitleLabel.text = tr("手机号码")
            cell.showInputTextField.placeholder = tr("请输入手机号码")
            cell.showInputTextField.tag = 11
            cell.showInputTextField.keyboardType = .numberPad
            cell.showInputTextField.text = model.mobile
        }
        if indexPath.section == 5{
            cell.showTitleLabel.text = tr("邮箱")
            cell.showInputTextField.placeholder = tr("请输入邮箱")
            cell.showInputTextField.tag = 6
            cell.showInputTextField.text = model.eMail
        }
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableNameFieldCell.CELL_HEIGHT
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // CELL ImageView Add click
    @objc func cellAddImageViewClick(sender: UITapGestureRecognizer) {
        isHavePhone = true
        self.tableView.reloadSections(IndexSet.init(integer: 1), with: UITableView.RowAnimation.automatic)
    }
    
    // CELL ImageView Del click
    @objc func cellDelImageViewClick(sender: UITapGestureRecognizer) {
        isHavePhone = false
        self.tableView.reloadSections(IndexSet.init(integer: 1), with: UITableView.RowAnimation.automatic)
        model.mobile = ""
    }
    
}

extension AddLocalContactViewController {
    func isIPAddressText(text:String) -> Bool {
        if text.components(separatedBy: ".").count != 4 {
            return false
        }else{
            let reg = "^(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])$"
            let pre2 = NSPredicate(format: "SELF MATCHES %@", reg)
            return pre2.evaluate(with: text)
        }
    }
    
    func isNumberText(number:String) -> Bool {
        let reg = "^[0-9]+$"
        let pre2 = NSPredicate(format: "SELF MATCHES %@", reg)
        return pre2.evaluate(with: number)
    }
}
