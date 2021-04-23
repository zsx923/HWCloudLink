//
//  SVCMeetingManager.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/4.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

// 使用哪一种ssrc设置策略
enum SsrcNumType {
    case ssrcFlashback // 单双数倒叙
    case ssrcIncrease // 递增
    case ssrcBefore // 使用以前的
}

var SvcBottomNameOffSet : CGFloat = 0

class SVCMeetingManager: NSObject {
    // 与会者数组
    public var attendeeArray: [ConfAttendeeInConf] = []
    // 语音入会与会者数组
    public var voiceAttendeeArray: [ConfAttendeeInConf] = []
    // 全部在线与会者数组（包含语音，视频在线等）
    public var allAttendeeArray: [ConfAttendeeInConf] = []
    // 全部在线的与会者ID
    public var allAttendeeIDArray: [String] = []
    // 全部在线与会者字典（包含语音，视频在线等）
    public var allAttendeeDictionary : [String:ConfAttendeeInConf] = [:]
    // 不在线的与会者
    public var offlineAttendArray: [ConfAttendeeInConf] = []
    // 当前页面展示的与会者数组
    public var currentShowAttendeeArray: [ConfAttendeeInConf] = []
    // 页面展示与会者二维数组
    public var attendeesPageArray : [[ConfAttendeeInConf]] = []
    // 与会者ID二维数组
    public var attendeesIDPageArray : [[String]] = []
    // 与会者ID数组
    public var attendeeIDArray:[String] = []
    // 当前会议信息
    public var currentMeetInfo: ConfBaseInfo?
    // 当前接听的call对象信息
    public var currentCallInfo: CallInfo?
    // 与会者中的自己
    public var mineConfInfo: ConfAttendeeInConf?
    // 与会者中的主持人
    public var chairmanConfInfo: ConfAttendeeInConf?
    // 与会者中的选看对象
    public var watchConfInfo: ConfAttendeeInConf?
    // 与会者中的广播对象
    public var broadcastConfInfo: ConfAttendeeInConf?
    // 与会者大画面展示对象
    public var bigPictureConfInfo : ConfAttendeeInConf?
    // 记录上一次大画面语音激励对象
    public var lastTimeSpeckConfInfo : ConfAttendeeInConf?
    // call manager
    private var callManager = CallMeetingManager()
    // 是否接收共享辅流
    public var isAuxiliary = false
    // 是否正在共享辅流
    public var isMyShare = false
    // 是否是大会模式
    public var isPolicy = false
    // 是否点击取消举手(防止会议页面与会者离开提示取消举手)
    public var isClickCancleRaise = false
    // 当前是否切换到小窗口模式
    public var isSmallWindow = false
    // 小画面是否需要刷新
    public var isReloadSmallWindow = false
    // 当前使用的最后一个ssrc
    public var useLastSsrc:Int = 0
    // 当前与会者远端View
    public var remotes:[EAGLView?] = []
    // 当前是否是大画面
    public var isBigPicture:Bool = false
    // 当前页
    public var indexRow:Int = 0
    // 当前的CallID
    public var callID:UInt32 = 0
    // 当前的动态带宽
    public var bindWidth:Int = 1920
    // 是否需要刷新本地小画面
    public var isNeedRefreshLoc:Bool = true
    
