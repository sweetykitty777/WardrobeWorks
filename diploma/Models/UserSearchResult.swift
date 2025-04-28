//
//  UserSearchResult.swift
//  diploma
//
//  Created by Olga on 27.04.2025.
//

import Foundation

struct UserSearchResult: Codable, Identifiable {
    let id: Int
    let username: String
    let bio: String?
    let avatar: String?
}
