//
//  GlobalPrefixHeader.swift
//  EnvironmentSource
//
//  Created by jointsky on 2016/11/28.
//  Copyright © 2016年 陈帆. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

/*******************   SCREEN  屏幕的尺寸     ******************/
// 进入APP需要重新设置宽高 防止横屏进入宽高是反的
var SCREEN_WIDTH = UIScreen.main.bounds.size.width              // 宽
var SCREEN_HEIGHT = UIScreen.main.bounds.size.height            // 高
//日志最大限制
var LOGSIZEMAX = 600*1024*1024
//状态栏高度
let  StatusBarHeight =  UIApplication.shared.statusBarFrame.size.height
// 导航栏高度
let  AppNaviHeight   =  44 + StatusBarHeight
 

/*******************   SCREEN  判断设备型号     ******************/
// is 横屏
let UI_IS_LANDSCAPE = (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight)
// is pad
let UI_IS_IPAD = (UIDevice.current.userInterfaceIdiom == .pad)
// is phone
let UI_IS_IPHONE = (UIDevice.current.userInterfaceIdiom == .phone)
// is bang screen
let UI_IS_BANG_SCREEN = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
let UI_IS_IPHONE_6 = (UI_IS_IPHONE && SCREEN_HEIGHT == 667.0)

/********************    application Delegate  *************/
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate


/*****************     VIEW 界面视图设置     *****************/
// 导航栏和状态栏的高度
let NAVIGATION_AND_STATUS_HEIGHT: CGFloat = (44.0+20.0)
// 状态栏的高度
let STATUS_BAR_HEIGHT: CGFloat = 20.0
// 导航栏的高度
let NAVIGATION_BAR_HEIGHT: CGFloat = 44.0


/*********************   COLOR  - 颜色      **************************/
// 系统普通颜色
let COLOR_NORMAL_SYSTEM = UIColorRGBA_Selft(r: 255, g: 255, b: 255, a: 1.0)
// 系统高亮颜色
let COLOR_HIGHT_LIGHT_SYSTEM = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1.0)

// 分割线的颜色
let COLOR_SEPARATOR_LINE = UIColorFromRGB(rgbValue: 0xe8e8e8)
// tableView 的背景色
let BG_COLOR_TABLE_OR_COLLECTION = UIColorFromRGB(rgbValue: 0xfafafa)
// light Gay color
let COLOR_LIGHT_GAY = UIColorFromRGB(rgbValue: 0x999999)
// Gay color
let COLOR_GAY = UIColorFromRGB(rgbValue: 0x666666)
// dark Gay color
let COLOR_DARK_GAY = UIColorFromRGB(rgbValue: 0x333333)

// normal white color
let COLOR_NORMAL_WHITE = UIColorFromRGB(rgbValue: 0xfdfdfd)

// gray white color
let COLOR_GRAY_WHITE = UIColorFromRGB(rgbValue: 0xcccccc)

// User Red
let COLOR_RED = UIColorFromRGB(rgbValue: 0xF34B4B)

// blue
let COLOR_BLUE = UIColorFromRGB(rgbValue: 0x419dff)


/********************     web 设置    ****************/
let PAGE_COUNT_PER: Int32 = 20
let PAGE_COUNT_50PER: Int32 = 50
let PAGE_COUNT_8PRE: Int32 = 8


/*******************    DATE 日期时间设置     *********************/
// 日期的标准格式
let DATE_STANDARD_FORMATTER = "yyyy-MM-dd HH:mm:ss"


