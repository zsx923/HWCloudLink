//
// ViewDateTimePickerController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/6.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

private let quarterCount = 31
private let timeConversionCount = 60
private let differSecond = quarterCount * timeConversionCount * 24 * 60 * 60

protocol ViewDateTimePickerDelegate: NSObjectProtocol {
    func viewDateTimePickerSureBtnClick(viewVC: ViewDateTimePickerController, selectedDateStr: String)
}

class ViewDateTimePickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var customDelegate: ViewDateTimePickerDelegate?
    
    fileprivate lazy var dataPicker: UIPickerView = {
        let temp = UIPickerView.init(frame: CGRect.init(x: 0, y: 50, width: SCREEN_WIDTH, height: 198.0))
        temp.backgroundColor = UIColor.white
        temp.showsSelectionIndicator = true
        
        return temp
    }()
    
    fileprivate var yearsDataSource: [String] = []
    ///只有一个年份的情况
    private var  monthDaysForOneYearDataSource: [String] = []
    /// 两个年份的情况
    private var monthDaysForTowYearDataSource: [String] = []
    ///月份的总数据源
    fileprivate var monthDaysDataSource: [String] = []
    
    
    fileprivate var hoursDataSource: [String] = []
    fileprivate var minutesDataSource: [String] = []
    
    fileprivate var selectedYearIndex = 0
    fileprivate var selectedMonthDayIndex = 0
    fileprivate var selectedHourIndex = 0
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
        let dataPickerView = UIView.init(frame:  CGRect.init(x: 0, y: SCREEN_HEIGHT - PICKER_HEIGHT, width: SCREEN_WIDTH, height: PICKER_HEIGHT))
        
        
        let dataPickerTopView = UIView.init(frame:  CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        dataPickerTopView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        
        // title
        let showTitleLabel = UILabel.init(frame: CGRect.init(x: 16, y: 0, width: SCREEN_WIDTH / 2, height: dataPickerTopView.height))
        showTitleLabel.font = UIFont.systemFont(ofSize: 16.0)
        showTitleLabel.textColor = COLOR_DARK_GAY
        showTitleLabel.text = tr("请选择开始时间")
        dataPickerTopView.addSubview(showTitleLabel)
        
        // btn
        let sureBtn = UIButton.init(frame: CGRect.init(x: SCREEN_WIDTH - 16 - 60, y: 0, width: 60, height: dataPickerTopView.height))
        sureBtn.setTitle(tr("确定"), for: .normal)
        sureBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        sureBtn.addTarget(self, action: #selector(sureBtnClick(sender:)), for: .touchUpInside)
        dataPickerTopView.addSubview(sureBtn)
        
        
        dataPickerView.addSubview(dataPickerTopView)
        dataPickerView.addSubview(self.dataPicker)
        self.view.addSubview(dataPickerView)
    }
    
    func setInitData() {
        self.yearsDataSource.removeAll()
        self.monthDaysDataSource.removeAll()
        
        // 获取当前的时间
        let currentDate = Int(Date().timeIntervalSince1970)
        
        let dateArray = NSDate.getDateYearMonthDay(with: Date.init())
        
        //每年的12月15日 24：00就需要显示下个年份了
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日HH时mm分ss秒"
        let endDayForYear = Int(dateFormatter.date(from: "\(dateArray![0])年" + "12月2日23时59分59秒")?.timeIntervalSince1970 ?? 0)
        
        if  currentDate - endDayForYear < 0 {
            //本年度的时间够用
            self.yearsDataSource.append("\(dateArray![0])年")
        }else{
            //需要增加下一年的年份
            self.yearsDataSource.append("\(dateArray![0])年")
            self.yearsDataSource.append("\((dateArray![0] as! NSInteger) + 1)年")
        }
        
        // set month and day
        let currentDays =  NSDate.getNumberOfDaysInMonth(with: Date.init())
        let currentMonth = dateArray![1] as! Int
        let currentDay = dateArray![2] as! Int
        
        if yearsDataSource.count == 1 {  //一个年份的情况
            
            for index in currentDay..<currentDays+1 {
                self.monthDaysForOneYearDataSource.append("\(String.init(format: "%02d", currentMonth))月\(String.init(format: "%02d", index))日") // 获取当月当天的日期后的日期 可能30天  31天  28天  29 天
            }
            
            var isNeedTowMonth = false
            
            while self.monthDaysForOneYearDataSource.count < 30  {
                //获取下个月的日期数组
                let nextDate = startOfMonth(year: (dateArray![0] as! NSInteger), month: currentMonth + (isNeedTowMonth ? 2 : 1))
                 let nextMonthArray =  NSDate.getNumberOfDaysInMonth(with: nextDate)
                
                
                for index in 1..<nextMonthArray + 1 {
                    self.monthDaysForOneYearDataSource.append("\(String.init(format: "%02d", currentMonth + (isNeedTowMonth ? 2 : 1)))月\(String.init(format: "%02d", index))日")
                    if monthDaysForOneYearDataSource.count == 30 {
                        return
                    }
                }
                
                isNeedTowMonth = true
            }
            
        }else{ //2个年份
            
            for index in currentDay..<currentDays+1 { //获取自己年份的剩余日期
                monthDaysForOneYearDataSource.append("\(String.init(format: "%02d", currentMonth))月\(String.init(format: "%02d", index))日")
            }
            
            var isNeedTowMonth = false
            while self.monthDaysForTowYearDataSource.count !=  30 - monthDaysForOneYearDataSource.count {
               //获取下个月的日期数组
               let nextDate = startOfMonth(year: ((dateArray![0] as! NSInteger) + 1), month: (isNeedTowMonth ? 2 : 1))
               
               let nextMonthArray =  NSDate.getNumberOfDaysInMonth(with: nextDate)
               
               
               for index in 1..<nextMonthArray+1 {
                   self.monthDaysForTowYearDataSource.append("\(String.init(format: "%02d", (isNeedTowMonth ? 2 : 1)))月\(String.init(format: "%02d", index))日")
                if monthDaysForTowYearDataSource.count == 30 - monthDaysForOneYearDataSource.count {
                       return
                   }
               }
               
               isNeedTowMonth = true
           }
            
            
        }
        
        //首次赋值
        monthDaysDataSource = monthDaysForOneYearDataSource
        
        //处理小时分钟
        setHourAndMinutesData(selectedMonth: currentMonth, selectedDay: currentDay)
        
        self.dataPicker.reloadAllComponents()
    }
    
    private func setMinute(selectHoure: Int) {
         self.minutesDataSource.removeAll()
         let dateArray = NSDate.getDateYearMonthDay(with: Date.init())
         let currentHoure = dateArray![3] as! Int
        
         let scaleValue = 15 // 刻度
        
        // set minute
        var currentMinute = dateArray![4] as! Int
        if currentMinute % scaleValue != 0 {
            currentMinute = currentMinute/scaleValue + 1
        } else {
            currentMinute = currentMinute/scaleValue
        }
        
        if currentHoure == selectHoure {
            for index in currentMinute..<4 {
                
                self.minutesDataSource.append(String.init(format: "%02d", index * scaleValue))
            }
        }else{
            for index in 0..<4 {
                self.minutesDataSource.append(String.init(format: "%02d", index * scaleValue))
            }
        }
        self.dataPicker.reloadComponent(3)
    }
    
    func setHourAndMinutesData(selectedMonth: Int, selectedDay: Int) {
        self.hoursDataSource.removeAll()
        self.minutesDataSource.removeAll()
        
        let dateArray = NSDate.getDateYearMonthDay(with: Date.init())
        let currentMonth = dateArray![1] as! Int
        let currentDay = dateArray![2] as! Int
        
        let scaleValue = 15 // 刻度
        if selectedDay == currentDay && selectedMonth == currentMonth {
            // set hour
            let currentHour = dateArray![3] as! Int
            for index in currentHour..<24 {
                self.hoursDataSource.append(String.init(format: "%02d", index))
            }
            
            // set minute
            var currentMinute = dateArray![4] as! Int
            if currentMinute % scaleValue != 0 {
                currentMinute = currentMinute/scaleValue + 1
            } else {
                currentMinute = currentMinute/scaleValue
            }
            
            if currentMinute != 4 {
                
                for index in currentMinute..<4 {
                    
                    self.minutesDataSource.append(String.init(format: "%02d", index * scaleValue))
                }
            }else{
                
                hoursDataSource.removeFirst()
                for index in 0..<4 {
                    self.minutesDataSource.append(String.init(format: "%02d", index * scaleValue))
                }
            }
            
            
        } else {
            // set hour
            for index in 1..<24 {
                self.hoursDataSource.append(String.init(format: "%02d", index))
            }
            
            hoursDataSource.insert("00", at: 0)
            
            // set minute
            for index in 0..<4 {
                self.minutesDataSource.append(String.init(format: "%02d", index * scaleValue))
            }
        }
        self.dataPicker.reloadComponent(2)
        self.dataPicker.reloadComponent(3)
        selectedHourIndex = 0
        selectedMinuteIndex = 0
        self.dataPicker.selectRow(selectedHourIndex, inComponent: 2, animated: true)
        self.dataPicker.selectRow(selectedMinuteIndex, inComponent: 3, animated: true)
        self.pickerView(self.dataPicker, didSelectRow: selectedHourIndex, inComponent: 2)
        self.pickerView(self.dataPicker, didSelectRow: selectedMinuteIndex, inComponent: 3)
    }
    
    // sure btn click
    @objc func sureBtnClick(sender: UIButton) {
        // 确定
        // 获取当前时间
        let currentDateStr = NSString.getLocalTime()
        
        // 当前选中的时间
        let year = NSString.getRangeOfIndex(withStart: 0, andEnd: 4, andDealStr: self.yearsDataSource[selectedYearIndex])
        let month = NSString.getRangeOfIndex(withStart: 0, andEnd: 2, andDealStr: self.monthDaysDataSource[selectedMonthDayIndex])
        let day = NSString.getRangeOfIndex(withStart: 3, andEnd: 5, andDealStr: self.monthDaysDataSource[selectedMonthDayIndex])
        let hour = self.hoursDataSource[selectedHourIndex]
        let minute = self.minutesDataSource[selectedMinuteIndex]
        
        let selectedDateStr = "\(year!)-\(month!)-\(day!) \(hour):\(minute):00"
        
        if selectedDateStr < currentDateStr! {
            // 选择历史时间
            MBProgressHUD.showBottom(tr("不能小于当前时间"), icon: nil, view: self.view)
            return
        } else if selectedDateStr == currentDateStr! {
            // 选择现在时间
        } else {
            // 选择未来时间
        }
        
        self.customDelegate?.viewDateTimePickerSureBtnClick(viewVC: self, selectedDateStr: selectedDateStr)
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
        
        self.dataPicker.selectRow(selectedYearIndex, inComponent: 0, animated: true)
        self.dataPicker.selectRow(selectedMonthDayIndex, inComponent: 1, animated: true)
        self.dataPicker.selectRow(selectedHourIndex, inComponent: 2, animated: true)
        self.dataPicker.selectRow(selectedMinuteIndex, inComponent: 3, animated: true)
        
        self.pickerView(self.dataPicker, didSelectRow: selectedYearIndex, inComponent: 0)
        self.pickerView(self.dataPicker, didSelectRow: selectedMonthDayIndex, inComponent: 1)
        self.pickerView(self.dataPicker, didSelectRow: selectedHourIndex, inComponent: 2)
        self.pickerView(self.dataPicker, didSelectRow: selectedMinuteIndex, inComponent: 3)
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
            return self.yearsDataSource.count
        case 1:
            return  monthDaysDataSource.count
        case 2:
            return self.hoursDataSource.count
        case 3:
            return self.minutesDataSource.count
        default:
            return 0
        }
    }
    
    // MARK: titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return self.yearsDataSource[row]
        case 1:
            
            return self.monthDaysDataSource[row]
        case 2:
            return self.hoursDataSource[row]
        case 3:
            return self.minutesDataSource[row]
        default:
            return ""
        }
    }
    
    // MARK: didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 当前选中的
               let selectedLabel = pickerView.view(forRow: row, forComponent: component) as? UILabel
               if selectedLabel != nil {
                   selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                   selectedLabel?.font = UIFont.systemFont(ofSize: 20.0)
                   if component == 2 && selectedLabel?.subviews.count == 1 {
                       let pointLabel = selectedLabel?.subviews[0]
                       pointLabel?.isHidden = false
                   }
               }
        
        switch component {
        case 0:
            self.selectedYearIndex = row
            
            if row == 1 {
                monthDaysDataSource = monthDaysForTowYearDataSource
            }else{
                monthDaysDataSource = monthDaysForOneYearDataSource
            }
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            
            let selectedLabel = pickerView.view(forRow: 0, forComponent: 1) as? UILabel
            if selectedLabel != nil {
                selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                selectedLabel?.font = UIFont.systemFont(ofSize: 20.0)
            }
            
            let selectedMonth = Int(NSString.getRangeOfIndex(withStart: 0, andEnd: 2, andDealStr: self.monthDaysDataSource[0])!)!
            let selectedDay = Int(NSString.getRangeOfIndex(withStart: 3, andEnd: 5, andDealStr: self.monthDaysDataSource[0])!)!
            
            setHourAndMinutesData(selectedMonth:selectedMonth, selectedDay: selectedDay)
            
        case 1:
            pickerView.reloadComponent(2)
            pickerView.reloadComponent(3)
             let selectedLabel = pickerView.view(forRow: row, forComponent: component) as? UILabel
            if selectedLabel != nil {
                selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                selectedLabel?.font = UIFont.systemFont(ofSize: 20.0)
            }
            self.selectedMonthDayIndex = row
            let selectedMonth = Int(NSString.getRangeOfIndex(withStart: 0, andEnd: 2, andDealStr: self.monthDaysDataSource[selectedMonthDayIndex])!)!
            let selectedDay = Int(NSString.getRangeOfIndex(withStart: 3, andEnd: 5, andDealStr: self.monthDaysDataSource[row])!)!
            self.setHourAndMinutesData(selectedMonth: selectedMonth, selectedDay: selectedDay)
             
        case 2:
            self.selectedHourIndex = row
            setMinute(selectHoure: Int(self.hoursDataSource[row])!)
              let selectedLabel = pickerView.view(forRow: 0, forComponent: 3) as? UILabel
                      if selectedLabel != nil {
                          selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                          selectedLabel?.font = UIFont.systemFont(ofSize: 20.0)
                      }
        case 3:
            self.selectedMinuteIndex = row
        default:
            break
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
            showTitleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: component == 1 ?  (SCREEN_WIDTH / 5) * 2 : (SCREEN_WIDTH / 5) * 1, height: 40.0))
            // set point
            if component == 2 {
                let pointLabel = UILabel.init(frame: CGRect.init(x: (SCREEN_WIDTH / 5) * 1 / 2, y: 0, width: 4, height: 40.0))
                pointLabel.textAlignment = .right
                pointLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                pointLabel.text = ":"
                pointLabel.font = UIFont.systemFont(ofSize: 16.0)
                showTitleLabel?.addSubview(pointLabel)
            }
            
        } else {
            showTitleLabel = view as? UILabel
        }
        
        showTitleLabel?.textAlignment = .left
        showTitleLabel?.textColor = COLOR_DARK_GAY
        showTitleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        switch component {
        case 0:
            showTitleLabel?.textAlignment = .center
            showTitleLabel?.text = self.yearsDataSource[row]
        case 1:
            showTitleLabel?.text = self.monthDaysDataSource[row]
        case 2:
            showTitleLabel?.text = self.hoursDataSource[row]
            if showTitleLabel!.subviews.count == 1 {
                let pointLabel = showTitleLabel!.subviews[0]
                pointLabel.isHidden = true
            }
        case 3:
            showTitleLabel?.text = self.minutesDataSource[row]
        default:
            break
        }
        
        return showTitleLabel!
    }
    
    
    // MARK: widthForComponent
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 1 ?  (SCREEN_WIDTH / 5) * 2 : (SCREEN_WIDTH / 5) * 1
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

//处理日期
extension ViewDateTimePickerController {
    
    //指定年月的开始日期
    private func startOfMonth(year: Int, month: Int) -> Date {
        let calendar = NSCalendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calendar.date(from: startComps)!
        return startDate
    }
}
