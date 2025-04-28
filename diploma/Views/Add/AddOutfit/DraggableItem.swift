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
            RemoteImageView(
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
            print("DraggableItem → clothId: \(item.clothId)")
            print("URL: \(imageURL)")
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                offset = gesture.translation
            }
            .onEnded { _ in
                item.x += offset.width
                item.y += offset.height
                offset = .zero
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = value.magnitude
            }
            .onEnded { _ in
                item.scale *= scale
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
