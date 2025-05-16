//
//  ClothingItem.swift
//  diploma
//
//  Created by Olga on 01.02.2025.
//

import Foundation
import SwiftUI

struct ClothingItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var image_str: String?
    var category: String?
    var brand: String?
    var color: String?
    var season: String?
    var price: String?
    var wardrobeId: Int?

    // ⚠️ Убираем image как часть модели данных, т.к. UIImage не Codable.
    // Для отображения image можно использовать computed property:
    var image: UIImage? {
        if let image_str = image_str, let uiImage = UIImage(named: image_str) {
            return uiImage
        }
        return nil
    }
}
