import SwiftUI

// MARK: - Модель точки стирания
struct ErasePoint: Identifiable, Hashable {
    let id = UUID()
    let point: CGPoint
    let size: CGFloat

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ErasePoint, rhs: ErasePoint) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Основное вью
struct BackgroundEraserView: View {
    let inputImage: UIImage
    let onFinish: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var erasePoints: [ErasePoint] = []
    @State private var brushSize: CGFloat = 40
    @State private var isAutoCropping = false
    @State private var progress: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            let imageSize = inputImage.size
            let containerSize = geometry.size
            let fittedSize = aspectFitSize(for: imageSize, in: containerSize)
            let imageRect = CGRect(
                x: (containerSize.width - fittedSize.width) / 2,
                y: (containerSize.height - fittedSize.height) / 2,
                width: fittedSize.width,
                height: fittedSize.height
            )

            ZStack {
                Color.white
                    .frame(width: fittedSize.width, height: fittedSize.height)
                    .position(x: containerSize.width / 2, y: containerSize.height / 2)

                Image(uiImage: inputImage)
                    .resizable()
                    .frame(width: fittedSize.width, height: fittedSize.height)
                    .position(x: containerSize.width / 2, y: containerSize.height / 2)
                    .compositingGroup()
                    .overlay(
                        ZStack {
                            ForEach(erasePoints) { erasePoint in
                                Circle()
                                    .fill(Color.white) // белая кисть
                                    .frame(width: erasePoint.size, height: erasePoint.size)
                                    .position(erasePoint.point)
                            }
                        }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if imageRect.contains(value.location) {
                                    erasePoints.append(ErasePoint(point: value.location, size: brushSize))
                                }
                            }
                    )

                VStack(spacing: 14) {
                    Spacer()

                    // MARK: - Размер кисти
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Размер кисти: \(Int(brushSize))")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Slider(value: $brushSize, in: 10...100)
                            .accentColor(.blue)
                    }
                    .padding(.horizontal)

                    // MARK: - Автообрезка
                    if isAutoCropping {
                        VStack(spacing: 8) {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding(.horizontal)

                            Text("Автообрезка изображения...")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 10)
                    } else {
                        Button(action: startAutoCrop) {
                            HStack {
                                Image(systemName: "scissors")
                                Text("Автообрезка")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }

                    // MARK: - Очистить всё
                    Button(action: {
                        erasePoints.removeAll()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Очистить всё")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }

                    // MARK: - Готово
                    Button("Готово") {
                        let finalImage = renderErasedImage(in: imageRect)
                        onFinish(finalImage)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
    }

    // MARK: - Автообрезка (заглушка)
    private func startAutoCrop() {
        isAutoCropping = true
        progress = 0.0

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if progress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAutoCropping = false
                    print("Автообрезка")
                }
            } else {
                progress += 0.02
            }
        }
    }

    // MARK: - Аспект-фит размеров
    private func aspectFitSize(for imageSize: CGSize, in containerSize: CGSize) -> CGSize {
        let aspectRatio = imageSize.width / imageSize.height
        let containerRatio = containerSize.width / containerSize.height

        if aspectRatio > containerRatio {
            let width = containerSize.width
            return CGSize(width: width, height: width / aspectRatio)
        } else {
            let height = containerSize.height
            return CGSize(width: height * aspectRatio, height: height)
        }
    }

    // MARK: - Применение стирания
    private func renderErasedImage(in imageRect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        return renderer.image { context in
            inputImage.draw(in: CGRect(origin: .zero, size: imageRect.size))

            context.cgContext.translateBy(x: -imageRect.origin.x, y: -imageRect.origin.y)
            context.cgContext.setBlendMode(.clear)

            for erasePoint in erasePoints {
                let point = erasePoint.point
                let size = erasePoint.size
                let rect = CGRect(
                    x: point.x - size / 2,
                    y: point.y - size / 2,
                    width: size,
                    height: size
                )
                context.cgContext.fillEllipse(in: rect)
            }
        }
    }
}
