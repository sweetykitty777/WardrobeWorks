//
//  Post.swift
//  diploma
//
//  Created by Olga on 24.04.2025.
//

import Foundation

struct Post: Identifiable, Decodable {
    let id: Int
    let user: Int                // ID автора
    let createdAt: String        // ISO-строка
    let text: String
    let images: [String]
    var likes: Int               // текущее число лайков
    var isLiked: Bool            // новое поле!

    // Мы не пишем свой инициализатор, Codable сгенерирует его автоматически
}
