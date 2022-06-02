//
//  Extension+DateFormatter.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 26/05/21.
//

import Foundation

extension DateFormatter {
    
    convenience init(dateFormat: String, withUTCTimeZone: Bool = false) {
        self.init()
        self.dateFormat = dateFormat
        self.timeZone = withUTCTimeZone ? TimeZone(abbreviation: "UTC") : TimeZone.current
    }
    
    static let standard: DateFormatter = {
        return DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")
    }()

    static let yearMonthDay: DateFormatter = {
        return DateFormatter(dateFormat: "yyyy-MM-dd")
    }()
    
    static let hourMinuteSecond: DateFormatter = {
        return DateFormatter(dateFormat: "HH:mm:ss")
    }()
    
    static let monthDayYear: DateFormatter = {
        return DateFormatter(dateFormat: "MMM d yyyy")
    }()
    
    static let monthDayCommaYear: DateFormatter = {
        return DateFormatter(dateFormat: "MMM d, yyyy")
    }()
    
    static let monthDayYearWithDayName: DateFormatter = {
        return DateFormatter(dateFormat: "MMM d, yyyy (E)")
    }()
    
    static let timeFormat: DateFormatter = {
        return DateFormatter(dateFormat: "hh:mm a")
    }()
    
    static let dateMonthNameYearWithTime: DateFormatter = {
        return DateFormatter(dateFormat: "dd MMM yyyy hh:mm a")
    }()
    
    // Mark:- UTC
    static let standardUTC: DateFormatter = {
        return DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss", withUTCTimeZone: true)
    }()
}
