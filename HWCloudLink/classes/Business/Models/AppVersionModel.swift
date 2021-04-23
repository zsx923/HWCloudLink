//
//  AppVersionModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2019/1/2.
//  Copyright © 2019 陈帆. All rights reserved.
//

import UIKit

class AppVersionModel: BaseModel {
    /**
     * 应用id
     */
    var appId: String?
    
    /**
     * 版本
     */
    var version: String?
    
    /**
     * 编译版本
     */
    var buildVersion: String?
    
    /**
     * 文件大小（B）
     */
    var fileSize: Int?
    
    /**
     * 文件位置
     */
    var path: String?
    
    /**
     * 下载次数
     */
    var downloadCount: Int?
    
    /**
     * 更新说明
     */
    var updateDescription: String?
    
    required init(json: JSON) {
        super.init(json: json)
        
        appId = json["appId"].stringValue
        version = json["version"].stringValue
        buildVersion = json["buildVersion"].stringValue
        fileSize = json["fileSize"].intValue
        path = json["path"].stringValue
        downloadCount = json["downloadCount"].intValue
        updateDescription = json["updateDescription"].stringValue
        
    }
}