/************************     DICT_KEY 自定义         ********************/
let DICT_TITLE = "title"             // 标题
let DICT_SUB_TITLE = "subTitle"      // 标题
let DICT_IMAGE_PATH = "imagePath"    // 本地图片地址
let DICT_IDENTIFIER = "identifier"   // ID
let DICT_IS_NEXT = "isNext"          // 是否有跳转
let DICT_USER_INFO  = "userInfo"     // 用户信息字典key
let DICT_USER_RECENT  = "userRecent" // 用户信息字典key
let DICT_SUB_TYPE  = "dictType"      // Type的key
let DICT_SUB_VALUE1  = "value1"      // value1的key
let DICT_SUB_VALUE2  = "value2"      // value2的key
let DICT_SUB_VALUE3  = "value3"      // value3的key
let DICT_IS_MESSAGE_ALL_READED = "isMessageAllReaded"   // 是否所有消息已读
let DICT_SAVE_PHOTO_DESCIPTION = "SAVE_PHOTO_DESCIPTION"   // 保存照片描述
let DICT_SAVE_LOGIN_RemainPwd = "SAVE_LOGIN_RemainPwd"   // 记住密码
let DICT_SAVE_LOGIN_autoLogin = "SAVE_LOGIN_autoLogin"   // 自动登录
let DICT_SAVE_SERVER_INFO = "SERVER_CONFIG"   // 存储服务器相关信息
let DICT_SAVE_SERVER_PORT_TYPE = "SERVER_PORT_TYPE"   // 存储服务器的端口类型
let DICT_SAVE_SERVER_INFO_AGENT_IS_ON = "SERVER_CONFIG_AGENT_IS_ON"// 代理服务器的相关信息是否开启
let DICT_SAVE_SERVER_INFO_CA_IS_ON = "SERVER_CONFIG_CA_IS_ON"// CA证书是否开启
let DICT_SAVE_SERVER_INFO_GUOMI_IS_ON = "DICT_SAVE_SERVER_INFO_GUOMI_IS_ON"// 国密是否开启
let DICT_SAVE_SERVER_INFO_AGENT = "SERVER_CONFIG_AGENT"// 代理服务器的相关信息
let DICT_SAVE_LOGIN_userName = "SAVE_LOGIN_userName"   // 用户名
let DICT_SAVE_LOGIN_password = "SAVE_LOGIN_password"   // 密码
let DICT_SAVE_NIC_NAME = "DICT_SAVE_NIC_NAME"
let DICT_SAVE_UPLOAD_LOCATION = "SAVE_UPLOAD_LOCATION" // 上报位置
let DICT_SAVE_HOME_LAYOUT_LEVEL = "SAVE_HOME_LAYOUT_LEVEL" // 首页图层选择
let DICT_SAVE_WEB_REQUEST_IP_PORT = "SAVE_WEB_REQUEST_IP_PORT" // 请求IP和端口
let DICT_SAVE_iS_FIRST_OPEN_APP = "DICT_SAVE_iS_FIRST_OPEN_APP"   // 第一次打开APP
let DICT_SAVE_MICROPHONE_IS_ON = "MICROPHONE_IS_ON"   // 麦克风是否开启
let DICT_SAVE_VIDEO_IS_ON = "VIDEO_IS_ON"   //  摄像头是否开启
let DICT_SAVE_LOG_UPLOAD_IS_ON = "LOG_UPLOAD_IS_ON"   //  日志上传是否开启
let DICT_SAVE_SHAKE_IS_ON = "SHAKE_IS_ON"   //  振动是否开启
let DICT_SAVE_RING_IS_ON = "RING_IS_ON"   //  铃声是否开启
let DICT_SAVE_WLAN_CALL_BROADBAND_SETTING = "WLAN_CALL_BROADBAND_SETTING"   //  WLAN呼叫宽带
let DICT_SAVE_THEME_SETTING = "THEME_SETTING"   //  主题设置
let DICT_SAVE_MEETING_TYPE = "MEETING_TYPE"   //  会议类型
let DICT_SAVE_LOGIN_HISTORY_ACCOUNTS_TYPE = "DICT_SAVE_LOGIN_HISTORY_ACCOUNTS_TYPE" // 帐号类型 change at xuegd 2021/01/13 : 暂时不用
let DICT_SAVE_LOGIN_HISTORY_PASSWORDS_TYPE = "DICT_SAVE_LOGIN_HISTORY_PASSWORDS_TYPE" // change at xuegd 2021/01/13 : 暂时不用
let DICT_SAVE_MEETING_ADVANCE_SETTING_PASSWORD = "DICT_SAVE_MEETING_ADVANCE_SETTING_PASSWORD" // 高级设置-会议密码
let DICT_SAVE_UserSetingTable_Version = "DICT_SAVE_UserSetingTable_Version"   //  用户配置信息表
let DICT_SAVE_SRTPENCRYPTIONN = "DICT_SAVE_SRTPENCRYPTIONN" // SRTP加密
let DICT_SAVE_BFCPTRANSFERMODE = "DICT_SAVE_TRANSFERMODE" // BFCP传输类型
let DICT_SAVE_AGREESTATEMENT = "DICT_SAVE_AGREE_STATEMENT" //同意风险提示(未设置会议密码的提示)
let DICT_SAVE_IS_AGREE_PRIVATEEXPLAIN = "DICT_SAVE_IS_AGREE_PRIVATEEXPLAIN"   // 隐私协议

