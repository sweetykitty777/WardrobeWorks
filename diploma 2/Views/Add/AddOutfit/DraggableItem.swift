//
//  DraggableItem.swift
//  diploma
//
//  Created by Olga on 10.03.2025.
//

import SwiftUI

struct DraggableItem: View {
    @Binding var item: OutfitItem
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    var canvasSize: CGSize // ✅ Размер холста

    var body: some View {
        VStack {
            if let uiImage = UIImage(named: item.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100 * item.scale, height: 100 * item.scale)
                    .rotationEffect(.degrees(item.rotation + rotation)) // ✅ Учитываем текущее вращение
                    .offset(offset)
                    .position(x: item.position.x, y: item.position.y)
                    .gesture(dragGesture)
                    .gesture(magnificationGesture)
                    .gesture(rotationGesture)
            } else {
                Image(systemName: "photo") // ✅ Заглушка, если изображение не найдено
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .overlay(
                        Text("Изображение не найдено")
                            .font(.caption)
                            .foregroundColor(.red)
                    )
            }
        }
        .onAppear {
            print("Загружаем изображение: \(item.imageName)")
        }
    }

    // ✅ Жест перетаскивания
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let newX = item.position.x + gesture.translation.width
                let newY = item.position.y + gesture.translation.height

                if isWithinBounds(newX: newX, newY: newY, item: item) {
                    offset = gesture.translation
                }
            }
            .onEnded { _ in
                item.position.x += offset.width
                item.position.y += offset.height
                offset = .zero
            }
    }

    // ✅ Жест увеличения
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = item.scale * value.magnitude
                if newScale > 0.5 && newScale < 3.0 { // ✅ Ограничение масштаба (0.5x - 3x)
                    scale = value.magnitude
                }
            }
            .onEnded { _ in
                item.scale *= scale
                scale = 1.0
            }
    }

    // ✅ Жест вращения
    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { angle in
                rotation = angle.degrees
            }
            .onEnded { _ in
                item.rotation += rotation
                rotation = 0.0
            }
    }

    /// ✅ Проверяем, находится ли объект в границах холста
    private func isWithinBounds(newX: CGFloat, newY: CGFloat, item: OutfitItem) -> Bool {
        let halfWidth = (50 * item.scale)
        let halfHeight = (50 * item.scale)

        return newX >= halfWidth &&
               newX <= (canvasSize.width - halfWidth) &&
               newY >= halfHeight &&
               newY <= (canvasSize.height - halfHeight)
    }
}

