//
//  EWDatePickerViewController.swift
//  EWDatePicker
//
//  Created by Ethan.Wang on 2018/8/27.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

class EWDatePickerViewController: UIViewController {

    var backDate: ((Date) -> Void)?
    
    var isFirst = true
    
    var dataSelectString = ""
    
    fileprivate var yearMonthArray: [String] = []
   
    var containV:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: ScreenInfo.Height-280, width: ScreenInfo.Width, height: 280))
        view.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "#fafafa"), darkColor: UIColor(hexString: "#171717"))
        return view
    }()
    var backgroundView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        return view
    }()
    var picker: UIPickerView = UIPickerView()
    var selectDateCom:DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())
    
    private var selectDayIndex: Int = 0
    
    private var minuteSelectIndexIsNeedToZero: Bool = false
    fileprivate var isFistLoading = true

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let currentCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        var currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        if currentDateCom != selectDateCom {
            currentDateCom = selectDateCom
        }
        
        let iseq = (selectDateCom.year == currentCom.year)
        
        picker.selectRow((currentDateCom.year)!-(currentCom.year)!, inComponent: 0, animated: true)
        picker.selectRow(iseq ? (currentDateCom.month)!-(currentCom.month)! : (selectDateCom.month!) - 1, inComponent: 1, animated: false)
        picker.selectRow((currentDateCom.day!) - 1, inComponent: 2, animated: true)
        picker.selectRow(caculateHowManyHour(), inComponent: 3, animated: true)
        picker.selectRow( minuteSelectIndexIsNeedToZero ? 0 : caculateHowManyMinut(), inComponent: 4, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFirst = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        picker.reloadAllComponents()
        let currentCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        var currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        if currentDateCom != selectDateCom {
            currentDateCom = selectDateCom
        }
        
        let iseq = (selectDateCom.year == currentCom.year)
        pickerView(picker, didSelectRow: (currentDateCom.year)!-(currentCom.year)!, inComponent: 0)
        pickerView(picker, didSelectRow: iseq ? (currentDateCom.month)!-(currentCom.month)! : (selectDateCom.month!) - 1, inComponent: 1)
        pickerView(picker, didSelectRow: (currentDateCom.day!) - 1, inComponent: 2)
        pickerView(picker, didSelectRow: caculateHowManyHour(), inComponent: 3)
        pickerView(picker, didSelectRow: minuteSelectIndexIsNeedToZero ? 0 : caculateHowManyMinut(), inComponent: 4)
        
        
//        pickerView(picker, didSelectRow: 0, inComponent: 0)
//        pickerView(picker, didSelectRow: (currentDateCom.month!) - 1, inComponent: 1)
//        pickerView(picker, didSelectRow: (currentDateCom.day!) - 1, inComponent: 2)
//        pickerView(picker, didSelectRow: caculateHowManyHour(), inComponent: 3)
//        pickerView(picker, didSelectRow: minuteSelectIndexIsNeedToZero ? 0 : caculateHowManyMinut(), inComponent: 4)
        
    }
    
    //计算分钟的index
    private func caculateHowManyMinut() -> Int {
        var currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        if currentDateCom != selectDateCom {
            currentDateCom = selectDateCom
        }
        switch currentDateCom.minute! {
        case 0...14:
            return 0
        case 15...29:
            return 1
        case 30...44:
            return 2
        default:
            return 3
        }
    }
    
    private func caculateHowManyHour() -> Int {
        var currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        if currentDateCom != selectDateCom {
            currentDateCom = selectDateCom
        }
        switch currentDateCom.minute! {
               case 0...45:
                   return currentDateCom.hour!
               default:
                   minuteSelectIndexIsNeedToZero = true
                   return currentDateCom.hour! + 1
               }
    }
    
    
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        drawMyView()
    }
    //MARK: - Func
    private func drawMyView(){
        self.view.backgroundColor = UIColor.clear
        self.view.insertSubview(self.backgroundView, at: 0)
        self.modalPresentationStyle = .custom//viewcontroller弹出后之前控制器页面不隐藏 .custom代表自定义

        let titlelable = UILabel(frame: CGRect(x: 15, y: 20, width: ScreenInfo.Width - 100, height: 20))
        titlelable.text = tr("请选择开始时间")
        titlelable.textColor = UIColor.colorWithSystem(lightColor: UIColor.colorWithRGBA(r: 30, g: 30, b: 30, a: 1), darkColor: UIColor.white)
        let sure = UIButton(frame: CGRect(x: ScreenInfo.Width - 80, y: 20, width: 70, height: 20))
        sure.setTitle(tr("确定"), for: .normal)
        sure.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
//        cancel.addTarget(self, action: #selector(self.onClickCancel), for: .touchUpInside)
        sure.addTarget(self, action: #selector(self.onClickSure), for: .touchUpInside)
        picker = UIPickerView(frame: CGRect(x: 0, y: 50, width: ScreenInfo.Width, height: 230))
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor(hexString: "#262626"))
        picker.clipsToBounds = true//如果子视图的范围超出了父视图的边界，那么超出的部分就会被裁剪掉。
        //创建日期选择器
        self.containV.addSubview(titlelable)
        self.containV.addSubview(sure)
        self.containV.addSubview(picker)
        self.view.addSubview(self.containV)

        self.transitioningDelegate = self as UIViewControllerTransitioningDelegate//自定义转场动画
    }
    
    func getChooseDate() -> Date? {
        //计算选择的小时
        var hourString = ""
        
        if picker.selectedRow(inComponent: 3) < 10 {
            
            if picker.selectedRow(inComponent: 3) == 0 {
                hourString = "00:"
            }else{
                hourString = "0" + "\(picker.selectedRow(inComponent: 3)):"
            }
        }else{
            hourString = "\(picker.selectedRow(inComponent: 3)):"
        }
        
        let currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        let selectYear = (currentDateCom.year ?? 0) + self.picker.selectedRow(inComponent: 0)
        
        var dateString = ""
        
        if selectYear == currentDateCom.year {
            if isCNlanguage() {
                dateString = "\(selectYear)" + "年" + "\(self.picker.selectedRow(inComponent: 1) + (currentDateCom.month ?? 0))" + "月" + "\(self.picker.selectedRow(inComponent: 2) + 1)" + "日" + hourString + (self.picker.selectedRow(inComponent: 4) == 0 ? "00" : "\(self.picker.selectedRow(inComponent: 4) * 15)") + ":59"
            } else {
                dateString = "\(selectYear)" + "-" + "\(self.picker.selectedRow(inComponent: 1) + (currentDateCom.month ?? 0))" + "-" + "\(self.picker.selectedRow(inComponent: 2) + 1)" + " " + hourString + (self.picker.selectedRow(inComponent: 4) == 0 ? "00" : "\(self.picker.selectedRow(inComponent: 4) * 15)") + ":59"
            }
        }else {
            if isCNlanguage() {
               dateString = "\(selectYear)" + "年" + "\(self.picker.selectedRow(inComponent: 1) + 1)" + "月" + "\(self.picker.selectedRow(inComponent: 2) + 1)" + "日" + hourString + (self.picker.selectedRow(inComponent: 4) == 0 ? "00" : "\(self.picker.selectedRow(inComponent: 4) * 15)") + ":59"
            } else {
                dateString = "\(selectYear)" + "-" + "\(self.picker.selectedRow(inComponent: 1) + 1)" + "-" + "\(self.picker.selectedRow(inComponent: 2) + 1)" + " " + hourString + (self.picker.selectedRow(inComponent: 4) == 0 ? "00" : "\(self.picker.selectedRow(inComponent: 4) * 15)") + ":59"
            }
        }
        
        
      

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = isCNlanguage() ? "yyyy年MM月dd日HH:mm:ss" : "yyyy-MM-dd HH:mm:ss"
        
        self.yearMonthArray = ["\(self.picker.selectedRow(inComponent: 0) + (currentDateCom.year!))", "\(self.picker.selectedRow(inComponent: 1) + 1)"]
        return dateFormatter.date(from: dateString)
    }

    //MARK: onClick
    @objc func onClickCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func onClickSure() {
        
        //计算选择的小时
//        var hourString = ""
//
//        if picker.selectedRow(inComponent: 3) < 10 {
//
//            if picker.selectedRow(inComponent: 3) == 0 {
//                hourString = "00:"
//            }else{
//                hourString = "0" + "\(picker.selectedRow(inComponent: 3)):"
//            }
//        }else{
//            hourString = "\(picker.selectedRow(inComponent: 3)):"
//        }
//
//        let currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
//
//        let dateString = "\(self.picker.selectedRow(inComponent: 0) + (currentDateCom.year!))年" + "\(self.picker.selectedRow(inComponent: 1) + 1)月" + "\(self.picker.selectedRow(inComponent: 2) + 1)日" + hourString + (self.picker.selectedRow(inComponent: 4) == 0 ? "00" : "\(self.picker.selectedRow(inComponent: 4) * 15)") + ":59"
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy年MM月dd日HH:mm:ss"
        
        guard let chooseDate = self.getChooseDate() else { return }
        
        if chooseDate.compare(Date()).rawValue == -1 {
            MBProgressHUD.showBottom(tr("所选时间不能小于当前时间"), icon: nil, view: self.view)
            return
        }
        
        /// 直接回调显示
        if self.backDate != nil{
            self.backDate!(chooseDate)
        }
        /*** 如果需求需要不能选择已经过去的日期
         let dateSelect = dateFormatter.date(from: dateString)
         let date = Date()
         let calendar = Calendar.current
         let dateNowString = String(format: "%02ld-%02ld-%02ld", calendar.component(.year, from: date) , calendar.component(.month, from: date), calendar.component(.day, from: date))

        /// 判断选择日期与当前日期关系
        let result:ComparisonResult = (dateSelect?.compare(dateFormatter.date(from: dateNowString)!))!

        if result == ComparisonResult.orderedAscending {
            /// 选择日期在当前日期之前,可以选择使用toast提示用户.
            return
            }else{
            /// 选择日期在当前日期之后. 正常调用
            if self.backDate != nil{
                self.backDate!(dateFormatter.date(from: dateString) ?? Date())
            }
        }
         */
        self.dismiss(animated: true, completion: nil)
    }
    ///点击任意位置view消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
