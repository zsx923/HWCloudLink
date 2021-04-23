//
//  NetLevel.swift
//  HWCloudLink
//
//  Created by mac on 2021/3/25.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class NetLevel {
    
    private var upLevel = "5"
    private var downLevel = "5"
    private var agoLevel  = 5

    func getCurrenLevel(isVoice:Bool = false, notfication: Notification) -> (level: String, image: UIImage?)? {
        
        guard let userInfo = notfication.userInfo as? [String:String], let tempDownLevel = Int(userInfo["netLevel"] ?? ""), let tempUpLevel = Int(userInfo["upNetLevel"] ?? "") else {
            CLLog("- 为获取到\(isVoice ? "音频" : "视频")质量变化返回结果 -")
            return nil
        }
        CLLog("--------当前\(isVoice ? "音频" : "视频")网络状态 - 下行\(tempDownLevel) - 上行\(tempUpLevel)--------")
        //肯定不需要刷新图标
        if downLevel == "\(tempDownLevel)", upLevel == "\(tempUpLevel)" {
            return nil
        }
        
        //需要提示
        if tempDownLevel <= 3 || tempUpLevel <= 2 {
            CLLog("当前网络状况较差提示了")
//            MBProgressHUD.showBottom(tr("当前网络状况较差"), icon: nil, view: nil)
            Toast.showBottomMessage("当前网络状况较差")
        }
        
        //是否需要刷新图标
        downLevel = "\(tempDownLevel)"
        upLevel = "\(tempUpLevel)"
        //新方案 图标只和下行有关，和上行无关 (保留上行  万一有改方案呢)
        return compareAgoLevel(with: caculateToRefresh(upLevel: tempUpLevel, downLevel: tempDownLevel))
    }
    
    private func caculateToRefresh(upLevel: Int , downLevel: Int) -> String {
        
//        if upLevel <= 3, downLevel <= 2 {  //这种情况只能去一种
//            // 因为2，3 是一张图片 0，1是另一张图片， 所以需要具体判断
//            if upLevel <= 1 {
//                CLLog("--------上行--------\(upLevel)")
//                return "\(upLevel)"
//            }
//            if downLevel <= 1 {
//                CLLog("--------下行--------\(downLevel)")
//                return "\(downLevel)"
//            }
//            //2，3一张图片， 随便返回 这里取上行
//            CLLog("--------上行--------\(upLevel)")
//            return "\(upLevel)"
//        }
//
//        if upLevel > 3, downLevel <= 2 { //取相对差的
//            CLLog("--------下行--------\(downLevel)")
//            return "\(downLevel)"
//        }
//
//        if upLevel <= 3, downLevel > 2 { //取相对差的
//            CLLog("--------上行--------\(upLevel)")
//            return "\(upLevel)"
//        }
//
//      剩余的的情况 因为4，5取的是同一张图片显示，所以可以随便取一个 这里取xia行
        // 新方案
        CLLog("--------下行--------\(downLevel)")
        return "\(downLevel)"
        
        
    }
    
    private func compareAgoLevel(with level: String) ->(level: String,image: UIImage?)? {
        guard let level = Int(level) else {
            return nil
        }
        if agoLevel == level {
            return nil
        }else {
            switch (agoLevel, level) {
            case (4...5,4...5),(2...3,2...3),(0...1,0...1) :
                agoLevel = level
                return nil
            default:
                agoLevel = level
                return ("\(level)",SessionHelper.getSignalQualityImage(netLevel: "\(level)"))
            }
        }
    }
}
