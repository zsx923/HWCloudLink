//
//  CallKeyViewController.swift
//  HWCloudLink
//
//  Created by mac on 2021/1/9.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class CallKeyViewController: UIViewController {

    fileprivate var arrayStr = NSMutableArray.init()
    fileprivate var mutableStr = NSMutableString.init()
    
    @IBOutlet weak var numberTextField: UITextField!
    
    @IBOutlet weak var clearBtn: UIButton!
    
    private var isClickVideoBtn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = tr("拨号盘")
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        numberTextField.placeholder = tr("请输入号码")
        clearBtn.isHidden = true
        
        //检测是否横屏改变约束
        
    }
    
    // MARK: 返回
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func numberBtnClick(_ sender: UIButton) {
        mutableStr.append(sender.titleLabel?.text ?? "" as String)
//        numberTextField.text = SessionHelper.setCallKeyType(meetingId: mutableStr as String, divideCount: 3)
        numberTextField.text = mutableStr as String
        clearBtn.isHidden =  (numberTextField.text?.count != 0) ? false : true
        
    }
    //clearBtn
    @IBAction func clearBtn(_ sender: Any) {
        if ((numberTextField.text?.count) != 0) {
//            var numberStr = numberTextField.text?.replacingOccurrences(of: " ", with: "")
            var numberStr = numberTextField.text
            numberStr?.removeLast()
//            numberTextField.text = SessionHelper.setCallKeyType(meetingId: numberStr ?? "", divideCount: 3)
            numberTextField.text = numberStr
            mutableStr = ""
            mutableStr.append(numberStr ?? "")
        }
        
        clearBtn.isHidden =  (numberTextField.text?.count != 0) ? false : true
        
    }
    
    //视频
    @IBAction func videoCallBtn(_ sender: Any) {
        isClickVideoBtn = true
        if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
            self.getAuthAlertWithAccessibilityValue(value: "10")
            return
        }
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        
        if numberTextField.text?.count == 0 {
            return MBProgressHUD .showBottom(tr("请输入号码"), icon: "", view: nil)
        }
        CLLog("=视频点呼==\(NSString.encryptNumber(with: mutableStr as String) ?? "")")
        SessionManager.shared.startCall(isVideo: true, name: mutableStr as String, number: mutableStr as String, depart: "")
    }
    
    
    //语音
    @IBAction func voiceCallBtn(_ sender: Any) {
        isClickVideoBtn = false
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        
        if numberTextField.text?.count == 0 {
            return MBProgressHUD .showBottom(tr("请输入号码"), icon: "", view: nil)
        }
        CLLog("=语音点呼=\(NSString.encryptNumber(with: mutableStr as String) ?? "")")
        SessionManager.shared.startCall(isVideo: false, name: mutableStr as String, number: mutableStr as String, depart: "")
    }
    
    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension CallKeyViewController: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("视频呼叫需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("\(self.isClickVideoBtn ? "视频" : "语音")呼叫需要开启麦克风权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
    }
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
    }
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        viewVC.dismiss(animated: true, completion: nil)
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
