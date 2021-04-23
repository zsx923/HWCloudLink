//
//  HistoryAccounts.swift
//  HWCloudLink
//
//  Created by cos on 2021/1/13.
//  Copyright © 2021 陈帆. All rights reserved.
//  add at xuegd: 历史账号数据处理

import Foundation

class HistoryAccounts {
    // 本地账号信息
    fileprivate static var localInfo = UserDefaults.standard.dictionary(forKey: "LOGIN_HISTORY_ACCOUNTS")
    // 账号
    fileprivate static var localAccounts = localInfo?["accounts"] as? Array<String> ?? []
    // 账号: 密码
    fileprivate static var localAccountsInfo = localInfo?["accountsInfo"] as? Dictionary ?? [:]

    // 加密的Key
    fileprivate static let encryptKey = "hwcloudlink"
    
    /// 获取所有账号信息
    /// - Returns: 所有账号信息[String]
    static func all() -> Array<String> {
        var accounts : Array<String> = []
        for item in localAccounts {
            let itemNS = item as NSString
            accounts.append(itemNS.aes256_decrypt(encryptKey) as String)
        }
        CLLog("History Accounts: get all history accounts success, count is: \(accounts.count).")
        return accounts
    }
    
    /// 添加账号
    /// - Parameter user: 用户信息<LoginInfo>
    static func addAcount(user: LoginInfo) {
        if user.password == nil || user.password == "" {
            CLLog("History Accounts: save history account, password is nil.")
            return
        }
        if user.account == nil || user.account == "" {
            CLLog("History Accounts: save history account, account is nil.")
            return
        }
        // 加密
        let accountNS = user.account as NSString
        let passwordNS = user.password as NSString
        let accountEncrypt = accountNS.aes256_encrypt(encryptKey) as String
        let passwordEncrypt = passwordNS.aes256_encrypt(encryptKey) as String
        // 去重
        if localAccounts.contains(accountEncrypt) {
            for (index, str) in localAccounts.enumerated() {
                if str == accountEncrypt {
                    localAccounts.remove(at: index)
                }
            }
        }
        localAccounts.insert(accountEncrypt, at: 0)
        localAccountsInfo.updateValue(passwordEncrypt, forKey: accountEncrypt)
        // 存储
        HistoryAccounts.updateUserDefaults()
        CLLog("History Accounts: save history account to local success.")
    }

    /// 重置账号：密码
    /// - Parameter user: 用户信息<LoginInfo>
    static func setPassword(account: String, password: String) {
        // 加密
        let accountNS = account as NSString
        let passwordNS = password as NSString
        let accountEncrypt = accountNS.aes256_encrypt(encryptKey) as String
        if password != "" {
            let passwordEncrypt = passwordNS.aes256_encrypt(encryptKey) as String
            localAccountsInfo.updateValue(passwordEncrypt, forKey: accountEncrypt)
        } else {
            localAccountsInfo.updateValue("", forKey: accountEncrypt)
        }
        // 存储
        HistoryAccounts.updateUserDefaults()
        CLLog("History Accounts: set history account password success.")
    }

    /// 获取用户密码
    /// - Parameter account: 账号<String>
    /// - Returns: 密码<String>
    static func getPassword(account: String) -> String {
        if account == "" { return "" }
        let localAccountsInfo = localInfo?["accountsInfo"] as? Dictionary ?? [:]
        // 密文读取
        let accountNS = account as NSString
        let accountKey = accountNS.aes256_encrypt(encryptKey) as String
        let passwordNS = localAccountsInfo[accountKey] as? String ?? ""
        if passwordNS == "" { return "" }
        let password = passwordNS.aes256_decrypt(encryptKey) as String
        CLLog("Get history account password success.")
        return password
    }
    
    /// 删除本地账号
    /// - Parameter account: 账号<String>
    static func deleteAccount(account: String) {
        // 加密
        let accountNS = account as NSString
        let accountEncrypt = accountNS.aes256_encrypt(encryptKey) as String
        localAccounts.removeAll{$0 == accountEncrypt}
        localAccountsInfo.removeValue(forKey: accountEncrypt)
        // 存储
        HistoryAccounts.updateUserDefaults()
        CLLog("Delete history account success.")
    }
    
    /// 更新本地历史账号数据
    static func updateUserDefaults() {
        let info : Dictionary = [
            "accounts" : localAccounts,
            "accountsInfo" : localAccountsInfo
        ] as [String : Any]
        HistoryAccounts.localInfo = info
        UserDefaults.standard.setValue(info, forKey: "LOGIN_HISTORY_ACCOUNTS")
        UserDefaults.standard.synchronize()
    }
    
    
    
    /// 当前是否自动登录
    /// - Returns: Bool
    static func isAutoLogin() -> Bool {
        if HistoryAccounts.all().count > 0 {
            return HistoryAccounts.getPassword(account: HistoryAccounts.all()[0]) != ""
        } else {
            return false
        }
    }
}
