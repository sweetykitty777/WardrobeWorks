//
//  OutfitCollections.swift
//  diploma
//
//  Created by Olga on 03.03.2025.
//

import Foundation

struct OutfitCollection: Identifiable {
    let id = UUID()
    var name: String
    var outfits: [Outfit]
}
