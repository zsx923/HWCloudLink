//
//  CommonValueTextmodel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/10/23.
//  Copyright © 2018 陈帆. All rights reserved.
//

import UIKit

class CommonValueTextmodel: JSONMappable {
    /// value
    var value: String?
    
    /// name
    var text: String?
    
    /// code
    var code: String?
    
    /// type
    var type: String?
    
    /// latitude
    var latitude: Double?
    
    /// longitude
    var longitude: Double?
    
    /// status
    var status: String?
    
    /// statusCn
    var statusCn: String?
    
    required init(json: JSON) {
        value = json["value"].stringValue
        text = json["text"].stringValue
        code = json["code"].stringValue
        type = json["type"].stringValue
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        status = json["status"].stringValue
        statusCn = json["statusCn"].stringValue
    }
    
    init() {
    }
}
