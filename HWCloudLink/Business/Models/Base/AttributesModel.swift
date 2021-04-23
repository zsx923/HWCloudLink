//
//  AttributesModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/11/12.
//  Copyright © 2018 陈帆. All rights reserved.
//

import UIKit


class AttributesModel: BaseModel {
    /**
     * level
     */
    var level: Int?
    
    required init(json: JSON) {
        super.init(json: json)
        
        level = json["level"].intValue
    }
}
