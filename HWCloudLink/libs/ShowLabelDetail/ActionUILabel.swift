//
// ActionUILabel.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/6/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class ActionUILabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init() {
        self.init(frame: CGRect())
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        setup()
    }
  
    private func setup() {
        // do something.
        self.isUserInteractionEnabled = true
        // 添加双击手势
        let doubleClickGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleClickGestureCallBack(gesture:)))
        doubleClickGesture.numberOfTapsRequired = 2
        doubleClickGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleClickGesture)
    }
    
    deinit {
        CLLog("ActionUILabel deinit")
    }

}


extension ActionUILabel {
    // MARK: - 手势事件响应
    // MARK: 双击事件
    @objc func doubleClickGestureCallBack(gesture: UITapGestureRecognizer) {
        // 双击处理
        if self.text == nil {
            self.text = ""
        }
        
        CLLog("双击了事件，\(self.text!)")
        let textVC = WhiteTextViewController.init(nibName: "WhiteTextViewController", bundle: nil)
        textVC.showText = self.text!
        textVC.modalPresentationStyle = .overFullScreen
        textVC.modalTransitionStyle = .crossDissolve
        
        let currentVC = ViewControllerUtil.getCurrentViewController()
        currentVC.present(textVC, animated: true, completion: nil)
    }
}
