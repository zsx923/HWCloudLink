//
//  ImageTextButton.swift
//  HWCloudLink
//
//  Created by mac on 2020/5/22.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class ImageTextButton: UIButton {
    
    fileprivate lazy var image : UIImage = UIImage()

    override var frame: CGRect {
        
        didSet{
            
            self.layoutIfNeeded()
        }
    }
    
    func configImageTextButton(image: UIImage, title:String, titleFont: UIFont, tintColor: UIColor) {
        
        self.image = image
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        
        //设置属性
        self.tintColor = tintColor
        self.setTitleColor(tintColor, for: .normal)
        imageView?.contentMode = .center
        titleLabel?.contentMode = .center
        titleLabel?.backgroundColor = .clear
        titleLabel?.font = titleFont
        titleLabel?.textColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gapX = (self.width - image.size.width) / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: gapX, bottom: 16, right: gapX)
        titleEdgeInsets = UIEdgeInsets(top: self.image.size.height, left: -self.image.size.height, bottom: 0, right: 0)
        
    }
}
