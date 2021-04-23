//
//  Log.swift
//  HWCloudLink
//
//  Created by mac on 2020/6/30.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import CocoaLumberjack
import SSZipArchive
class Log {
    static func checkLog(){
        let logPath = NSHomeDirectory() + "/Documents/Log"
        let isYES: ()? = try? FileManager.default.createDirectory(atPath: logPath, withIntermediateDirectories: true, attributes: nil)
        CLLog("文件创建结果\(String(describing: isYES))")
        let today = self.getTodayStr()
        let fileArray = FileManager.default.subpaths(atPath: logPath)
        
        if fileArray?.count != 0  {
            for fileName in (fileArray! as Array) {
                if fileName.hasSuffix(".log"){
                    let longDate = fileName.components(separatedBy: " ")[1] //2020-12-09-40-25-371
                    let shortDate = longDate.subString(to: 10) //2020-12-09
                    if shortDate != today { // 不是今天的，结尾是.log,需要压缩处理
                        let zipPath = self.getZipPath(fileName: fileName)
                        let zipYES = SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: [logPath+"/"+fileName])
//                        let zipYES = SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory:)
                        if zipYES {
                            CLLog("zipPath:压缩成功")
                            let removeYES: ()? = try? FileManager.default.removeItem(atPath: logPath + "/" + fileName)
                            CLLog("rmeoveYES:\(String(describing: removeYES))")
                        } else {
                            CLLog("zipPath:压缩失败")
                        }
                    }
                    
                }
            }
            //删除三天之前的日志，当天的日志算第一天，
            var timeArray:[String] = []
            for fileName in (fileArray! as Array) {
                let longDate = fileName.components(separatedBy: " ")[1] //2020-12-09-40-25-371
                let shortDate = longDate.subString(to: 10) //2020-12-09
                timeArray.append(shortDate) //获取到所有的时间
            }
            //按照时间进行排序
            timeArray.sort { (item1, item2) -> Bool in
                return item1 > item2
            }
            while timeArray.count > 3  { //删除超过三天之前的日志
                timeArray.removeLast()
            }
            //判断那些日志不在最近三天的日志里，然后清除掉
            for fileName in (fileArray! as Array) {
                let longDate = fileName.components(separatedBy: " ")[1] //2020-12-09-40-25-371
                let shortDate = longDate.subString(to: 10) //2020-12-09
                var isEqual = false
                for innerDate in timeArray {
                    if innerDate == shortDate { //时间相同，不需要清除掉
                        isEqual = true
                    }
                }
                if isEqual == false {
                    let removeYES: ()? = try? FileManager.default.removeItem(atPath: logPath + "/" + fileName)
                    CLLog("删除之前的日志:\(String(describing: removeYES))  日期是：\(shortDate)")
                }
                
            }
        }
    }
    
    
    static func start() {
        self.checkLog()
        let logPath = NSHomeDirectory() + "/Documents/Log"
        let logFileManager = DDLogFileManagerDefault(logsDirectory: logPath)
        let fileLogger = DDFileLogger(logFileManager: logFileManager)
        
        //保存周期 最多3天
        fileLogger.rollingFrequency = 60 * 60 * 24 ;//* 3; // 24*3 hour rolling
        //最大的日志文件数量
        fileLogger.logFileManager.maximumNumberOfLogFiles = 4
        //单个文件最大
        fileLogger.maximumFileSize =  1024 * 1024 * 5 //5M
        //文件总大小
        fileLogger.logFileManager.logFilesDiskQuota = 1024 * 1024 * 20
        
        let formatter = LogFormatter()
        fileLogger.logFormatter = formatter
        DDLog.add(fileLogger)
        
        let osLogger = DDOSLogger.sharedInstance
        osLogger.logFormatter = formatter
        DDLog.add(osLogger)
        
        guard let ttyLogger = DDTTYLogger.sharedInstance else { return }
        ttyLogger.logFormatter = formatter
        ttyLogger.colorsEnabled = false
        DDLog.add(ttyLogger)
    }
    
    static func stop() {
        DDLog.removeAllLoggers()
    }
   static func getTodayStr() -> String {
        //获得时间戳
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        return result
    }
    //获取压缩文件存放路径
    static func getZipPath(fileName:String) -> String {
        let logPath = NSHomeDirectory() + "/Documents/Log/"
        let result = fileName.subString(from: 0, to: fileName.count - 5 )
        let zipPath = logPath + result + ".zip"
        
        return zipPath
    }
}
