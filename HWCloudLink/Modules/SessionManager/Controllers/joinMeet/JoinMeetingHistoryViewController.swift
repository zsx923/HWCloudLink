//
//  JoinMeetingHistoryViewController.swift
//  HWCloudLink
//
//  Created by lyw on 2021/2/8.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class JoinMeetingHistoryViewController: UIViewController {
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    var arrData = [MeetingHistoryModel]()
    var selectBlock: ((_ model: MeetingHistoryModel)->Void)?
    var clearHistoryBlock: (()->Void)?
    
    init(_ historyData: [MeetingHistoryModel]) {
        super.init(nibName: nil, bundle: nil)
        self.arrData = historyData
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSubViews()
    }
}

extension JoinMeetingHistoryViewController {
    func initSubViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor(hexString: "#000000", alpha: 0.4)
        
        self.tableView.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#333333")
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(JoinMeetingHistoryTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(JoinMeetingHistoryTableViewCell.self))
        
        self.view.addSubview(self.tableView)
        self.tableView.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(self.view)
            make?.centerY.mas_equalTo()(self.view)
            make?.width.mas_equalTo()(SCREEN_WIDTH-72)
            make?.height.mas_equalTo()(58*2+50*self.arrData.count)
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH-72, height: 58))
        self.tableView.tableHeaderView = headerView
        let headerLab = UILabel()
        headerLab.textAlignment = .left
        headerLab.font = UIFont.systemFont(ofSize: 20)
        headerLab.textColor = UIColor.colorWithSystem(lightColor: UIColor.black, darkColor: UIColor.white)
        headerLab.text = tr("最近加入的会议")
        headerView.addSubview(headerLab)
        headerLab.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(headerView)?.offset()(24)
            make?.right.mas_equalTo()(headerView)?.offset()(-24)
            make?.centerY.mas_equalTo()(headerView)
            make?.height.mas_equalTo()(28)
        }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH-72, height: 58))
        self.tableView.tableFooterView = footerView
        let footerLab = UIButton(type: .system)
        footerLab.titleLabel?.textAlignment = .left
        footerLab.contentHorizontalAlignment = .left
        footerLab.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        footerLab.setTitleColor(UIColor(hexString: "#0D94FF"), for: .normal)
        footerLab.setTitle(tr("清空历史会议记录"), for: .normal)
        footerLab.addTarget(self, action: #selector(clearHistoryHanlde), for: .touchUpInside)
        footerView.addSubview(footerLab)
        footerLab.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(headerView)?.offset()(24)
            make?.right.mas_equalTo()(headerView)?.offset()(-24)
            make?.centerY.mas_equalTo()(footerView)
            make?.height.mas_equalTo()(22)
        }
    }
}

extension JoinMeetingHistoryViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func clearHistoryHanlde() {
        ContactManager.shared.removeMeetingHistoryAllData()
        self.clearHistoryBlock?()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JoinMeetingHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: JoinMeetingHistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(JoinMeetingHistoryTableViewCell.self), for: indexPath) as! JoinMeetingHistoryTableViewCell
        let model = self.arrData[indexPath.row]
        cell.labTitle.text = model.title
        cell.labSubTitle.text = model.number
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true) {
            self.selectBlock?(self.arrData[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
