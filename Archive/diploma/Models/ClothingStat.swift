//
//  ClothingStat.swift
//  diploma
//
//  Created by Olga on 01.02.2025.
//

import Foundation

struct ClothingStat: Identifiable, Codable {
    let id: UUID
    let clothingItem: String
    let usageCount: Int
}
