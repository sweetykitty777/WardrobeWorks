//  UserCalendarViewModel.swift
//  diploma
//
//  Created by Olga on 27.04.2025.

import Foundation
import SwiftUI

class UserCalendarViewModel: ObservableObject {
    @Published var scheduledOutfits: [ScheduledOutfitResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private var userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    func fetchCalendar() {
        isLoading = true
        errorMessage = nil

        CalendarService.shared.fetchUserCalendars(userId: userId) { (result: Result<[UserCalendar], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let calendars):
                    guard let firstCalendar = calendars.first else {
                        self.isLoading = false
                        self.errorMessage = "Нет доступных календарей у пользователя."
                        return
                    }
                    self.fetchCalendarEntries(calendarId: firstCalendar.id)
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchCalendarEntries(calendarId: Int) {
        CalendarService.shared.fetchCalendarEntries(calendarId: calendarId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let entries):
                    self.scheduledOutfits = entries
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
