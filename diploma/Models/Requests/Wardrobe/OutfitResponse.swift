//
//  OutfitResponse.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation

struct OutfitResponse: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let createdAt: Date?
    let imagePath: String?
}
