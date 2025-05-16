//
//  ScheduledOutfitResponse.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation

struct ScheduledOutfitResponse: Codable, Identifiable {
    let id: Int
    let userId: Int
    let outfit: OutfitResponse
    let date: Date
    let eventNote: String?
    let calendarId: Int

    enum CodingKeys: String, CodingKey {
        case id, userId, outfit, date, eventNote, calendarId
    }
}

