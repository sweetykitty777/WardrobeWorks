import Foundation
import SwiftUI
import Combine

class OutfitViewModel: ObservableObject {
    @Published var outfits: [OutfitResponse] = []

    func addOutfit(name: String, description: String, wardrobeId: Int, placedItems: [PlacedClothingItem]) {
        let clothesData = placedItems.map { item in
            return [
                "clothId": item.clothId,
                "x": item.x,
                "y": item.y,
                "rotation": item.rotation,
                "scale": item.scale,
                "zindex": item.zIndex
            ] as [String: Any]
        }

        let payload: [String: Any] = [
            "name": name,
            "description": description,
            "wardrobeId": wardrobeId,
            "imagePath": "", 
            "clothes": clothesData
        ]

        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/outfits/create") else {
            print("Невалидный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

       /* if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }*/

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Ошибка сериализации: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка запроса: \(error)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Нет ответа от сервера")
                    return
                }

                print("Ответ сервера: \(httpResponse.statusCode)")
                if let data = data {
                    print("Ответ: \(String(data: data, encoding: .utf8) ?? "—")")
                }

                if (200..<300).contains(httpResponse.statusCode) {
                    print("Аутфит успешно создан")
                } else {
                    print("Сервер вернул ошибку")
                }
            }
        }.resume()
    }

    func fetchOutfits(for wardrobeId: Int) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/outfits/wardrobe=\(wardrobeId)/all") else {
            print("Невалидный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка запроса: \(error)")
                    return
                }

                guard let data = data else {
                    print("Пустой ответ от сервера")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)

                        if let date = formatter.date(from: dateStr) {
                            return date
                        } else {
                            throw DecodingError.dataCorruptedError(
                                in: container,
                                debugDescription: "Invalid ISO8601 date: \(dateStr)"
                            )
                        }
                    }

                    let fetchedOutfits = try decoder.decode([OutfitResponse].self, from: data)
                    self.outfits = fetchedOutfits
                    print("Аутфиты успешно загружены: \(fetchedOutfits.count)")
                } catch {
                    print("Ошибка декодирования: \(error)")
                    if let raw = String(data: data, encoding: .utf8) {
                        print("Ответ сервера:\n\(raw)")
                    }
                }
            }
        }.resume()
    }


    func removeOutfit(_ outfit: OutfitResponse) {
        outfits.removeAll { $0.id == outfit.id }
        print("Аутфит удален: \(outfit.name)")
    }
}
