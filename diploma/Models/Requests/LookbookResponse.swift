//
//  LookbookResponse.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation

struct LookbookResponse: Identifiable, Codable, Hashable {
    let id: Int
    let wardrobeId: Int
    let createdAt: Date?
    let name: String
    let description: String
}
