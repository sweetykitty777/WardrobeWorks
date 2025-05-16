//
//  Post.swift
//  diploma
//
//  Created by Olga on 11.03.2025.
//

import Foundation


struct Post: Identifiable {
    let id = UUID()
    let author: String
    let date: Date
    var likes: Int
    var comments: [String]
    var outfit: Outfit?
    var lookbook: Lookbook?
}
