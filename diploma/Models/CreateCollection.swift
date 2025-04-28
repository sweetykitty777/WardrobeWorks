//
//  CreateCollection.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation

struct CreateCollection: Identifiable {
    let id = UUID()
    var name: String
    var wardrobeId: Int
    var outfits: [OutfitResponse]
}
