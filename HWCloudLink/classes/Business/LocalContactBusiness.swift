//
//  LocalContactBusiness.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/23.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class LocalContactBusiness: NSObject {
    // 单例
    static let shareInstance: LocalContactBusiness = {
        let instance = LocalContactBusiness()
        return instance
    }()
}

extension LocalContactBusiness{
    
//    //本地通讯录更新
//    func updateLocalContact(localContactModel:LocalContactModel, complete: ((Bool) -> Void)?) {
//        if DBManager.shared.openDB(){
//            let sql = "update cl_local_contact set name=?,first_charactor=?,number=?,campany=?,depart=?,post=?,mobile=?,fax=?,e_mail=?,address=?,type=?,remark=? where number=?"
//            let res = DBManager.shared.database.executeUpdate(sql, withArgumentsIn:[
//                  localContactModel.name,
//                  localContactModel.firstCharactor,
//                  localContactModel.number,
//                  localContactModel.campany,
//                  localContactModel.depart,
//                  localContactModel.post,
//                  localContactModel.mobile,
//                  localContactModel.fax,
//                  localContactModel.eMail,
//                  localContactModel.address,
//                  localContactModel.type,localContactModel.remark,localContactModel.number])
//            if !res{
//                print("本地联系人保存失败")
//            }
//            complete?(res)
//            DBManager.shared.closeDB()
//        }
//    }
//
    //本地通讯录更新
    func updateLocalContact(localContactModel:LocalContactModel, complete: ((Bool) -> Void)?) {
        if DBManager.shared.openDB(){
            let sql = "update cl_local_contact set name=?, number=?, post=?, mobile=?, e_mail=?, depart=?   where local_contact_id=?"
            let res = DBManager.shared.database.executeUpdate(sql, withArgumentsIn:[
                                                                localContactModel.name, localContactModel.number,localContactModel.post,localContactModel.mobile, localContactModel.eMail, localContactModel.depart, localContactModel.localContactId])
            if !res{
                print("本地联系人保存失败")
            }
            complete?(res)
            DBManager.shared.closeDB()
        }
    }
    
