//
// AlertSingleTextFieldViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol AlertSingleTextFieldViewDelegate: NSObjectProtocol {
    func alertSingleTextFieldViewViewDidLoad(viewVC: AlertSingleTextFieldViewController)
    func alertSingleTextFieldViewLeftBtnClick(viewVC: AlertSingleTextFieldViewController, sender: UIButton)
    func alertSingleTextFieldViewRightBtnClick(viewVC: AlertSingleTextFieldViewController, sender: UIButton)
}

class AlertSingleTextFieldViewController: UIViewController {

    static let vcID = "AlertSingleTextFieldViewController"
    @IBOutlet weak var backviewToRight: NSLayoutConstraint!

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backviewToLeft: NSLayoutConstraint!
    @IBOutlet weak var heightContraint: NSLayoutConstraint!
    // 标题
    @IBOutlet weak var showTitleLabel: UILabel!
    // 输入框
    @IBOutlet weak var showInputTextField: NoCopyTextField!
    
    @IBOutlet weak var showLeftBtn: UIButton!
    
    @IBOutlet weak var showRightBtn: UIButton!
    
    @IBOutlet weak var yoffset: NSLayoutConstraint!
    weak var customDelegate: AlertSingleTextFieldViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.customDelegate?.alertSingleTextFieldViewViewDidLoad(viewVC: self)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIApplication.shared.statusBarOrientation.isLandscape {
            self.yoffset.constant = (SCREEN_WIDTH - 150) / 2

            self.backviewToLeft.constant = (SCREEN_HEIGHT - heightContraint.constant * 2 - (isiPhoneXMore() ? 88 : 0)) / 2
            self.backviewToRight.constant = self.backviewToLeft.constant
            
        } else {
            self.yoffset.constant = (SCREEN_HEIGHT - 150) / 2
            
            self.backviewToLeft.constant = 36
            self.backviewToRight.constant = 36
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIApplication.shared.statusBarOrientation.isLandscape {
            self.yoffset.constant = (SCREEN_WIDTH - 150) / 2
//
            self.backviewToLeft.constant = (SCREEN_HEIGHT-(SCREEN_WIDTH-72))/2
            self.backviewToRight.constant = (SCREEN_HEIGHT-(SCREEN_WIDTH-72))/2
            
        }
    }
    
    @IBAction func touchBackView(_ sender: Any) {
        showInputTextField.resignFirstResponder()
    }
    
    // 显示/隐藏 密码
    @IBAction func clickEye(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.showInputTextField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func showLeftBtnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        self.customDelegate?.alertSingleTextFieldViewLeftBtnClick(viewVC: self, sender: sender)
    }
    
    @IBAction func showRightBtnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        self.customDelegate?.alertSingleTextFieldViewRightBtnClick(viewVC: self, sender: sender)
    }
    
    @objc func keyboardWillShow(notify: NSNotification) {
        let userInfo = notify.userInfo
        
        let keyboardRect = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardRect.size.height
        
        let bounds = self.view.bounds
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            
            let y = (SCREEN_WIDTH - 150) / 2
            if y < keyboardHeight && showInputTextField.isFirstResponder {
                let offsetY = y - (keyboardHeight - y) - 10
                self.yoffset.constant = offsetY
            }
        }else {
            
            let y = (bounds.height - 150) / 2
            if y < keyboardHeight {
                let offsetY = y - (keyboardHeight - y) - 10
                self.yoffset.constant = offsetY
            }
        }
    }
}
