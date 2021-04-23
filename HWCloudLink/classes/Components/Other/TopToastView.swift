//
// TopToastView.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/26.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TopToastView: UIView {
    static let VIEW_HEIGHT: CGFloat = 30.0

    private let showImageView = UIImageView.init()
    private let showTitleLabel = UILabel.init()
    
    //是否有网的属性
    var isHaveNet = true
    // 是否显示无网络提示
    var isShowNetToast = false
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    static let shareInstance = TopToastView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: TopToastView.VIEW_HEIGHT))
    
    // SessionViewController
    static let sessionViewToast = TopToastView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: TopToastView.VIEW_HEIGHT))
    
    // ContactViewController
    static let contactViewToast = TopToastView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: TopToastView.VIEW_HEIGHT))
    
    // MineViewController
    static let mineViewToast = TopToastView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: TopToastView.VIEW_HEIGHT))
    
    // LoginViewController
    static let loginViewToast = TopToastView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: TopToastView.VIEW_HEIGHT))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        // imageview
        let imageWH: CGFloat = 16.0
        let GAP_X: CGFloat = 16.0
        self.showImageView.frame = CGRect.init(x: GAP_X, y: (TopToastView.VIEW_HEIGHT - imageWH) / 2, width: imageWH, height: imageWH)
        
        // title
        self.showTitleLabel.frame = CGRect.init(x: GAP_X + imageWH + GAP_X/2, y: 0, width: SCREEN_WIDTH - (2*GAP_X + imageWH + GAP_X), height: TopToastView.VIEW_HEIGHT)
        self.showTitleLabel.textColor = UIColorFromRGB(rgbValue: 0x999999)
        self.showTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
        
        self.addSubview(self.showImageView)
        self.addSubview(self.showTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWarning(text: String, isAddToView: Bool = true) {
        self.showTitleLabel.text = text
        self.backgroundColor = UIColorFromRGBA(rgbValue: 0xFFA700, alpha: 0.05)
        
        self.showImageView.image = UIImage.init(named: "top_toast_warning")
        if isAddToView {
            self.addtoView()
        } else {
            self.backgroundColor = UIColorFromRGB(rgbValue: 0xfffbf2)
        }
    }
    
    func showError(text: String) {
        self.showTitleLabel.text = text
        self.backgroundColor = UIColorFromRGB(rgbValue: 0xF34B4B)
        
        self.showImageView.image = UIImage.init(named: "top_toast_warning")
        self.addtoView()
    }
    
    func showNormal(text: String) {
        self.showTitleLabel.text = text
        self.backgroundColor = UIColorFromRGB(rgbValue: 0xFAFAFA)
        
        self.showImageView.image = UIImage.init(named: "top_toast_warning")
        self.addtoView()
    }
    
    func hideToast() {
        self.removeFromSuperview()
    }
    
    private func addtoView() {
//        let windowTemp = (UIApplication.shared.delegate?.window)!
//
//        // 获取根控制器
//        var currentViewController = windowTemp?.rootViewController
//        while true {
//            if ((currentViewController?.presentedViewController) != nil) {
//                currentViewController = currentViewController?.presentedViewController
//            } else if (currentViewController?.isKind(of: UINavigationController.classForCoder()))! {
//                let navigationVC = currentViewController as! UINavigationController
//                currentViewController = navigationVC.children.last
//            } else if (currentViewController?.isKind(of: UITabBarController.classForCoder()))! {
//                let tabbarVC = currentViewController as! UITabBarController
//                currentViewController = tabbarVC.selectedViewController
//            } else {
//                let childVCCount = currentViewController?.children.count;
//                if childVCCount! > 0 {
//                    currentViewController = currentViewController?.children.last
//                }
//                break
//            }
//        }
//
//        if SCREEN_HEIGHT > 800.0 {
//            self.y = 0
//        } else {
//            self.y = 0
//        }
//
//        currentViewController?.view.addSubview(self)
        
        if SCREEN_HEIGHT > 800.0 {
            self.y = 44 + 44
        } else {
            self.y = 20 + 44
        }
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
}

// 网络异常
extension TopToastView {
    static func showNetworkTopToast() {
        TopToastView.sessionViewToast.isHidden = false
        TopToastView.contactViewToast.isHidden = false
        TopToastView.mineViewToast.isHidden = false
    }
    
    static func hideNetworkTopToast() {
        TopToastView.sessionViewToast.isHidden = true
        TopToastView.contactViewToast.isHidden = true
        TopToastView.mineViewToast.isHidden = true
        TopToastView.loginViewToast.isHidden = true
    }
}
