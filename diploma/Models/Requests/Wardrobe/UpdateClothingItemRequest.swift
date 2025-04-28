//
//  UpdateClothingItemRequest.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import Foundation

struct UpdateClothingItemRequest: Codable {
    let price: Int?
    let typeId: Int?
    let colourId: Int?
    let seasonId: Int?
    let brandId: Int?
    let description: String?
}
