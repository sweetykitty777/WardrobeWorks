//
//  CreateWardrobeRequest.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation
struct CreateWardrobeRequest: Codable {
    let name: String
    let description: String
    let isPrivate: Bool
}
