//
//  DraggableItemStaticView.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

struct DraggableItemStaticView: View {
    let item: PlacedClothingItem
    let imageURL: String

    var body: some View {
        RemoteImageView(urlString: imageURL, width: 100 * item.scale, height: 100 * item.scale)
            .rotationEffect(.degrees(item.rotation))
            .position(x: item.x, y: item.y)
    }
}