    deinit {
        CLLog("SVCMeetingManager deinit")
    }
}
//MARK: 返回的与会者原始数据处理
extension SVCMeetingManager {
    // 处理与会者数组中特殊存在
    func conferenceSetAttendeeArray() {
        
        let AttDataSource:[ConfAttendeeInConf] = callManager.haveJoinAttendeeArray()
        
        // 全部执空
        self.chairmanConfInfo = nil // 主席先置为空
        self.mineConfInfo = nil
        
        var allTempAttendeeArray:[ConfAttendeeInConf] = [] // 全部在线的与会者
        var allTempAttendeeDictionary:[String:ConfAttendeeInConf] = [:] // 所有在线与会者字典
        var allTempAttendeeIDArray:[String] = [] // 全部在线的与会者ID
        var tempAttendeeIDArray:[String] = [] // 在线与会者ID数组
        var tempAttendeeArray:[ConfAttendeeInConf] = [] // 视频入会与会者
        var tempVoAttendeeArray:[ConfAttendeeInConf] = [] // 语音入会与会者
        var tempOfflineAttendArray:[ConfAttendeeInConf] = [] // 不在线的与会者
        
        // 处理与会者中的特殊存在
        var isBigPictureConfExist : Bool = false
        var isWatchConfExist: Bool = false
//        var isBoardConfExist: Bool = false
        
        for (_,attendInConf) in AttDataSource.enumerated() {
            // 过滤number为空的与会者
            if attendInConf.number == "" || attendInConf.number == nil  {
                CLLog("当前与会者ID是空")
                continue
            }
            // 过滤会议中你不需要的状态
            switch attendInConf.state {
            case ATTENDEE_STATUS_LEAVED, ATTENDEE_STATUS_NO_EXIST, ATTENDEE_STATUS_BUSY, ATTENDEE_STATUS_NO_ANSWER, ATTENDEE_STATUS_REJECT, ATTENDEE_STATUS_CALL_FAILED:
                tempOfflineAttendArray.append(attendInConf) // 返回的不在线的与会者
                // 如果当前广播对象在离线的与会者中，将广播对象置为空
                if self.broadcastConfInfo != nil,self.broadcastConfInfo?.number == attendInConf.number {
                    self.broadcastConfInfo = nil
                }
                continue
            default:
                print("no define")
            }
            // 返回的所有在线与会者
            allTempAttendeeArray.append(attendInConf)
            allTempAttendeeIDArray.append(attendInConf.number)
            allTempAttendeeDictionary.updateValue(attendInConf, forKey: attendInConf.number)
            // 主持人
            if attendInConf.role == .CONF_ROLE_CHAIRMAN {
                self.chairmanConfInfo = attendInConf
            }
            // 过滤语音入会
            if attendInConf.is_audio {
                tempVoAttendeeArray.append(attendInConf)
                continue
            }
            // 处理会议中的特殊与会者存在(画中画，广播，选看)
            // 处理大画面显示的与会者,判断选看人是否在与会者中
            if self.bigPictureConfInfo != nil, attendInConf.number == self.bigPictureConfInfo?.number {
                self.bigPictureConfInfo = attendInConf
                isBigPictureConfExist = true
            }
            // 当前选看与会者不再会议中(离会)
            if self.watchConfInfo != nil {
                if attendInConf.number == self.watchConfInfo?.number { // 判断选看人是否在与会者中
                    self.watchConfInfo = attendInConf
                    isWatchConfExist = true
                }
            }
//            // 当前与会者是广播会场
//            if self.broadcastConfInfo != nil {
//                if attendInConf.number == self.broadcastConfInfo?.number {
//                    self.broadcastConfInfo = attendInConf
//                    isBoardConfExist = true
//                }
//            }
            // 判断当前与会者是否是自己
            let selfNumber = ManagerService.call()?.sipAccount
            CLLog("selfJoinNumber sipAccount - \(selfNumber ?? "")")
            if attendInConf.isSelf || attendInConf.number == selfNumber || attendInConf.number == NSString.getSipaccount(selfNumber) || attendInConf.participant_id == selfNumber || attendInConf.participant_id == NSString.getSipaccount(selfNumber) { // 找到自己
                CLLog("找到自己了 - number:\(String(describing: attendInConf.number)) - participant_id:\(String(describing: attendInConf.participant_id)) - selfNumber:\(String(describing: selfNumber))")
                self.mineConfInfo = attendInConf
                continue // 结束本次循环，自己不加入到与会者数组中
            }
            // 自己不是主席，有选看的对象，大会模式 - (将选看的对象置为空)
            if self.mineConfInfo?.role != .CONF_ROLE_CHAIRMAN, self.watchConfInfo != nil, self.isPolicy == true {
                self.watchConfInfo = nil
            }
            // 视频入会与会者
            tempAttendeeArray.append(attendInConf)
            // 视频入会与会者ID
            tempAttendeeIDArray.append(attendInConf.number)
        }
        // 不存在与会者中（已经离会）
        if isBigPictureConfExist == false {
            self.bigPictureConfInfo = nil
        }
        // 不存在与会者中（已经离会）
        if isWatchConfExist == false {
            self.watchConfInfo = nil
        }
//        // 不存在与会者中 (已经离会)
//        if isBoardConfExist == false {
//            self.broadcastConfInfo = nil
//        }
        // 视频入会与会者
        self.attendeeArray.removeAll()
        self.attendeeArray = tempAttendeeArray
        // 音频入会与会者
        self.voiceAttendeeArray.removeAll()
        self.voiceAttendeeArray = tempVoAttendeeArray
        // 会议中不在线的与会者
        self.offlineAttendArray.removeAll()
        self.offlineAttendArray = tempOfflineAttendArray
        // 视频入会在线与会者ID
        self.attendeeIDArray.removeAll()
        self.attendeeIDArray = tempAttendeeIDArray
        // 所有与会者数组
        self.allAttendeeArray.removeAll()
        self.allAttendeeArray = allTempAttendeeArray
        // 所有在线与会者ID
        self.allAttendeeIDArray.removeAll()
        self.allAttendeeIDArray = allTempAttendeeIDArray
        // 所有与会者字典
        self.allAttendeeDictionary.removeAll()
        self.allAttendeeDictionary = allTempAttendeeDictionary
        CLLog("SDK返回的所有视频与会者 -      \(getAllAttendeesReturnMessage(attendees: attendeeArray))")
        CLLog("SDK返回的所有在线与会者 -      \(getAllAttendeesReturnMessage(attendees: allAttendeeArray))")
        CLLog("SDK返回的所有不在线与会者 -     \(getAllAttendeesReturnMessage(attendees: offlineAttendArray))")
    }
}

