//
//  UserProfile.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation

struct UserProfile: Codable, Identifiable, Hashable {
    let id: Int
    var username: String
    var bio: String?
    var avatar: String?
}
