//
//  UIColor+Gradient.swift
//  PictureInPicture
//
//  Created by mac on 2020/6/17.
//  Copyright © 2020 coderybxu. All rights reserved.
//

import UIKit

enum UIColorForGradientDirectionStyle: Int {
      case `default` = 0                 // 垂直Vertical
      case level = 1                     // 水平
      case upwardDiagonalLin = 2         // 主对角线方向渐变
      case downDiagonalLine = 3          // 副对角线方向渐变
}

extension UIColor {
    
    /// 返回渐变色
    /// - Parameters:
    ///   - size: 渐变区域的尺寸
    ///   - direction: 渐变方向
    ///   - start: 开始颜色
    ///   - end: 结束颜色
    static func gradient(size: CGSize, direction: UIColorForGradientDirectionStyle, start: UIColor, end: UIColor, locations:[NSNumber] = [0, 0.4]) ->UIColor{
        
        if size == .zero || start == end{
            return start
            
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        var startPoint: CGPoint = .zero
        if direction == .downDiagonalLine {
            startPoint = CGPoint(x: 0, y: 1)
        }
        gradientLayer.startPoint = startPoint
        
        var endtPoint: CGPoint = .zero
        
        switch direction {
        case .default:
            endtPoint = CGPoint(x: 0, y: 1)
        case .level:
            endtPoint = CGPoint(x: 1, y: 0)
        case .upwardDiagonalLin:
            endtPoint = CGPoint(x: 1, y: 1)
        default:
            endtPoint = CGPoint(x: 1, y: 0)
        }
        
        gradientLayer.endPoint = endtPoint
        
        gradientLayer.colors = [start.cgColor,end.cgColor]
        
        gradientLayer.locations = locations
        
        UIGraphicsBeginImageContext(size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        
        guard  let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return start
        }
        
        UIGraphicsEndImageContext()
        let color = UIColor(patternImage: image)
        return color
    }
}
