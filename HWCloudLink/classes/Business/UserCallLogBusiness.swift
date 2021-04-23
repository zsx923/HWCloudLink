//
//  UserCallLogBusiness.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/16.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation


class UserCallLogBusiness: NSObject {
    
//    private lazy var selfAccount = ManagerService.loginService()?.obtainCurrentLoginInfo()?.account ?? ""
    
    // 单例
    static let shareInstance: UserCallLogBusiness = {
        let instance = UserCallLogBusiness()
        return instance
    }()
}

extension UserCallLogBusiness{
    
    func insertUserCallLog(selfAccont:String = (ManagerService.call()?.terminal) ?? "", userCallLogModel:UserCallLogModel,complete:((Bool) ->Void)?) {
        if DBManager.shared.openDB(){
            let sql = "insert into " + userCallLogModel.sqlTabelName + "("
            + "self_account,"
            + "user_id,"
            + "user_name,"
            + "number,"
            + "image_url,"
            + "title,"
            + "meeting_type,"
            + "call_type," // 1:个人通话记录 2:会议记录
            + "talk_time," // 通话时长
            + "is_answer," // 是否接听
            + "is_coming)" // 是否呼入
            + "values(?,?,?,?,?,?,?,?,?,?,?)"
            var res = DBManager.shared.database.executeUpdate(sql, withArgumentsIn:[
                  selfAccont,
                  userCallLogModel.userId,
                  userCallLogModel.userName,
                  userCallLogModel.number,
                  userCallLogModel.imageUrl,
                  userCallLogModel.title,
                  userCallLogModel.meetingType,
                  userCallLogModel.callType,
                  userCallLogModel.talkTime,
                  userCallLogModel.isAnswer ? 1:0,
                  userCallLogModel.isComing ? 1:0])
            if !res{
                print("通话记录保存失败")
            }
            complete?(res)
            DBManager.shared.closeDB()
            //发送刷新数据通知
            NotificationCenter.default.post(name: NSNotification.Name(RECENT_CONTACT_REFRESH_DATA), object: nil)
        }
       
    }
    
    func selectUserCallLog(userCallLogModel:UserCallLogModel,complete: (([UserCallLogModel]) -> Void)?){
        if DBManager.shared.openDB(){
            var userCallLogModelArray: [UserCallLogModel] = []
            let sql = "select "
            + "self_account,"
            + "user_call_log_id,"
            + "user_id,"
            + "user_name,"
            + "number,"
            + "image_url,"
            + "title,"
            + "meeting_type,"
            + "call_type,"// 1:个人通话记录 2:会议记录
            + "talk_time," // 通话时长
            + "is_answer," // 是否接听
            + "is_coming," // 是否呼入
            + "create_time from cl_user_call_log where 1 = 1 and self_account = " + "'" + "\(ManagerService.call()?.terminal ?? "")" + "'" + " order by user_call_log_id desc limit " + String(userCallLogModel.page) + "," + String(userCallLogModel.limit)
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = UserCallLogModel()
                    model.userCallLogId = Int(results.longLongInt(forColumn: "user_call_log_id"))
                    model.userId = Int(results.longLongInt(forColumn: "user_id"))
                    model.userName = results.string(forColumn: "user_name")
                    model.number = results.string(forColumn: "number")
                    model.imageUrl = results.string(forColumn: "image_url")
                    model.title = results.string(forColumn: "title")
                    model.callType = Int(results.longLongInt(forColumn: "call_type"))
                    model.meetingType = Int(results.longLongInt(forColumn: "meeting_type"))
                    model.talkTime = Int(results.longLongInt(forColumn: "talk_time"))
                    model.isAnswer = results.bool(forColumn: "is_answer")
                    model.isComing = results.bool(forColumn: "is_coming")
                    model.createTime = results.string(forColumn: "create_time")
                    userCallLogModelArray.append(model)
                }
            }catch{
                print("查询通话记录失败")
            }
            complete?(userCallLogModelArray)
            DBManager.shared.closeDB()
        }
    }
    
    func selectNearlyUserCallLog(complete: (([UserCallLogModel]) -> Void)?){
        if DBManager.shared.openDB(){
            var userCallLogModelArray: [UserCallLogModel] = []
            let sql = "select "
            + "self_account,"
            + "user_call_log_id,"
            + "user_id,"
            + "user_name,"
            + "number,"
            + "title,"
            + "image_url,"
            + "meeting_type,"
            + "call_type,"// 1:个人通话记录 2:会议记录
            + "talk_time," // 通话时长
            + "is_answer," // 是否接听
            + "is_coming," // 是否呼入
            + "create_time,count(*) as count from cl_user_call_log where self_account = " + "'" + "\(ManagerService.call()?.terminal ?? "")" + "'" + " and" + " julianday('now') - julianday(create_time) <= 30 group by user_name,number order by count desc limit 5"
            //let fsql = "select * from (" + sql + ") order by count desc"
            do{
                let results = try DBManager.shared.database.executeQuery(sql, values: nil)
                while results.next() {
                    let model = UserCallLogModel()
                    model.userCallLogId = Int(results.longLongInt(forColumn: "user_call_log_id"))
                    model.userId = Int(results.longLongInt(forColumn: "user_id"))
                    model.userName = results.string(forColumn: "user_name")
                    model.number = results.string(forColumn: "number")
                    model.imageUrl = results.string(forColumn: "image_url")
                    model.title = results.string(forColumn: "title")
                    model.callType = Int(results.longLongInt(forColumn: "call_type"))
                    model.meetingType = Int(results.longLongInt(forColumn: "meeting_type"))
                    model.talkTime = Int(results.longLongInt(forColumn: "talk_time"))
                    model.isAnswer = results.bool(forColumn: "is_answer")
                    model.isAnswer = results.bool(forColumn: "is_coming")
                    model.createTime = results.string(forColumn: "create_time")
                    print(Int(results.longLongInt(forColumn: "count")))
                    userCallLogModelArray.append(model)
                }
            }catch{
                print("查询通话记录失败")
            }
            complete?(userCallLogModelArray)
            DBManager.shared.closeDB()
        }
    }
    
    func deleteUserCallLog(userCallLogModel:UserCallLogModel,complete:((Bool) ->Void)?){
        if DBManager.shared.openDB(){
            let sql = "delete from " + userCallLogModel.sqlTabelName + " where self_account = " + "'" + "\(ManagerService.call()?.terminal ?? "")" + "'" + " and" + " user_id = ?"
            var res = DBManager.shared.database.executeUpdate(sql, withArgumentsIn: [userCallLogModel.userId])
            if !res{
                print("通话记录删除失败")
            }
            complete?(res)
            DBManager.shared.closeDB()
        }
    }
}

