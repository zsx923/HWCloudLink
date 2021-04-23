//
//  HWLoginInfoManager.swift
//  HWCloudLink
//
//  Created by Jabien on 2020/9/24.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

typealias getLoginInfoBlock = (_ name: String)-> Void

class HWLoginInfoManager: NSObject,TUPContactServiceDelegate {
    
    static let shareInstance = HWLoginInfoManager.init()
    
    var getLoginInfoBack: getLoginInfoBlock!
    
    // 是否保存名字
    func isSuccessGetName() -> Bool {
        if ((UserDefaults.standard.object(forKey: DICT_SAVE_NIC_NAME) as? String) == "") || (UserDefaults.standard.object(forKey: DICT_SAVE_NIC_NAME) == nil) {
            return false
        }
        return true
    }
    
    // MARK: 企业通讯录查询自己的name
    func getLoginInfoByCorporateDirectory()  {
        if !isSuccessGetName() {
            ManagerService.contactService()?.delegate = self
            let search = SearchParam.init()
            search.keywords = ManagerService.call()?.terminal
            search.curentBaseDn = ""
            search.sortAttribute = ""
            search.searchSingleLevel = 0
            search.pageSize = 1000
            search.cookieLength = 0
            search.pageCookie = nil
            ManagerService.contactService()?.searchLdapContact(with: search)
        }
    }
        
    // MARK: TUPContactServiceDelegate
    func contactEventCallback(_ contactEvent: TUP_CONTACT_EVENT_TYPE, result resultDictionary: [AnyHashable : Any]!) {
        if contactEvent == CONTACT_E_SEARCH_LDAP_CONTACT_RESULT {
            let res = resultDictionary[TUP_CONTACT_EVENT_RESULT_KEY] as! Bool
            if !res{
                CLLog("Search ldap contact failed!")
            }
            let contactList = resultDictionary[TUP_CONTACT_KEY] as! [LdapContactInfo];
            print("contactList count =",contactList.count)
            if contactList.count == 0 {
                CLLog("contactList Empty")
                return
            }
            //遍历所搜索到的所有数据
            for searcher in contactList {
                // change at xuegd: 处理终端号码含有域后缀，匹配不到的问题，如: @域名、@ip地址
                if searcher.ucAcc == ManagerService.call()?.terminal {
                    CLLog("Search user ldap success!，\(String(describing: NSString.encryptNumber(with: searcher.name)))")
                    UserDefaults.standard.set(searcher.name, forKey: DICT_SAVE_NIC_NAME)
                    ManagerService.call()?.ldapContactInfo = searcher
                    ManagerService.call()?.setTerminalLocalName(searcher.name)
                    CLLog("set user ldap success!")
                    self.getLoginInfoBack?(searcher.name)
                    ManagerService.loginService()?.setLoginInfoWithUserName(searcher.name)
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name.init(LOGIN_GET_USER_INFO_SUCCESS_KEY), object: nil)
                    }
                    return
                }
            }
        }
    }
    
    
    /// 弹出字符串提示Alert窗口
    /// - Parameters:
    ///   - title: 标题
    ///   - titleBtn: 按钮文字
    static func showMessageSingleBtnAlert(title: String, titleBtn: String) {
        let currentVC = ViewControllerUtil.getCurrentViewController()
        let alertTitleVC = TextTitleSingleBtnViewController()
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        
        alertTitleVC.title = title
        
        alertTitleVC.viewDidLoadClosure = { [weak alertTitleVC] () -> Void in
            if (alertTitleVC != nil && alertTitleVC?.showTitleLabel != nil) {
                alertTitleVC?.showTitleLabel.text = tr(title)
                alertTitleVC?.showSureBtn.setTitle(tr(titleBtn), for: UIControl.State.normal)
            }
        }
        currentVC.present(alertTitleVC, animated: true, completion: nil)
    }
    
    
    /// 检查SMC3.0的密码是否过期并提示
    static func checkPasswordExpireShowToast(view: UIView?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            guard let isSmc3 = ManagerService.call()?.isSMC3, let pwdExpireDay = ManagerService.loginService()?.passwordExpire else {
                CLLog("isSmc3 object is nil")
                return
            }
            if isSmc3 {
                guard let pwdExpireDayNum = Int32(pwdExpireDay) else { return }
                switch pwdExpireDayNum {
                case 0:
                    MBProgressHUD.showBottom(tr("密码过期"), icon: nil, view: view)
                case _ where pwdExpireDayNum != 255:
                    MBProgressHUD.showBottom(isCNlanguage() ? "密码有效期剩余\(pwdExpireDayNum)天，请重新修改密码" : "The password will expire in \(pwdExpireDayNum) days", icon: nil, view: view)
                default: break
                }
            }
        }
    }
    
    /// 设置TextField逐个删除（在shouldChangeCharactersIn代理方法中调用）
    /// - Parameters:
    ///   - textField: TextField
    ///   - globalStr: 全局保存字符串
    ///   - string: 当前获取字符串
    ///   - range: 范围
    /// - Returns: 是否继续输入
    static func setTextFieldDeleteOneByOne(textField: UITextField,
                                           globalStr: inout String,
                                           string: String,
                                           range: NSRange) -> Bool {
        // 逐个删除
        let textFieldContent = textField.text as NSString?
        let textfieldContent2 = textFieldContent?.replacingCharacters(in: range, with: string)
        
        textField.text = textfieldContent2;
        let start = textField.position(from:textField.beginningOfDocument, offset: string == "" ? range.location : range.location+1)
        let end = textField.position(from: start!, offset: 0)
        textField.selectedTextRange = textField.textRange(from: start!, to: end!)
        globalStr = textField.text!
        
        return false
    }
}

