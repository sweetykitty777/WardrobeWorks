//
//  Lookbook.swift
//  diploma
//
//  Created by Olga on 11.03.2025.
//

import Foundation

struct Lookbook: Identifiable {
    let id = UUID()
    let name: String
    var outfits: [Outfit]
}
