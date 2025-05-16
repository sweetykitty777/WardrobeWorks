//
//  OutfitResponse.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation

struct OutfitResponse: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let description: String
    let createdAt: Date?
    let imagePath: String?

    static func == (lhs: OutfitResponse, rhs: OutfitResponse) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
