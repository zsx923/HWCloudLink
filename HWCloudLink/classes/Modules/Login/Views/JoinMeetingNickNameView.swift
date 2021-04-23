//
//  JoinMeetingNickNameView.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/12/15.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class JoinMeetingNickNameView: BaseCustomView, UITextFieldDelegate {

    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var confirmAvtion: UIButton!
    var passActionSureBlock: ((_ isYES: Bool ,_ text: String)->Void)?
    
    static func creatJoinMeetingNickNameView() ->JoinMeetingNickNameView {
        return loadNibView(nibName: "JoinMeetingNickNameView") as! JoinMeetingNickNameView
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        //第一次获取手机型号，如果改动存储用户输入的，
        let result = UserDefaults.standard.object(forKey:"nickJoinMeeting_defaultName")
        if result != nil {
            nickTextField.text = result as? String
        } else {
            nickTextField.text = UIDevice.current.name
        }
        nickTextField.delegate = self
        addView.layer.cornerRadius = 4
        addView.layer.masksToBounds = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    //MARK: - 清除昵称
    @IBAction func clearBtn(_ sender: Any) {
        nickTextField.text = ""
        confirmAvtion.isEnabled  = false
        confirmAvtion.setTitleColor(UIColor.init(hexString: "#CCCCCC"), for:.normal)
    }

    //MARK: - 取消
    @IBAction func cancleBtn(_ sender: Any) {
        if passActionSureBlock != nil {
            passActionSureBlock!(false,"")
        }
        self.removeFromSuperview()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //((textField.text ?? "").count >= 6) ? false : true
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        if nowString.count>0 {
            confirmAvtion.isEnabled  = true
            confirmAvtion.setTitleColor(UIColor.init(hexString: "#0D94FF"), for:.normal)
        }else {
            confirmAvtion.isEnabled  = false
            confirmAvtion.setTitleColor(UIColor.init(hexString: "#CCCCCC"), for:.normal)
        }
        return nowString.count <= 64
    }
    //MARK: - 确认
    @IBAction func makeSureBtn(_ sender: Any) {
        if nickTextField.text?.count == 0  {
            MBProgressHUD.showBottom(tr("请输入昵称"), icon: nil, view: self)
            return
        }
        //把用户输入的存储在本地
        UserDefaults.standard.setValue(nickTextField.text, forKey: "nickJoinMeeting_defaultName")
        if passActionSureBlock != nil {
            passActionSureBlock!(true,nickTextField.text!)
        }
        self.removeFromSuperview()
    }
}
