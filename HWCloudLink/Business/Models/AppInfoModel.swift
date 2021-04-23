//
//  AppInfoModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/1/31.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class AppInfoModel: BaseModel {
    /**
     * 用户id
     */
    var userId: String?
    
    /**
     * 系统类型编码
     */
    var systemTypeCode: String?
    
    /**
     * 应用名称
     */
    var name: String?
    
    /**
     * 最新版本
     */
    var latestVersion: String?
    
    /**
     * 最新编译版本
     */
    var latestBuildVersion: String?
    
    /**
     * 最新更新说明
     */
    var latestUpdateDescription: String?
    
    /**
     * 最新强制更新版本
     */
    var latestForceVersion: String?
    
    /**
     * 下载次数
     */
    var downloadCount: Int?
    
    /**
     * 包名
     */
    var applicationIdentifier: String?
    
    /**
     * 图标
     */
    var icon: String?
    
    /**
     * 介绍
     */
    var description: String?
    
    /**
     * 安装方式编码
     */
    var installTypeCode: String?
    
    /**
     * 安装密码
     */
    var installPassword: String?
    
    /**
     * 关联应用id
     */
    var associateAppId: String?
    
    /**
     * IOS商店id
     */
    var iosStoreId: String?
    
    /**
     * 版本
     */
    var versions: [AppVersionModel]?
    
    /**
     * 图片
     */
    var images: [AppImageModel]?
    
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        userId = json["userId"].stringValue
        systemTypeCode = json["systemTypeCode"].stringValue
        name = json["name"].stringValue
        latestVersion = json["latestVersion"].stringValue
        latestBuildVersion = json["latestBuildVersion"].stringValue
        latestUpdateDescription = json["latestUpdateDescription"].stringValue
        latestForceVersion = json["latestForceVersion"].stringValue
        downloadCount = json["downloadCount"].intValue
        applicationIdentifier = json["applicationIdentifier"].stringValue
        icon = json["icon"].stringValue
        description = json["description"].stringValue
        installTypeCode = json["installTypeCode"].stringValue
        installPassword = json["installPassword"].stringValue
        associateAppId = json["associateAppId"].stringValue
        iosStoreId = json["iosStoreId"].stringValue
        versions = json["versions"].arrayValue.map({ (json) -> AppVersionModel in
            AppVersionModel(json: json)
        })
        images = json["images"].arrayValue.map({ (json) ->AppImageModel in
            AppImageModel(json: json)
        })
    }
}
