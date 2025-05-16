//
//  CalendarDay.swift
//  diploma
//
//  Created by Olga on 12.01.2025.
//

import Foundation


struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isSelected: Bool
    let isToday: Bool
}
