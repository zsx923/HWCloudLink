//
// RecentContactViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/17.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

private let recentContactViewCellID = "RecentContactViewCell"

class RecentContactViewController: UIViewController{
    
    var userCallLogModelArray: [UserCallLogModel] = []
    
    fileprivate var header:MJRefreshNormalHeader?
    

    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var nodataLabel: UILabel!
    
    @IBOutlet weak var nodataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        
        self.title = tr("通话记录")
        
        self.tableView.separatorStyle = .none
        
        self.nodataLabel.text = tr("暂无通话记录")
        self.nodataLabel.textColor = UIColor(hexString: "999999 ")
        self.nodataView.isHidden = true
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.tableView.register(UINib.init(nibName: recentContactViewCellID, bundle: nil), forCellReuseIdentifier: recentContactViewCellID)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.isTranslucent = false
        
        header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(addNewInfo))
        header?.setTitle(tr("下拉刷新"), for: .idle)
        header?.setTitle(tr("松开立即刷新"), for: .pulling)
        header?.setTitle(tr("正在加载"), for: .refreshing)
        header?.lastUpdatedTimeLabel?.isHidden = true
        self.tableView.mj_header = header
        
        //刷新数据通知
        NotificationCenter.default.addObserver(self, selector: #selector(recentContactrefreshData), name: NSNotification.Name(RECENT_CONTACT_REFRESH_DATA), object: nil)
        
   
    }
    
    //刷新数据
    @objc func recentContactrefreshData(notification: Notification) {
        self.loadData()
    }
    
    //下拉刷新
    @objc func addNewInfo(){
        self.loadData()
    }
    

}

// MARK: - 点击事件
extension RecentContactViewController {
    @objc private func leftBarBtnItemClick(sender: UIBarButtonItem) {
           self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - 获取数据
extension RecentContactViewController {
    private func loadData() {
        //结束刷新
        self.tableView.mj_header?.endRefreshing()
        UserCallLogBusiness.shareInstance.selectUserCallLog(userCallLogModel: UserCallLogModel()) {[weak self] array in
            self?.userCallLogModelArray = array
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension RecentContactViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //显示占位图
        nodataView.isHidden = userCallLogModelArray.count != 0  ? true : false
        return userCallLogModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: recentContactViewCellID, for: indexPath) as! RecentContactViewCell
        cell.userCallLogModel = userCallLogModelArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if SuspendTool.isMeeting() {
            SessionManager.showMeetingWarning()
            return
        }
        let userCallLogModel = userCallLogModelArray[indexPath.row]
        let name = userCallLogModel.meetingType == 1 ? userCallLogModel.userName : userCallLogModel.title
        SessionManager.shared.showCallSelectView(name: name, number: userCallLogModel.number, depart: "", vc: self)
    }
}
