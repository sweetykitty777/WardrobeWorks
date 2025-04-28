import Foundation
import SwiftUI

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

        CalendarService.shared.deleteScheduledOutfit(entryId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.toast("🗑️ Удалено", color: .green)
                    self.scheduledOutfit = nil
                    self.onDelete?() // 🔥 ВАЖНО: теперь после удаления обновляем календарь
                case .failure(let error):
                    self.toast("❌ Ошибка: \(error.localizedDescription)", color: .red)
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
