//
//  ViewMinutesViewController.swift
//  HWCloudLink
//
//  Created by JYF on 2020/7/20.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol ViewOnlyMinuteDelegate: NSObjectProtocol {
    func viewOnlyMinuteSureBtnClick(viewVC: ViewMinutesViewController, seconds: Int)
}

class ViewMinutesViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    static let vcID = "ViewMinutesViewController"
    
    weak var customDelegate: ViewOnlyMinuteDelegate?
    
    fileprivate lazy var dataPicker: UIPickerView = {
        let temp = UIPickerView.init(frame: CGRect.init(x: 0, y: 50, width: SCREEN_WIDTH, height: 198.0))
        temp.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor(hexString: "#262626"))
        temp.showsSelectionIndicator = true
        
        return temp
    }()
    
    fileprivate var minutesDataSource: [String] = []
    fileprivate var selectedMinuteIndex = 0
    
    override func viewDidLoad() {
          super.viewDidLoad()

          // Do any additional setup after loading the view.
          self.setViewUI()
          self.setInitData()
      }
      
      func setViewUI() {
          self.dataPicker.delegate = self
          self.dataPicker.dataSource = self
          
          let PICKER_HEIGHT: CGFloat = 248.0
          let dataPickerView = UIView()
          self.view.addSubview(dataPickerView)
          
          let dataPickerTopView = UIView.init(frame:  CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
          dataPickerTopView.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "#fafafa"), darkColor: UIColor(hexString: "#171717"))
                
          // title
        let showTitleLabel = UILabel.init(frame: CGRect.init(x: isiPhoneXMore() ? 44 + 16 : 16, y: 0, width: SCREEN_WIDTH / 2, height: dataPickerTopView.height))
          showTitleLabel.font = UIFont.systemFont(ofSize: 16.0)
          showTitleLabel.textColor = UIColor.colorWithSystem(lightColor: UIColor.colorWithRGBA(r: 30, g: 30, b: 30, a: 1), darkColor: UIColor.white)
          showTitleLabel.text = self.title
          dataPickerTopView.addSubview(showTitleLabel)
          
          // btn
        let sureBtn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDTH - 16 - 60 - (isiPhoneXMore() ? 44 : 0), y: 0, width: 60, height: dataPickerTopView.height))
          sureBtn.setTitle(tr("确定"), for: .normal)
          sureBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
          sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
          sureBtn.addTarget(self, action: #selector(sureBtnClick(sender:)), for: .touchUpInside)
          dataPickerTopView.addSubview(sureBtn)
          
          sureBtn.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(dataPickerTopView)?.offset()(isiPhoneXMore() ? -44 - 16 : -16)
            make?.height.mas_equalTo()(dataPickerTopView)
            make?.bottom.mas_equalTo()(dataPickerTopView)
          }
          
          dataPickerView.mas_makeConstraints { [weak self] (make) in
              guard let self = self else {return}
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
        self.minutesDataSource.removeAll()
        // set minute
        for index in 1..<25 {
            self.minutesDataSource.append(String.init(format: "%02d", index * 15))
        }
        self.dataPicker.reloadAllComponents()
    }
     // sure btn click
    @objc func sureBtnClick(sender: UIButton) {
        // 当前选中的时间
        var minute = self.minutesDataSource[selectedMinuteIndex] as NSString
        if minute.substring(to: 1) == "0" {
            minute = minute.substring(from: 1) as NSString
        }
        let minuteTemp = minute.integerValue

        self.customDelegate?.viewOnlyMinuteSureBtnClick(viewVC: self, seconds: minuteTemp * 60)

        self.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func backgroundBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.dataPicker.selectRow(selectedMinuteIndex, inComponent: 0, animated: true)
        self.pickerView(self.dataPicker, didSelectRow: self.selectedMinuteIndex, inComponent: 0)
    }
       
    

    // MARK: - UIPikcerView Delegate
    // MARK: numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.minutesDataSource.count
    }
    
    // MARK: titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.minutesDataSource[row] + "  \(tr("分钟"))"
    }
    
    // MARK: didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 当前选中的
        let selectedLabel = pickerView.view(forRow: row, forComponent: component) as? UILabel
        if selectedLabel != nil {
            selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            selectedLabel?.font = UIFont.systemFont(ofSize: 20.0)
        }
        self.selectedMinuteIndex = row
        selectedLabel?.text = self.minutesDataSource[row] + "  \(tr("分钟"))"
    }
    
    // MARK: rowHeightForComponent
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    // MARK: viewForRow
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let showTitleLabel: UILabel?
        if view == nil {
            showTitleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH / 2, height: 40.0))
        } else {
            showTitleLabel = view as? UILabel
        }
        
        showTitleLabel?.textAlignment = .center
        showTitleLabel?.textColor = UIColor(hexString: "#999999")
        showTitleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        showTitleLabel?.text = self.minutesDataSource[row] + "  \(tr("分钟"))"
        return showTitleLabel!
    }
    
    // MARK: widthForComponent
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return SCREEN_WIDTH / 2
    }
    
    
    class func secondTodelayStr(_ seconds: Int) -> String {
//           var delayStr = ""
//           let minutes = (seconds % 3600) / 60
//           let hour = seconds / 3600
//           if hour > 0 {
//               delayStr = "会议已延长" + String(hour) + "  小时"
//               if minutes > 0 {
//                   delayStr = delayStr + String(minutes) + "  分钟"
//               }
//           } else {
//               delayStr = "会议已延长" + String(minutes) + "  分钟"
//           }
        return "\(tr("会议已延长")) \(seconds / 60 ) \(tr("分钟"))"
    }
}
