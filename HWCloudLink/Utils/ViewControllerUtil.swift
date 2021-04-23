//
//  ViewControllerUtil.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/12/4.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
class ViewControllerUtil: NSObject {
    // MARK: - 获取当前控制器
    static func getCurrentViewController() -> UIViewController {
        let windowTemp = (UIApplication.shared.delegate?.window)!
        
        // 获取根控制器
        var currentViewController = windowTemp?.rootViewController
        while true {
            if currentViewController?.presentedViewController != nil {
                currentViewController = currentViewController?.presentedViewController
            } else if currentViewController?.isKind(of: UINavigationController.classForCoder()) ?? false {
                let navigationVC = currentViewController as! UINavigationController
                currentViewController = navigationVC.children.last
            } else if currentViewController?.isKind(of: UITabBarController.classForCoder()) ?? false {
                let tabbarVC = currentViewController as! UITabBarController
                currentViewController = tabbarVC.selectedViewController
            } else {
                let childVCCount = currentViewController?.children.count ?? 0
                if childVCCount > 0 {
                    currentViewController = currentViewController?.children.last
                }
                return currentViewController!
            }
        }
        
        return currentViewController!
    }
    
    // 设置导航栏样式
    static func setNavigationStyle(navigationVC: UINavigationController?) {
        
        // 去掉分割线
//        navigationVC?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.clear]
        navigationVC?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        navigationVC?.navigationBar.shadowImage = UIImage.init()
        navigationVC?.navigationBar.isTranslucent = false
    }
    
}
