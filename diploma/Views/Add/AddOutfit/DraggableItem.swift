import SwiftUI

struct DraggableItem: View {
    @Binding var item: PlacedClothingItem
    var imageURL: String
    var canvasSize: CGSize
    var onDelete: () -> Void

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var isSelected: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CachedImageView(
                urlString: imageURL,
                width: 100 * item.scale,
                height: 100 * item.scale
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
            )
            .overlay(
                Group {
                    if isSelected {
                        Button(action: {
                            onDelete()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .offset(x: 8, y: -8)
                    }
                },
                alignment: .topTrailing
            )
            .rotationEffect(.degrees(item.rotation + rotation))
            .offset(offset)
            .position(x: item.x, y: item.y)
            .gesture(dragGesture)
            .gesture(magnificationGesture)
            .gesture(rotationGesture)
            .onTapGesture {
                withAnimation {
                    isSelected.toggle()
                }
            }
        }
        .onAppear {
            if item.x == 0 && item.y == 0 {
                item.x = canvasSize.width / 2
                item.y = canvasSize.height / 2
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                offset = gesture.translation
            }
            .onEnded { _ in
                let newX = item.x + offset.width
                let newY = item.y + offset.height

                // Ограничим новые координаты рамками холста
                let halfWidth = (100 * item.scale) / 2
                let halfHeight = (100 * item.scale) / 2

                item.x = min(max(newX, halfWidth), canvasSize.width - halfWidth)
                item.y = min(max(newY, halfHeight), canvasSize.height - halfHeight)

                offset = .zero
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = value.magnitude
            }
            .onEnded { _ in
                let newScale = item.scale * scale
                item.scale = min(max(newScale, 0.3), 3.0) // Ограничим масштаб
                scale = 1.0
            }
    }

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
}

//import SwiftUI
//
//struct DraggableItem: View {
//    @Binding var item: PlacedClothingItem
//    var imageURL: String
//    var canvasSize: CGSize
//    var onDelete: () -> Void
//
//    @State private var offset: CGSize = .zero
//    @State private var scale: CGFloat = 1.0
//    @State private var rotation: Double = 0.0
//    @State private var isSelected: Bool = false
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            AsyncImage(url: URL(string: imageURL)) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(width: 100 * item.scale, height: 100 * item.scale)
//                case .success(let image):
//                    image
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100 * item.scale, height: 100 * item.scale)
//                        .background(Color.clear) // Прозрачный фон
//                case .failure:
//                    Image(systemName: "xmark.circle")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100 * item.scale, height: 100 * item.scale)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
//            )
//            .overlay(
//                Group {
//                    if isSelected {
//                        Button(action: {
//                            onDelete()
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(.red)
//                                .background(Color.white)
//                                .clipShape(Circle())
//                        }
//                        .offset(x: 8, y: -8)
//                    }
//                },
//                alignment: .topTrailing
//            )
//            .rotationEffect(.degrees(item.rotation + rotation))
//            .offset(x: item.x + offset.width, y: item.y + offset.height)
//            .gesture(dragGesture)
//            .gesture(magnificationGesture)
//            .gesture(rotationGesture)
//            .onTapGesture {
//                withAnimation {
//                    isSelected.toggle()
//                }
//            }
//        }
//    }
//
//    private var dragGesture: some Gesture {
//        DragGesture()
//            .onChanged { gesture in
//                offset = gesture.translation
//            }
//            .onEnded { _ in
//                let newPos = applyMovementConstraint(x: item.x + offset.width, y: item.y + offset.height, scale: item.scale)
//                item.x = newPos.x
//                item.y = newPos.y
//                offset = .zero
//            }
//    }
//
//    private var magnificationGesture: some Gesture {
//        MagnificationGesture()
//            .onChanged { value in
//                scale = value.magnitude
//            }
//            .onEnded { _ in
//                let newScale = item.scale * scale
//                let constrainedPos = applyMovementConstraint(x: item.x, y: item.y, scale: newScale)
//                item.scale = scaleConstrained(newScale)
//                item.x = constrainedPos.x
//                item.y = constrainedPos.y
//                scale = 1.0
//            }
//    }
//
//    private var rotationGesture: some Gesture {
//        RotationGesture()
//            .onChanged { angle in
//                rotation = angle.degrees
//            }
//            .onEnded { _ in
//                item.rotation += rotation
//                rotation = 0.0
//
//                let constrainedPos = applyMovementConstraint(x: item.x, y: item.y, scale: item.scale)
//                item.x = constrainedPos.x
//                item.y = constrainedPos.y
//            }
//    }
//
//    private func applyMovementConstraint(x: CGFloat, y: CGFloat, scale: CGFloat) -> CGPoint {
//        let size = 100 * scale
//        let half = size / 2
//
//        let minX = half
//        let maxX = canvasSize.width - half
//        let minY = half
//        let maxY = canvasSize.height - half
//
//        return CGPoint(
//            x: min(max(x, minX), maxX),
//            y: min(max(y, minY), maxY)
//        )
//    }
//
//    private func scaleConstrained(_ value: CGFloat) -> CGFloat {
//        min(max(value, 0.3), 3.0)
//    }
//}
