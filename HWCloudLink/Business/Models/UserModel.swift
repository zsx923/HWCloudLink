//
//  UserModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/10/18.
//  Copyright © 2018 陈帆. All rights reserved.
//

import UIKit

// 用户类型
public enum RoleCodeType: String {
    case roleAdmin = "role_admin"   // 管理员
    case roleTemp = "role_temp"     // 临时用户
    case roleUser = "role_user"     // 正式用户
    case roleMerchant = "role_merchant"     // 商家用户
}

// 雾炮车状态
public enum CarStatus: Int {
    case offWork = 0    // 下班
    case onlineWork = 1 // 工作中
}

class UserModel: BaseModel {
    
    
    /// userId
    var userId: String?
    
    /// deviceId
    var grid: [CommonIdNameModel]?
    
    /// account
    var account: String?
    
    /// trueName
    var trueName: String?
    
    /// isLeader
    var isLeader: Bool?
    
    /// gridRole
    var gridRole: String?
    
    /// mobile
    var mobile: String?
    
    /// isParent
    var isParent: Int?
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        grid = json["grid"].arrayValue.map({ (json) -> CommonIdNameModel in
            CommonIdNameModel(json: json)
        })
        userId = json["userId"].stringValue
        account = json["account"].stringValue
        trueName = json["trueName"].stringValue
        isLeader = json["isLeader"].boolValue
        gridRole = json["gridRole"].stringValue
        mobile = json["mobile"].stringValue
        isParent = json["isParent"].intValue
    }
    
    // 模型转字典
    func modelToDict() -> NSDictionary {
        let dict = NSMutableDictionary.init()
        
        dict.setValue(self.account!, forKey: "deviceId")
        dict.setValue(self.trueName!, forKey: "username")
        dict.setValue(self.gridRole!, forKey: "nickname")
        dict.setValue(self.mobile!, forKey: "phoneNumber")
        
        return dict
    }
}