//MARK: - PickerViewDelegate
extension EWDatePickerViewController:UIPickerViewDelegate,UIPickerViewDataSource {

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        if component == 0 {
            return 2
        }else if component == 1 {
            
            let year: Int = pickerView.selectedRow(inComponent: 0) + currentDateCom.year!
            return year == currentDateCom.year ? (13 - (currentDateCom.month ?? 0)) : currentDateCom.month ?? 0
            
        }else if component == 2 {
            let year: Int = pickerView.selectedRow(inComponent: 0) + currentDateCom.year!
            let month: Int = (year == currentDateCom.year) ?  pickerView.selectedRow(inComponent: 1) + (currentDateCom.month ?? 0) : (pickerView.selectedRow(inComponent: 1) + 1)
            var days: Int = howManyDays(inThisYear: year, withMonth: month)
            
            if year != (currentDateCom.year ?? 0) && month == (currentDateCom.month ?? 0) {
                days = currentDateCom.day ?? days
            }
            
            return days
            
        }else if component == 3 {
            
            let year: Int = pickerView.selectedRow(inComponent: 0) + currentDateCom.year!
            let month: Int = (year == currentDateCom.year) ?  pickerView.selectedRow(inComponent: 1) + (currentDateCom.month ?? 0) : (pickerView.selectedRow(inComponent: 1) + 1)
            let day: Int = pickerView.selectedRow(inComponent: 2)
            
            if year != (currentDateCom.year ?? 0) && month == (currentDateCom.month ?? 0) && day == (currentDateCom.day ?? 0){
               
                return currentDateCom.hour ?? 24
            }
            
            return 24
            
        }else{
            return 4
        }
    }
    
