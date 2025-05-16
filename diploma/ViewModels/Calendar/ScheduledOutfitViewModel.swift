import Foundation
import SwiftUI
import PostHog

class ScheduledOutfitViewModel: ObservableObject {
    @Published var scheduledOutfit: ScheduledOutfitResponse?
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var toastColor: Color = .black

    private var onDelete: (() -> Void)?

    init(scheduledOutfit: ScheduledOutfitResponse?, onDelete: (() -> Void)? = nil) {
        self.scheduledOutfit = scheduledOutfit
        self.onDelete = onDelete
    }

    func deleteScheduled() {
        guard let id = scheduledOutfit?.id else { return }

        PostHogSDK.shared.capture("scheduled_outfit_deletion_attempt", properties: [
            "scheduled_outfit_id": id
        ])

        WardrobeService.shared.deleteScheduledOutfit(entryId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.toast("Удалено", color: .green)
                    PostHogSDK.shared.capture("scheduled_outfit_deleted", properties: [
                        "scheduled_outfit_id": id
                    ])
                    self.scheduledOutfit = nil
                    self.onDelete?()
                case .failure(let error):
                    self.toast("Ошибка: \(error.localizedDescription)", color: .red)
                    PostHogSDK.shared.capture("scheduled_outfit_deletion_failed", properties: [
                        "scheduled_outfit_id": id,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    private func toast(_ message: String, color: Color) {
        toastMessage = message
        toastColor = color
        showToast = true
    }
}
