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
        formatter.locale = Locale(identifier: "ru_RU") 
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: self).capitalized
    }

    var formattedDayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter.string(from: self).capitalized
    }
}

extension DateFormatter {
    static var short: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

extension ISO8601DateFormatter {
    static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}

