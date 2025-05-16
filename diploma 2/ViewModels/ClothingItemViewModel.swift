//
//  ClothingItemViewModel.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import SwiftUI
import Combine
import UIKit

class ClothingItemsViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []

    func addClothingItem(name: String, image: UIImage?) {
        let newItem = ClothingItem(name: name, image: image)
        clothingItems.append(newItem)
    }

    func removeClothingItem(_ item: ClothingItem) {
        clothingItems.removeAll { $0.id == item.id }
    }
}

