import Foundation
import SwiftUI
import PostHog

class UserCalendarViewModel: ObservableObject {
    @Published var scheduledOutfits: [ScheduledOutfitResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private var userId: Int
    private let calendar = Calendar.current

    init(userId: Int) {
        self.userId = userId
    }

    func fetchCalendar() {
        isLoading = true
        errorMessage = nil

        PostHogSDK.shared.capture("calendar_view_requested", properties: [
            "user_id": userId
        ])

        WardrobeService.shared.fetchUserCalendars(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let calendars):
                    guard let firstCalendar = calendars.first else {
                        self.isLoading = false
                        self.errorMessage = "Нет доступных календарей у пользователя."
                        PostHogSDK.shared.capture("calendar_view_failed", properties: [
                            "user_id": self.userId,
                            "reason": "no_calendars"
                        ])
                        return
                    }
                    self.fetchCalendarEntries(calendarId: firstCalendar.id)
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    PostHogSDK.shared.capture("calendar_view_failed", properties: [
                        "user_id": self.userId,
                        "reason": error.localizedDescription
                    ])
                }
            }
        }
    }

    private func fetchCalendarEntries(calendarId: Int) {
        WardrobeService.shared.fetchCalendarEntries(calendarId: calendarId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let entries):
                    self.scheduledOutfits = entries
                    PostHogSDK.shared.capture("calendar_entries_loaded", properties: [
                        "calendar_id": calendarId,
                        "entry_count": entries.count
                    ])
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    PostHogSDK.shared.capture("calendar_entries_failed", properties: [
                        "calendar_id": calendarId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func scheduledOutfit(for date: Date) -> ScheduledOutfitResponse? {
        let match = scheduledOutfits.first {
            calendar.isDate($0.date, inSameDayAs: date)
        }

        if let outfit = match {
            PostHogSDK.shared.capture("calendar_day_outfit_viewed", properties: [
                "date": ISO8601DateFormatter().string(from: date),
                "outfit_id": outfit.id
            ])
        }

        return match
    }
}
