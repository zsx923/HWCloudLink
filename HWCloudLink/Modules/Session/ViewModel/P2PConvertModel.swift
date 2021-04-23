//
//  P2PConvertModel.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2021/2/7.
//  Copyright © 2021 陈帆. All rights reserved.
//

import Foundation

class P2PConvertModel {
    //接收方信息
    var meetInfo: ConfBaseInfo?
    //呼叫方信息
    var callInfo: CallInfo?
    //静音键状态
    var silenceType: Bool = false
    
    //扬声器状态
    var soundType: Bool = false
    
    //是否点击了listenBtn按钮
    var isListenBtnClick = false
    
    
    
    var currentCalledSeconds: Int =  0
}
