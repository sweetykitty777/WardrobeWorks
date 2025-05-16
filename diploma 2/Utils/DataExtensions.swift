//
//  DataExtensions.swift
//  diploma
//
//  Created by Olga on 01.02.2025.
//

import Foundation

extension Date {
    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: self)
    }
    
    var formattedDayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
}
