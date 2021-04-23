//
//  ShareView.swift
//  HWCloudLink
//
//  Created by mac on 2021/1/19.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

enum ShareType {
    case wechat
    case sms
    case email
    case info
}

typealias ShareTypeClickBack = (_ shareType: ShareType) -> Void

public class ShareView: UIView {
    
    /// 点击的闭包返回
    var shareType: ShareTypeClickBack?
    private let buttonToTop: CGFloat = 15
    /// 按钮的大小
    private let buttonW = kScreenWidth / 3
    private let buttonH = kScreenWidth / 4
    /// 内容view的高度
    private let contentViewHeight: CGFloat  = ScreenInfo.isIphoneX() ? 200 : 180
    /// 取消按钮的高度
    private let cancleButtonHeight: CGFloat = 50
    /// 横线的高度
    private let lineViewHeight: CGFloat     = 15
    /// 传的模型
    var shareItemModels: [ShareItemModel] = []
    /// 默认模型
    private var defaulModels: [ShareItemModel] {
        var models: [ShareItemModel] = []
//        let imageNames: [String] = ["meeting_weixin_share", "meeting_sms_share", "meeting_message_share", "meeting_link_share"]
//        let titles: [String] = ["微信邀请", "短信邀请", "邮件邀请", "复制信息"]
        let imageNames: [String] = ["meeting_sms_share", "meeting_message_share", "meeting_link_share"]
        let titles: [String] = [tr("短信邀请"), tr("邮件邀请"), tr("复制信息")]
        for i in 0..<titles.count {
           var model = ShareItemModel()
            model.imageName = imageNames[i]
            model.title = titles[i]
            models.append(model)
        }
        return models
    }
    /// 内容View
    private lazy var contentView: UIView = {
        let tempView = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentViewHeight))
        tempView.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor(hexString: "#333333"))
        return tempView
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init (models: [ShareItemModel]) {
        self.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        shareItemModels = models
        creatContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view is ShareView {
            dismiss()
        }
    }
}

extension ShareView {
    
    public func show() {
        
        let window =  UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.addSubview(self)
        addSubview(contentView)
        UIView.animate(withDuration: 0.3) {
            var frame = self.contentView.frame
            frame.origin.y = kScreenHeight - self.contentViewHeight
            self.contentView.frame = frame
        }
    }
    
    public func dismiss() {
        
        UIView.animate(withDuration: 0.3) {
            var frame = self.contentView.frame
            frame.origin.y = kScreenHeight
            self.contentView.frame = frame
        } completion: { (finished) in
            self.removeFromSuperview()
        }
    }
    
    private func creatContentView() {
        
        shareItemModels.count > 0 ? creatShareItems(from: shareItemModels) : creatShareItems(from: defaulModels)
    }
    
    private func creatShareItems(from models: [ShareItemModel]) {
        
        for (i, model) in models.enumerated() {
            let button = UIButton(frame: CGRect(x: CGFloat(i) * buttonW, y: buttonToTop, width: buttonW, height: buttonH))
            button.setTopAndBottomImage(UIImage(named: model.imageName), withTitle: model.title, for: .normal, andTintColor: .lightGray, withTextFont: UIFont.systemFont(ofSize: 12), andTitleTextHeight: 20)
            button.tag = i
            button.setImage(UIImage(named: model.imageName), for: .highlighted)
            button.addTarget(self, action: #selector(shareClick(button:)), for: .touchUpInside)
            button.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor(hexString: "#333333"))
            button.setTitleColor(UIColor.colorWithSystem(lightColor: UIColor(hexString: "#333333"), darkColor: UIColor.white), for: .normal)
            contentView.addSubview(button)
        }
        
        //横线
        let lineView = UIView(frame: CGRect(x: 0, y: buttonToTop + buttonH, width: kScreenWidth, height: lineViewHeight))
        lineView.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "#fafafa"), darkColor: UIColor(hexString: "#3e3e3e"))
        contentView.addSubview(lineView)
        
        //取消按钮
        let cancelButton = UIButton(frame: CGRect(x: 0, y: lineView.frame.maxY, width: kScreenWidth, height: contentViewHeight - lineView.frame.maxY))
        cancelButton.addTarget(self, action: #selector(cancle), for: .touchUpInside)
        cancelButton.setTitle(tr("取消"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelButton.setTitleColor(.lightGray, for: .normal)
        cancelButton.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor(hexString: "#444444"))
        contentView.addSubview(cancelButton)
    }
    
    @objc private func cancle() {
        dismiss()
    }
    
    @objc private func shareClick(button: UIButton) {
        
        switch button.tag {
        case 0:
            shareType?(.sms)
        case 1:
            shareType?(.email)
        case 2:
            shareType?(.info)
        default:
            shareType?(.wechat)
        }
        dismiss()
    }
}
