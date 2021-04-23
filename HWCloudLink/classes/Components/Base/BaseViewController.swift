//
//  BaseViewController.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/11/20.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: 添加默认返回按钮
    func addReturnBarBtnItem(){
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(returnPopController(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
    }
    //MARK: 添加自定义返回按钮
    func addReturnBarBtnItem(imageName: String){
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: imageName), style: .plain, target: self, action: #selector(returnPopController(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
    }
    
    
    
    @objc public func returnPopController(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
     
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
