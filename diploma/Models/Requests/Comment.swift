//
//  Comment.swift
//  diploma
//
//  Created by Olga on 25.04.2025.
//

import Foundation

struct Comment: Identifiable, Decodable {
    let id: Int
    let user: UserProfile
    let text: String
    let createdAt: String
}