/*********************     LOCATION  定位设置     **********************/
/// 默认 未定位成功的城市 和 code
let DEFAULT_LOCATIONFAILED_CITY = "北京市"
let DEFAULT_LOCATIONFAILED_CODE = "110000000"
let DEFAULT_CITY_CENTER_LONGITUDE = "116.403406"
let DEFAULT_CITY_CENTER_LATITUDE = "39.91582"
/// 定位保存值
let LOCATION_ADDRESS = "locationAddress"        // 定位地址
let LOCATION_LATITUDE = "locationLatitude"      // 定位维度
let LOCATION_LONGTITUDE = "locationLongitude"   // 定位经度

/*********************     LANGUAGE  国际化设置     **********************/
// 设置语言改变
let LOCALIZABLE_CHANGE_LANGUAGE = "LOCALIZABLE_CHANGE_LANGUAGE"
//  语言选择
let LOCALIZABLE_SAVE_LANGUAGE_SWITCH = "LOCALIZABLE_LANGUAGE_SWITCH"


/*****************     IMAGE_DEFAULT  默认图片     ********************/
// 默认返回键的图片地址
let DEFAULT_BACK_IMAGE_PATH = "default_back_icon.png"
// 默认的用户头像
let DEFAULT_USER_ICON = #imageLiteral(resourceName: "i-2")
// 默认App图标
let DEFUALT_APP_ICON = UIImage(named: "default_app_icon.png")

let PHOTO_PM_25 = "pm25"                        // Pm2.5


/****************  NOTIFICATION - 消息通知机制    *********************/
let NOTIFICATION_UPDATE_UserContacts = "NotificationUpdateUserContacts"     // 通讯录消息通知
let NOTIFICATION_UPDATE_UserPhotos = "NotificationUpdateUserPhotos"     // 图片消息通知
let NOTIFICATION_UPDATE_UserVideos = "NotificationUpdateUserVideo"   // 视频消息通知
let NOTIFICATION_UPDATE_UserCalendar = "NotificationUpdateUserCalendar"   // 日历消息通知
let NOTIFICATION_UPDATE_UserConnected = "NotificationUpdateUserConnected"   // 连接成功的消息通知
let NOTIFICATION_UPDATE_UserDataSure = "NotificationUpdateUserDataSure"   // 数据确认的消息通知
let NOTIFICATION_UPDATE_UserDataTranslateDone = "NotificationUpdateUserDataTranslateDone"   // 数据传输完成


/**************   ACCOUNT - 账户信息    ****************/
/// App Store id信息
let APP_ID = "382201985"   // Appid
let URL_APPSTORE_APP = "itms-apps://itunes.apple.com/app/id"        // App在App Store的下载地址

// bugly
let BUGLY_APP_ID = "68b6b609d3"
let BUGLY_APP_KEY = "68fe995c-c148-439c-88e1-fefb3d294174"


/****************   CHARACTER 文字长度个数     ******************/
let WORDCOUNT_USERNAME = 127   // 用户昵称（字）
let WORDCOUNT_USER_PASSWORD = 32    // 用户密码长度（字）
let WORDCOUNT_USER_PASSWORD_MIN = 2 // 用户密码长度（字）
let WORDCOUNT_SERVER_IP_COUNT_MAX = 255  // 服务器的ip的最大字数
let WORDCOUNT_SERVER_PORT_COUNT_MAX = 16  // 服务器的port的最大字数
let WORDCOUNT_SERVER_URI_COUNT_MAX = 255  // 服务器的URI的最大字数


