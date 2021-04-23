//
// SingalHeaderFooterView.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/17.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class SingalHeaderFooterView: UITableViewHeaderFooterView {
    static let CELL_ID = "SingalHeaderFooterView"
    static let CELL_HEIGHT: CGFloat = 40.0
    
    let label = UILabel()
    let lineView = UIView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        addSubview(label)
        addSubview(lineView)
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        
        lineView.backgroundColor = UIColor.systemGray
    }
    
    override func setNeedsLayout() {
        label.frame = CGRect.init(x: 0, y: 0, width: self.width/3.0, height: self.height)
        lineView.mas_makeConstraints { [weak self] (make) in
            guard let self = self else {return}
            make?.right.mas_equalTo()
            make?.left.mas_equalTo()
            make?.bottom.equalTo()(self)?.offset()(1)
            make?.height.mas_equalTo()(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        CLLog("SingalHeaderFooterView deinit")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
