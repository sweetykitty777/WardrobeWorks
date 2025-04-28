//
//  UserPreview.swift
//  diploma
//
//  Created by Olga on 24.04.2025.
//

import Foundation
struct UserPreview: Identifiable, Decodable {
    let id: Int
    let username: String
    let bio: String
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case id, username, bio, avatar
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        username = try c.decodeIfPresent(String.self, forKey: .username) ?? ""
        bio      = try c.decodeIfPresent(String.self, forKey: .bio) ?? ""
        avatar   = try c.decodeIfPresent(String.self, forKey: .avatar) ?? ""
    }
}
