//
//  UserSettingModel.swift
//  HWCloudLink
//
//  Created by JYF on 2020/7/21.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class UserSettingModel {
    
    let sqlTabelName = "user_setting_table"
    
    var userAccount: String = ""
    var videpDefinitionPolicy: Int = 2 // 视频清晰度 ，默认流畅优先SDK取值2标清, 图像质量优先SDK取值1高清。
    var logUploadIsOn: Int = 0 // 日志是否开启 默认为开启
    var languageSwitch: String = "China" // 语言选择 默认中文
    var micIsOpen: Int = 1// 麦克风是否开启 默认开启
    var videoIsOpen: Int = 1// 摄像头是否开启 默认开启
    var shakeIsOpen: Int = 1 // 振动是否开启 默认开启
    var ringIsOpen: Int = 1 // 铃声是否开启 默认开启
    //备注信息
    var remark1: String = ""
    var remark2: String = ""
    var remark3: String = ""
    var remark4: String = ""

    
}
