//
// TableHeaderFooterTextCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableHeaderFooterTextCell: UITableViewHeaderFooterView {
    static let CELL_ID = "TableHeaderFooterTextCell"
    static let CELL_HEIGHT: CGFloat = 30.0
    
    let label = ActionUILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
//        if #available(iOS 13.0, *) {  // 适配暗黑模式
//            contentView.backgroundColor = UIColor.init { (trainColl) -> UIColor in
//                if trainColl.userInterfaceStyle == .dark {
//                    return COLOR_DARK_GAY
//                } else {
//                    return BG_COLOR_TABLE_OR_COLLECTION
//                }
//            }
//        } else {
//            // Fallback on earlier versions
//            contentView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
//        }
        addSubview(label)
        
        label.textColor = COLOR_LIGHT_GAY
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        
        label.mas_makeConstraints { (make) in
            make?.left.equalTo()(self)?.offset()(16)
            make?.right.equalTo()(self)?.offset()(0)
            make?.top.equalTo()
            make?.bottom.equalTo()
        }
    }
    
    override func setNeedsLayout() {
        // 更变布局
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}