/// 设置rgb颜色的方法
///
/// - parameter r: red
/// - parameter g: green
/// - parameter b: blue
/// - parameter a: alpha
///
/// - returns: UIColor
func UIColorRGBA_Selft(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

func isiPhoneXMore() -> Bool {
    return (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! > 0.0
}
/// 获取随机颜色值
///
/// - Returns: 颜色对象
func getRandomColor() -> UIColor {
    return UIColor(red: CGFloat(Double(arc4random_uniform(256))/255.0), green: CGFloat(Double(arc4random_uniform(256))/255.0), blue: CGFloat(Double(arc4random_uniform(256))/255.0), alpha: 1.0)
}

/// 16进制的方式设置颜色（eg. 0xff1122）
///
/// - Parameter rgbValue: 16进制颜色值
/// - Returns: UIColor
func UIColorFromRGB(rgbValue:Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
}

/// 16进制的方式设置颜色（eg. 0xff1122）透明
///
/// - Parameter rgbValue: 16进制颜色值
/// - Returns: UIColor
func UIColorFromRGBA(rgbValue:Int, alpha: CGFloat) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: alpha)
}


/// 获取A-Z的图片对象
/// - Parameter name: 汉字或字母
func getUserIconWithAZ(name: String) -> UIImage {
    var imageName: String = "az_default"
    let defaultImage = UIImage.init(named: imageName)
    defaultImage?.accessibilityIdentifier = imageName
    
    if name == "" {
        let randomNum = Int(arc4random() % 4)
        if randomNum == 0 {
            return defaultImage!
        }
        imageName = "az_default-\(randomNum)"
        let image = UIImage.init(named: imageName)
        image?.accessibilityIdentifier = imageName
        if image == nil {
            return defaultImage!
        }
        return image!
    }

    guard let letter = NSString.firstCharactor(name)else {
        return defaultImage!
    }
        
    if (letter >= "A" && letter <= "Z") || (letter >= "a" && letter <= "z") {
        let lowerLetter = letter.lowercased()
        let randomNum = Int(arc4random() % 4)
        
        var goalImage: UIImage?
        if randomNum == 0 {
            imageName = "\(lowerLetter)-\(1)"
        } else {
            imageName = "\(lowerLetter)-\(randomNum)"
        }
        goalImage = UIImage.init(named: imageName)
        goalImage?.accessibilityIdentifier = imageName

        if goalImage == nil {
            goalImage = defaultImage
        }
        return goalImage!
    }
    
    let nums = ["0","1","2","3","4","5","6","7","8","9"]
    if nums.contains(letter) {
        let lowerLetter = letter.lowercased()
        let randomNum = Int(arc4random() % 4)
        
        var goalImage: UIImage?
        if randomNum == 0 {
            imageName = "num-\(lowerLetter)-\(1)"
        } else {
            imageName = "num-\(lowerLetter)-\(randomNum)"
        }
        goalImage = UIImage.init(named: imageName)
        goalImage?.accessibilityIdentifier = imageName
        
        if goalImage == nil {
            goalImage = defaultImage
        }
        return goalImage!
    }
    
    if letter == "#" || letter == "*" {
        let lowerLetter = letter.lowercased()
        let randomNum = Int(arc4random() % 4)
        
        var goalImage: UIImage?
        if randomNum == 0 {
            imageName = "symbol-\(lowerLetter)-\(1)"
        } else {
            imageName = "symbol-\(lowerLetter)-\(randomNum)"
        }
        goalImage = UIImage.init(named: imageName)
        goalImage?.accessibilityIdentifier = imageName

        if goalImage == nil {
            goalImage = defaultImage
        }
        return goalImage!
    }
    
    let randomNum = Int(arc4random() % 4)
    if randomNum == 0 {
        return defaultImage!
    }
    imageName = "az_default-\(randomNum)"
    let image = UIImage.init(named: imageName)
    image?.accessibilityIdentifier = imageName
    if image == nil {
        return defaultImage!
    }
    return image!
}


