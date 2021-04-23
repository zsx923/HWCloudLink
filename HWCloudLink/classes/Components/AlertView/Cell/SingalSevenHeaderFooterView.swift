//
//  SingalSevenHeaderFooterView.swift
//  HWCloudLink
//
//  Created by mac on 2021/1/8.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class SingalSevenHeaderFooterView: UITableViewHeaderFooterView {

    static let CELL_ID = "SingalSevenHeaderFooterView"
    static let CELL_HEIGHT: CGFloat = 40.0
    
    let label = UILabel()
    let lineView = UIView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        addSubview(label)
        addSubview(lineView)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        
        lineView.backgroundColor = UIColor.systemGray
    }
    
    override func setNeedsLayout() {
//        let maxWidth = SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH : SCREEN_HEIGHT
//        label.frame = CGRect.init(x: 0, y: 0, width: maxWidth/CGFloat(TableSingalViewCell.LABEL_COLUMN), height: self.height)
        label.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self)?.offset()(13)
            make?.right.mas_equalTo()(self)?.offset()(-13)
            make?.top.mas_equalTo()(self)
            make?.height.mas_equalTo()(self.height)
        }
        lineView.mas_makeConstraints {(make) in
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
        CLLog("SingalSevenHeaderFooterView deinit")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
