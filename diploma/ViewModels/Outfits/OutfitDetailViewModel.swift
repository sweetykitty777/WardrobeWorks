import Foundation
import SwiftUI
import PostHog

@MainActor
class OutfitDetailViewModel: ObservableObject {
    let outfit: OutfitResponse

    @Published var clothes: [ClothItem] = []
    @Published var scheduledDates: [Date] = []
    @Published var showShareSheet = false
    @Published var imageToShare: UIImage?
    @Published var textToShare: String? = nil
    @Published var isDeleting = false
    @Published var showDeleteErrorAlert = false
    @Published var showDatePicker = false
    @Published var selectedDate = Date()
    @Published var showEditView = false

    init(outfit: OutfitResponse) {
        self.outfit = outfit
    }

    func loadInitialData() {
        fetchOutfitClothes()
        fetchScheduledDates()

        PostHogSDK.shared.capture("outfit detail opened", properties: [
            "outfit_id": outfit.id,
            "outfit_name": outfit.name
        ])
    }

    func fetchOutfitClothes() {
        WardrobeService.shared.fetchOutfitClothes(outfitId: outfit.id) { [weak self] result in
            if case let .success(items) = result {
                self?.clothes = items
                PostHogSDK.shared.capture("outfit clothes loaded", properties: [
                    "outfit_id": self?.outfit.id ?? 0,
                    "items_count": items.count
                ])
            }
        }
    }

    func fetchScheduledDates() {
        WardrobeService.shared.fetchScheduledDates(for: outfit.id) { [weak self] dates in
            self?.scheduledDates = dates
            PostHogSDK.shared.capture("outfit scheduled dates loaded", properties: [
                "outfit_id": self?.outfit.id ?? 0,
                "dates_count": dates.count
            ])
        }
    }

    func deleteOutfit(completion: @escaping (Bool) -> Void) {
        isDeleting = true
        WardrobeService.shared.deleteOutfit(id: outfit.id) { [weak self] result in
            self?.isDeleting = false
            if case .failure = result {
                self?.showDeleteErrorAlert = true
                PostHogSDK.shared.capture("outfit delete failed", properties: [
                    "outfit_id": self?.outfit.id ?? 0
                ])
                completion(false)
            } else {
                PostHogSDK.shared.capture("outfit deleted", properties: [
                    "outfit_id": self?.outfit.id ?? 0
                ])
                completion(true)
            }
        }
    }

    func deleteCalendarEntry(for date: Date) {
        WardrobeService.shared.deleteCalendarEntry(for: outfit.id, date: date) { [weak self] success in
            if success {
                self?.scheduledDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
                PostHogSDK.shared.capture("calendar entry deleted", properties: [
                    "outfit_id": self?.outfit.id ?? 0,
                    "date": ISO8601DateFormatter().string(from: date)
                ])
            } else {
                print("❌ Не удалось удалить запись из календаря.")
                PostHogSDK.shared.capture("calendar entry delete failed", properties: [
                    "outfit_id": self?.outfit.id ?? 0,
                    "date": ISO8601DateFormatter().string(from: date)
                ])
            }
        }
    }

    func shareImage(from urlString: String) {
        PostHogSDK.shared.capture("outfit share started", properties: [
            "outfit_id": outfit.id,
            "url": urlString
        ])

        ImageShareService.fetchImage(from: urlString) { [weak self] image in
            guard let self = self else { return }

            self.imageToShare = image
            self.textToShare = "Сделано в WardrobeWorks"
            self.showShareSheet = image != nil
        }
    }

    func scheduleOutfitDate() {
        WardrobeService.shared.scheduleOutfit(outfitId: outfit.id, date: selectedDate) { [weak self] result in
            if case .success = result {
                self?.fetchScheduledDates()
                self?.showDatePicker = false
                PostHogSDK.shared.capture("outfit scheduled on date", properties: [
                    "outfit_id": self?.outfit.id ?? 0,
                    "date": ISO8601DateFormatter().string(from: self?.selectedDate ?? Date())
                ])
            } else {
                PostHogSDK.shared.capture("outfit schedule failed", properties: [
                    "outfit_id": self?.outfit.id ?? 0,
                    "date": ISO8601DateFormatter().string(from: self?.selectedDate ?? Date())
                ])
            }
        }
    }
}
