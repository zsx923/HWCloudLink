//
// MeetingTypeSetViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/20.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

enum MeetingType {
    case `deafault`
    case voice
    case other
}

class MeetingTypeSetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    typealias TypeForMeeting = (_ type: MeetingType) ->()
    var typeComeBack: TypeForMeeting?
    
    var type: MeetingType = .deafault
    private var dataSource: [String] = [tr("视频会议"), tr("语音会议")]  // "多媒体会议", "视频+多媒体会议", "桌面共享会议"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = tr("会议类型")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: TableTitleSymbolCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTitleSymbolCell.CELL_ID)
        // 去分割线
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TableTitleSymbolCell.CELL_ID) as! TableTitleSymbolCell
        cell.showRightImageView.image = UIImage.init(named: "selected_icon")
        
        switch type {
        case .deafault:
            indexPath.row == 0 ? (cell.showRightImageView.isHidden = false) : (cell.showRightImageView.isHidden = true)
        case .voice:
            indexPath.row == 0 ? (cell.showRightImageView.isHidden = true) : (cell.showRightImageView.isHidden = false)
        default:
            indexPath.row == 0 ? (cell.showRightImageView.isHidden = false) : (cell.showRightImageView.isHidden = true)
        }

        cell.showTitleLabel.text = self.dataSource[indexPath.row]
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        switch indexPath.row {
        case 0: // 视频会议
            type = .deafault
        case 1: // 语音会议
            type = .voice
        default:
            type = .other
            CLLog("not defined.")
        }
        self.tableView.reloadData()
        typeComeBack?(type)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return TableTitleSymbolCell.CELL_HEIGHT
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
}
