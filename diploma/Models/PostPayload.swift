//
//  PostPayload.swift
//  diploma
//
//  Created by Olga on 24.04.2025.
//

import Foundation
struct PostPayload: Codable {
    let text: String
    let postImages: [PostImagePayload]
}
