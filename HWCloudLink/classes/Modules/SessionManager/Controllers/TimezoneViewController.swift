//
//  TimezoneViewController.swift
//  HWCloudLink
//
//  Created by 严腾飞 on 2020/12/7.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TimezoneViewController: UIViewController {
    
    typealias SelectTimezoneCallBack = (_ timezoneModel: TimezoneModel) -> Void
    var selectCallBack: SelectTimezoneCallBack?
    
    var timezoneLists : [TimezoneModel] = []
    private var tableView: UITableView?
    private var selectIndex: Int = NSNotFound

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = tr("时区")
        steupTableView()

        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
    }

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    private func steupTableView() {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - KNavgationBarHeight))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 54
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#000000")
        view.addSubview(tableView)
        self.tableView = tableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "timezoneCell")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TimezoneViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timezoneLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timezoneCell")!
        let zoneModel = self.timezoneLists[indexPath.row]
        cell.textLabel?.text = zoneModel.timeZoneDesc
        cell.textLabel?.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#f0f0f0")
        if selectIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#000000")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectIndex = indexPath.row
        tableView.reloadData()
        
        let zoneModel = self.timezoneLists[indexPath.row]
        self.selectCallBack!(zoneModel)
        navigationController?.popViewController(animated: true)
    }
}
