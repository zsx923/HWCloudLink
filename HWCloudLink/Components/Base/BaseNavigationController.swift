//
//  BaseNavigationController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    private var isPushing = false
    
    
    private var titleLabel = UILabel.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var gapY: CGFloat = 0
        if UI_IS_BANG_SCREEN {
            gapY = 0
        }
        self.titleLabel.frame = CGRect.init(x: 40, y: gapY, width: SCREEN_WIDTH - 80, height: 44)
        self.titleLabel.font = UIFont.systemFont(ofSize: 20.0)
        self.titleLabel.textColor = UIColor.colorWithSystem(lightColor: "#000000", darkColor: "#F0F0F0")
        self.titleLabel.textAlignment = NSTextAlignment.left
        setNaviIsHidden(ishidden: true, isAnimate: false)
        self.navigationBar.addSubview(self.titleLabel)
        self.navigationBar.backgroundColor = UIColor.colorWithSystem(lightColor: "#FFFFFF", darkColor: "#000000")
        self.navigationBar.tintColor = UIColor.colorWithSystem(lightColor: "#000000", darkColor: "#F0F0F0")
        
        self.delegate = self
    }
    
    func updateNaviTitle(currentVC: UIViewController) {
        setNaviIsHidden(ishidden: true, isAnimate: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.titleLabel.text = currentVC.title
            self.setNaviIsHidden(ishidden: self.children.count == 1, isAnimate: true)
        }
    }
    
    func updateTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func setNaviIsHidden(ishidden: Bool, isAnimate: Bool) {
        if !isAnimate {
            self.titleLabel.alpha = ishidden ? 0.0 : 1.0
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.titleLabel.alpha = ishidden ? 0.0 : 1.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 适配暗黑模式
    fileprivate func hookTraitCollectionDidChange(_ viewController: UIViewController) {
        let wrappedBlock:@convention(block) (AspectInfo)-> Void = { aspectInfo in
            MyThemes.switchNight(isToNight: MyThemes.isNight())
        }
        let wrappedObject: AnyObject = unsafeBitCast(wrappedBlock, to: AnyObject.self)
        do {
            try viewController.aspect_hook(#selector(traitCollectionDidChange(_:)), with: AspectOptions.init(rawValue: 0), usingBlock: wrappedObject)
            
        } catch {
            CLLog("hook traitCollectionDidChange fail")
        }
    }
    
    //每一次push都会执行这个方法，push之前设置viewController的hidesBottomBarWhenPushed
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if isPushing,AppDelegate.isInToSession {
            CLLog("被拦截")
            return
        } else {
            isPushing = true
        }
//
        
        hookTraitCollectionDidChange(viewController)
        
        if animated {
            viewController.hidesBottomBarWhenPushed = true
            super.pushViewController(viewController, animated: true)
            viewController.hidesBottomBarWhenPushed = false
        } else {
            super.pushViewController(viewController, animated: animated)
        }
        updateNaviTitle(currentVC: viewController)
        
        
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        //以下函数是对返回上一级界面之前的设置操作
        //每一次对viewController进行push的时候，会把viewController放入一个栈中
        //每一次对viewController进行pop的时候，会把viewController从栈中移除
        if self.children.count == 2
        {
            //如果viewController栈中存在的ViewController的个数为两个，再返回上一级界面就是根界面了
            //那么要对tabbar进行显示
            let controller:UIViewController = self.children[0]
            controller.hidesBottomBarWhenPushed = false
            updateNaviTitle(currentVC: controller)
        } else {
            //如果viewController栈中存在的ViewController的个数超过两个，对要返回到的上一级的界面设置hidesBottomBarWhenPushed = true
            //把tabbar进行隐藏
            let count = self.children.count-2
            
            if count < 0 {
                return super.popViewController(animated: animated)
            }
            let controller = self.children[count]
            controller.hidesBottomBarWhenPushed = true
            updateNaviTitle(currentVC: controller)
        }
        
        
        return super.popViewController(animated: animated)
    }
    
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        let index = self.viewControllers.index(of: viewController)
        
        if index == 0
        {
            viewController.hidesBottomBarWhenPushed = false
            
        }
        else
        {
            viewController.hidesBottomBarWhenPushed = true
        }
        updateNaviTitle(currentVC: viewController)
        
        return super.popToViewController(viewController, animated: animated)
    }
    
    
    /// 回退到指定的类页面
    ///
    /// - Parameters:
    ///   - customClass: 类 class
    ///   - animated: 是否动画
    func popToTargetVC(customClass: AnyClass, animated: Bool) {
        for vc in self.viewControllers {
            if vc.classForCoder == customClass {
                _ = self.popToViewController(vc, animated: animated)
                updateNaviTitle(currentVC: vc)
                break
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return APP_DELEGATE.rotateDirection
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let isDark = self.traitCollection.userInterfaceStyle == .dark
        self.titleLabel.textColor = UIColor(hexString: isDark ? "#F0F0F0" : "#000000")
        self.navigationBar.backgroundColor = UIColor(hexString: isDark ? "#000000": "#FFFFFF")
    }
    
    deinit {
        CLLog("BaseNavigationController deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        isPushing = false
    }
}