/// 获取A-Z的图片对象
/// - Parameter name: 汉字或字母
func getUserIconWithAZForOne(name: String) -> UIImage {
    let defaultImage: UIImage = UIImage.init(named: "az_default-2")!
    
    if name == "" {
       return defaultImage
    }

    guard let letter = NSString.firstCharactor(name)else {
        return defaultImage
    }
    
    if (letter < "A" || letter > "Z") && (letter < "a" || letter > "z") {
         return defaultImage
    }
    
    let lowerLetter = letter.lowercased()
    
    return UIImage.init(named: lowerLetter)!
    
}

/// 获取A-Z的图片卡片的背景色
/// - Parameter name: 汉字或字母
func getCardImageAndColor(from name: String) -> (textColor: UIColor,backGroudColor: UIColor, gradientColor: UIColor, cardImage: UIImage?, colorIndex: Int) {
    let defaultImage: UIImage = UIImage.init(named: "more-orange")!
    let blueTextColor = UIColor.colorWithSystem(lightColor: UIColorFromRGB(rgbValue: 0x2A5177), darkColor: UIColor.white)
    let blueBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xBFDDF5, alpha: 1), darkColor: UIColor(hexString: "#191B20"))
    let blueGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xBFDDF5, alpha: 0.6), darkColor: UIColor(hexString: "#191B20", alpha: 0.8))
    let orangeTextColor = UIColor.colorWithSystem(lightColor: UIColorFromRGB(rgbValue: 0x562A0E), darkColor: UIColor.white)
    let orangeBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xFFE8C7, alpha: 1), darkColor: UIColor(hexString: "#211919"))
    let orangeGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xFFE8C7, alpha: 0.6), darkColor: UIColor(hexString: "#211919", alpha: 0.8))
    let purpleTextColor = UIColor.colorWithSystem(lightColor: UIColorFromRGB(rgbValue: 0x2A336E), darkColor: UIColor.white)
    let purpleBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xCFC8F7, alpha: 1), darkColor: UIColor(hexString: "#20191E"))
    let purpleGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xCFC8F7, alpha: 0.6), darkColor: UIColor(hexString: "#20191E", alpha: 0.8))
    let greenTextColor = UIColor.colorWithSystem(lightColor: UIColorFromRGB(rgbValue: 0x253229), darkColor: UIColor.white)
    let greenBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xB8ECC1, alpha: 1), darkColor: UIColor(hexString: "#19201B"))
    let greenGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xB8ECC1, alpha: 0.6), darkColor: UIColor(hexString: "#19201B", alpha: 0.8))
    
    if name == "" {
        return (orangeTextColor, orangeBackgroundColor, orangeGradientColor, defaultImage, 1)
    }

    guard let letter = NSString.firstCharactor(name)else {
        return (orangeTextColor, orangeBackgroundColor, orangeGradientColor, defaultImage, 1)
    }
    
    let randomNum = Int(arc4random() % 4)
    if (letter < "A" || letter > "Z") && (letter < "a" || letter > "z") {
        
         switch randomNum {
            case 0:
                return (blueTextColor, blueBackgroundColor, blueGradientColor, UIImage(named: "more-blue"), randomNum)
            case 1:
                return (orangeTextColor, orangeBackgroundColor, orangeGradientColor, UIImage(named: "more-orange"), randomNum)
            case 2:
                return (purpleTextColor, purpleBackgroundColor, purpleGradientColor, UIImage(named: "more-purple"), randomNum)
            default:
                return (greenTextColor, greenBackgroundColor, greenGradientColor, UIImage(named: "more-green"), randomNum)
         }
    }
    
    let lowerLetter = letter.lowercased()
        
    switch randomNum {
       case 0:
           return (blueTextColor, blueBackgroundColor, blueGradientColor, UIImage(named: "\(lowerLetter)-blue"), randomNum)
       case 1:
           return (orangeTextColor, orangeBackgroundColor, orangeGradientColor, UIImage(named: "\(lowerLetter)-orange"), randomNum)
       case 2:
           return (purpleTextColor, purpleBackgroundColor, purpleGradientColor, UIImage(named: "\(lowerLetter)-purple"), randomNum)
       default:
           return (greenTextColor, greenBackgroundColor, greenGradientColor, UIImage(named: "\(lowerLetter)-green"), randomNum)
    }
}

