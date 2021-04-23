//
//  UserSettingBusiness.swift
//  HWCloudLink
//
//  Created by JYF on 2020/7/22.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class UserSettingBusiness {
    static let shareInstance: UserSettingBusiness = {
        let instance = UserSettingBusiness()
        return instance
    }()
    
    func saveUserSetting(complete:((Bool) ->Void)?) {
        selectUserSetting { (settingArray) in
            if settingArray.count == 0 {
                self.insertContactSetting(settingModel: self.installUserSettingModel()) { (res) in
                    complete?(res)
                }
            } else{
                complete?(true)
            }
        }
    }
    
    func getUserVideoPolicy() -> Int {
        var videoPolicy = 2
        selectUserSetting { (settingArray) in
            if settingArray.count > 0 {
                let model = settingArray[0]
                videoPolicy =  model.videpDefinitionPolicy
            }
        }
        return videoPolicy
    }
    
    func updateUserSettingVideoPolicy(videpDefinitionPolicy:Int, complete: ((Bool) -> Void)?) {
        if DBManager.shared.openDB(){
            let sql = "update user_setting_table set videpDefinitionPolicy = '" + String(videpDefinitionPolicy) + "'where self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'"
            do{
                let results = try DBManager.shared.database!.executeUpdate(sql, withArgumentsIn: [])
                    complete?(results)
            } catch {
                CLLogError("更新用户配置信息失败")
            }
            DBManager.shared.closeDB()
        }
    }
    private func installUserSettingModel() -> UserSettingModel {
        let settingModel = UserSettingModel.init()
        settingModel.userAccount = ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? ""
        return settingModel
   
    }
    
    private func insertContactSetting(settingModel:UserSettingModel,complete:((Bool) ->Void)?) {
        if DBManager.shared.openDB(){
            let sql = "insert into " + settingModel.sqlTabelName + "("
            + "self_account,"
            + "videpDefinitionPolicy,"
            + "logUploadIsOn,"
            + "languageSwitch,"
            + "micIsOpen,"
            + "videoIsOpen,"
            + "shakeIsOpen,"
            + "ringIsOpen,"
            + "remark1,"
            + "remark2,"
            + "remark3,"
            + "remark4)"
            + "values(?,?,?,?,?,?,?,?,?,?,?,?)"
            let res = DBManager.shared.database.executeUpdate(sql, withArgumentsIn:[
                    settingModel.userAccount,
                    settingModel.videpDefinitionPolicy,
                    settingModel.logUploadIsOn,
                    settingModel.languageSwitch,
                    settingModel.micIsOpen,
                    settingModel.videoIsOpen,
                    settingModel.shakeIsOpen,
                    settingModel.ringIsOpen,
                    settingModel.remark1,
                    settingModel.remark2,
                    settingModel.remark3,
                    settingModel.remark4])
            if !res{
                CLLogError("用户配置信息保存失败")
            }
            complete?(res)
                DBManager.shared.closeDB()
        }
    }
    private func selectUserSetting(complete: (([UserSettingModel]) -> Void)?){
        if DBManager.shared.openDB(){
            let sql = "select "
            + "self_account,"
            + "videpDefinitionPolicy,"
            + "logUploadIsOn,"
            + "languageSwitch,"
            + "micIsOpen,"
            + "videoIsOpen,"
            + "shakeIsOpen,"
            + "ringIsOpen,"
            + "remark1,"
            + "remark2,"
            + "remark3,"
            + "remark4 from user_setting_table where self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'"
            var usersettintModelArray: [UserSettingModel] = []
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = UserSettingModel()
                    model.userAccount = results.string(forColumn: "self_account") ?? ""
                    model.videpDefinitionPolicy = Int(results.longLongInt(forColumn: "videpDefinitionPolicy"))
                    model.logUploadIsOn = Int(results.longLongInt(forColumn: "logUploadIsOn"))
                    model.languageSwitch = results.string(forColumn: "languageSwitch") ?? ""
                    model.micIsOpen = Int(results.longLongInt(forColumn: "micIsOpen"))
                    model.videoIsOpen = Int(results.longLongInt(forColumn: "videoIsOpen"))
                    model.shakeIsOpen = Int(results.longLongInt(forColumn: "shakeIsOpen"))
                    model.ringIsOpen = Int(results.longLongInt(forColumn: "ringIsOpen"))
                    model.remark1 = results.string(forColumn: "remark1") ?? ""
                    model.remark2 = results.string(forColumn: "remark2") ?? ""
                    model.remark3 = results.string(forColumn: "remark3") ?? ""
                    model.remark4 = results.string(forColumn: "remark4") ?? ""
                    usersettintModelArray.append(model)
                }
            } catch {
                CLLogError("查询用户配置信息失败")
            }
            complete?(usersettintModelArray)
            DBManager.shared.closeDB()
        }
    }
}


