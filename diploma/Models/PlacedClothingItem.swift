//
//  PlacedClothingItem.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

struct PlacedClothingItem: Identifiable, Codable {
    var id: UUID = UUID()
    let clothId: Int
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
    var zIndex: Int
}