//MARK: svc选看绑定远端窗口
extension SVCMeetingManager {

    /**
     SVC选看绑定远端窗口逻辑说明
     1、先调用svc批量选看接口，接口调用后有block回调，返回code=-1和result。
     2、选看接口调用成功后有TSDK_E_CONF_EVT_SVC_WATCH_IND通知回调，该回调中返回svc选看结果（大会模式非主席返回的结构不一定是用户主动选看的与会者，mcu会推送其他与会者），收到通知后block回调，该回调包含code值、result结果、svc选看列表，根据该改列表绑定远端窗口。
     3、svc批量绑定接口调用成功后1.5秒内未收到选看通知，直接使用用户选看的与会者数组绑定远端窗口
     4、svc选看接口调用失败或通知未返回选看与会者数组则失败
     */
    // svc选看绑定远端窗口
    func svcWatchAttendeesAndAddRemoveSvcVideoWindow(currentAttendeeArray:[ConfAttendeeInConf],Remotes:[EAGLView?],callId:UInt32,isBigPicture:Bool,indexRow:Int,ssrcType:SsrcNumType,watchCompletion: @escaping (_ result:Bool,_ watchAttendees:[ConfAttendeeInConf]?)->Void,mcuWatchCompletion: @escaping (_ result:Bool, _ mcuAttendees:[ConfAttendeeInConf]?)->Void,bindCompletion: @escaping (_ result:Bool,_ bindAttendees:[ConfAttendeeInConf]?)->Void)
    {
        self.remotes = Remotes
        self.callID = callId
        self.isBigPicture = isBigPicture
        self.indexRow = indexRow
        // 设置远端与会者label_id
        var currentAttendArr:[ConfAttendeeInConf] = []
        switch ssrcType {
        case .ssrcFlashback:
            currentAttendArr = setCurrentAttendeeFlashbackLabelID(currentAttendeeArray: currentAttendeeArray, isBigPicture: isBigPicture, indexRow: indexRow)
        case .ssrcIncrease:
            currentAttendArr = setCurrentAttendeeIncreaseLabelID(currentAttendeeArray: currentAttendeeArray, isBigPicture: isBigPicture, indexRow: indexRow)
        case .ssrcBefore:
            currentAttendArr = currentShowAttendeeArray
        default:
            print("no ssrc")
            break
        }
        var isWatchAttends:Bool = false // 判断当前是否选看，只有选看了才绑定远端窗口
        // 是否绑定远端接口
        CLLog("svc meeting watch - request:    \(self.getCurrentAttendeesNameAndLabelID(attendees: currentAttendeeArray)),    indexRow:\(indexRow)")
        // 调用SVC选看接口
        ManagerService.confService()?.svcWatchAttendeeArray(currentAttendArr, isBigPicture: isBigPicture, bandWidth: UInt32(bindWidth), isH265SVC: (currentCallInfo?.svcType == CALL_SVC_H265 ? true : false), watchComplete: { [weak self] (result, code, watchLists:[ConfAttendeeInConf]?) in // 用户选看回调
            guard let self = self else {return}
            isWatchAttends = true // 选看置为YES
            CLLog("svc meeting watch - result:     \(String(result)),       NameAndlabelsID:\(self.getCurrentAttendeesNameAndLabelID(attendees: watchLists ?? [])),      NameAndIDs:\(self.getCurrentOnLinkAttendeesNameAndId(attendees: watchLists ?? [])),    callId:\(NSString.encryptNumber(with: String(callId)) ?? ""),    bandWidth:\(self.bindWidth),    indexRow:\(indexRow)")
            if result { // 接口调用成功
                watchCompletion(true,watchLists)
                // 接口调用成功，muc2秒未通知返回选看结果
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                    watchCompletion(true,nil)
                }
            }else {
                watchCompletion(false,nil)
            }
        }, complete: { [weak self] (result, code, mcuWatchList:[ConfAttendeeInConf]?, svcWatchDic:[AnyHashable:Any]?) in // 通知mcu返回选看回调
            guard let self = self else {return}
            CLLog("svc meeting watch - mcu result:     \(String(result)),      NameAndIDs:\(self.getCurrentMcuWatchAttendeesNameAndID(attendees: mcuWatchList ?? [])),        callId:\(NSString.encryptNumber(with: String(callId)) ?? ""),     bandWidth:\(self.bindWidth),       indexRow:\(indexRow)")
            if !isWatchAttends {
                CLLog("- 当前未选看不做绑定操作 -")
                return
            }
            isWatchAttends = false
            if result { // 收到通知回调，并且有返回选看列表
                // 绑定远端窗口
                var bindCurrentAttendArr:[ConfAttendeeInConf] = []
                if mcuWatchList?.count != 0 {
                    bindCurrentAttendArr = self.dealWithSvcWatchList(svcWatchLists: mcuWatchList, currentAttend: currentAttendArr)
                }else if bindCurrentAttendArr.count == 0 {
                    bindCurrentAttendArr = currentAttendArr
                }
                // mcu通知返回选看与会者回调
                mcuWatchCompletion(true,bindCurrentAttendArr)
                // 绑定远端窗口
                let result = ManagerService.call()?.addRemoveSvcVideoWindow(withRemotes: Remotes as [Any], attendees: bindCurrentAttendArr, callId: callId, isBigPicture: isBigPicture, bandWidth: UInt32(self.bindWidth), isH265SVC: (self.currentCallInfo?.svcType == CALL_SVC_H265 ? true : false))
                CLLog("svc meeting bind - result:      \(String(result ?? false)),       NameAndlabelsID:\(self.getCurrentAttendeesNameAndLabelID(attendees: bindCurrentAttendArr)),      callId:\(NSString.encryptNumber(with: String(callId)) ?? ""),      bandWidth:\(self.bindWidth),      Remotes:\(Remotes),     indexRow:\(indexRow)")
                // 第一个与会者是自己
                if !isBigPicture {
                    var allAttendArr:[ConfAttendeeInConf] = []
                    allAttendArr.append(self.mineConfInfo ?? ConfAttendeeInConf())
                    for confInfo in bindCurrentAttendArr {
                        allAttendArr.append(confInfo)
                    }
                    bindCurrentAttendArr = allAttendArr
                }
                // 绑定结果回调
                bindCompletion((result ?? false),bindCurrentAttendArr)
            }else{
                // mcu通知返回选看与会者回调
                mcuWatchCompletion(false,currentAttendeeArray)
            }
        })
    }
    /**
     与会者ssrc设置逻辑 循环使用，全局保存上一次用的最后一个ssrc，需要使用时全局保存的每次加1，超过end重新从start开始
     */
    // 设置svc刷新页面的label_id（递增）
    private func setCurrentAttendeeIncreaseLabelID(currentAttendeeArray:[ConfAttendeeInConf], isBigPicture:Bool, indexRow:Int) -> [ConfAttendeeInConf] {
        CLLog("svc meeting Increase ulSvcSsrcStart:\(String(self.currentCallInfo?.ulSvcSsrcStart ?? 0))    ulSvcSsrcEnd:\(String(self.currentCallInfo?.ulSvcSsrcEnd ?? 0))")
        let ulSvcSsrc:Int = (self.currentCallInfo?.ulSvcSsrcEnd ?? 0)-(self.currentCallInfo?.ulSvcSsrcStart ?? 0)
        CLLog("svc meeting ulSvcSsrc Difference:\(String(ulSvcSsrc))")
        var attendeeArr:[ConfAttendeeInConf] = []
        for attendee in currentAttendeeArray {
            var currentlabel_id:Int = useLastSsrc+1
            useLastSsrc = currentlabel_id
            if currentlabel_id > (self.currentCallInfo?.ulSvcSsrcEnd ?? 0) {
                useLastSsrc = self.currentCallInfo?.ulSvcSsrcStart ?? 0
                currentlabel_id = useLastSsrc
            }
            let AttendeeConf:ConfAttendeeInConf = attendee
            AttendeeConf.lable_id = Int32(currentlabel_id)
            attendeeArr.append(AttendeeConf)
        }
        return attendeeArr
    }
    // 设置svc刷新页面label_id（按照单双数单数页start开始加一，双数end开始减一）
    private func setCurrentAttendeeFlashbackLabelID(currentAttendeeArray:[ConfAttendeeInConf], isBigPicture:Bool, indexRow:Int) -> [ConfAttendeeInConf] {
        CLLog("svc meeting Flashback ulSvcSsrcStart:\(String(self.currentCallInfo?.ulSvcSsrcStart ?? 0))    ulSvcSsrcEnd:\(String(self.currentCallInfo?.ulSvcSsrcEnd ?? 0))")
        let ulSvcSsrc:Int = (self.currentCallInfo?.ulSvcSsrcEnd ?? 0)-(self.currentCallInfo?.ulSvcSsrcStart ?? 0)
        CLLog("svc meeting ulSvcSsrc Difference:\(String(ulSvcSsrc))")
        var attendeeArr:[ConfAttendeeInConf] = []
        let needRow:Int = isAuxiliary ? indexRow-1 : indexRow
        if needRow % 2 == 0 {  // 双数页
            for (index,attendee) in currentAttendeeArray.enumerated() {
                let currentlabel_id:Int = (self.currentCallInfo?.ulSvcSsrcEnd ?? 0)
                let AttendeeConf:ConfAttendeeInConf = attendee
                AttendeeConf.lable_id = Int32(currentlabel_id-index)
                attendeeArr.append(AttendeeConf)
            }
        }else{                  // 单数页
            for (index,attendee) in currentAttendeeArray.enumerated() {
                let currentlabel_id:Int = self.currentCallInfo?.ulSvcSsrcStart ?? 0
                let AttendeeConf:ConfAttendeeInConf = attendee
                AttendeeConf.lable_id = Int32(currentlabel_id+index)
                attendeeArr.append(AttendeeConf)
            }
        }
        return attendeeArr
    }
    
    // 处理svc选看通知回调与会者数组与会者顺序
    func dealWithSvcWatchList(svcWatchLists:[ConfAttendeeInConf]?,currentAttend:[ConfAttendeeInConf]) -> [ConfAttendeeInConf] {
        var currentAttendees:[ConfAttendeeInConf] = []
        guard let attendeesList = svcWatchLists else {
            return currentAttend
        }
        for confInfo in attendeesList {
            if confInfo.number != "" , confInfo.number != nil , confInfo.lable_id == 0 {
                continue
            }
            if confInfo.number != "", confInfo.number != nil {
                let confModel = self.allAttendeeDictionary[confInfo.number ?? "0"]
                if confModel != nil {
                    confModel?.lable_id = confInfo.lable_id
                    currentAttendees.append(confModel ?? ConfAttendeeInConf())
                }
            }
        }
        return currentAttendees
    }
    
    // 当前与会者对应的ssrc
    func getCurrentAttendeesLabelID(attendees:[ConfAttendeeInConf]) -> [String] {
        var labelIDAtt:[String] = []
        for (_,attConf) in attendees.enumerated() {
            labelIDAtt.append(String(attConf.lable_id))
        }
        return labelIDAtt
    }
    
    
    // 获取当前与会者ID
    func getCurrentAttendeesID(attendees:[ConfAttendeeInConf]) -> [String] {
        var idAtt:[String] = []
        for (_,attConf) in attendees.enumerated() {
            idAtt.append(attConf.number)
        }
        return idAtt
    }
    
    
    // 获取当前与会者名字和对应的sssrc （log日志，number和name做了处理）
    func getCurrentAttendeesNameAndLabelID(attendees:[ConfAttendeeInConf]) -> [[String:String]] {
        var attArr:[[String:String]] = []
        for attendInfo in attendees {
            var attDic:[String:String] = [:]
            attDic = ["name":(attendInfo.name == nil || attendInfo.name == "") ? "nil" : NSString.encryptNumber(with: attendInfo.name),"label_id":String(attendInfo.lable_id)]
            attArr.append(attDic)
        }
        return attArr
    }
    
    
    // 获取当前与会者的名字和ID （log日志，number做了处理）
    func getCurrentOnLinkAttendeesNameAndId(attendees:[ConfAttendeeInConf]) -> [[String:String]] {
        var attArr:[[String:String]] = []
        for attendInfo in attendees {
            var attDic:[String:String] = [:]
            attDic = ["name":(attendInfo.name == nil || attendInfo.name == "") ? "nil" : NSString.encryptNumber(with: attendInfo.name),"number":(attendInfo.number == nil || attendInfo.number == "") ? "0" : NSString.encryptNumber(with: attendInfo.number)]
            attArr.append(attDic)
        }
        return attArr
    }
    
    // mcu选看的与会者labelID和number （log日志，number做了处理）
    func getCurrentMcuWatchAttendeesNameAndID(attendees:[ConfAttendeeInConf]) -> [[String:String]] {
        var attArr:[[String:String]] = []
        for attendInfo in attendees {
            var attDic:[String:String] = [:]
            attDic = ["labelID": String(attendInfo.lable_id),"number":(attendInfo.number == nil || attendInfo.number == "") ? "0" : NSString.encryptNumber(with: attendInfo.number)]
            attArr.append(attDic)
        }
        return attArr
    }
    
    // 邀请与会者返回的数据 (log日志，number做了处理）
    func getInviteAttendeesMessage(attendees:[LdapContactInfo]) -> [[String:String]] {
        var attArr:[[String:String]] = []
        for attendInfo in attendees {
            var attDic:[String:String] = [:]
            attDic = ["name":(attendInfo.name == nil || attendInfo.name == "") ? "nil" : NSString.encryptNumber(with: attendInfo.name),"number":(attendInfo.number == nil || attendInfo.number == "") ? "0" : NSString.encryptNumber(with: attendInfo.number)]
            attArr.append(attDic)
        }
        return attArr
    }
    
    // 返回的所有与会者 (log日志，number做了处理）
    func getAllAttendeesReturnMessage(attendees:[ConfAttendeeInConf]) -> [[String:String]] {
        var attArr:[[String:String]] = []
        for attendInfo in attendees {
            var attDic:[String:String] = [:]
            // 是否在线
            var attState:String = "Online"
            if attendInfo.state != ATTENDEE_STATUS_IN_CONF {
                attState = "Offline"
            }
            // 是否是主持人
            var attIsVideo:String = "true"
            if attendInfo.is_audio {
                attIsVideo = "false"
            }
            attDic = ["name":(attendInfo.name == nil || attendInfo.name == "") ? "nil" : NSString.encryptNumber(with: attendInfo.name),"number":(attendInfo.number == nil || attendInfo.number == "") ? "0" : NSString.encryptNumber(with: attendInfo.number),"state":attState,"isVideo":attIsVideo]
            attArr.append(attDic)
        }
        return attArr
    }
    
    // 判断当前是否需要刷新与会者
    func isCurrentParticipantsNeedToRefreshCollectionView(currentyShowAttendeesPageArray:[ConfAttendeeInConf]) -> Bool {
        let nowOldAttendees:[ConfAttendeeInConf] = currentyShowAttendeesPageArray
        let allAttendeesIDSet = Set(allAttendeeIDArray)
        let oldAttendeesIDSet = Set(getCurrentAttendeesID(attendees: nowOldAttendees))
        if allAttendeesIDSet.isSubset(of: oldAttendeesIDSet) { // 包含 未离会
            return false
        }
        return true
    }
    // 判断两个与会者ID数组是否相等
    func isCurrentAttendeesNeedRegfreshWithIDSame(oldAttends:[String],newAttends:[String]) -> Bool {
        // 两个数组不相等则需要刷新
        if oldAttends.count != newAttends.count {
            return true
        }
        // 两个数组相等
        for (_,IDStr) in newAttends.enumerated() {
            if !oldAttends.contains(IDStr) {
                return true
            }
        }
        return false
    }
    // 判断两个与会者数组与会者是否一样
    func isCurrentAttendeesNeedRefreshSame(currentAttendees:[ConfAttendeeInConf],newAttendees:[ConfAttendeeInConf]) -> Bool {
        var isRefresh:Bool = false
        let currentAttendeesID:[String] = getCurrentAttendeesID(attendees: currentAttendees)
        let newAttendeesID:[String] = getCurrentAttendeesID(attendees: newAttendees)
        if currentAttendeesID != newAttendeesID {
            isRefresh = true
        }
        return isRefresh
    }
    // 判断当前与会者是否有人离会
    func isCurrentAttendeesLeftTheMeeting(attendees:[ConfAttendeeInConf]) -> Bool {
        var isLeftMeeting:Bool = false
        let currentConfID:[String] = getCurrentAttendeesID(attendees: attendees)
        for ConfID in currentConfID {
            if !allAttendeeIDArray.contains(ConfID) {
                isLeftMeeting = true
                break
            }
        }
        return isLeftMeeting
    }
}

