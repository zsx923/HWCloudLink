//
//  JoinMeetingHistoryTableViewCell.swift
//  HWCloudLink
//
//  Created by lyw on 2021/2/9.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class JoinMeetingHistoryTableViewCell: UITableViewCell {
    let labTitle = UILabel()
    let labSubTitle = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#333333")
        self.loadSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UI
extension JoinMeetingHistoryTableViewCell {
    func loadSubViews() {
        self.initSubViews()
        self.addSubViews()
        self.addSubViewConstraints()
    }
    
    func initSubViews() {
        self.labTitle.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#f0f0f0")
        self.labTitle.textAlignment = .left
        self.labTitle.font = UIFont.systemFont(ofSize: 16)
        
        self.labSubTitle.textColor = UIColor(hexString: "#0D94FF")
        self.labSubTitle.textAlignment = .right
        self.labSubTitle.font = UIFont.systemFont(ofSize: 16)
    }
    
    func addSubViews() {
        self.contentView.addSubview(self.labTitle)
        self.contentView.addSubview(self.labSubTitle)
    }
    
    func addSubViewConstraints() {
        self.labSubTitle.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(self.contentView)?.offset()(-26)
            make?.centerY.mas_equalTo()(self.contentView)
            make?.height.mas_equalTo()(16)
        }
        self.labTitle.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self.contentView)?.offset()(26)
            make?.right.mas_lessThanOrEqualTo()(self.labSubTitle.mas_left)?.offset()(-5)
            make?.centerY.mas_equalTo()(self.contentView)
            make?.height.mas_equalTo()(16)
        }
    }
}
