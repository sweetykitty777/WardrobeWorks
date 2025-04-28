//
//  ClothesViewModel.swift
//  diploma
//
//  Created by Olga on 21.04.2025.
//

import Foundation
import SwiftUI

class ClothesViewModel: ObservableObject {
    @Published var clothes: [ClothItem] = []

    func fetchClothes(for wardrobeId: Int) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/clothes/\(wardrobeId)/all") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([ClothItem].self, from: data)
                    DispatchQueue.main.async {
                        self.clothes = decoded
                    }
                } catch {
                    print("Ошибка декодирования: \(error)")
                }
            } else if let error = error {
                print("Ошибка сети: \(error)")
            }
        }.resume()
    }
}
