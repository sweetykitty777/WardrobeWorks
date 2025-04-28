import Foundation
import SwiftUI

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
                case .failure(let error):
                    self?.showToast("Ошибка гардеробов: \(error.localizedDescription)", color: .red)
                }
            }
        }
    }

    func selectWardrobe(_ wardrobe: UsersWardrobe) {
        selectedWardrobeId = wardrobe.id
        fetchOutfits(for: wardrobe.id)
    }

    private func fetchOutfits(for wardrobeId: Int) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/outfits/wardrobe=\(wardrobeId)/all") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showToast("Ошибка загрузки аутфитов: \(error.localizedDescription)", color: .red)
                    return
                }

                guard let data = data else {
                    self.showToast("Ошибка: нет данных от сервера", color: .red)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                    decoder.dateDecodingStrategy = .formatted(formatter)

                    self.outfits = try decoder.decode([OutfitResponse].self, from: data)
                } catch {
                    self.showToast("Ошибка декодирования: \(error.localizedDescription)", color: .red)
                }
            }
        }.resume()
    }

    func submit(completion: @escaping () -> Void) {
        guard let outfit = selectedOutfit else { return }
        isSubmitting = true

        CalendarService.shared.scheduleOutfit(outfitId: outfit.id, date: date, note: self.eventNote) { result in
            DispatchQueue.main.async {
                self.isSubmitting = false
                switch result {
                case .success:
                    self.showToast("🎉 Аутфит запланирован!", color: .green)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        completion()
                        self.onSuccess?() // Trigger additional fetch if needed
                    }
                case .failure(let error):
                    self.showToast("Ошибка: \(error.localizedDescription)", color: .red)
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
