//
//  AddClothingItemViewModel.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI
import UIKit

class AddClothingItemViewModel: ObservableObject {
    @Published var itemName: String = ""
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var category: String = ""
    @Published var brand: String = ""
    @Published var color: String = ""
    @Published var season: String = ""
    @Published var wardrobeName: String = "" // 🆕 Добавлено поле гардероба
    @Published var price: String = ""
    @Published var purchaseDate: Date = Date()
    @Published var note: String = ""
    @Published var wardrobe: Wardrobe?


    let colors = ["Красный", "Синий", "Зелёный", "Чёрный", "Белый"]
    let seasons = ["Лето", "Зима", "Осень", "Весна"]

    func saveClothingItem(wardrobeId: Int, completion: @escaping () -> Void) {
        let request = CreateClothingItemRequest(
            name: itemName,
            price: Int(price) ?? 0,
            typeId: 0,
            colourId: 0,
            seasonId: 0,
            brandId: 0,
            description: note,
            imagePath: ""
        )

        WardrobeService.shared.createClothingItem(wardrobeId: wardrobeId, request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    completion()
                case .failure(let error):
                    print("Ошибка создания вещи: \(error)")
                }
            }
        }
    }

}
