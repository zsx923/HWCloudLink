//
//  UIButton+ImagePosition.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2020/12/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

enum ImagePosition {
        case top          //图片在上，文字在下，垂直居中对齐
        case bottom       //图片在下，文字在上，垂直居中对齐
        case left         //图片在左，文字在右，水平居中对齐
        case right        //图片在右，文字在左，水平居中对齐
}

extension UIButton {
    
    func setImageName(normalImg: String, pressImg: String, title: String) {
        self.setImage(UIImage(named: normalImg), for: UIControl.State.normal)
        self.setImage(UIImage(named: pressImg), for: UIControl.State.highlighted)
        self.setTitle(title, for: UIControl.State.normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel?.backgroundColor = .clear
        self.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.tintColor = .white
        
        self.imagePosition(style: .top, spacing: 16)
    }
    
    func setImageName(normalImg: String, pressImg: String, disableImg: String, title: String) {
        self.setImage(UIImage(named: normalImg), for: UIControl.State.normal)
        self.setImage(UIImage(named: pressImg), for: UIControl.State.highlighted)
        self.setImage(UIImage(named: disableImg), for: UIControl.State.disabled)
        self.setTitle(title, for: UIControl.State.normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel?.backgroundColor = .clear
        self.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.tintColor = .white
        
        self.imagePosition(style: .top, spacing: 16)
    }
    
    func setImageName(_ imageName: String, title: String) {
        let size = CGSize(width: 24, height: 24)
        let image = UIImage.scal(toSize: UIImage(named: imageName), size: size)
        self.setImage(image, for: UIControl.State.normal)
        self.setTitle(title, for: UIControl.State.normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel?.backgroundColor = .clear
        self.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.tintColor = .white
        self.accessibilityIdentifier = imageName
        
        self.imagePosition(style: .top, spacing: 16)
    }
    
    /// - Parameters:
    ///   - style: 图片位置
    ///   - spacing: 按钮图片与文字之间的间隔
    func imagePosition(style: ImagePosition, spacing: CGFloat) {
        //得到imageView和titleLabel的宽高
        let imageWidth = self.imageView?.frame.size.width
        let imageHeight = self.imageView?.frame.size.height
        
        var labelWidth: CGFloat! = 0.0
        var labelHeight: CGFloat! = 0.0
        
        labelWidth = self.titleLabel?.intrinsicContentSize.width
        labelHeight = self.titleLabel?.intrinsicContentSize.height
        
        //初始化imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        
        //根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch style {
        case .top:
            //上 左 下 右
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-spacing/2, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!, bottom: -imageHeight!-spacing/2, right: 0)
            break;
            
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
            break;
            
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight!-spacing/2, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight!-spacing/2, left: -imageWidth!, bottom: 0, right: 0)
            break;
            
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+spacing/2, bottom: 0, right: -labelWidth-spacing/2)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!-spacing/2, bottom: 0, right: imageWidth!+spacing/2)
            break;
            
        }
        
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
        
    }
}
