//
//  ClothItem.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import Foundation

struct ClothItem: Identifiable, Decodable {
    var id: Int
    var createdAt: String?
    var description: String?
    var imagePath: String
    var price: Int?
    var numberOfWear: Int?
    var wardrobeId: Int?

    var typeName: String?
    var colourName: String?
    var seasonName: String?
    var brandName: String?

    var category: String {
        return typeName ?? "Без категории"
    }
}
