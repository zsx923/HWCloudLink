//
// UpgradeViewController.swift
// HWCloudLink
// Notes：
//
// Created by wangyh on 2020/12/23.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol UpgradeViewDelegate: NSObjectProtocol {
    func textTitleViewViewDidLoad(viewVC: UpgradeViewController)
    func textTitleViewRightBtnClick(viewVC: UpgradeViewController, sender: UIButton)
}

class UpgradeViewController: UIViewController {

    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var releaseNotesTextView: UITextView!
    
    @IBOutlet weak var showLeftBtn: UIButton!
    
    @IBOutlet weak var showRightBtn: UIButton!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    weak var customDelegate: UpgradeViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                       
        self.customDelegate?.textTitleViewViewDidLoad(viewVC: self)
        
        self.showRightBtn.addTarget({ (sender) in
            self.customDelegate?.textTitleViewRightBtnClick(viewVC: self, sender: sender!)
            self.dismiss(animated: true, completion: nil)
        }, andEvent: .touchUpInside)
    }

    @IBAction func backgroundBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leftBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setReleaseNotes(_ text: String) {
        self.releaseNotesTextView.text = text
        let textViewSize = self.releaseNotesTextView.size
        let newSize = NSString(string: text).boundingRect(with: CGSize(width: textViewSize.width, height: 500), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : self.releaseNotesTextView.font as Any], context: nil)
        
        CLLog("newSize.width = \(newSize.width), height = \(newSize.height)")
        let diffHeight = newSize.height - textViewSize.height + 8
        if diffHeight > 0  {
            self.textViewHeight.constant = self.textViewHeight.constant + (diffHeight > 48 ? 48 : diffHeight)
        }
    }
}
