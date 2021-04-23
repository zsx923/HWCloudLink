//
// TextTitleViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol TextTitleViewDelegate: NSObjectProtocol {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController)
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton)
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton)
}

class TextTitleViewController: UIViewController {

    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showLeftBtn: UIButton!
    
    @IBOutlet weak var showRightBtn: UIButton!
    
    weak var customDelegate: TextTitleViewDelegate?
    
    // 是否取消背景点击界面消失功能
    open var isCancelBgViewTouch = false
    
    var vcTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
                
        self.customDelegate?.textTitleViewViewDidLoad(viewVC: self)
                
        self.showLeftBtn.addTarget({ [weak self] (sender) in
            guard let self = self else {return}
            self.customDelegate?.textTitleViewLeftBtnClick(viewVC: self, sender: sender!)
            self.dismiss(animated: true, completion: nil)
        }, andEvent: .touchUpInside)
        
        self.showRightBtn.addTarget({ [weak self] (sender) in
            guard let self = self else {return}
            self.customDelegate?.textTitleViewRightBtnClick(viewVC: self, sender: sender!)
            self.dismiss(animated: true, completion: nil)
        }, andEvent: .touchUpInside)
    }

    @IBAction func backgroundBtnClick(_ sender: Any) {
        if !isCancelBgViewTouch {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        CLLog("TextTitleViewController deinit")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
