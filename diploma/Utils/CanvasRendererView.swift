//
//  CanvasRendererView.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

struct CanvasRendererView: View {
    let items: [PlacedClothingItem]
    let images: [Int: UIImage]
    let canvasSize: CGSize

    var body: some View {
        ZStack {
            Color.white

            ForEach(items, id: \.clothId) { item in
                if let image = images[item.clothId] {
                    Image(uiImage: image)
                        .resizable()
                        .frame(
                            width: 100 * item.scale,
                            height: 100 * item.scale
                        )
                        .rotationEffect(.degrees(item.rotation))
                        .position(x: item.x, y: item.y)
                    
                } 
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }
}
