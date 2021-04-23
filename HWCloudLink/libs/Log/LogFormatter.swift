//
//  LogFormatter.swift
//  HWCloudLink
//
//  Created by mac on 2020/6/30.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import CocoaLumberjack.DDDispatchQueueLogFormatter

class LogFormatter: DDDispatchQueueLogFormatter {

    let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

      super.init()
    }

    override func format(message logMessage: DDLogMessage) -> String? {
        
        var logLevel = ""
        switch logMessage.flag {
            case .error:
            logLevel = "[ERROR] >  "
            case .warning:
            logLevel = "[WARN]  >  "
            case .info:
            logLevel = "[INFO] >  "
            case .debug:
            logLevel = "[DEBUG] >  "
            case .verbose:
            logLevel = "[VBOSE] >  "
            default:
            logLevel = "[VBOSE] >  "
        }
        
        let dateAndTime = dateFormatter.string(from: logMessage.timestamp)
        return "\(dateAndTime) :  \(logLevel) [class:\(logMessage.fileName):  line:\(logMessage.line): func:\(logMessage.function ?? "")]:   \(logMessage.message)"
    }
}
