//
//  AppImageModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2019/1/2.
//  Copyright © 2019 陈帆. All rights reserved.
//

import UIKit

class AppImageModel: BaseModel {
    /**
     * 应用id
     */
    var appId: String?
    
    /**
     * 图片
     */
    var image: String?
    
    /**
     * 产品图片类型编码
     */
    var sort: Int?
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        appId = json["appId"].stringValue
        image = json["image"].stringValue
        sort = json["sort"].intValue
    }
}
