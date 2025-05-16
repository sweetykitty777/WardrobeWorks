//
//  CreateClothingItemRequest.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import Foundation

struct CreateClothingItemRequest: Codable {
    let name: String
    let price: Int
    let typeId: Int
    let colourId: Int
    let seasonId: Int
    let brandId: Int
    let description: String
    let imagePath: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case price
        case typeId = "type_id"
        case colourId = "colour_id"
        case seasonId = "season_id"
        case brandId = "brand_id"
        case description
        case imagePath = "image_path"
    }
}