func getBackgroundColor(index: Int) -> (backGroudColor: UIColor, gradientColor: UIColor) {
    let blueBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xBFDDF5, alpha: 1), darkColor: UIColor(hexString: "#191B20"))
    let blueGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xBFDDF5, alpha: 0.6), darkColor: UIColor(hexString: "#191B20", alpha: 0.8))
    let orangeBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xFFE8C7, alpha: 1), darkColor: UIColor(hexString: "#211919"))
    let orangeGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xFFE8C7, alpha: 0.6), darkColor: UIColor(hexString: "#211919", alpha: 0.8))
    let purpleBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xCFC8F7, alpha: 1), darkColor: UIColor(hexString: "#20191E"))
    let purpleGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xCFC8F7, alpha: 0.6), darkColor: UIColor(hexString: "#20191E", alpha: 0.8))
    let greenBackgroundColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xB8ECC1, alpha: 1), darkColor: UIColor(hexString: "#19201B"))
    let greenGradientColor = UIColor.colorWithSystem(lightColor: UIColorFromRGBA(rgbValue: 0xB8ECC1, alpha: 0.6), darkColor: UIColor(hexString: "#19201B", alpha: 0.8))
    switch index {
       case 0:
           return (blueBackgroundColor, blueGradientColor)
       case 1:
           return (orangeBackgroundColor, orangeGradientColor)
       case 2:
           return (purpleBackgroundColor, purpleGradientColor)
       default:
           return (greenBackgroundColor, greenGradientColor)
    }
}

/// 计算字符串长度
///
/// - Parameters:
///   - text: 字符串
///   - font: 字体大小
///   - size: 字符串长宽最大值
/// - Returns: 计算字符串的合理长宽
func sizeWithText(text: NSString, font: UIFont, size: CGSize) -> CGSize {
    let attributes = [NSAttributedString.Key.font: font]
    let option = NSStringDrawingOptions.usesLineFragmentOrigin
    let rect:CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
    return rect.size;
}

