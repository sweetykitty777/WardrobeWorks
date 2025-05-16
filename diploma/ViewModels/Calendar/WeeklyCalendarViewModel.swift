import Foundation
import Combine
import SwiftUI
import PostHog

class WeeklyCalendarViewModel: ObservableObject {
    @Published var currentWeek: [CalendarDay] = []
    @Published var selectedDate: Date = Date()
    @Published var clothingStats: [ClothingStat] = []
    @Published var clothingItems: [ClothingItem] = []
    @Published var selectedOutfit: Outfit? = nil
    @Published var selectedScheduledOutfit: ScheduledOutfitResponse? = nil
    @Published var sharedAccesses: [SharedAccess] = []
    @Published var scheduledOutfits: [ScheduledOutfitResponse] = []
    @Published var calendar: UserCalendar? = nil

    private var calendarSystem: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        return calendar
    }

    var weekRange: String {
        guard let start = currentWeek.first?.date, let end = currentWeek.last?.date else { return "" }
        return "\(start.formattedShort) - \(end.formattedShort)"
    }

    func updateCurrentWeek() {
        guard let weekInterval = calendarSystem.dateInterval(of: .weekOfYear, for: selectedDate) else { return }

        let today = Date()
        currentWeek = (0..<7).compactMap { offset in
            if let date = calendarSystem.date(byAdding: .day, value: offset, to: weekInterval.start) {
                return CalendarDay(
                    date: date,
                    isSelected: calendarSystem.isDate(date, inSameDayAs: selectedDate),
                    isToday: calendarSystem.isDate(date, inSameDayAs: today)
                )
            }
            return nil
        }

        fetchScheduledOutfits { result in
            switch result {
            case .success(let outfits):
                self.scheduledOutfits = outfits
                self.selectedScheduledOutfit = outfits.first {
                    self.calendarSystem.isDate($0.date, inSameDayAs: self.selectedDate)
                }
                PostHogSDK.shared.capture("calendar_week_loaded", properties: [
                    "week_start": weekInterval.start.formattedShort,
                    "scheduled_outfits_count": outfits.count
                ])
            case .failure(let error):
                print("Не удалось загрузить запланированные аутфиты: \(error.localizedDescription)")
                PostHogSDK.shared.capture("calendar_week_load_failed", properties: [
                    "error": error.localizedDescription
                ])
            }
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        currentWeek = currentWeek.map {
            CalendarDay(
                date: $0.date,
                isSelected: calendarSystem.isDate($0.date, inSameDayAs: date),
                isToday: calendarSystem.isDateInToday($0.date)
            )
        }
        selectedScheduledOutfit = scheduledOutfits.first {
            calendarSystem.isDate($0.date, inSameDayAs: date)
        }

        PostHogSDK.shared.capture("calendar_date_selected", properties: [
            "selected_date": date.formattedShort,
            "has_outfit": selectedScheduledOutfit != nil
        ])
    }

    func changeWeek(by value: Int) {
        if let newDate = calendarSystem.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
            selectedDate = newDate
            updateCurrentWeek()
            PostHogSDK.shared.capture("calendar_week_changed", properties: ["offset": value])
        }
    }

    func fetchCalendar(completion: (() -> Void)? = nil) {
        WardrobeService.shared.fetchCalendars { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let calendars):
                    self.calendar = calendars.first
                    completion?()
                    PostHogSDK.shared.capture("calendar_loaded", properties: [
                        "calendars_found": calendars.count
                    ])
                case .failure(let error):
                    print("Ошибка загрузки календаря: \(error.localizedDescription)")
                    PostHogSDK.shared.capture("calendar_load_failed", properties: [
                        "error": error.localizedDescription
                    ])
                    completion?()
                }
            }
        }
    }

    func fetchScheduledOutfits(completion: @escaping (Result<[ScheduledOutfitResponse], Error>) -> Void) {
        guard let calendarId = calendar?.id else {
            completion(.failure(NSError(domain: "No calendar", code: 404)))
            return
        }

        WardrobeService.shared.fetchCalendarEntries(calendarId: calendarId) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    var totalItems: Int {
        clothingStats.count
    }

    var weeklyUsage: Int {
        clothingStats.reduce(0) { $0 + $1.usageCount }
    }

    var mostPopularItem: String {
        clothingStats.max { $0.usageCount < $1.usageCount }?.clothingItem ?? "Нет данных"
    }

    func addClothingItem(name: String, image: UIImage?) {
        let newItem = ClothingItem(name: name)
        clothingItems.append(newItem)

        PostHogSDK.shared.capture("calendar_item_added", properties: ["name": name])
    }
}
