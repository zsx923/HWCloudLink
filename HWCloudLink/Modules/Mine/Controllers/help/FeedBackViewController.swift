//
// FeedBackViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class FeedBackViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = tr("帮助与反馈")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // table view
        tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.view.addSubview(tableView!)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.register(UINib.init(nibName: TableTextNextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTextNextCell.CELL_ID)
//        self.tableView.register(TableHeaderFooterTextCell.classForCoder(), forHeaderFooterViewReuseIdentifier: TableHeaderFooterTextCell.CELL_ID)
        // 去分割线
        self.tableView!.separatorStyle = .none
    }
    
     
    
    @IBAction func exitLoginBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section ==  0  {
            return 1
        }
        return 0
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableTextNextCell.CELL_ID) as! TableTextNextCell
        cell.showTipLabel.isHidden = true
        /*
        
        if indexPath.section == 0 {
            // 帮助
            if indexPath.row == 0 {
                // 一个手机能创建几个帐号？
                cell.showTitleLabel.text = "一个手机能创建几个帐号？"
            } else if indexPath.row == 1 {
                // 如何修改绑定的手机号？
                cell.showTitleLabel.text = "如何修改绑定的手机号？"
            } else if indexPath.row == 2 {
                // 会议主持人转让的方法？
                cell.showTitleLabel.text = "会议主持人转让的方法？"
            }
        }  else if indexPath.section == 1 {
              // 反馈
            cell.showTitleLabel.text = "反馈"
        }
        */
        cell.showTitleLabel.text = "反馈"
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // set title
//        if indexPath.section == 0 {
//            // 帮助
//            if indexPath.row == 0 {
//                // 一个手机能创建几个帐号？
//                navigationController?.pushViewController(FeedBackAnswerViewController(), animated: true)
//
//            } else if indexPath.row == 1 {
//                // 如何修改绑定的手机号？
//
//            } else if indexPath.row == 2 {
//                // 会议主持人转让的方法？
//
//            }
//        }  else if indexPath.section == 1 {
            // 反馈
            let fbcVc = FeedBackCommitViewController()
            navigationController?.pushViewController(fbcVc, animated: true)
//            MBProgressHUD.show("该功能暂未开放", icon: nil, view: view)
//        }
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return TableTextNextCell.CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderFooterTextCell.CELL_ID) as! TableHeaderFooterTextCell
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 30))
        let label = UILabel.init(frame: CGRect(x: 10, y: 0, width: 200, height: 30))
        label.textColor = COLOR_LIGHT_GAY
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        
        label.text = tr("反馈")
        headerView.addSubview(label)
        return headerView
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // MARK: footer Title
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return ""
//    }
//    
//    // MARK: footer View
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView.init()
//    }
    
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
    
    //MARK: -  返回
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
   

}
