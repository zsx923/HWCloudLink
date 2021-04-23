//
//  StyleCssMocel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/11/23.
//  Copyright © 2018 陈帆. All rights reserved.
//

import UIKit

class StyleCssModel: JSONMappable {
    /// fillColor
    var fillColor: String?
    
    /// fillOpacity
    var fillOpacity: Float?
    
    /// strokeColor
    var strokeColor: String?
    
    /// strokeOpacity
    var strokeOpacity: Float?
    
    /// strokeWeight
    var strokeWeight: Float?
    
    /// strokeStyle
    var strokeStyle: String?
    
    
    required init(json: JSON) {
        fillColor = json["fillColor"].stringValue
        fillOpacity = json["fillOpacity"].floatValue
        strokeColor = json["strokeColor"].stringValue
        strokeOpacity = json["strokeOpacity"].floatValue
        strokeWeight = json["strokeWeight"].floatValue
        strokeStyle = json["strokeStyle"].stringValue
    }
    
    init() {
    }
}
