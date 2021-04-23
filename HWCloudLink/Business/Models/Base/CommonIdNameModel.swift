//
//  CommonIdNameModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/10/18.
//  Copyright © 2018 陈帆. All rights reserved.
//

import UIKit

class CommonIdNameModel: JSONMappable {
    
    /// id
    var id: String?
    
    /// name
    var name: String?
    
    required init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
    }
    
    init() {
    }
}
