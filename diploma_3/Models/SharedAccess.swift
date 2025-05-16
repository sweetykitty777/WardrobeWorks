//
//  SharedAccess.swift
//  diploma
//
//  Created by Olga on 21.04.2025.
//

import Foundation

struct SharedAccess: Identifiable, Codable {
    let id: Int
    let wardrobeId: Int
    let grantedToUserId: Int
    let accessType: String
}
