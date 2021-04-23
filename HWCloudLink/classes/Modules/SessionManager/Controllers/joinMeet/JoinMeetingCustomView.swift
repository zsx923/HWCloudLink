//
//  JoinMeetingCustomView.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/12/4.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class JoinMeetingCustomView: BaseCustomView ,UITextFieldDelegate {

    
    @IBOutlet var secureTextField: UITextField!
    @IBOutlet var lineLabel: UILabel!
    //确定回调密码
    var passSecureValueBlock: ((_ secureStr: String)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
         secureTextField.delegate = self
    }
    
    static func creatJoinMeetingCustomView() -> JoinMeetingCustomView {
        return loadNibView(nibName: "JoinMeetingCustomView") as! JoinMeetingCustomView
    }

    
    @IBAction func clearBtn(_ sender: Any) {
        secureTextField.text = ""
    }
    
    
    @IBAction func clickCancleBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    @IBAction func makeSureBtn(_ sender: Any) {
        if secureTextField.text?.count == 0 {
            MBProgressHUD.showBottom("请输入会议密码", icon: nil, view: self)
            return
        }
        self.removeFromSuperview()
        if passSecureValueBlock != nil {
            passSecureValueBlock!(secureTextField.text!)
        }
    }
    
    
}

extension JoinMeetingCustomView {
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        lineLabel.backgroundColor =
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
