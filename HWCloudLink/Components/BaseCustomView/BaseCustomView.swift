//
//  BaseCustomView.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/11/19.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class BaseCustomView: UIView {

    class func loadNibView(nibName: String) -> UIView {
        return  Bundle.main.loadNibNamed(String(describing: nibName), owner: nil, options: nil)?.last as! UIView
    }
}
