//
//  MyselfHeaderView.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/11/19.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MyselfHeaderView: BaseCustomView {

    @IBOutlet weak var nameLabel: UILabel!//用户名称
    @IBOutlet weak var codeLabel: UILabel!//用户端口号
    @IBOutlet weak var upImageView: UIImageView!//上部的图片 ，需要变颜色
    @IBOutlet weak var bottomView: UIView!//底部的view 。需要变颜色
    @IBOutlet weak var rightBottomView: UIView!
    
    let bgView = UIView()
    
    //点击headerview 需要跳转到个人中心页面
//    typealias clickBlock = (()->Void)
//    var passClickHeaderViewBlock : clickBlock?
    
    var passClickHeaderViewValueBlock : (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap =  UITapGestureRecognizer.init(target: self, action: #selector(self.clickBottomView))
        bottomView.addGestureRecognizer(tap)
        
        
        bottomView.layer.cornerRadius = 2
        bottomView.isUserInteractionEnabled = true
        bottomView.layer.shadowOffset = CGSize(width: 5, height: 5)
        bottomView.layer.shadowColor =  UIColor.colorWithSystem(lightColor: UIColor.lightGray, darkColor: UIColor.darkGray).cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowRadius = 5;//阴影半径，默认3
        
        rightBottomView.clipsToBounds = true
        
        self.bottomView.insertSubview(self.bgView, belowSubview: self.codeLabel)
        self.bgView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(self.bottomView)
        }
        self.bottomView.bringSubviewToFront(self.nameLabel)
        
        let layer = CAGradientLayer.init()
        layer.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH-32, height: bottomView.bounds.size.height)
        layer.locations = [0, 0.6, 1]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.cornerRadius = 2
        layer.masksToBounds = true
        bgView.layer.insertSublayer(layer, at: 0)
    }
     
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        bottomView.layer.shadowColor = UIColor.colorWithSystem(lightColor: UIColor.lightGray, darkColor: UIColor.darkGray).cgColor
    }
    
    class func creatMySeftHeaderView() -> UIView {
        return loadNibView(nibName: "MyselfHeaderView")
    }

    func setHeaderViewName(name: String,code: String){
        nameLabel.text = name
        codeLabel.text = code
    }
    
    //MARK: 点击headerview 跳转方法
    @objc func clickBottomView() {
        if passClickHeaderViewValueBlock != nil {
            passClickHeaderViewValueBlock!()
        }
    }
    
    
}
