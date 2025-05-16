//
//  ErasePoint.swift
//  diploma
//
//  Created by Olga on 02.05.2025.
//

import Foundation
import SwiftUI

struct ErasePoint: Identifiable, Hashable {
    let id = UUID()
    let point: CGPoint
    let size: CGFloat

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(point.x)
        hasher.combine(point.y)
        hasher.combine(size)
    }

    static func == (lhs: ErasePoint, rhs: ErasePoint) -> Bool {
        lhs.id == rhs.id &&
        lhs.point == rhs.point &&
        lhs.size == rhs.size
    }
}
