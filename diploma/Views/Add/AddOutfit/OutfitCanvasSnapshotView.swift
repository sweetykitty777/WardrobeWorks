//
//  OutfitCanvasSnapshotView.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

struct OutfitCanvasSnapshotView: View {
    let placedItems: [PlacedClothingItem]
    let imageURLsByClothId: [Int: String]

    var body: some View {
        ZStack {
            ForEach(placedItems.indices, id: \.self) { index in
                if let url = imageURLsByClothId[placedItems[index].clothId] {
                    RemoteImageView(urlString: url)
                        .frame(width: 100 * placedItems[index].scale,
                               height: 100 * placedItems[index].scale)
                        .rotationEffect(.degrees(placedItems[index].rotation))
                        .position(x: placedItems[index].x,
                                  y: placedItems[index].y)
                }
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    var canvasSize: CGSize {
        // Минимальный холст, можно потом динамически вычислять
        CGSize(width: 400, height: 600)
    }
}
