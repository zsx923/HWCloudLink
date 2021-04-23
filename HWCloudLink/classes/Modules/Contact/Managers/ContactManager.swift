//
//  ContactManager.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/12/3.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

class ContactManager {
    
    static let shared = ContactManager()
    static var startRun: CFAbsoluteTime = 0
    
    // 存储通话记录  1：语音呼叫  2：视频呼叫
    func saveContactCallLog(callType: Int, name: String, number: String, depart: String, isAnswer: Bool, talkTime: Int, isComing: Bool = false) {
        
        let linkTime: CFAbsoluteTime = (CFAbsoluteTimeGetCurrent() - ContactManager.startRun) * 1000
        if linkTime < 1000 {
            CLLog("1秒内连续调用了saveContactCallLog方法，此次调用不予处理");
            return
        }
        ContactManager.startRun = CFAbsoluteTimeGetCurrent();
        
        guard let terminal = ManagerService.call()?.terminal else {
            CLLog("保存通话记录失败-无terminal号码")
            return
        }
        let model = UserCallLogModel.init()
        model.meetingType = 1
        model.callType = callType
        model.userId = Int(terminal)
        model.userName = name
        model.imageUrl = "a"
        model.number = number
        model.title = depart
        model.isAnswer = isAnswer
        model.talkTime = talkTime
        model.isComing = isComing
        DispatchQueue.main.async {
            UserCallLogBusiness.shareInstance.insertUserCallLog(userCallLogModel: model) { (res) in
                if res {
                    CLLog("保存通话记录成功")
                } else {
                    CLLog("保存通话记录失败")
                }
            }
        }
    }
    
    // 存储会议历史记录
    func saveMeetingRecently(meetingInfo: ConfBaseInfo, startTime: String, duration: Int) {
        
        let linkTime: CFAbsoluteTime = (CFAbsoluteTimeGetCurrent() - ContactManager.startRun) * 1000
        if linkTime < 1000 {
            CLLog("1秒内连续调用了saveMeetingRecently方法，此次调用不予处理");
            return
        }
        ContactManager.startRun = CFAbsoluteTimeGetCurrent();
        
        guard let terminal = ManagerService.call()?.terminal else {
            CLLog("保存通话记录失败-无terminal号码")
            return
        }
        if meetingInfo.scheduleUserAccount == nil {
            meetingInfo.scheduleUserAccount = ""
        }
        if meetingInfo.confSubject == nil {
            meetingInfo.confSubject = ""
        }
        
        let model = UserCallLogModel()
        model.meetingType = 2
        model.callType = (meetingInfo.mediaType.rawValue == 0 ? 1 : 2)
        model.userId = Int(terminal)
        if meetingInfo.scheduleUserAccount != nil && meetingInfo.scheduleUserAccount.count > 0 {
            model.userName = meetingInfo.scheduleUserAccount
        } else {
            model.userName = meetingInfo.scheduleUserName
        }
        if meetingInfo.confSubject != nil && meetingInfo.confSubject.count > 0 {
            model.title = meetingInfo.confSubject
        } else {
            model.title = meetingInfo.accessNumber
        }
        model.imageUrl = ""
        model.number = meetingInfo.accessNumber
        model.isAnswer = true
        model.talkTime = duration
        model.isComing = meetingInfo.isComing
//        model.createTime = startTime
        DispatchQueue.main.async {
            UserCallLogBusiness.shareInstance.insertUserCallLog(userCallLogModel: model) { (res) in
                if res {
                    CLLog("保存会议记录成功")
                } else {
                    CLLog("保存会议记录失败")
                }
            }
            self.saveMeetingHistory(meetingInfo: meetingInfo)
        }
    }
    
    // 存储加入会议页面中的历史记录
    func saveMeetingHistory(meetingInfo: ConfBaseInfo) {
        if meetingInfo.confSubject.count <= 0 || meetingInfo.accessNumber.count <= 0 {
            CLLog("保存加入会议历史记录失败-会议信息异常")
            return
        }
        guard let accont = ManagerService.loginService()?.obtainCurrentLoginInfo()?.account else {
            CLLog("保存加入会议历史记录失败-无用户登陆账号信息")
            return
        }
        let key = "CLJoinMeetingHistoryIdentifierKey" + accont
        var data:[MeetingHistoryModel]? = self.getMeetingHistory()
        if data == nil {
            data = [MeetingHistoryModel]()
        }
        if var arr = data {
            for i in 0..<arr.count {
                let item = arr[i]
                if item.number == meetingInfo.accessNumber {
                    arr.remove(at: i)
                    break
                }
            }
            let model = MeetingHistoryModel(meetingInfo.confSubject, meetingInfo.accessNumber)
            arr.insert(model, at: 0)
            if arr.count > 5 {
                arr.removeLast()
            }
            do {
                let encodedObject = try NSKeyedArchiver.archivedData(withRootObject: arr, requiringSecureCoding: false)
                UserDefaults.standard.set(encodedObject, forKey: key)
                UserDefaults.standard.synchronize()
            } catch {
                CLLog("保存加入会议历史记录失败: \(error)")
            }
        }
    }
    
    // 获取会议页面中的历史记录
    func getMeetingHistory() -> [MeetingHistoryModel]? {
        guard let accont = ManagerService.loginService()?.obtainCurrentLoginInfo()?.account else {
            return nil
        }
        let key = "CLJoinMeetingHistoryIdentifierKey" + accont
        let encodedObject = UserDefaults.standard.value(forKey: key)
        if let data = encodedObject {
            do {
                let arr = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MeetingHistoryModel.self], from: data as! Data)
                return arr as? [MeetingHistoryModel]
            } catch {
                CLLog("获取加入会议历史记录失败: \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    // 删除会议页面中的历史记录
    func removeMeetingHistoryAllData() {
        guard let accont = ManagerService.loginService()?.obtainCurrentLoginInfo()?.account else {
            return
        }
        let key = "CLJoinMeetingHistoryIdentifierKey" + accont
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}

class MeetingHistoryModel: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    var title = ""
    var number = ""
    
    init(_ title: String, _ number: String) {
        super.init()
        self.title = title
        self.number = number
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: NSStringFromClass(MeetingHistoryModel.self) + ".title")
        coder.encode(self.number, forKey: NSStringFromClass(MeetingHistoryModel.self) + ".number")
    }
    
    required init?(coder: NSCoder) {
        self.title = coder.decodeObject(forKey: NSStringFromClass(MeetingHistoryModel.self) + ".title") as! String
        self.number = coder.decodeObject(forKey: NSStringFromClass(MeetingHistoryModel.self) + ".number") as! String
    }
}