//    private func howManyHours() ->
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return ScreenInfo.Width / 4
        }else{
            return (ScreenInfo.Width - (ScreenInfo.Width / 4 )) / 4 - 4
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
        if component == 0 {
            return "\((currentDateCom.year!) + row)\(tr("年"))"
        }else if component == 1 {
            
            return "\(row + (currentDateCom.month ?? 0))\(tr("月"))"
        }else if component == 2 {
            return "\(row + 1)\(tr("日"))"
        }else if component == 3 {
           
            if row < 10 {
                 return "0\(row + 0)\(" :")"
            }else{
                 return "\(row)\(" :")"
            }
            
        }else {
            if row == 0 {
                return "00"
            }else{
                return "\(row * 15)"
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 当前选中的
        let selectedLabel = pickerView.view(forRow: row, forComponent: component) as? UILabel
        if selectedLabel != nil {
            selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            selectedLabel?.font = UIFont.systemFont(ofSize: 22.0)
        }
        
        
        if component == 2 {
            if selectDayIndex != row {
                selectDayIndex = row
            }
        }
        
        if component == 0 {
    
            pickerView.reloadComponent(1)
             pickerView.reloadComponent(2)
            
            let selectedLabel = pickerView.view(forRow: 0, forComponent: 1) as? UILabel
            if selectedLabel != nil {
                selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                selectedLabel?.font = UIFont.systemFont(ofSize: 22.0)
            }
            
            if !isFirst {
                self.picker.selectRow(0, inComponent: 1, animated: false)
                self.pickerView(self.picker, didSelectRow: 0, inComponent: 1)
                self.picker.selectRow(0, inComponent: 2, animated: false)
                self.pickerView(self.picker, didSelectRow: 0, inComponent: 2)
            }else{
                
                let currentCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
                var currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
                if currentDateCom != selectDateCom {
                    currentDateCom = selectDateCom
                }
                
                let iseq = (selectDateCom.year == currentCom.year)
                
                self.picker.selectRow(iseq ? (currentDateCom.month)!-(currentCom.month)! : (selectDateCom.month!) - 1, inComponent: 1, animated: false)
                self.pickerView(self.picker, didSelectRow: iseq ? (currentDateCom.month)!-(currentCom.month)! : (currentDateCom.month!) - 1, inComponent: 1)
                self.picker.selectRow((currentDateCom.day!) - 1, inComponent: 2, animated: false)
                self.pickerView(self.picker, didSelectRow: (currentDateCom.day!) - 1, inComponent: 2)
                
                isFirst = false
                
            }
        }
        
        if component == 1 {
            pickerView.reloadComponent(2)
            _ = self.getChooseDate()
            let dateStr = "\(self.yearMonthArray[0])-\(self.yearMonthArray[1])-01 00:00:00"
            let selectedDate = NSDate.init(from: dateStr, andFormatterString: DATE_STANDARD_FORMATTER, andTimeZone: nil)
            if selectedDate != nil {
                let day = NSDate.getNumberOfDaysInMonth(with: selectedDate as Date?)
                if selectDayIndex > day - 1 {
                    selectDayIndex = day - 1
                } else {
                    if self.isFistLoading {
                        let dateArray = NSDate.getDateYearMonthDay(with: Date.init())
                        selectDayIndex = dateArray![2] as! Int - 1
                        self.isFistLoading = false
                    }
                }
            } else {
                let dateArray = NSDate.getDateYearMonthDay(with: Date.init())
                selectDayIndex = dateArray![2] as! Int - 1
            }
            
            let selectedLabel = pickerView.view(forRow: row, forComponent: component) as? UILabel
            if selectedLabel != nil {
                selectedLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                selectedLabel?.font = UIFont.systemFont(ofSize: 22.0)
            }
            
            self.picker.selectRow(selectDayIndex, inComponent: 2, animated: false)
            self.pickerView(self.picker, didSelectRow: selectDayIndex, inComponent: 2)
        }
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let showTitleLabel: UILabel?
        if view == nil {
            showTitleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH / 2, height: 40.0))
        } else {
            showTitleLabel = view as? UILabel
        }
        
        showTitleLabel?.textAlignment = .center
        showTitleLabel?.textColor = UIColor(hexString: "#999999")
        showTitleLabel?.font = UIFont.systemFont(ofSize: 18)
        let currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],   from: Date())    //日期类型
         if component == 0 {
               showTitleLabel?.text = "\((currentDateCom.year!) + row)\(tr("年"))"
           }else if component == 1 {
            let year = pickerView.selectedRow(inComponent: 0) + currentDateCom.year!
            showTitleLabel?.text =  (year == currentDateCom.year) ? "\(row + (currentDateCom.month ?? 0))\(tr("月"))" : "\(row + 1)\(tr("月"))"
           }else if component == 2 {
            showTitleLabel?.text = "\(row + 1)\(tr("日"))"
           }else if component == 3 {
              
               if row < 10 {
                    showTitleLabel?.text =  "0\(row + 0)\(" :")"
               }else{
                    showTitleLabel?.text =  "\(row)\(" :")"
               }
               
           }else {
               if row == 0 {
                   showTitleLabel?.text  = "00"
               }else{
                   showTitleLabel?.text = "\(row * 15)"
               }
           }
        
        return showTitleLabel!
    }
}



//MARK: - 转场动画delegate
extension EWDatePickerViewController:UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = EWDatePickerPresentAnimated(type: .present)
        return animated
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = EWDatePickerPresentAnimated(type: .dismiss)
        return animated
    }
    
    //计算天
   private func howManyDays(inThisYear year: Int, withMonth month: Int) -> Int {
       
       if (month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12) {
           return 31
       }
       if (month == 4) || (month == 6) || (month == 9) || (month == 11) {
           return 30
       }
       if (year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3) {
           return 28
       }
       if year % 400 == 0 {
           return 29
       }
       if year % 100 == 0 {
           return 28
       }
       return 29
   }
}

