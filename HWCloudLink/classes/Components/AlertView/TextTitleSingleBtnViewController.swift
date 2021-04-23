//
// TextTitleSingleBtnViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol TextTitleSingleBtnViewDelegate: NSObjectProtocol {
    func textTitleSingleBtnViewDidLoad(viewVC: TextTitleSingleBtnViewController)
    func textTitleSingleBtnViewSureBtnClick(viewVC: TextTitleSingleBtnViewController, sender: UIButton)
}

class TextTitleSingleBtnViewController: UIViewController {
    var showTitle: String?
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var labBgView: UIView!
    
    @IBOutlet weak var showSureBtn: UIButton!
    @IBOutlet weak var btnBgView: UIView!
    
    @IBOutlet weak var bgView: UIView!
    
    weak var customDelegate: TextTitleSingleBtnViewDelegate?
    
    var viewDidLoadClosure: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showTitleLabel.text = self.showTitle
        self.showSureBtn.setTitle(tr("确定"), for: .normal)
        self.showSureBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
        self.showTitleLabel.textColor = UIColor.colorWithSystem(lightColor: "#000000", darkColor: "#CCCCCC")
        self.showTitleLabel.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#262626")
        self.labBgView.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#262626")
        self.showSureBtn.backgroundColor = UIColor.colorWithSystem(lightColor: "#f9f9f9", darkColor: "#303030")
        self.btnBgView.backgroundColor = UIColor.colorWithSystem(lightColor: "#f9f9f9", darkColor: "#303030")
        self.bgView.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#262626")
        
        self.customDelegate?.textTitleSingleBtnViewDidLoad(viewVC: self)
        
        self.showSureBtn.addTarget({ [weak self] (sender) in
            guard let self = self else {return}
            self.dismiss(animated: true, completion: nil)
            self.customDelegate?.textTitleSingleBtnViewSureBtnClick(viewVC: self, sender: sender!)
        }, andEvent: .touchUpInside)
        
        self.viewDidLoadClosure?()
    }
    
    @IBAction func backgroundBtnClick(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
    }

    deinit {
        CLLog("TextTitleSingleBtnViewController deinit")
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
