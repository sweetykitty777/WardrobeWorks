//
//  Wardrobe.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation
struct Wardrobe: Identifiable, Codable {
    let id: UUID
    let name: String
    let isPrivate: Bool
}