    func insertLocalContact(selfAccont:String = (ManagerService.loginService()?.obtainCurrentLoginInfo()?.account)!, localContactModel:LocalContactModel,complete:((Bool) ->Void)?) {
        
        if localContactModel.post == nil { localContactModel.post = "" }
        if localContactModel.address == nil { localContactModel.address = "" }
        if localContactModel.remark == nil { localContactModel.remark = "" }
//        if localContactModel.post == nil { localContactModel.post = "" }
        
        if DBManager.shared.openDB(){
            let sql = "insert into " + localContactModel.sqlTabelName + "("
            + "nameForPinYin,"
            + "self_account,"
            + "name,"
            + "first_charactor,"
            + "number,"
            + "campany,"
            + "depart,"
            + "post,"
            + "mobile,"
            + "fax,"
            + "e_mail,"
            + "address,"
            + "type,"
            + "remark)"
            + "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            let res = DBManager.shared.database.executeUpdate(sql, withArgumentsIn:[
                  transChineseToPinYin(from: localContactModel.name),
                  selfAccont,
                  localContactModel.name,
                  localContactModel.firstCharactor,
                  localContactModel.number,
                  localContactModel.campany,
                  localContactModel.depart,
                  localContactModel.post,
                  localContactModel.mobile,
                  localContactModel.fax,
                  localContactModel.eMail,
                  localContactModel.address,
                  localContactModel.type,
                  localContactModel.remark])
            if !res{
                print("本地联系人保存失败")
            }
            complete?(res)
            DBManager.shared.closeDB()
        }
    }
    
    //本地通讯录
    func selectLocalContact(localContactModel:LocalContactModel,complete: (([LocalContactModel]) -> Void)?){
        if DBManager.shared.openDB(){
            var localContactModelArray: [LocalContactModel] = []
            var sql = "select "
            + "self_account,"
            + "local_contact_id,"
            + "name,"
            + "first_charactor,"
            + "number,"
            + "campany,"
            + "mobile,"
            + "fax,"
            + "depart,"
            + "post,"
            + "e_mail,"
            + "address,"
            + "type,"
            + "remark,"
            + "create_time from "
            + localContactModel.sqlTabelName
            + " where self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'" + " and" + " 1 = 1 "
            if (localContactModel.searchWord != nil || localContactModel.searchWord != "") && localContactModel.searchWord != "*" && localContactModel.searchWord != " " {
                sql = sql + " and (name like '%" + localContactModel.searchWord! + "%'" + " or number like '%" + localContactModel.searchWord! + "%'" + " or nameForPinYin like '%" + localContactModel.searchWord! + "%')"
            }
            
            if localContactModel.searchWord != "*" && localContactModel.searchWord != " " {
                sql = sql + " order by local_contact_id desc limit " + String(localContactModel.page) + "," + String(localContactModel.limit)
            }
            
            
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = LocalContactModel()
                    model.localContactId = Int(results.longLongInt(forColumn: "local_contact_id"))
                    model.name = results.string(forColumn: "name")
                    model.firstCharactor = results.string(forColumn: "first_charactor") 
                    model.number = results.string(forColumn: "number")
                    model.campany = results.string(forColumn: "campany")
                    model.depart = results.string(forColumn: "depart")
                    model.mobile = results.string(forColumn: "mobile")
                    model.fax = results.string(forColumn: "fax")
                    model.post = results.string(forColumn: "post")
                    model.eMail = results.string(forColumn: "e_mail")
                    model.address = results.string(forColumn: "address")
                    model.type = Int(results.longLongInt(forColumn: "type"))
                    model.remark = results.string(forColumn: "remark")
                    model.createTime = results.string(forColumn: "create_time")
                    localContactModelArray.append(model)
                }
            }catch{
                print("查询本地联系人失败")
            }
            complete?(localContactModelArray)
            DBManager.shared.closeDB()
        }
    }
    
    //获取首字母
    func selectFirstCharactor(type:Int,complete: (([String]) -> Void)?){
        if DBManager.shared.openDB(){
            var sql = "select "
            + "first_charactor from cl_local_contact where self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'" + " and" + " 1 = 1 "
            if type != -1 {
                sql = sql + "and type = " + String(type)
            }
            sql = sql + " group by first_charactor order by first_charactor asc"
            var firstCharactorArr: [String]  = []
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    firstCharactorArr.append(results.string(forColumn: "first_charactor") as! String)
                }
            }catch{
                print("查询本地联系人失败")
            }
            complete?(firstCharactorArr)
            DBManager.shared.closeDB()
        }
    }
    
    //根据字母排序
    func selectLocalContactByFirstCharactor(type:Int,firstCharactor:String,complete: (([LocalContactModel]) -> Void)?){
        if DBManager.shared.openDB(){
            var localContactModelArray: [LocalContactModel] = []
            var sql = "select "
            + "self_account,"
            + "local_contact_id,"
            + "name,"
            + "first_charactor,"
            + "number,"
            + "campany,"
            + "mobile,"
            + "fax,"
            + "depart,"
            + "post,"
            + "e_mail,"
            + "address,"
            + "type,"
            + "remark,"
            + "create_time from cl_local_contact where first_charactor =  '" + firstCharactor + "'" + " and self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'"
            if type != -1{
                sql = sql + " and type = " + String(type)
            }
            sql = sql + " order by name asc"
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = LocalContactModel()
                    model.localContactId = Int(results.longLongInt(forColumn: "local_contact_id"))
                    model.name = results.string(forColumn: "name")
                    model.firstCharactor = results.string(forColumn: "first_charactor")
                    model.number = results.string(forColumn: "number")
                    model.campany = results.string(forColumn: "campany")
                    model.depart = results.string(forColumn: "depart")
                    model.post = results.string(forColumn: "post")
                    model.mobile = results.string(forColumn: "mobile")
                    model.fax = results.string(forColumn: "fax")
                    model.eMail = results.string(forColumn: "e_mail")
                    model.address = results.string(forColumn: "address")
                    model.type = Int(results.longLongInt(forColumn: "type"))
                    model.remark = results.string(forColumn: "remark")
                    model.createTime = results.string(forColumn: "create_time")
                    localContactModelArray.append(model)
                }
            }catch{
                print("查询本地联系人失败")
            }
            complete?(localContactModelArray)
            DBManager.shared.closeDB()
        }
    }
    
    // 本地通讯录
    func selectLocalContact(number:String,name:String,complete: (([LocalContactModel]) -> Void)?){
        if DBManager.shared.openDB(){
            let sql = "select "
            + "self_account,"
            + "local_contact_id,"
            + "name,"
            + "first_charactor,"
            + "number,"
            + "campany,"
            + "mobile,"
            + "fax,"
            + "depart,"
            + "post,"
            + "e_mail,"
            + "address,"
            + "type,"
            + "remark,"
            + "create_time from cl_local_contact where number = '" + number + "' and name = '" + name + "'" + " and self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'"
            var localContactModelArray: [LocalContactModel] = []
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = LocalContactModel()
                    model.localContactId = Int(results.longLongInt(forColumn: "local_contact_id"))
                    model.name = results.string(forColumn: "name")
                    model.firstCharactor = results.string(forColumn: "first_charactor")
                    model.number = results.string(forColumn: "number")
                    model.campany = results.string(forColumn: "campany")
                    model.depart = results.string(forColumn: "depart")
                    model.post = results.string(forColumn: "post")
                    model.mobile = results.string(forColumn: "mobile")
                    model.fax = results.string(forColumn: "fax")
                    model.eMail = results.string(forColumn: "e_mail")
                    model.address = results.string(forColumn: "address")
                    model.type = Int(results.longLongInt(forColumn: "type"))
                    model.remark = results.string(forColumn: "remark")
                    model.createTime = results.string(forColumn: "create_time")
                    localContactModelArray.append(model)
                }
            }catch{
                print("查询本地联系人失败")
            }
            complete?(localContactModelArray)
            DBManager.shared.closeDB()
        }
    }
    
    // 本地通讯录
    func selectLocalContact(number:String,complete: (([LocalContactModel]) -> Void)?){
        if DBManager.shared.openDB(){
            let sql = "select "
            + "self_account,"
            + "local_contact_id,"
            + "name,"
            + "first_charactor,"
            + "number,"
            + "campany,"
            + "mobile,"
            + "fax,"
            + "depart,"
            + "post,"
            + "e_mail,"
            + "address,"
            + "type,"
            + "remark,"
            + "create_time from cl_local_contact where number = '" + number + "'" + " and self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'"
            var localContactModelArray: [LocalContactModel] = []
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = LocalContactModel()
                    model.localContactId = Int(results.longLongInt(forColumn: "local_contact_id"))
                    model.name = results.string(forColumn: "name")
                    model.firstCharactor = results.string(forColumn: "first_charactor")
                    model.number = results.string(forColumn: "number")
                    model.campany = results.string(forColumn: "campany")
                    model.depart = results.string(forColumn: "depart")
                    model.post = results.string(forColumn: "post")
                    model.mobile = results.string(forColumn: "mobile")
                    model.fax = results.string(forColumn: "fax")
                    model.eMail = results.string(forColumn: "e_mail")
                    model.address = results.string(forColumn: "address")
                    model.type = Int(results.longLongInt(forColumn: "type"))
                    model.remark = results.string(forColumn: "remark")
                    model.createTime = results.string(forColumn: "create_time")
                    localContactModelArray.append(model)
                }
            }catch{
                print("查询本地联系人失败")
            }
            complete?(localContactModelArray)
            DBManager.shared.closeDB()
        }
    }
    
    func deleteLocalContact(id:Int,complete: ((Bool) -> Void)?){
        if DBManager.shared.openDB(){
            let sql = "delete from cl_local_contact where local_contact_id = " + String(id) + " and self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'"
            do{
                let results = try DBManager.shared.database.executeStatements(sql)
                 complete?(results)
            }catch{
                print("删除本地联系人失败")
            }
            DBManager.shared.closeDB()
        }
    }
    
    
    /// 更新本地联系人备注
    /// - Parameters:
    ///   - id: id
    ///   - name: name
    ///   - complete:
    func updateLocalContactName(id:Int, name: String, complete: ((Bool) -> Void)?) {
        if DBManager.shared.openDB(){
            let sql = "update cl_local_contact set name = '" + name + "' where local_contact_id = " + String(id) + " and self_account = " + "'" + "\(ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? "")" + "'"
            do{
                let results = try DBManager.shared.database!.executeUpdate(sql, withArgumentsIn: [])
                 complete?(results)
            }catch{
                print("更新本地联系人失败")
            }
            DBManager.shared.closeDB()
        }
    }
    
    
    private func transChineseToPinYin(from chinese: String?) ->String {
        
        if chinese == nil {
            return ""
        }
        
       //转化为可变字符串

       let mString = NSMutableString(string: chinese!)

       //转化为带声调的拼音

       CFStringTransform(mString, nil, kCFStringTransformToLatin, false)

       //转化为不带声调

       CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false)

       //转化为不可变字符串

       let string = NSString(string: mString)

       //去除字符串之间的空格

       return string.replacingOccurrences(of: " ", with: "")
    }
    
}
