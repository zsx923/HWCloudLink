//
// AboutCloudLinkViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
//, UITableViewDelegate,UITableViewDataSource
class AboutCloudLinkViewController: UIViewController {
    
    @IBOutlet weak var versionTitleLabel: UILabel!
    @IBOutlet weak var copyrightTitleLabel: UILabel!
    @IBOutlet weak var privacyTitleLabel: UILabel!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var newBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化
        self.title = tr("关于HW CloudLink")
        self.versionTitleLabel.text = tr("软件版本")
        self.copyrightTitleLabel.text = tr("版权说明")
        self.privacyTitleLabel.text = tr("隐私声明")
        self.newBtn.layer.cornerRadius = 9
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        displayVersionInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(hasUpgradeVersionNotify), name: .AppStoreHasUpgradeVersion, object: nil)
    }
    
    @objc func hasUpgradeVersionNotify() {
        self.displayVersionInfo()
    }
    
    private func displayVersionInfo() {
        
        let manager = UpgradeManager.shared
        let hasNewVersion = manager.hasNewVersion()
        
        arrowIcon.isHidden = !hasNewVersion
        newBtn.isHidden = !hasNewVersion
        
        versionLabel.text = hasNewVersion ? manager.appStoreVersion : manager.localVersion()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func versionUpgradeBtn(_ sender: Any) {
        if UpgradeManager.shared.hasNewVersion() {
            UpgradeManager.shared.jumpToAppStore()
        }
    }
    
    @IBAction func copyrightBtn(_ sender: Any) {
        let versionExplainViewVC = VersionExplainViewController.init()
        self.navigationController?.pushViewController(versionExplainViewVC, animated: true)
    }
    
    @IBAction func privacyStatementBtn(_ sender: Any) {
        let privateExplainViewVC = PrivateExplainViewController.init()
        self.navigationController?.pushViewController(privateExplainViewVC, animated: true)
    }
    
    
}
