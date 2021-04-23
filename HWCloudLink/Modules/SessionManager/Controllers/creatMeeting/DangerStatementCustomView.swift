//
//  DangerStatementCustomView.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/12/3.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class DangerStatementCustomView: BaseCustomView {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var safeTipsLabel: UILabel!
    
    @IBOutlet weak var upViewHightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var contentLabelHightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var contentLabelTopHightConstant: NSLayoutConstraint!
    @IBOutlet weak var alertContentLabel: UILabel!
    
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var cancelLabel: UIButton!
    @IBOutlet weak var okLabel: UIButton!
    
    var contentStr: String? {
        willSet {
            let height = NSString.getStrHight(newValue, maxWidth: self.bgView.frame.size.width-48, fontSize: 14)
            if height <= 75 {
                upViewHightConstant.constant = 232
                contentLabelHightConstant.constant = 75
            } else {
                upViewHightConstant.constant = 232.0 + height - 75.0 + 5.0
                contentLabelHightConstant.constant = height + 5.0
            }
            contentLabelTopHightConstant.constant = 15
        }
        didSet {
            alertContentLabel.text = contentStr
        }
    }
    //_ isYES: 取消或确认， isSelected 是否是选了选择框
    var passAlertStatementValueBlock : (( _ isAgree: Bool,_ isConfirm: Bool )->Void)?
    
    override func awakeFromNib() {
        superview?.awakeFromNib()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.safeTipsLabel.text = tr("风险提示")
        self.alertContentLabel.text = tr("当前会议未设置密码，存在安全风险，建议开启来宾密码。")
        self.agreeLabel.text = tr("我已了解风险，不再提示")
        self.cancelLabel.setTitle(tr("取消"), for: .normal)
        self.okLabel.setTitle(tr("确定"), for: .normal)
        
        self.safeTipsLabel.textAlignment = .center
        self.agreeLabel.numberOfLines = 2
        
        self.safeTipsLabel.mas_remakeConstraints { (make) in
            make?.left.mas_equalTo()(self.bgView)?.offset()(24)
            make?.right.mas_equalTo()(self.bgView)?.offset()(-24)
            make?.top.mas_equalTo()(self.bgView)?.offset()(20)
            make?.height.mas_equalTo()(20)
        }
        self.alertContentLabel.mas_remakeConstraints { (make) in
            make?.left.mas_equalTo()(self.bgView)?.offset()(24)
            make?.right.mas_equalTo()(self.bgView)?.offset()(-24)
            make?.top.mas_equalTo()(self.safeTipsLabel.mas_bottom)?.offset()(10)
        }
        self.agreeBtn.mas_remakeConstraints { (make) in
            make?.left.mas_equalTo()(self.bgView)?.offset()(24)
            make?.bottom.mas_equalTo()(self.bgView)?.offset()(-60)
            make?.width.height()?.mas_equalTo()(35)
        }
        self.agreeLabel.mas_remakeConstraints { (make) in
            make?.left.mas_equalTo()(self.bgView)?.offset()(52)
            make?.right.mas_equalTo()(self.bgView)?.offset()(-24)
            make?.centerY.mas_equalTo()(self.agreeBtn.mas_centerY)
            make?.top.mas_equalTo()(self.alertContentLabel.bottom)?.offset()(10)
        }
    }
    static func creatDangerStatementCustomView() -> DangerStatementCustomView {
        return loadNibView(nibName: "DangerStatementCustomView") as! DangerStatementCustomView
    }
    
    
    
    //MARK: - 了解风险 同意 选项框
    @IBAction func clickAgreeBtn(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.setImage(UIImage(named: "danger_normal"), for: .normal)
        } else {
            sender.isSelected = true
            sender.setImage(UIImage(named: "danger_selected"), for: .normal)
            
        }
    }
    //MARK: - 选择取消
    @IBAction func passResignBtn(_ sender: Any) {
        if passAlertStatementValueBlock != nil {
            passAlertStatementValueBlock!(false,false)
        }
        self.removeFromSuperview()
    }
    //MARK: - 选择确认
    @IBAction func passActionBtn(_ sender: Any) {
        if passAlertStatementValueBlock != nil {
            passAlertStatementValueBlock!(agreeBtn.isSelected, true)
            self.removeFromSuperview()
        }
    }
}
