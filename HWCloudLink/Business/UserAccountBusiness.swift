//
//  UserAccountBusiness.swift
//  HWCloudLink
//
//  Created by mac on 2020/6/28.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class UserAccountBusiness: NSObject {

    // 单例
    static let shareInstance: UserAccountBusiness = {
        let instance = UserAccountBusiness()
        return instance
    }()
}


extension UserAccountBusiness {
    
    //储存用户登录模型
    func saveUserAccount(frome userAccontModel: UserAccount) {
        
        //检测是否本帐号已经储存
        let hasSave = checkUserAccountHasSave(frome: userAccontModel.user_name!)
        if hasSave { //已经储存
            //删除已经存储的重复帐号
            removeUserAccount(frome: userAccontModel.user_name!)
        }
        
        // 存储到最后一个位置
        if DBManager.shared.openDB() {
            let sql = "insert into " + userAccontModel.user_account_table + "("
                      + "user_name,"
                      + "pass_word)"
                      + "values(?,?)"
            let result = DBManager.shared.database.executeUpdate(sql, withArgumentsIn: [userAccontModel.user_name!, userAccontModel.pass_word!])
            
            if !result{
                print("保存用户帐号失败")
            }
            DBManager.shared.closeDB()
        }
    }
    
    //获取所有的用户登录模型
    func getUserAccounts() -> [UserAccount] {
        
        var alluserAccont: [UserAccount] = []
        if DBManager.shared.openDB() {
            
            let sql = "select "  + "user_name," + "pass_word" + " from user_account_table"
            
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = UserAccount()
                    model.user_account_id = Int(results.int(forColumn: "user_account_id"))
                    model.user_name = results.string(forColumn: "user_name")
                    model.pass_word = results.string(forColumn: "pass_word")
                    alluserAccont.append(model)
                }
            }catch{
                print("查询用户帐号失败")
            }
            DBManager.shared.closeDB()
        }
        return alluserAccont
    }
    
    //根据登录名查询帐号
    private func getUserAccounts(frome userName: String ) ->[UserAccount] {
        
        var alluserAccont: [UserAccount] = []
        if DBManager.shared.openDB() {
            
            let sql = "select "  + "user_name," + "pass_word" + " where user_name = " + "'" + userName + "'" +  " from user_account_table"
            
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = UserAccount()
                    model.user_account_id = Int(results.int(forColumn: "user_account_id"))
                    model.user_name = results.string(forColumn: "user_name")
                    model.pass_word = results.string(forColumn: "pass_word")
                    alluserAccont.append(model)
                }
            }catch{
                print("查询用户帐号失败")
            }
            DBManager.shared.closeDB()
        }
        return alluserAccont
    }
    
    //删除用户登录模型（超过5个删除最后一个）
    private func removeLastUserAccount()  {
        
        let sql = "delete from " + "user_account_table" + " where user_account_id = " + "'" + "5" + "'"
        let result = DBManager.shared.database.executeUpdate(sql, withArgumentsIn: [])
        if !result{
            print("删除最后一个帐号失败")
        }
        DBManager.shared.closeDB()
    }
    
    //通过用户名删除帐号
    private func removeUserAccount(frome userName: String) {
        let sql = "delete from " + "user_account_table" + " where user_name = " + "'" + userName + "'"
        let result = DBManager.shared.database.executeUpdate(sql, withArgumentsIn: [])
        if !result{
            print("删除固定帐号失败")
        }
        DBManager.shared.closeDB()
    }
    
    //检测帐号是否已经存储，如果存储了， 就排序到第一个
    private func checkUserAccountHasSave(frome userName: String) ->Bool {
        
        if getUserAccounts(frome: userName).count > 0 {
            
            sortUserAccontToFirst(frome: userName)
            
            return true
        }
        return false
    }
    
    private func sortUserAccontToFirst(frome userName: String) {
        
        let sql = "select "  + "user_name," + "pass_word" + " where user_name = " + "'" + userName + "'" +  " from user_account_table"
        print(sql)
    }
}
