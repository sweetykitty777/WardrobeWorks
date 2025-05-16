//
//  Post.swift
//  diploma
//
//  Created by Olga on 24.04.2025.
//

import Foundation

struct Post: Identifiable, Decodable {
    let id: Int
    let user: Int
    let createdAt: String
    var text: String?
    let images: [String]
    var outfits: [Int]
    var likes: Int
    var isLiked: Bool
}
