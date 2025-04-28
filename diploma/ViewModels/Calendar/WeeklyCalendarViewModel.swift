import Foundation
import Combine
import SwiftUI

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
        guard let startOfWeek = currentWeek.first?.date,
              let endOfWeek = currentWeek.last?.date else { return "" }
        return "\(startOfWeek.formattedShort) - \(endOfWeek.formattedShort)"
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
            case .success(let fetched):
                self.scheduledOutfits = fetched
                self.selectedScheduledOutfit = fetched.first {
                    self.calendarSystem.isDate($0.date, inSameDayAs: self.selectedDate)
                }
            case .failure(let error):
                print("Не удалось загрузить запланированные аутфиты: \(error.localizedDescription)")
            }
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        currentWeek = currentWeek.map { day in
            CalendarDay(
                date: day.date,
                isSelected: calendarSystem.isDate(day.date, inSameDayAs: date),
                isToday: calendarSystem.isDateInToday(day.date)
            )
        }
        selectedScheduledOutfit = scheduledOutfits.first {
            calendarSystem.isDate($0.date, inSameDayAs: date)
        }
    }

    func changeWeek(by value: Int) {
        if let newDate = calendarSystem.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
            selectedDate = newDate
            updateCurrentWeek()
        }
    }

    func fetchCalendar(completion: (() -> Void)? = nil) {
        CalendarService.shared.fetchCalendars { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let calendars):
                    self.calendar = calendars.first
                    completion?()
                case .failure(let error):
                    print("Ошибка загрузки календаря: \(error.localizedDescription)")
                    completion?()
                }
            }
        }
    }


    func fetchScheduledOutfits(completion: @escaping (Result<[ScheduledOutfitResponse], Error>) -> Void) {
        guard let calendarId = calendar?.id else {
            print("Календарь ещё не загружен")
            completion(.failure(NSError(domain: "No calendar available", code: 404)))
            return
        }

        CalendarService.shared.fetchCalendarEntries(calendarId: calendarId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    print("Загружено \(entries.count) записей календаря")
                    completion(.success(entries))
                case .failure(let error):
                    print("Ошибка при загрузке записей календаря: \(error.localizedDescription)")
                    completion(.failure(error))
                }
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
    }
}
