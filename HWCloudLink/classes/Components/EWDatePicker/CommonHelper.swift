//
//  CommonHelper.swift
//  EWDatePicker
//
//  Created by Ethan.Wang on 2018/8/27.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import Foundation
import UIKit

struct ScreenInfo {
    static let Frame = UIScreen.main.bounds
    static let Height = Frame.height
    static let Width = Frame.width
    static let navigationHeight:CGFloat = navBarHeight()

    static func isIphoneX() -> Bool {
        let iphoneX = false
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone {
            return iphoneX
        }
        if #available(iOS 11.0, *) {
            let Window:UIWindow = APP_DELEGATE.window!
            if Window.safeAreaInsets.bottom != 0 {
                return true
            }
        }
        return iphoneX
    }    
    
    static private func navBarHeight() -> CGFloat {
        return isIphoneX() ? 88 : 64;
    }
}
//便捷的类方法
extension UIColor {
    class func colorWithRGBA(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}
