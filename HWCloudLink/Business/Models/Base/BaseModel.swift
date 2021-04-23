//
//  BaseModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/26.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class BaseModel: JSONMappable {

    
    /// id
    var sid: String?
    
    /// updatedTime
    var supdatedTime: Int64?
    
    /// createdTime
    var screatedTime: Int64?
    
    /// status
    var sstatus: Int?
    
    required init(json: JSON) {
        sid = json["sid"].stringValue
        supdatedTime = json["supdatedTime"].int64Value
        screatedTime = json["screatedTime"].int64Value
        sstatus = json["sstatus"].intValue
    }
    
    init() {
    }
}
