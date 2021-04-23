//
//  Date+extension.swift
//  HWCloudLink
//
//  Created by mac on 2020/6/12.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

extension Date {
    
    /**  是否为今天 */
    static func isToday(date: Date) -> Bool{
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day,.month,.year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfCmps = calendar.dateComponents(unit, from: date)
        return (selfCmps.year == nowComps.year) &&
        (selfCmps.month == nowComps.month) &&
        (selfCmps.day == nowComps.day)
    }
    
    //本月开始日期
    static func startOfCurrentMonth() -> Date {
        let date = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(
            Set<Calendar.Component>([.year, .month]), from: date)
        let startOfMonth = calendar.date(from: components)!
        return startOfMonth
    }
     
    //本月结束日期
    static func endOfCurrentMonth(returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
         
        let endOfMonth =  calendar.date(byAdding: components, to: startOfCurrentMonth())!
        return endOfMonth
    }
    
    //本年开始日期
    static func startOfCurrentYear() -> Date {
        let date = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(Set<Calendar.Component>([.year]), from: date)
        let startOfYear = calendar.date(from: components)!
        return startOfYear
    }
     
    //本年结束日期
    static func endOfCurrentYear(returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.year = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
         
        let endOfYear = calendar.date(byAdding: components, to: startOfCurrentYear())!
        return endOfYear
    }
    
    //指定年月的开始日期
    static func startOfMonth(year: Int, month: Int) -> Date {
        let calendar = NSCalendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calendar.date(from: startComps)!
        return startDate
    }
     
    //指定年月的结束日期
    static func endOfMonth(year: Int, month: Int, returnEndTime:Bool = false) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
         
        let endOfYear = calendar.date(byAdding: components,
                                      to: startOfMonth(year: year, month:month))!
        return endOfYear
    }
}
