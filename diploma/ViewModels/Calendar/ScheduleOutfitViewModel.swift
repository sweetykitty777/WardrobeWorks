import Foundation
import SwiftUI
import PostHog

class ScheduleOutfitViewModel: ObservableObject {
    let date: Date

    @Published var wardrobes: [UsersWardrobe] = []
    @Published var outfits: [OutfitResponse] = []
    @Published var selectedWardrobeId: Int?
    @Published var selectedOutfit: OutfitResponse?
    @Published var eventNote: String = ""
    @Published var isSubmitting = false

    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var toastColor: Color = .black

    var onSuccess: (() -> Void)?

    init(date: Date) {
        self.date = date
    }

    var selectedWardrobeName: String {
        if let id = selectedWardrobeId,
           let wardrobe = wardrobes.first(where: { $0.id == id }) {
            return wardrobe.name
        }
        return "Выбрать гардероб"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self?.wardrobes = fetched
                    PostHogSDK.shared.capture("wardrobes_fetched_for_scheduling", properties: [
                        "count": fetched.count
                    ])
                case .failure(let error):
                    self?.showToast("Ошибка гардеробов: \(error.localizedDescription)", color: .red)
                    PostHogSDK.shared.capture("wardrobes_fetch_failed", properties: [
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func selectWardrobe(_ wardrobe: UsersWardrobe) {
        selectedWardrobeId = wardrobe.id
        PostHogSDK.shared.capture("wardrobe_selected_for_scheduling", properties: [
            "wardrobe_id": wardrobe.id,
            "wardrobe_name": wardrobe.name
        ])
        fetchOutfits(for: wardrobe.id)
    }

    private func fetchOutfits(for wardrobeId: Int) {
        WardrobeService.shared.fetchOutfits(for: wardrobeId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outfits):
                    self?.outfits = outfits
                    PostHogSDK.shared.capture("outfits_fetched_for_scheduling", properties: [
                        "wardrobe_id": wardrobeId,
                        "count": outfits.count
                    ])
                case .failure(let error):
                    self?.showToast("Ошибка загрузки аутфитов: \(error.localizedDescription)", color: .red)
                    PostHogSDK.shared.capture("outfits_fetch_failed", properties: [
                        "wardrobe_id": wardrobeId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func submit(completion: @escaping () -> Void) {
        guard let outfit = selectedOutfit else { return }
        isSubmitting = true

        PostHogSDK.shared.capture("schedule_outfit_submit_attempt", properties: [
            "outfit_id": outfit.id,
            "scheduled_date": date.formatted(.iso8601),
            "note_length": eventNote.count
        ])

        WardrobeService.shared.scheduleOutfit(outfitId: outfit.id, date: date, note: self.eventNote) { result in
            DispatchQueue.main.async {
                self.isSubmitting = false
                switch result {
                case .success:
                    self.showToast("🎉 Аутфит запланирован!", color: .green)
                    PostHogSDK.shared.capture("schedule_outfit_success", properties: [
                        "outfit_id": outfit.id,
                        "scheduled_date": self.date.formatted(.iso8601)
                    ])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        completion()
                        self.onSuccess?()
                    }
                case .failure(let error):
                    self.showToast("Ошибка: \(error.localizedDescription)", color: .red)
                    PostHogSDK.shared.capture("schedule_outfit_failed", properties: [
                        "outfit_id": outfit.id,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func showToast(_ message: String, color: Color = .black) {
        toastMessage = message
        toastColor = color
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showToast = false
            }
        }
    }
}