// 一些判断条件
extension SVCMeetingManager {
    // 判断当前屏幕是否是当前控制器
    func isShowCurrentVC() -> Bool {
        let curretVC = ViewControllerUtil.getCurrentViewController()
        if curretVC is SVCMeetingViewController {
            return true
        }
        return false
    }
    
    // 自己是否是主席
    func isChairmanForMine() -> Bool {
        var isChairman = false
        if chairmanConfInfo != nil,mineConfInfo != nil,chairmanConfInfo?.number == mineConfInfo?.number {
            isChairman = true
        }
        return isChairman
    }
    
    // 不可以双击选看的条件
    func isConNotDoubleClickToWatchInfo() -> Bool {
        // 大会模式和自己不是主席，会议中就两个人，当前有广播对象
        if self.isPolicy && self.mineConfInfo?.role != .CONF_ROLE_CHAIRMAN {
            MBProgressHUD.showBottom(tr("进入大会模式，当前不支持自由选"), icon: nil, view: nil)
        }
        if self.broadcastConfInfo != nil {
            MBProgressHUD.showBottom(tr("正在广播中，暂时不能选看"), icon: nil, view: nil)
        }
        if (self.isPolicy && self.mineConfInfo?.role != .CONF_ROLE_CHAIRMAN) || (self.attendeeArray.count <= 1) || self.broadcastConfInfo != nil {
            return true
        }
        return false
    }
    
}



