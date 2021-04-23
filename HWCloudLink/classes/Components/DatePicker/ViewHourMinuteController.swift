//
// ViewHourMinuteController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/7.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol ViewHourMinuteDelegate: NSObjectProtocol {
    func viewHourMinuteSureBtnClick(viewVC: ViewHourMinuteController, seconds: Int)
}

class ViewHourMinuteController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var customDelegate: ViewHourMinuteDelegate?
    
    var selectedTimeLen:Int = 3600
    
    fileprivate lazy var dataPicker: UIPickerView = {
        let temp = UIPickerView.init(frame: CGRect.init(x: 0, y: 50, width: SCREEN_WIDTH, height: 198.0))
        temp.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor(hexString: "#262626"))
        temp.showsSelectionIndicator = true
        
        return temp
    }()
    
    fileprivate var hoursDataSource: [String] = []
    fileprivate var minutesDataSource: [String] = []
    
    //默认延长时间修改为30分钟 --2020.7.17 by lisa
    fileprivate var selectedHourIndex = 0
    fileprivate var selectedMinuteIndex = 2
    

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    func setViewUI() {
        
        // 设置时长
        if self.selectedTimeLen % 3600 == 0 {
            selectedHourIndex = (self.selectedTimeLen/3600)
            selectedMinuteIndex = 0
        } else {
            selectedHourIndex = (self.selectedTimeLen/3600)
            let CurrentMin = (self.selectedTimeLen % 3600 / 60)
            if CurrentMin == 0 {
                selectedMinuteIndex = 0
            }else if CurrentMin == 15 {
                selectedMinuteIndex = 1
            }else if CurrentMin == 30 {
                selectedMinuteIndex = 2
            }else{
                selectedMinuteIndex = 3
            }
        }
        
        self.dataPicker.delegate = self
        self.dataPicker.dataSource = self
        
        let PICKER_HEIGHT: CGFloat = 248.0
        let dataPickerView = UIView()
        self.view.addSubview(dataPickerView)
        
        let dataPickerTopView = UIView.init(frame:  CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        dataPickerTopView.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "#fafafa"), darkColor: UIColor(hexString: "#171717"))
        
        // title
        let showTitleLabel = UILabel.init(frame: CGRect.init(x: 16, y: 0, width: SCREEN_WIDTH / 2, height: dataPickerTopView.height))
        showTitleLabel.font = UIFont.systemFont(ofSize: 17.0)
        showTitleLabel.textColor = UIColor.colorWithSystem(lightColor: UIColor.colorWithRGBA(r: 30, g: 30, b: 30, a: 1), darkColor: UIColor.white)
        showTitleLabel.text = self.title
        dataPickerTopView.addSubview(showTitleLabel)
        
        // btn
        let sureBtn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDTH - 16 - 120, y: 0, width: 120, height: dataPickerTopView.height))
        sureBtn.setTitle(tr("确定"), for: .normal)
        sureBtn.contentHorizontalAlignment = .trailing
        sureBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        sureBtn.addTarget(self, action: #selector(sureBtnClick(sender:)), for: .touchUpInside)
        dataPickerTopView.addSubview(sureBtn)
        
        sureBtn.mas_makeConstraints { (make) in
            make?.width.mas_equalTo()(120)
            make?.right.mas_equalTo()(dataPickerTopView)?.offset()(-16)
            make?.height.mas_equalTo()(dataPickerTopView)
            make?.bottom.mas_equalTo()(dataPickerTopView)
        }
        
        dataPickerView.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self.view)
            make?.right.mas_equalTo()(self.view)
            make?.height.mas_equalTo()(PICKER_HEIGHT)
            make?.bottom.mas_equalTo()(self.view)
        }
        
        dataPickerView.addSubview(dataPickerTopView)
        dataPickerView.addSubview(self.dataPicker)
        
        dataPicker.mas_makeConstraints { (make) in
                   make?.left.mas_equalTo()(dataPickerView)
                   make?.right.mas_equalTo()(dataPickerView)
                   make?.height.mas_equalTo()(198.0)
                   make?.bottom.mas_equalTo()
            
        }
        
        dataPickerTopView.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(dataPickerView)
            make?.right.mas_equalTo()(dataPickerView)
            make?.height.mas_equalTo()(50)
            make?.top.mas_equalTo()
            
        }
        
    }
    
    func setInitData() {
        self.hoursDataSource.removeAll()
        self.minutesDataSource.removeAll()

        // set hour
        for index in 0..<24 {
            self.hoursDataSource.append(String.init(format: "%02d", index))
        }
        
        // set minute
        for index in 0..<4 {
            self.minutesDataSource.append(String.init(format: "%02d", index * 15))
        }
        
        self.dataPicker.reloadAllComponents()
    }
    
    // sure btn click
    @objc func sureBtnClick(sender: UIButton) {
        // 确定
        // 当前选中的时间
        let hour = self.hoursDataSource[selectedHourIndex] as NSString
        var minute = self.minutesDataSource[selectedMinuteIndex] as NSString
        if minute.substring(to: 1) == "0" {
            minute = minute.substring(from: 1) as NSString
        }
        let hourTemp = hour.integerValue
        let minuteTemp = minute.integerValue
        
        if hourTemp == 0 && minuteTemp == 0 {
            MBProgressHUD.showBottom(tr("会议时长至少15分钟"), icon: nil, view: self.view)
            return
        }
        
        self.customDelegate?.viewHourMinuteSureBtnClick(viewVC: self, seconds: hourTemp * 3600 + minuteTemp * 60)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        self.setViewUI()
        self.setInitData()
        self.dataPicker.selectRow(selectedHourIndex, inComponent: 0, animated: false)
        self.dataPicker.selectRow(selectedMinuteIndex, inComponent: 2, animated: false)
        self.dataPicker.selectRow(0, inComponent: 1, animated: false)
        self.dataPicker.selectRow(0, inComponent: 3, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.pickerView(self.dataPicker, didSelectRow: self.selectedHourIndex, inComponent: 0)
            self.pickerView(self.dataPicker, didSelectRow: self.selectedMinuteIndex, inComponent: 2)
            self.pickerView(self.dataPicker, didSelectRow: 0, inComponent: 1)
            self.pickerView(self.dataPicker, didSelectRow: 0, inComponent: 3)
        }
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        //changed at 2020.7.17 by lisa
        //延迟的原因是：pickerview的可视view尚未创建
       
       
    }
    
    
    // MARK: - UIPikcerView Delegate
    // MARK: numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    // MARK: numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.hoursDataSource.count
        case 1:
            return 1
        case 2:
            return self.minutesDataSource.count
        default:
            return 1
        }
    }
    
    // MARK: titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return self.hoursDataSource[row]
        case 1:
            return tr("小时")
        case 2:
             return self.minutesDataSource[row]
        default:
            return tr("分钟")
        }
    }
    
    // MARK: didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 当前选中的
        let selectedLabel = pickerView.view(forRow: row, forComponent: component) as? UILabel
        if selectedLabel != nil {
            selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            selectedLabel?.font = UIFont.systemFont(ofSize: 20.0)
        }
        
        switch component {
        case 0:
            self.selectedHourIndex = row
            selectedLabel?.text = self.hoursDataSource[row]
        case 1:
            selectedLabel?.text = tr("小时")
            selectedLabel?.textAlignment = .left
        case 2:
            self.selectedMinuteIndex = row
            selectedLabel?.text = self.minutesDataSource[row]
        default:
            selectedLabel?.text = tr("分钟")
            selectedLabel?.textAlignment = .left
        }
    }
    
    // MARK: rowHeightForComponent
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    // MARK: viewForRow
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let showTitleLabel: UILabel?
        if view == nil {
            showTitleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH / 4, height: 40.0))
        } else {
            showTitleLabel = view as? UILabel
        }
        
        showTitleLabel?.textAlignment = .center
        showTitleLabel?.textColor = UIColor(hexString: "#999999")
        showTitleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        switch component {
        case 0:
            showTitleLabel?.text = self.hoursDataSource[row]
        case 2:
            showTitleLabel?.text = self.minutesDataSource[row]
        default:
            break
        }
        
        return showTitleLabel!
    }
    
    
    // MARK: widthForComponent
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return SCREEN_WIDTH / 4
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
