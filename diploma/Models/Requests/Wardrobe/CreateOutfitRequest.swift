//
//  CreateOutfitRequest.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation

struct CreateOutfitRequest: Codable {
    let name: String
    let description: String
    let wardrobeId: Int
    let imagePath: String
    let clothes: [OutfitClothPlacement]
}
