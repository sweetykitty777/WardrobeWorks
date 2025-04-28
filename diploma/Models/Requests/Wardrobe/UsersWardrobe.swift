//
//  UsersWardrobe.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation

struct UsersWardrobe: Identifiable, Codable {
    var id: Int
    var creatorId: Int
    var createdAt: String
    var name: String          
    var description: String
    var isPrivate: Bool
}
