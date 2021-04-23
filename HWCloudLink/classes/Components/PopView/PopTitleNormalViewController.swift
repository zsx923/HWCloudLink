//
// PopTitleNormalViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

typealias PopTitleItemBlock = (Int) -> Void

protocol PopTitleNormalViewDelegate {
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController)
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath)
}

class PopTitleNormalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let vcID = "PopTitleNormalViewController"
    
    var dataSource: [String] = []
    var subTitleArray: [String]?
    var isShowDestroyColor: Bool?
    var isShowDestroyColor2: Bool?
    var showName: String?
    var showNumber: String?
    var showDepart: String?
    //判断是否弹出
    var isShow: Bool = false
    //是否允许横竖屏flag
    var isAllowRote = true
    var selectedAtteendeeIndex = 0
    
    var itemBlocks: [PopTitleItemBlock]?
    
    var tableView: UITableView = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
               
        isAllowRote ? ( (UIApplication.shared.delegate as? AppDelegate)?.isAllowRotate = true) : ((UIApplication.shared.delegate as? AppDelegate)?.isAllowRotate = false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         isAllowRote ? ( (UIApplication.shared.delegate as? AppDelegate)?.isAllowRotate = true) : ((UIApplication.shared.delegate as? AppDelegate)?.isAllowRotate = false)
    }
    
    var tableHeight: CGFloat = 0
    var customDelegate: PopTitleNormalViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColorFromRGBA(rgbValue: 0x000000, alpha: 0.3)
        
        self.customDelegate?.popTitleNormalViewDidLoad(viewVC: self)
        // set table view
        tableView.separatorStyle = .none
//        tableView.tableHeaderView = UIView.init()
//        tableView.tableHeaderView?.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
//        tableView.tableFooterView = UIView.init()
//        tableView.tableFooterView?.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: TableCenterTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableCenterTextCell.CELL_ID)
        tableView.register(TableHeaderFooterTextCell.classForCoder(), forHeaderFooterViewReuseIdentifier: TableHeaderFooterTextCell.CELL_ID)
        tableHeight = CGFloat(self.dataSource.count) * TableCenterTextCell.CELL_HEIGHT + TableHeaderFooterTextCell.CELL_HEIGHT + (UI_IS_BANG_SCREEN ? 30 : 10)
        tableView.height = tableHeight
        tableView.y = SCREEN_HEIGHT - self.tableHeight
        
        self.view.addSubview(tableView)
        tableView.mas_makeConstraints { [weak self] (make) in
            guard let self = self else { return }
            make?.left.mas_equalTo()(self.view)
            make?.right.mas_equalTo()(self.view)
            make?.height.mas_equalTo()(tableHeight)
            make?.bottom.mas_equalTo()(self.view)
        }
    }
    
    deinit {
        CLLog("PopTitleNormalViewController deinit")
    }
    
    
    @IBAction func backgroundBtnClick(_ sender: UIButton) {
        isShow = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCenterTextCell.CELL_ID) as! TableCenterTextCell
        
        cell.showTitleLabel.text = self.dataSource[indexPath.row]
        cell.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#333333")
        cell.showTitleLabel.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#f0f0f0")
        
        if isShowDestroyColor != nil && self.isShowDestroyColor! && indexPath.row == self.dataSource.count - 2 || isShowDestroyColor2 != nil && self.isShowDestroyColor2! && indexPath.row == self.dataSource.count - 3 {
            cell.showTitleLabel.textColor = COLOR_RED
        }
        if indexPath.row == self.dataSource.count - 1 {
            cell.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#333333")
        }
        
        // set subtitle
        if self.subTitleArray != nil && indexPath.row < self.subTitleArray!.count {
            cell.setSubTitle(subTitle: self.subTitleArray![indexPath.row])
        } else {
            cell.setSubTitle(subTitle: nil)
        }
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let itemBlocks = self.itemBlocks, indexPath.row < itemBlocks.count {
            let itemBlock = itemBlocks[indexPath.row]
            itemBlock(selectedAtteendeeIndex)
        }
        
        if self.dataSource[indexPath.row] == tr("取消") {
            // 取消按钮
            self.customDelegate?.popTitleNormalViewCellClick(viewVC: self, index: IndexPath.init(row: -1, section: 0))
        } else {
            self.customDelegate?.popTitleNormalViewCellClick(viewVC: self, index: indexPath)
            //主动结束会议时主动结束扩展进程
            self.passiveStopShareScreen()
        }
        
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableCenterTextCell.CELL_HEIGHT
    }
    
    
    // MARK: header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderFooterTextCell.CELL_ID) as! TableHeaderFooterTextCell
        headerView.contentView.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
        let label = UILabel.init()
        label.backgroundColor = UIColor.colorWithSystem(lightColor: "#fafafa", darkColor: "#222222")
        label.textColor = UIColor.colorWithSystem(lightColor: "#999999", darkColor: "#cccccc")
        label.text = self.showName
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14.0)
        headerView.addSubview(label)
        label.mas_makeConstraints { (make) in
            make?.left.equalTo()(headerView)?.offset()(0)
            make?.right.equalTo()(headerView)?.offset()(0)
            make?.top.equalTo()
            make?.bottom.equalTo()
        }
        headerView.setNeedsLayout()
        
        return headerView
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableHeaderFooterTextCell.CELL_HEIGHT + 10
    }
    
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

}

extension PopTitleNormalViewController{
    //被动结束扩展进程
    func passiveStopShareScreen() -> Void {
        
        let cfnotification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(cfnotification, CFNotificationName.init("STOPSHARED" as CFString), nil, nil, true)
    }
}
