//
//  FullOutfitResponse.swift
//  diploma
//
//  Created by Olga on 07.05.2025.
//
import Foundation

struct FullOutfitResponse: Codable {
    let id: Int
    let name: String
    let description: String
    let createdAt: Date?
    let imagePath: String?
    let clothes: [OutfitClothLayoutItem]
}

struct OutfitClothLayoutItem: Codable {
    let cloth_id: Int
    let imagePath: String
    let x: Double
    let y: Double
    let rotation: Double
    let scale: Double
    let zindex: Int
}
