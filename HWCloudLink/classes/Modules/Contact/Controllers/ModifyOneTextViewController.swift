//
// ModifyOneTextViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

typealias TextCallBack = (String)->()

class ModifyOneTextViewController: UIViewController {
    var textCallBack : TextCallBack?
    @IBOutlet weak var preserveBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    
    var localContactInfo : LocalContactModel?
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = tr("修改备注")
        textField.addTarget(self, action: #selector(textFieldValueChange), for: .editingChanged )
        textField.text = name
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.clear)
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldValueChange(textField: UITextField) {
        if textField.text?.count ?? 0 > 0 {
            preserveBtn.isEnabled = true
            preserveBtn.backgroundColor = UIColor(hexString: "0D94FF")
        }else{
            preserveBtn.isEnabled = false
            preserveBtn.backgroundColor = UIColor(hexString: "CCCCCC")
        }
    }
    
    /// 保存
    @IBAction func preserve(_ sender: UIButton) {
        if textField.text?.count == 0 {
            MBProgressHUD.showBottom(tr("请输入备注"), icon: nil, view: self.view)
            return
        }
        
        LocalContactBusiness.shareInstance.updateLocalContactName(id: (self.localContactInfo?.localContactId)!, name: textField.text!) { (isComplete) in
            // 修改完成
            self.textCallBack?(self.textField.text!)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
