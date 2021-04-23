//
//  BaseTextField.swift
//  HWCloudLink
//
//  Created by mac on 2021/2/20.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class BaseTextField: UITextField {
    //去除粘贴功能
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    
}
