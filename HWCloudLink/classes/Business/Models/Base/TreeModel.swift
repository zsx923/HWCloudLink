//
//  TreeModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/10/23.
//  Copyright © 2018 陈帆. All rights reserved.
//

import UIKit

class TreeModel: JSONMappable {

    /// id
    var id: String?
    
    /// text
    var text: String?
    
    /// level
    var level: String?
    
    /// parentId
    var parentId: String?
    
    /// state
    var state: String?
    
    /// stateCN
    var stateCN: String?
    
    /// isSelect
    var isSelect: Bool?
    
    /// isHideSelectView  是否隐藏选择框
    var isHideSelectView: Bool?
    
    /// isOpen
    var isOpen: Bool?
    
    /// attributes
    var attributes: AttributesModel?
    
    /// text
    var children: [TreeModel]?
    
    required init(json: JSON) {
        
        id = json["id"].stringValue
        text = json["text"].stringValue
        level = json["level"].stringValue
        parentId = json["parentId"].stringValue
        state = json["state"].stringValue
        isSelect = json["isSelect"].boolValue
        isOpen = json["isOpen"].boolValue
        isHideSelectView = json["isHideSelectView"].boolValue
        attributes = AttributesModel.init(json: json["attributes"])
        children = json["children"].arrayValue.map({ (json) -> TreeModel in
            TreeModel(json: json)
        })
    }
    
    init() {
    }
}
