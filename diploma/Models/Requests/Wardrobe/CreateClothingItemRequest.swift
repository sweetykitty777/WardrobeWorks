//
//  CreateClothingItemRequest.swift
//  diploma
//
//  Created by Olga on 21.04.2025.
//

import Foundation

struct CreateClothingItemRequest: Codable {
    let price: Int
    let typeId: Int
    let colourId: Int
    let seasonId: Int
    let brandId: Int
    let description: String
    let imagePath: String
} 