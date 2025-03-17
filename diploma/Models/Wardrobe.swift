//
//  Wardrobe.swift
//  diploma
//
//  Created by Olga on 09.03.2025.
//

import Foundation

struct Wardrobe: Identifiable, Hashable { // ✅ Добавляем `Hashable`
    let id = UUID()
    var name: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Wardrobe, rhs: Wardrobe) -> Bool {
        return lhs.id == rhs.id
    }
}
