//
//  FeedBackAnswerViewController.swift
//  HWCloudLink
//
//  Created by 严腾飞 on 2020/7/17.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class FeedBackAnswerViewController: UIViewController {
    
    private var contentLabel: UILabel = {
        let contentLabel = UILabel(frame: CGRect(x: 16, y: 16, width: kScreenWidth - 32, height: 200))
        contentLabel.textColor = UIColorFromRGB(rgbValue: 0x2A2A2A)
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont(name: "HuaweiSans", size: 14)
        return contentLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        contentLabel.text = "目前一个手机号只能绑定一个HW CloudLink帐号。目前一个手机号只能绑定一个HW CloudLink帐号。目前一个手机号只能绑定一个HW CloudLink帐号。目前一个手机号只能绑定一个HW CloudLink帐号"
        contentLabel.sizeToFit()
        view.addSubview(contentLabel)
    }

}
