//
//  OutfitItem.swift
//  diploma
//
//  Created by Olga on 10.03.2025.
//

import Foundation
import SwiftUI

struct OutfitItem: Identifiable {
    let id = UUID()
    var name: String?
    var imageName: String
    var position: CGPoint = CGPoint(x: 150, y: 150)
    var scale: CGFloat = 1.0
    var rotation: Double = 0.0
}
