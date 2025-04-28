//
//  CalendarPrivacyViewModel.swift
//  diploma
//
//  Created by Olga on 27.04.2025.
//

import Foundation
import SwiftUI

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

    func changePrivacy() {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/calendar/\(calendarId)/change-privacy?calendarId=\(calendarId)") else {
            print("Невалидный URL")
            return
        }

        print("PATCH \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка запроса: \(error.localizedDescription)")
                    self.showToast("Ошибка обновления", color: .red)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📬 Код ответа: \(httpResponse.statusCode)")
                    if (200...299).contains(httpResponse.statusCode) {
                        self.showToast("✅ Успешно обновлено", color: .green)
                    } else {
                        self.showToast("❌ Ошибка сервера", color: .red)
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
