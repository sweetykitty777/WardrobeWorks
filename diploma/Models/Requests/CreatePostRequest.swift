
//
//  CreatePostRequest.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

struct CreatePostRequest: Codable {
    let text: String
    let postImages: [PostImagePayload]
}
