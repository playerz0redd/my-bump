//
//  Date+Formatter.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation

extension Date {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }
    
    var chatFormattedString: String {
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDateInToday(self) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return formatter.string(from: self)
        }
        
        if calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            formatter.locale = Locale.current
            let dayString = formatter.string(from: self)
            return dayString.capitalized
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: self)
    }
}
