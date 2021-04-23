//
//  PageResultModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class PageResultModel<T: JSONMappable>: JSONMappable {
    
    
    /// 总条数
    var totalCount: Int?
    
    /// 总页数
    var totalPage: Int?
    
    /// 当前页面
    var pageNo: Int?
    
    /// 每页条数
    var pageSize: Int?
    
    /// 数据列表
    var beanList: [T]?
    
    required init(json: JSON) {
        totalCount = json["totalCount"].intValue
        totalPage = json["PageCount"].intValue
        pageNo = json["pageNo"].intValue
        pageSize = json["pageSize"].intValue
        
        beanList = json["beanList"].arrayValue.map({ (json) -> T in
            T(json: json)
        })
    }

}
