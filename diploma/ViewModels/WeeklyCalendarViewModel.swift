import Foundation
import Combine
import SwiftUI

class WeeklyCalendarViewModel: ObservableObject {
    @Published var currentWeek: [CalendarDay] = []
    @Published var selectedDate: Date = Date()
    @Published var clothingStats: [ClothingStat] = []
    @Published var clothingItems: [ClothingItem] = []
    
    private let calendar = Calendar.current
    
    var weekRange: String {
        guard let startOfWeek = currentWeek.first?.date,
              let endOfWeek = currentWeek.last?.date else { return "" }
        return "\(startOfWeek.formattedShort) - \(endOfWeek.formattedShort)"
    }
    
    func updateCurrentWeek() {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return }
        let today = Date()
        
        currentWeek = (0..<7).compactMap { offset in
            if let date = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) {
                return CalendarDay(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    isToday: calendar.isDate(date, inSameDayAs: today)
                )
            }
            return nil
        }
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        updateCurrentWeek()
    }
    
    func changeWeek(by value: Int) {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
            selectedDate = newDate
            updateCurrentWeek()
        }
    }
    
    func fetchClothingStats() {
            clothingStats = [
                ClothingStat(id: UUID(), clothingItem: "Blue Jeans", usageCount: 12),
                ClothingStat(id: UUID(), clothingItem: "White T-Shirt", usageCount: 20),
                ClothingStat(id: UUID(), clothingItem: "Black Jacket", usageCount: 5),
                ClothingStat(id: UUID(), clothingItem: "Sneakers", usageCount: 15),
                ClothingStat(id: UUID(), clothingItem: "Cap", usageCount: 8)
            ]
        }
    class WeeklyCalendarViewModel: ObservableObject {
        @Published var clothingItems: [ClothingItem] = []
        
        func addClothingItem(name: String, image: UIImage?) {
            let newItem = ClothingItem(name: name, image: image)
            clothingItems.append(newItem)
        }
    }
    
    var totalItems: Int {
            clothingStats.count
        }

        /// **Сколько использовали за неделю**
        var weeklyUsage: Int {
            clothingStats.reduce(0) { $0 + $1.usageCount }
        }

        /// **Самый популярный предмет одежды**
        var mostPopularItem: String {
            clothingStats.max { $0.usageCount < $1.usageCount }?.clothingItem ?? "Нет данных"
        }
    func addClothingItem(name: String, image: UIImage?) {
        let newItem = ClothingItem(name: name, image: image)
        clothingItems.append(newItem)
    }
}

