//
//  MyMeetingDayTimeHeaderView.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/9.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MyMeetingDayTimeHeaderView: UITableViewHeaderFooterView {

    static let CellID = "MyMeetingDayTimeHeaderView"
    static let CellHeight: CGFloat = 30.0
    
    let label = ActionUILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(label)
        label.textColor = UIColor(hexString: "#999999")
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        
        label.mas_makeConstraints { (make) in
            make?.left.equalTo()(self)?.offset()(16.0)
            make?.right.equalTo()(self)?.offset()(-16.0)
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
