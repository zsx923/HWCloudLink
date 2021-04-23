//
//  LocalVMRInfoManager.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2021/1/20.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit
/*
 3.0 本地vmr设置，主席密码，来宾密码开关状态，关闭是否显示弹窗提醒功能
 */
class LocalVMRInfoManager {
    
    let userAccount: String = ""
   
    static func getUserAccount() -> String {
        if let userAccount = NSObject.getUserDefaultValue(withKey: DICT_SAVE_LOGIN_userName) as? String {
            return userAccount
        }
        return ""
    }
    //获取主席密码开关状态
    static func getChairmanPwdStatus() -> Bool {
        let account = self.getUserAccount() + "chairmanStatus"
       return  UserDefaults.standard.bool(forKey: account)
    }
    //获取来宾密码开关状态
    static func getGeneralPwdStatus() -> Bool {
        let  account = self.getUserAccount() + "generalStatus"
        return UserDefaults.standard.bool(forKey: account)
    }
    //获取关闭主席密码是否显示弹窗状态
    static func getChainManPwdAlertViewStatus() -> Bool {
        let chairmanView = self.getUserAccount() + "ChairmandisplayAlertView"
        return UserDefaults.standard.bool(forKey: chairmanView)
    }
    //获取关闭来宾密码是否显示弹窗状态
    static func getGeneralPwdAlertViewStatus() -> Bool {
        let generalView = self.getUserAccount() + "GeneraldisplayAlertView"
        return UserDefaults.standard.bool(forKey: generalView)
    }
    //更新主席密码开关状态
    static func updateChirmanPwdStatus(status: Bool){
        let account = self.getUserAccount() + "chairmanStatus"
        UserDefaults.standard.setValue(status, forKey: account)
    }
    //更新来宾密码开关状态
    static func updateGeneralPwdStatus(status: Bool){
        let account = self.getUserAccount() + "generalStatus"
        UserDefaults.standard.setValue(status, forKey: account)
    }
    //关闭弹窗提示
    static func updateChairmanPwdAlertViewStatus(){
        let account = self.getUserAccount() + "ChairmandisplayAlertView"
        UserDefaults.standard.setValue(true, forKey: account)
    }
    //关闭弹窗提示
    static func updateGeneralPwdAlertViewStatus(){
        let account = self.getUserAccount() + "GeneraldisplayAlertView"
        UserDefaults.standard.setValue(true, forKey: account)
    }
    
    
}
