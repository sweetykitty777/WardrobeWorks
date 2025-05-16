//
//  Post.swift
//  diploma
//
//  Created by Olga on 11.03.2025.
//

import Foundation

struct Post: Identifiable {
    let id = UUID()
    var outfit: Outfit
    var likes: Int
    var comments: [String]
    var description: String? // ✅ Опциональное описание
    var author: String // ✅ Автор поста

    init(outfit: Outfit, likes: Int = 0, comments: [String] = [], description: String? = nil, author: String) {
        self.outfit = outfit
        self.likes = likes
        self.comments = comments
        self.description = description
        self.author = author
    }
}
