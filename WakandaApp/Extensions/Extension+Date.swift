//
//  Extension+Date.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 28/05/21.
//

import Foundation

extension Date {
    
    static let zero: Date = {
        return DateFormatter.standard.date(from: "1970-01-01 00:00:00")!
    }()
    
    func asString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func asString(dateFormatter: DateFormatter) -> String {
        return dateFormatter.string(from: self)
    }
    
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
    
    func removeTime() -> Date {
        let formatter = DateFormatter.yearMonthDay
        let strDate = formatter.string(from: self)
        return formatter.date(from: strDate) ?? self
    }
    
    func removeDate() -> Date {
        let formatter = DateFormatter.timeFormat
        let strDate = formatter.string(from: self)
        return formatter.date(from: strDate) ?? self
    }
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func combineTime(time: Date) -> Date {
        let dateStr = DateFormatter.yearMonthDay.string(from: self)
        let timeStr = DateFormatter.hourMinuteSecond.string(from: time)
        let combineDate = DateFormatter.standard.date(from: "\(dateStr) \(timeStr)")
        return combineDate ?? self
    }
    
    // This Month Start
    var getThisMonthStart: Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)
    }
    
    //Last Month Start
    var getLastMonthStart: Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)
    }

    //Last Month End
    var getLastMonthEnd: Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
}
