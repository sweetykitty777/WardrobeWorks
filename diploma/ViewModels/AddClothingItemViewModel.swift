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
    @Published var price: String = ""
    @Published var purchaseDate: Date = Date()
    @Published var note: String = ""

    let colors = ["Красный", "Синий", "Зелёный", "Чёрный", "Белый"]
    let seasons = ["Лето", "Зима", "Осень", "Весна"]

    func saveClothingItem() {
        let newItem = ClothingItem(
            name: itemName,
            image: selectedImage,
            category: category,
            brand: brand,
            color: color,
            season: season,
            price: price,
            purchaseDate: purchaseDate,
            note: note
        )
        print("Вещь сохранена: \(newItem)")
    }
}
