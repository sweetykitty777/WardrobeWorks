//
//  Collection.swift
//  diploma
//
//  Created by Olga on 17.03.2025.
//

import Foundation
import Foundation

struct Collection: Identifiable {
    let id: UUID
    var name: String
    var outfits: [Outfit] // ✅ Коллекция хранит аутфиты

    init(id: UUID = UUID(), name: String, outfits: [Outfit] = []) {
        self.id = id
        self.name = name
        self.outfits = outfits
    }
}
