import Foundation
import SwiftUI
import PostHog

class CalendarPrivacyViewModel: ObservableObject {
    @Published var isPrivate: Bool
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var toastColor: Color = .black

    private let calendarId: Int

    init(calendarId: Int, initialPrivacy: Bool) {
        self.calendarId = calendarId
        self.isPrivate = initialPrivacy
    }

    func setPrivacy(to newValue: Bool) {
        guard newValue != isPrivate else { return }
        changePrivacy(to: newValue)
    }

    private func changePrivacy(to newValue: Bool) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/calendar/\(calendarId)/change-privacy?calendarId=\(calendarId)") else {
            print("Невалидный URL")
            return
        }

        PostHogSDK.shared.capture("calendar_privacy_change_attempt", properties: [
            "calendar_id": calendarId,
            "attempt_to_set_private": newValue
        ])

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка запроса: \(error.localizedDescription)")
                    self.showToast("Ошибка обновления", color: .red)
                    PostHogSDK.shared.capture("calendar_privacy_change_failed", properties: [
                        "calendar_id": self.calendarId,
                        "error": error.localizedDescription
                    ])
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📬 Код ответа: \(httpResponse.statusCode)")
                    if (200...299).contains(httpResponse.statusCode) {
                        self.isPrivate = newValue
                        self.showToast("Успешно обновлено", color: .green)
                        PostHogSDK.shared.capture("calendar_privacy_changed", properties: [
                            "calendar_id": self.calendarId,
                            "new_privacy": newValue
                        ])
                    } else {
                        self.showToast("Ошибка сервера", color: .red)
                        PostHogSDK.shared.capture("calendar_privacy_change_failed", properties: [
                            "calendar_id": self.calendarId,
                            "error_code": httpResponse.statusCode
                        ])
                    }
                }
            }
        }.resume()
    }

    private func showToast(_ message: String, color: Color) {
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
