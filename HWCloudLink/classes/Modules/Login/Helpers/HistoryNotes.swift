//
//  HistoryNotes.swift
//  HWCloudLink
//
//  Created by cos on 2020/11/28.
//  Copyright © 2020 陈帆. All rights reserved.
//  add at xuegd: 历史账号 View

import UIKit

typealias ClickHistoryNotes = (Int) -> Void
typealias DeleteHistoryNotes = (Int) -> Void

class HistoryNotes: UITableView, UITableViewDelegate, UITableViewDataSource {
    /// 数据
    var data : Array<Any> = []
    /// add at xuegd: 点击账号回调
    var clickHistoryNotes : ClickHistoryNotes = {_ in }
    /// add at xuegd: 删除账号回调
    var deleteHistoryNotes : DeleteHistoryNotes = {_ in }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.isHidden = true
        self.separatorStyle = .none
        self.register(UINib.init(nibName: TableAccountHistoryCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableAccountHistoryCell.CELL_ID)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableAccountHistoryCell.CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.data.count > 5 {
            return 5
        }
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableAccountHistoryCell.CELL_ID) as! TableAccountHistoryCell
        // data
        cell.showTitleLabel.text = (self.data[indexPath.row] as! String)
        cell.showDeleteBtn.tag = indexPath.row
        cell.showDeleteBtn.addTarget({ (sender) in
            self.data.remove(at: indexPath.row)
            self.deleteHistoryNotes(indexPath.row)
        }, andEvent: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.clickHistoryNotes(indexPath.row)
    }
}
