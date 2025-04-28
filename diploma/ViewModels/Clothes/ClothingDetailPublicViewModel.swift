//
//  ClothingDetailPublicViewModel.swift
//  diploma
//
//  Created by Olga on 26.04.2025.
//

import Foundation
import SwiftUI

class ClothingDetailPublicViewModel: ObservableObject {
    @Published var wardrobes: [UsersWardrobe] = []

    func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    self.wardrobes = wardrobes
                case .failure(let error):
                    print("Ошибка загрузки гардеробов:", error)
                }
            }
        }
    }

    func copyItem(clothId: Int, to wardrobeId: Int, completion: @escaping () -> Void) {
        guard let token = KeychainHelper.get(forKey: "accessToken") else { return }
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/clothes/\(clothId)/copy/\(wardrobeId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка копирования:", error.localizedDescription)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        completion()
                    } else {
                        print("Сервер вернул ошибку при копировании: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
}
