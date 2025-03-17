//
//  DruggableItem.swift
//  diploma
//
//  Created by Olga on 10.03.2025.
//

import Foundation
import SwiftUI

struct DraggableItem: View {
    @Binding var item: OutfitItem
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0

    var body: some View {
        Image(item.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100 * scale, height: 100 * scale)
            .rotationEffect(.degrees(rotation))
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        item.position.x += offset.width
                        item.position.y += offset.height
                        offset = .zero
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = value.magnitude
                    }
                    .onEnded { _ in
                        item.scale *= scale
                        scale = 1.0
                    }
            )
            .gesture(
                RotationGesture()
                    .onChanged { angle in
                        rotation = angle.degrees
                    }
                    .onEnded { _ in
                        item.rotation += rotation
                        rotation = 0.0
                    }
            )
    }
}
