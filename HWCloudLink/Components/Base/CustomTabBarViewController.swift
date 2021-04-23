//
// CustomTabBarViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController {
    
    private var tabBarTitles : Array<String> = [tr("会议"), tr("联系人"), tr("我的")]
    private let tabBarControllers : Array<String> = ["SessionViewController", "ContactViewController", "MineViewController"]
    private let tabBarIdentifiers : Array<String> = ["SessionView", "ContactView", "MineView"]
    private let tabBarimages : Array<String> = ["tab1_nor", "tab2_nor", "tab3_nor"]
    private let tabBarSelectedImages : Array<String> = ["tab1_sel", "tab2_sel", "tab3_sel"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = UIColor.colorWithSystem(lightColor: "#FAFAFA", darkColor: "#141414")
        var items : Array<UIViewController> = []
        for i in 0 ..< self.tabBarTitles.count {
            let vc = self.createTabbarItem(
                controllerString: tabBarControllers[i],
                      identifier: tabBarIdentifiers[i],
                           title: tabBarTitles[i],
                           image: tabBarimages[i],
                     selectImage: tabBarSelectedImages[i]
            )
            items.append(vc)
        }
        self.viewControllers = items
        
        // language change
        NotificationCenter.default.addObserver(self, selector: #selector(languageChange(notfic:)), name: NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noStreamAlertAction(notfic:)), name: NSNotification.Name.init("noStreamAlertNoti"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(oneMeetingNoti), name: NSNotification.Name.init(rawValue: "isOneMeetingNotiKey"), object: nil)
        SuspendTool.sharedInstance.suspendWindows.removeAll()
    }

    
    @objc func languageChange(notfic:Notification) {
        tabBarTitles = [tr("会议"), tr("联系人"), tr("我的")]
        for i in 0 ..< self.tabBarTitles.count {
            self.tabBar.items![i].title = tabBarTitles[i]
        }
    }
    
    @objc private func noStreamAlertAction(notfic: Notification) {
        let alert = UIAlertController(title: tr("当前未收到会议码流，会议已结束"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: tr("确定"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createTabbarItem(controllerString: String, identifier: String, title: String, image: String, selectImage: String) -> BaseNavigationController {
        let storyboard = UIStoryboard.init(name: controllerString, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        let nav = BaseNavigationController.init(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = UIImage.init(named: image)
        nav.tabBarItem.selectedImage = UIImage.init(named: selectImage)
        if vc.classForCoder == ContactViewController.classForCoder() {
            // 触发ContactViewController加载
            vc.view.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.black)
        }
        return nav
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let isDark = self.traitCollection.userInterfaceStyle == .dark
        self.tabBar.backgroundColor = UIColor(hexString: isDark ? "#141414" : "#FAFAFA")
    }
    
    deinit {
        CLLog("CustomTabBarViewController deinit")
        NotificationCenter.default.removeObserver(self)
    }
}