public func CLLog<T>(_ message: T,
                      level: DDLogLevel = DDDefaultLogLevel,
                      context: Int = 0,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line,
                      tag: Any? = nil,
                      asynchronous async: Bool = asyncLoggingEnabled,
                      ddlog: DDLog = .sharedInstance) {
    
    _DDLogMessage(("\(message)"), level: level, flag: .info, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}
public func CLLogDebug<T>(_ message: T,
                          level: DDLogLevel = .debug,
                      context: Int = 0,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line,
                      tag: Any? = nil,
                      asynchronous async: Bool = asyncLoggingEnabled,
                      ddlog: DDLog = .sharedInstance) {
    
    _DDLogMessage(("\(message)"), level: level, flag: .info, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}
public func CLLogError<T>(_ message: T,
                          level: DDLogLevel = .error,
                      context: Int = 0,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line,
                      tag: Any? = nil,
                      asynchronous async: Bool = asyncLoggingEnabled,
                      ddlog: DDLog = .sharedInstance) {
    _DDLogMessage(("\(message)"), level: level, flag: .info, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}
public func CLLogWarn<T>(_ message: T,
                          level: DDLogLevel = .warning,
                      context: Int = 0,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line,
                      tag: Any? = nil,
                      asynchronous async: Bool = asyncLoggingEnabled,
                      ddlog: DDLog = .sharedInstance) {
    _DDLogMessage(("\(message)"), level: level, flag: .info, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}
/// 格式化显示浮点数字符串（有小数值，则显示；没有就不显示）
///
/// - Parameter testNumber: 源字符串
/// - Returns: 格式后字符串
func formatterDoubleStringShow(testNumber:String) -> String{
    
    var outNumber = String(format: "%@", testNumber)
    var i = 1
    
    if testNumber.contains("."){
        while i < testNumber.count {
            if outNumber.hasSuffix("0"){
                outNumber.remove(at: outNumber.endIndex)
                i = i + 1
            }else{
                break
            }
        }
        if outNumber.hasSuffix("."){
            outNumber.remove(at: outNumber.endIndex)
        }
        return outNumber
    }
    else{
        return testNumber
    }
}


//将原始的url编码为合法的url
func urlEncoded(str: String) -> String {
    let encodeUrlString = str.addingPercentEncoding(withAllowedCharacters:
        .urlQueryAllowed)
    return encodeUrlString ?? ""
}

//将编码后的url转换回原始的url
func urlDecoded(str: String) -> String {
    return str.removingPercentEncoding ?? ""
}

// 设置样式类型
func changeNameAndCodeTitleStyle(cellText:String,nameStr:String,codeStr:String) -> NSMutableAttributedString {
    let strStyle = NSMutableAttributedString.init(string: cellText)
    strStyle.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0), range: NSRange.init(location: nameStr.count + 1, length: codeStr.count))
    strStyle.addAttribute(.foregroundColor, value: COLOR_GAY, range: NSRange.init(location: nameStr.count + 1, length: codeStr.count))
    return strStyle
}

// reasonCode is equal
func reasonCodeIsEqualErrorType(reasonCode: UInt32, type: UInt32) -> Bool {
    return Tools.toHex(Int64(type)) == Tools.toHex(Int64(reasonCode))
}

/// 拨打电话
func callPhone(_ phone: String) {
    if phone.isEmpty {
        CLLog("电话号码异常")
    } else {
        var tel = "tel://"+phone
        //去掉空格-不然有些电话号码会使 URL 报 nil
        tel = tel.replacingOccurrences(of: " ", with: "", options: .literal, range: nil);
        CLLog(tel)
        if let urls = URL(string: tel){
            UIApplication.shared.open(urls, options: [:], completionHandler: {
               (success) in
                CLLog("Open \(phone): \(success)")
            })
        }else{
            CLLog("url 为空!")
        }
    }
}

/// 更改特殊表达式的颜色和字体（字符串）
///
/// - Parameters:
///   - goalStr: 目标字符串
///   - color: 颜色
///   - font: 字体
///   - regx: 正则 默认： "\\d+"数字样式， "包含的字符串"的样式
///   匹配中文字符 [\u4e00-\u9fa5]
///   匹配双字节字符(包括汉字在内) [^\x00-\xff]
///   匹配网址：[a-zA-z]+://[^\s]*
///   匹配国内电话 \d{3}-\d{8}|\d{4}-\{7,8}
///   匹配腾讯QQ号 [1-9][0-9]{4,}
///   匹配18位身份证号^(\d{6})(\d{4})(\d{2})(\d{2})(\d{3})([0-9]|X)$
/// - Returns: attributeString
func changeRegxSpecialStringStyle(goalStr: String,
                 color: UIColor,
                  font: UIFont?,
                  regx: String = "\\d+") -> NSMutableAttributedString {
    let attributeString = NSMutableAttributedString(string: goalStr)
    do {
        // 数字正则表达式
        let regexExpression = try NSRegularExpression(pattern: regx, options: NSRegularExpression.Options())
        let result = regexExpression.matches(
            in: goalStr,
            options: NSRegularExpression.MatchingOptions(),
            range: NSMakeRange(0, goalStr.count)
        )
        for item in result {
            if font != nil {
                attributeString.setAttributes(
                    [.foregroundColor : color, .font: font as Any],
                    range: item.range
                )
            } else {
                attributeString.setAttributes(
                    [.foregroundColor : color],
                    range: item.range
                )
            }
        }
    } catch {
        print("Failed with error: \(error)")
    }
    return attributeString
}

// 获取当前语音
public func getCurrentLanguage() -> String {
    return Locale.preferredLanguages.first ?? "en"
}

// 国际化设置语言
public func tr(_ string:String) -> String {
    return (Bundle.init(path: Bundle.main.path(forResource: UserDefaults.standard.string(forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH), ofType: "lproj") ?? "en")?.localizedString(forKey: string, value: nil, table: "Localizable"))!;
}

// 是否中文语言
public func isCNlanguage() -> Bool {
    let str = UserDefaults.standard.string(forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH)
    if str == "" || str == nil {
        return getCurrentLanguage().hasPrefix("zh")
    } else {
        return !(str == "en")
    }
}

// 微信分享相关信息
let wechatShareAppId = "wx43e05ad84e851d6b"
let universalLink = "https://ipsapro.isoftstone.com/portal/app/"
let appSecret = "7ba8465323dc6d9a662c03fb6e7a6061"


