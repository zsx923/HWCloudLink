//
// VersionExplainViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class VersionExplainViewController: UIViewController {
    
//    @IBOutlet weak var versionLabel: UILabel!
//    @IBOutlet weak var versionDetailLabel: UILabel!
    //HW CloudLink 1.0.6
    @IBOutlet weak var versionNumLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        self.title = tr("版权说明")
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        

        // TODO: 暂时先添加（CFBundleVersion）， 后续需要删除
        self.versionNumLabel.text = "HW CloudLink " + NSString.getAppInfo(withKey: "CFBundleShortVersionString")
//            + "(" + NSString.getAppInfo(withKey: "CFBundleVersion") + ")"

//        self.versionDetailLabel.attributedText = UILabel.setLabelSpaceWithTextValue("版本所有软通动力信息技术（集团）股份有限公司2020。保留一切权利。本程序受版权法和架构保护法的保护，凡未经授权而擅自复制本软件的部分或全部内容，将要承担严厉的民事或刑事责任!", with: self.versionDetailLabel.font, andLineSpaceing: 6.0)
        
        self.descLabel.text = tr("版本所有软通动力信息技术（集团）股份有限公司2021。保留一切权利。本程序受版权法和架构保护法的保护，凡未经授权而擅自复制本软件的部分或全部内容，将要承担严厉的民事或刑事责任!")
    }

    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}
