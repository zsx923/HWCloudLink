//
//  UIColorExtensionFile.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/11/19.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

extension UIColor {
    static func colorWithSystem(lightColor: String, darkColor: String) -> UIColor {
        guard let light = UIColor(hexString: lightColor) else { return UIColor.clear }
        guard let dark = UIColor(hexString: darkColor) else { return UIColor.clear }
        return UIColor.colorWithSystem(lightColor: light, darkColor: dark)
    }
    
    static func colorWithSystem(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .light {
                    return lightColor;
                } else {
                    return darkColor;
                }
            }
        } else {
            return lightColor
        }
    }
}
