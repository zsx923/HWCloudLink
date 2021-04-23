//
// CallComingSetViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2021/2/8.
// Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class CallComingSetViewController: UIViewController {
    struct DataSourceInfo {
        var title: String = ""
        var isOn: Bool = false
        var statusKey: String = SOUND_BELL_KEY
        
        init(_title: String, _isOn: Bool, _statusKey: String) {
            self.title = _title
            self.isOn = _isOn
            self.statusKey = _statusKey
        }
    }
    
    private var dataSourceArray: [DataSourceInfo] = []
    
    private lazy var tableView: UITableView = {
        let tableV = UITableView.init(frame: self.view.bounds, style: UITableView.Style.plain)
        
        return tableV;
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = tr("来电通知")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(leftBarBtnItemClick(sender:))
        )
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.view.addSubview(self.tableView)
        self.tableView.register(UINib.init(nibName: TableTitleSwitchCell.CELL_ID, bundle: nil),
                                forCellReuseIdentifier: TableTitleSwitchCell.CELL_ID)
        self.tableView.tableFooterView = UIView.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        // 设置数据
        let soundBellStatus = NSObject.getUserDefaultValue(withKey: SOUND_BELL_KEY) as? String
        let vibrateStatus = NSObject.getUserDefaultValue(withKey: VIBRATE_KEY) as? String
        if soundBellStatus != nil && vibrateStatus != nil {
            self.dataSourceArray.append(DataSourceInfo.init(_title: tr("振动"),
                                                            _isOn: vibrateStatus == "1",
                                                            _statusKey: VIBRATE_KEY))
            self.dataSourceArray.append(DataSourceInfo.init(_title: tr("铃声"),
                                                            _isOn: soundBellStatus == "1",
                                                            _statusKey: SOUND_BELL_KEY))
        }
        
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func switchChanged(sender: UISwitch) {
        self.dataSourceArray[sender.tag].isOn = sender.isOn
        NSObject.userDefaultSaveValue(sender.isOn, forKey: self.dataSourceArray[sender.tag].statusKey)
    }
}

// MARK: - UItableview Delegate dataSource complementation
extension CallComingSetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableTitleSwitchCell.CELL_ID) as? TableTitleSwitchCell else {
            return UITableViewCell.init()
        }
        
        let dataSourceInfo = self.dataSourceArray[indexPath.row]
        cell.showTitleLabel.text = dataSourceInfo.title
        cell.showSwitch.isOn = dataSourceInfo.isOn
        cell.showSwitch.tag = indexPath.row
        cell.showSwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControl.Event.valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableTitleSwitchCell.CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
