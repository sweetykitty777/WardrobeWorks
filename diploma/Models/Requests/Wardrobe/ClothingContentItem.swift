//
//  ClothingContentItem.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//
import Foundation

protocol NamedItem: Identifiable {
    var name: String { get }
}

struct ClothingContentItem: Codable, Identifiable, NamedItem {
    let id: Int
    let name: String
}
