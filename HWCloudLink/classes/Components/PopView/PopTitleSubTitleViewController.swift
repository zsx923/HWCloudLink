//
// PopTitleSubTitleViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol PopTitleSubTitleViewDelegate: NSObjectProtocol {
    func popTitleSubTitleViewDidLoad(viewVC: PopTitleSubTitleViewController)
    func popTitleSubTitleViewCellClick(viewVC: PopTitleSubTitleViewController, dataDict: [String:String]?)
}

class PopTitleSubTitleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var showTitle: String?
    var dataSource: [[String : String]]?
    
    fileprivate lazy var tableView: UITableView = {
        let temp = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0), style: .plain)
        
        return temp
    }()
    
    
    weak var customDelegate: PopTitleSubTitleViewDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColorFromRGBA(rgbValue: 0x000000, alpha: 0.3)
        
        self.customDelegate?.popTitleSubTitleViewDidLoad(viewVC: self)
        
        // set table view
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView.init()
        self.tableView.isScrollEnabled = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: TableCenterTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableCenterTextCell.CELL_ID)
        self.tableView.register(UINib.init(nibName: TableLeftTitleRightSubTitleCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableLeftTitleRightSubTitleCell.CELL_ID)
        self.tableView.register(TableHeaderFooterTextCell.classForCoder(), forHeaderFooterViewReuseIdentifier: TableHeaderFooterTextCell.CELL_ID)
        let tableHeight = CGFloat((self.dataSource?.count)!) * TableCenterTextCell.CELL_HEIGHT + TableHeaderFooterTextCell.CELL_HEIGHT + 10
        self.tableView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT - tableHeight, width: SCREEN_WIDTH, height: tableHeight)
        self.view.addSubview(self.tableView)
    }
    
    
    @IBAction func showCancelBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource!.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // data
        let dataDict = self.dataSource![indexPath.row]
        // cancel
        if indexPath.row == self.dataSource!.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableCenterTextCell.CELL_ID) as! TableCenterTextCell
            cell.showTitleLabel.text = dataDict[DICT_TITLE]
            cell.showTitleLabel.textColor = COLOR_DARK_GAY
            cell.contentView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
            
            return cell
        }
        // title
        let titleCell = tableView.dequeueReusableCell(withIdentifier: TableLeftTitleRightSubTitleCell.CELL_ID) as! TableLeftTitleRightSubTitleCell
        
        titleCell.showTitleLabel.text = dataDict[DICT_TITLE]
        titleCell.showSubTitleLabel.text = dataDict[DICT_SUB_TITLE]
        
        let isNext = dataDict[DICT_IS_NEXT]
        if isNext != nil && isNext! == "1" {
            titleCell.showSubTitleLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        } else {
            titleCell.showSubTitleLabel.textColor = COLOR_DARK_GAY
        }
        
        return titleCell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == self.dataSource!.count - 1 {
            // 取消按钮
            self.showCancelBtnClick(UIButton.init())
            self.customDelegate?.popTitleSubTitleViewCellClick(viewVC: self, dataDict: nil)
        } else {
            self.customDelegate?.popTitleSubTitleViewCellClick(viewVC: self, dataDict: self.dataSource![indexPath.row])
        }
        
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableCenterTextCell.CELL_HEIGHT
    }
    
    
    // MARK: header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderFooterTextCell.CELL_ID) as! TableHeaderFooterTextCell
        
        headerView.label.text = self.showTitle
        headerView.label.textAlignment = .center
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
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
