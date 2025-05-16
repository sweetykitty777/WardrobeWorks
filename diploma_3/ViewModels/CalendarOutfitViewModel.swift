//
//  CalendarOutfitViewModel.swift
//  diploma
//
//  Created by Olga on 23.03.2025.
//

import Foundation
class CalendarOutfitViewModel: ObservableObject {
    @Published var scheduledOutfits: [ScheduledOutfit] = []

    func schedule(outfit: Outfit, on date: Date, note: String) {
        let newEntry = ScheduledOutfit(date: date, outfit: outfit, eventNote: note)
        scheduledOutfits.append(newEntry)
    }

    func outfits(for date: Date) -> [ScheduledOutfit] {
        scheduledOutfits.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
