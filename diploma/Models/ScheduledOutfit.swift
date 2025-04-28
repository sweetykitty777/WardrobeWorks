//
//  ScheduledOutfit.swift
//  diploma
//
//  Created by Olga on 23.03.2025.
//

import Foundation
struct ScheduledOutfit: Identifiable {
    let id = UUID()
    let date: Date
    let outfit: Outfit
    var eventNote: String?
}
